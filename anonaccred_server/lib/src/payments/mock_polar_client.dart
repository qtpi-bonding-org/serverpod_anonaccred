// anonaccred_server/lib/src/payments/mock_polar_client.dart
import 'polar_client.dart';
import 'polar_http_client.dart';
import 'mock_api_call.dart';
import '../protocol_failures.dart';
import '../generated/protocol.dart';
import '../exception_factory.dart';

export 'mock_api_call.dart' show ApiCall;

/// Test double for [PolarClient]. Subclasses rather than implements an
/// interface because PolarRail depends on the concrete PolarClient type
/// directly (unlike AppleIAPRail/GoogleIAPRail, which depend on abstract
/// client interfaces) — see the design spec's note on this asymmetry.
class MockPolarClient extends PolarClient {
  MockPolarClient()
      : super(
          organizationId: 'mock-org',
          http: PolarHttpClient(
            baseUrl: 'http://mock.invalid',
            bearerToken: 'mock-token',
          ),
        );

  final List<ApiCall> callLog = [];
  final Map<String, PolarLicenseValidation> _mockLicenses = {};
  final Map<String, Map<String, dynamic>> _mockOrders = {};

  Object? validateLicenseKeyError;

  void addMockLicense(String key, PolarLicenseValidation validation) {
    _mockLicenses[key] = validation;
  }

  void addMockOrder(String orderId, Map<String, dynamic> orderJson) {
    _mockOrders[orderId] = orderJson;
  }

  @override
  Future<PolarLicenseValidation> validateLicenseKey({
    required String key,
    String? activationId,
    String? benefitId,
    int? incrementUsage,
  }) async {
    callLog.add(ApiCall('validateLicenseKey', {'key': key}));

    if (validateLicenseKeyError != null) {
      throw validateLicenseKeyError!;
    }

    final validation = _mockLicenses[key];
    if (validation == null) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.polarValidationFailed,
        message: 'License key not found in mock: $key',
        paymentRail: PaymentRail.polar.name,
      );
    }
    return validation;
  }

  @override
  Future<Map<String, dynamic>> getOrder(String orderId) async {
    callLog.add(ApiCall('getOrder', {'orderId': orderId}));

    final order = _mockOrders[orderId];
    if (order == null) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.polarApiUnavailable,
        message: 'Order not found in mock: $orderId',
        paymentRail: PaymentRail.polar.name,
      );
    }
    return order;
  }
}
