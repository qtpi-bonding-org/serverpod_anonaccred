import 'package:serverpod/serverpod.dart';

import 'generated/protocol.dart';

/// Context passed to the post-fulfillment hook after grants are applied.
class PostFulfillmentContext {
  const PostFulfillmentContext({
    required this.accountUuid,
    required this.grantsApplied,
    required this.payment,
    required this.storeProductId,
  });

  final UuidValue accountUuid;
  final List<RailProductGrant> grantsApplied;
  final TransactionPayment payment;
  final String storeProductId;
}
