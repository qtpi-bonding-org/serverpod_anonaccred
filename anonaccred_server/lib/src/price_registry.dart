/// Price Registry for AnonAccred Commerce Foundation
/// 
/// Provides a singleton service for managing product definitions and pricing.
/// This registry allows parent applications to define custom products with prices
/// and provides catalog and query operations for the commerce system.
library;

import 'exception_factory.dart';

/// Singleton service that manages product definitions and pricing
class PriceRegistry {
  /// Factory constructor that returns the singleton instance
  factory PriceRegistry() => _instance;
  
  /// Private constructor for singleton pattern
  PriceRegistry._internal();
  
  static final PriceRegistry _instance = PriceRegistry._internal();
  
  /// Internal storage for product prices in USD
  final Map<String, double> _pricesUSD = {};
  
  /// Registers a product with its price in USD
  /// 
  /// If a product with the same [sku] already exists, updates the existing price.
  /// 
  /// Parameters:
  /// - [sku]: The consumable type identifier (e.g., "storage_days", "api_credits")
  /// - [priceUSD]: The price in USD for this product
  /// 
  /// Throws:
  /// - [PaymentException] if SKU is empty or price is invalid
  void registerProduct(String sku, double priceUSD) {
    // Validate SKU
    if (sku.isEmpty) {
      throw AnonAccredExceptionFactory.createPriceRegistryException(
        code: AnonAccredErrorCodes.priceRegistryInvalidSku,
        message: 'Product SKU cannot be empty',
        sku: sku,
        details: {'providedSku': 'empty'},
      );
    }
    
    // Validate price
    if (priceUSD <= 0 || !priceUSD.isFinite) {
      throw AnonAccredExceptionFactory.createPriceRegistryException(
        code: AnonAccredErrorCodes.priceRegistryInvalidPrice,
        message: 'Product price must be a positive finite number',
        sku: sku,
        details: {
          'providedPrice': priceUSD.toString(),
          'minimumPrice': '0.01',
        },
      );
    }
    
    try {
      _pricesUSD[sku] = priceUSD;
    } catch (e) {
      throw AnonAccredExceptionFactory.createPriceRegistryException(
        code: AnonAccredErrorCodes.priceRegistryOperationFailed,
        message: 'Failed to register product: ${e.toString()}',
        sku: sku,
        details: {'error': e.toString()},
      );
    }
  }
  
  /// Gets the current price for a registered product
  /// 
  /// Returns the USD price for the given [sku], or null if the product
  /// is not registered.
  /// 
  /// Parameters:
  /// - [sku]: The consumable type identifier to look up
  /// 
  /// Returns: The USD price or null if not found
  double? getPrice(String sku) => _pricesUSD[sku];
  
  /// Gets a list of all available product SKUs
  /// 
  /// Returns: List of all registered product identifiers
  List<String> getAvailableProducts() => _pricesUSD.keys.toList();
  
  /// Gets the complete product catalog with prices
  /// 
  /// Returns: Map of all products with their SKUs as keys and USD prices as values
  Map<String, double> getProductCatalog() => Map<String, double>.from(_pricesUSD);
  
  /// Clears all registered products from the registry
  /// 
  /// This method is primarily intended for testing purposes to reset
  /// the registry state between tests.
  void clearRegistry() {
    _pricesUSD.clear();
  }
}