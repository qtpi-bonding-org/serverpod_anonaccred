import 'package:serverpod/serverpod.dart';

import '../exception_factory.dart';
import '../generated/payment_rail.dart';
import '../generated/payment_request.dart';
import 'payment_rail_interface.dart';
import 'rails/apple_iap_rail.dart';
import 'rails/google_iap_rail.dart';
import 'x402_payment_rail.dart';

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
  static PaymentRailInterface? getRail(PaymentRail railType) =>
      _rails[railType];

  /// Create a payment using the specified payment rail
  ///
  /// [session] - Serverpod session for logging operations (optional for testing)
  /// [railType] - The payment rail to use for processing
  /// [amountUSD] - Payment amount in USD
  /// [internalTransactionId] - Unique internal transaction identifier
  ///
  /// Returns a PaymentRequest with payment details and rail-specific metadata
  ///
  /// Throws PaymentException if the rail type is not supported
  ///
  /// Requirements 2.2, 2.3: Route requests to appropriate rails with error handling
  /// Requirement 9.1: Log payment creation with transaction ID, rail type, and amount details
  static Future<PaymentRequest> createPayment({
    required PaymentRail railType,
    required double amountUSD,
    required String internalTransactionId,
    Session? session,
  }) async {
    // Log payment creation initiation (Requirement 9.1)
    session?.log(
      'Payment creation initiated - TxId: $internalTransactionId, Rail: $railType, Amount: \$${amountUSD.toStringAsFixed(2)}',
      level: LogLevel.info,
    );

    final rail = getRail(railType);
    if (rail == null) {
      // Log error with operation context (Requirement 9.3)
      session?.log(
        'Payment creation failed - Unsupported rail type: $railType for TxId: $internalTransactionId',
        level: LogLevel.error,
      );

      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentInvalidRail,
        message: 'Payment rail not supported: $railType',
        internalTransactionId: internalTransactionId,
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
        internalTransactionId: internalTransactionId,
      );

      // Log successful payment creation (Requirement 9.1)
      session?.log(
        'Payment created successfully - TxId: $internalTransactionId, PaymentRef: ${paymentRequest.paymentRef}, Rail: $railType',
        level: LogLevel.info,
      );

      return paymentRequest;
    } catch (e) {
      // Log error with complete error details and operation context (Requirement 9.3)
      session?.log(
        'Payment creation failed - TxId: $internalTransactionId, Rail: $railType, Error: ${e.toString()}',
        level: LogLevel.error,
      );

      // Wrap unexpected errors in PaymentException
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentFailed,
        message: 'Payment creation failed: ${e.toString()}',
        internalTransactionId: internalTransactionId,
        paymentRail: railType.toString(),
        details: {'error': e.toString(), 'railType': railType.toString()},
      );
    }
  }

  /// Get all registered payment rail types
  ///
  /// Returns a list of all currently registered payment rail types
  static List<PaymentRail> getRegisteredRailTypes() => _rails.keys.toList();

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
  static bool isRailRegistered(PaymentRail railType) =>
      _rails.containsKey(railType);

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
        session?.log(
          'Failed to register X402 rail: $e',
          level: LogLevel.warning,
        );
      }
    }
  }

  /// Initialize Apple IAP payment rail asynchronously
  ///
  /// [session] - Serverpod session for logging (optional)
  ///
  /// Requirements 4.1, 4.2: IAP rail integration with existing payment patterns
  static Future<void> initializeAppleIAPRail([Session? session]) async {
    if (!isRailRegistered(PaymentRail.apple_iap)) {
      try {
        // Apple IAP now uses async factory for client initialization
        final rail = await AppleIAPRail.create();
        registerRail(rail);
        session?.log('Apple IAP Payment Rail registered', level: LogLevel.info);
      } catch (e) {
        session?.log(
          'Apple IAP rail was not registered (likely missing config): $e',
          level: LogLevel.warning,
        );
      }
    }
  }

  /// Initialize Google IAP payment rail asynchronously
  ///
  /// [session] - Serverpod session for logging (optional)
  ///
  /// Requirements 4.1, 4.2: IAP rail integration with existing payment patterns
  static Future<void> initializeGoogleIAPRail([Session? session]) async {
    if (!isRailRegistered(PaymentRail.google_iap)) {
      try {
        // Google IAP requires async factory for client initialization
        final rail = await GoogleIAPRail.create();
        registerRail(rail);
        session?.log(
          'Google IAP Payment Rail registered',
          level: LogLevel.info,
        );
      } catch (e) {
        session?.log(
          'Google IAP rail was not registered (likely missing config): $e',
          level: LogLevel.warning,
        );
      }
    }
  }

  /// Initialize all available payment rails asynchronously
  ///
  /// [session] - Serverpod session for logging (optional)
  ///
  /// Convenience method to register all supported payment rails
  static Future<void> initializeAllRails([Session? session]) async {
    // 1. Initialize X402 rail (no credentials required)
    try {
      initializeX402Rail(session);
    } catch (e) {
      session?.log('Failed to initialize x402 rail: $e', level: LogLevel.error);
    }

    // 2. Initialize Apple IAP rail (async, credentials required)
    try {
      await initializeAppleIAPRail(session);
    } catch (e) {
      session?.log(
        'Failed to initialize apple_iap rail: $e',
        level: LogLevel.warning,
      );
    }

    // 3. Initialize Google IAP rail (async, credentials required)
    try {
      await initializeGoogleIAPRail(session);
    } catch (e) {
      session?.log(
        'Failed to initialize google_iap rail: $e',
        level: LogLevel.warning,
      );
    }

    session?.log(
      'Payment rails initialization complete. Active: ${getRegisteredRailTypes().map((r) => r.toString()).join(', ')}',
      level: LogLevel.info,
    );
  }
}
