import 'package:anonaccred_server/src/payments/mock_polar_client.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:anonaccred_server/src/payments/polar_signature_validator.dart';
import 'package:anonaccred_server/src/payments/rails/polar_rail.dart';
import 'package:anonaccred_server/src/webhooks/polar_webhook_route.dart';
import 'package:relic_core/relic_core.dart' show Response;
import 'package:test/test.dart';

import 'test_tools/fake_webhook_request.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/webhook_signer.dart';

void main() {
  withServerpod('PolarWebhookRoute smoke test', (sessionBuilder, endpoints) {
    test('handleCall accepts a validly signed refund payload', () async {
      const secret = 'whsec_dGVzdC1zZWNyZXQ=';
      PaymentManager.clearRails();
      PaymentManager.registerRail(
        PolarRail(client: MockPolarClient(), signatureValidator: PolarSignatureValidator(secret: secret)),
      );

      final signed = WebhookSigner.polarWebhook(
        secret: secret,
        payload: {
          'type': 'refund.created',
          'data': {'order_id': 'order-does-not-exist'},
        },
      );
      final request = FakeWebhookRequest.build(body: signed.requestBody, headers: signed.headers);
      final session = sessionBuilder.build();

      final response = await PolarWebhookRoute().handleCall(session, request) as Response;

      expect(response.statusCode, 200);
      await session.close();
      PaymentManager.clearRails();
    });

    test('handleCall rejects a bad signature', () async {
      PaymentManager.clearRails();
      PaymentManager.registerRail(
        PolarRail(client: MockPolarClient(), signatureValidator: PolarSignatureValidator(secret: 'whsec_dGVzdA==')),
      );

      final request = FakeWebhookRequest.build(
        body: '{"type":"refund.created"}',
        headers: {'webhook-id': 'x', 'webhook-timestamp': '1700000000', 'webhook-signature': 'v1,bad'},
      );
      final session = sessionBuilder.build();

      final response = await PolarWebhookRoute().handleCall(session, request) as Response;

      expect(response.statusCode, 401);
      await session.close();
      PaymentManager.clearRails();
    });
  });
}
