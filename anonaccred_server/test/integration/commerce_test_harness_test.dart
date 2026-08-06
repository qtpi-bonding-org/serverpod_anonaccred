import 'dart:convert';

import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:app_store_server_sdk/app_store_server_sdk.dart';
import 'package:test/test.dart';

import 'test_tools/commerce_test_harness.dart';
import 'test_tools/serverpod_test_tools.dart';

/// Builds a fake Apple-signed transaction JWT. AppleIAPRail decodes
/// signedTransactions with its own local `DecodedTransaction.fromJWT`
/// (defined at the bottom of `apple_iap_rail.dart`, not the class of the
/// same name in `decoded_transaction.dart`) which does not verify the
/// signature and requires `inAppOwnershipType` rather than `bundleId` —
/// mirrors `_makeFakeSignedTransaction` in `apple_iap_rail_test.dart`.
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
  withServerpod('CommerceTestHarness', (sessionBuilder, endpoints) {
    test('buyApple fulfils via the mock and credits the account', () async {
      final harness = await CommerceTestHarness.create(
        sessionBuilder,
        endpoints,
        label: 'h1',
      );

      await seedRailProduct(
        sessionBuilder.build(),
        rail: PaymentRail.apple_iap,
        storeProductId: 'coins_100',
        tag: 'coins',
        quantity: 100,
      );

      harness.appleMock.addMockTransaction(
        'txn-1',
        HistoryResponse('sandbox', null, 'com.example.app', false, '', [
          _makeFakeSignedTransaction(
            transactionId: 'txn-1',
            productId: 'coins_100',
          ),
        ]),
      );

      final result = await harness.buyApple(
        transactionId: 'txn-1',
        productId: 'coins_100',
      );

      expect(result.success, isTrue);
      final entitlements = await harness.getEntitlements();
      expect(entitlements, isNotEmpty);
      expect(await harness.getBalance('coins'), equals(100));
    });
  });
}
