import 'package:serverpod/serverpod.dart';

import 'package:anonaccount_server/anonaccount_server.dart';

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
  /// - [publicKey]: ECDSA P-256 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [transactionId]: Apple transaction ID from the app
  /// - [productId]: Apple product ID (SKU)
  /// - [internalTransactionId]: Optional client-generated reference (e.g. UUID)
  Future<IapValidationResponse> validateAppleTransaction(
    Session session,
    String publicKey,
    String signature,
    String transactionId,
    String productId, {
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

      // Resolve accountId from device public key
      final accountId = await AnonAccountHelpers.resolveAccountId(
        session, publicKey, 'validateAppleTransaction',
      );

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
        return IapValidationResponse(
          success: false,
          fromCache: result.fromCache,
          error: 'Apple transaction validation failed',
        );
      }

      session.log(
        'Apple IAP fulfilled: ${result.transactionId} (${result.productId})',
        level: LogLevel.info,
      );

      return IapValidationResponse(
        success: true,
        productId: result.productId,
        tag: result.tag,
        amount: result.quantity,
        fromCache: result.fromCache,
      );
    } on AuthenticationException {
      rethrow;
    } on PaymentException {
      rethrow;
    } catch (e) {
      throw AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.internalError,
        message:
            'Unexpected error validating Apple transaction: ${e.toString()}',
        details: {
          'error': e.toString(),
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
  /// - [publicKey]: ECDSA P-256 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [packageName]: Android app package name
  /// - [productId]: Google product ID (SKU)
  /// - [purchaseToken]: Google purchase token
  /// - [internalTransactionId]: Optional client-generated reference (e.g. UUID)
  Future<IapValidationResponse> validateGooglePurchase(
    Session session,
    String publicKey,
    String signature,
    String packageName,
    String productId,
    String purchaseToken, {
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

      // Resolve accountId from device public key
      final accountId = await AnonAccountHelpers.resolveAccountId(
        session, publicKey, 'validateGooglePurchase',
      );

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
        return IapValidationResponse(
          success: false,
          fromCache: result.fromCache,
          error: result.errorMessage,
        );
      }

      session.log(
        'Google IAP fulfilled: ${result.internalTransactionId} ($productId)',
        level: LogLevel.info,
      );

      return IapValidationResponse(
        success: true,
        productId: productId,
        tag: result.tag,
        amount: result.quantity,
        fromCache: result.fromCache,
      );
    } on AuthenticationException {
      rethrow;
    } on PaymentException {
      rethrow;
    } catch (e) {
      throw AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.internalError,
        message: 'Unexpected error validating Google purchase: ${e.toString()}',
        details: {
          'error': e.toString(),
          'productId': productId,
        },
      );
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
