import 'package:serverpod/serverpod.dart';
import 'package:anonaccred_server/src/generated/apple_consumable_delivery.dart';
import 'package:anonaccred_server/src/payments/i_consumable_delivery_manager.dart';

/// Apple IAP implementation of IConsumableDeliveryManager.
///
/// This class manages consumable delivery records for Apple App Store transactions.
/// It provides idempotency checking, delivery recording, and delivery history queries.
///
/// **Purpose:**
/// - Prevents duplicate deliveries using transaction ID as idempotency key
/// - Records deliveries with all required fields for audit and refund processing
/// - Supports querying deliveries by account ID or original transaction ID
///
/// **Database Operations:**
/// - Uses AppleConsumableDelivery table for persistence
/// - Transaction ID is the idempotency key (unique index)
/// - Supports queries by accountId and originalTransactionId
class AppleConsumableDeliveryManager
    implements IConsumableDeliveryManager<AppleConsumableDelivery> {
  /// Creates a new AppleConsumableDeliveryManager instance.
  const AppleConsumableDeliveryManager();

  @override
  Future<AppleConsumableDelivery?> findByIdempotencyKey(
    Session session,
    String transactionId,
  ) async {
    final deliveries = await AppleConsumableDelivery.db.find(
      session,
      where: (t) => t.transactionId.equals(transactionId),
      limit: 1,
    );
    return deliveries.isEmpty ? null : deliveries.first;
  }

  @override
  Future<AppleConsumableDelivery> recordDelivery(
    Session session, {
    required String productId,
    required int accountId,
    required String consumableType,
    required double quantity,
    required String orderId,
    required Map<String, dynamic> platformSpecificData,
  }) async {
    final transactionId = platformSpecificData['transactionId'] as String;
    final originalTransactionId =
        platformSpecificData['originalTransactionId'] as String;

    final delivery = AppleConsumableDelivery(
      transactionId: transactionId,
      originalTransactionId: originalTransactionId,
      productId: productId,
      accountId: accountId,
      consumableType: consumableType,
      quantity: quantity,
      orderId: orderId,
      deliveredAt: DateTime.now(),
    );

    return await AppleConsumableDelivery.db.insertRow(session, delivery);
  }

  @override
  Future<List<AppleConsumableDelivery>> getDeliveriesForAccount(
    Session session,
    int accountId,
  ) async {
    return await AppleConsumableDelivery.db.find(
      session,
      where: (t) => t.accountId.equals(accountId),
    );
  }

  /// Apple-specific: Find deliveries by original transaction ID.
  ///
  /// This is useful for refund processing and transaction history lookups
  /// where the original transaction ID is used to find all related transactions.
  ///
  /// [session] - The database session
  /// [originalTransactionId] - The original transaction ID from Apple
  ///
  /// Returns a list of all delivery records matching the original transaction ID.
  Future<List<AppleConsumableDelivery>> findByOriginalTransactionId(
    Session session,
    String originalTransactionId,
  ) async {
    return await AppleConsumableDelivery.db.find(
      session,
      where: (t) => t.originalTransactionId.equals(originalTransactionId),
    );
  }
}