import 'dart:convert';

import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/polar_client.dart';
import 'package:anonaccred_server/src/payments/polar_http_client.dart';
import 'package:anonaccred_server/src/payments/rails/polar_rail.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

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
      final req = await _rail(mock).createPayment(
        amountUSD: 9.99,
        internalTransactionId: 'tx-1',
      );
      expect(req.paymentRef, 'tx-1');
      expect(req.amountUSD, 9.99);
      expect(req.internalTransactionId, 'tx-1');
      final railData = jsonDecode(req.railDataJson) as Map<String, dynamic>;
      expect(railData['payment_rail'], 'polar');
      expect(railData['flow'], 'license_key');
    });

    test('processCallback returns success acknowledgement (stub today)',
        () async {
      final mock = MockClient((req) async => http.Response('{}', 200));
      final result = await _rail(mock).processCallback({
        'session': null,
        'request_body': '{"type":"refund.created"}',
        'headers': <String, String>{},
      });
      expect(result.success, isTrue);
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
      expect(result.purchaseTimestamp,
          DateTime.parse('2026-01-01T00:00:00Z'));
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
}
