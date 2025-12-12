import 'dart:math';
import 'package:test/test.dart';
import 'package:anonaccred_server/anonaccred_server.dart';

/// **Feature: anonaccred-phase3, Property 1: Price Registry Consistency**
/// **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5**

void main() {
  group('Price Registry Property Tests', () {
    final random = Random();

    setUp(() {
      // Clear registry before each test to ensure clean state
      PriceRegistry().clearRegistry();
    });

    test('Property 1: Price Registry Consistency - For any product registration operation, the price registry should correctly store, update, and retrieve product definitions with accurate pricing information', () {
      // Run 5 iterations during development (can be increased to 100+ for production)
      for (int i = 0; i < 5; i++) {
        final registry = PriceRegistry();
        
        // Generate random test data
        final sku = _generateRandomSku();
        final priceUSD = _generateRandomPrice();
        
        // Test initial state - product should not exist
        expect(registry.getPrice(sku), isNull);
        expect(registry.getAvailableProducts(), isNot(contains(sku)));
        
        // Register product (Requirement 1.1)
        registry.registerProduct(sku, priceUSD);
        
        // Verify product is stored correctly (Requirement 1.4)
        expect(registry.getPrice(sku), equals(priceUSD));
        expect(registry.getAvailableProducts(), contains(sku));
        
        // Verify product appears in catalog (Requirement 1.2)
        final catalog = registry.getProductCatalog();
        expect(catalog, containsPair(sku, priceUSD));
        
        // Test price update (Requirement 1.3)
        final newPrice = _generateRandomPrice();
        registry.registerProduct(sku, newPrice);
        
        // Verify price was updated
        expect(registry.getPrice(sku), equals(newPrice));
        expect(registry.getProductCatalog()[sku], equals(newPrice));
        
        // Test multiple products
        final additionalProducts = <String, double>{};
        for (int j = 0; j < 3; j++) {
          final additionalSku = _generateRandomSku();
          final additionalPrice = _generateRandomPrice();
          additionalProducts[additionalSku] = additionalPrice;
          registry.registerProduct(additionalSku, additionalPrice);
        }
        
        // Verify all products are stored correctly
        for (final entry in additionalProducts.entries) {
          expect(registry.getPrice(entry.key), equals(entry.value));
          expect(registry.getAvailableProducts(), contains(entry.key));
        }
        
        // Verify catalog contains all products
        final fullCatalog = registry.getProductCatalog();
        expect(fullCatalog[sku], equals(newPrice));
        for (final entry in additionalProducts.entries) {
          expect(fullCatalog, containsPair(entry.key, entry.value));
        }
        
        // Test unregistered product returns null (Requirement 1.5)
        final unregisteredSku = _generateRandomSku();
        expect(registry.getPrice(unregisteredSku), isNull);
        expect(registry.getAvailableProducts(), isNot(contains(unregisteredSku)));
        
        // Clear for next iteration
        registry.clearRegistry();
      }
    });

    test('Property 1 Extension: Singleton behavior consistency', () {
      // Test that multiple instances return the same singleton
      final registry1 = PriceRegistry();
      final registry2 = PriceRegistry();
      
      expect(identical(registry1, registry2), isTrue);
      
      // Test that changes through one instance are visible through another
      final sku = _generateRandomSku();
      final price = _generateRandomPrice();
      
      registry1.registerProduct(sku, price);
      expect(registry2.getPrice(sku), equals(price));
      
      registry2.clearRegistry();
      expect(registry1.getAvailableProducts(), isEmpty);
    });

    test('Property 1 Extension: Catalog immutability', () {
      final registry = PriceRegistry();
      final sku = _generateRandomSku();
      final price = _generateRandomPrice();
      
      registry.registerProduct(sku, price);
      
      // Get catalog and try to modify it
      final catalog = registry.getProductCatalog();
      catalog['malicious_sku'] = 999.99;
      
      // Verify original registry is not affected
      expect(registry.getPrice('malicious_sku'), isNull);
      expect(registry.getAvailableProducts(), isNot(contains('malicious_sku')));
      
      // Verify original product is still there
      expect(registry.getPrice(sku), equals(price));
    });
  });
}

// Test data generators
String _generateRandomSku() {
  final random = Random();
  const prefixes = ['storage', 'api', 'compute', 'bandwidth', 'credits'];
  const suffixes = ['days', 'calls', 'hours', 'gb', 'units'];
  
  final prefix = prefixes[random.nextInt(prefixes.length)];
  final suffix = suffixes[random.nextInt(suffixes.length)];
  final number = random.nextInt(1000);
  
  return '${prefix}_${suffix}_$number';
}

double _generateRandomPrice() {
  final random = Random();
  // Generate prices between 0.01 and 999.99
  return (random.nextDouble() * 999.98) + 0.01;
}