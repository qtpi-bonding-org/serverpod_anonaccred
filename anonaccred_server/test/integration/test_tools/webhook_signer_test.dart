import 'package:anonaccred_server/src/payments/google_pubsub_verifier.dart';
import 'package:anonaccred_server/src/payments/notification_signature_validator.dart';
import 'package:anonaccred_server/src/payments/polar_signature_validator.dart';
import 'package:test/test.dart';
import '../../test_helpers/apple_test_certificates.dart';
import '../../test_helpers/google_test_oidc.dart';
import 'webhook_signer.dart';

void main() {
  group('WebhookSigner', () {
    test('appleNotification produces a payload that verifies', () async {
      NotificationSignatureValidator.trustedRootDerOverride =
          AppleTestCertificates.rootDer;
      final body = WebhookSigner.appleNotification({'notificationType': 'REFUND'});
      final signedPayload = NotificationSignatureValidator.extractSignedPayload(body)!;

      expect(
        await NotificationSignatureValidator.validateSignature(signedPayload: signedPayload),
        isTrue,
      );
      NotificationSignatureValidator.trustedRootDerOverride = null;
    });

    test('polarWebhook produces headers that verify against the same secret', () {
      const secret = 'whsec_dGVzdC1zZWNyZXQ=';
      final signed = WebhookSigner.polarWebhook(secret: secret, payload: {'type': 'refund.created'});
      final validator = PolarSignatureValidator(secret: secret);

      final isValid = validator.verify(
        id: signed.headers['webhook-id']!,
        timestamp: signed.headers['webhook-timestamp']!,
        signatureHeader: signed.headers['webhook-signature']!,
        rawBody: signed.requestBody,
      );

      expect(isValid, isTrue);
    });

    test('googlePubSubPush produces a token that verifies', () async {
      GooglePubSubVerifier.certsUriOverride = await GoogleTestOidc.certsUri;
      final signed = WebhookSigner.googlePubSubPush(
        notification: {'packageName': 'com.example.app', 'eventTimeMillis': '1'},
        audience: 'https://example.com/hooks/google',
      );

      final decoded = await GooglePubSubVerifier.verifyAndDecode(
        authorizationHeader: signed.authorizationHeader,
        requestBody: signed.requestBody,
        expectedAudience: 'https://example.com/hooks/google',
      );

      expect(decoded.packageName, 'com.example.app');
      GooglePubSubVerifier.certsUriOverride = null;
    });
  });
}
