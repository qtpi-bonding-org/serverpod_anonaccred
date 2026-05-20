import 'package:serverpod/serverpod.dart';

import 'exception_factory.dart';
import 'generated/protocol.dart';

/// Shared internals for account-scoped and group-scoped entitlement
/// managers. Holds the things that are identical across both scopes:
/// tag → Entitlement lookup, amount validation, common exception
/// constructors. Each scope-specific manager owns its own DB
/// interaction (which balance table, which log table, how rows are
/// keyed) but reuses these utilities.
class EntitlementCore {
  /// Throws InventoryException if [amount] is non-positive.
  static void requirePositiveAmount(
    double amount, {
    String? tag,
    String operation = 'entitlement operation',
  }) {
    if (amount <= 0) {
      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccredErrorCodes.inventoryInvalidQuantity,
        message: '$operation amount must be positive',
        tag: tag,
        details: {'providedAmount': amount.toString()},
      );
    }
  }

  /// Look up an [Entitlement] by tag, throwing if it doesn't exist.
  ///
  /// Pass a [transaction] to keep the lookup in the caller's transaction.
  static Future<Entitlement> requireByTag(
    Session session,
    String tag, {
    Transaction? transaction,
  }) async {
    final entitlement = await Entitlement.db.findFirstRow(
      session,
      where: (t) => t.tag.equals(tag),
      transaction: transaction,
    );
    if (entitlement == null) {
      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccredErrorCodes.inventoryInvalidConsumable,
        message: 'Entitlement with tag "$tag" not found',
        tag: tag,
      );
    }
    return entitlement;
  }

  /// Standardized insufficient-balance exception.
  static InventoryException insufficientBalance({
    required double currentBalance,
    required double requested,
    required String tag,
  }) {
    return AnonAccredExceptionFactory.createInventoryException(
      code: AnonAccredErrorCodes.inventoryInsufficientBalance,
      message: 'Insufficient balance for entitlement "$tag"',
      tag: tag,
      details: {
        'currentBalance': currentBalance.toString(),
        'requested': requested.toString(),
      },
    );
  }
}
