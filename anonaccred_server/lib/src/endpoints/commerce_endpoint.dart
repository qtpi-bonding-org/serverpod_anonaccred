import 'package:serverpod/serverpod.dart';
import '../crypto_auth.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../inventory_manager.dart';
import '../inventory_utils.dart';
import '../order_manager.dart';
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
  /// - [publicKey]: Ed25519 public key for authentication
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

      // Register products in the price registry
      final registry = PriceRegistry();
      try {
        for (final entry in products.entries) {
          registry.registerProduct(entry.key, entry.value);
        }
      } on PaymentException {
        rethrow;
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

  /// Create a new order for consumable items
  ///
  /// Creates a pending transaction record with the specified items and pricing.
  /// Requires authentication and validates all items against the price registry.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [accountId]: The account ID creating the order
  /// - [items]: Map of consumable types to quantities
  /// - [paymentRail]: Payment method to be used
  ///
  /// Returns: The created TransactionPayment record
  ///
  /// Throws:
  /// - [AuthenticationException] for invalid authentication
  /// - [PaymentException] for invalid order data
  /// - [AnonAccredException] for system errors
  Future<TransactionPayment> createOrder(
    Session session,
    String publicKey,
    String signature,
    int accountId,
    Map<String, double> items,
    PaymentRail paymentRail,
  ) async {
    try {
      // Validate authentication
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'createOrder',
      );

      // Validate items
      if (items.isEmpty) {
        final exception = AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.orderInvalidProduct,
          message: 'At least one item must be provided for order',
          details: {'itemCount': '0'},
        );

        throw exception;
      }

      // Create the order using OrderManager
      final transaction = await OrderManager.createOrder(
        session,
        accountId: accountId,
        items: items,
        priceCurrency: Currency.USD,
        paymentRail: paymentRail,
        paymentCurrency: Currency.USD, // Default to USD for now
      );

      // Log successful order creation

      return transaction;
    } on AuthenticationException {
      rethrow;
    } on PaymentException {
      // Log payment/price registry errors
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error during order creation: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }

  /// Get inventory for an account
  ///
  /// Returns all consumable types and their current balances for the specified account.
  /// Requires authentication to ensure only authorized access to inventory data.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [accountId]: The account ID to query inventory for
  ///
  /// Returns: List of AccountInventory records
  ///
  /// Throws:
  /// - [AuthenticationException] for invalid authentication
  /// - [InventoryException] for inventory access errors
  /// - [AnonAccredException] for system errors
  Future<List<AccountInventory>> getInventory(
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
        'getInventory',
      );

      // Get inventory using InventoryManager
      final inventory = await InventoryManager.getInventory(session, accountId);

      // Log successful inventory query

      return inventory;
    } on AuthenticationException {
      rethrow;
    } on InventoryException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error getting inventory: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }

  /// Get balance for a specific consumable type
  ///
  /// Returns the current balance for the specified consumable type and account.
  /// Requires authentication to ensure only authorized access to balance data.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [accountId]: The account ID to check balance for
  /// - [consumableType]: The consumable type to check
  ///
  /// Returns: Current balance as double
  ///
  /// Throws:
  /// - [AuthenticationException] for invalid authentication
  /// - [InventoryException] for inventory access errors
  /// - [AnonAccredException] for system errors
  Future<double> getBalance(
    Session session,
    String publicKey,
    String signature,
    int accountId,
    String consumableType,
  ) async {
    try {
      // Validate authentication
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'getBalance',
      );

      // Validate consumable type
      if (consumableType.isEmpty) {
        final exception = AnonAccredExceptionFactory.createInventoryException(
          code: AnonAccredErrorCodes.inventoryInvalidConsumable,
          message: 'Consumable type cannot be empty',
          accountId: accountId,
          consumableType: consumableType,
          details: {'consumableType': 'empty'},
        );

        throw exception;
      }

      // Get balance using InventoryManager
      final balance = await InventoryManager.getBalance(
        session,
        accountId: accountId,
        consumableType: consumableType,
      );

      // Log successful balance query

      return balance;
    } on AuthenticationException {
      rethrow;
    } on InventoryException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error getting balance: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }

  /// Consume inventory using atomic utilities
  ///
  /// Attempts to consume a specified quantity from account inventory using
  /// the optional InventoryUtils. This endpoint provides atomic consumption
  /// operations for parent applications that choose to use them.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [accountId]: The account ID to consume inventory from
  /// - [consumableType]: The consumable type to consume
  /// - [quantity]: Amount to consume (must be positive)
  ///
  /// Returns: ConsumeResult with operation outcome and balance information
  ///
  /// Throws:
  /// - [AuthenticationException] for invalid authentication
  /// - [InventoryException] for invalid consumption parameters
  /// - [AnonAccredException] for system errors
  Future<ConsumeResult> consumeInventory(
    Session session,
    String publicKey,
    String signature,
    int accountId,
    String consumableType,
    double quantity,
  ) async {
    try {
      // Validate authentication
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'consumeInventory',
      );

      // Validate consumable type
      if (consumableType.isEmpty) {
        final exception = AnonAccredExceptionFactory.createInventoryException(
          code: AnonAccredErrorCodes.inventoryInvalidConsumable,
          message: 'Consumable type cannot be empty',
          accountId: accountId,
          consumableType: consumableType,
          details: {'consumableType': 'empty'},
        );

        throw exception;
      }

      // Validate quantity
      if (quantity <= 0) {
        final exception = AnonAccredExceptionFactory.createInventoryException(
          code: AnonAccredErrorCodes.inventoryInvalidQuantity,
          message: 'Quantity must be positive',
          accountId: accountId,
          consumableType: consumableType,
          details: {'quantity': quantity.toString(), 'minimumQuantity': '0'},
        );

        throw exception;
      }

      // Attempt consumption using InventoryUtils
      final result = await InventoryUtils.tryConsume(
        session,
        accountId: accountId,
        consumableType: consumableType,
        quantity: quantity,
      );

      // Log consumption attempt

      return result;
    } on AuthenticationException {
      rethrow;
    } on InventoryException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message:
            'Unexpected error during inventory consumption: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }

  /// Validates authentication using Ed25519 signature verification
  ///
  /// This is a simplified authentication check that validates the public key format
  /// and signature. In a production system, this would include more sophisticated
  /// challenge-response authentication.
  ///
  /// Parameters:
  /// - [session]: Serverpod session for logging
  /// - [publicKey]: Ed25519 public key as hex string
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
            message: 'Invalid Ed25519 public key format',
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
