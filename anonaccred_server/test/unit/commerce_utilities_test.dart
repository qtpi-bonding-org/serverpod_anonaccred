import 'dart:math';

import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:test/test.dart';

void main() {
  group('Commerce Utilities Tests', () {
    final random = Random();

    group('InventoryUtil', () {
      test('validateConsumableType accepts any non-empty string', () {
        // Test various valid consumable types
        expect(InventoryUtil.validateConsumableType('storage_days'), isTrue);
        expect(InventoryUtil.validateConsumableType('api_credits'), isTrue);
        expect(InventoryUtil.validateConsumableType('premium_features'), isTrue);
        expect(InventoryUtil.validateConsumableType('custom_type_123'), isTrue);
        expect(InventoryUtil.validateConsumableType('   spaced   '), isTrue);
      });

      test('validateConsumableType rejects empty or null strings', () {
        expect(
          () => InventoryUtil.validateConsumableType(''),
          throwsA(isA<InventoryException>()),
        );
        expect(
          () => InventoryUtil.validateConsumableType('   '),
          throwsA(isA<InventoryException>()),
        );
        expect(
          () => InventoryUtil.validateConsumableType(null),
          throwsA(isA<InventoryException>()),
        );
      });
    });

    group('TransactionUtil', () {
      test('TransactionData validation works correctly', () {
        // Test valid transaction data creation
        final validTransactionData = TransactionData(
          externalId: 'test_tx_${random.nextInt(1000000)}',
          accountId: 123,
          priceCurrency: Currency.USD,
          price: 10.0,
          paymentRail: PaymentRail.monero,
          paymentCurrency: Currency.XMR,
          paymentAmount: 0.05,
          status: OrderStatus.pending,
          lineItems: [
            const TransactionLineItem(
              consumableType: 'storage_days',
              quantity: 30.0,
            ),
            const TransactionLineItem(
              consumableType: 'api_credits',
              quantity: 100.0,
            ),
          ],
        );

        expect(validTransactionData.externalId, isNotEmpty);
        expect(validTransactionData.price, equals(10.0));
        expect(validTransactionData.paymentAmount, equals(0.05));
        expect(validTransactionData.lineItems.length, equals(2));
      });

      test('PaymentReceipt structure is correct', () {
        final receipt = PaymentReceipt(
          transactionId: 1,
          externalId: 'test_receipt',
          accountId: 123,
          priceCurrency: Currency.USD,
          price: 5.0,
          paymentRail: PaymentRail.x402_http,
          paymentCurrency: Currency.USD,
          paymentAmount: 5.0,
          paymentRef: 'payment_ref_123',
          status: OrderStatus.paid,
          timestamp: DateTime.now(),
          lineItems: [
            const ReceiptLineItem(
              consumableType: 'premium_features',
              quantity: 1.0,
            ),
          ],
        );

        expect(receipt.transactionId, equals(1));
        expect(receipt.externalId, equals('test_receipt'));
        expect(receipt.price, equals(5.0));
        expect(receipt.paymentRef, equals('payment_ref_123'));
        expect(receipt.lineItems.length, equals(1));
        expect(receipt.lineItems.first.consumableType, equals('premium_features'));
      });

      test('InventoryOperation structure is correct', () {
        final operation = InventoryOperation(
          accountId: 123,
          consumableType: 'test_consumable',
          quantityDelta: 2.5,
        );

        expect(operation.accountId, equals(123));
        expect(operation.consumableType, equals('test_consumable'));
        expect(operation.quantityDelta, equals(2.5));
      });
    });
  });
}