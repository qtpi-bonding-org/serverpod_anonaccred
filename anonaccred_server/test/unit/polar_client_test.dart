import 'dart:convert';

import 'package:anonaccred_server/src/exception_factory.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/polar_client.dart';
import 'package:anonaccred_server/src/payments/polar_http_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _organizationId = '00000000-0000-0000-0000-000000000001';

Map<String, dynamic> _grantedBody({
  String status = 'granted',
  String? expiresAt,
}) =>
    {
      'id': 'license-id',
      'organization_id': _organizationId,
      'customer_id': 'cust',
      'benefit_id': 'benefit-1',
      'key': 'k',
      'status': status,
      'expires_at': expiresAt,
    };

PolarClient _client(http.Client mock) => PolarClient(
      organizationId: _organizationId,
      http: PolarHttpClient(
        baseUrl: 'https://api.polar.sh',
        bearerToken: 't',
        httpClient: mock,
      ),
    );

Matcher _paymentExceptionWithCode(String code) =>
    isA<PaymentException>().having((e) => e.code, 'code', code);

void main() {
  group('PolarClient.validateLicenseKey', () {
    test('returns parsed validation on granted', () async {
      final mock = MockClient((req) async => http.Response(
            jsonEncode(_grantedBody(expiresAt: '2026-12-31T00:00:00Z')),
            200,
          ));
      final v = await _client(mock).validateLicenseKey(key: 'k');
      expect(v.isGranted, isTrue);
      expect(v.id, 'license-id');
      expect(v.benefitId, 'benefit-1');
      expect(v.expiresAt, DateTime.parse('2026-12-31T00:00:00Z'));
    });

    test('sends organization_id + key in request body', () async {
      late http.Request captured;
      final mock = MockClient((req) async {
        captured = req;
        return http.Response(jsonEncode(_grantedBody()), 200);
      });
      await _client(mock).validateLicenseKey(key: 'k');
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['key'], 'k');
      expect(body['organization_id'], _organizationId);
      expect(body.containsKey('activation_id'), isFalse);
    });

    test('hits /v1/license-keys/validate via POST', () async {
      late http.Request captured;
      final mock = MockClient((req) async {
        captured = req;
        return http.Response(jsonEncode(_grantedBody()), 200);
      });
      await _client(mock).validateLicenseKey(key: 'k');
      expect(captured.method, 'POST');
      expect(captured.url.path, '/v1/license-keys/validate');
    });

    test('status=revoked → POLAR_LICENSE_REVOKED', () async {
      final mock = MockClient((req) async => http.Response(
            jsonEncode(_grantedBody(status: 'revoked')),
            200,
          ));
      expect(
        () => _client(mock).validateLicenseKey(key: 'k'),
        throwsA(_paymentExceptionWithCode(AnonAccredErrorCodes.polarLicenseRevoked)),
      );
    });

    test('status=disabled → POLAR_LICENSE_REVOKED', () async {
      final mock = MockClient((req) async => http.Response(
            jsonEncode(_grantedBody(status: 'disabled')),
            200,
          ));
      expect(
        () => _client(mock).validateLicenseKey(key: 'k'),
        throwsA(_paymentExceptionWithCode(AnonAccredErrorCodes.polarLicenseRevoked)),
      );
    });
  });
}
