import 'package:googleapis/androidpublisher/v3.dart';

import 'android_publisher_client.dart';

/// Represents a single API call made through the mock client
///
/// Used for test verification to ensure the correct methods were called
/// with the correct parameters.
class ApiCall {
  final String methodName;
  final Map<String, dynamic> parameters;

  ApiCall(this.methodName, this.parameters);

  @override
  String toString() => '$methodName($parameters)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiCall &&
          runtimeType == other.runtimeType &&
          methodName == other.methodName &&
          parameters == other.parameters;

  @override
  int get hashCode => methodName.hashCode ^ parameters.hashCode;
}

/// Mock implementation of AndroidPublisherClient for testing
///
/// Provides a test double that simulates the AndroidPublisher API without
/// making real Google API calls. Tracks all method calls for test verification.
///
/// Requirements 9.1, 9.2, 9.3, 9.4, 9.5: Mock support for testing
class MockAndroidPublisherClient implements AndroidPublisherClient {
  /// Log of all API calls made through this mock client
  ///
  /// Each call is recorded with the method name and parameters for test verification.
  /// Requirements 9.5: Mock API call tracking
  final List<ApiCall> callLog = [];

  /// Map of purchase tokens to mock purchase data
  ///
  /// Used to configure mock responses for getPurchase() calls.
  /// Requirements 9.2: addMockPurchase() for test setup
  final Map<String, ProductPurchase> mockPurchases = {};

  /// Add a mock purchase response for testing
  ///
  /// Configures the mock client to return the specified ProductPurchase
  /// when getPurchase() is called with the given purchase token.
  ///
  /// Parameters:
  /// - [purchaseToken]: The purchase token to match
  /// - [purchase]: The ProductPurchase object to return
  ///
  /// Requirements 9.2: Implement addMockPurchase() for test setup
  void addMockPurchase(String purchaseToken, ProductPurchase purchase) {
    mockPurchases[purchaseToken] = purchase;
  }

  /// Validate purchase by retrieving purchase details (mock implementation)
  ///
  /// Returns mock purchase data if configured, otherwise throws ApiRequestError.
  /// Logs the call for test verification.
  ///
  /// Parameters:
  /// - [packageName]: Android app package name
  /// - [productId]: In-app product ID (SKU)
  /// - [purchaseToken]: Purchase token from Android app
  ///
  /// Returns: [ProductPurchase] with mock purchase details
  ///
  /// Throws: [ApiRequestError] if purchase token not found in mock data
  ///
  /// Requirements 9.3: getPurchase() returning mock data or throwing ApiRequestError
  Future<ProductPurchase> getPurchase({
    required String packageName,
    required String productId,
    required String purchaseToken,
  }) async {
    callLog.add(ApiCall('getPurchase', {
      'packageName': packageName,
      'productId': productId,
      'purchaseToken': purchaseToken,
    }));

    if (mockPurchases.containsKey(purchaseToken)) {
      return mockPurchases[purchaseToken]!;
    }

    throw ApiRequestError('Purchase not found: $purchaseToken');
  }

  /// Acknowledge purchase (mock implementation)
  ///
  /// Logs the call for test verification. Does not perform any actual operations.
  ///
  /// Parameters:
  /// - [packageName]: Android app package name
  /// - [productId]: In-app product ID (SKU)
  /// - [purchaseToken]: Purchase token from Android app
  ///
  /// Requirements 9.4: acknowledgePurchase() with call logging
  Future<void> acknowledgePurchase({
    required String packageName,
    required String productId,
    required String purchaseToken,
  }) async {
    callLog.add(ApiCall('acknowledgePurchase', {
      'packageName': packageName,
      'productId': productId,
      'purchaseToken': purchaseToken,
    }));
  }

  /// Consume purchase (mock implementation)
  ///
  /// Logs the call for test verification. Does not perform any actual operations.
  ///
  /// Parameters:
  /// - [packageName]: Android app package name
  /// - [productId]: In-app product ID (SKU)
  /// - [purchaseToken]: Purchase token from Android app
  ///
  /// Requirements 9.4: consumePurchase() with call logging
  Future<void> consumePurchase({
    required String packageName,
    required String productId,
    required String purchaseToken,
  }) async {
    callLog.add(ApiCall('consumePurchase', {
      'packageName': packageName,
      'productId': productId,
      'purchaseToken': purchaseToken,
    }));
  }
}
