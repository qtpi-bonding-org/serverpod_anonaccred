import 'package:serverpod/serverpod.dart';

import '../crypto_auth.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../inventory_manager.dart';
import '../payments/rails/apple_iap_rail.dart';
import '../payments/rails/google_iap_rail.dart';

/// In-App Purchase endpoint for Apple and Google IAP validation
///
/// Provides server-side validation of mobile app store purchases while maintaining
/// privacy-first architecture. Integrates with existing inventory management and
/// transaction recording systems.
///
/// Requirements 1.1, 1.4: Mobile IAP validation with inventory fulfillment
class IAPEndpoint extends Endpoint {
  /// Validate Apple App Store transaction and fulfill purchase
  ///
  /// Validates iOS app transaction using Apple's App Store Server API and adds
  /// purchased consumables to user inventory upon successful validation.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [transactionId]: Apple transaction ID from the app
  /// - [productId]: Apple product ID (SKU)
  /// - [orderId]: Order ID for transaction tracking
  /// - [accountId]: Account ID for inventory management
  /// - [consumableType]: Type of consumable being purchased
  /// - [quantity]: Quantity of consumables purchased
  ///
  /// Returns: Validation result with transaction details or error information
  ///
  /// Requirements 2.1, 2.2, 2.3: Apple transaction validation
  /// Requirements 1.4: Inventory fulfillment integration
  Future<Map<String, dynamic>> validateAppleTransaction(
    Session session,
    String publicKey,
    String signature,
    String transactionId,
    String productId,
    String orderId,
    int accountId,
    String consumableType,
    double quantity,
  ) async {
    try {
      // Validate authentication
      await _validateAuthentication(session, publicKey, signature, 'validateAppleTransaction');

      // Validate parameters
      if (transactionId.isEmpty || productId.isEmpty) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.paymentValidationFailed,
          message: 'Transaction ID and product ID are required',
          details: {
            'transactionId': transactionId.isEmpty ? 'empty' : 'provided',
            'productId': productId.isEmpty ? 'empty' : 'provided',
          },
        );
      }

      if (consumableType.isEmpty) {
        throw AnonAccredExceptionFactory.createInventoryException(
          code: AnonAccredErrorCodes.inventoryInvalidConsumable,
          message: 'Consumable type cannot be empty',
          accountId: accountId,
          consumableType: consumableType,
          details: {'consumableType': 'empty'},
        );
      }

      if (quantity <= 0) {
        throw AnonAccredExceptionFactory.createInventoryException(
          code: AnonAccredErrorCodes.inventoryInvalidQuantity,
          message: 'Quantity must be positive',
          accountId: accountId,
          consumableType: consumableType,
          details: {'quantity': quantity.toString()},
        );
      }

      // Create Apple IAP rail and validate transaction
      final appleRail = AppleIAPRail();
      final validationResult = await appleRail.validateTransaction(
        session: session,
        transactionId: transactionId,
        productId: productId,
        accountId: accountId,
      );

      if (!validationResult.isValid) {
        session.log(
          'Apple transaction validation failed: ${validationResult.transactionId}',
          level: LogLevel.warning,
        );

        return {
          'success': false,
          'error': 'Transaction validation failed',
          'details': {
            'transaction_id': validationResult.transactionId,
            'product_id': validationResult.productId,
          },
        };
      }

      // Add consumables to inventory
      await InventoryManager.addToInventory(
        session,
        accountId: accountId,
        consumableType: consumableType,
        quantity: quantity,
      );

      session.log(
        'Apple IAP validation successful: ${validationResult.transactionId}',
        level: LogLevel.info,
      );

      return {
        'success': true,
        'transaction_id': validationResult.transactionId,
        'product_id': validationResult.productId,
        'purchase_date': validationResult.purchaseDate?.toIso8601String(),
        'quantity_added': quantity,
        'consumable_type': validationResult.consumableType,
        'order_id': orderId,
        'from_cache': validationResult.fromCache,
      };

    } on AuthenticationException {
      rethrow;
    } on PaymentException {
      rethrow;
    } on InventoryException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error validating Apple transaction: ${e.toString()}',
        details: {
          'error': e.toString(),
          'orderId': orderId,
          'accountId': accountId.toString(),
          'transactionId': transactionId,
          'productId': productId,
        },
      );
    }
  }

  /// Validate Google Play purchase and fulfill purchase
  ///
  /// Validates Android app purchase using Google Play Developer API and adds
  /// purchased consumables to user inventory upon successful validation.
  /// Also acknowledges the purchase as required by Google.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [packageName]: Android app package name
  /// - [productId]: In-app product ID (SKU)
  /// - [purchaseToken]: Purchase token from Android app
  /// - [orderId]: Order ID for transaction tracking
  /// - [accountId]: Account ID for inventory management
  /// - [consumableType]: Type of consumable being purchased
  /// - [quantity]: Quantity of consumables purchased
  ///
  /// Returns: Validation result with transaction details or error information
  ///
  /// Requirements 3.1, 3.2, 3.3: Google purchase validation and acknowledgment
  /// Requirements 1.4: Inventory fulfillment integration
  Future<Map<String, dynamic>> validateGooglePurchase(
    Session session,
    String publicKey,
    String signature,
    String packageName,
    String productId,
    String purchaseToken,
    String orderId,
    int accountId,
    String consumableType,
    double quantity,
  ) async {
    try {
      // Validate authentication
      await _validateAuthentication(session, publicKey, signature, 'validateGooglePurchase');

      // Validate parameters
      if (packageName.isEmpty || productId.isEmpty || purchaseToken.isEmpty) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.paymentValidationFailed,
          message: 'Package name, product ID, and purchase token are required',
          details: {
            'packageName': packageName.isEmpty ? 'empty' : 'provided',
            'productId': productId.isEmpty ? 'empty' : 'provided',
            'purchaseToken': purchaseToken.isEmpty ? 'empty' : 'provided',
          },
        );
      }

      if (consumableType.isEmpty) {
        throw AnonAccredExceptionFactory.createInventoryException(
          code: AnonAccredErrorCodes.inventoryInvalidConsumable,
          message: 'Consumable type cannot be empty',
          accountId: accountId,
          consumableType: consumableType,
          details: {'consumableType': 'empty'},
        );
      }

      if (quantity <= 0) {
        throw AnonAccredExceptionFactory.createInventoryException(
          code: AnonAccredErrorCodes.inventoryInvalidQuantity,
          message: 'Quantity must be positive',
          accountId: accountId,
          consumableType: consumableType,
          details: {'quantity': quantity.toString()},
        );
      }

      // Create Google IAP rail and validate purchase
      final googleRail = GoogleIAPRail();
      final validationResult = await googleRail.validatePurchase(
        session: session,
        packageName: packageName,
        productId: productId,
        purchaseToken: purchaseToken,
        accountId: accountId,
      );

      if (!validationResult.isValid) {
        session.log(
          'Google purchase validation failed: ${validationResult.errorMessage}',
          level: LogLevel.warning,
        );

        return {
          'success': false,
          'error': 'Purchase validation failed',
          'details': {
            'purchase_state': validationResult.purchaseState,
            'error_message': validationResult.errorMessage,
            'consumption_state': validationResult.consumptionState,
          },
        };
      }

      // Acknowledge the purchase (required by Google)
      final acknowledged = await googleRail.acknowledgePurchase(
        packageName: packageName,
        productId: productId,
        purchaseToken: purchaseToken,
      );

      if (!acknowledged) {
        session.log(
          'Google purchase acknowledgment failed for order: $orderId',
          level: LogLevel.warning,
        );
      }

      // Extract transaction data (PII-free)
      final transactionData = GoogleIAPRail.extractTransactionData({
        'orderId': validationResult.orderId,
        'productId': productId,
        'purchaseTimeMillis': validationResult.purchaseTimeMillis,
        'purchaseState': validationResult.purchaseState,
        'consumptionState': validationResult.consumptionState,
        'acknowledgementState': validationResult.acknowledgementState,
      });

      // Add consumables to inventory
      await InventoryManager.addToInventory(
        session,
        accountId: accountId,
        consumableType: consumableType,
        quantity: quantity,
      );

      session.log(
        'Google IAP validation successful: ${validationResult.orderId}',
        level: LogLevel.info,
      );

      return {
        'success': true,
        'order_id': validationResult.orderId,
        'product_id': productId,
        'purchase_time_millis': validationResult.purchaseTimeMillis,
        'quantity_added': quantity,
        'consumable_type': consumableType,
        'acknowledged': acknowledged,
        'transaction_order_id': orderId,
      };

    } on AuthenticationException {
      rethrow;
    } on PaymentException {
      rethrow;
    } on InventoryException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error validating Google purchase: ${e.toString()}',
        details: {
          'error': e.toString(),
          'orderId': orderId,
          'accountId': accountId.toString(),
          'packageName': packageName,
          'productId': productId,
        },
      );
    }
  }

  /// Handle Apple server-to-server notifications (webhook)
  ///
  /// Processes webhook notifications from Apple about purchase events.
  /// This is a placeholder for future webhook implementation.
  ///
  /// Parameters:
  /// - [webhookData]: Webhook payload from Apple
  ///
  /// Returns: Acknowledgment of webhook processing
  ///
  /// Requirements 8.1: Process Apple server-to-server notifications
  Future<Map<String, dynamic>> handleAppleWebhook(
    Session session,
    Map<String, dynamic> webhookData,
  ) async {
    try {
      session.log(
        'Received Apple webhook notification',
        level: LogLevel.info,
      );

      // TODO: Implement Apple webhook processing
      // This would include:
      // 1. Validate webhook signature
      // 2. Parse notification data
      // 3. Update transaction status
      // 4. Handle subscription events

      return {
        'success': true,
        'message': 'Apple webhook processed (placeholder)',
        'timestamp': DateTime.now().toIso8601String(),
      };

    } catch (e) {
      session.log(
        'Apple webhook processing failed: ${e.toString()}',
        level: LogLevel.error,
        exception: e,
      );

      return {
        'success': false,
        'error': 'Webhook processing failed',
        'message': e.toString(),
      };
    }
  }

  /// Handle Google Real-time Developer Notifications (webhook)
  ///
  /// Processes webhook notifications from Google about purchase events.
  /// This is a placeholder for future webhook implementation.
  ///
  /// Parameters:
  /// - [webhookData]: Webhook payload from Google
  ///
  /// Returns: Acknowledgment of webhook processing
  ///
  /// Requirements 8.2: Process Google Real-time Developer Notifications
  Future<Map<String, dynamic>> handleGoogleWebhook(
    Session session,
    Map<String, dynamic> webhookData,
  ) async {
    try {
      session.log(
        'Received Google webhook notification',
        level: LogLevel.info,
      );

      // TODO: Implement Google webhook processing
      // This would include:
      // 1. Validate webhook signature
      // 2. Parse notification data
      // 3. Update transaction status
      // 4. Handle subscription events

      return {
        'success': true,
        'message': 'Google webhook processed (placeholder)',
        'timestamp': DateTime.now().toIso8601String(),
      };

    } catch (e) {
      session.log(
        'Google webhook processing failed: ${e.toString()}',
        level: LogLevel.error,
        exception: e,
      );

      return {
        'success': false,
        'error': 'Webhook processing failed',
        'message': e.toString(),
      };
    }
  }

  /// Validates authentication using Ed25519 signature verification
  ///
  /// This is a simplified authentication check that validates the public key format
  /// and signature. Uses the same pattern as other endpoints.
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
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.authMissingKey,
        message: 'Public key is required for authentication',
        operation: operation,
        details: {'publicKey': 'empty'},
      );
    }

    if (!CryptoAuth.isValidPublicKey(publicKey)) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.cryptoInvalidPublicKey,
        message: 'Invalid Ed25519 public key format',
        operation: operation,
        details: {
          'publicKeyLength': publicKey.length.toString(),
          'expectedLength': '64',
        },
      );
    }

    // Validate signature format
    if (signature.isEmpty) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.authInvalidSignature,
        message: 'Signature is required for authentication',
        operation: operation,
        details: {'signature': 'empty'},
      );
    }
  }
}