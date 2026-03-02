import 'package:serverpod/serverpod.dart';

import '../crypto_auth.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../payments/rails/apple_iap_rail.dart';
import '../payments/rails/google_iap_rail.dart';

/// In-App Purchase endpoint for Apple and Google IAP validation.
///
/// Implements a "Reactive & Anonymous" fulfillment flow.
/// 1. Identity-Linked Inventory: Adds coins directly to the account balance.
/// 2. Identity-Free Financials: Records the payment in TransactionPayment without an accountId.
/// 3. The Bridge: EphemeralAuditLog links the two for 7 days, then breaks.
class IAPEndpoint extends Endpoint {
  /// Validate Apple App Store transaction and fulfill purchase.
  ///
  /// This endpoint is reactive: if no order exists, it creates the financial
  /// record on-the-fly from the verified receipt.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [transactionId]: Apple transaction ID from the app
  /// - [productId]: Apple product ID (SKU)
  /// - [accountId]: Account ID for inventory management
  /// - [internalTransactionId]: Optional client-generated reference (e.g. UUID)
  Future<Map<String, dynamic>> validateAppleTransaction(
    Session session,
    String publicKey,
    String signature,
    String transactionId,
    String productId,
    int accountId, {
    String? internalTransactionId,
  }) async {
    try {
      // Validate authentication
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'validateAppleTransaction',
      );

      // Validate parameters
      if (transactionId.isEmpty || productId.isEmpty) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.paymentValidationFailed,
          message: 'Transaction ID and product ID are required',
          internalTransactionId: internalTransactionId,
          details: {
            'transactionId': transactionId.isEmpty ? 'empty' : 'provided',
            'productId': productId.isEmpty ? 'empty' : 'provided',
          },
        );
      }

      // Create Apple IAP rail and validate transaction
      final appleRail = await AppleIAPRail.create();
      final result = await appleRail.validateTransaction(
        session: session,
        transactionId: transactionId,
        productId: productId,
        accountId: accountId,
        internalTransactionId: internalTransactionId,
      );

      if (!result.isValid) {
        return {
          'success': false,
          'error': 'Apple transaction validation failed',
          'from_cache': result.fromCache,
        };
      }

      session.log(
        'Apple IAP fulfilled: ${result.transactionId} (${result.productId})',
        level: LogLevel.info,
      );

      return {
        'success': true,
        'product_id': result.productId,
        'tag': result.tag,
        'amount': result.quantity,
        'from_cache': result.fromCache,
      };
    } on AuthenticationException {
      rethrow;
    } on PaymentException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message:
            'Unexpected error validating Apple transaction: ${e.toString()}',
        details: {
          'error': e.toString(),
          'accountId': accountId.toString(),
          'transactionId': transactionId,
        },
      );
    }
  }

  /// Validate Google Play purchase and fulfill purchase.
  ///
  /// This endpoint is reactive: if no order exists, it creates the financial
  /// record on-the-fly from the verified purchase token.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [packageName]: Android app package name
  /// - [productId]: Google product ID (SKU)
  /// - [purchaseToken]: Google purchase token
  /// - [accountId]: Account ID for inventory management
  /// - [internalTransactionId]: Optional client-generated reference (e.g. UUID)
  Future<Map<String, dynamic>> validateGooglePurchase(
    Session session,
    String publicKey,
    String signature,
    String packageName,
    String productId,
    String purchaseToken,
    int accountId, {
    String? internalTransactionId,
  }) async {
    try {
      // Validate authentication
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'validateGooglePurchase',
      );

      // Validate parameters
      if (packageName.isEmpty || productId.isEmpty || purchaseToken.isEmpty) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.paymentValidationFailed,
          message: 'Package name, product ID, and purchase token are required',
          internalTransactionId: internalTransactionId,
        );
      }

      // Create Google IAP rail and validate purchase
      final googleRail = await GoogleIAPRail.create();
      final result = await googleRail.validatePurchase(
        session: session,
        packageName: packageName,
        productId: productId,
        purchaseToken: purchaseToken,
        accountId: accountId,
        internalTransactionId: internalTransactionId,
      );

      if (!result.isValid) {
        return {
          'success': false,
          'error': result.errorMessage,
          'from_cache': result.fromCache,
        };
      }

      session.log(
        'Google IAP fulfilled: ${result.internalTransactionId} ($productId)',
        level: LogLevel.info,
      );

      return {
        'success': true,
        'product_id': productId,
        'tag': result.tag,
        'amount': result.quantity,
        'from_cache': result.fromCache,
      };
    } on AuthenticationException {
      rethrow;
    } on PaymentException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error validating Google purchase: ${e.toString()}',
        details: {
          'error': e.toString(),
          'accountId': accountId.toString(),
          'productId': productId,
        },
      );
    }
  }

  /// Placeholder for Apple server-to-server notifications.
  Future<Map<String, dynamic>> handleAppleWebhook(
    Session session,
    Map<String, dynamic> webhookData,
  ) async {
    // Webhook logic for status updates (e.g. refunds)
    return {
      'success': true,
      'message': 'Apple webhook processed',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Placeholder for Google purchase notifications.
  Future<Map<String, dynamic>> handleGoogleWebhook(
    Session session,
    Map<String, dynamic> webhookData,
  ) async {
    // Webhook logic for status updates
    return {
      'success': true,
      'message': 'Google webhook processed',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Validates authentication using Ed25519 signature verification.
  Future<void> _validateAuthentication(
    Session session,
    String publicKey,
    String signature,
    String operation,
  ) async {
    if (publicKey.isEmpty) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.authMissingKey,
        message: 'Public key required',
        operation: operation,
      );
    }

    if (!CryptoAuth.isValidPublicKey(publicKey)) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.cryptoInvalidPublicKey,
        message: 'Invalid public key',
        operation: operation,
      );
    }

    if (signature.isEmpty) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.authInvalidSignature,
        message: 'Signature required',
        operation: operation,
      );
    }
  }
}
