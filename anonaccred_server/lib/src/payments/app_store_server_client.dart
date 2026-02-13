import 'package:app_store_server_sdk/app_store_server_sdk.dart';
import '../exception_factory.dart';
import 'apple_jwt_auth_client.dart';

/// Wrapper around app_store_server_sdk for type-safe access to App Store Server API.
///
/// This class provides a clean interface for interacting with Apple's App Store
/// Server API, wrapping the AppStoreServerAPI from the app_store_server_sdk
/// package. It handles authentication via AppleJWTAuthClient and provides
/// convenient methods for common operations.
///
/// **Purpose:**
/// - Provides type-safe access to App Store Server API endpoints
/// - Handles authentication and token management
/// - Adds error handling using app_store_server_sdk error types
///
/// **Supported Operations:**
/// - getTransactionInfo: Retrieve transaction details by transaction ID (via history lookup)
/// - getTransactionHistory: Get transaction history with pagination support
/// - lookUpOrderId: Look up order ID for a transaction
///
/// **Usage Example:**
/// ```dart
/// final authClient = AppleJWTAuthClient.fromEnvironment();
/// final client = AppStoreServerClient(authClient);
///
/// final transactionInfo = await client.getTransactionInfo('transaction_id');
/// final history = await client.getTransactionHistory(
///   originalTransactionId: 'original_txn_id',
/// );
/// ```
class AppStoreServerClient {
  final AppStoreServerAPI _api;

  /// Creates a new AppStoreServerClient instance.
  ///
  /// [authClient] - The Apple JWT authentication client
  /// [environment] - The Apple environment to connect to (sandbox or production)
  AppStoreServerClient(
    AppleJWTAuthClient authClient, {
    AppStoreClientEnvironment environment = AppStoreClientEnvironment.production,
  })  : _api = AppStoreServerAPI(
          AppStoreServerHttpClient(
            environment == AppStoreClientEnvironment.production
                ? AppStoreEnvironment.live(
                    bundleId: authClient.bundleId,
                    issuerId: authClient.issuerId,
                    keyId: authClient.keyId,
                    privateKey: authClient.privateKey,
                  )
                : AppStoreEnvironment.sandbox(
                    bundleId: authClient.bundleId,
                    issuerId: authClient.issuerId,
                    keyId: authClient.keyId,
                    privateKey: authClient.privateKey,
                  ),
          ),
        );

  /// Get transaction information for a given transaction ID.
  ///
  /// Note: The App Store Server API doesn't have a direct "get transaction info" endpoint.
  /// This method retrieves the transaction history and finds the specific transaction.
  ///
  /// [transactionId] - The Apple transaction ID to look up
  ///
  /// Returns a [HistoryResponse] containing the transaction details.
  ///
  /// Throws:
  /// - [PaymentException] with code PAYMENT_VALIDATION_FAILED if transaction is invalid
  /// - [PaymentException] with code CONFIGURATION_MISSING if API configuration is invalid
  /// - [AnonAccredException] for other API errors
  Future<HistoryResponse> getTransactionInfo(
    String transactionId,
  ) async {
    try {
      // The SDK doesn't have a direct getTransactionInfo method
      // We use getTransactionHistory with the transaction ID as the original transaction ID
      return await _api.getTransactionHistory(transactionId);
    } on ApiException catch (e) {
      _handleApiException(e, 'getTransactionInfo', {'transactionId': transactionId});
      rethrow;
    } on Exception catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Failed to get transaction info: ${e.toString()}',
        details: {'transactionId': transactionId, 'operation': 'getTransactionInfo'},
      );
    }
  }

  /// Get transaction history for an original transaction ID.
  ///
  /// [originalTransactionId] - The original Apple transaction ID
  /// [revision] - Optional revision token for pagination
  ///
  /// Returns a [HistoryResponse] containing the transaction history.
  /// The response includes a revision token for fetching subsequent pages.
  ///
  /// Throws:
  /// - [PaymentException] with code PAYMENT_VALIDATION_FAILED if request fails
  /// - [AnonAccredException] for other API errors
  Future<HistoryResponse> getTransactionHistory({
    required String originalTransactionId,
    String? revision,
  }) async {
    try {
      return await _api.getTransactionHistory(
        originalTransactionId,
        revision: revision,
      );
    } on ApiException catch (e) {
      _handleApiException(
        e,
        'getTransactionHistory',
        {'originalTransactionId': originalTransactionId, 'revision': revision ?? 'null'},
      );
      rethrow;
    } on Exception catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Failed to get transaction history: ${e.toString()}',
        details: {
          'originalTransactionId': originalTransactionId,
          'operation': 'getTransactionHistory',
        },
      );
    }
  }

  /// Look up an order ID for a given transaction.
  ///
  /// [orderId] - The Apple order ID to look up
  ///
  /// Returns an [OrderLookupResponse] containing the order details.
  ///
  /// Throws:
  /// - [PaymentException] with code PAYMENT_VALIDATION_FAILED if order not found
  /// - [AnonAccredException] for other API errors
  Future<OrderLookupResponse> lookUpOrderId(String orderId) async {
    try {
      return await _api.lookUpOrderId(orderId);
    } on ApiException catch (e) {
      _handleApiException(e, 'lookUpOrderId', {'orderId': orderId});
      rethrow;
    } on Exception catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Failed to look up order ID: ${e.toString()}',
        details: {'orderId': orderId, 'operation': 'lookUpOrderId'},
      );
    }
  }

  /// Handles ApiException from the app_store_server_sdk and converts to appropriate domain exceptions.
  ///
  /// [exception] - The API exception from the SDK
  /// [operation] - The name of the operation that failed
  /// [details] - Additional details about the request
  void _handleApiException(
    ApiException exception,
    String operation,
    Map<String, String> details,
  ) {
    final errorCode = _mapApiErrorToErrorCode(exception.statusCode);
    final message = _getErrorMessage(exception);

    throw AnonAccredExceptionFactory.createPaymentException(
      code: errorCode,
      message: message,
      details: {
        ...details,
        'apiStatusCode': exception.statusCode.toString(),
        'apiErrorCode': exception.error?.errorCode.toString() ?? 'unknown',
        'apiErrorMessage': exception.error?.errorMessage ?? 'Unknown error',
        'operation': operation,
      },
    );
  }

  /// Maps app_store_server_sdk error codes to AnonAccred error codes.
  String _mapApiErrorToErrorCode(int statusCode) {
    // Map known Apple API status codes to AnonAccred error codes
    switch (statusCode) {
      case 404:
        return AnonAccredErrorCodes.paymentValidationFailed;
      case 401:
      case 403:
        return AnonAccredErrorCodes.configurationMissing;
      case 429:
        return AnonAccredErrorCodes.networkTimeout;
      default:
        return AnonAccredErrorCodes.paymentValidationFailed;
    }
  }

  /// Gets a user-friendly error message for the API exception.
  String _getErrorMessage(ApiException exception) {
    final statusCode = exception.statusCode;
    final errorMessage = exception.error?.errorMessage;

    if (statusCode == 404) {
      return 'Transaction not found';
    } else if (statusCode == 401 || statusCode == 403) {
      return 'Authentication failed with App Store Server API';
    } else if (statusCode == 429) {
      return 'Rate limit exceeded for App Store Server API';
    } else if (errorMessage != null && errorMessage.isNotEmpty) {
      return errorMessage;
    }

    return 'App Store Server API error: Status $statusCode';
  }
}

/// Apple environment for API connections.
enum AppStoreClientEnvironment {
  /// Production environment
  production,
  /// Sandbox environment for testing
  sandbox,
}