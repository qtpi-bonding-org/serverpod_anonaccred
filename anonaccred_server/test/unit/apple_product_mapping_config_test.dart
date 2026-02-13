import 'package:test/test.dart';
import 'package:anonaccred_server/src/apple_product_mapping_config.dart';
import 'package:anonaccred_server/src/exception_factory.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';

/// Unit tests for Apple product mapping configuration
///
/// Tests product ID to consumable type mapping including:
/// - Loading mappings from configuration
/// - Retrieving mappings for valid product IDs
/// - Error handling for unmapped product IDs
/// - Configuration validation
void main() {
  group('AppleProductMappingConfig Tests', () {
    tearDown(() {
      // Clean up static state after each test
      AppleProductMappingConfig.clearMappings();
    });

    test('getMapping returns null for unmapped product ID', () {
      // Test that unmapped product IDs return null
      final mapping = AppleProductMappingConfig.getMapping('com.unknown.product');

      expect(mapping, isNull);
    });

    test('getMapping returns mapping for valid product ID', () {
      // Test happy path: valid product ID returns correct mapping
      AppleProductMappingConfig.setMappings({
        'com.app.coins_100': AppleProductMapping(
          consumableType: 'coins',
          quantity: 100,
        ),
      });

      final mapping = AppleProductMappingConfig.getMapping('com.app.coins_100');

      expect(mapping, isNotNull);
      expect(mapping!.consumableType, equals('coins'));
      expect(mapping.quantity, equals(100.0));
    });

    test('getMapping returns correct quantity for different products', () {
      // Test multiple product mappings
      AppleProductMappingConfig.setMappings({
        'com.app.coins_100': AppleProductMapping(
          consumableType: 'coins',
          quantity: 100,
        ),
        'com.app.gems_50': AppleProductMapping(
          consumableType: 'gems',
          quantity: 50,
        ),
        'com.app.energy_25': AppleProductMapping(
          consumableType: 'energy',
          quantity: 25,
        ),
      });

      expect(
        AppleProductMappingConfig.getMapping('com.app.coins_100'),
        isA<AppleProductMapping>()
            .having((m) => m.consumableType, 'consumableType', 'coins')
            .having((m) => m.quantity, 'quantity', 100.0),
      );
      expect(
        AppleProductMappingConfig.getMapping('com.app.gems_50'),
        isA<AppleProductMapping>()
            .having((m) => m.consumableType, 'consumableType', 'gems')
            .having((m) => m.quantity, 'quantity', 50.0),
      );
      expect(
        AppleProductMappingConfig.getMapping('com.app.energy_25'),
        isA<AppleProductMapping>()
            .having((m) => m.consumableType, 'consumableType', 'energy')
            .having((m) => m.quantity, 'quantity', 25.0),
      );
    });

    test('validateProductId throws for unmapped product', () {
      // Test error handling for unmapped product ID
      AppleProductMappingConfig.clearMappings();

      expect(
        () => AppleProductMappingConfig.validateProductId('com.unknown.product'),
        throwsA(isA<AnonAccredException>()),
      );
    });

    test('validateProductId throws with correct error code', () {
      // Test that exception has correct error code
      try {
        AppleProductMappingConfig.validateProductId('com.unknown.product');
        fail('Expected exception to be thrown');
      } on AnonAccredException catch (e) {
        expect(e.code, equals(AnonAccredErrorCodes.configurationMissing));
      }
    });

    test('validateProductId throws with product ID in details', () {
      // Test that exception includes product ID in details
      try {
        AppleProductMappingConfig.validateProductId('com.unknown.product');
        fail('Expected exception to be thrown');
      } on AnonAccredException catch (e) {
        expect(e.details, contains('productId'));
        expect(e.details!['productId'], equals('com.unknown.product'));
      }
    });

    test('validateProductId succeeds for mapped product', () {
      // Test that valid product ID passes validation
      AppleProductMappingConfig.setMappings({
        'com.app.coins_100': AppleProductMapping(
          consumableType: 'coins',
          quantity: 100,
        ),
      });

      // Should not throw
      expect(
        () => AppleProductMappingConfig.validateProductId('com.app.coins_100'),
        returnsNormally,
      );
    });

    test('getAllMappings returns all loaded mappings', () {
      // Test retrieving all loaded mappings
      AppleProductMappingConfig.setMappings({
        'com.app.coins_100': AppleProductMapping(
          consumableType: 'coins',
          quantity: 100,
        ),
        'com.app.gems_50': AppleProductMapping(
          consumableType: 'gems',
          quantity: 50,
        ),
      });

      final allMappings = AppleProductMappingConfig.getAllMappings();

      expect(allMappings.length, equals(2));
      expect(allMappings.containsKey('com.app.coins_100'), isTrue);
      expect(allMappings.containsKey('com.app.gems_50'), isTrue);
    });

    test('clearMappings removes all mappings', () {
      // Test clearing all mappings
      AppleProductMappingConfig.setMappings({
        'com.app.coins_100': AppleProductMapping(
          consumableType: 'coins',
          quantity: 100,
        ),
      });

      final beforeClear = AppleProductMappingConfig.getAllMappings();
      expect(beforeClear.length, equals(1));

      AppleProductMappingConfig.clearMappings();
      final afterClear = AppleProductMappingConfig.getAllMappings();
      expect(afterClear.isEmpty, isTrue);
    });
  });

  group('AppleProductMapping Tests', () {
    test('fromJson parses valid JSON', () {
      // Test parsing of valid JSON structure
      final json = {'type': 'coins', 'quantity': 100};
      final mapping = AppleProductMapping.fromJson(json);

      expect(mapping.consumableType, equals('coins'));
      expect(mapping.quantity, equals(100.0));
    });

    test('fromJson handles integer quantity', () {
      // Test that integer quantities are converted to double
      final json = {'type': 'gems', 'quantity': 50};
      final mapping = AppleProductMapping.fromJson(json);

      expect(mapping.quantity, isA<double>());
      expect(mapping.quantity, equals(50.0));
    });

    test('fromJson handles decimal quantity', () {
      // Test that decimal quantities are preserved
      final json = {'type': 'premium', 'quantity': 99.99};
      final mapping = AppleProductMapping.fromJson(json);

      expect(mapping.quantity, equals(99.99));
    });
  });
}