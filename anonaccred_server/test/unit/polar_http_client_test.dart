import 'dart:async';
import 'dart:io';

import 'package:anonaccred_server/src/exception_factory.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/polar_http_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

PolarHttpClient _client(http.Client mock) => PolarHttpClient(
      baseUrl: 'https://api.polar.sh',
      bearerToken: 'tok',
      httpClient: mock,
    );

Matcher _paymentExceptionWithCode(String code) =>
    isA<PaymentException>().having((e) => e.code, 'code', code);

void main() {
  group('PolarHttpClient.postJson', () {
    test('attaches bearer token and JSON headers', () async {
      late http.Request captured;
      final mock = MockClient((req) async {
        captured = req;
        return http.Response('{"ok":true}', 200);
      });
      await _client(mock).postJson('/v1/anything', body: {'k': 'v'});
      expect(captured.headers['authorization'], 'Bearer tok');
      expect(captured.headers['content-type'], startsWith('application/json'));
      expect(captured.body, '{"k":"v"}');
    });

    test('returns decoded JSON on 2xx', () async {
      final mock = MockClient(
          (req) async => http.Response('{"a":1,"b":"x"}', 200));
      final res = await _client(mock).postJson('/v1/p', body: {});
      expect(res.statusCode, 200);
      expect(res.body['a'], 1);
      expect(res.body['b'], 'x');
    });

    test('5xx → POLAR_API_UNAVAILABLE', () async {
      final mock = MockClient((req) async => http.Response('bad', 503));
      expect(
        () => _client(mock).postJson('/v1/p', body: {}),
        throwsA(_paymentExceptionWithCode(AnonAccredErrorCodes.polarApiUnavailable)),
      );
    });

    test('SocketException → POLAR_API_UNAVAILABLE', () async {
      final mock = MockClient((req) async => throw const SocketException('no'));
      expect(
        () => _client(mock).postJson('/v1/p', body: {}),
        throwsA(_paymentExceptionWithCode(AnonAccredErrorCodes.polarApiUnavailable)),
      );
    });

    test('TimeoutException → POLAR_API_UNAVAILABLE', () async {
      final mock =
          MockClient((req) async => throw TimeoutException('timed out'));
      expect(
        () => _client(mock).postJson('/v1/p', body: {}),
        throwsA(_paymentExceptionWithCode(AnonAccredErrorCodes.polarApiUnavailable)),
      );
    });

    test('401 → CONFIGURATION_MISSING', () async {
      final mock = MockClient((req) async => http.Response('forbidden', 401));
      expect(
        () => _client(mock).postJson('/v1/p', body: {}),
        throwsA(_paymentExceptionWithCode(AnonAccredErrorCodes.configurationMissing)),
      );
    });

    test('403 → CONFIGURATION_MISSING', () async {
      final mock = MockClient((req) async => http.Response('forbidden', 403));
      expect(
        () => _client(mock).postJson('/v1/p', body: {}),
        throwsA(_paymentExceptionWithCode(AnonAccredErrorCodes.configurationMissing)),
      );
    });

    test('4xx (other) → POLAR_VALIDATION_FAILED', () async {
      final mock = MockClient(
          (req) async => http.Response('{"detail":"no"}', 404));
      expect(
        () => _client(mock).postJson('/v1/p', body: {}),
        throwsA(_paymentExceptionWithCode(AnonAccredErrorCodes.polarValidationFailed)),
      );
    });

    test('malformed JSON on 2xx → POLAR_API_UNAVAILABLE', () async {
      final mock = MockClient((req) async => http.Response('not json {', 200));
      expect(
        () => _client(mock).postJson('/v1/p', body: {}),
        throwsA(_paymentExceptionWithCode(AnonAccredErrorCodes.polarApiUnavailable)),
      );
    });
  });
}
