import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('PaymentProcessor', (sessionBuilder, endpoints) {
    late TransactionPayment testTransaction;
    late AnonAccount testAccount;

    setUp(() async {
      final session = sessionBuilder.build();

      // Create a test account for foreign key constraint
      testAccount = AnonAccount(
        accountUuid: UuidValue.fromString(const Uuid().v4()),
        ultimateSigningPublicKeyHex:
            'test_public_key_${DateTime.now().millisecondsSinceEpoch}',
        encryptedDataKey: 'encrypted_data_key_test',
        ultimatePublicKey:
            'ultimate_public_key_${DateTime.now().millisecondsSinceEpoch}',
      );
      testAccount = await AnonAccount.db.insertRow(session, testAccount);

      // 1. Create a dummy RailProduct for testing
      final railProduct = await RailProduct.db.insertRow(
        session,
        RailProduct(
          rail: PaymentRail.x402_http,
          storeProductId: 'test_sku',
          isActive: true,
        ),
      );

      // 2. Create a test transaction for each test
      testTransaction = TransactionPayment(
        railProductId: railProduct.id!,
        internalTransactionId:
            'test-order-${DateTime.now().millisecondsSinceEpoch}',
        priceCurrency: Currency.USD,
        price: 10.0,
        paymentRail: PaymentRail.x402_http,
        paymentCurrency: Currency.USD,
        paymentAmount: 10.0,
        transactionTimestamp: DateTime.now(),
        status: OrderStatus.pending,
      );

      testTransaction = await TransactionPayment.db.insertRow(
        session,
        testTransaction,
      );
    });

    tearDown(() async {
      final session = sessionBuilder.build();
      // Clean up test transaction and account
      if (testTransaction.id != null) {
        await TransactionPayment.db.deleteRow(session, testTransaction);
      }
      if (testAccount.id != null) {
        await AnonAccount.db.deleteRow(session, testAccount);
      }
    });

    test('updateTransactionStatus updates status successfully', () async {
      final session = sessionBuilder.build();

      // Act
      await PaymentProcessor.updateTransactionStatus(
        session,
        testTransaction.internalTransactionId,
        OrderStatus.processing,
      );

      // Assert
      final updated = await TransactionPayment.db.findById(
        session,
        testTransaction.id!,
      );
      expect(updated?.status, equals(OrderStatus.processing));
    });

    test('updatePaymentRef updates payment reference successfully', () async {
      final session = sessionBuilder.build();
      const paymentRef = 'payment-ref-123';

      // Act
      await PaymentProcessor.updatePaymentRef(
        session,
        testTransaction.internalTransactionId,
        paymentRef,
      );

      // Assert
      final updated = await TransactionPayment.db.findById(
        session,
        testTransaction.id!,
      );
      expect(updated?.paymentRef, equals(paymentRef));
    });

    test(
      'updateTransactionTimestamp updates transaction timestamp successfully',
      () async {
        final session = sessionBuilder.build();
        final transactionTimestamp = DateTime.now();

        // Act
        await PaymentProcessor.updateTransactionTimestamp(
          session,
          testTransaction.internalTransactionId,
          transactionTimestamp,
        );

        // Assert
        final updated = await TransactionPayment.db.findById(
          session,
          testTransaction.id!,
        );
        expect(updated?.transactionTimestamp, isNotNull);
      },
    );

    test(
      'updateStatusAndPaymentRef updates both fields successfully',
      () async {
        final session = sessionBuilder.build();
        const paymentRef = 'payment-ref-456';

        // Act
        await PaymentProcessor.updateStatusAndPaymentRef(
          session,
          testTransaction.internalTransactionId,
          OrderStatus.paid,
          paymentRef,
        );

        // Assert
        final updated = await TransactionPayment.db.findById(
          session,
          testTransaction.id!,
        );
        expect(updated?.status, equals(OrderStatus.paid));
        expect(updated?.paymentRef, equals(paymentRef));
      },
    );

    test('getTransactionById retrieves transaction successfully', () async {
      final session = sessionBuilder.build();

      // Act
      final retrieved = await PaymentProcessor.getTransactionById(
        session,
        testTransaction.internalTransactionId,
      );

      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved?.id, equals(testTransaction.id));
      expect(
        retrieved?.internalTransactionId,
        equals(testTransaction.internalTransactionId),
      );
    });

    test(
      'updateTransactionStatus throws exception for non-existent transaction',
      () async {
        final session = sessionBuilder.build();

        // Act & Assert
        expect(
          () => PaymentProcessor.updateTransactionStatus(
            session,
            'non-existent-order-id',
            OrderStatus.processing,
          ),
          throwsA(isA<PaymentException>()),
        );
      },
    );

    test(
      'updatePaymentRef throws exception for non-existent transaction',
      () async {
        final session = sessionBuilder.build();

        // Act & Assert
        expect(
          () => PaymentProcessor.updatePaymentRef(
            session,
            'non-existent-order-id',
            'payment-ref-123',
          ),
          throwsA(isA<PaymentException>()),
        );
      },
    );

    test(
      'getTransactionById returns null for non-existent transaction',
      () async {
        final session = sessionBuilder.build();

        // Act
        final retrieved = await PaymentProcessor.getTransactionById(
          session,
          'non-existent-order-id',
        );

        // Assert
        expect(retrieved, isNull);
      },
    );
  });
}
