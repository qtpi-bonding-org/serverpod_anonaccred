import 'package:serverpod/serverpod.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import 'payment_manager.dart';
import 'payment_processor.dart';
import 'webhook_signature_validator.dart';

/// Simple webhook handler for processing external payment callbacks
///
/// This class provides basic webhook processing that routes callbacks to
/// appropriate payment rails and updates transaction status based on results.
/// Implements idempotent processing to handle duplicate webhooks safely.
class WebhookHandler {
  /// Process a webhook callback from an external payment service
  ///
  /// [session] - Serverpod session for database operations
  /// [railType] - The payment rail type that sent the webhook
  /// [webhookData] - Raw webhook payload from the payment service
  ///
  /// Routes the webhook to the appropriate payment rail for processing
  /// and updates transaction status based on the result.
  ///
  /// Requirements 4.1, 4.2, 4.3: Route callbacks, update records, handle errors
  /// Requirement 9.4: Log webhook processing results with payload details
  static Future<void> processWebhook({
    required Session session,
    required PaymentRail railType,
    required Map<String, dynamic> webhookData,
  }) async {
    // Log webhook processing initiation with payload details (Requirement 9.4)
    final orderId = extractOrderId(webhookData);
    session.log(
      'Webhook processing initiated - Rail: $railType, OrderId: ${orderId ?? 'unknown'}, PayloadKeys: ${webhookData.keys.join(', ')}, Timestamp: ${DateTime.now().toIso8601String()}',
      level: LogLevel.info,
    );

    try {
      // Get the payment rail for processing
      final rail = PaymentManager.getRail(railType);
      if (rail == null) {
        // Log error with operation context (Requirement 9.3)
        session.log(
          'Webhook processing failed - Unsupported rail: $railType, OrderId: ${orderId ?? 'unknown'}',
          level: LogLevel.warning,
        );
        return;
      }

      // Process the webhook through the payment rail
      final result = await rail.processCallback(webhookData);

      // Log webhook processing result (Requirement 9.4)
      session.log(
        'Webhook processed by rail - Rail: $railType, Success: ${result.success}, OrderId: ${result.orderId ?? 'unknown'}, Timestamp: ${result.transactionTimestamp?.toIso8601String() ?? 'none'}',
        level: LogLevel.info,
      );

      // Update transaction status if orderId is provided
      if (result.orderId != null) {
        await _updateTransactionFromResult(session, result);

        // Log successful webhook processing with complete details (Requirement 9.4)
        session.log(
          'Webhook processed successfully - Rail: $railType, OrderId: ${result.orderId}, Success: ${result.success}, Timestamp: ${result.transactionTimestamp?.toIso8601String() ?? 'none'}',
          level: LogLevel.info,
        );
      } else {
        // Log warning about missing orderId (Requirement 9.4)
        session.log(
          'Webhook processed but no orderId provided - Rail: $railType, Success: ${result.success}',
          level: LogLevel.warning,
        );
      }
    } on Exception catch (e) {
      // Log error with complete error details and operation context (Requirement 9.3, 9.4)
      session.log(
        'Webhook processing failed - Rail: $railType, OrderId: ${orderId ?? 'unknown'}, Error: ${e.toString()}, PayloadKeys: ${webhookData.keys.join(', ')}',
        level: LogLevel.error,
      );

      // Don't rethrow - webhook endpoints should return success to prevent retries
      // for processing errors that won't be resolved by retrying
    }
  }

  /// Update transaction status based on payment result
  ///
  /// [session] - Serverpod session for database operations
  /// [result] - Payment result from rail processing
  ///
  /// Updates transaction status and optionally transaction timestamp based on
  /// the payment result. Implements idempotent behavior by checking current
  /// status before making changes.
  ///
  /// Requirement 4.4: Handle duplicate webhooks idempotently
  static Future<void> _updateTransactionFromResult(
    Session session,
    PaymentResult result,
  ) async {
    if (result.orderId == null) return;

    try {
      // Check current transaction status for idempotency
      final currentTransaction =
          await PaymentProcessor.getTransactionByExternalId(
            session,
            result.orderId!,
          );

      if (currentTransaction == null) {
        session.log(
          'Transaction not found for webhook orderId: ${result.orderId}',
          level: LogLevel.warning,
        );
        return;
      }

      // Determine new status based on result
      final newStatus = result.success ? OrderStatus.paid : OrderStatus.failed;

      // Implement idempotency: don't update if already in final state
      if (currentTransaction.status == OrderStatus.paid ||
          currentTransaction.status == OrderStatus.cancelled) {
        session.log(
          'Transaction ${result.orderId} already in final state: ${currentTransaction.status}',
          level: LogLevel.info,
        );
        return;
      }

      // Update transaction status
      await PaymentProcessor.updateTransactionStatus(
        session,
        result.orderId!,
        newStatus,
      );

      // Update transaction timestamp if provided and payment was successful
      if (result.success && result.transactionTimestamp != null) {
        await PaymentProcessor.updateTransactionTimestamp(
          session,
          result.orderId!,
          result.transactionTimestamp!,
        );
      }
    } catch (e) {
      // Wrap unexpected errors in PaymentException
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentFailed,
        message: 'Failed to update transaction from webhook: ${e.toString()}',
        orderId: result.orderId,
        details: {
          'operation': 'updateTransactionFromResult',
          'success': result.success.toString(),
          'error': e.toString(),
        },
      );
    }
  }

  /// Validate webhook data contains required fields
  ///
  /// [webhookData] - Raw webhook payload to validate
  ///
  /// Returns true if webhook data appears valid, false otherwise.
  /// This is a basic validation - payment rails should implement
  /// their own specific validation logic.
  static bool isValidWebhookData(Map<String, dynamic> webhookData) {
    // Basic validation - webhook should not be empty
    return webhookData.isNotEmpty;
  }

  /// Validate webhook signature for Google webhooks
  ///
  /// Validates the webhook signature using HMAC-SHA256 with Google's public key.
  /// Throws HTTP 401 if signature is invalid.
  ///
  /// [session] - Serverpod session for logging
  /// [payload] - Raw webhook payload (JSON string)
  /// [signature] - Signature from request headers
  ///
  /// Requirements 8.3, 8.5: Validate signatures and throw HTTP 401 for invalid
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

  /// Extract order ID from webhook data if present
  ///
  /// [webhookData] - Raw webhook payload
  ///
  /// Returns order ID if found in common webhook fields, null otherwise.
  /// Payment rails should implement their own extraction logic for
  /// rail-specific webhook formats.
  static String? extractOrderId(Map<String, dynamic> webhookData) {
    // Check common field names for order ID
    return webhookData['orderId'] as String? ??
        webhookData['order_id'] as String? ??
        webhookData['externalId'] as String? ??
        webhookData['external_id'] as String?;
  }
}
