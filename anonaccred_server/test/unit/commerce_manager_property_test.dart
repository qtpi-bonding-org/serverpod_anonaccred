import 'dart:math';

import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:anonaccred_server/src/payments/mock_android_publisher_client.dart';
import 'package:anonaccred_server/src/payments/mock_app_store_server_client.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:anonaccred_server/src/payments/payment_rail_interface.dart';
import 'package:anonaccred_server/src/payments/rails/apple_iap_rail.dart';
import 'package:anonaccred_server/src/payments/rails/google_iap_rail.dart';
import 'package:anonaccred_server/src/refund_event.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

/// Mock payment rail for testing
class MockPaymentRail implements PaymentRailInterface {
  MockPaymentRail(this._railType);
  final PaymentRail _railType;
  
  @override
  PaymentRail get railType => _railType;
  
  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String internalTransactionId,
  }) async {
    return PaymentRequest(
      paymentRef: 'mock_${_railType.name}_$internalTransactionId',
      amountUSD: amountUSD,
      internalTransactionId: internalTransactionId,
      railDataJson: '{"mock": true, "rail": "${_railType.name}"}',
    );
  }
  
  @override
  Future<PaymentResult> processCallback(Map<String, dynamic> callbackData) async {
    return PaymentResult(success: true);
  }

  @override
  RefundEvent? extractRefundEvent(Map<String, dynamic> notificationData) => null;
}

/// **Feature: anonaccred-phase3, Property 2: Transaction Initiation Integrity**
/// **Validates: Requirements 2.1, 2.2, 2.4, 2.5**

void main() {
  withServerpod('Commerce Manager Property Tests', (sessionBuilder, endpoints) {
    setUpAll(() async {
      // Register all payment rails with mock implementations
      PaymentManager.clearRails();
      PaymentManager.registerRail(AppleIAPRail(client: MockAppStoreServerClient()));
      PaymentManager.registerRail(GoogleIAPRail(client: MockAndroidPublisherClient()));
      PaymentManager.registerRail(MockPaymentRail(PaymentRail.monero));
      PaymentManager.registerRail(MockPaymentRail(PaymentRail.stripe));
      PaymentManager.registerRail(MockPaymentRail(PaymentRail.x402_http));
    });
    test(
      'Property 2: Transaction Initiation Integrity - For any valid payment initiation, the system should generate an identity-free record linked via the accreditation bridge',
      () async {
        for (var i = 0; i < 5; i++) {
          final session = sessionBuilder.build();

          // 1. Setup random account
          final account = await AnonAccount.db.insertRow(session, AnonAccount(
            id: UuidValue.fromString(const Uuid().v4()),
            ultimateSigningPublicKeyHex: _generateRandomPublicKey(),
            encryptedDataKey: 'encrypted_data_key_test_$i',
            ultimatePublicKey: _generateRandomPublicKey(),
          ));
          final accountUuid = account.id!;

          // 2. Setup random RailProduct
          final storeProductId = 'com.test.product_$i';
          const rail = PaymentRail.apple_iap;
          final price = _generateRandomPrice();

          final railProduct = await RailProduct.db.insertRow(
            session,
            RailProduct(
              rail: rail,
              storeProductId: storeProductId,
              isActive: true,
            ),
          );

          // 3. Initiate payment (Requirement 2.1, 2.4)
          final payment = await CommerceManager.initiateTransactionPayment(
            session,
            accountUuid: accountUuid,
            rail: rail,
            storeProductId: storeProductId,
            clientReference: 'client_ref_$i',
            customPrice: price,
          );

          // Verify TransactionPayment properties (Requirement 2.1)
          expect(payment.id, isNotNull);
          expect(payment.railProductId, equals(railProduct.id));
          expect(payment.internalTransactionId, isNotNull);
          expect(payment.price, equals(price));
          expect(payment.status, equals(OrderStatus.pending));
          expect(payment.clientReference, equals('client_ref_$i'));

          // Verify Accreditation Bridge exists (Requirement 2.2)
          final bridge = await EphemeralAccreditation.db.findFirstRow(
            session,
            where: (t) =>
                t.transactionTimestamp.equals(payment.transactionTimestamp),
          );
          expect(bridge, isNotNull);
          expect(bridge!.accountUuid, equals(accountUuid));

          // 4. Verify uniqueness (Requirement 2.4)
          final secondPayment =
              await CommerceManager.initiateTransactionPayment(
                session,
                accountUuid: accountUuid,
                rail: rail,
                storeProductId: storeProductId,
                customPrice: price,
              );
          expect(
            secondPayment.internalTransactionId,
            isNot(equals(payment.internalTransactionId)),
          );

          // Clean up
          await _cleanupTransactionData(session, payment.internalTransactionId);
          await _cleanupTransactionData(
            session,
            secondPayment.internalTransactionId,
          );
          await RailProduct.db.deleteRow(session, railProduct);
        }
      },
    );

    test(
      'Property 3: Product Validation - Rejects inactive or non-existent products',
      () async {
        // Create account first
        final session1 = sessionBuilder.build();
        final account = await AnonAccount.db.insertRow(
          session1,
          AnonAccount(
            id: UuidValue.fromString(const Uuid().v4()),
            ultimateSigningPublicKeyHex: _generateRandomPublicKey(),
            encryptedDataKey: 'encrypted_data_key_val',
            ultimatePublicKey: _generateRandomPublicKey(),
          ),
        );
        final accountUuid = account.id!;

        // 1. Test non-existent SKU
        try {
          await CommerceManager.initiateTransactionPayment(
            session1,
            accountUuid: accountUuid,
            rail: PaymentRail.google_iap,
            storeProductId: 'non_existent_sku',
          );
          fail('Expected PaymentException');
        } on PaymentException catch (e) {
          expect(e.code, equals(AnonAccredErrorCodes.orderInvalidProduct));
        }

        // 2. Test inactive SKU - create the inactive product first
        final railProduct = await RailProduct.db.insertRow(
          session1,
          RailProduct(
            rail: PaymentRail.monero,
            storeProductId: 'inactive_sku',
            isActive: false,
          ),
        );

        // Use the same session for CommerceManager call
        try {
          await CommerceManager.initiateTransactionPayment(
            session1,
            accountUuid: accountUuid,
            rail: PaymentRail.monero,
            storeProductId: 'inactive_sku',
          );
          fail('Expected PaymentException');
        } on PaymentException catch (e) {
          expect(e.code, equals(AnonAccredErrorCodes.orderInvalidProduct));
        }

        await RailProduct.db.deleteRow(session1, railProduct);
        await AnonAccount.db.deleteRow(session1, account);
      },
    );

    test(
      'Property 7: Fulfillment Completeness - Correctly grants entitlements via the bridge',
      () async {
        for (var i = 0; i < 5; i++) {
          final session = sessionBuilder.build();

          // 1. Account
          final account = await AnonAccount.db.insertRow(session, AnonAccount(
            id: UuidValue.fromString(const Uuid().v4()),
            ultimateSigningPublicKeyHex: _generateRandomPublicKey(),
            encryptedDataKey: 'encrypted_data_key_full_$i',
            ultimatePublicKey: _generateRandomPublicKey(),
          ));
          final accountUuid = account.id!;

          // 2. Entitlements and RailProduct
          final tag = 'credits_$i';
          final ent = await Entitlement.db.insertRow(
            session,
            Entitlement(
              tag: tag,
              name: 'Credits $i',
              type: EntitlementType.consumable,
              serverValidated: true,
            ),
          );

          final railProduct = await RailProduct.db.insertRow(
            session,
            RailProduct(
              rail: PaymentRail.stripe,
              storeProductId: 'stripe_prod_$i',
              isActive: true,
            ),
          );

          // 3. Grants
          const quantity = 100.0;
          final grant = await RailProductGrant.db.insertRow(
            session,
            RailProductGrant(
              railProductId: railProduct.id!,
              entitlementId: ent.id!,
              quantity: quantity,
            ),
          );

          // 4. Exercise Payment and Fulfillment
          final payment = await CommerceManager.initiateTransactionPayment(
            session,
            accountUuid: accountUuid,
            rail: PaymentRail.stripe,
            storeProductId: 'stripe_prod_$i',
            customPrice: 10.0,
          );

          await CommerceManager.fulfillTransactionPayment(
            session,
            internalTransactionId: payment.internalTransactionId,
          );

          // 5. Verify Entitlement Balance
          final balance = await EntitlementManager.getEntitlementBalance(
            session,
            accountUuid: accountUuid,
            tag: tag,
          );
          expect(balance, equals(quantity));

          // 6. Verify Transaction Status
          final updated = await TransactionPayment.db.findFirstRow(
            session,
            where: (t) =>
                t.internalTransactionId.equals(payment.internalTransactionId),
          );
          expect(updated!.status, equals(OrderStatus.paid));

          // Clean up - delete in correct order to avoid FK constraint violations
          await _cleanupTransactionData(session, payment.internalTransactionId);
          await AccountEntitlement.db.deleteWhere(
            session,
            where: (t) => t.accountUuid.equals(accountUuid),
          );
          await RailProductGrant.db.deleteRow(session, grant);
          await RailProduct.db.deleteRow(session, railProduct);
          await Entitlement.db.deleteRow(session, ent);
        }
      },
    );
  });
}

// Helpers
String _generateRandomPublicKey() {
  final random = Random();
  final buffer = StringBuffer();
  for (var i = 0; i < 128; i++) {
    buffer.write(random.nextInt(16).toRadixString(16));
  }
  return buffer.toString();
}

double _generateRandomPrice() => (Random().nextDouble() * 100.0) + 0.99;

Future<void> _cleanupTransactionData(
  Session session,
  String internalTxId,
) async {
  try {
    final payment = await TransactionPayment.db.findFirstRow(
      session,
      where: (t) => t.internalTransactionId.equals(internalTxId),
    );
    if (payment != null) {
      await EphemeralAccreditation.db.deleteWhere(
        session,
        where: (t) =>
            t.transactionTimestamp.equals(payment.transactionTimestamp),
      );
      await TransactionPayment.db.deleteRow(session, payment);
    }
  } catch (e) {
    // Ignore
  }
}
