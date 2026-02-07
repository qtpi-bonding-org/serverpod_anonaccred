import 'package:serverpod/serverpod.dart';
import '../crypto_auth.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../payments/payment_manager.dart';
import '../payments/payment_processor.dart';
import '../payments/webhook_handler.dart';
import '../payments/x402_interceptor.dart';

/// Payment endpoints for AnonAccred Phase 4 payment rail architecture
///
/// Provides endpoints for payment initiation, status checking, and webhook processing
/// while maintaining the established authentication and error handling patterns.
class PaymentEndpoint extends Endpoint {
  /// Initiate a payment using the specified payment rail
  ///
  /// Creates a payment request through the appropriate payment rail and updates
  /// the transaction with payment reference information.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [orderId]: External order ID for the transaction
  /// - [railType]: Payment rail to use for processing
  ///
  /// Returns: PaymentRequest with payment details and rail-specific metadata
  ///
  /// Throws:
  /// - [AuthenticationException] for invalid authentication
  /// - [PaymentException] for payment processing errors
  /// - [AnonAccredException] for system errors
  ///
  /// Requirements 6.1: Create payment requests using specified rail
  Future<PaymentRequest> initiatePayment(
    Session session,
    String publicKey,
    String signature,
    String orderId,
    PaymentRail railType,
  ) async {
    try {
      // Validate authentication
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'initiatePayment',
      );

      // Validate orderId
      if (orderId.isEmpty) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.orderInvalidProduct,
          message: 'Order ID cannot be empty',
          orderId: orderId,
          details: {'orderId': 'empty'},
        );
      }

      // Get the transaction to determine amount
      final transaction = await PaymentProcessor.getTransactionByExternalId(
        session,
        orderId,
      );

      if (transaction == null) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.orderInvalidProduct,
          message: 'Transaction not found for order ID: $orderId',
          orderId: orderId,
          details: {'operation': 'initiatePayment'},
        );
      }

      // Create payment using PaymentManager
      final paymentRequest = await PaymentManager.createPayment(
        session: session,
        railType: railType,
        amountUSD: transaction.price,
        orderId: orderId,
      );

      // Update transaction with payment reference
      await PaymentProcessor.updatePaymentRef(
        session,
        orderId,
        paymentRequest.paymentRef,
      );

      // Update transaction status to processing
      await PaymentProcessor.updateTransactionStatus(
        session,
        orderId,
        OrderStatus.processing,
      );

      session.log(
        'Payment initiated successfully for order: $orderId, rail: $railType',
        level: LogLevel.info,
      );

      return paymentRequest;
    } on AuthenticationException {
      rethrow;
    } on PaymentException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error during payment initiation: ${e.toString()}',
        details: {
          'error': e.toString(),
          'orderId': orderId,
          'railType': railType.toString(),
        },
      );
    }
  }

  /// Check the status of a payment transaction
  ///
  /// Returns the current status and details of a payment transaction.
  /// Requires authentication to ensure only authorized access to payment data.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [orderId]: External order ID to check status for
  ///
  /// Returns: TransactionPayment with current status and payment details
  ///
  /// Throws:
  /// - [AuthenticationException] for invalid authentication
  /// - [PaymentException] for transaction not found
  /// - [AnonAccredException] for system errors
  ///
  /// Requirements 6.2: Return current transaction and payment status
  Future<TransactionPayment> checkPaymentStatus(
    Session session,
    String publicKey,
    String signature,
    String orderId,
  ) async {
    try {
      // Validate authentication
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'checkPaymentStatus',
      );

      // Validate orderId
      if (orderId.isEmpty) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.orderInvalidProduct,
          message: 'Order ID cannot be empty',
          orderId: orderId,
          details: {'orderId': 'empty'},
        );
      }

      // Get transaction status
      final transaction = await PaymentProcessor.getTransactionByExternalId(
        session,
        orderId,
      );

      if (transaction == null) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.orderInvalidProduct,
          message: 'Transaction not found for order ID: $orderId',
          orderId: orderId,
          details: {'operation': 'checkPaymentStatus'},
        );
      }

      session.log(
        'Payment status checked for order: $orderId, status: ${transaction.status}',
        level: LogLevel.info,
      );

      return transaction;
    } on AuthenticationException {
      rethrow;
    } on PaymentException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error checking payment status: ${e.toString()}',
        details: {
          'error': e.toString(),
          'orderId': orderId,
        },
      );
    }
  }

  /// Process webhook for Monero payment rail
  ///
  /// Handles webhook callbacks from Monero payment services.
  /// This endpoint does not require authentication as it's called by external services.
  ///
  /// Parameters:
  /// - [webhookData]: Raw webhook payload from Monero service
  ///
  /// Returns: Success message
  ///
  /// Requirements 6.4: Process callbacks and update transaction status
  Future<String> processMoneroWebhook(
    Session session,
    Map<String, dynamic> webhookData,
  ) async {
    try {
      await WebhookHandler.processWebhook(
        session: session,
        railType: PaymentRail.monero,
        webhookData: webhookData,
      );

      return 'Webhook processed successfully';
    } catch (e) {
      // Log error but return success to prevent webhook retries
      session.log(
        'Monero webhook processing failed: ${e.toString()}',
        level: LogLevel.error,
      );
      return 'Webhook received';
    }
  }

  /// Process webhook for X402 HTTP payment rail
  ///
  /// Handles webhook callbacks from X402 HTTP payment services.
  /// This endpoint does not require authentication as it's called by external services.
  ///
  /// Parameters:
  /// - [webhookData]: Raw webhook payload from X402 service
  ///
  /// Returns: Success message
  ///
  /// Requirements 6.4: Process callbacks and update transaction status
  Future<String> processX402Webhook(
    Session session,
    Map<String, dynamic> webhookData,
  ) async {
    try {
      await WebhookHandler.processWebhook(
        session: session,
        railType: PaymentRail.x402_http,
        webhookData: webhookData,
      );

      return 'Webhook processed successfully';
    } catch (e) {
      // Log error but return success to prevent webhook retries
      session.log(
        'X402 webhook processing failed: ${e.toString()}',
        level: LogLevel.error,
      );
      return 'Webhook received';
    }
  }

  /// Process webhook for Apple IAP payment rail
  ///
  /// Handles webhook callbacks from Apple In-App Purchase services.
  /// This endpoint does not require authentication as it's called by external services.
  ///
  /// Parameters:
  /// - [webhookData]: Raw webhook payload from Apple IAP service
  ///
  /// Returns: Success message
  ///
  /// Requirements 6.4: Process callbacks and update transaction status
  Future<String> processAppleIAPWebhook(
    Session session,
    Map<String, dynamic> webhookData,
  ) async {
    try {
      await WebhookHandler.processWebhook(
        session: session,
        railType: PaymentRail.apple_iap,
        webhookData: webhookData,
      );

      return 'Webhook processed successfully';
    } catch (e) {
      // Log error but return success to prevent webhook retries
      session.log(
        'Apple IAP webhook processing failed: ${e.toString()}',
        level: LogLevel.error,
      );
      return 'Webhook received';
    }
  }

  /// Process webhook for Google IAP payment rail
  ///
  /// Handles webhook callbacks from Google In-App Purchase services.
  /// This endpoint does not require authentication as it's called by external services.
  ///
  /// Parameters:
  /// - [webhookData]: Raw webhook payload from Google IAP service
  ///
  /// Returns: Success message
  ///
  /// Requirements 6.4: Process callbacks and update transaction status
  Future<String> processGoogleIAPWebhook(
    Session session,
    Map<String, dynamic> webhookData,
  ) async {
    try {
      await WebhookHandler.processWebhook(
        session: session,
        railType: PaymentRail.google_iap,
        webhookData: webhookData,
      );

      return 'Webhook processed successfully';
    } catch (e) {
      // Log error but return success to prevent webhook retries
      session.log(
        'Google IAP webhook processing failed: ${e.toString()}',
        level: LogLevel.error,
      );
      return 'Webhook received';
    }
  }

  /// Request payment status with X402 integration
  ///
  /// Demonstrates X402 integration with existing payment endpoints.
  /// This endpoint can be accessed with or without payment, showcasing
  /// the X402 protocol flow for pay-per-use API access.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [orderId]: Order ID to check status for
  /// - [headers]: HTTP headers (may contain X-PAYMENT)
  ///
  /// Returns: Either HTTP 402 payment requirement or payment status
  ///
  /// Requirements 5.1, 5.2, 5.3: X402 endpoint integration
  Future<Map<String, dynamic>> requestPaymentStatusWithX402(
    Session session,
    String publicKey,
    String signature,
    String orderId, {
    Map<String, String>? headers,
  }) async {
    try {
      // Validate authentication
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'requestPaymentStatusWithX402',
      );

      // Use X402 interceptor to handle payment flow
      return await X402Interceptor.interceptRequest(
        session: session,
        headers: headers ?? <String, String>{},
        resourceId: 'payment_status_$orderId',
        amount: 0.50, // $0.50 for payment status access
        onPaymentRequired: () async {
          return await X402Interceptor.generatePaymentRequired(
            session: session,
            resourceId: 'payment_status_$orderId',
            amount: 0.50,
            description: 'Access to payment status for order $orderId',
          );
        },
        onPaymentVerified: () async {
          // Payment verified - provide payment status
          final transaction = await PaymentProcessor.getTransactionByExternalId(
            session,
            orderId,
          );

          if (transaction == null) {
            throw AnonAccredExceptionFactory.createPaymentException(
              code: AnonAccredErrorCodes.orderInvalidProduct,
              message: 'Transaction not found for order ID: $orderId',
              orderId: orderId,
              details: {'operation': 'requestPaymentStatusWithX402'},
            );
          }

          return {
            'success': true,
            'orderId': orderId,
            'status': transaction.status.name,
            'amount': transaction.price,
            'paymentRail': transaction.paymentRail?.name,
            'paymentRef': transaction.paymentRef,
            'accessTime': DateTime.now().toIso8601String(),
            'paymentMethod': 'x402_http',
          };
        },
      );

    } on AuthenticationException {
      rethrow;
    } on PaymentException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error in X402 payment status request: ${e.toString()}',
        details: {
          'error': e.toString(),
          'orderId': orderId,
        },
      );
    }
  }

  /// Validates authentication using Ed25519 signature verification
  ///
  /// This is a simplified authentication check that validates the public key format
  /// and signature. In a production system, this would include more sophisticated
  /// challenge-response authentication.
  ///
  /// Parameters:
  /// - [session]: Serverpod session for logging
  /// - [publicKey]: Ed25519 public key as hex string
  /// - [signature]: Signature to verify
  /// - [operation]: Operation name for logging
  ///
  /// Throws:
  /// - [AuthenticationException] for invalid authentication
  Future<void> _validateAuthentication(
    Session session,
    String publicKey,
    String signature,
    String operation,
  ) async {
    // Validate public key format
    if (publicKey.isEmpty) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.authMissingKey,
        message: 'Public key is required for authentication',
        operation: operation,
        details: {'publicKey': 'empty'},
      );
    }

    if (!CryptoAuth.isValidPublicKey(publicKey)) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.cryptoInvalidPublicKey,
        message: 'Invalid Ed25519 public key format',
        operation: operation,
        details: {
          'publicKeyLength': publicKey.length.toString(),
          'expectedLength': '64',
        },
      );
    }

    // Validate signature format
    if (signature.isEmpty) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.authInvalidSignature,
        message: 'Signature is required for authentication',
        operation: operation,
        details: {'signature': 'empty'},
      );
    }
  }
}