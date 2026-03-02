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
import 'payment_rail.dart' as _i2;

abstract class ReceiptHash implements _i1.SerializableModel {
  ReceiptHash._({
    this.id,
    required this.hash,
    required this.paymentRail,
    DateTime? processedAt,
  }) : processedAt = processedAt ?? DateTime.now();

  factory ReceiptHash({
    int? id,
    required String hash,
    required _i2.PaymentRail paymentRail,
    DateTime? processedAt,
  }) = _ReceiptHashImpl;

  factory ReceiptHash.fromJson(Map<String, dynamic> jsonSerialization) {
    return ReceiptHash(
      id: jsonSerialization['id'] as int?,
      hash: jsonSerialization['hash'] as String,
      paymentRail: _i2.PaymentRail.fromJson(
        (jsonSerialization['paymentRail'] as String),
      ),
      processedAt: jsonSerialization['processedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['processedAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String hash;

  _i2.PaymentRail paymentRail;

  DateTime processedAt;

  /// Returns a shallow copy of this [ReceiptHash]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ReceiptHash copyWith({
    int? id,
    String? hash,
    _i2.PaymentRail? paymentRail,
    DateTime? processedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.ReceiptHash',
      if (id != null) 'id': id,
      'hash': hash,
      'paymentRail': paymentRail.toJson(),
      'processedAt': processedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ReceiptHashImpl extends ReceiptHash {
  _ReceiptHashImpl({
    int? id,
    required String hash,
    required _i2.PaymentRail paymentRail,
    DateTime? processedAt,
  }) : super._(
         id: id,
         hash: hash,
         paymentRail: paymentRail,
         processedAt: processedAt,
       );

  /// Returns a shallow copy of this [ReceiptHash]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ReceiptHash copyWith({
    Object? id = _Undefined,
    String? hash,
    _i2.PaymentRail? paymentRail,
    DateTime? processedAt,
  }) {
    return ReceiptHash(
      id: id is int? ? id : this.id,
      hash: hash ?? this.hash,
      paymentRail: paymentRail ?? this.paymentRail,
      processedAt: processedAt ?? this.processedAt,
    );
  }
}
