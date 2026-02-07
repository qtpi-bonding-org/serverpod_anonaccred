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

abstract class TransactionConsumable implements _i1.SerializableModel {
  TransactionConsumable._({
    this.id,
    required this.transactionId,
    required this.consumableType,
    required this.quantity,
  });

  factory TransactionConsumable({
    int? id,
    required int transactionId,
    required String consumableType,
    required double quantity,
  }) = _TransactionConsumableImpl;

  factory TransactionConsumable.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return TransactionConsumable(
      id: jsonSerialization['id'] as int?,
      transactionId: jsonSerialization['transactionId'] as int,
      consumableType: jsonSerialization['consumableType'] as String,
      quantity: (jsonSerialization['quantity'] as num).toDouble(),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int transactionId;

  String consumableType;

  double quantity;

  /// Returns a shallow copy of this [TransactionConsumable]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TransactionConsumable copyWith({
    int? id,
    int? transactionId,
    String? consumableType,
    double? quantity,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.TransactionConsumable',
      if (id != null) 'id': id,
      'transactionId': transactionId,
      'consumableType': consumableType,
      'quantity': quantity,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransactionConsumableImpl extends TransactionConsumable {
  _TransactionConsumableImpl({
    int? id,
    required int transactionId,
    required String consumableType,
    required double quantity,
  }) : super._(
         id: id,
         transactionId: transactionId,
         consumableType: consumableType,
         quantity: quantity,
       );

  /// Returns a shallow copy of this [TransactionConsumable]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TransactionConsumable copyWith({
    Object? id = _Undefined,
    int? transactionId,
    String? consumableType,
    double? quantity,
  }) {
    return TransactionConsumable(
      id: id is int? ? id : this.id,
      transactionId: transactionId ?? this.transactionId,
      consumableType: consumableType ?? this.consumableType,
      quantity: quantity ?? this.quantity,
    );
  }
}
