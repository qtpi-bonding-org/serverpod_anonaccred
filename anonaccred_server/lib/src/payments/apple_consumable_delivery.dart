import '../generated/apple_consumable_delivery.dart';
import 'i_consumable_delivery.dart';

/// Apple IAP implementation of IConsumableDelivery.
///
/// This class wraps the generated AppleConsumableDelivery and implements
/// the IConsumableDelivery interface with Apple-specific values:
/// - paymentRail: 'apple_iap'
/// - idempotencyKey: transactionId
class AppleConsumableDeliveryImpl implements IConsumableDelivery {

  AppleConsumableDeliveryImpl({
    required String transactionId, required String originalTransactionId, required String productId, required int accountId, required String consumableType, required double quantity, required String orderId, required DateTime deliveredAt, int? id,
  }) : _generated = AppleConsumableDelivery(
         id: id,
         transactionId: transactionId,
         originalTransactionId: originalTransactionId,
         productId: productId,
         accountId: accountId,
         consumableType: consumableType,
         quantity: quantity,
         orderId: orderId,
         deliveredAt: deliveredAt,
       );

  /// Creates an AppleConsumableDeliveryImpl from a generated AppleConsumableDelivery.
  factory AppleConsumableDeliveryImpl.fromGenerated(
    AppleConsumableDelivery generated,
  ) => AppleConsumableDeliveryImpl(
      id: generated.id,
      transactionId: generated.transactionId,
      originalTransactionId: generated.originalTransactionId,
      productId: generated.productId,
      accountId: generated.accountId,
      consumableType: generated.consumableType,
      quantity: generated.quantity,
      orderId: generated.orderId,
      deliveredAt: generated.deliveredAt,
    );
  final AppleConsumableDelivery _generated;

  /// Access to the generated AppleConsumableDelivery for database operations.
  AppleConsumableDelivery get generated => _generated;

  int? get id => _generated.id;

  String get transactionId => _generated.transactionId;

  String get originalTransactionId => _generated.originalTransactionId;

  @override
  String get productId => _generated.productId;

  @override
  int get accountId => _generated.accountId;

  @override
  String get consumableType => _generated.consumableType;

  @override
  double get quantity => _generated.quantity;

  @override
  String get orderId => _generated.orderId;

  @override
  DateTime get deliveredAt => _generated.deliveredAt;

  @override
  String get paymentRail => 'apple_iap';

  @override
  String get idempotencyKey => transactionId;

  Map<String, dynamic> toJson() => _generated.toJson();

  @override
  String toString() => _generated.toString();
}