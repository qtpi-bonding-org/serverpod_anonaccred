import 'dart:convert';

import 'package:anonaccount_server/src/crypto_utils.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/polar_client.dart';
import 'package:anonaccred_server/src/payments/polar_http_client.dart';
import 'package:anonaccred_server/src/payments/polar_signature_validator.dart';
import 'package:anonaccred_server/src/payments/rails/polar_rail.dart';
import 'package:anonaccred_server/src/refund_manager.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

PolarRail _rail(http.Client mock) => PolarRail(
  client: PolarClient(
    organizationId: 'org',
    http: PolarHttpClient(
      baseUrl: 'https://api.polar.sh',
      bearerToken: 't',
      httpClient: mock,
    ),
  ),
);

void main() {
  group('PolarRail interface conformance', () {
    test('railType is PaymentRail.polar', () {
      final mock = MockClient((req) async => http.Response('{}', 200));
      expect(_rail(mock).railType, PaymentRail.polar);
    });

    test('createPayment returns license_key flow PaymentRequest', () async {
      final mock = MockClient((req) async => http.Response('{}', 200));
      final req = await _rail(
        mock,
      ).createPayment(amountUSD: 9.99, internalTransactionId: 'tx-1');
      expect(req.paymentRef, 'tx-1');
      expect(req.amountUSD, 9.99);
      expect(req.internalTransactionId, 'tx-1');
      final railData = jsonDecode(req.railDataJson) as Map<String, dynamic>;
      expect(railData['payment_rail'], 'polar');
      expect(railData['flow'], 'license_key');
    });

    test('processCallback rejects an unconfigured webhook secret', () async {
      final mock = MockClient((req) async => http.Response('{}', 200));
      final result = await _rail(mock).processCallback({
        'session': null,
        'request_body': '{"type":"refund.created"}',
        'headers': <String, String>{},
      });
      expect(result.success, isFalse);
    });
  });

  group('PolarRail.signatureValidator', () {
    test('defaults to null when not provided', () {
      final mock = MockClient((req) async => http.Response('{}', 200));
      expect(_rail(mock).signatureValidator, isNull);
    });

    test('can be constructed with a configured validator', () {
      final mock = MockClient((req) async => http.Response('{}', 200));
      final validator = PolarSignatureValidator(secret: 'whsec_dGVzdA==');
      final rail = PolarRail(
        client: PolarClient(
          organizationId: 'org',
          http: PolarHttpClient(
            baseUrl: 'https://api.polar.sh',
            bearerToken: 't',
            httpClient: mock,
          ),
        ),
        signatureValidator: validator,
      );
      expect(rail.signatureValidator, same(validator));
    });
  });

  group('PolarRail.extractRefundEvent', () {
    test('parses refund.created into RefundEvent', () {
      final mock = MockClient((req) async => http.Response('{}', 200));
      final result = _rail(mock).extractRefundEvent({
        'type': 'refund.created',
        'data': {
          'order_id': 'ord-1',
          'created_at': '2026-01-01T00:00:00Z',
          'product_id': 'prod-x',
        },
      });
      expect(result, isNotNull);
      expect(result!.rail, PaymentRail.polar);
      expect(result.paymentRef, 'ord-1');
      expect(result.productId, 'prod-x');
      expect(result.purchaseTimestamp, DateTime.parse('2026-01-01T00:00:00Z'));
    });

    test('parses refund.updated into RefundEvent', () {
      final mock = MockClient((req) async => http.Response('{}', 200));
      final result = _rail(mock).extractRefundEvent({
        'type': 'refund.updated',
        'data': {'order_id': 'ord-2', 'created_at': '2026-01-02T00:00:00Z'},
      });
      expect(result, isNotNull);
      expect(result!.paymentRef, 'ord-2');
    });

    test('returns null for non-refund types', () {
      final mock = MockClient((req) async => http.Response('{}', 200));
      expect(
        _rail(mock).extractRefundEvent({'type': 'order.created', 'data': {}}),
        isNull,
      );
    });

    test('returns null when order_id is missing', () {
      final mock = MockClient((req) async => http.Response('{}', 200));
      expect(
        _rail(mock).extractRefundEvent({
          'type': 'refund.created',
          'data': {'customer_id': 'cust'},
        }),
        isNull,
      );
    });

    test('returns null when malformed', () {
      final mock = MockClient((req) async => http.Response('{}', 200));
      expect(_rail(mock).extractRefundEvent({}), isNull);
    });
  });

  group('PolarRail.resolveRefundEvent', () {
    test('rebuilds identifiers from the resolved license-key id', () async {
      final mock = MockClient((req) async {
        expect(req.url.path, '/v1/orders/ord-42');
        return http.Response(
          jsonEncode({'id': 'ord-42', 'license_key_id': 'lk-resolved'}),
          200,
        );
      });
      final rail = _rail(mock);
      final preliminary = rail.extractRefundEvent({
        'type': 'refund.created',
        'data': {'order_id': 'ord-42', 'product_id': 'prod-x'},
      })!;

      final resolved = await rail.resolveRefundEvent('ord-42', preliminary);

      expect(resolved, isNotNull);
      expect(resolved!.paymentRef, 'lk-resolved');
      expect(resolved.receiptHash, CryptoUtils.sha256Hash('lk-resolved'));
      expect(resolved.productId, 'prod-x');
    });

    test('returns null when the order is not a license-key order', () async {
      final mock = MockClient(
        (req) async => http.Response(jsonEncode({'id': 'ord-99'}), 200),
      );
      final rail = _rail(mock);
      final preliminary = rail.extractRefundEvent({
        'type': 'refund.created',
        'data': {'order_id': 'ord-99'},
      })!;

      expect(await rail.resolveRefundEvent('ord-99', preliminary), isNull);
    });

    test('returns null when the order lookup fails', () async {
      final mock = MockClient((req) async => http.Response('not found', 404));
      final rail = _rail(mock);
      final preliminary = rail.extractRefundEvent({
        'type': 'refund.created',
        'data': {'order_id': 'ord-missing'},
      })!;

      expect(await rail.resolveRefundEvent('ord-missing', preliminary), isNull);
    });
  });

  withServerpod('PolarRail.processCallback', (sessionBuilder, endpoints) {
    setUp(RefundManager.resetHandler);
    tearDown(RefundManager.resetHandler);

    Map<String, String> validHeaders(String id, String timestamp, String body) {
      final key = base64.decode('dGVzdA==');
      final signature = base64.encode(
        Hmac(sha256, key).convert(utf8.encode('$id.$timestamp.$body')).bytes,
      );
      return {
        'webhook-id': id,
        'webhook-timestamp': timestamp,
        'webhook-signature': 'v1,$signature',
      };
    }

    PolarRail railWithSecret(
      Future<http.Response> Function(http.Request) handler,
    ) => PolarRail(
      client: PolarClient(
        organizationId: 'org',
        http: PolarHttpClient(
          baseUrl: 'https://api.polar.sh',
          bearerToken: 't',
          httpClient: MockClient(handler),
        ),
      ),
      signatureValidator: PolarSignatureValidator(secret: 'whsec_dGVzdA=='),
    );

    test('rejects an invalid signature before calling Polar', () async {
      var called = false;
      final rail = railWithSecret((req) async {
        called = true;
        return http.Response('{}', 200);
      });
      final session = sessionBuilder.build();
      final result = await rail.processCallback({
        'session': session,
        'request_body': '{"type":"refund.created"}',
        'headers': {
          'webhook-id': 'evt-1',
          'webhook-timestamp': (DateTime.now().millisecondsSinceEpoch ~/ 1000)
              .toString(),
          'webhook-signature': 'v1,bad',
        },
      });

      expect(result.success, isFalse);
      expect(called, isFalse);
    });

    test('forwards a resolved refund to RefundManager', () async {
      final rail = railWithSecret((req) async {
        return http.Response(
          jsonEncode({'id': 'ord-1', 'license_key_id': 'lk-1'}),
          200,
        );
      });
      String? paymentRef;
      RefundManager.onRefund((session, event, context) async {
        paymentRef = event.paymentRef;
        return RefundAction.ignore;
      });
      final session = sessionBuilder.build();
      final body = jsonEncode({
        'type': 'refund.created',
        'data': {'order_id': 'ord-1'},
      });
      final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
          .toString();

      final result = await rail.processCallback({
        'session': session,
        'request_body': body,
        'headers': validHeaders('evt-2', timestamp, body),
      });

      expect(result.success, isTrue);
      expect(paymentRef, 'lk-1');
    });
  });
}
