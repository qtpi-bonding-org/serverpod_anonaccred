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

abstract class RefundClaim implements _i1.SerializableModel {
  RefundClaim._({
    this.id,
    required this.paymentRail,
    required this.paymentRef,
    DateTime? claimedAt,
  }) : claimedAt = claimedAt ?? DateTime.now();

  factory RefundClaim({
    int? id,
    required _i2.PaymentRail paymentRail,
    required String paymentRef,
    DateTime? claimedAt,
  }) = _RefundClaimImpl;

  factory RefundClaim.fromJson(Map<String, dynamic> jsonSerialization) {
    return RefundClaim(
      id: jsonSerialization['id'] as int?,
      paymentRail: _i2.PaymentRail.fromJson(
        (jsonSerialization['paymentRail'] as String),
      ),
      paymentRef: jsonSerialization['paymentRef'] as String,
      claimedAt: jsonSerialization['claimedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['claimedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i2.PaymentRail paymentRail;

  String paymentRef;

  DateTime claimedAt;

  /// Returns a shallow copy of this [RefundClaim]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RefundClaim copyWith({
    int? id,
    _i2.PaymentRail? paymentRail,
    String? paymentRef,
    DateTime? claimedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.RefundClaim',
      if (id != null) 'id': id,
      'paymentRail': paymentRail.toJson(),
      'paymentRef': paymentRef,
      'claimedAt': claimedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RefundClaimImpl extends RefundClaim {
  _RefundClaimImpl({
    int? id,
    required _i2.PaymentRail paymentRail,
    required String paymentRef,
    DateTime? claimedAt,
  }) : super._(
         id: id,
         paymentRail: paymentRail,
         paymentRef: paymentRef,
         claimedAt: claimedAt,
       );

  /// Returns a shallow copy of this [RefundClaim]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RefundClaim copyWith({
    Object? id = _Undefined,
    _i2.PaymentRail? paymentRail,
    String? paymentRef,
    DateTime? claimedAt,
  }) {
    return RefundClaim(
      id: id is int? ? id : this.id,
      paymentRail: paymentRail ?? this.paymentRail,
      paymentRef: paymentRef ?? this.paymentRef,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }
}
