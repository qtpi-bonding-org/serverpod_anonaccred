import 'package:test/test.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('TransactionPayment Database Operations', (
    sessionBuilder,
    endpoints,
  ) {

    test('Insert and retrieve TransactionPayment with paymentRef and transactionHash', () async {
      final session = sessionBuilder.build();
      
      // Create a test account for foreign key constraint
      final testAccount = AnonAccount(
        ultimateSigningPublicKeyHex: 'test_public_key_${DateTime.now().millisecondsSinceEpoch}',
        encryptedDataKey: 'encrypted_data_key_test',
        ultimatePublicKey: 'ultimate_public_key_${DateTime.now().millisecondsSinceEpoch}',
      );
      final insertedAccount = await AnonAccount.db.insertRow(session, testAccount);
      
      // Create a transaction with both paymentRef and transactionHash
      final transaction = TransactionPayment(
        externalId: 'test_external_id_${DateTime.now().millisecondsSinceEpoch}',
        accountId: insertedAccount.id!,
        priceCurrency: Currency.USD,
        price: 9.99,
        paymentRail: PaymentRail.monero,
        paymentCurrency: Currency.XMR,
        paymentAmount: 0.05,
        paymentRef: 'payment_ref_test_123',
        transactionHash: 'tx_hash_abc123def456',
        status: OrderStatus.paid,
      );

      // Insert the transaction
      final insertedTransaction = await TransactionPayment.db.insertRow(session, transaction);

      // Verify the transaction was inserted with correct values
      expect(insertedTransaction.id, isNotNull);
      expect(insertedTransaction.paymentRef, equals('payment_ref_test_123'));
      expect(insertedTransaction.transactionHash, equals('tx_hash_abc123def456'));

      // Retrieve the transaction from database
      final retrievedTransaction = await TransactionPayment.db.findById(session, insertedTransaction.id!);

      // Verify all fields including the new ones
      expect(retrievedTransaction, isNotNull);
      expect(retrievedTransaction!.externalId, equals(transaction.externalId));
      expect(retrievedTransaction.paymentRef, equals('payment_ref_test_123'));
      expect(retrievedTransaction.transactionHash, equals('tx_hash_abc123def456'));
      expect(retrievedTransaction.status, equals(OrderStatus.paid));

      // Clean up
      await TransactionPayment.db.deleteRow(session, insertedTransaction);
    });

    test('Insert TransactionPayment with null paymentRef and transactionHash', () async {
      final session = sessionBuilder.build();
      
      // Create a test account for foreign key constraint
      final testAccount = AnonAccount(
        ultimateSigningPublicKeyHex: 'test_public_key_null_${DateTime.now().millisecondsSinceEpoch}',
        encryptedDataKey: 'encrypted_data_key_test',
        ultimatePublicKey: 'ultimate_public_key_null_${DateTime.now().millisecondsSinceEpoch}',
      );
      final insertedAccount = await AnonAccount.db.insertRow(session, testAccount);
      
      // Create a transaction with null values for optional fields
      final transaction = TransactionPayment(
        externalId: 'test_external_id_null_${DateTime.now().millisecondsSinceEpoch}',
        accountId: insertedAccount.id!,
        priceCurrency: Currency.USD,
        price: 5.99,
        paymentRail: PaymentRail.x402_http,
        paymentCurrency: Currency.USD,
        paymentAmount: 5.99,
        paymentRef: null,
        transactionHash: null,
        status: OrderStatus.pending,
      );

      // Insert the transaction
      final insertedTransaction = await TransactionPayment.db.insertRow(session, transaction);

      // Verify the transaction was inserted with null values
      expect(insertedTransaction.id, isNotNull);
      expect(insertedTransaction.paymentRef, isNull);
      expect(insertedTransaction.transactionHash, isNull);

      // Retrieve the transaction from database
      final retrievedTransaction = await TransactionPayment.db.findById(session, insertedTransaction.id!);

      // Verify null values are preserved
      expect(retrievedTransaction, isNotNull);
      expect(retrievedTransaction!.paymentRef, isNull);
      expect(retrievedTransaction.transactionHash, isNull);
      expect(retrievedTransaction.status, equals(OrderStatus.pending));

      // Clean up
      await TransactionPayment.db.deleteRow(session, insertedTransaction);
    });

    test('Update TransactionPayment paymentRef and transactionHash fields', () async {
      final session = sessionBuilder.build();
      
      // Create a test account for foreign key constraint
      final testAccount = AnonAccount(
        ultimateSigningPublicKeyHex: 'test_public_key_update_${DateTime.now().millisecondsSinceEpoch}',
        encryptedDataKey: 'encrypted_data_key_test',
        ultimatePublicKey: 'ultimate_public_key_update_${DateTime.now().millisecondsSinceEpoch}',
      );
      final insertedAccount = await AnonAccount.db.insertRow(session, testAccount);
      
      // Create initial transaction
      final transaction = TransactionPayment(
        externalId: 'test_external_id_update_${DateTime.now().millisecondsSinceEpoch}',
        accountId: insertedAccount.id!,
        priceCurrency: Currency.USD,
        price: 15.99,
        paymentRail: PaymentRail.apple_iap,
        paymentCurrency: Currency.USD,
        paymentAmount: 15.99,
        paymentRef: null,
        transactionHash: null,
        status: OrderStatus.pending,
      );

      // Insert the transaction
      final insertedTransaction = await TransactionPayment.db.insertRow(session, transaction);

      // Update with paymentRef and transactionHash
      final updatedTransaction = insertedTransaction.copyWith(
        paymentRef: 'updated_payment_ref_456',
        transactionHash: 'updated_tx_hash_789xyz',
        status: OrderStatus.paid,
      );

      // Update in database
      final savedTransaction = await TransactionPayment.db.updateRow(session, updatedTransaction);

      // Verify the update
      expect(savedTransaction.paymentRef, equals('updated_payment_ref_456'));
      expect(savedTransaction.transactionHash, equals('updated_tx_hash_789xyz'));
      expect(savedTransaction.status, equals(OrderStatus.paid));

      // Retrieve and verify persistence
      final retrievedTransaction = await TransactionPayment.db.findById(session, savedTransaction.id!);
      expect(retrievedTransaction!.paymentRef, equals('updated_payment_ref_456'));
      expect(retrievedTransaction.transactionHash, equals('updated_tx_hash_789xyz'));

      // Clean up
      await TransactionPayment.db.deleteRow(session, savedTransaction);
    });
  });
}