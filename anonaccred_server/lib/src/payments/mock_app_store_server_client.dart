import 'package:app_store_server_sdk/app_store_server_sdk.dart';
import 'app_store_server_client.dart';

/// Mock implementation of AppStoreServerClient for testing without real API calls.
///
/// This mock tracks all API calls made through it and allows tests to set up
/// mock responses for different scenarios. It's designed to be used in unit tests
/// to avoid making real network calls to Apple's servers.
///
/// **Features:**
/// - Call logging: Tracks all API calls with their parameters
/// - Mock responses: Pre-configure responses for specific transaction IDs
/// - Error simulation: Can throw ApiException for testing error handling
///
/// **Usage Example:**
/// ```dart
/// final mockClient = MockAppStoreServerClient();
///
/// // Set up mock transaction
/// mockClient.addMockTransaction('txn_123', HistoryResponse(
///   signedTransactions: ['signed_jwt_token'],
/// ));
///
/// // Use in tests
/// final response = await mockClient.getTransactionInfo('txn_123');
/// expect(mockClient.callLog.length, equals(1));
/// expect(mockClient.callLog.first.method, equals('getTransactionInfo'));
/// ```
class MockAppStoreServerClient implements AppStoreServerClient {
  /// Log of all API calls made through this mock client
  final List<ApiCall> callLog = [];

  /// Mock transaction responses keyed by transaction ID
  final Map<String, HistoryResponse> _mockTransactions = {};

  /// Mock history responses keyed by original transaction ID
  final Map<String, HistoryResponse> _mockHistories = {};

  /// Add a mock transaction response for a specific transaction ID.
  ///
  /// [transactionId] - The transaction ID to mock
  /// [response] - The HistoryResponse to return when this transaction is requested
  void addMockTransaction(String transactionId, HistoryResponse response) {
    _mockTransactions[transactionId] = response;
  }

  /// Add a mock history response for a specific original transaction ID.
  ///
  /// [originalTransactionId] - The original transaction ID to mock
  /// [response] - The HistoryResponse to return when this history is requested
  void addMockHistory(String originalTransactionId, HistoryResponse response) {
    _mockHistories[originalTransactionId] = response;
  }

  @override
  Future<HistoryResponse> getTransactionInfo(String transactionId) async {
    callLog.add(ApiCall('getTransactionInfo', {
      'transactionId': transactionId,
    }));

    if (_mockTransactions.containsKey(transactionId)) {
      return _mockTransactions[transactionId]!;
    }

    throw ApiException(404, error: const ApiError(4040000, 'Transaction not found'));
  }

  @override
  Future<HistoryResponse> getTransactionHistory({
    required String originalTransactionId,
    String? revision,
  }) async {
    callLog.add(ApiCall('getTransactionHistory', {
      'originalTransactionId': originalTransactionId,
      'revision': revision ?? 'null',
    }));

    if (_mockHistories.containsKey(originalTransactionId)) {
      return _mockHistories[originalTransactionId]!;
    }

    // Return empty history if not found (not an error)
    return const HistoryResponse('sandbox', null, 'com.example.app', false, '', []);
  }

  @override
  Future<OrderLookupResponse> lookUpOrderId(String orderId) async {
    callLog.add(ApiCall('lookUpOrderId', {
      'orderId': orderId,
    }));

    throw ApiException(501, error: const ApiError(5010000, 'Not implemented in mock'));
  }
}

/// Represents a single API call made through the mock client.
///
/// Used for test verification to ensure the correct API methods were called
/// with the expected parameters.
class ApiCall {
  /// The name of the API method that was called
  final String method;

  /// The parameters passed to the API method
  final Map<String, String> parameters;

  ApiCall(this.method, this.parameters);

  @override
  String toString() => 'ApiCall{method: $method, parameters: $parameters}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiCall &&
          runtimeType == other.runtimeType &&
          method == other.method &&
          _mapsEqual(parameters, other.parameters);

  @override
  int get hashCode => method.hashCode ^ parameters.hashCode;

  bool _mapsEqual(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (var key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}
