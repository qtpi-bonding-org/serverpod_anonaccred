import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:anonaccred_server/src/commerce_manager.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/group_entitlement_manager.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('CommerceManager group fulfillment', (
    sessionBuilder,
    endpoints,
  ) {
    test(
      'fulfillTransactionPayment resolves group bridge and grants to group',
      () async {
        final session = sessionBuilder.build();
        final tag = 'group_pro_days_${const Uuid().v4().substring(0, 8)}';
        final shareGroupUuid =
            UuidValue.fromString(const Uuid().v4());

        // Entitlement registered for the group_* tag.
        final entitlement = await Entitlement.db.insertRow(
          session,
          Entitlement(
            tag: tag,
            name: 'Group Pro Days',
            type: EntitlementType.consumable,
            serverValidated: true,
          ),
        );

        // RailProduct + grant: a purchase of this product grants 30 of the
        // group entitlement.
        final railProduct = await RailProduct.db.insertRow(
          session,
          RailProduct(
            rail: PaymentRail.stripe,
            storeProductId:
                'group_pro_monthly_${const Uuid().v4().substring(0, 8)}',
            isActive: true,
          ),
        );
        const grantQuantity = 30.0;
        await RailProductGrant.db.insertRow(
          session,
          RailProductGrant(
            railProductId: railProduct.id!,
            entitlementId: entitlement.id!,
            quantity: grantQuantity,
          ),
        );

        // Group bridge + pending payment at the same timestamp.
        final txTimestamp = DateTime.now();
        await EphemeralAccreditationGroup.db.insertRow(
          session,
          EphemeralAccreditationGroup(
            accountUuid: UuidValue.fromString(const Uuid().v4()),
            shareGroupUuid: shareGroupUuid,
            transactionTimestamp: txTimestamp,
          ),
        );
        final internalTxId = const Uuid().v4();
        await TransactionPayment.db.insertRow(
          session,
          TransactionPayment(
            railProductId: railProduct.id!,
            internalTransactionId: internalTxId,
            priceCurrency: Currency.USD,
            price: 9.99,
            paymentRail: PaymentRail.stripe,
            paymentCurrency: Currency.USD,
            paymentAmount: 9.99,
            transactionTimestamp: txTimestamp,
            status: OrderStatus.pending,
          ),
        );

        // Fulfill: should resolve via the group bridge and credit the group.
        await CommerceManager.fulfillTransactionPayment(
          session,
          internalTransactionId: internalTxId,
        );

        // Group balance was credited.
        final balance =
            await GroupEntitlementManager.getGroupEntitlementBalance(
          session,
          shareGroupUuid: shareGroupUuid,
          tag: tag,
        );
        expect(balance, equals(grantQuantity));

        // No account-side row was created (no account bridge existed).
        final accountRows = await AccountEntitlement.db.find(
          session,
          where: (t) => t.entitlementId.equals(entitlement.id!),
        );
        expect(accountRows, isEmpty);

        // Transaction marked paid.
        final updated = await TransactionPayment.db.findFirstRow(
          session,
          where: (t) => t.internalTransactionId.equals(internalTxId),
        );
        expect(updated!.status, equals(OrderStatus.paid));
      },
    );

    test('fulfillTransactionPayment prefers account bridge over group bridge',
        () async {
      // If both bridges happen to exist at the same timestamp, account wins
      // (per spec §7.5 order). This protects existing semantics.
      final session = sessionBuilder.build();
      final tag = 'pro_days_${const Uuid().v4().substring(0, 8)}';
      final accountUuid = UuidValue.fromString(const Uuid().v4());
      final shareGroupUuid = UuidValue.fromString(const Uuid().v4());

      final entitlement = await Entitlement.db.insertRow(
        session,
        Entitlement(
          tag: tag,
          name: 'Pro Days',
          type: EntitlementType.consumable,
          serverValidated: true,
        ),
      );
      final railProduct = await RailProduct.db.insertRow(
        session,
        RailProduct(
          rail: PaymentRail.stripe,
          storeProductId:
              'pro_monthly_${const Uuid().v4().substring(0, 8)}',
          isActive: true,
        ),
      );
      const grantQuantity = 30.0;
      await RailProductGrant.db.insertRow(
        session,
        RailProductGrant(
          railProductId: railProduct.id!,
          entitlementId: entitlement.id!,
          quantity: grantQuantity,
        ),
      );

      final txTimestamp = DateTime.now();
      await EphemeralAccreditation.db.insertRow(
        session,
        EphemeralAccreditation(
          accountUuid: accountUuid,
          transactionTimestamp: txTimestamp,
        ),
      );
      await EphemeralAccreditationGroup.db.insertRow(
        session,
        EphemeralAccreditationGroup(
          accountUuid: UuidValue.fromString(const Uuid().v4()),
          shareGroupUuid: shareGroupUuid,
          transactionTimestamp: txTimestamp,
        ),
      );
      final internalTxId = const Uuid().v4();
      await TransactionPayment.db.insertRow(
        session,
        TransactionPayment(
          railProductId: railProduct.id!,
          internalTransactionId: internalTxId,
          priceCurrency: Currency.USD,
          price: 9.99,
          paymentRail: PaymentRail.stripe,
          paymentCurrency: Currency.USD,
          paymentAmount: 9.99,
          transactionTimestamp: txTimestamp,
          status: OrderStatus.pending,
        ),
      );

      await CommerceManager.fulfillTransactionPayment(
        session,
        internalTransactionId: internalTxId,
      );

      // Account got the grant.
      final acctRow = await AccountEntitlement.db.findFirstRow(
        session,
        where: (t) =>
            t.accountUuid.equals(accountUuid) &
            t.entitlementId.equals(entitlement.id!),
      );
      expect(acctRow!.balance, equals(grantQuantity));

      // Group did NOT get the grant.
      final groupRows = await GroupEntitlement.db.find(
        session,
        where: (t) => t.shareGroupUuid.equals(shareGroupUuid),
      );
      expect(groupRows, isEmpty);
    });

    test('group post-fulfillment hook fires with the right context',
        () async {
      final session = sessionBuilder.build();
      final tag =
          'group_hook_test_${const Uuid().v4().substring(0, 8)}';
      final shareGroupUuid = UuidValue.fromString(const Uuid().v4());
      final buyerAccountUuid = UuidValue.fromString(const Uuid().v4());

      final entitlement = await Entitlement.db.insertRow(
        session,
        Entitlement(
          tag: tag,
          name: 'Group Hook',
          type: EntitlementType.consumable,
          serverValidated: true,
        ),
      );
      final railProduct = await RailProduct.db.insertRow(
        session,
        RailProduct(
          rail: PaymentRail.stripe,
          storeProductId:
              'group_hook_prod_${const Uuid().v4().substring(0, 8)}',
          isActive: true,
        ),
      );
      await RailProductGrant.db.insertRow(
        session,
        RailProductGrant(
          railProductId: railProduct.id!,
          entitlementId: entitlement.id!,
          quantity: 5.0,
        ),
      );

      final txTimestamp = DateTime.now();
      await EphemeralAccreditationGroup.db.insertRow(
        session,
        EphemeralAccreditationGroup(
          accountUuid: buyerAccountUuid,
          shareGroupUuid: shareGroupUuid,
          transactionTimestamp: txTimestamp,
        ),
      );
      final internalTxId = const Uuid().v4();
      await TransactionPayment.db.insertRow(
        session,
        TransactionPayment(
          railProductId: railProduct.id!,
          internalTransactionId: internalTxId,
          priceCurrency: Currency.USD,
          price: 4.99,
          paymentRail: PaymentRail.stripe,
          paymentCurrency: Currency.USD,
          paymentAmount: 4.99,
          transactionTimestamp: txTimestamp,
          status: OrderStatus.pending,
        ),
      );

      GroupPostFulfillmentContext? captured;
      CommerceManager.onGroupPostFulfillment((s, ctx) async {
        captured = ctx;
      });
      addTearDown(CommerceManager.resetGroupPostFulfillmentHook);

      await CommerceManager.fulfillTransactionPayment(
        session,
        internalTransactionId: internalTxId,
      );

      expect(captured, isNotNull);
      expect(captured!.shareGroupUuid, equals(shareGroupUuid));
      expect(captured!.buyerAccountUuid, equals(buyerAccountUuid));
      expect(captured!.grantsApplied, hasLength(1));
      expect(captured!.grantsApplied.single.quantity, equals(5.0));
      expect(captured!.payment.internalTransactionId, equals(internalTxId));
    });

    test(
      'fulfillTransactionPayment fails when neither bridge exists',
      () async {
        final session = sessionBuilder.build();
        final railProduct = await RailProduct.db.insertRow(
          session,
          RailProduct(
            rail: PaymentRail.stripe,
            storeProductId:
                'orphan_prod_${const Uuid().v4().substring(0, 8)}',
            isActive: true,
          ),
        );
        final internalTxId = const Uuid().v4();
        await TransactionPayment.db.insertRow(
          session,
          TransactionPayment(
            railProductId: railProduct.id!,
            internalTransactionId: internalTxId,
            priceCurrency: Currency.USD,
            price: 1.0,
            paymentRail: PaymentRail.stripe,
            paymentCurrency: Currency.USD,
            paymentAmount: 1.0,
            transactionTimestamp: DateTime.now(),
            status: OrderStatus.pending,
          ),
        );

        expect(
          () => CommerceManager.fulfillTransactionPayment(
            session,
            internalTransactionId: internalTxId,
          ),
          throwsA(isA<Exception>()),
        );
      },
    );
  });
}
