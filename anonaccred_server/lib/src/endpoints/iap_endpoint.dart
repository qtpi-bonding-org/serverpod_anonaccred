import 'package:serverpod/serverpod.dart';

import 'package:anonaccount_server/anonaccount_server.dart';

import '../protocol_failures.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../payments/payment_manager.dart';
import '../payments/rails/apple_iap_rail.dart';
import '../payments/rails/google_iap_rail.dart';

/// JWT-protected In-App Purchase endpoint for Apple and Google IAP validation.
///
/// Implements a "Reactive & Anonymous" fulfillment flow.
/// 1. Identity-Linked Inventory: Adds coins directly to the account balance.
/// 2. Identity-Free Financials: Records the payment in TransactionPayment without an accountUuid.
/// 3. The Bridge: EphemeralAuditLog links the two for 7 days, then breaks.
class IAPEndpoint extends JwtEndpoint {
  /// Validate Apple App Store transaction and fulfill purchase.
  ///
  /// This endpoint is reactive: if no order exists, it creates the financial
  /// record on-the-fly from the verified receipt.
  ///
  /// Parameters:
  /// - [transactionId]: Apple transaction ID from the app
  /// - [productId]: Apple product ID (SKU)
  /// - [internalTransactionId]: Optional client-generated reference (e.g. UUID)
  Future<IapValidationResponse> validateAppleTransaction(
    Session session,
    String transactionId,
    String productId, {
    String? internalTransactionId,
  }) async {
    return tryOperation(
      session,
      'validateAppleTransaction',
      () async {
        final accountUuid = getAccountUuid(session);
        await AnonAccountHelpers.requireCaller(
          session,
          getDevicePublicKey(session),
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

        // Prefer a rail registered with PaymentManager (tests inject a mock
        // client this way, mirroring PolarEndpoint's pattern), otherwise
        // build the live rail from environment credentials.
        final appleRail =
            PaymentManager.getRail(PaymentRail.apple_iap) as AppleIAPRail? ??
            await AppleIAPRail.create();
        final result = await appleRail.validateTransaction(
          session: session,
          transactionId: transactionId,
          productId: productId,
          accountUuid: accountUuid,
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
      },
      onFailure: accountFailure,
      code: AnonAccountErrorCodes.internalError,
      extraDetails: {'transactionId': transactionId},
    );
  }

  /// Validate Google Play purchase and fulfill purchase.
  ///
  /// This endpoint is reactive: if no order exists, it creates the financial
  /// record on-the-fly from the verified purchase token.
  ///
  /// Parameters:
  /// - [packageName]: Android app package name
  /// - [productId]: Google product ID (SKU)
  /// - [purchaseToken]: Google purchase token
  /// - [internalTransactionId]: Optional client-generated reference (e.g. UUID)
  Future<IapValidationResponse> validateGooglePurchase(
    Session session,
    String packageName,
    String productId,
    String purchaseToken, {
    String? internalTransactionId,
  }) async {
    return tryOperation(
      session,
      'validateGooglePurchase',
      () async {
        final accountUuid = getAccountUuid(session);
        await AnonAccountHelpers.requireCaller(
          session,
          getDevicePublicKey(session),
          'validateGooglePurchase',
        );

        // Validate parameters
        if (packageName.isEmpty || productId.isEmpty || purchaseToken.isEmpty) {
          throw AnonAccredExceptionFactory.createPaymentException(
            code: AnonAccredErrorCodes.paymentValidationFailed,
            message:
                'Package name, product ID, and purchase token are required',
            internalTransactionId: internalTransactionId,
          );
        }

        // Prefer a rail registered with PaymentManager (tests inject a mock
        // client this way, mirroring PolarEndpoint's pattern), otherwise
        // build the live rail from environment credentials.
        final googleRail =
            PaymentManager.getRail(PaymentRail.google_iap) as GoogleIAPRail? ??
            await GoogleIAPRail.create();
        final result = await googleRail.validatePurchase(
          session: session,
          packageName: packageName,
          productId: productId,
          purchaseToken: purchaseToken,
          accountUuid: accountUuid,
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
      },
      onFailure: accountFailure,
      code: AnonAccountErrorCodes.internalError,
      extraDetails: {'productId': productId},
    );
  }
}
