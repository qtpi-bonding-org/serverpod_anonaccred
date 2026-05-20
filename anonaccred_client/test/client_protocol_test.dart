import 'package:test/test.dart';
import 'package:anonaccred_client/anonaccred_client.dart';

/// Integration tests for client-side protocol class usage
///
/// These tests verify that the AnonAccred client protocol classes
/// are properly generated and accessible for external consumption.
void main() {
  group('Client Protocol Integration Tests', () {
    test('AnonAccount protocol class works correctly', () {
      final account = AnonAccount(
        id: 1,
        ultimateSigningPublicKeyHex: 'a' * 128,
        encryptedDataKey: 'encrypted_data_key_example',
        ultimatePublicKey: 'b' * 128,
        createdAt: DateTime.now(),
      );

      expect(account.id, equals(1));
      expect(account.ultimateSigningPublicKeyHex, equals('a' * 128));
      expect(account.encryptedDataKey, equals('encrypted_data_key_example'));
      expect(account.createdAt, isA<DateTime>());
    });

    test('AccountDevice protocol class works correctly', () {
      final device = AccountDevice(
        id: 1,
        accountId: 123,
        deviceSigningPublicKeyHex: 'b' * 128,
        encryptedDataKey: 'device_encrypted_key',
        label: 'Test Device',
        lastActive: DateTime.now(),
        isRevoked: false,
      );

      expect(device.id, equals(1));
      expect(device.accountId, equals(123));
      expect(device.deviceSigningPublicKeyHex, equals('b' * 128));
      expect(device.encryptedDataKey, equals('device_encrypted_key'));
      expect(device.label, equals('Test Device'));
      expect(device.isRevoked, isFalse);
    });

    test('TransactionPayment protocol class works correctly', () {
      final transaction = TransactionPayment(
        railProductId: 1,
        internalTransactionId: '123e4567-e89b-12d3-a456-426614174000',
        priceCurrency: Currency.USD,
        price: 9.99,
        paymentRail: PaymentRail.monero,
        paymentCurrency: Currency.XMR,
        paymentAmount: 0.05,
        paymentRef: 'payment_ref_123',
        transactionTimestamp: DateTime.now(),
        status: OrderStatus.paid,
      );

      expect(transaction.internalTransactionId,
          equals('123e4567-e89b-12d3-a456-426614174000'));
      expect(transaction.priceCurrency, equals(Currency.USD));
      expect(transaction.price, equals(9.99));
      expect(transaction.paymentRail, equals(PaymentRail.monero));
      expect(transaction.paymentCurrency, equals(Currency.XMR));
      expect(transaction.paymentAmount, equals(0.05));
      expect(transaction.paymentRef, equals('payment_ref_123'));
      expect(transaction.status, equals(OrderStatus.paid));
    });

    test('Currency enum works correctly', () {
      expect(Currency.USD.name, equals('USD'));
      expect(Currency.XMR.name, equals('XMR'));

      final currencies = Currency.values;
      expect(currencies, contains(Currency.USD));
      expect(currencies, contains(Currency.XMR));
    });

    test('PaymentRail enum works correctly', () {
      expect(PaymentRail.monero.name, equals('monero'));
      expect(PaymentRail.x402_http.name, equals('x402_http'));
      expect(PaymentRail.apple_iap.name, equals('apple_iap'));
      expect(PaymentRail.google_iap.name, equals('google_iap'));

      final rails = PaymentRail.values;
      expect(rails, contains(PaymentRail.monero));
      expect(rails, contains(PaymentRail.x402_http));
      expect(rails, contains(PaymentRail.apple_iap));
      expect(rails, contains(PaymentRail.google_iap));
    });

    test('OrderStatus enum works correctly', () {
      expect(OrderStatus.pending.name, equals('pending'));
      expect(OrderStatus.processing.name, equals('processing'));
      expect(OrderStatus.paid.name, equals('paid'));
      expect(OrderStatus.failed.name, equals('failed'));
      expect(OrderStatus.cancelled.name, equals('cancelled'));

      final statuses = OrderStatus.values;
      expect(statuses, contains(OrderStatus.pending));
      expect(statuses, contains(OrderStatus.processing));
      expect(statuses, contains(OrderStatus.paid));
      expect(statuses, contains(OrderStatus.failed));
      expect(statuses, contains(OrderStatus.cancelled));
    });

    test('exception protocol classes work correctly', () {
      // Test authentication exception
      final authException = AuthenticationException(
        code: 'AUTH_ERROR',
        message: 'Auth message',
        operation: 'login',
        details: {'context': 'test'},
      );

      expect(authException.code, equals('AUTH_ERROR'));
      expect(authException.message, equals('Auth message'));
      expect(authException.operation, equals('login'));
      expect(authException.details, equals({'context': 'test'}));

      // Test payment exception
      final paymentException = PaymentException(
        code: 'PAYMENT_ERROR',
        message: 'Payment message',
        internalTransactionId: 'txn123',
        paymentRail: 'monero',
        details: {'amount': '10.0'},
      );

      expect(paymentException.code, equals('PAYMENT_ERROR'));
      expect(paymentException.message, equals('Payment message'));
      expect(paymentException.internalTransactionId, equals('txn123'));
      expect(paymentException.paymentRail, equals('monero'));

      // Test inventory exception
      final inventoryException = InventoryException(
        code: 'INVENTORY_ERROR',
        message: 'Inventory message',
        tag: 'credits',
        details: {'balance': '50'},
      );

      expect(inventoryException.code, equals('INVENTORY_ERROR'));
      expect(inventoryException.message, equals('Inventory message'));
      expect(inventoryException.tag, equals('credits'));
    });

    test('protocol classes support JSON serialization', () {
      final account = AnonAccount(
        id: 1,
        ultimateSigningPublicKeyHex: 'c' * 128,
        encryptedDataKey: 'test_key',
        ultimatePublicKey: 'd' * 128,
        createdAt: DateTime.now(),
      );

      expect(() => account.toJson(), returnsNormally);

      final json = account.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json['ultimateSigningPublicKeyHex'], equals('c' * 128));
      expect(json['encryptedDataKey'], equals('test_key'));
    });
  });

  group('Module Import and Dependency Resolution', () {
    test('module can be imported without conflicts', () {
      expect(AnonAccount, isNotNull);
      expect(Currency, isNotNull);
      expect(PaymentRail, isNotNull);
      expect(OrderStatus, isNotNull);
    });

    test('Serverpod client integration works', () {
      expect(() {
        final account = AnonAccount(
          id: 1,
          ultimateSigningPublicKeyHex: 'd' * 128,
          encryptedDataKey: 'integration_test',
          ultimatePublicKey: 'e' * 128,
          createdAt: DateTime.now(),
        );

        expect(account.ultimateSigningPublicKeyHex, isNotEmpty);
      }, returnsNormally);
    });
  });
}
