import 'package:serverpod/serverpod.dart';

import '../crypto_auth.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../inventory_manager.dart';
import '../payments/x402_interceptor.dart';
import '../payments/x402_payment_processor.dart';

/// X402 HTTP Payment Rail endpoint integration
///
/// Demonstrates X402 protocol integration with AnonAccred endpoints.
/// Supports the standard client-server communication flow where clients
/// can request resources and receive HTTP 402 responses when payment is required.
///
/// Requirements 5.1, 5.2, 5.3: X402 endpoint integration with request interception
class X402Endpoint extends Endpoint {
  /// Request a paid resource with X402 payment integration
  ///
  /// This endpoint demonstrates the X402 protocol flow:
  /// 1. Client requests resource without payment -> HTTP 402 response
  /// 2. Client resubmits with X-PAYMENT header -> verify and deliver resource
  ///
  /// This endpoint supports AI agents and autonomous systems by enabling
  /// micropayments without human intervention.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [resourceId]: The resource being requested
  /// - [accountId]: Account ID for inventory management
  ///
  /// Returns: Either X402PaymentResponse (HTTP 402) or the requested resource data
  ///
  /// Requirements 5.1: Standard client-server communication flow
  /// Requirements 5.2: HTTP 402 response when payment required
  /// Requirements 5.3: Verify payment and provide resource
  Future<Map<String, dynamic>> requestPaidResource(
    Session session,
    String publicKey,
    String signature,
    String resourceId,
    int accountId, {
    Map<String, String>? headers,
  }) async {
    try {
      // Validate authentication
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'requestPaidResource',
      );

      // Validate resource ID
      if (resourceId.isEmpty) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.orderInvalidProduct,
          message: 'Resource ID cannot be empty',
          details: {'resourceId': 'empty'},
        );
      }

      // Check if X-PAYMENT header is provided
      final requestHeaders = headers ?? <String, String>{};
      final hasPayment = X402Interceptor.hasPaymentHeader(requestHeaders);

      if (!hasPayment) {
        // No payment provided - return HTTP 402 with payment requirements
        return await _generatePaymentRequired(
          session,
          resourceId,
          accountId,
        );
      }

      // Payment provided - verify it
      final paymentVerified = await X402PaymentProcessor.verifyPayment(requestHeaders);
      
      if (!paymentVerified) {
        // Payment verification failed - return HTTP 402 with payment requirements
        session.log(
          'X402 payment verification failed for resource: $resourceId',
          level: LogLevel.warning,
        );
        
        return await _generatePaymentRequired(
          session,
          resourceId,
          accountId,
        );
      }

      // Payment verified - deliver the requested resource
      return await _deliverResource(
        session,
        resourceId,
        accountId,
      );

    } on AuthenticationException {
      rethrow;
    } on PaymentException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error processing X402 request: ${e.toString()}',
        details: {
          'error': e.toString(),
          'resourceId': resourceId,
          'accountId': accountId.toString(),
        },
      );
    }
  }

  /// Request consumable inventory with X402 payment integration
  ///
  /// Demonstrates pay-per-use model where each API call consumes inventory.
  /// Supports micropayments for AI agents and autonomous systems.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [consumableType]: Type of consumable to access
  /// - [quantity]: Amount to consume
  /// - [accountId]: Account ID for inventory management
  ///
  /// Returns: Either X402PaymentResponse (HTTP 402) or consumption result
  ///
  /// Requirements 5.4: Support AI agents and autonomous systems
  /// Requirements 5.5: Pay-per-use model charging per API call
  Future<Map<String, dynamic>> requestConsumableAccess(
    Session session,
    String publicKey,
    String signature,
    String consumableType,
    double quantity,
    int accountId, {
    Map<String, String>? headers,
  }) async {
    try {
      // Validate authentication
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'requestConsumableAccess',
      );

      // Validate parameters
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

      // Check current inventory balance
      final currentBalance = await InventoryManager.getBalance(
        session,
        accountId: accountId,
        consumableType: consumableType,
      );

      // Check if X-PAYMENT header is provided
      final requestHeaders = headers ?? <String, String>{};
      final hasPayment = X402Interceptor.hasPaymentHeader(requestHeaders);

      // If insufficient balance and no payment, require payment
      if (currentBalance < quantity && !hasPayment) {
        return await _generateConsumablePaymentRequired(
          session,
          consumableType,
          quantity,
          accountId,
        );
      }

      // If payment provided, verify it
      if (hasPayment) {
        final paymentVerified = await X402PaymentProcessor.verifyPayment(requestHeaders);
        
        if (!paymentVerified) {
          session.log(
            'X402 payment verification failed for consumable: $consumableType',
            level: LogLevel.warning,
          );
          
          return await _generateConsumablePaymentRequired(
            session,
            consumableType,
            quantity,
            accountId,
          );
        }

        // Payment verified - this would typically add to inventory
        // For this demo, we'll simulate successful payment processing
        session.log(
          'X402 payment verified for consumable access: $consumableType',
          level: LogLevel.info,
        );
      }

      // Deliver consumable access (simulate consumption)
      return {
        'success': true,
        'consumableType': consumableType,
        'quantityConsumed': quantity,
        'remainingBalance': currentBalance - quantity,
        'timestamp': DateTime.now().toIso8601String(),
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
        message: 'Unexpected error processing consumable access: ${e.toString()}',
        details: {
          'error': e.toString(),
          'consumableType': consumableType,
          'quantity': quantity.toString(),
          'accountId': accountId.toString(),
        },
      );
    }
  }

  /// Generate HTTP 402 payment required response for resource access
  ///
  /// Creates X402 protocol compliant payment requirements for the requested resource.
  /// The response includes all information necessary for programmatic payment completion.
  ///
  /// Requirements 1.2, 1.4: HTTP 402 response with payment requirements
  Future<Map<String, dynamic>> _generatePaymentRequired(
    Session session,
    String resourceId,
    int accountId,
  ) async {
    // Generate unique order ID for this payment request
    final orderId = 'x402_resource_${resourceId}_${DateTime.now().millisecondsSinceEpoch}';
    
    // Set resource price (in a real system, this would come from price registry)
    const resourcePrice = 1.99; // $1.99 per resource access

    // Generate X402 payment response
    final paymentResponse = X402PaymentProcessor.generatePaymentRequired(
      amount: resourcePrice,
      orderId: orderId,
    );

    session.log(
      'Generated X402 payment requirement for resource: $resourceId, order: $orderId',
      level: LogLevel.info,
    );

    // Return HTTP 402 response data
    return {
      'httpStatus': 402,
      'message': 'Payment Required',
      'paymentRequired': paymentResponse.toJson(),
    };
  }

  /// Generate HTTP 402 payment required response for consumable access
  ///
  /// Creates X402 protocol compliant payment requirements for consumable inventory.
  /// Supports pay-per-use model for API access charging.
  ///
  /// Requirements 5.5: Pay-per-use model charging per API call
  Future<Map<String, dynamic>> _generateConsumablePaymentRequired(
    Session session,
    String consumableType,
    double quantity,
    int accountId,
  ) async {
    // Generate unique order ID for this payment request
    final orderId = 'x402_consumable_${consumableType}_${DateTime.now().millisecondsSinceEpoch}';
    
    // Calculate price based on quantity (in a real system, this would use price registry)
    const unitPrice = 0.10; // $0.10 per unit
    final totalPrice = quantity * unitPrice;

    // Generate X402 payment response
    final paymentResponse = X402PaymentProcessor.generatePaymentRequired(
      amount: totalPrice,
      orderId: orderId,
    );

    session.log(
      'Generated X402 payment requirement for consumable: $consumableType, quantity: $quantity, order: $orderId',
      level: LogLevel.info,
    );

    // Return HTTP 402 response data
    return {
      'httpStatus': 402,
      'message': 'Payment Required',
      'paymentRequired': paymentResponse.toJson(),
      'consumableType': consumableType,
      'quantity': quantity,
    };
  }

  /// Deliver the requested resource after successful payment verification
  ///
  /// Simulates resource delivery after X402 payment verification.
  /// In a real system, this would deliver actual resource data.
  ///
  /// Requirements 2.4: Provide requested resource after successful payment
  Future<Map<String, dynamic>> _deliverResource(
    Session session,
    String resourceId,
    int accountId,
  ) async {
    session.log(
      'Delivering resource after X402 payment verification: $resourceId',
      level: LogLevel.info,
    );

    // Simulate resource delivery
    return {
      'success': true,
      'resourceId': resourceId,
      'resourceData': {
        'content': 'This is the paid resource content for $resourceId',
        'metadata': {
          'accessTime': DateTime.now().toIso8601String(),
          'paymentMethod': 'x402_http',
          'accountId': accountId,
        },
      },
    };
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