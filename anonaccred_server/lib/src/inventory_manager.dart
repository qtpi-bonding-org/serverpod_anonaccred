import 'package:serverpod/serverpod.dart';
import 'exception_factory.dart';
import 'generated/protocol.dart';
import 'inventory_util.dart';

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
        details: {
          'providedQuantity': quantity.toString(),
        },
      );
    }

    try {
      await InventoryUtil.updateInventoryBalance(
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
      return await InventoryUtil.getAccountInventory(
        session,
        accountId: accountId,
      );
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
      return await InventoryUtil.getInventoryBalance(
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
}