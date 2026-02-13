import 'package:serverpod/serverpod.dart';
import 'i_consumable_delivery.dart';

/// Abstract interface for managing consumable delivery records.
///
/// This interface defines the contract for tracking and retrieving consumable
/// deliveries across different payment rails (Apple IAP, Google IAP).
/// Implementations provide platform-specific delivery tracking while maintaining
/// a consistent interface.
///
/// **Purpose:**
/// - Provides idempotency checking to prevent duplicate deliveries
/// - Records new deliveries with all required fields
/// - Retrieves delivery history for account and refund processing
///
/// **Implementations:**
/// - [AppleConsumableDeliveryManager] - for Apple App Store transactions
/// - [GoogleConsumableDeliveryManager] - for Google Play transactions
///
/// **Usage Example:**
/// ```dart
/// final manager = AppleConsumableDeliveryManager();
/// final existing = await manager.findByIdempotencyKey(session, transactionId);
/// if (existing != null) {
///   // Already delivered, return cached result
///   return existing;
/// }
/// // Record new delivery
/// final delivery = await manager.recordDelivery(
///   session,
///   productId: 'com.app.coins_100',
///   accountId: 12345,
///   consumableType: 'coins',
///   quantity: 100.0,
///   orderId: 'order_abc',
///   platformSpecificData: {'transactionId': transactionId},
/// );
/// ```
abstract class IConsumableDeliveryManager<T> {
  /// Find an existing delivery by its idempotency key.
  ///
  /// [session] - The database session
  /// [idempotencyKey] - The platform-specific idempotency key
  ///   (transaction ID for Apple IAP, purchase token for Google IAP)
  ///
  /// Returns the existing delivery record if found, null otherwise.
  /// Used for idempotency checking - if a delivery exists, the purchase
  /// has already been processed and consumables have been delivered.
  Future<T?> findByIdempotencyKey(Session session, String idempotencyKey);

  /// Record a new delivery for a purchase.
  ///
  /// [session] - The database session
  /// [productId] - The product ID from the payment provider
  /// [accountId] - The account ID that received the consumable
  /// [consumableType] - The type of consumable delivered (e.g., "coins")
  /// [quantity] - The quantity of consumables delivered
  /// [orderId] - The order ID from the payment provider
  /// [platformSpecificData] - Platform-specific data (e.g., transactionId for Apple)
  ///
  /// Creates a delivery record with all required fields. This record serves as:
  /// - An idempotency key (prevents duplicate deliveries)
  /// - An audit trail of what was delivered
  /// - A reference for refund processing
  ///
  /// Returns the created delivery record.
  Future<T> recordDelivery(
    Session session, {
    required String productId,
    required int accountId,
    required String consumableType,
    required double quantity,
    required String orderId,
    required Map<String, dynamic> platformSpecificData,
  });

  /// Get all delivery records for an account.
  ///
  /// [session] - The database session
  /// [accountId] - The account ID to query deliveries for
  ///
  /// Returns a list of all delivery records for the specified account,
  /// ordered by delivery timestamp (newest first).
  Future<List<T>> getDeliveriesForAccount(Session session, int accountId);
}