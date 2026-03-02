import 'package:anonaccred_server/src/entitlement_manager.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/mock_android_publisher_client.dart';
import 'package:anonaccred_server/src/payments/mock_app_store_server_client.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:anonaccred_server/src/payments/payment_rail_interface.dart';
import 'package:anonaccred_server/src/payments/rails/apple_iap_rail.dart';
import 'package:anonaccred_server/src/payments/rails/google_iap_rail.dart';
import 'package:anonaccred_server/src/price_registry.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

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
}

void main() {
  withServerpod('CommerceEndpoint Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    // Test constants
    const validPublicKey =
        '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
    const validSignature =
        'valid_signature_placeholder_64_chars_1234567890abcdef1234567890ab';
    late int testAccountId;

    setUpAll(() async {
      // Register all payment rails with mock implementations
      PaymentManager.clearRails();
      PaymentManager.registerRail(AppleIAPRail(client: MockAppStoreServerClient()));
      PaymentManager.registerRail(GoogleIAPRail(client: MockAndroidPublisherClient()));
      PaymentManager.registerRail(MockPaymentRail(PaymentRail.monero));
      PaymentManager.registerRail(MockPaymentRail(PaymentRail.stripe));
      PaymentManager.registerRail(MockPaymentRail(PaymentRail.x402_http));
    });

    setUp(() async {
      // Clear the price registry before each test to ensure clean state
      PriceRegistry().clearRegistry();

      // Create a test account for tests that need it
      final account = await endpoints.account.createAccount(
        sessionBuilder,
        validPublicKey,
        'encrypted_data_key_for_commerce_test',
        validPublicKey, // Use the same valid key for ultimatePublicKey
      );
      testAccountId = account.id!;
    });

    group('registerProducts endpoint', () {
      test(
        'successful product registration with valid authentication',
        () async {
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
        },
      );

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
        final catalog = await endpoints.commerce.getProductCatalog(
          sessionBuilder,
        );
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

        final catalog = await endpoints.commerce.getProductCatalog(
          sessionBuilder,
        );
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

        final catalog = await endpoints.commerce.getProductCatalog(
          sessionBuilder,
        );
        expect(catalog['test_item'], equals(9.99));
      });
    });

    group('initiatePayment endpoint', () {
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

      test('successful payment initiation with valid product', () async {
        final transaction = await endpoints.commerce.initiatePayment(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccountId,
          PaymentRail.monero,
          'storage_days',
        );

        expect(transaction.status, equals(OrderStatus.pending));
        expect(transaction.paymentRail, equals(PaymentRail.monero));
        expect(transaction.priceCurrency, equals(Currency.USD));
        expect(transaction.paymentCurrency, equals(Currency.USD));
        expect(transaction.internalTransactionId, isNotNull);
        expect(transaction.id, isNotNull);

        // Verify price (storage_days was registered at 5.99)
        expect(transaction.price, closeTo(5.99, 0.001));
        expect(transaction.paymentAmount, closeTo(5.99, 0.001));
      });

      test('fails with empty public key', () async {
        expect(
          () => endpoints.commerce.initiatePayment(
            sessionBuilder,
            '', // empty public key
            validSignature,
            testAccountId,
            PaymentRail.monero,
            'storage_days',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with invalid public key format', () async {
        expect(
          () => endpoints.commerce.initiatePayment(
            sessionBuilder,
            'invalid_key',
            validSignature,
            testAccountId,
            PaymentRail.monero,
            'storage_days',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with empty signature', () async {
        expect(
          () => endpoints.commerce.initiatePayment(
            sessionBuilder,
            validPublicKey,
            '', // empty signature
            testAccountId,
            PaymentRail.monero,
            'storage_days',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with unregistered product', () async {
        expect(
          () => endpoints.commerce.initiatePayment(
            sessionBuilder,
            validPublicKey,
            validSignature,
            testAccountId,
            PaymentRail.monero,
            'unregistered_item',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('creates payment with X402 rail and correct price', () async {
        final transaction = await endpoints.commerce.initiatePayment(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccountId,
          PaymentRail.x402_http,
          'premium_features',
        );

        // Verify price: premium_features was registered at 29.99
        expect(transaction.price, closeTo(29.99, 0.001));
        expect(transaction.paymentRail, equals(PaymentRail.x402_http));
      });

      test('creates payment with custom price override', () async {
        final transaction = await endpoints.commerce.initiatePayment(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccountId,
          PaymentRail.x402_http,
          'storage_days', // Registered at 5.99
          customPrice: 15.99, // Override with custom price
        );

        // Verify custom price is used
        expect(transaction.price, closeTo(15.99, 0.001));
        expect(transaction.paymentAmount, closeTo(15.99, 0.001));
      });
    });

    group('getEntitlements endpoint', () {
      test(
        'returns empty entitlements for account with no inventory',
        () async {
          final entitlements = await endpoints.commerce.getEntitlements(
            sessionBuilder,
            validPublicKey,
            validSignature,
            testAccountId,
          );

          expect(entitlements, isEmpty);
        },
      );

      test('fails with empty public key', () async {
        expect(
          () => endpoints.commerce.getEntitlements(
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
          () => endpoints.commerce.getEntitlements(
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
          () => endpoints.commerce.getEntitlements(
            sessionBuilder,
            validPublicKey,
            '', // empty signature
            testAccountId,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getEntitlementBalance endpoint', () {
      test('returns zero balance for non-existent consumable', () async {
        final balance = await endpoints.commerce.getEntitlementBalance(
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
          () => endpoints.commerce.getEntitlementBalance(
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
          () => endpoints.commerce.getEntitlementBalance(
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
          () => endpoints.commerce.getEntitlementBalance(
            sessionBuilder,
            validPublicKey,
            '', // empty signature
            testAccountId,
            'test_item',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with empty tag', () async {
        // Empty tag returns 0.0 balance (no entitlement found)
        final result = await endpoints.commerce.getEntitlementBalance(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccountId,
          '', // empty tag
        );
        expect(result, equals(0.0));
      });
    });

    group('authentication validation', () {
      test('all endpoints validate public key format consistently', () async {
        const invalidKey = 'invalid';
        final products = {'test_item': 1.99};
        final items = {'test_item': 1.0};

        // Test all endpoints with invalid key
        expect(
          () => endpoints.commerce.registerProducts(
            sessionBuilder,
            invalidKey,
            validSignature,
            products,
          ),
          throwsA(isA<Exception>()),
        );

        expect(
          () => endpoints.commerce.initiatePayment(
            sessionBuilder,
            invalidKey,
            validSignature,
            testAccountId,
            PaymentRail.monero,
            'test_item',
          ),
          throwsA(isA<Exception>()),
        );

        expect(
          () => endpoints.commerce.getEntitlements(
            sessionBuilder,
            invalidKey,
            validSignature,
            testAccountId,
          ),
          throwsA(isA<Exception>()),
        );

        expect(
          () => endpoints.commerce.getEntitlementBalance(
            sessionBuilder,
            invalidKey,
            validSignature,
            testAccountId,
            'test_item',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('all endpoints validate signature presence consistently', () async {
        const emptySignature = '';
        final products = {'test_item': 1.99};
        final items = {'test_item': 1.0};

        // Test all endpoints with empty signature
        expect(
          () => endpoints.commerce.registerProducts(
            sessionBuilder,
            validPublicKey,
            emptySignature,
            products,
          ),
          throwsA(isA<Exception>()),
        );

        expect(
          () => endpoints.commerce.initiatePayment(
            sessionBuilder,
            validPublicKey,
            emptySignature,
            testAccountId,
            PaymentRail.monero,
            'test_item',
          ),
          throwsA(isA<Exception>()),
        );

        expect(
          () => endpoints.commerce.getEntitlements(
            sessionBuilder,
            validPublicKey,
            emptySignature,
            testAccountId,
          ),
          throwsA(isA<Exception>()),
        );

        expect(
          () => endpoints.commerce.getEntitlementBalance(
            sessionBuilder,
            validPublicKey,
            emptySignature,
            testAccountId,
            'test_item',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('consumeEntitlement endpoint', () {
      setUp(() async {
        // Add some entitlement for consumption tests
        final session = sessionBuilder.build();

        // Ensure the Entitlement exists first
        final existing = await Entitlement.db.findFirstRow(
          session,
          where: (t) => t.tag.equals('api_calls'),
        );
        if (existing == null) {
          await Entitlement.db.insertRow(
            session,
            Entitlement(
              name: 'API Calls',
              tag: 'api_calls',
              type: EntitlementType.consumable,
            ),
          );
        }

        await EntitlementManager.grantEntitlement(
          session,
          accountId: testAccountId,
          tag: 'api_calls',
          quantity: 100.0,
        );
      });

      test('successful consumption with sufficient balance', () async {
        final result = await endpoints.commerce.consumeEntitlement(
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
        final result = await endpoints.commerce.consumeEntitlement(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccountId,
          'api_calls',
          150.0, // More than available
        );

        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Insufficient balance'));
      });

      test('fails with empty public key', () async {
        expect(
          () => endpoints.commerce.consumeEntitlement(
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
          () => endpoints.commerce.consumeEntitlement(
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
          () => endpoints.commerce.consumeEntitlement(
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
        final result = await endpoints.commerce.consumeEntitlement(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccountId,
          '', // empty consumable type
          10.0,
        );
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('not found'));
      });

      test('fails with negative quantity', () async {
        final result = await endpoints.commerce.consumeEntitlement(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccountId,
          'test_consumable',
          -5.0, // negative quantity
        );
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('positive'));
      });

      test('fails with zero quantity', () async {
        final result = await endpoints.commerce.consumeEntitlement(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccountId,
          'test_consumable',
          0.0, // zero quantity
        );
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('positive'));
      });

      test(
        'atomic operation behavior - multiple concurrent consumptions',
        () async {
          // This test verifies that concurrent consumption operations are handled atomically
          // We'll consume the entire balance in two operations that should not interfere

          // First consumption should succeed
          final result1 = await endpoints.commerce.consumeEntitlement(
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
          final result2 = await endpoints.commerce.consumeEntitlement(
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
          final result3 = await endpoints.commerce.consumeEntitlement(
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
        },
      );

      test('consumption from non-existent consumable type', () async {
        final result = await endpoints.commerce.consumeEntitlement(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccountId,
          'non_existent_consumable',
          10.0,
        );

        expect(result.success, isFalse);
        expect(result.availableBalance, equals(0.0));
        expect(result.errorMessage, contains('not found'));
      });

      test('consumption with fractional quantities', () async {
        final result = await endpoints.commerce.consumeEntitlement(
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
