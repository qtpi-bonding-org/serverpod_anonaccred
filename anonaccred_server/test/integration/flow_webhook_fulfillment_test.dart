import 'package:anonaccred_server/src/payments/google_pubsub_verifier.dart';
import 'package:anonaccred_server/src/payments/notification_signature_validator.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:anonaccred_server/src/payments/polar_signature_validator.dart';
import 'package:anonaccred_server/src/payments/rails/google_iap_rail.dart';
import 'package:anonaccred_server/src/payments/rails/polar_rail.dart';
import 'package:anonaccred_server/src/webhooks/apple_webhook_route.dart';
import 'package:anonaccred_server/src/webhooks/google_webhook_route.dart';
import 'package:anonaccred_server/src/webhooks/polar_webhook_route.dart';
import 'package:relic_core/relic_core.dart' show Response;
import 'package:test/test.dart';

import '../test_helpers/apple_test_certificates.dart';
import '../test_helpers/google_test_oidc.dart';
import 'test_tools/commerce_test_harness.dart';
import 'test_tools/fake_webhook_request.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/webhook_signer.dart';

void main() {
  withServerpod('Webhook-driven fulfillment', (sessionBuilder, endpoints) {
    test('Polar: a validly signed webhook is accepted; a bad signature is rejected', () async {
      final harness = await CommerceTestHarness.create(sessionBuilder, endpoints, label: 'wh-polar');
      const secret = 'whsec_dGVzdC1zZWNyZXQ=';
      PaymentManager.registerRail(
        PolarRail(client: harness.polarMock, signatureValidator: PolarSignatureValidator(secret: secret)),
      );

      final good = WebhookSigner.polarWebhook(
        secret: secret,
        payload: {'type': 'order.created', 'data': {'order_id': 'order-1'}},
      );
      final goodResponse = await PolarWebhookRoute().handleCall(
        sessionBuilder.build(),
        FakeWebhookRequest.build(body: good.requestBody, headers: good.headers),
      ) as Response;
      expect(goodResponse.statusCode, 200);

      final tampered = WebhookSigner.polarWebhook(secret: 'whsec_d3Jvbmc=', payload: {'type': 'order.created'});
      final badResponse = await PolarWebhookRoute().handleCall(
        sessionBuilder.build(),
        FakeWebhookRequest.build(body: tampered.requestBody, headers: tampered.headers),
      ) as Response;
      expect(badResponse.statusCode, 401);
    });

    test('Apple: a validly signed notification is accepted; an untrusted chain is rejected', () async {
      await CommerceTestHarness.create(sessionBuilder, endpoints, label: 'wh-apple');
      NotificationSignatureValidator.trustedRootDerOverride = AppleTestCertificates.rootDer;
      addTearDown(() => NotificationSignatureValidator.trustedRootDerOverride = null);

      final good = WebhookSigner.appleNotification({
        'notificationType': 'TEST',
        'data': <String, dynamic>{},
      });
      final goodResponse = await AppleWebhookRoute().handleCall(
        sessionBuilder.build(),
        FakeWebhookRequest.build(body: good, headers: const {}),
      ) as Response;
      expect(goodResponse.statusCode, 200);

      // Untrusted chain: no root override in effect, so the leaf/intermediate
      // pair signs correctly but doesn't chain to anything the validator trusts.
      NotificationSignatureValidator.trustedRootDerOverride = null;
      final untrusted = WebhookSigner.appleNotification({
        'notificationType': 'TEST',
        'data': <String, dynamic>{},
      });
      final badResponse = await AppleWebhookRoute().handleCall(
        sessionBuilder.build(),
        FakeWebhookRequest.build(body: untrusted, headers: const {}),
      ) as Response;
      expect(badResponse.statusCode, 401);
    });

    test('Google: a validly signed push notification is accepted; a wrong audience is rejected', () async {
      await CommerceTestHarness.create(sessionBuilder, endpoints, label: 'wh-google');
      GooglePubSubVerifier.certsUriOverride = await GoogleTestOidc.certsUri;
      addTearDown(() => GooglePubSubVerifier.certsUriOverride = null);

      // GoogleWebhookRoute builds `expected_audience` from
      // GoogleIAPRail.expectedPushAudience (an env var, unset in test runs,
      // so it's the empty string) — sign against that same value to match.
      final audience = GoogleIAPRail.expectedPushAudience;
      final good = WebhookSigner.googlePubSubPush(
        notification: {
          'packageName': 'com.example.app',
          'eventTimeMillis': '1700000000000',
          'oneTimeProductNotification': {'notificationType': 1, 'purchaseToken': 'tok-1'},
        },
        audience: audience,
      );
      final goodResponse = await GoogleWebhookRoute().handleCall(
        sessionBuilder.build(),
        FakeWebhookRequest.build(
          body: good.requestBody,
          headers: {'authorization': good.authorizationHeader},
        ),
      ) as Response;
      expect(goodResponse.statusCode, 200);

      final wrongAudience = WebhookSigner.googlePubSubPush(
        notification: {
          'packageName': 'com.example.app',
          'eventTimeMillis': '1700000000000',
          'oneTimeProductNotification': {'notificationType': 1, 'purchaseToken': 'tok-2'},
        },
        audience: '$audience-wrong',
      );
      final badResponse = await GoogleWebhookRoute().handleCall(
        sessionBuilder.build(),
        FakeWebhookRequest.build(
          body: wrongAudience.requestBody,
          headers: {'authorization': wrongAudience.authorizationHeader},
        ),
      ) as Response;
      expect(badResponse.statusCode, 401);
    });
  });
}
