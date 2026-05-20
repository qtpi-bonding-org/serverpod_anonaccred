import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('TransactionPayment Database Operations', (
    sessionBuilder,
    endpoints,
  ) {
    late RailProduct testRailProduct;

    setUp(() async {
      final session = sessionBuilder.build();
      // Ensure we have a RailProduct for tests
      testRailProduct = await RailProduct.db.insertRow(
        session,
        RailProduct(
          rail: PaymentRail.monero,
          storeProductId: 'test_store_sku',
          isActive: true,
        ),
      );
    });

    test(
      'Insert and retrieve TransactionPayment with paymentRef and transactionTimestamp',
      () async {
        final testTimestamp = DateTime.now();
        final session = sessionBuilder.build();

        // Create a transaction with all required fields
        final transaction = TransactionPayment(
          railProductId: testRailProduct.id!,
          internalTransactionId:
              'test_internal_id_${DateTime.now().millisecondsSinceEpoch}',
          priceCurrency: Currency.USD,
          price: 9.99,
          paymentRail: PaymentRail.monero,
          paymentCurrency: Currency.XMR,
          paymentAmount: 0.05,
          paymentRef: 'payment_ref_test_123',
          transactionTimestamp: testTimestamp,
          status: OrderStatus.paid,
        );

        // Insert the transaction
        final insertedTransaction = await TransactionPayment.db.insertRow(
          session,
          transaction,
        );

        // Verify the transaction was inserted with correct values
        expect(insertedTransaction.id, isNotNull);
        expect(insertedTransaction.paymentRef, equals('payment_ref_test_123'));
        expect(insertedTransaction.transactionTimestamp, isNotNull);

        // Retrieve the transaction from database
        final retrievedTransaction = await TransactionPayment.db.findById(
          session,
          insertedTransaction.id!,
        );

        // Verify all fields including the new ones
        expect(retrievedTransaction, isNotNull);
        expect(
          retrievedTransaction!.internalTransactionId,
          equals(transaction.internalTransactionId),
        );
        expect(retrievedTransaction.paymentRef, equals('payment_ref_test_123'));
        expect(retrievedTransaction.transactionTimestamp, isNotNull);
        expect(retrievedTransaction.status, equals(OrderStatus.paid));

        // Clean up
        await TransactionPayment.db.deleteRow(session, insertedTransaction);
      },
    );

    test(
      'TransactionPayment requires railProductId and transactionTimestamp',
      () async {
        final session = sessionBuilder.build();

        // Create a transaction - all required fields must be present
        final transaction = TransactionPayment(
          railProductId: testRailProduct.id!,
          internalTransactionId:
              'test_internal_id_req_${DateTime.now().millisecondsSinceEpoch}',
          priceCurrency: Currency.USD,
          price: 5.99,
          paymentRail: PaymentRail.x402_http,
          paymentCurrency: Currency.USD,
          paymentAmount: 5.99,
          transactionTimestamp: DateTime.now(),
          status: OrderStatus.pending,
        );

        // Insert the transaction
        final insertedTransaction = await TransactionPayment.db.insertRow(
          session,
          transaction,
        );

        expect(insertedTransaction.id, isNotNull);
        expect(insertedTransaction.railProductId, equals(testRailProduct.id));

        // Clean up
        await TransactionPayment.db.deleteRow(session, insertedTransaction);
      },
    );

    test('Update TransactionPayment status and paymentRef', () async {
      final session = sessionBuilder.build();

      // Create initial transaction
      final transaction = TransactionPayment(
        railProductId: testRailProduct.id!,
        internalTransactionId:
            'test_internal_id_update_${DateTime.now().millisecondsSinceEpoch}',
        priceCurrency: Currency.USD,
        price: 15.99,
        paymentRail: PaymentRail.apple_iap,
        paymentCurrency: Currency.USD,
        paymentAmount: 15.99,
        transactionTimestamp: DateTime.now(),
        status: OrderStatus.pending,
      );

      // Insert the transaction
      final insertedTransaction = await TransactionPayment.db.insertRow(
        session,
        transaction,
      );

      // Update with paymentRef
      final updatedTransaction = insertedTransaction.copyWith(
        paymentRef: 'updated_payment_ref_456',
        status: OrderStatus.paid,
      );

      // Update in database
      final savedTransaction = await TransactionPayment.db.updateRow(
        session,
        updatedTransaction,
      );

      // Verify the update
      expect(savedTransaction.paymentRef, equals('updated_payment_ref_456'));
      expect(savedTransaction.status, equals(OrderStatus.paid));

      // Retrieve and verify persistence
      final retrievedTransaction = await TransactionPayment.db.findById(
        session,
        savedTransaction.id!,
      );
      expect(
        retrievedTransaction!.paymentRef,
        equals('updated_payment_ref_456'),
      );

      // Clean up
      await TransactionPayment.db.deleteRow(session, savedTransaction);
    });
  });
}
