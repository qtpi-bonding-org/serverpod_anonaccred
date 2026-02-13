import 'package:googleapis/androidpublisher/v3.dart';
import 'package:googleapis_auth/googleapis_auth.dart';

import '../exception_factory.dart';
import '../generated/protocol.dart';

/// Wrapper around googleapis AndroidPublisher API for type-safe access
///
/// Provides methods for validating, acknowledging, and consuming purchases
/// using the Google Play Developer API through the googleapis package.
///
/// Requirements 2.1, 2.2, 2.3, 2.4, 2.5: AndroidPublisher API integration
class AndroidPublisherClient {
  final AndroidPublisherApi _api;

  AndroidPublisherClient(AuthClient authClient)
      : _api = AndroidPublisherApi(authClient);

  /// Validate purchase by retrieving purchase details
  ///
  /// Calls purchases.products.get() to retrieve the current state of a purchase.
  /// Returns the ProductPurchase object containing purchase details.
  ///
  /// Parameters:
  /// - [packageName]: Android app package name
  /// - [productId]: In-app product ID (SKU)
  /// - [purchaseToken]: Purchase token from Android app
  ///
  /// Returns: [ProductPurchase] with purchase details
  ///
  /// Throws: [PaymentException] if the API call fails
  ///
  /// Requirements 2.1: Use purchases.products.get() from googleapis
  Future<ProductPurchase> getPurchase({
    required String packageName,
    required String productId,
    required String purchaseToken,
  }) async {
    try {
      return await _api.purchases.products.get(
        packageName,
        productId,
        purchaseToken,
      );
    } catch (e) {
      throw _handleApiError(
        e,
        'Failed to get purchase details',
        {
          'packageName': packageName,
          'productId': productId,
          'purchaseToken': purchaseToken,
        },
      );
    }
  }

  /// Acknowledge purchase
  ///
  /// Calls purchases.products.acknowledge() to acknowledge a purchase.
  /// Google requires purchases to be acknowledged within 3 days or they will
  /// be automatically refunded.
  ///
  /// Parameters:
  /// - [packageName]: Android app package name
  /// - [productId]: In-app product ID (SKU)
  /// - [purchaseToken]: Purchase token from Android app
  ///
  /// Throws: [PaymentException] if the API call fails
  ///
  /// Requirements 2.2: Use purchases.products.acknowledge() from googleapis
  Future<void> acknowledgePurchase({
    required String packageName,
    required String productId,
    required String purchaseToken,
  }) async {
    try {
      await _api.purchases.products.acknowledge(
        ProductPurchasesAcknowledgeRequest(),
        packageName,
        productId,
        purchaseToken,
      );
    } catch (e) {
      throw _handleApiError(
        e,
        'Failed to acknowledge purchase',
        {
          'packageName': packageName,
          'productId': productId,
          'purchaseToken': purchaseToken,
        },
      );
    }
  }

  /// Consume purchase
  ///
  /// Calls purchases.products.consume() to mark a consumable purchase as consumed.
  /// This allows the user to purchase the same consumable again.
  ///
  /// Parameters:
  /// - [packageName]: Android app package name
  /// - [productId]: In-app product ID (SKU)
  /// - [purchaseToken]: Purchase token from Android app
  ///
  /// Throws: [PaymentException] if the API call fails
  ///
  /// Requirements 2.3: Use purchases.products.consume() from googleapis
  Future<void> consumePurchase({
    required String packageName,
    required String productId,
    required String purchaseToken,
  }) async {
    try {
      await _api.purchases.products.consume(
        packageName,
        productId,
        purchaseToken,
      );
    } catch (e) {
      throw _handleApiError(
        e,
        'Failed to consume purchase',
        {
          'packageName': packageName,
          'productId': productId,
          'purchaseToken': purchaseToken,
        },
      );
    }
  }

  /// Handle googleapis API errors and convert to domain exceptions
  ///
  /// Converts googleapis error types to PaymentException with appropriate
  /// error codes and messages.
  ///
  /// Requirements 2.5: Handle API errors using googleapis error types
  PaymentException _handleApiError(
    dynamic error,
    String message,
    Map<String, dynamic> details,
  ) {
    // Handle DetailedApiRequestError from googleapis
    if (error is DetailedApiRequestError) {
      return AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentValidationFailed,
        message: '$message: ${error.message ?? 'Unknown error'}',
        details: {
          ...details.map((k, v) => MapEntry(k, v.toString())),
          'httpStatus': error.status.toString(),
          'apiError': error.message ?? 'Unknown error',
        },
      );
    }

    // Handle generic ApiRequestError from googleapis
    if (error is ApiRequestError) {
      return AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentValidationFailed,
        message: '$message: ${error.message ?? 'Unknown error'}',
        details: {
          ...details.map((k, v) => MapEntry(k, v.toString())),
          'apiError': error.message ?? 'Unknown error',
        },
      );
    }

    // Handle other exceptions
    return AnonAccredExceptionFactory.createPaymentException(
      code: AnonAccredErrorCodes.paymentValidationFailed,
      message: '$message: ${error.toString()}',
      details: {
        ...details.map((k, v) => MapEntry(k, v.toString())),
        'error': error.toString(),
      },
    );
  }
}
