import 'package:anonaccount_server/src/crypto_utils.dart';
import 'package:anonaccred_server/src/entitlement_manager.dart';
import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/refund_event.dart';
import 'package:anonaccred_server/src/refund_manager.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

/// Helper: seed the full bridge chain (ReceiptHash, TransactionPayment,
/// EphemeralAccreditation, Entitlement, RailProduct, RailProductGrant,
/// AccountEntitlement) and return a RefundEvent.
Future<_SeedResult> _seedBridgeChain(
  Session session, {
  required String paymentRef,
  required String storeProductId,
  DateTime? timestamp,
  double grantQuantity = 100.0,
  String entitlementTag = 'coins',
}) async {
  final ts = timestamp ?? DateTime.now();
  final receiptHash = CryptoUtils.sha256Hash(paymentRef);

  // 1. AnonAccount (must exist before FK references)
  final account = await AnonAccount.db.insertRow(
    session,
    AnonAccount(
      id: UuidValue.fromString(const Uuid().v4()),
      ultimateSigningPublicKeyHex: 'test_key_$paymentRef',
      encryptedDataKey: 'test_data',
      ultimateEncryptionPublicKeyHex: 'test_pubkey_$paymentRef',
    ),
  );
  final accountUuid = account.id!;

  // 2. ReceiptHash
  await ReceiptHash.db.insertRow(
    session,
    ReceiptHash(hash: receiptHash, paymentRail: PaymentRail.apple_iap),
  );

  // 3. Entitlement
  final entitlement = await Entitlement.db.insertRow(
    session,
    Entitlement(
      tag: entitlementTag,
      name: entitlementTag,
      type: EntitlementType.consumable,
      serverValidated: true,
    ),
  );

  // 4. RailProduct
  final railProduct = await RailProduct.db.insertRow(
    session,
    RailProduct(
      rail: PaymentRail.apple_iap,
      storeProductId: storeProductId,
      isActive: true,
    ),
  );

  // 5. RailProductGrant
  await RailProductGrant.db.insertRow(
    session,
    RailProductGrant(
      railProductId: railProduct.id!,
      entitlementId: entitlement.id!,
      quantity: grantQuantity,
    ),
  );

  // 6. TransactionPayment
  await TransactionPayment.db.insertRow(
    session,
    TransactionPayment(
      railProductId: railProduct.id!,
      internalTransactionId: 'itx_$paymentRef',
      priceCurrency: Currency.USD,
      price: 9.99,
      paymentRail: PaymentRail.apple_iap,
      paymentCurrency: Currency.USD,
      paymentAmount: 9.99,
      paymentRef: paymentRef,
      transactionTimestamp: ts,
      status: OrderStatus.paid,
    ),
  );

  // 7. EphemeralAccreditation (bridge)
  await EphemeralAccreditation.db.insertRow(
    session,
    EphemeralAccreditation(accountUuid: accountUuid, transactionTimestamp: ts),
  );

  // 8. AccountEntitlement (grant the entitlement)
  await AccountEntitlement.db.insertRow(
    session,
    AccountEntitlement(
      accountUuid: accountUuid,
      entitlementId: entitlement.id!,
      balance: grantQuantity,
    ),
  );

  final event = RefundEvent(
    rail: PaymentRail.apple_iap,
    receiptHash: receiptHash,
    paymentRef: paymentRef,
  );

  return _SeedResult(
    event: event,
    entitlementId: entitlement.id!,
    accountUuid: accountUuid,
  );
}

class _SeedResult {
  _SeedResult({
    required this.event,
    required this.entitlementId,
    required this.accountUuid,
  });
  final RefundEvent event;
  final int entitlementId;
  final UuidValue accountUuid;
}

void main() {
  withServerpod('RefundManager', (sessionBuilder, endpoints) {
    tearDown(() {
      RefundManager.resetHandler();
    });

    // -----------------------------------------------------------------------
    // Default behavior (no hook): revoke + mark refunded
    // -----------------------------------------------------------------------
    group('default behavior (no hook)', () {
      test('revokes entitlements and marks status=refunded', () async {
        final session = sessionBuilder.build();
        final seed = await _seedBridgeChain(
          session,
          paymentRef: 'txn_default_revoke',
          storeProductId: 'com.test.coins',
        );

        await RefundManager.processRefund(session, seed.event);

        // Verify entitlement balance is 0
        final balance = await EntitlementManager.getEntitlementBalance(
          session,
          accountUuid: seed.accountUuid,
          tag: 'coins',
        );
        expect(balance, equals(0.0));

        // Verify ConsumptionLog entry exists with REFUND reason
        final logs = await ConsumptionLog.db.find(
          session,
          where: (t) => t.accountUuid.equals(seed.accountUuid),
        );
        expect(logs, isNotEmpty);
        expect(logs.first.reason, startsWith('REFUND:'));

        // Verify TransactionPayment status is refunded
        final payment = await TransactionPayment.db.findFirstRow(
          session,
          where: (t) => t.paymentRef.equals('txn_default_revoke'),
        );
        expect(payment!.status, equals(OrderStatus.refunded));
      });
    });

    // -----------------------------------------------------------------------
    // Expired bridge: no EphemeralAccreditation
    // -----------------------------------------------------------------------
    group('expired bridge', () {
      test('marks refunded but does not touch entitlements', () async {
        final session = sessionBuilder.build();
        final ts = DateTime.now();
        const paymentRef = 'txn_expired_bridge';
        final receiptHash = CryptoUtils.sha256Hash(paymentRef);

        // Seed ReceiptHash + TransactionPayment but NO EphemeralAccreditation
        await ReceiptHash.db.insertRow(
          session,
          ReceiptHash(hash: receiptHash, paymentRail: PaymentRail.apple_iap),
        );

        final railProduct = await RailProduct.db.insertRow(
          session,
          RailProduct(
            rail: PaymentRail.apple_iap,
            storeProductId: 'com.test.expired',
            isActive: true,
          ),
        );

        await TransactionPayment.db.insertRow(
          session,
          TransactionPayment(
            railProductId: railProduct.id!,
            internalTransactionId: 'itx_$paymentRef',
            priceCurrency: Currency.USD,
            price: 9.99,
            paymentRail: PaymentRail.apple_iap,
            paymentCurrency: Currency.USD,
            paymentAmount: 9.99,
            paymentRef: paymentRef,
            transactionTimestamp: ts,
            status: OrderStatus.paid,
          ),
        );

        final event = RefundEvent(
          rail: PaymentRail.apple_iap,
          receiptHash: receiptHash,
          paymentRef: paymentRef,
        );

        await RefundManager.processRefund(session, event);

        // TransactionPayment should be marked refunded
        final payment = await TransactionPayment.db.findFirstRow(
          session,
          where: (t) => t.paymentRef.equals(paymentRef),
        );
        expect(payment!.status, equals(OrderStatus.refunded));
      });
    });

    // -----------------------------------------------------------------------
    // Idempotency: processing same refund twice
    // -----------------------------------------------------------------------
    group('idempotency', () {
      test('second call is a no-op when status already refunded', () async {
        final session = sessionBuilder.build();
        final seed = await _seedBridgeChain(
          session,
          paymentRef: 'txn_idempotent',
          storeProductId: 'com.test.idempotent',
        );

        await RefundManager.processRefund(session, seed.event);
        // Process again
        await RefundManager.processRefund(session, seed.event);

        // Should still have 0 balance (not -100)
        final balance = await EntitlementManager.getEntitlementBalance(
          session,
          accountUuid: seed.accountUuid,
          tag: 'coins',
        );
        expect(balance, equals(0.0));

        // Only one ConsumptionLog entry
        final logs = await ConsumptionLog.db.find(
          session,
          where: (t) =>
              t.accountUuid.equals(seed.accountUuid) &
              t.reason.like('REFUND:%'),
        );
        expect(logs, hasLength(1));
      });
    });

    group('idempotency claim', () {
      test('processing the same event twice only revokes once', () async {
        final session = sessionBuilder.build();
        final seed = await _seedBridgeChain(
          session,
          paymentRef: 'claim_test_1',
          storeProductId: 'sku_claim_1',
          grantQuantity: 50.0,
        );

        await RefundManager.processRefund(session, seed.event);
        await RefundManager.processRefund(session, seed.event);

        final balance = await AccountEntitlement.db.findFirstRow(
          session,
          where: (t) =>
              t.accountUuid.equals(seed.accountUuid) &
              t.entitlementId.equals(seed.entitlementId),
        );
        expect(balance?.balance, 0.0);
      });

      test('the developer hook only runs once for a duplicate event', () async {
        final session = sessionBuilder.build();
        final seed = await _seedBridgeChain(
          session,
          paymentRef: 'claim_test_2',
          storeProductId: 'sku_claim_2',
        );

        var hookCallCount = 0;
        RefundManager.onRefund((s, event, context) async {
          hookCallCount++;
          return RefundAction.ignore;
        });

        await RefundManager.processRefund(session, seed.event);
        await RefundManager.processRefund(session, seed.event);

        expect(hookCallCount, 1);
      });

      test(
        'concurrent processRefund calls for the same event only revoke once',
        () async {
          final session = sessionBuilder.build();
          final seed = await _seedBridgeChain(
            session,
            paymentRef: 'claim_test_3',
            storeProductId: 'sku_claim_3',
            grantQuantity: 50.0,
          );

          var hookCallCount = 0;
          RefundManager.onRefund((s, event, context) async {
            hookCallCount++;
            return RefundAction.ignore;
          });

          await Future.wait([
            RefundManager.processRefund(session, seed.event),
            RefundManager.processRefund(session, seed.event),
          ]);

          expect(hookCallCount, 1);
        },
      );

      test(
        'a genuinely new event is not blocked by an unrelated claim',
        () async {
          final session = sessionBuilder.build();
          final seedA = await _seedBridgeChain(
            session,
            paymentRef: 'claim_test_unrelated_a',
            storeProductId: 'sku_claim_unrelated_a',
            entitlementTag: 'coins_claim_unrelated_a',
          );
          final seedB = await _seedBridgeChain(
            session,
            paymentRef: 'claim_test_unrelated_b',
            storeProductId: 'sku_claim_unrelated_b',
            entitlementTag: 'coins_claim_unrelated_b',
          );

          var hookCallCount = 0;
          RefundManager.onRefund((s, event, context) async {
            hookCallCount++;
            return RefundAction.ignore;
          });

          await RefundManager.processRefund(session, seedA.event);
          await RefundManager.processRefund(session, seedB.event);

          expect(hookCallCount, 2);
        },
      );
    });

    group('payment resolution', () {
      test('uses the event rail when payment refs overlap across rails', () async {
        final session = sessionBuilder.build();
        const paymentRef = 'shared_cross_rail_ref';

        final unrelatedRailProduct = await RailProduct.db.insertRow(
          session,
          RailProduct(
            rail: PaymentRail.polar,
            storeProductId: 'sku_cross_rail_polar',
            isActive: true,
          ),
        );
        await TransactionPayment.db.insertRow(
          session,
          TransactionPayment(
            railProductId: unrelatedRailProduct.id!,
            internalTransactionId: 'itx_cross_rail_polar',
            priceCurrency: Currency.USD,
            price: 9.99,
            paymentRail: PaymentRail.polar,
            paymentCurrency: Currency.USD,
            paymentAmount: 9.99,
            paymentRef: paymentRef,
            transactionTimestamp: DateTime.now().subtract(
              const Duration(seconds: 1),
            ),
            status: OrderStatus.paid,
          ),
        );

        final seed = await _seedBridgeChain(
          session,
          paymentRef: paymentRef,
          storeProductId: 'sku_cross_rail_apple',
        );

        PaymentRail? resolvedRail;
        RefundManager.onRefund((s, event, context) async {
          resolvedRail = context.payment?.paymentRail;
          return RefundAction.ignore;
        });

        await RefundManager.processRefund(session, seed.event);

        expect(resolvedRail, PaymentRail.apple_iap);
      });
    });

    // -----------------------------------------------------------------------
    // Unknown hash: graceful return
    // -----------------------------------------------------------------------
    group('unknown hash', () {
      test('returns gracefully without crashing', () async {
        final session = sessionBuilder.build();
        final event = RefundEvent(
          rail: PaymentRail.apple_iap,
          receiptHash: 'nonexistent_hash_abc123',
          paymentRef: 'nonexistent_txn',
        );

        // Should not throw
        await expectLater(
          RefundManager.processRefund(session, event),
          completes,
        );
      });
    });

    // -----------------------------------------------------------------------
    // Custom hook: revokeAll
    // -----------------------------------------------------------------------
    group('custom hook returning revokeAll', () {
      test('revokes all entitlements like default', () async {
        final session = sessionBuilder.build();
        RefundManager.onRefund((session, event, context) async {
          return RefundAction.revokeAll;
        });

        final seed = await _seedBridgeChain(
          session,
          paymentRef: 'txn_hook_revokeAll',
          storeProductId: 'com.test.hookRevoke',
        );

        await RefundManager.processRefund(session, seed.event);

        final balance = await EntitlementManager.getEntitlementBalance(
          session,
          accountUuid: seed.accountUuid,
          tag: 'coins',
        );
        expect(balance, equals(0.0));

        final payment = await TransactionPayment.db.findFirstRow(
          session,
          where: (t) => t.paymentRef.equals('txn_hook_revokeAll'),
        );
        expect(payment!.status, equals(OrderStatus.refunded));
      });
    });

    // -----------------------------------------------------------------------
    // Custom hook: handled
    // -----------------------------------------------------------------------
    group('custom hook returning handled', () {
      test('does not auto-revoke entitlements, but marks refunded', () async {
        final session = sessionBuilder.build();
        RefundManager.onRefund((session, event, context) async {
          return RefundAction.handled;
        });

        final seed = await _seedBridgeChain(
          session,
          paymentRef: 'txn_hook_handled',
          storeProductId: 'com.test.hookHandled',
        );

        await RefundManager.processRefund(session, seed.event);

        // Entitlement balance should be UNCHANGED (100)
        final balance = await EntitlementManager.getEntitlementBalance(
          session,
          accountUuid: seed.accountUuid,
          tag: 'coins',
        );
        expect(balance, equals(100.0));

        // But payment is marked refunded
        final payment = await TransactionPayment.db.findFirstRow(
          session,
          where: (t) => t.paymentRef.equals('txn_hook_handled'),
        );
        expect(payment!.status, equals(OrderStatus.refunded));
      });
    });

    // -----------------------------------------------------------------------
    // Custom hook: ignore
    // -----------------------------------------------------------------------
    group('custom hook returning ignore', () {
      test('nothing changes at all', () async {
        final session = sessionBuilder.build();
        RefundManager.onRefund((session, event, context) async {
          return RefundAction.ignore;
        });

        final seed = await _seedBridgeChain(
          session,
          paymentRef: 'txn_hook_ignore',
          storeProductId: 'com.test.hookIgnore',
        );

        await RefundManager.processRefund(session, seed.event);

        // Entitlement balance unchanged
        final balance = await EntitlementManager.getEntitlementBalance(
          session,
          accountUuid: seed.accountUuid,
          tag: 'coins',
        );
        expect(balance, equals(100.0));

        // Payment status unchanged (still paid)
        final payment = await TransactionPayment.db.findFirstRow(
          session,
          where: (t) => t.paymentRef.equals('txn_hook_ignore'),
        );
        expect(payment!.status, equals(OrderStatus.paid));
      });
    });

    // -----------------------------------------------------------------------
    // revokeEntitlement clamping: balance never goes negative
    // -----------------------------------------------------------------------
    group('revokeEntitlement clamping', () {
      test('grant 100, consume 80, revoke 100 → balance=0 (not -80)', () async {
        final session = sessionBuilder.build();
        final seed = await _seedBridgeChain(
          session,
          paymentRef: 'txn_clamp',
          storeProductId: 'com.test.clamp',
          grantQuantity: 100.0,
        );

        // Consume 80
        await EntitlementManager.consumeEntitlement(
          session,
          accountUuid: seed.accountUuid,
          tag: 'coins',
          amount: 80.0,
          reason: 'usage',
        );

        // Now revoke the full 100 (only 20 remains)
        await EntitlementManager.revokeEntitlement(
          session,
          accountUuid: seed.accountUuid,
          entitlementId: seed.entitlementId,
          quantity: 100.0,
          reason: 'REFUND:test',
        );

        final balance = await EntitlementManager.getEntitlementBalance(
          session,
          accountUuid: seed.accountUuid,
          tag: 'coins',
        );
        expect(balance, equals(0.0));
      });
    });
  });
}
