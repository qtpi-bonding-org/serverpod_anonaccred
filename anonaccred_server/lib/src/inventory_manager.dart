import 'package:serverpod/serverpod.dart';
import 'exception_factory.dart';
import 'generated/protocol.dart';

/// High-level inventory management service for AnonAccred commerce operations
///
/// Provides static methods for managing account inventory balances with
/// atomic operations and proper error handling. This class serves as the
/// primary interface for inventory operations in the commerce layer.
class InventoryManager {
  /// Adds items to an account's inventory with atomic operations
  ///
  /// Creates new inventory record if none exists, or increments existing balance.
  /// All operations are performed atomically within a database transaction.
  ///
  /// [session] - Serverpod session for database operations
  /// [accountId] - The account to add inventory to
  /// [consumableType] - String identifier for the consumable item
  /// [quantity] - Amount to add (must be positive)
  ///
  /// Throws [InventoryException] if:
  /// - Quantity is negative or zero
  /// - Account not found
  /// - Database operation fails
  static Future<void> addToInventory(
    Session session, {
    required int accountId,
    required String consumableType,
    required double quantity,
  }) async {
    if (quantity <= 0) {
      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccredErrorCodes.inventoryInvalidQuantity,
        message: 'Quantity must be positive for inventory addition',
        accountId: accountId,
        consumableType: consumableType,
        details: {'providedQuantity': quantity.toString()},
      );
    }

    try {
      await updateInventoryBalance(
        session,
        accountId: accountId,
        consumableType: consumableType,
        quantityDelta: quantity,
      );
    } catch (e) {
      if (e is InventoryException) {
        rethrow;
      }

      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccredErrorCodes.databaseError,
        message: 'Failed to add inventory: ${e.toString()}',
        accountId: accountId,
        consumableType: consumableType,
        details: {'error': e.toString()},
      );
    }
  }

  /// Gets all inventory records for an account
  ///
  /// Returns complete inventory list with all consumable types and balances.
  /// Returns empty list if account has no inventory records.
  ///
  /// [session] - Serverpod session for database operations
  /// [accountId] - The account to query inventory for
  ///
  /// Returns list of AccountInventory records ordered by consumable type
  static Future<List<AccountInventory>> getInventory(
    Session session,
    int accountId,
  ) async {
    try {
      return getAccountInventoryWithTransaction(session, accountId: accountId);
    } catch (e) {
      if (e is InventoryException) {
        rethrow;
      }

      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccredErrorCodes.databaseError,
        message: 'Failed to get inventory: ${e.toString()}',
        accountId: accountId,
        details: {'error': e.toString()},
      );
    }
  }

  /// Gets the current balance for a specific consumable type
  ///
  /// Returns the exact quantity available for the specified consumable type.
  /// Returns 0.0 if no inventory record exists for the consumable type.
  ///
  /// [session] - Serverpod session for database operations
  /// [accountId] - The account to check balance for
  /// [consumableType] - The consumable type to check
  ///
  /// Returns current balance as double
  static Future<double> getBalance(
    Session session, {
    required int accountId,
    required String consumableType,
  }) async {
    try {
      return await getInventoryBalanceWithTransaction(
        session,
        accountId: accountId,
        consumableType: consumableType,
      );
    } catch (e) {
      if (e is InventoryException) {
        rethrow;
      }

      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccredErrorCodes.databaseError,
        message: 'Failed to get balance: ${e.toString()}',
        accountId: accountId,
        consumableType: consumableType,
        details: {'error': e.toString()},
      );
    }
  }

  /// Updates inventory balance for a specific account and consumable type
  ///
  /// Supports fractional quantities for flexible pricing models.
  /// Creates new inventory record if none exists.
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
        where: (t) =>
            t.accountId.equals(accountId) &
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
            message:
                'Insufficient balance for consumable type: $consumableType',
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
            message:
                'Cannot create inventory with negative balance for consumable type: $consumableType',
            accountId: accountId,
            consumableType: consumableType,
            details: {'requestedDelta': quantityDelta.toString()},
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

  /// Gets current inventory balance for a specific consumable type (with transaction support)
  static Future<double> getInventoryBalanceWithTransaction(
    Session session, {
    required int accountId,
    required String consumableType,
    Transaction? transaction,
  }) async {
    try {
      final inventory = await AccountInventory.db.findFirstRow(
        session,
        where: (t) =>
            t.accountId.equals(accountId) &
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

  /// Gets all inventory records for an account (with transaction support)
  static Future<List<AccountInventory>> getAccountInventoryWithTransaction(
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
  static Future<List<AccountInventory>> performAtomicInventoryOperations(
    Session session,
    List<InventoryOperation> operations,
  ) => session.db.transaction((transaction) async {
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

/// Represents a single inventory operation for atomic processing
class InventoryOperation {
  const InventoryOperation({
    required this.accountId,
    required this.consumableType,
    required this.quantityDelta,
  });

  final int accountId;
  final String consumableType;
  final double quantityDelta;
}
