import 'package:serverpod/serverpod.dart';
import 'exception_factory.dart';
import 'generated/protocol.dart';

/// Utility class for inventory management operations
/// 
/// Provides atomic inventory operations with fractional quantity support
/// and flexible consumable type validation.
class InventoryUtil {
  /// Updates inventory balance for a specific account and consumable type
  /// 
  /// Supports fractional quantities for flexible pricing models.
  /// Creates new inventory record if none exists.
  /// 
  /// [accountId] - The account to update inventory for
  /// [consumableType] - Any string identifier for the consumable (no validation)
  /// [quantityDelta] - Amount to add (positive) or subtract (negative)
  /// [transaction] - Optional database transaction for atomicity
  /// 
  /// Returns the updated AccountInventory record
  /// 
  /// Throws [InventoryException] if:
  /// - Account not found
  /// - Insufficient balance for negative delta
  /// - Database operation fails
  static Future<AccountInventory> updateInventoryBalance(
    Session session, {
    required int accountId,
    required String consumableType,
    required double quantityDelta,
    Transaction? transaction,
  }) async {
    try {
      // Find existing inventory record
      final existingInventory = await AccountInventory.db.findFirstRow(
        session,
        where: (t) => t.accountId.equals(accountId) & 
                     t.consumableType.equals(consumableType),
        transaction: transaction,
      );

      if (existingInventory != null) {
        // Update existing record
        final newQuantity = existingInventory.quantity + quantityDelta;
        
        // Check for insufficient balance
        if (newQuantity < 0) {
          throw AnonAccredExceptionFactory.createInventoryException(
            code: AnonAccredErrorCodes.inventoryInsufficientBalance,
            message: 'Insufficient balance for consumable type: $consumableType',
            accountId: accountId,
            consumableType: consumableType,
            details: {
              'currentBalance': existingInventory.quantity.toString(),
              'requestedDelta': quantityDelta.toString(),
              'resultingBalance': newQuantity.toString(),
            },
          );
        }

        return await AccountInventory.db.updateRow(
          session,
          existingInventory.copyWith(
            quantity: newQuantity,
            lastUpdated: DateTime.now(),
          ),
          transaction: transaction,
        );
      } else {
        // Create new inventory record
        if (quantityDelta < 0) {
          throw AnonAccredExceptionFactory.createInventoryException(
            code: AnonAccredErrorCodes.inventoryInsufficientBalance,
            message: 'Cannot create inventory with negative balance for consumable type: $consumableType',
            accountId: accountId,
            consumableType: consumableType,
            details: {
              'requestedDelta': quantityDelta.toString(),
            },
          );
        }

        return await AccountInventory.db.insertRow(
          session,
          AccountInventory(
            accountId: accountId,
            consumableType: consumableType,
            quantity: quantityDelta,
          ),
          transaction: transaction,
        );
      }
    } catch (e) {
      if (e is InventoryException) {
        rethrow;
      }
      
      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccredErrorCodes.databaseError,
        message: 'Failed to update inventory balance: ${e.toString()}',
        accountId: accountId,
        consumableType: consumableType,
        details: {'error': e.toString()},
      );
    }
  }

  /// Gets current inventory balance for a specific consumable type
  /// 
  /// [accountId] - The account to check inventory for
  /// [consumableType] - The consumable type to check
  /// [transaction] - Optional database transaction
  /// 
  /// Returns the current quantity (0.0 if no inventory record exists)
  static Future<double> getInventoryBalance(
    Session session, {
    required int accountId,
    required String consumableType,
    Transaction? transaction,
  }) async {
    try {
      final inventory = await AccountInventory.db.findFirstRow(
        session,
        where: (t) => t.accountId.equals(accountId) & 
                     t.consumableType.equals(consumableType),
        transaction: transaction,
      );

      return inventory?.quantity ?? 0.0;
    } catch (e) {
      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccredErrorCodes.databaseError,
        message: 'Failed to get inventory balance: ${e.toString()}',
        accountId: accountId,
        consumableType: consumableType,
        details: {'error': e.toString()},
      );
    }
  }

  /// Gets all inventory records for an account
  /// 
  /// [accountId] - The account to get inventory for
  /// [transaction] - Optional database transaction
  /// 
  /// Returns list of AccountInventory records
  static Future<List<AccountInventory>> getAccountInventory(
    Session session, {
    required int accountId,
    Transaction? transaction,
  }) async {
    try {
      return await AccountInventory.db.find(
        session,
        where: (t) => t.accountId.equals(accountId),
        orderBy: (t) => t.consumableType,
        transaction: transaction,
      );
    } catch (e) {
      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccredErrorCodes.databaseError,
        message: 'Failed to get account inventory: ${e.toString()}',
        accountId: accountId,
        details: {'error': e.toString()},
      );
    }
  }

  /// Validates consumable type (accepts any string)
  /// 
  /// This method implements the requirement that any string identifier
  /// should be accepted as a valid consumable type without validation
  /// against predefined enums.
  /// 
  /// [consumableType] - The consumable type to validate
  /// 
  /// Returns true if valid (always true for non-empty strings)
  /// 
  /// Throws [InventoryException] if consumable type is empty or null
  static bool validateConsumableType(String? consumableType) {
    if (consumableType == null || consumableType.trim().isEmpty) {
      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccredErrorCodes.inventoryInvalidConsumable,
        message: 'Consumable type cannot be null or empty',
        consumableType: consumableType,
      );
    }
    
    // Accept any non-empty string as valid consumable type
    return true;
  }

  /// Performs atomic inventory operations within a transaction
  /// 
  /// Executes multiple inventory operations atomically to ensure consistency.
  /// All operations succeed or all fail together.
  /// 
  /// [operations] - List of inventory operations to perform
  /// 
  /// Returns list of updated AccountInventory records
  static Future<List<AccountInventory>> performAtomicInventoryOperations(
    Session session,
    List<InventoryOperation> operations,
  ) async {
    return await session.db.transaction((transaction) async {
      final results = <AccountInventory>[];
      
      for (final operation in operations) {
        validateConsumableType(operation.consumableType);
        
        final result = await updateInventoryBalance(
          session,
          accountId: operation.accountId,
          consumableType: operation.consumableType,
          quantityDelta: operation.quantityDelta,
          transaction: transaction,
        );
        
        results.add(result);
      }
      
      return results;
    });
  }
}

/// Represents a single inventory operation for atomic processing
class InventoryOperation {
  final int accountId;
  final String consumableType;
  final double quantityDelta;

  const InventoryOperation({
    required this.accountId,
    required this.consumableType,
    required this.quantityDelta,
  });
}