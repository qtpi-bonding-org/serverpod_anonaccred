// anonaccred_server/test/unit/mock_polar_client_test.dart
import 'package:anonaccred_server/src/payments/mock_polar_client.dart';
import 'package:anonaccred_server/src/payments/polar_client.dart';
import 'package:anonaccred_server/src/protocol_failures.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  group('MockPolarClient', () {
    test('validateLicenseKey returns a configured mock response', () async {
      final client = MockPolarClient();
      final validation = PolarLicenseValidation(
        id: 'lk-1',
        key: 'LICENSE-KEY-1',
        status: 'granted',
        organizationId: 'org-1',
        benefitId: 'benefit-1',
        customerId: 'cust-1',
        expiresAt: null,
        raw: const {},
      );
      client.addMockLicense('LICENSE-KEY-1', validation);

      final result = await client.validateLicenseKey(key: 'LICENSE-KEY-1');

      expect(result.benefitId, 'benefit-1');
      expect(client.callLog, hasLength(1));
      expect(client.callLog.first.method, 'validateLicenseKey');
    });

    test('validateLicenseKey throws PaymentException for an unknown key', () async {
      final client = MockPolarClient();

      await expectLater(
        client.validateLicenseKey(key: 'UNKNOWN'),
        throwsA(isA<PaymentException>()),
      );
    });

    test('getOrder returns a configured mock order', () async {
      final client = MockPolarClient();
      client.addMockOrder('order-1', {'id': 'order-1', 'status': 'refunded'});

      final order = await client.getOrder('order-1');

      expect(order['status'], 'refunded');
    });
  });
}
