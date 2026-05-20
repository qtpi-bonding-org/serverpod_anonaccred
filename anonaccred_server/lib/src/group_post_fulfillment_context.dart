import 'package:serverpod/serverpod.dart';

import 'generated/protocol.dart';

/// Context passed to the group post-fulfillment hook after a group-scoped
/// transaction has been resolved and grants applied to a group's balances.
///
/// Mirrors [PostFulfillmentContext] field-for-field except the identity is
/// split: [shareGroupUuid] names the group that was credited;
/// [buyerAccountUuid] names the member whose [EphemeralAccreditationGroup]
/// row authorized the purchase (useful for UI attribution like "Bob bought
/// the team plan").
class GroupPostFulfillmentContext {
  const GroupPostFulfillmentContext({
    required this.shareGroupUuid,
    required this.buyerAccountUuid,
    required this.grantsApplied,
    required this.payment,
    required this.storeProductId,
  });

  final UuidValue shareGroupUuid;
  final UuidValue buyerAccountUuid;
  final List<RailProductGrant> grantsApplied;
  final TransactionPayment payment;
  final String storeProductId;
}
