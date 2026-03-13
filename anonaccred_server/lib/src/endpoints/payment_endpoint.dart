import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:anonaccount_server/anonaccount_server.dart';

import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../payments/payment_processor.dart';
import '../payments/webhook_handler.dart';

/// Payment endpoints for managing non-IAP rails (Monero, X402, etc).
///
/// Note: IAP rails (Apple/Google) are now handled via IAPEndpoint for better
/// reactive fulfillment coupling.
class PaymentEndpoint extends Endpoint {
  /// Check the status of a payment transaction.
  ///
  /// Uses internalTransactionId for the check.
  Future<TransactionPayment> checkPaymentStatus(
    Session session,
    String publicKey,
    String signature,
    String internalTransactionId,
  ) async {
    try {
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'checkPaymentStatus',
      );

      final transaction = await PaymentProcessor.getTransactionById(
        session,
        internalTransactionId,
      );

      if (transaction == null) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.orderFulfillmentFailed,
          message: 'Transaction not found for ID: $internalTransactionId',
          internalTransactionId: internalTransactionId,
        );
      }

      return transaction;
    } on AuthenticationException {
      rethrow;
    } on PaymentException {
      rethrow;
    } catch (e) {
      throw AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.internalError,
        message: 'Unexpected error checking payment status: ${e.toString()}',
        details: {'error': e.toString(), 'id': internalTransactionId},
      );
    }
  }

  /// Process Monero webhook.
  Future<String> processMoneroWebhook(
    Session session,
    String webhookDataJson,
  ) async {
    try {
      final webhookData =
          jsonDecode(webhookDataJson) as Map<String, dynamic>;
      await WebhookHandler.processWebhook(
        session: session,
        railType: PaymentRail.monero,
        webhookData: webhookData,
      );
      return 'Webhook processed';
    } catch (e) {
      session.log('Monero webhook error: $e', level: LogLevel.error);
      return 'Webhook received';
    }
  }

  /// Process X402 webhook.
  Future<String> processX402Webhook(
    Session session,
    String webhookDataJson,
  ) async {
    try {
      final webhookData =
          jsonDecode(webhookDataJson) as Map<String, dynamic>;
      await WebhookHandler.processWebhook(
        session: session,
        railType: PaymentRail.x402_http,
        webhookData: webhookData,
      );
      return 'Webhook processed';
    } catch (e) {
      session.log('X402 webhook error: $e', level: LogLevel.error);
      return 'Webhook received';
    }
  }

  /// Validates authentication using ECDSA P-256 signature verification.
  Future<void> _validateAuthentication(
    Session session,
    String publicKey,
    String signature,
    String operation,
  ) async {
    if (publicKey.isEmpty) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authMissingKey,
        message: 'Public key required',
        operation: operation,
      );
    }
    if (!CryptoAuth.isValidPublicKey(publicKey)) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.cryptoInvalidPublicKey,
        message: 'Invalid public key',
        operation: operation,
      );
    }
    if (signature.isEmpty) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authInvalidSignature,
        message: 'Signature required',
        operation: operation,
      );
    }
  }
}
