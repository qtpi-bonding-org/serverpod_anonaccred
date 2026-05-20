import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../group_entitlement_manager.dart';
import '../group_entitlement_utils.dart';

/// JWT-protected group commerce endpoints.
///
/// Mirrors the account-level commerce endpoint for the per-group
/// entitlement layer. The authenticated caller is the acting member;
/// the target group is supplied as a parameter. Authorization (caller
/// must be an active member of the group) is enforced via
/// `[_requireGroupMember]`.
///
/// The acting member's account UUID is attached to consumption events
/// as `consumingAccountUuid` for in-app attribution (e.g., "Bob used
/// 200MB of this group's quota"). Billing correctness does not depend
/// on that field.
class GroupCommerceEndpoint extends JwtEndpoint {
  /// Get all entitlement balances for a group. Caller must be a member.
  Future<List<GroupEntitlement>> getGroupEntitlements(
    Session session,
    UuidValue shareGroupUuid,
  ) async {
    try {
      final accountUuid = getAccountUuid(session);
      await _requireGroupMember(session, accountUuid, shareGroupUuid);

      return await GroupEntitlementManager.getGroupEntitlements(
        session,
        shareGroupUuid: shareGroupUuid,
      );
    } on AuthenticationException {
      rethrow;
    } on InventoryException {
      rethrow;
    } catch (e) {
      throw AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.internalError,
        message: 'Unexpected error getting group entitlements: ${e.toString()}',
      );
    }
  }

  /// Get the balance for a single entitlement tag in this group. Caller
  /// must be a member.
  Future<double> getGroupEntitlementBalance(
    Session session,
    UuidValue shareGroupUuid,
    String tag,
  ) async {
    try {
      final accountUuid = getAccountUuid(session);
      await _requireGroupMember(session, accountUuid, shareGroupUuid);

      return await GroupEntitlementManager.getGroupEntitlementBalance(
        session,
        shareGroupUuid: shareGroupUuid,
        tag: tag,
      );
    } on AuthenticationException {
      rethrow;
    } on InventoryException {
      rethrow;
    } catch (e) {
      throw AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.internalError,
        message:
            'Unexpected error getting group entitlement balance: ${e.toString()}',
      );
    }
  }

  /// Consume from a group's entitlement balance.
  ///
  /// The acting member (resolved from JWT) is recorded as
  /// `consumingAccountUuid` on the log row for UI attribution. Returns
  /// a [ConsumeResult] (does not throw on insufficient balance).
  Future<ConsumeResult> consumeGroupEntitlement(
    Session session,
    UuidValue shareGroupUuid,
    String tag,
    double quantity,
  ) async {
    try {
      final accountUuid = getAccountUuid(session);
      await _requireGroupMember(session, accountUuid, shareGroupUuid);

      return await GroupEntitlementUtils.tryConsumeGroup(
        session,
        shareGroupUuid: shareGroupUuid,
        tag: tag,
        quantity: quantity,
        consumingAccountUuid: accountUuid,
      );
    } on AuthenticationException {
      rethrow;
    } on InventoryException {
      rethrow;
    } catch (e) {
      throw AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.internalError,
        message:
            'Unexpected error during group entitlement consumption: ${e.toString()}',
      );
    }
  }

  Future<void> _requireGroupMember(
    Session session,
    UuidValue accountUuid,
    UuidValue shareGroupUuid,
  ) async {
    final membership = await GroupMember.db.findFirstRow(
      session,
      where: (t) =>
          t.shareGroupId.equals(shareGroupUuid) &
          t.anonAccountId.equals(accountUuid) &
          t.isRevoked.equals(false),
    );
    if (membership == null) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authAccountNotFound,
        message: 'Caller is not an active member of the requested group',
        operation: 'groupCommerce',
        details: {
          'accountUuid': accountUuid.toString(),
          'shareGroupUuid': shareGroupUuid.toString(),
        },
      );
    }
  }
}
