import 'generated/protocol.dart';

/// Factory methods for creating AnonAccred commerce exceptions with consistent structure
class AnonAccredExceptionFactory {
  /// Creates a payment exception
  static PaymentException createPaymentException({
    required String code,
    required String message,
    String? internalTransactionId,
    String? paymentRail,
    Map<String, String>? details,
  }) => PaymentException(
    code: code,
    message: message,
    internalTransactionId: internalTransactionId,
    paymentRail: paymentRail,
    details: details,
  );

  /// Creates an inventory exception
  static InventoryException createInventoryException({
    required String code,
    required String message,
    int? accountId,
    String? tag,
    Map<String, String>? details,
  }) => InventoryException(
    code: code,
    message: message,
    accountId: accountId,
    tag: tag,
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

/// Commerce error codes for AnonAccred operations
class AnonAccredErrorCodes {
  // Payment error codes
  static const String paymentFailed = 'PAYMENT_FAILED';
  static const String paymentInsufficientFunds = 'PAYMENT_INSUFFICIENT_FUNDS';
  static const String paymentInvalidRail = 'PAYMENT_INVALID_RAIL';
  static const String paymentValidationFailed = 'PAYMENT_VALIDATION_FAILED';
  static const String paymentNotFound = 'PAYMENT_NOT_FOUND';
  static const String paymentVerificationFailed = 'PAYMENT_VERIFICATION_FAILED';
  static const String configurationMissing = 'CONFIGURATION_MISSING';

  // X402-specific error codes
  static const String x402FacilitatorUnavailable =
      'X402_FACILITATOR_UNAVAILABLE';
  static const String x402InvalidPaymentPayload =
      'X402_INVALID_PAYMENT_PAYLOAD';
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
}
