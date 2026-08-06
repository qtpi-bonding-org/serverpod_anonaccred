import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/polar_client.dart';
import 'package:anonaccred_server/src/refund_manager.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:anonaccred_server/src/payments/polar_signature_validator.dart';
import 'package:anonaccred_server/src/payments/rails/polar_rail.dart';
import 'package:anonaccred_server/src/webhooks/polar_webhook_route.dart';
import 'package:relic_core/relic_core.dart' show Response;
import 'package:test/test.dart';
import 'test_tools/commerce_test_harness.dart';
import 'test_tools/fake_webhook_request.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/webhook_signer.dart';

void main() {
  withServerpod('Refund lifecycle', (sessionBuilder, endpoints) {
    tearDown(RefundManager.resetHandler);

    test('a refund webhook revokes the entitlement, and a duplicate delivery is a no-op', () async {
      await seedRailProduct(
        sessionBuilder.build(),
        rail: PaymentRail.polar,
        storeProductId: 'benefit-refund-license-1',
        tag: 'coins',
        quantity: 100,
      );
      final harness = await CommerceTestHarness.create(sessionBuilder, endpoints, label: 'refund1');
      const licenseKeyId = 'lk-refund-license-1';
      harness.polarMock.addMockLicense(
        'REFUND-LICENSE-1',
        PolarLicenseValidation(
          id: licenseKeyId,
          key: 'REFUND-LICENSE-1',
          status: 'granted',
          organizationId: 'mock-org',
          benefitId: 'benefit-refund-license-1',
          customerId: 'cust-refund',
          expiresAt: null,
          raw: const {},
        ),
      );
      final purchase = await harness.redeemPolar(licenseKey: 'REFUND-LICENSE-1');
      final balanceAfterBuy = await harness.getBalance(purchase.tag!);
      expect(balanceAfterBuy, greaterThan(0));

      harness.polarMock.addMockOrder('order-refund-1', {
        'id': 'order-refund-1',
        'license_key_id': licenseKeyId,
      });

      const secret = 'whsec_dGVzdC1zZWNyZXQ=';
      PaymentManager.registerRail(
        PolarRail(client: harness.polarMock, signatureValidator: PolarSignatureValidator(secret: secret)),
      );

      final refundSigned = WebhookSigner.polarWebhook(
        secret: secret,
        payload: {
          'type': 'refund.created',
          'data': {'order_id': 'order-refund-1', 'created_at': DateTime.now().toIso8601String()},
        },
      );

      final response1 = await PolarWebhookRoute().handleCall(
        sessionBuilder.build(),
        FakeWebhookRequest.build(body: refundSigned.requestBody, headers: refundSigned.headers),
      ) as Response;
      expect(response1.statusCode, 200);

      final balanceAfterRefund = await harness.getBalance(purchase.tag!);
      expect(balanceAfterRefund, 0);

      // Duplicate delivery — RefundClaim's unique index makes this a no-op
      // (RefundManager.processRefund, refund_manager.dart:84-97).
      final response2 = await PolarWebhookRoute().handleCall(
        sessionBuilder.build(),
        FakeWebhookRequest.build(body: refundSigned.requestBody, headers: refundSigned.headers),
      ) as Response;
      expect(response2.statusCode, 200);

      final balanceAfterDuplicate = await harness.getBalance(purchase.tag!);
      expect(balanceAfterDuplicate, 0, reason: 'duplicate refund must not double-process');
    });
  });
}
