import 'package:serverpod/serverpod.dart';

import 'generated/protocol.dart';
import 'group_entitlement_manager.dart';

/// Atomic group entitlement consumption helper.
///
/// Mirrors [EntitlementUtils] for the group scope. Returns a
/// [ConsumeResult] instead of throwing on insufficient balance, so
/// endpoint callers can map "not enough" to a non-error response shape.
class GroupEntitlementUtils {
  /// Attempts to consume from a group balance.
  ///
  /// Returns failure-result instead of throwing on validation /
  /// inventory errors. Throws only on unexpected DB failure.
  static Future<ConsumeResult> tryConsumeGroup(
    Session session, {
    required UuidValue shareGroupUuid,
    required String tag,
    required double quantity,
    UuidValue? consumingAccountUuid,
    String reason = 'API Consumption (tryConsumeGroup)',
  }) async {
    if (quantity <= 0) {
      return ConsumeResult(
        success: false,
        availableBalance: 0.0,
        errorMessage: 'Quantity must be positive',
      );
    }

    try {
      await GroupEntitlementManager.consumeGroupEntitlement(
        session,
        shareGroupUuid: shareGroupUuid,
        tag: tag,
        amount: quantity,
        reason: reason,
        consumingAccountUuid: consumingAccountUuid,
      );

      final newBalance = await GroupEntitlementManager.getGroupEntitlementBalance(
        session,
        shareGroupUuid: shareGroupUuid,
        tag: tag,
      );

      return ConsumeResult(success: true, availableBalance: newBalance);
    } on InventoryException catch (e) {
      return ConsumeResult(
        success: false,
        availableBalance: 0.0,
        errorMessage: e.message,
      );
    } catch (e) {
      return ConsumeResult(
        success: false,
        availableBalance: 0.0,
        errorMessage: 'Group consumption operation failed: ${e.toString()}',
      );
    }
  }
}
