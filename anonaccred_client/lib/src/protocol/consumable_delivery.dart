/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class ConsumableDelivery implements _i1.SerializableModel {
  ConsumableDelivery._({
    this.id,
    required this.purchaseToken,
    required this.productId,
    required this.accountId,
    required this.consumableType,
    required this.quantity,
    required this.orderId,
    required this.deliveredAt,
  });

  factory ConsumableDelivery({
    int? id,
    required String purchaseToken,
    required String productId,
    required int accountId,
    required String consumableType,
    required double quantity,
    required String orderId,
    required DateTime deliveredAt,
  }) = _ConsumableDeliveryImpl;

  factory ConsumableDelivery.fromJson(Map<String, dynamic> jsonSerialization) {
    return ConsumableDelivery(
      id: jsonSerialization['id'] as int?,
      purchaseToken: jsonSerialization['purchaseToken'] as String,
      productId: jsonSerialization['productId'] as String,
      accountId: jsonSerialization['accountId'] as int,
      consumableType: jsonSerialization['consumableType'] as String,
      quantity: (jsonSerialization['quantity'] as num).toDouble(),
      orderId: jsonSerialization['orderId'] as String,
      deliveredAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['deliveredAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String purchaseToken;

  String productId;

  int accountId;

  String consumableType;

  double quantity;

  String orderId;

  DateTime deliveredAt;

  /// Returns a shallow copy of this [ConsumableDelivery]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ConsumableDelivery copyWith({
    int? id,
    String? purchaseToken,
    String? productId,
    int? accountId,
    String? consumableType,
    double? quantity,
    String? orderId,
    DateTime? deliveredAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.ConsumableDelivery',
      if (id != null) 'id': id,
      'purchaseToken': purchaseToken,
      'productId': productId,
      'accountId': accountId,
      'consumableType': consumableType,
      'quantity': quantity,
      'orderId': orderId,
      'deliveredAt': deliveredAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ConsumableDeliveryImpl extends ConsumableDelivery {
  _ConsumableDeliveryImpl({
    int? id,
    required String purchaseToken,
    required String productId,
    required int accountId,
    required String consumableType,
    required double quantity,
    required String orderId,
    required DateTime deliveredAt,
  }) : super._(
         id: id,
         purchaseToken: purchaseToken,
         productId: productId,
         accountId: accountId,
         consumableType: consumableType,
         quantity: quantity,
         orderId: orderId,
         deliveredAt: deliveredAt,
       );

  /// Returns a shallow copy of this [ConsumableDelivery]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ConsumableDelivery copyWith({
    Object? id = _Undefined,
    String? purchaseToken,
    String? productId,
    int? accountId,
    String? consumableType,
    double? quantity,
    String? orderId,
    DateTime? deliveredAt,
  }) {
    return ConsumableDelivery(
      id: id is int? ? id : this.id,
      purchaseToken: purchaseToken ?? this.purchaseToken,
      productId: productId ?? this.productId,
      accountId: accountId ?? this.accountId,
      consumableType: consumableType ?? this.consumableType,
      quantity: quantity ?? this.quantity,
      orderId: orderId ?? this.orderId,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}
