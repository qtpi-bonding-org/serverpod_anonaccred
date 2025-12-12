import 'generated/protocol.dart';

/// Factory methods for creating AnonAccred exceptions with consistent structure
class AnonAccredExceptionFactory {
  /// Creates a base AnonAccred exception
  static AnonAccredException createException({
    required String code,
    required String message,
    Map<String, String>? details,
  }) {
    return AnonAccredException(
      code: code,
      message: message,
      details: details,
    );
  }

  /// Creates an authentication exception
  static AuthenticationException createAuthenticationException({
    required String code,
    required String message,
    String? operation,
    Map<String, String>? details,
  }) {
    return AuthenticationException(
      code: code,
      message: message,
      operation: operation,
      details: details,
    );
  }

  /// Creates a payment exception
  static PaymentException createPaymentException({
    required String code,
    required String message,
    String? orderId,
    String? paymentRail,
    Map<String, String>? details,
  }) {
    return PaymentException(
      code: code,
      message: message,
      orderId: orderId,
      paymentRail: paymentRail,
      details: details,
    );
  }

  /// Creates an inventory exception
  static InventoryException createInventoryException({
    required String code,
    required String message,
    int? accountId,
    String? consumableType,
    Map<String, String>? details,
  }) {
    return InventoryException(
      code: code,
      message: message,
      accountId: accountId,
      consumableType: consumableType,
      details: details,
    );
  }
}

/// Common error codes for AnonAccred operations
class AnonAccredErrorCodes {
  // Authentication error codes
  static const String authInvalidSignature = 'AUTH_INVALID_SIGNATURE';
  static const String authExpiredChallenge = 'AUTH_EXPIRED_CHALLENGE';
  static const String authMissingKey = 'AUTH_MISSING_KEY';
  
  // Payment error codes
  static const String paymentFailed = 'PAYMENT_FAILED';
  static const String paymentInsufficientFunds = 'PAYMENT_INSUFFICIENT_FUNDS';
  static const String paymentInvalidRail = 'PAYMENT_INVALID_RAIL';
  
  // Inventory error codes
  static const String inventoryInsufficientBalance = 'INVENTORY_INSUFFICIENT_BALANCE';
  static const String inventoryInvalidConsumable = 'INVENTORY_INVALID_CONSUMABLE';
  static const String inventoryAccountNotFound = 'INVENTORY_ACCOUNT_NOT_FOUND';
  
  // General error codes
  static const String networkTimeout = 'NETWORK_TIMEOUT';
  static const String databaseError = 'DATABASE_ERROR';
  static const String internalError = 'INTERNAL_ERROR';
}