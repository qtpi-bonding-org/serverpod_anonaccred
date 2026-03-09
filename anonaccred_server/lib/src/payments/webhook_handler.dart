import 'package:serverpod/serverpod.dart';
import 'package:anonaccount_server/anonaccount_server.dart';

import '../exception_factory.dart';
import '../generated/protocol.dart';
import 'payment_manager.dart';
import 'payment_processor.dart';
import 'webhook_signature_validator.dart';

/// Simple webhook handler for processing external payment callbacks.
///
/// Routes callbacks (e.g. refunds or subscription updates) to the correct
/// payment rail and handles status updates via PaymentProcessor.
class WebhookHandler {
  /// Process a webhook callback from an external payment service.
  ///
  /// Requirement 9.4: Log webhook result with payload key details
  static Future<void> processWebhook({
    required Session session,
    required PaymentRail railType,
    required Map<String, dynamic> webhookData,
  }) async {
    final internalTransactionId = extractInternalId(webhookData);

    session.log(
      'Webhook processing initiated - Rail: $railType, TxId: ${internalTransactionId ?? 'unknown'}',
      level: LogLevel.info,
    );

    try {
      final rail = PaymentManager.getRail(railType);
      if (rail == null) {
        session.log(
          'Webhook processing failed - Unsupported rail: $railType',
          level: LogLevel.warning,
        );
        return;
      }

      // Process the webhook through the payment rail
      final result = await rail.processCallback(webhookData);

      if (result.internalTransactionId != null) {
        await _updateTransactionFromResult(session, result);
        session.log(
          'Webhook processed successfully - TxId: ${result.internalTransactionId}, Success: ${result.success}',
          level: LogLevel.info,
        );
      } else {
        session.log(
          'Webhook processed by rail but no internal ID found - Success: ${result.success}',
          level: LogLevel.warning,
        );
      }
    } catch (e) {
      session.log(
        'Webhook processing failed - Error: ${e.toString()}',
        level: LogLevel.error,
        exception: e,
      );
    }
  }

  /// Update transaction status based on payment result
  ///
  /// Status updates (paid, failed, cancelled) are idempotent.
  static Future<void> _updateTransactionFromResult(
    Session session,
    PaymentResult result,
  ) async {
    final internalId = result.internalTransactionId;
    if (internalId == null) return;

    try {
      final currentTx = await PaymentProcessor.getTransactionById(
        session,
        internalId,
      );

      if (currentTx == null) {
        session.log(
          'Transaction not found for ID: $internalId',
          level: LogLevel.warning,
        );
        return;
      }

      // Idempotency: don't update if already in final state
      if (currentTx.status == OrderStatus.paid ||
          currentTx.status == OrderStatus.cancelled) {
        return;
      }

      final newStatus = result.success ? OrderStatus.paid : OrderStatus.failed;
      await PaymentProcessor.updateTransactionStatus(
        session,
        internalId,
        newStatus,
      );

      if (result.success && result.transactionTimestamp != null) {
        await PaymentProcessor.updateTransactionTimestamp(
          session,
          internalId,
          result.transactionTimestamp!,
        );
      }
    } catch (e) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Failed to update transaction from result: ${e.toString()}',
        internalTransactionId: internalId,
      );
    }
  }

  /// Extracts the internal transaction ID from the webhook payload.
  static String? extractInternalId(Map<String, dynamic> webhookData) =>
      webhookData['internalTransactionId'] as String? ??
      webhookData['orderId'] as String? ??
      webhookData['externalId'] as String?;

  /// Validate webhook signature (for Rails like Google/Stripe).
  static void validateWebhookSignature({
    required Session session,
    required String payload,
    required String signature,
  }) {
    WebhookSignatureValidator.validateSignatureOrThrow(
      session: session,
      payload: payload,
      signature: signature,
    );
  }
}
