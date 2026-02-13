import 'dart:convert';
import 'dart:io';
import 'exception_factory.dart';

/// Represents a mapping from an Apple product ID to a consumable type and quantity.
class AppleProductMapping {
  final String consumableType;
  final double quantity;

  AppleProductMapping({
    required this.consumableType,
    required this.quantity,
  });

  factory AppleProductMapping.fromJson(Map<String, dynamic> json) {
    return AppleProductMapping(
      consumableType: json['type'] as String,
      quantity: (json['quantity'] as num).toDouble(),
    );
  }
}

/// Configuration for mapping Apple product IDs to consumable types.
/// Loads mappings from APPLE_PRODUCT_MAPPINGS environment variable.
/// Environment variable format: APPLE_PRODUCT_MAPPINGS={"com.app.coins_100": {"type": "coins", "quantity": 100}}
class AppleProductMappingConfig {
  static final Map<String, AppleProductMapping> _mappings = {};
  static bool _initialized = false;

  /// Load product mappings from environment variable.
  /// Environment variable format: APPLE_PRODUCT_MAPPINGS={"com.app.coins_100": {"type": "coins", "quantity": 100}}
  static void loadMappings() {
    if (_initialized) {
      return;
    }

    final mappingsJson = Platform.environment['APPLE_PRODUCT_MAPPINGS'];
    if (mappingsJson != null && mappingsJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(mappingsJson) as Map<String, dynamic>;
        decoded.forEach((productId, mapping) {
          _mappings[productId] =
              AppleProductMapping.fromJson(mapping as Map<String, dynamic>);
        });
      } catch (e) {
        throw AnonAccredExceptionFactory.createException(
          code: AnonAccredErrorCodes.configurationMissing,
          message: 'Failed to parse APPLE_PRODUCT_MAPPINGS: $e',
        );
      }
    }

    _initialized = true;
  }

  /// Set mappings directly (for testing purposes).
  /// This allows setting mappings without relying on environment variables.
  static void setMappings(Map<String, AppleProductMapping> mappings) {
    _mappings.clear();
    _mappings.addAll(mappings);
    _initialized = true;
  }

  /// Get consumable type and quantity for product ID.
  static AppleProductMapping? getMapping(String productId) {
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
  static Map<String, AppleProductMapping> getAllMappings() {
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