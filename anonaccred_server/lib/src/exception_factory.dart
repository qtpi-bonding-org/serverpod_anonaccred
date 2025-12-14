import 'generated/protocol.dart';

/// Factory methods for creating AnonAccred exceptions with consistent structure
class AnonAccredExceptionFactory {
  /// Creates a base AnonAccred exception
  static AnonAccredException createException({
    required String code,
    required String message,
    Map<String, String>? details,
  }) => AnonAccredException(code: code, message: message, details: details);

  /// Creates an authentication exception
  static AuthenticationException createAuthenticationException({
    required String code,
    required String message,
    String? operation,
    Map<String, String>? details,
  }) => AuthenticationException(
    code: code,
    message: message,
    operation: operation,
    details: details,
  );

  /// Creates a payment exception
  static PaymentException createPaymentException({
    required String code,
    required String message,
    String? orderId,
    String? paymentRail,
    Map<String, String>? details,
  }) => PaymentException(
    code: code,
    message: message,
    orderId: orderId,
    paymentRail: paymentRail,
    details: details,
  );

  /// Creates an inventory exception
  static InventoryException createInventoryException({
    required String code,
    required String message,
    int? accountId,
    String? consumableType,
    Map<String, String>? details,
  }) => InventoryException(
    code: code,
    message: message,
    accountId: accountId,
    consumableType: consumableType,
    details: details,
  );

  /// Creates a price registry exception (using PaymentException for commerce errors)
  static PaymentException createPriceRegistryException({
    required String code,
    required String message,
    String? sku,
    Map<String, String>? details,
  }) => PaymentException(
    code: code,
    message: message,
    details: {if (sku != null) 'sku': sku, ...?details},
  );
}

/// Common error codes for AnonAccred operations
class AnonAccredErrorCodes {
  // Authentication error codes
  static const String authInvalidSignature = 'AUTH_INVALID_SIGNATURE';
  static const String authExpiredChallenge = 'AUTH_EXPIRED_CHALLENGE';
  static const String authMissingKey = 'AUTH_MISSING_KEY';
  static const String authDeviceNotFound = 'AUTH_DEVICE_NOT_FOUND';
  static const String authDeviceRevoked = 'AUTH_DEVICE_REVOKED';
  static const String authAccountNotFound = 'AUTH_ACCOUNT_NOT_FOUND';
  static const String authDuplicateDevice = 'AUTH_DUPLICATE_DEVICE';
  static const String authChallengeExpired = 'AUTH_CHALLENGE_EXPIRED';

  // Cryptographic error codes
  static const String cryptoInvalidPublicKey = 'CRYPTO_INVALID_PUBLIC_KEY';
  static const String cryptoInvalidSignature = 'CRYPTO_INVALID_SIGNATURE';
  static const String cryptoInvalidMessage = 'CRYPTO_INVALID_MESSAGE';
  static const String cryptoVerificationFailed = 'CRYPTO_VERIFICATION_FAILED';
  static const String cryptoFormatError = 'CRYPTO_FORMAT_ERROR';

  // Payment error codes
  static const String paymentFailed = 'PAYMENT_FAILED';
  static const String paymentInsufficientFunds = 'PAYMENT_INSUFFICIENT_FUNDS';
  static const String paymentInvalidRail = 'PAYMENT_INVALID_RAIL';
  
  // X402-specific error codes
  static const String x402FacilitatorUnavailable = 'X402_FACILITATOR_UNAVAILABLE';
  static const String x402InvalidPaymentPayload = 'X402_INVALID_PAYMENT_PAYLOAD';
  static const String x402ConfigurationMissing = 'X402_CONFIGURATION_MISSING';
  static const String x402VerificationFailed = 'X402_VERIFICATION_FAILED';

  // Inventory error codes
  static const String inventoryInsufficientBalance =
      'INVENTORY_INSUFFICIENT_BALANCE';
  static const String inventoryInvalidConsumable =
      'INVENTORY_INVALID_CONSUMABLE';
  static const String inventoryAccountNotFound = 'INVENTORY_ACCOUNT_NOT_FOUND';
  static const String inventoryInvalidQuantity = 'INVENTORY_INVALID_QUANTITY';

  // Order error codes
  static const String orderInvalidProduct = 'ORDER_INVALID_PRODUCT';
  static const String orderInvalidQuantity = 'ORDER_INVALID_QUANTITY';
  static const String orderCreationFailed = 'ORDER_CREATION_FAILED';
  static const String orderFulfillmentFailed = 'ORDER_FULFILLMENT_FAILED';

  // Price Registry error codes
  static const String priceRegistryProductNotFound =
      'PRICE_REGISTRY_PRODUCT_NOT_FOUND';
  static const String priceRegistryInvalidPrice =
      'PRICE_REGISTRY_INVALID_PRICE';
  static const String priceRegistryInvalidSku = 'PRICE_REGISTRY_INVALID_SKU';
  static const String priceRegistryOperationFailed =
      'PRICE_REGISTRY_OPERATION_FAILED';

  // General error codes
  static const String networkTimeout = 'NETWORK_TIMEOUT';
  static const String databaseError = 'DATABASE_ERROR';
  static const String internalError = 'INTERNAL_ERROR';
}
