import 'package:serverpod/serverpod.dart';
import '../exception_factory.dart';
import '../generated/payment_rail.dart';
import '../generated/payment_request.dart';
import 'payment_rail_interface.dart';
import 'x402_payment_rail.dart';
import 'rails/apple_iap_rail.dart';
import 'rails/google_iap_rail.dart';

/// Payment Manager factory for routing payment requests to appropriate rails
/// 
/// This class manages payment rail registration and provides a unified interface
/// for creating payments across different payment methods (X402, Monero, IAP).
class PaymentManager {
  static final Map<PaymentRail, PaymentRailInterface> _rails = {};
  
  /// Register a payment rail implementation
  /// 
  /// [rail] - The payment rail implementation to register
  /// 
  /// Requirement 2.1: Payment rails can be registered and stored by type identifier
  static void registerRail(PaymentRailInterface rail) {
    _rails[rail.railType] = rail;
  }
  
  /// Get a registered payment rail by type
  /// 
  /// [railType] - The type of payment rail to retrieve
  /// 
  /// Returns the registered rail implementation or null if not found
  /// 
  /// Requirement 2.2: Payment requests can be routed to the specified payment rail
  static PaymentRailInterface? getRail(PaymentRail railType) {
    return _rails[railType];
  }
  
  /// Create a payment using the specified payment rail
  /// 
  /// [session] - Serverpod session for logging operations (optional for testing)
  /// [railType] - The payment rail to use for processing
  /// [amountUSD] - Payment amount in USD
  /// [orderId] - Unique order identifier
  /// 
  /// Returns a PaymentRequest with payment details and rail-specific metadata
  /// 
  /// Throws PaymentException if the rail type is not supported
  /// 
  /// Requirements 2.2, 2.3: Route requests to appropriate rails with error handling
  /// Requirement 9.1: Log payment creation with order ID, rail type, and amount details
  static Future<PaymentRequest> createPayment({
    Session? session,
    required PaymentRail railType,
    required double amountUSD,
    required String orderId,
  }) async {
    // Log payment creation initiation (Requirement 9.1)
    session?.log(
      'Payment creation initiated - OrderId: $orderId, Rail: $railType, Amount: \$${amountUSD.toStringAsFixed(2)}',
      level: LogLevel.info,
    );

    final rail = getRail(railType);
    if (rail == null) {
      // Log error with operation context (Requirement 9.3)
      session?.log(
        'Payment creation failed - Unsupported rail type: $railType for OrderId: $orderId',
        level: LogLevel.error,
      );
      
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentInvalidRail,
        message: 'Payment rail not supported: $railType',
        orderId: orderId,
        paymentRail: railType.toString(),
        details: {
          'requestedRail': railType.toString(),
          'availableRails': _rails.keys.map((r) => r.toString()).join(', '),
        },
      );
    }
    
    try {
      final paymentRequest = await rail.createPayment(
        amountUSD: amountUSD,
        orderId: orderId,
      );
      
      // Log successful payment creation (Requirement 9.1)
      session?.log(
        'Payment created successfully - OrderId: $orderId, PaymentRef: ${paymentRequest.paymentRef}, Rail: $railType',
        level: LogLevel.info,
      );
      
      return paymentRequest;
    } catch (e) {
      // Log error with complete error details and operation context (Requirement 9.3)
      session?.log(
        'Payment creation failed - OrderId: $orderId, Rail: $railType, Error: ${e.toString()}',
        level: LogLevel.error,
      );
      
      // Wrap unexpected errors in PaymentException
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentFailed,
        message: 'Payment creation failed: ${e.toString()}',
        orderId: orderId,
        paymentRail: railType.toString(),
        details: {
          'error': e.toString(),
          'railType': railType.toString(),
        },
      );
    }
  }
  
  /// Get all registered payment rail types
  /// 
  /// Returns a list of all currently registered payment rail types
  static List<PaymentRail> getRegisteredRailTypes() {
    return _rails.keys.toList();
  }
  
  /// Clear all registered payment rails (primarily for testing)
  /// 
  /// This method removes all registered payment rails from the manager
  static void clearRails() {
    _rails.clear();
  }
  
  /// Check if a payment rail is registered
  /// 
  /// [railType] - The payment rail type to check
  /// 
  /// Returns true if the rail is registered, false otherwise
  static bool isRailRegistered(PaymentRail railType) {
    return _rails.containsKey(railType);
  }
  
  /// Initialize X402 payment rail (simple registration)
  /// 
  /// [session] - Serverpod session for logging (optional)
  /// 
  /// Registers X402 rail if not already registered
  static void initializeX402Rail([Session? session]) {
    if (!isRailRegistered(PaymentRail.x402_http)) {
      try {
        registerRail(X402PaymentRail());
        session?.log('X402 HTTP Payment Rail registered', level: LogLevel.info);
      } catch (e) {
        session?.log('Failed to register X402 rail: $e', level: LogLevel.warning);
      }
    }
  }

  /// Initialize Apple IAP payment rail (simple registration)
  /// 
  /// [session] - Serverpod session for logging (optional)
  /// 
  /// Registers Apple IAP rail if not already registered
  /// 
  /// Requirements 4.1, 4.2: IAP rail integration with existing payment patterns
  static void initializeAppleIAPRail([Session? session]) {
    if (!isRailRegistered(PaymentRail.apple_iap)) {
      try {
        registerRail(AppleIAPRail());
        session?.log('Apple IAP Payment Rail registered', level: LogLevel.info);
      } catch (e) {
        session?.log('Failed to register Apple IAP rail: $e', level: LogLevel.warning);
      }
    }
  }

  /// Initialize Google IAP payment rail (simple registration)
  /// 
  /// [session] - Serverpod session for logging (optional)
  /// 
  /// Registers Google IAP rail if not already registered
  /// 
  /// Requirements 4.1, 4.2: IAP rail integration with existing payment patterns
  static void initializeGoogleIAPRail([Session? session]) {
    if (!isRailRegistered(PaymentRail.google_iap)) {
      try {
        registerRail(GoogleIAPRail());
        session?.log('Google IAP Payment Rail registered', level: LogLevel.info);
      } catch (e) {
        session?.log('Failed to register Google IAP rail: $e', level: LogLevel.warning);
      }
    }
  }

  /// Initialize all available payment rails
  /// 
  /// [session] - Serverpod session for logging (optional)
  /// 
  /// Convenience method to register all supported payment rails
  static void initializeAllRails([Session? session]) {
    initializeX402Rail(session);
    initializeAppleIAPRail(session);
    initializeGoogleIAPRail(session);
    
    session?.log(
      'Payment rails initialized: ${getRegisteredRailTypes().map((r) => r.toString()).join(', ')}',
      level: LogLevel.info,
    );
  }
}