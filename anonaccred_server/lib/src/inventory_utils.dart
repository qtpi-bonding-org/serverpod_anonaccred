import 'package:serverpod/serverpod.dart';
import 'generated/protocol.dart';
import 'inventory_util.dart';

/// Optional atomic inventory consumption utilities for parent applications
/// 
/// Provides safe consumption operations that atomically check balance and
/// decrement inventory if sufficient balance exists. These utilities are
/// optional tools that parent applications can choose to use for convenience.
class InventoryUtils {
  /// Attempts to consume a specified quantity from account inventory
  /// 
  /// Atomically checks if sufficient balance exists and decrements the balance
  /// if the operation can succeed. Returns structured result indicating success
  /// or failure with available balance information.
  /// 
  /// [session] - Serverpod session for database operations
  /// [accountId] - The account to consume inventory from
  /// [consumableType] - String identifier for the consumable item
  /// [quantity] - Amount to consume (must be positive)
  /// 
  /// Returns [ConsumeResult] with operation outcome and balance information
  /// 
  /// Requirements:
  /// - 6.1: Atomically decrement balance and return success if sufficient balance
  /// - 6.2: Reject operation and return available balance if insufficient balance
  /// - 6.3: Ensure no partial state changes on failure
  /// - 6.4: Handle concurrent operations without race conditions
  static Future<ConsumeResult> tryConsume(
    Session session, {
    required int accountId,
    required String consumableType,
    required double quantity,
  }) async {
    // Validate input parameters
    if (quantity <= 0) {
      return ConsumeResult(
        success: false,
        availableBalance: 0.0,
        errorMessage: 'Quantity must be positive',
      );
    }

    try {
      // Use database transaction to ensure atomicity (Requirements 6.3, 6.4)
      return await session.db.transaction((transaction) async {
        // Get current balance within transaction
        final currentBalance = await InventoryUtil.getInventoryBalance(
          session,
          accountId: accountId,
          consumableType: consumableType,
          transaction: transaction,
        );

        // Check if sufficient balance exists (Requirement 6.2)
        if (currentBalance < quantity) {
          return ConsumeResult(
            success: false,
            availableBalance: currentBalance,
            errorMessage: 'Insufficient balance: requested $quantity, available $currentBalance',
          );
        }

        // Atomically decrement balance (Requirement 6.1)
        await InventoryUtil.updateInventoryBalance(
          session,
          accountId: accountId,
          consumableType: consumableType,
          quantityDelta: -quantity,
          transaction: transaction,
        );

        // Return success with updated balance
        return ConsumeResult(
          success: true,
          availableBalance: currentBalance - quantity,
        );
      });
    } on InventoryException catch (e) {
      // Handle inventory-specific errors and return failure result (Requirement 6.3)
      return ConsumeResult(
        success: false,
        availableBalance: 0.0,
        errorMessage: e.message,
      );
    } catch (e) {
      // Handle any other errors and return failure result (Requirement 6.3)
      return ConsumeResult(
        success: false,
        availableBalance: 0.0,
        errorMessage: 'Consumption operation failed: ${e.toString()}',
      );
    }
  }
}