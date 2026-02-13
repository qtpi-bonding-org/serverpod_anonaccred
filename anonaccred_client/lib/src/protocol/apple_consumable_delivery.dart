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

abstract class AppleConsumableDelivery implements _i1.SerializableModel {
  AppleConsumableDelivery._({
    this.id,
    required this.transactionId,
    required this.originalTransactionId,
    required this.productId,
    required this.accountId,
    required this.consumableType,
    required this.quantity,
    required this.orderId,
    required this.deliveredAt,
  });

  factory AppleConsumableDelivery({
    int? id,
    required String transactionId,
    required String originalTransactionId,
    required String productId,
    required int accountId,
    required String consumableType,
    required double quantity,
    required String orderId,
    required DateTime deliveredAt,
  }) = _AppleConsumableDeliveryImpl;

  factory AppleConsumableDelivery.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AppleConsumableDelivery(
      id: jsonSerialization['id'] as int?,
      transactionId: jsonSerialization['transactionId'] as String,
      originalTransactionId:
          jsonSerialization['originalTransactionId'] as String,
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

  String transactionId;

  String originalTransactionId;

  String productId;

  int accountId;

  String consumableType;

  double quantity;

  String orderId;

  DateTime deliveredAt;

  /// Returns a shallow copy of this [AppleConsumableDelivery]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AppleConsumableDelivery copyWith({
    int? id,
    String? transactionId,
    String? originalTransactionId,
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
      '__className__': 'anonaccred.AppleConsumableDelivery',
      if (id != null) 'id': id,
      'transactionId': transactionId,
      'originalTransactionId': originalTransactionId,
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

class _AppleConsumableDeliveryImpl extends AppleConsumableDelivery {
  _AppleConsumableDeliveryImpl({
    int? id,
    required String transactionId,
    required String originalTransactionId,
    required String productId,
    required int accountId,
    required String consumableType,
    required double quantity,
    required String orderId,
    required DateTime deliveredAt,
  }) : super._(
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

  /// Returns a shallow copy of this [AppleConsumableDelivery]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AppleConsumableDelivery copyWith({
    Object? id = _Undefined,
    String? transactionId,
    String? originalTransactionId,
    String? productId,
    int? accountId,
    String? consumableType,
    double? quantity,
    String? orderId,
    DateTime? deliveredAt,
  }) {
    return AppleConsumableDelivery(
      id: id is int? ? id : this.id,
      transactionId: transactionId ?? this.transactionId,
      originalTransactionId:
          originalTransactionId ?? this.originalTransactionId,
      productId: productId ?? this.productId,
      accountId: accountId ?? this.accountId,
      consumableType: consumableType ?? this.consumableType,
      quantity: quantity ?? this.quantity,
      orderId: orderId ?? this.orderId,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}
