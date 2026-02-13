import 'package:serverpod/serverpod.dart';
import '../generated/consumable_delivery.dart';

/// Manages delivery records for consumable purchases.
///
/// This manager provides methods to:
/// - Check for existing deliveries (for idempotency)
/// - Record new delivery records with all required fields
/// - Retrieve delivery info for refund processing
class ConsumableDeliveryManager {
  /// Check if a delivery already exists for a purchase token.
  ///
  /// Returns the existing delivery record if found, null otherwise.
  /// Used for idempotency checking - if a delivery exists, the purchase
  /// has already been processed and consumables have been delivered.
  static Future<ConsumableDelivery?> findByPurchaseToken(
    Session session,
    String purchaseToken,
  ) async {
    final deliveries = await ConsumableDelivery.db.find(
      session,
      where: (t) => t.purchaseToken.equals(purchaseToken),
      limit: 1,
    );
    return deliveries.isEmpty ? null : deliveries.first;
  }

  /// Record a new delivery for a purchase.
  ///
  /// Creates a delivery record with all required fields. This record serves as:
  /// - An idempotency key (purchase_token is unique)
  /// - An audit trail of what was delivered
  /// - A reference for refund processing
  ///
  /// Throws an exception if a delivery with the same purchase token already exists.
  static Future<ConsumableDelivery> recordDelivery(
    Session session, {
    required String purchaseToken,
    required String productId,
    required int accountId,
    required String consumableType,
    required double quantity,
    required String orderId,
  }) async {
    final delivery = ConsumableDelivery(
      purchaseToken: purchaseToken,
      productId: productId,
      accountId: accountId,
      consumableType: consumableType,
      quantity: quantity,
      orderId: orderId,
      deliveredAt: DateTime.now(),
    );

    return await ConsumableDelivery.db.insertRow(session, delivery);
  }

  /// Get delivery record for refund processing.
  ///
  /// Retrieves the delivery record for a given purchase token.
  /// Used when processing refund webhooks to determine what was delivered.
  ///
  /// Returns the delivery record if found, null otherwise.
  static Future<ConsumableDelivery?> getDeliveryForRefund(
    Session session,
    String purchaseToken,
  ) async {
    return await findByPurchaseToken(session, purchaseToken);
  }
}
