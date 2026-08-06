import 'dart:convert';

import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:anonaccred_server/src/payments/google_pubsub_verifier.dart';
import 'package:test/test.dart';

import '../test_helpers/google_test_oidc.dart';

void main() {
  group('GooglePubSubVerifier', () {
    setUp(() async {
      GooglePubSubVerifier.certsUriOverride = await GoogleTestOidc.certsUri;
    });

    tearDown(() {
      GooglePubSubVerifier.certsUriOverride = null;
    });

    test('decodes a valid Pub/Sub push envelope with a valid OIDC token',
        () async {
      final notification = {
        'version': '1.0',
        'packageName': 'com.example.app',
        'eventTimeMillis': '1700000000000',
        'oneTimeProductNotification': {
          'version': '1.0',
          'notificationType': 1,
          'purchaseToken': 'tok-1',
          'sku': 'sku-1',
        },
      };
      final data = base64.encode(utf8.encode(jsonEncode(notification)));
      final requestBody = jsonEncode({
        'message': {'data': data, 'messageId': 'm-1'},
        'subscription': 'projects/p/subscriptions/s',
      });
      final token = GoogleTestOidc.signToken(
        audience: 'https://example.com/hooks/google',
      );

      final decoded = await GooglePubSubVerifier.verifyAndDecode(
        authorizationHeader: 'Bearer $token',
        requestBody: requestBody,
        expectedAudience: 'https://example.com/hooks/google',
      );

      expect(decoded.packageName, 'com.example.app');
      expect(decoded.eventTimeMillis, '1700000000000');
      expect(decoded.oneTimeProductNotification?['purchaseToken'], 'tok-1');
      expect(decoded.subscriptionNotification, isNull);
      expect(decoded.voidedPurchaseNotification, isNull);
    });

    test('rejects a token with the wrong audience', () async {
      final requestBody = jsonEncode({
        'message': {
          'data': base64.encode(
            utf8.encode('{"packageName":"x","eventTimeMillis":"1"}'),
          ),
        },
      });
      final token = GoogleTestOidc.signToken(
        audience: 'https://wrong.example.com/hooks/google',
      );

      await expectLater(
        GooglePubSubVerifier.verifyAndDecode(
          authorizationHeader: 'Bearer $token',
          requestBody: requestBody,
          expectedAudience: 'https://example.com/hooks/google',
        ),
        throwsA(isA<AnonAccountException>()),
      );
    });

    test('rejects a token signed by a key not present in the JWKS', () async {
      // A syntactically valid RS256 JWT whose signature does not verify
      // against any key the loopback JWKS server publishes — proves
      // verifyAndDecode checks the signature bytes, not just claim shape.
      final header = base64Url
          .encode(utf8.encode(jsonEncode({
            'alg': 'RS256',
            'typ': 'JWT',
            'kid': 'test-key-1',
          })))
          .replaceAll('=', '');
      final payload = base64Url
          .encode(utf8.encode(jsonEncode({
            'iss': 'https://accounts.google.com',
            'aud': 'https://example.com/hooks/google',
          })))
          .replaceAll('=', '');
      final forgedSignature =
          base64Url.encode(List<int>.filled(256, 7)).replaceAll('=', '');
      final forgedToken = '$header.$payload.$forgedSignature';

      final requestBody = jsonEncode({
        'message': {
          'data': base64.encode(
            utf8.encode('{"packageName":"x","eventTimeMillis":"1"}'),
          ),
        },
      });

      await expectLater(
        GooglePubSubVerifier.verifyAndDecode(
          authorizationHeader: 'Bearer $forgedToken',
          requestBody: requestBody,
          expectedAudience: 'https://example.com/hooks/google',
        ),
        throwsA(isA<AnonAccountException>()),
      );
    });

    test('rejects a request with no Authorization header', () async {
      final token = GoogleTestOidc.signToken(
        audience: 'https://example.com/hooks/google',
      );
      await expectLater(
        GooglePubSubVerifier.verifyAndDecode(
          authorizationHeader: token, // missing the "Bearer " prefix
          requestBody: jsonEncode({
            'message': {'data': base64.encode(utf8.encode('{}'))},
          }),
          expectedAudience: 'https://example.com/hooks/google',
        ),
        throwsA(isA<AnonAccountException>()),
      );
    });
  });
}
