import 'dart:convert';
import 'dart:io';
import 'exception_factory.dart';
import 'generated/protocol.dart';

/// Represents a mapping from a Google product ID to a consumable type and quantity.
class ProductMapping {
  final String consumableType;
  final double quantity;
  final bool autoConsume;

  ProductMapping({
    required this.consumableType,
    required this.quantity,
    this.autoConsume = true,
  });

  factory ProductMapping.fromJson(Map<String, dynamic> json) {
    return ProductMapping(
      consumableType: json['type'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      autoConsume: json['auto_consume'] as bool? ?? true,
    );
  }
}

/// Configuration for mapping Google product IDs to consumable types.
/// Loads mappings from environment variables or configuration files.
class ProductMappingConfig {
  static final Map<String, ProductMapping> _mappings = {};
  static bool _initialized = false;

  /// Load product mappings from environment or config file.
  /// Environment variable format: GOOGLE_PRODUCT_MAPPINGS={"com.app.coins_100": {"type": "coins", "quantity": 100}}
  static void loadMappings() {
    if (_initialized) {
      return;
    }

    final mappingsJson = Platform.environment['GOOGLE_PRODUCT_MAPPINGS'];
    if (mappingsJson != null && mappingsJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(mappingsJson) as Map<String, dynamic>;
        decoded.forEach((productId, mapping) {
          _mappings[productId] = ProductMapping.fromJson(mapping as Map<String, dynamic>);
        });
      } catch (e) {
        throw AnonAccredExceptionFactory.createException(
          code: AnonAccredErrorCodes.configurationMissing,
          message: 'Failed to parse GOOGLE_PRODUCT_MAPPINGS: $e',
        );
      }
    }

    _initialized = true;
  }

  /// Get consumable type and quantity for product ID.
  static ProductMapping? getMapping(String productId) {
    if (!_initialized) {
      loadMappings();
    }
    return _mappings[productId];
  }

  /// Validate that a product ID has a mapping.
  static void validateProductId(String productId) {
    if (!_initialized) {
      loadMappings();
    }
    if (!_mappings.containsKey(productId)) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.configurationMissing,
        message: 'No product mapping found for product ID: $productId',
        details: {'productId': productId},
      );
    }
  }

  /// Get all loaded mappings (for testing/debugging).
  static Map<String, ProductMapping> getAllMappings() {
    if (!_initialized) {
      loadMappings();
    }
    return Map.unmodifiable(_mappings);
  }

  /// Clear all mappings (for testing).
  static void clearMappings() {
    _mappings.clear();
    _initialized = false;
  }
}
