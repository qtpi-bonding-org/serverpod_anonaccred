import 'package:serverpod/serverpod.dart';

import 'entitlement_manager.dart';
import 'generated/protocol.dart';

/// Optional atomic entitlement consumption utilities for parent applications
///
/// Provides safe consumption operations that atomically check balance and
/// decrement inventory if sufficient balance exists. These utilities are
/// optional tools that parent applications can choose to use for convenience.
class EntitlementUtils {
  /// Attempts to consume a specified quantity from account inventory
  ///
  /// Atomically checks if sufficient balance exists and decrements the balance
  /// if the operation can succeed. Returns structured result indicating success
  /// or failure with available balance information.
  ///
  /// [session] - Serverpod session for database operations
  /// [accountUuid] - The account UUID to consume inventory from
  /// [tag] - String identifier for the entitlement (formerly consumableType)
  /// [quantity] - Amount to consume (must be positive)
  ///
  /// Returns [ConsumeResult] with operation outcome and balance information
  static Future<ConsumeResult> tryConsume(
    Session session, {
    required UuidValue accountUuid,
    required String tag,
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
      // Use EntitlementManager for consumption which handles transactions and logging
      await EntitlementManager.consumeEntitlement(
        session,
        accountUuid: accountUuid,
        tag: tag,
        amount: quantity,
        reason: 'API Consumption (tryConsume)',
      );

      final newBalance = await EntitlementManager.getEntitlementBalance(
        session,
        accountUuid: accountUuid,
        tag: tag,
      );

      return ConsumeResult(success: true, availableBalance: newBalance);
    } on InventoryException catch (e) {
      // Return failure result instead of throwing
      return ConsumeResult(
        success: false,
        availableBalance: 0.0,
        errorMessage: e.message,
      );
    } catch (e) {
      // Handle any other errors
      return ConsumeResult(
        success: false,
        availableBalance: 0.0,
        errorMessage: 'Consumption operation failed: ${e.toString()}',
      );
    }
  }
}
