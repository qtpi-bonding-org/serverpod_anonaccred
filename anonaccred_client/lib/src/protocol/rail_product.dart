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

abstract class RailProduct implements _i1.SerializableModel {
  RailProduct._({
    this.id,
    required this.rail,
    required this.storeProductId,
    required this.isActive,
  });

  factory RailProduct({
    int? id,
    required _i2.PaymentRail rail,
    required String storeProductId,
    required bool isActive,
  }) = _RailProductImpl;

  factory RailProduct.fromJson(Map<String, dynamic> jsonSerialization) {
    return RailProduct(
      id: jsonSerialization['id'] as int?,
      rail: _i2.PaymentRail.fromJson((jsonSerialization['rail'] as String)),
      storeProductId: jsonSerialization['storeProductId'] as String,
      isActive: _i1.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i2.PaymentRail rail;

  String storeProductId;

  bool isActive;

  /// Returns a shallow copy of this [RailProduct]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RailProduct copyWith({
    int? id,
    _i2.PaymentRail? rail,
    String? storeProductId,
    bool? isActive,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.RailProduct',
      if (id != null) 'id': id,
      'rail': rail.toJson(),
      'storeProductId': storeProductId,
      'isActive': isActive,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RailProductImpl extends RailProduct {
  _RailProductImpl({
    int? id,
    required _i2.PaymentRail rail,
    required String storeProductId,
    required bool isActive,
  }) : super._(
         id: id,
         rail: rail,
         storeProductId: storeProductId,
         isActive: isActive,
       );

  /// Returns a shallow copy of this [RailProduct]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RailProduct copyWith({
    Object? id = _Undefined,
    _i2.PaymentRail? rail,
    String? storeProductId,
    bool? isActive,
  }) {
    return RailProduct(
      id: id is int? ? id : this.id,
      rail: rail ?? this.rail,
      storeProductId: storeProductId ?? this.storeProductId,
      isActive: isActive ?? this.isActive,
    );
  }
}
