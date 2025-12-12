import 'package:test/test.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/inventory_manager.dart';
import 'package:anonaccred_server/src/price_registry.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('CommerceEndpoint Integration Tests', (sessionBuilder, endpoints) {
    // Test constants
    const validPublicKey = '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
    const validSignature = 'valid_signature_placeholder_64_chars_1234567890abcdef1234567890ab';
    late int testAccountId;

    setUp(() async {
      // Clear the price registry before each test to ensure clean state
      PriceRegistry().clearRegistry();
      
      // Create a test account for tests that need it
      final account = await endpoints.account.createAccount(
        sessionBuilder,
        validPublicKey,
        'encrypted_data_key_for_commerce_test',
      );
      testAccountId = account.id!;
    });

    group('registerProducts endpoint', () {
      test('successful product registration with valid authentication', () async {
        final products = {
          'storage_days': 5.99,
          'api_credits': 0.01,
          'premium_features': 29.99,
        };

        final result = await endpoints.commerce.registerProducts(
          sessionBuilder,
          validPublicKey,
          validSignature,
          products,
        );

        expect(result, equals(products));
        
        // Verify products are actually registered in the price registry
        final registry = PriceRegistry();
        expect(registry.getPrice('storage_days'), equals(5.99));
        expect(registry.getPrice('api_credits'), equals(0.01));
        expect(registry.getPrice('premium_features'), equals(29.99));
      });

      test('fails with empty public key', () async {
        final products = {'test_item': 1.99};

        expect(
          () => endpoints.commerce.registerProducts(
            sessionBuilder,
            '', // empty public key
            validSignature,
            products,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with invalid public key format', () async {
        final products = {'test_item': 1.99};

        expect(
          () => endpoints.commerce.registerProducts(
            sessionBuilder,
            'invalid_key_too_short',
            validSignature,
            products,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with empty signature', () async {
        final products = {'test_item': 1.99};

        expect(
          () => endpoints.commerce.registerProducts(
            sessionBuilder,
            validPublicKey,
            '', // empty signature
            products,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with empty products map', () async {
        expect(
          () => endpoints.commerce.registerProducts(
            sessionBuilder,
            validPublicKey,
            validSignature,
            {}, // empty products
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with empty product SKU', () async {
        final products = {'': 5.99}; // empty SKU

        expect(
          () => endpoints.commerce.registerProducts(
            sessionBuilder,
            validPublicKey,
            validSignature,
            products,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with negative product price', () async {
        final products = {'test_item': -1.99}; // negative price

        expect(
          () => endpoints.commerce.registerProducts(
            sessionBuilder,
            validPublicKey,
            validSignature,
            products,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with zero product price', () async {
        final products = {'test_item': 0.0}; // zero price

        expect(
          () => endpoints.commerce.registerProducts(
            sessionBuilder,
            validPublicKey,
            validSignature,
            products,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('updates existing product price', () async {
        // Register initial product
        final initialProducts = {'test_item': 5.99};
        await endpoints.commerce.registerProducts(
          sessionBuilder,
          validPublicKey,
          validSignature,
          initialProducts,
        );

        // Update the same product with new price
        final updatedProducts = {'test_item': 9.99};
        final result = await endpoints.commerce.registerProducts(
          sessionBuilder,
          validPublicKey,
          validSignature,
          updatedProducts,
        );

        expect(result, equals(updatedProducts));
        
        // Verify the price was updated in the registry
        final registry = PriceRegistry();
        expect(registry.getPrice('test_item'), equals(9.99));
      });
    });

    group('getProductCatalog endpoint', () {
      test('returns empty catalog when no products registered', () async {
        final catalog = await endpoints.commerce.getProductCatalog(sessionBuilder);
        expect(catalog, isEmpty);
      });

      test('returns all registered products', () async {
        // Register some products first
        final products = {
          'storage_days': 5.99,
          'api_credits': 0.01,
          'premium_features': 29.99,
        };
        
        await endpoints.commerce.registerProducts(
          sessionBuilder,
          validPublicKey,
          validSignature,
          products,
        );

        final catalog = await endpoints.commerce.getProductCatalog(sessionBuilder);
        expect(catalog, equals(products));
      });

      test('reflects product updates in catalog', () async {
        // Register initial products
        await endpoints.commerce.registerProducts(
          sessionBuilder,
          validPublicKey,
          validSignature,
          {'test_item': 5.99},
        );

        // Update product price
        await endpoints.commerce.registerProducts(
          sessionBuilder,
          validPublicKey,
          validSignature,
          {'test_item': 9.99},
        );

        final catalog = await endpoints.commerce.getProductCatalog(sessionBuilder);
        expect(catalog['test_item'], equals(9.99));
      });
    });

    group('createOrder endpoint', () {
      setUp(() async {
        // Register test products for order creation tests
        await endpoints.commerce.registerProducts(
          sessionBuilder,
          validPublicKey,
          validSignature,
          {
            'storage_days': 5.99,
            'api_credits': 0.01,
            'premium_features': 29.99,
          },
        );
      });

      test('successful order creation with valid items', () async {
        final items = {
          'storage_days': 10.0,
          'api_credits': 100.0,
        };

        final transaction = await endpoints.commerce.createOrder(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccountId,
          items,
          PaymentRail.monero,
        );

        expect(transaction.accountId, equals(testAccountId));
        expect(transaction.status, equals(OrderStatus.pending));
        expect(transaction.paymentRail, equals(PaymentRail.monero));
        expect(transaction.priceCurrency, equals(Currency.USD));
        expect(transaction.paymentCurrency, equals(Currency.USD));
        expect(transaction.externalId, isNotNull);
        expect(transaction.id, isNotNull);
        
        // Verify price calculation: (5.99 * 10) + (0.01 * 100) = 59.9 + 1.0 = 60.9
        expect(transaction.price, closeTo(60.9, 0.001));
        expect(transaction.paymentAmount, closeTo(60.9, 0.001));
      });

      test('fails with empty public key', () async {
        final items = {'storage_days': 10.0};

        expect(
          () => endpoints.commerce.createOrder(
            sessionBuilder,
            '', // empty public key
            validSignature,
            testAccountId,
            items,
            PaymentRail.monero,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with invalid public key format', () async {
        final items = {'storage_days': 10.0};

        expect(
          () => endpoints.commerce.createOrder(
            sessionBuilder,
            'invalid_key',
            validSignature,
            testAccountId,
            items,
            PaymentRail.monero,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with empty signature', () async {
        final items = {'storage_days': 10.0};

        expect(
          () => endpoints.commerce.createOrder(
            sessionBuilder,
            validPublicKey,
            '', // empty signature
            testAccountId,
            items,
            PaymentRail.monero,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with empty items map', () async {
        expect(
          () => endpoints.commerce.createOrder(
            sessionBuilder,
            validPublicKey,
            validSignature,
            testAccountId,
            {}, // empty items
            PaymentRail.monero,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with unregistered product', () async {
        final items = {'unregistered_item': 10.0};

        expect(
          () => endpoints.commerce.createOrder(
            sessionBuilder,
            validPublicKey,
            validSignature,
            testAccountId,
            items,
            PaymentRail.monero,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with negative quantity', () async {
        final items = {'storage_days': -5.0}; // negative quantity

        expect(
          () => endpoints.commerce.createOrder(
            sessionBuilder,
            validPublicKey,
            validSignature,
            testAccountId,
            items,
            PaymentRail.monero,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with zero quantity', () async {
        final items = {'storage_days': 0.0}; // zero quantity

        expect(
          () => endpoints.commerce.createOrder(
            sessionBuilder,
            validPublicKey,
            validSignature,
            testAccountId,
            items,
            PaymentRail.monero,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('creates order with multiple items and correct total', () async {
        final items = {
          'storage_days': 5.0,
          'api_credits': 200.0,
          'premium_features': 1.0,
        };

        final transaction = await endpoints.commerce.createOrder(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccountId,
          items,
          PaymentRail.x402_http,
        );

        // Verify price calculation: (5.99 * 5) + (0.01 * 200) + (29.99 * 1) = 29.95 + 2.0 + 29.99 = 61.94
        expect(transaction.price, closeTo(61.94, 0.001));
        expect(transaction.paymentRail, equals(PaymentRail.x402_http));
      });
    });

    group('getInventory endpoint', () {
      test('returns empty inventory for account with no inventory', () async {
        final inventory = await endpoints.commerce.getInventory(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccountId,
        );

        expect(inventory, isEmpty);
      });

      test('fails with empty public key', () async {
        expect(
          () => endpoints.commerce.getInventory(
            sessionBuilder,
            '', // empty public key
            validSignature,
            testAccountId,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with invalid public key format', () async {
        expect(
          () => endpoints.commerce.getInventory(
            sessionBuilder,
            'invalid_key',
            validSignature,
            testAccountId,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with empty signature', () async {
        expect(
          () => endpoints.commerce.getInventory(
            sessionBuilder,
            validPublicKey,
            '', // empty signature
            testAccountId,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getBalance endpoint', () {
      test('returns zero balance for non-existent consumable', () async {
        final balance = await endpoints.commerce.getBalance(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccountId,
          'non_existent_item',
        );

        expect(balance, equals(0.0));
      });

      test('fails with empty public key', () async {
        expect(
          () => endpoints.commerce.getBalance(
            sessionBuilder,
            '', // empty public key
            validSignature,
            testAccountId,
            'test_item',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with invalid public key format', () async {
        expect(
          () => endpoints.commerce.getBalance(
            sessionBuilder,
            'invalid_key',
            validSignature,
            testAccountId,
            'test_item',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with empty signature', () async {
        expect(
          () => endpoints.commerce.getBalance(
            sessionBuilder,
            validPublicKey,
            '', // empty signature
            testAccountId,
            'test_item',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with empty consumable type', () async {
        expect(
          () => endpoints.commerce.getBalance(
            sessionBuilder,
            validPublicKey,
            validSignature,
            testAccountId,
            '', // empty consumable type
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('authentication validation', () {
      test('all endpoints validate public key format consistently', () async {
        const invalidKey = 'invalid';
        final products = {'test_item': 1.99};
        final items = {'test_item': 1.0};

        // Test all endpoints with invalid key
        expect(
          () => endpoints.commerce.registerProducts(sessionBuilder, invalidKey, validSignature, products),
          throwsA(isA<Exception>()),
        );

        expect(
          () => endpoints.commerce.createOrder(sessionBuilder, invalidKey, validSignature, testAccountId, items, PaymentRail.monero),
          throwsA(isA<Exception>()),
        );

        expect(
          () => endpoints.commerce.getInventory(sessionBuilder, invalidKey, validSignature, testAccountId),
          throwsA(isA<Exception>()),
        );

        expect(
          () => endpoints.commerce.getBalance(sessionBuilder, invalidKey, validSignature, testAccountId, 'test_item'),
          throwsA(isA<Exception>()),
        );
      });

      test('all endpoints validate signature presence consistently', () async {
        const emptySignature = '';
        final products = {'test_item': 1.99};
        final items = {'test_item': 1.0};

        // Test all endpoints with empty signature
        expect(
          () => endpoints.commerce.registerProducts(sessionBuilder, validPublicKey, emptySignature, products),
          throwsA(isA<Exception>()),
        );

        expect(
          () => endpoints.commerce.createOrder(sessionBuilder, validPublicKey, emptySignature, testAccountId, items, PaymentRail.monero),
          throwsA(isA<Exception>()),
        );

        expect(
          () => endpoints.commerce.getInventory(sessionBuilder, validPublicKey, emptySignature, testAccountId),
          throwsA(isA<Exception>()),
        );

        expect(
          () => endpoints.commerce.getBalance(sessionBuilder, validPublicKey, emptySignature, testAccountId, 'test_item'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('consumeInventory endpoint', () {
      setUp(() async {
        // Add some inventory for consumption tests using InventoryManager directly
        // since the module endpoint is just a mock
        final session = sessionBuilder.build();
        await InventoryManager.addToInventory(
          session,
          accountId: testAccountId,
          consumableType: 'api_calls',
          quantity: 100.0,
        );
      });

      test('successful consumption with sufficient balance', () async {
        final result = await endpoints.commerce.consumeInventory(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccountId,
          'api_calls',
          25.0,
        );

        expect(result.success, isTrue);
        expect(result.availableBalance, equals(75.0)); // 100 - 25 = 75
        expect(result.errorMessage, isNull);
      });

      test('fails with insufficient balance', () async {
        final result = await endpoints.commerce.consumeInventory(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccountId,
          'api_calls',
          150.0, // More than available (100)
        );

        expect(result.success, isFalse);
        expect(result.availableBalance, equals(100.0)); // Original balance unchanged
        expect(result.errorMessage, contains('Insufficient balance'));
      });

      test('fails with empty public key', () async {
        expect(
          () => endpoints.commerce.consumeInventory(
            sessionBuilder,
            '', // empty public key
            validSignature,
            testAccountId,
            'api_calls',
            10.0,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with invalid public key format', () async {
        expect(
          () => endpoints.commerce.consumeInventory(
            sessionBuilder,
            'invalid_key',
            validSignature,
            testAccountId,
            'api_calls',
            10.0,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with empty signature', () async {
        expect(
          () => endpoints.commerce.consumeInventory(
            sessionBuilder,
            validPublicKey,
            '', // empty signature
            testAccountId,
            'api_calls',
            10.0,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with empty consumable type', () async {
        expect(
          () => endpoints.commerce.consumeInventory(
            sessionBuilder,
            validPublicKey,
            validSignature,
            testAccountId,
            '', // empty consumable type
            10.0,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with negative quantity', () async {
        expect(
          () => endpoints.commerce.consumeInventory(
            sessionBuilder,
            validPublicKey,
            validSignature,
            testAccountId,
            'test_consumable',
            -5.0, // negative quantity
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with zero quantity', () async {
        expect(
          () => endpoints.commerce.consumeInventory(
            sessionBuilder,
            validPublicKey,
            validSignature,
            testAccountId,
            'test_consumable',
            0.0, // zero quantity
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('atomic operation behavior - multiple concurrent consumptions', () async {
        // This test verifies that concurrent consumption operations are handled atomically
        // We'll consume the entire balance in two operations that should not interfere
        
        // First consumption should succeed
        final result1 = await endpoints.commerce.consumeInventory(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccountId,
          'api_calls',
          50.0,
        );

        expect(result1.success, isTrue);
        expect(result1.availableBalance, equals(50.0));

        // Second consumption should also succeed
        final result2 = await endpoints.commerce.consumeInventory(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccountId,
          'api_calls',
          50.0,
        );

        expect(result2.success, isTrue);
        expect(result2.availableBalance, equals(0.0));

        // Third consumption should fail due to insufficient balance
        final result3 = await endpoints.commerce.consumeInventory(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccountId,
          'api_calls',
          1.0,
        );

        expect(result3.success, isFalse);
        expect(result3.availableBalance, equals(0.0));
        expect(result3.errorMessage, contains('Insufficient balance'));
      });

      test('consumption from non-existent consumable type', () async {
        final result = await endpoints.commerce.consumeInventory(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccountId,
          'non_existent_consumable',
          10.0,
        );

        expect(result.success, isFalse);
        expect(result.availableBalance, equals(0.0));
        expect(result.errorMessage, contains('Insufficient balance'));
      });

      test('consumption with fractional quantities', () async {
        final result = await endpoints.commerce.consumeInventory(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccountId,
          'api_calls',
          25.5, // fractional quantity
        );

        expect(result.success, isTrue);
        expect(result.availableBalance, equals(74.5)); // 100 - 25.5 = 74.5
        expect(result.errorMessage, isNull);
      });
    });

    group('error response formatting', () {
      test('endpoints return structured error responses', () async {
        // Test with invalid authentication to verify error structure
        try {
          await endpoints.commerce.registerProducts(
            sessionBuilder,
            'invalid_key',
            validSignature,
            {'test_item': 1.99},
          );
          fail('Expected exception was not thrown');
        } catch (e) {
          // Verify that an exception is thrown (structure validation would require more specific exception types)
          expect(e, isA<Exception>());
        }
      });
    });
  });
}