import 'dart:math';

import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

/// See `entitlement_manager_grant_lock_test.dart` for why this test disables
/// `withServerpod`'s default transaction-per-test rollback.
///
/// Unlike the grant-lock tests, `fulfillTransactionPayment` opens its own
/// internal transaction rather than accepting one from the caller, so there
/// is no seam to hold one transaction open with a `Completer` while the
/// second starts — the two calls below race by genuine `Future.wait`
/// concurrency instead. Since rollback is disabled, every row this test
/// inserts is deleted in `tearDown`.
void main() {
  withServerpod(
    'CommerceManager.fulfillTransactionPayment locking',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      late UuidValue accountUuid;
      late int entitlementId;
      late int railProductId;
      const tag = 'fulfillment_lock_test';
      const internalTxId = 'fulfillment_lock_tx';

      tearDown(() async {
        final session = sessionBuilder.build();
        await TransactionPayment.db.deleteWhere(
          session,
          where: (t) => t.internalTransactionId.equals(internalTxId),
        );
        await EphemeralAccreditation.db.deleteWhere(
          session,
          where: (t) => t.accountUuid.equals(accountUuid),
        );
        await AccountEntitlement.db.deleteWhere(
          session,
          where: (t) => t.accountUuid.equals(accountUuid),
        );
        await RailProductGrant.db.deleteWhere(
          session,
          where: (t) => t.railProductId.equals(railProductId),
        );
        await RailProduct.db.deleteWhere(
          session,
          where: (t) => t.id.equals(railProductId),
        );
        await AnonAccount.db.deleteWhere(
          session,
          where: (t) => t.id.equals(accountUuid),
        );
        await Entitlement.db.deleteWhere(
          session,
          where: (t) => t.id.equals(entitlementId),
        );
      });

      test(
        'two concurrent fulfillment calls for the same transaction only '
        'grant once, not twice',
        () async {
          final session = sessionBuilder.build();
          final account = await AnonAccount.db.insertRow(
            session,
            AnonAccount(
              id: UuidValue.fromString(const Uuid().v4()),
              ultimateSigningPublicKeyHex: _randomHex(),
              encryptedDataKey: 'data',
              ultimateEncryptionPublicKeyHex: _randomHex(),
            ),
          );
          accountUuid = account.id!;
          final entitlement = await Entitlement.db.insertRow(
            session,
            Entitlement(
              tag: tag,
              name: tag,
              type: EntitlementType.consumable,
              serverValidated: true,
            ),
          );
          entitlementId = entitlement.id!;
          final railProduct = await RailProduct.db.insertRow(
            session,
            RailProduct(
              rail: PaymentRail.monero,
              storeProductId: 'fulfillment_lock_sku',
              isActive: true,
            ),
          );
          railProductId = railProduct.id!;
          await RailProductGrant.db.insertRow(
            session,
            RailProductGrant(
              railProductId: railProductId,
              entitlementId: entitlementId,
              quantity: 10.0,
            ),
          );
          final timestamp = DateTime.now();
          await EphemeralAccreditation.db.insertRow(
            session,
            EphemeralAccreditation(
              accountUuid: accountUuid,
              transactionTimestamp: timestamp,
            ),
          );
          await TransactionPayment.db.insertRow(
            session,
            TransactionPayment(
              railProductId: railProductId,
              internalTransactionId: internalTxId,
              priceCurrency: Currency.USD,
              price: 1.0,
              paymentRail: PaymentRail.monero,
              paymentCurrency: Currency.XMR,
              paymentAmount: 1.0,
              transactionTimestamp: timestamp,
              status: OrderStatus.pending,
            ),
          );

          await Future.wait([
            CommerceManager.fulfillTransactionPayment(
              session,
              internalTransactionId: internalTxId,
            ),
            CommerceManager.fulfillTransactionPayment(
              session,
              internalTransactionId: internalTxId,
            ),
          ]);

          final balance = await EntitlementManager.getEntitlementBalance(
            session,
            accountUuid: accountUuid,
            tag: tag,
          );
          expect(
            balance,
            10.0,
            reason:
                'only one call should grant — without the FOR UPDATE lock, '
                'both concurrent calls can read status=pending before '
                'either commits, so both grant (balance would be 20.0)',
          );
        },
      );
    },
  );
}

String _randomHex() {
  final random = Random();
  final buffer = StringBuffer();
  for (var i = 0; i < 128; i++) {
    buffer.write(random.nextInt(16).toRadixString(16));
  }
  return buffer.toString();
}
