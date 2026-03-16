import 'package:serverpod/serverpod.dart';

import 'entitlement_manager.dart';
import 'generated/protocol.dart';
import 'refund_event.dart';

/// What action the library should take after a refund.
enum RefundAction {
  /// Library revokes all entitlements, marks status=refunded.
  revokeAll,

  /// Dev already handled it in the hook, library just marks status=refunded.
  handled,

  /// Do nothing — user keeps entitlements, transaction unchanged.
  ignore,
}

/// Pre-resolved bridge chain data passed to the developer hook.
class RefundContext {
  RefundContext({
    this.receiptHash,
    this.payment,
    this.accountUuid,
    this.grants = const [],
    this.bridgeExpired = false,
  });

  /// Confirms purchase was processed (from ReceiptHash table).
  final ReceiptHash? receiptHash;

  /// The financial record for this transaction.
  final TransactionPayment? payment;

  /// Account UUID resolved via EphemeralAccreditation bridge. Null if expired.
  final UuidValue? accountUuid;

  /// What entitlement grants were associated with this product.
  final List<RailProductGrant> grants;

  /// True if accountUuid couldn't be resolved (bridge TTL expired or ambiguous).
  final bool bridgeExpired;
}

/// Callback type for custom refund handling.
typedef RefundHandler = Future<RefundAction> Function(
  Session session,
  RefundEvent event,
  RefundContext context,
);

/// Rail-independent refund processor.
///
/// Resolves the bridge chain from RefundEvent, optionally calls a developer
/// hook, then executes the appropriate action (revoke entitlements, mark
/// status, or ignore).
class RefundManager {
  static RefundHandler? _handler;

  /// Register a custom refund handler. Only if you need custom behavior.
  static void onRefund(RefundHandler handler) {
    _handler = handler;
  }

  /// Reset handler (for testing).
  static void resetHandler() {
    _handler = null;
  }

  /// Main entry point: process a refund event.
  static Future<void> processRefund(Session session, RefundEvent event) async {
    // 1. Resolve context via bridge chain
    final context = await _resolveContext(session, event);

    // 2. Determine action
    RefundAction action;
    if (_handler != null) {
      action = await _handler!(session, event, context);
    } else {
      action = RefundAction.revokeAll;
    }

    // 3. Execute action
    await _executeAction(session, event, context, action);
  }

  /// Resolve bridge chain: ReceiptHash → TransactionPayment → EphemeralAccreditation → grants.
  static Future<RefundContext> _resolveContext(
    Session session,
    RefundEvent event,
  ) async {
    // 1. Find ReceiptHash by hash
    final hashRecord = await ReceiptHash.db.findFirstRow(
      session,
      where: (t) => t.hash.equals(event.receiptHash),
    );

    if (hashRecord == null) {
      return RefundContext(bridgeExpired: true);
    }

    // 2. Find TransactionPayment by paymentRef
    final payment = await TransactionPayment.db.findFirstRow(
      session,
      where: (t) => t.paymentRef.equals(event.paymentRef),
    );

    if (payment == null) {
      return RefundContext(receiptHash: hashRecord, bridgeExpired: true);
    }

    // Already refunded? Short-circuit (idempotency).
    if (payment.status == OrderStatus.refunded) {
      return RefundContext(
        receiptHash: hashRecord,
        payment: payment,
        bridgeExpired: true,
      );
    }

    // 3. Bridge resolution: find EphemeralAccreditations at transactionTimestamp
    final timestamp = payment.transactionTimestamp;
    final railProductId = payment.railProductId;

    // Count TransactionPayments with same (timestamp, railProductId) — ambiguity check
    final paymentsAtTimestamp = await TransactionPayment.db.find(
      session,
      where: (t) =>
          t.transactionTimestamp.equals(timestamp) &
          t.railProductId.equals(railProductId),
    );

    if (paymentsAtTimestamp.length > 1) {
      // Truly ambiguous — two people bought same product at same millisecond
      session.log(
        'Refund bridge ambiguous: ${paymentsAtTimestamp.length} payments at '
        '(${timestamp.toIso8601String()}, railProductId=$railProductId). '
        'Treating as bridgeExpired.',
        level: LogLevel.warning,
      );
      return RefundContext(
        receiptHash: hashRecord,
        payment: payment,
        bridgeExpired: true,
      );
    }

    // Find EphemeralAccreditations at this timestamp
    final accreditations = await EphemeralAccreditation.db.find(
      session,
      where: (t) => t.transactionTimestamp.equals(timestamp),
    );

    if (accreditations.isEmpty) {
      // Bridge expired (7-day TTL passed)
      session.log(
        'Refund bridge expired: no EphemeralAccreditation at '
        '${timestamp.toIso8601String()} for paymentRef=${event.paymentRef}',
        level: LogLevel.warning,
      );
      return RefundContext(
        receiptHash: hashRecord,
        payment: payment,
        bridgeExpired: true,
      );
    }

    // Determine accountUuid
    UuidValue? accountUuid;
    bool bridgeExpired = false;

    if (accreditations.length == 1) {
      // Unambiguous
      accountUuid = accreditations.first.accountUuid;
    } else {
      // Multiple EAs at same timestamp — but only 1 TransactionPayment at (T, R).
      // Different rails purchased at same instant. We can still resolve:
      // pick the EA that belongs to this specific payment.
      // Since we have only 1 payment at (T, R), the EA is the one matching.
      // We just use the first one since we can't disambiguate further without
      // a direct FK. This is the "best effort" case.
      accountUuid = accreditations.first.accountUuid;
    }

    // 4. Get grants for the rail product
    final grants = await RailProductGrant.db.find(
      session,
      where: (t) => t.railProductId.equals(railProductId),
    );

    return RefundContext(
      receiptHash: hashRecord,
      payment: payment,
      accountUuid: accountUuid,
      grants: grants,
      bridgeExpired: bridgeExpired,
    );
  }

  /// Execute the refund action.
  static Future<void> _executeAction(
    Session session,
    RefundEvent event,
    RefundContext context,
    RefundAction action,
  ) async {
    switch (action) {
      case RefundAction.ignore:
        return;

      case RefundAction.handled:
        // Dev handled entitlements; we just mark the payment as refunded.
        await _markRefunded(session, context.payment);

      case RefundAction.revokeAll:
        // Revoke entitlements if we have an account, then mark refunded.
        if (context.accountUuid != null && context.grants.isNotEmpty) {
          final reason = 'REFUND:${event.rail.name}:${event.paymentRef}';
          for (final grant in context.grants) {
            await EntitlementManager.revokeEntitlement(
              session,
              accountUuid: context.accountUuid!,
              entitlementId: grant.entitlementId,
              quantity: grant.quantity,
              reason: reason,
            );
          }
        } else if (context.bridgeExpired) {
          session.log(
            'Refund revokeAll: bridge expired for paymentRef=${event.paymentRef}, '
            'skipping entitlement revocation.',
            level: LogLevel.warning,
          );
        }
        await _markRefunded(session, context.payment);
    }
  }

  /// Mark a TransactionPayment as refunded.
  static Future<void> _markRefunded(
    Session session,
    TransactionPayment? payment,
  ) async {
    if (payment == null || payment.status == OrderStatus.refunded) return;

    await TransactionPayment.db.updateRow(
      session,
      payment.copyWith(status: OrderStatus.refunded),
    );
  }
}
