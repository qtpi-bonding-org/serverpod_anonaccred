import 'package:serverpod/serverpod.dart';

/// Where a payment-rail redemption credits its entitlements.
///
/// Sealed so callers must handle both cases at compile time. Rails
/// accept a [RedemptionTarget] (not a bare [UuidValue]) so the same
/// code path can credit either an account or a group, with the type
/// system enforcing the dispatch.
sealed class RedemptionTarget {
  const RedemptionTarget();
}

/// Credit an [AccountEntitlement] for [accountUuid]. The Polar / IAP /
/// X402 default — most purchases are personal.
class AccountTarget extends RedemptionTarget {
  const AccountTarget(this.accountUuid);
  final UuidValue accountUuid;
}

/// Credit a [GroupEntitlement] for [shareGroupUuid]. The buyer is
/// still recorded on the [EphemeralAccreditationGroup] bridge for
/// refund resolution and "who upgraded the group" attribution; only
/// the entitlement balance attaches to the group itself.
class GroupTarget extends RedemptionTarget {
  const GroupTarget({
    required this.shareGroupUuid,
    required this.buyerAccountUuid,
  });
  final UuidValue shareGroupUuid;
  final UuidValue buyerAccountUuid;
}
