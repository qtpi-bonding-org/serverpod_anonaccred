import 'dart:convert';

import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/polar_client.dart';
import 'package:app_store_server_sdk/app_store_server_sdk.dart';
import 'package:googleapis/androidpublisher/v3.dart' show ProductPurchase;
import 'package:test/test.dart';

import 'test_tools/commerce_test_harness.dart';
import 'test_tools/serverpod_test_tools.dart';

/// Builds a fake Apple-signed transaction JWT. AppleIAPRail decodes
/// signedTransactions with its own local `DecodedTransaction.fromJWT`
/// (defined at the bottom of `apple_iap_rail.dart`, not the class of the
/// same name in `decoded_transaction.dart`) which does not verify the
/// signature and requires `inAppOwnershipType` rather than `bundleId` —
/// mirrors `_makeFakeSignedTransaction` in `commerce_test_harness_test.dart`.
String _makeFakeSignedTransaction({
  required String transactionId,
  required String productId,
}) {
  final header = base64Url.encode(
    utf8.encode(jsonEncode({'alg': 'ES256', 'typ': 'JWT'})),
  );
  final payload = base64Url.encode(
    utf8.encode(
      jsonEncode({
        'transactionId': transactionId,
        'originalTransactionId': 'orig_$transactionId',
        'productId': productId,
        'purchaseDate': DateTime.now().millisecondsSinceEpoch,
        'quantity': 1,
        'type': 'Consumable',
        'inAppOwnershipType': 'PURCHASED',
      }),
    ),
  );
  return '$header.$payload.fakesig';
}

void main() {
  withServerpod('Purchase-to-consume lifecycle', (sessionBuilder, endpoints) {
    test('Polar: redeem, query, consume, over-consume fails, replay is idempotent', () async {
      await seedRailProduct(
        sessionBuilder.build(),
        rail: PaymentRail.polar,
        storeProductId: 'benefit-license-1',
        tag: 'coins',
        quantity: 100,
      );
      final harness = await CommerceTestHarness.create(sessionBuilder, endpoints, label: 'polar1');
      harness.polarMock.addMockLicense(
        'LICENSE-1',
        PolarLicenseValidation(
          id: 'lk-license-1',
          key: 'LICENSE-1',
          status: 'granted',
          organizationId: 'mock-org',
          benefitId: 'benefit-license-1',
          customerId: 'cust-1',
          expiresAt: null,
          raw: const {},
        ),
      );

      final first = await harness.redeemPolar(licenseKey: 'LICENSE-1');
      expect(first.success, isTrue);

      final balanceAfterBuy = await harness.getBalance(first.tag!);
      expect(balanceAfterBuy, greaterThan(0));

      final consumeResult = await harness.consume(first.tag!, balanceAfterBuy);
      expect(consumeResult.success, isTrue);
      expect(consumeResult.availableBalance, 0);

      final overConsume = await harness.consume(first.tag!, 1);
      expect(overConsume.success, isFalse);

      final replay = await harness.redeemPolar(licenseKey: 'LICENSE-1');
      expect(replay.fromCache, isTrue);
      final balanceAfterReplay = await harness.getBalance(first.tag!);
      expect(balanceAfterReplay, 0, reason: 'replay must not double-credit');
    });

    test('Apple: buy, query, consume, over-consume fails, replay is idempotent', () async {
      await seedRailProduct(
        sessionBuilder.build(),
        rail: PaymentRail.apple_iap,
        storeProductId: 'coins_100',
        tag: 'coins',
        quantity: 100,
      );
      final harness = await CommerceTestHarness.create(sessionBuilder, endpoints, label: 'apple1');

      harness.appleMock.addMockTransaction(
        'txn-apple-1',
        HistoryResponse('sandbox', null, 'com.example.app', false, '', [
          _makeFakeSignedTransaction(
            transactionId: 'txn-apple-1',
            productId: 'coins_100',
          ),
        ]),
      );

      final first = await harness.buyApple(
        transactionId: 'txn-apple-1',
        productId: 'coins_100',
      );
      expect(first.success, isTrue);

      final balanceAfterBuy = await harness.getBalance(first.tag!);
      expect(balanceAfterBuy, greaterThan(0));

      final consumeResult = await harness.consume(first.tag!, balanceAfterBuy);
      expect(consumeResult.success, isTrue);
      expect(consumeResult.availableBalance, 0);

      final overConsume = await harness.consume(first.tag!, 1);
      expect(overConsume.success, isFalse);

      final replay = await harness.buyApple(
        transactionId: 'txn-apple-1',
        productId: 'coins_100',
      );
      expect(replay.fromCache, isTrue);
      final balanceAfterReplay = await harness.getBalance(first.tag!);
      expect(balanceAfterReplay, 0, reason: 'replay must not double-credit');
    });

    test('Google: buy, query, consume, over-consume fails, replay is idempotent', () async {
      await seedRailProduct(
        sessionBuilder.build(),
        rail: PaymentRail.google_iap,
        storeProductId: 'coins_100',
        tag: 'coins',
        quantity: 100,
      );
      final harness = await CommerceTestHarness.create(sessionBuilder, endpoints, label: 'google1');

      harness.googleMock.addMockPurchase(
        'token-google-1',
        ProductPurchase(purchaseState: 0, consumptionState: 0),
      );

      final first = await harness.buyGoogle(
        packageName: 'com.example.app',
        productId: 'coins_100',
        purchaseToken: 'token-google-1',
      );
      expect(first.success, isTrue);

      final balanceAfterBuy = await harness.getBalance(first.tag!);
      expect(balanceAfterBuy, greaterThan(0));

      final consumeResult = await harness.consume(first.tag!, balanceAfterBuy);
      expect(consumeResult.success, isTrue);
      expect(consumeResult.availableBalance, 0);

      final overConsume = await harness.consume(first.tag!, 1);
      expect(overConsume.success, isFalse);

      final replay = await harness.buyGoogle(
        packageName: 'com.example.app',
        productId: 'coins_100',
        purchaseToken: 'token-google-1',
      );
      expect(replay.fromCache, isTrue);
      final balanceAfterReplay = await harness.getBalance(first.tag!);
      expect(balanceAfterReplay, 0, reason: 'replay must not double-credit');
    });
  });
}
