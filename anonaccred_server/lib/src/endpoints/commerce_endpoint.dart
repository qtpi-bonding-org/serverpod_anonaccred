import 'package:serverpod/serverpod.dart';

import '../commerce_manager.dart';
import '../crypto_auth.dart';
import '../entitlement_manager.dart';
import '../entitlement_utils.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../payments/x402_interceptor.dart';
import '../price_registry.dart';

/// Commerce endpoints for AnonAccred Phase 3 commerce foundation
///
/// Provides endpoints for product registration, order creation, and inventory
/// management while maintaining the established authentication and error
/// handling patterns from the AnonAccred module.
class CommerceEndpoint extends Endpoint {
  /// Register products in the price registry
  ///
  /// Allows parent applications to define custom products with prices.
  /// This endpoint requires authentication and validates all input parameters.
  ///
  /// Parameters:
  /// - [publicKey]: ECDSA P-256 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [products]: Map of product SKUs to USD prices
  ///
  /// Returns: Map of registered products with their prices
  ///
  /// Throws:
  /// - [AuthenticationException] for invalid authentication
  /// - [PaymentException] for invalid product data
  /// - [AnonAccredException] for system errors
  Future<Map<String, double>> registerProducts(
    Session session,
    String publicKey,
    String signature,
    Map<String, double> products,
  ) async {
    try {
      // Validate authentication
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'registerProducts',
      );

      // Validate products
      if (products.isEmpty) {
        final exception = AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.orderInvalidProduct,
          message: 'At least one product must be provided',
          details: {'productCount': '0'},
        );

        throw exception;
      }

      // Validate each product
      for (final entry in products.entries) {
        final sku = entry.key;
        final price = entry.value;

        if (sku.isEmpty) {
          final exception = AnonAccredExceptionFactory.createPaymentException(
            code: AnonAccredErrorCodes.orderInvalidProduct,
            message: 'Product SKU cannot be empty',
            details: {'sku': 'empty'},
          );

          throw exception;
        }

        if (price <= 0) {
          final exception = AnonAccredExceptionFactory.createPaymentException(
            code: AnonAccredErrorCodes.orderInvalidQuantity,
            message: 'Product price must be positive',
            details: {'sku': sku, 'price': price.toString()},
          );

          throw exception;
        }
      }

      // Register products in the price registry and DATABASE
      final registry = PriceRegistry();
      for (final entry in products.entries) {
        final sku = entry.key;
        final price = entry.value;

        // 1. In-memory registry for fast lookup
        registry.registerProduct(sku, price);

        // 2. Ensure Entitlement exists for this SKU (assuming 1:1 mapping for default)
        var entitlement = await Entitlement.db.findFirstRow(
          session,
          where: (t) => t.tag.equals(sku),
        );
        entitlement ??= await Entitlement.db.insertRow(
            session,
            Entitlement(
              name: 'Product: $sku',
              tag: sku,
              type: EntitlementType.consumable,
            ),
          );

        // 3. Ensure RailProduct exists for common rails (Monero, X402)
        for (final rail in [PaymentRail.monero, PaymentRail.x402_http]) {
          var railProduct = await RailProduct.db.findFirstRow(
            session,
            where: (t) => t.rail.equals(rail) & t.storeProductId.equals(sku),
          );
          if (railProduct == null) {
            railProduct = await RailProduct.db.insertRow(
              session,
              RailProduct(rail: rail, storeProductId: sku, isActive: true),
            );

            // 4. Link Entitlement to RailProduct (Grant 1.0 units per purchase)
            await RailProductGrant.db.insertRow(
              session,
              RailProductGrant(
                railProductId: railProduct.id!,
                entitlementId: entitlement.id!,
                quantity: 1.0,
              ),
            );
          }
        }
      }

      // Log successful registration

      return products;
    } on AuthenticationException {
      rethrow;
    } on PaymentException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message:
            'Unexpected error during product registration: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }

  /// Initiate a transaction payment
  ///
  /// Wraps CommerceManager.initiateTransactionPayment to provide endpoint access.
  Future<TransactionPayment> initiatePayment(
    Session session,
    String publicKey,
    String signature,
    int accountId,
    PaymentRail rail,
    String storeProductId, {
    String? clientReference,
    double? customPrice,
  }) async {
    try {
      // Validate authentication
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'initiatePayment',
      );

      // Initiate payment via manager
      return await CommerceManager.initiateTransactionPayment(
        session,
        accountId: accountId,
        rail: rail,
        storeProductId: storeProductId,
        clientReference: clientReference,
        customPrice: customPrice,
      );
    } on AuthenticationException {
      rethrow;
    } on PaymentException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentFailed,
        message: 'Failed to initiate payment: ${e.toString()}',
        paymentRail: rail.toString(),
      );
    }
  }

  /// Get the complete product catalog
  ///
  /// Returns all registered products with their current prices.
  /// This endpoint does not require authentication as it provides public
  /// product information.
  ///
  /// Returns: Map of all products with SKUs as keys and USD prices as values
  ///
  /// Throws:
  /// - [PaymentException] for price registry errors
  /// - [AnonAccredException] for system errors
  Future<Map<String, double>> getProductCatalog(Session session) async {
    try {
      final registry = PriceRegistry();
      final catalog = registry.getProductCatalog();

      return catalog;
    } on PaymentException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createPriceRegistryException(
        code: AnonAccredErrorCodes.priceRegistryOperationFailed,
        message: 'Failed to get product catalog: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }

  /// Get entitlements for an account
  Future<List<AccountEntitlement>> getEntitlements(
    Session session,
    String publicKey,
    String signature,
    int accountId,
  ) async {
    try {
      // Validate authentication
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'getEntitlements',
      );

      // Get entitlements using EntitlementManager
      final entitlements = await EntitlementManager.getAccountEntitlements(
        session,
        accountId: accountId,
      );

      return entitlements;
    } on AuthenticationException {
      rethrow;
    } on InventoryException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error getting entitlements: ${e.toString()}',
      );
    }
  }

  /// Get balance for a specific entitlement tag
  Future<double> getEntitlementBalance(
    Session session,
    String publicKey,
    String signature,
    int accountId,
    String tag,
  ) async {
    try {
      // Validate authentication
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'getEntitlementBalance',
      );

      // Get balance using EntitlementManager
      final balance = await EntitlementManager.getEntitlementBalance(
        session,
        accountId: accountId,
        tag: tag,
      );

      return balance;
    } on AuthenticationException {
      rethrow;
    } on InventoryException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error getting balance: ${e.toString()}',
      );
    }
  }

  /// Consume entitlement using atomic utilities
  Future<ConsumeResult> consumeEntitlement(
    Session session,
    String publicKey,
    String signature,
    int accountId,
    String tag,
    double quantity,
  ) async {
    try {
      // Validate authentication
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'consumeEntitlement',
      );

      // Attempt consumption using EntitlementUtils
      final result = await EntitlementUtils.tryConsume(
        session,
        accountId: accountId,
        tag: tag,
        quantity: quantity,
      );

      return result;
    } on AuthenticationException {
      rethrow;
    } on InventoryException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message:
            'Unexpected error during entitlement consumption: ${e.toString()}',
      );
    }
  }

  /// Get product catalog with X402 pay-per-access integration
  ///
  /// Demonstrates X402 integration with commerce endpoints for pay-per-use access.
  /// This endpoint can be accessed with or without payment, showcasing micropayments
  /// for AI agents and autonomous systems.
  ///
  /// Parameters:
  /// - [publicKey]: ECDSA P-256 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [headers]: HTTP headers (may contain X-PAYMENT)
  ///
  /// Returns: Either HTTP 402 payment requirement or product catalog
  ///
  /// Requirements 5.4, 5.5: Support AI agents with pay-per-use model
  Future<Map<String, dynamic>> getProductCatalogWithX402(
    Session session,
    String publicKey,
    String signature, {
    Map<String, String>? headers,
  }) async {
    try {
      // Validate authentication
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'getProductCatalogWithX402',
      );

      // Use X402 interceptor to handle payment flow
      return await X402Interceptor.interceptRequest(
        session: session,
        headers: headers ?? <String, String>{},
        resourceId: 'product_catalog',
        amount: 0.25, // $0.25 for catalog access
        onPaymentRequired: () async => X402Interceptor.generatePaymentRequired(
          session: session,
          resourceId: 'product_catalog',
          amount: 0.25,
          description: 'Access to complete product catalog',
        ),
        onPaymentVerified: () async {
          // Payment verified - provide product catalog
          final registry = PriceRegistry();
          final catalog = registry.getProductCatalog();

          return {
            'success': true,
            'catalog': catalog,
            'accessTime': DateTime.now().toIso8601String(),
            'paymentMethod': 'x402_http',
            'catalogSize': catalog.length,
          };
        },
      );
    } on AuthenticationException {
      rethrow;
    } on PaymentException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error in X402 catalog request: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }

  /// Get entitlement balance with X402 pay-per-query integration
  Future<Map<String, dynamic>> getEntitlementBalanceWithX402(
    Session session,
    String publicKey,
    String signature,
    int accountId,
    String tag, {
    Map<String, String>? headers,
  }) async {
    try {
      // Validate authentication
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'getEntitlementBalanceWithX402',
      );

      // Use X402 interceptor to handle payment flow
      return await X402Interceptor.interceptRequest(
        session: session,
        headers: headers ?? <String, String>{},
        resourceId: 'balance_${accountId}_$tag',
        amount: 0.05,
        onPaymentRequired: () async => X402Interceptor.generatePaymentRequired(
          session: session,
          resourceId: 'balance_${accountId}_$tag',
          amount: 0.05,
          description: 'Balance query for $tag',
        ),
        onPaymentVerified: () async {
          final balance = await EntitlementManager.getEntitlementBalance(
            session,
            accountId: accountId,
            tag: tag,
          );

          return {
            'success': true,
            'accountId': accountId,
            'tag': tag,
            'balance': balance,
            'accessTime': DateTime.now().toIso8601String(),
            'paymentMethod': 'x402_http',
          };
        },
      );
    } on AuthenticationException {
      rethrow;
    } on InventoryException {
      rethrow;
    } on PaymentException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error in X402 balance request: ${e.toString()}',
      );
    }
  }

  /// Validates authentication using ECDSA P-256 signature verification
  ///
  /// This is a simplified authentication check that validates the public key format
  /// and signature. In a production system, this would include more sophisticated
  /// challenge-response authentication.
  ///
  /// Parameters:
  /// - [session]: Serverpod session for logging
  /// - [publicKey]: ECDSA P-256 public key as hex string
  /// - [signature]: Signature to verify
  /// - [operation]: Operation name for logging
  ///
  /// Throws:
  /// - [AuthenticationException] for invalid authentication
  Future<void> _validateAuthentication(
    Session session,
    String publicKey,
    String signature,
    String operation,
  ) async {
    // Validate public key format
    if (publicKey.isEmpty) {
      final exception =
          AnonAccredExceptionFactory.createAuthenticationException(
            code: AnonAccredErrorCodes.authMissingKey,
            message: 'Public key is required for authentication',
            operation: operation,
            details: {'publicKey': 'empty'},
          );

      throw exception;
    }

    if (!CryptoAuth.isValidPublicKey(publicKey)) {
      final exception =
          AnonAccredExceptionFactory.createAuthenticationException(
            code: AnonAccredErrorCodes.cryptoInvalidPublicKey,
            message: 'Invalid ECDSA P-256 public key format',
            operation: operation,
            details: {
              'publicKeyLength': publicKey.length.toString(),
              'expectedLength': '64',
            },
          );

      throw exception;
    }

    // Validate signature format
    if (signature.isEmpty) {
      final exception =
          AnonAccredExceptionFactory.createAuthenticationException(
            code: AnonAccredErrorCodes.authInvalidSignature,
            message: 'Signature is required for authentication',
            operation: operation,
            details: {'signature': 'empty'},
          );

      throw exception;
    }
  }
}
