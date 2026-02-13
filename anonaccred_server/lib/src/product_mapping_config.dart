import 'dart:convert';
import 'dart:io';
import 'exception_factory.dart';

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

/// Configuration for mapping product IDs to consumable types.
/// Supports both Google and Apple product mappings.
/// Loads mappings from environment variables or configuration files.
class ProductMappingConfig {
  static final Map<String, ProductMapping> _googleMappings = {};
  static final Map<String, ProductMapping> _appleMappings = {};
  static bool _initialized = false;

  /// Load product mappings from environment or config file.
  /// Environment variable formats:
  /// - GOOGLE_PRODUCT_MAPPINGS={"com.app.coins_100": {"type": "coins", "quantity": 100}}
  /// - APPLE_PRODUCT_MAPPINGS={"com.app.coins_100": {"type": "coins", "quantity": 100}}
  static void loadMappings() {
    if (_initialized) {
      return;
    }

    // Load Google mappings
    final googleMappingsJson = Platform.environment['GOOGLE_PRODUCT_MAPPINGS'];
    if (googleMappingsJson != null && googleMappingsJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(googleMappingsJson) as Map<String, dynamic>;
        decoded.forEach((productId, mapping) {
          _googleMappings[productId] = ProductMapping.fromJson(mapping as Map<String, dynamic>);
        });
      } catch (e) {
        throw AnonAccredExceptionFactory.createException(
          code: AnonAccredErrorCodes.configurationMissing,
          message: 'Failed to parse GOOGLE_PRODUCT_MAPPINGS: $e',
        );
      }
    }

    // Load Apple mappings
    final appleMappingsJson = Platform.environment['APPLE_PRODUCT_MAPPINGS'];
    if (appleMappingsJson != null && appleMappingsJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(appleMappingsJson) as Map<String, dynamic>;
        decoded.forEach((productId, mapping) {
          _appleMappings[productId] = ProductMapping.fromJson(mapping as Map<String, dynamic>);
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

  /// Get consumable type and quantity for Google product ID.
  static ProductMapping? getMapping(String productId) {
    if (!_initialized) {
      loadMappings();
    }
    return _googleMappings[productId];
  }

  /// Get consumable type and quantity for Apple product ID.
  static ProductMapping? getAppleMapping(String productId) {
    if (!_initialized) {
      loadMappings();
    }
    return _appleMappings[productId];
  }

  /// Validate that a Google product ID has a mapping.
  static void validateProductId(String productId) {
    if (!_initialized) {
      loadMappings();
    }
    if (!_googleMappings.containsKey(productId)) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.configurationMissing,
        message: 'No product mapping found for Google product ID: $productId',
        details: {'productId': productId},
      );
    }
  }

  /// Validate that an Apple product ID has a mapping.
  static void validateAppleProductId(String productId) {
    if (!_initialized) {
      loadMappings();
    }
    if (!_appleMappings.containsKey(productId)) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.configurationMissing,
        message: 'No product mapping found for Apple product ID: $productId',
        details: {'productId': productId},
      );
    }
  }

  /// Get all loaded Google mappings (for testing/debugging).
  static Map<String, ProductMapping> getAllMappings() {
    if (!_initialized) {
      loadMappings();
    }
    return Map.unmodifiable(_googleMappings);
  }

  /// Get all loaded Apple mappings (for testing/debugging).
  static Map<String, ProductMapping> getAllAppleMappings() {
    if (!_initialized) {
      loadMappings();
    }
    return Map.unmodifiable(_appleMappings);
  }

  /// Clear all mappings (for testing).
  static void clearMappings() {
    _googleMappings.clear();
    _appleMappings.clear();
    _initialized = false;
  }
}
