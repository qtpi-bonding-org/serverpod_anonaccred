import 'package:test/test.dart';
import 'package:anonaccred_client/anonaccred_client.dart';

/// Integration tests for client-side protocol class usage
/// 
/// **Feature: anonaccred-phase1, Requirements: 5.2, 5.3**
/// 
/// These tests verify that the AnonAccred client protocol classes
/// are properly generated and accessible for external consumption.
void main() {
  group('Client Protocol Integration Tests', () {
    test('AnonAccount protocol class works correctly', () {
      final account = AnonAccount(
        id: 1,
        publicMasterKey: 'a' * 64, // Valid 64-char hex string
        encryptedDataKey: 'encrypted_data_key_example',
        createdAt: DateTime.now(),
      );
      
      expect(account.id, equals(1));
      expect(account.publicMasterKey, equals('a' * 64));
      expect(account.encryptedDataKey, equals('encrypted_data_key_example'));
      expect(account.createdAt, isA<DateTime>());
    });
    
    test('AccountDevice protocol class works correctly', () {
      final device = AccountDevice(
        id: 1,
        accountId: 123,
        publicSubKey: 'b' * 64, // Valid 64-char hex string
        encryptedDataKey: 'device_encrypted_key',
        label: 'Test Device',
        lastActive: DateTime.now(),
        isRevoked: false,
      );
      
      expect(device.id, equals(1));
      expect(device.accountId, equals(123));
      expect(device.publicSubKey, equals('b' * 64));
      expect(device.encryptedDataKey, equals('device_encrypted_key'));
      expect(device.label, equals('Test Device'));
      expect(device.isRevoked, isFalse);
    });
    
    test('AccountInventory protocol class works correctly', () {
      final inventory = AccountInventory(
        id: 1,
        accountId: 123,
        consumableType: 'api_credits',
        quantity: 100.5, // Test fractional quantities
        lastUpdated: DateTime.now(),
      );
      
      expect(inventory.id, equals(1));
      expect(inventory.accountId, equals(123));
      expect(inventory.consumableType, equals('api_credits'));
      expect(inventory.quantity, equals(100.5));
      expect(inventory.lastUpdated, isA<DateTime>());
    });
    
    test('TransactionPayment protocol class works correctly', () {
      final transaction = TransactionPayment(
        id: 1,
        externalId: '123e4567-e89b-12d3-a456-426614174000',
        accountId: 123,
        priceCurrency: Currency.USD,
        price: 9.99,
        paymentRail: PaymentRail.monero,
        paymentCurrency: Currency.XMR,
        paymentAmount: 0.05,
        paymentRef: 'payment_ref_123',
        transactionHash: 'tx_hash_abc123def456',
        status: OrderStatus.paid,
        timestamp: DateTime.now(),
      );
      
      expect(transaction.externalId, equals('123e4567-e89b-12d3-a456-426614174000'));
      expect(transaction.accountId, equals(123));
      expect(transaction.priceCurrency, equals(Currency.USD));
      expect(transaction.price, equals(9.99));
      expect(transaction.paymentRail, equals(PaymentRail.monero));
      expect(transaction.paymentCurrency, equals(Currency.XMR));
      expect(transaction.paymentAmount, equals(0.05));
      expect(transaction.paymentRef, equals('payment_ref_123'));
      expect(transaction.transactionHash, equals('tx_hash_abc123def456'));
      expect(transaction.status, equals(OrderStatus.paid));
    });
    
    test('TransactionConsumable protocol class works correctly', () {
      final consumable = TransactionConsumable(
        id: 1,
        transactionId: 456,
        consumableType: 'storage_days',
        quantity: 30.0,
      );
      
      expect(consumable.id, equals(1));
      expect(consumable.transactionId, equals(456));
      expect(consumable.consumableType, equals('storage_days'));
      expect(consumable.quantity, equals(30.0));
    });
    
    test('Currency enum works correctly', () {
      expect(Currency.USD.name, equals('USD'));
      expect(Currency.XMR.name, equals('XMR'));
      
      // Test enum values
      final currencies = Currency.values;
      expect(currencies, contains(Currency.USD));
      expect(currencies, contains(Currency.XMR));
    });
    
    test('PaymentRail enum works correctly', () {
      expect(PaymentRail.monero.name, equals('monero'));
      expect(PaymentRail.x402_http.name, equals('x402_http'));
      expect(PaymentRail.apple_iap.name, equals('apple_iap'));
      expect(PaymentRail.google_iap.name, equals('google_iap'));
      
      // Test enum values
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
      
      // Test enum values
      final statuses = OrderStatus.values;
      expect(statuses, contains(OrderStatus.pending));
      expect(statuses, contains(OrderStatus.processing));
      expect(statuses, contains(OrderStatus.paid));
      expect(statuses, contains(OrderStatus.failed));
      expect(statuses, contains(OrderStatus.cancelled));
    });
    
    test('exception protocol classes work correctly', () {
      // Test base exception
      final baseException = AnonAccredException(
        code: 'TEST_ERROR',
        message: 'Test message',
        details: {'key': 'value'},
      );
      
      expect(baseException.code, equals('TEST_ERROR'));
      expect(baseException.message, equals('Test message'));
      expect(baseException.details, equals({'key': 'value'}));
      
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
        orderId: 'order123',
        paymentRail: 'monero',
        details: {'amount': '10.0'},
      );
      
      expect(paymentException.code, equals('PAYMENT_ERROR'));
      expect(paymentException.message, equals('Payment message'));
      expect(paymentException.orderId, equals('order123'));
      expect(paymentException.paymentRail, equals('monero'));
      
      // Test inventory exception
      final inventoryException = InventoryException(
        code: 'INVENTORY_ERROR',
        message: 'Inventory message',
        accountId: 123,
        consumableType: 'credits',
        details: {'balance': '50'},
      );
      
      expect(inventoryException.code, equals('INVENTORY_ERROR'));
      expect(inventoryException.message, equals('Inventory message'));
      expect(inventoryException.accountId, equals(123));
      expect(inventoryException.consumableType, equals('credits'));
    });
    
    test('protocol classes support JSON serialization', () {
      // Test that protocol classes can be serialized/deserialized
      // This is important for Serverpod RPC communication
      
      final account = AnonAccount(
        id: 1,
        publicMasterKey: 'c' * 64,
        encryptedDataKey: 'test_key',
        createdAt: DateTime.now(),
      );
      
      // Test JSON conversion (basic check)
      expect(() => account.toJson(), returnsNormally);
      
      final json = account.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json['publicMasterKey'], equals('c' * 64));
      expect(json['encryptedDataKey'], equals('test_key'));
    });
  });
  
  group('Module Import and Dependency Resolution', () {
    test('module can be imported without conflicts', () {
      // The fact that we can run these tests means the module
      // imports correctly and dependencies are resolved
      
      // Test that we can access Serverpod client classes
      expect(UuidValue, isNotNull);
      
      // Test that we can access AnonAccred protocol classes
      expect(AnonAccount, isNotNull);
      expect(Currency, isNotNull);
      expect(PaymentRail, isNotNull);
      expect(OrderStatus, isNotNull);
    });
    
    test('Serverpod client integration works', () {
      // Test that AnonAccred classes integrate with Serverpod client
      // This verifies that the protocol generation worked correctly
      
      expect(() {
        final account = AnonAccount(
          id: 1,
          publicMasterKey: 'd' * 64,
          encryptedDataKey: 'integration_test',
          createdAt: DateTime.now(),
        );
        
        // Test that the object can be created and used
        expect(account.publicMasterKey, isNotEmpty);
      }, returnsNormally);
    });
  });
}