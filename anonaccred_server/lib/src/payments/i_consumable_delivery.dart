/// Abstract interface for consumable delivery records across all payment rails.
///
/// This interface defines the contract for tracking consumable deliveries
/// for both Apple IAP and Google IAP transactions. Each platform-specific
/// implementation provides its own idempotency key (transaction ID for Apple,
/// purchase token for Google).
///
/// **Purpose:**
/// - Acts as a permanent audit trail for what was delivered
/// - Provides idempotency key (transaction ID → delivery record)
/// - Enables safe retry logic and refund handling without double-delivery
///
/// **Implementations:**
/// - [AppleConsumableDelivery] - for Apple App Store transactions
/// - [GoogleConsumableDelivery] - for Google Play transactions
abstract class IConsumableDelivery {
  /// The account ID that received the consumable.
  int get accountId;

  /// The type of consumable delivered (e.g., "coins", "gems").
  String get consumableType;

  /// The quantity of consumables delivered.
  double get quantity;

  /// The order ID from the payment provider.
  String get orderId;

  /// The timestamp when the delivery was recorded.
  DateTime get deliveredAt;

  /// The payment rail identifier (e.g., "apple_iap", "google_iap").
  String get paymentRail;

  /// The product ID from the payment provider.
  String get productId;

  /// Get the idempotency key for this delivery (platform-specific).
  ///
  /// For Apple IAP, this returns the transaction ID.
  /// For Google IAP, this returns the purchase token.
  String get idempotencyKey;
}