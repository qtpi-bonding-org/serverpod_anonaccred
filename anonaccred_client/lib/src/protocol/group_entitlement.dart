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
import 'entitlement.dart' as _i2;
import 'package:anonaccred_client/src/protocol/protocol.dart' as _i3;

abstract class GroupEntitlement implements _i1.SerializableModel {
  GroupEntitlement._({
    this.id,
    required this.shareGroupUuid,
    required this.entitlementId,
    this.entitlement,
    required this.balance,
  });

  factory GroupEntitlement({
    int? id,
    required _i1.UuidValue shareGroupUuid,
    required int entitlementId,
    _i2.Entitlement? entitlement,
    required double balance,
  }) = _GroupEntitlementImpl;

  factory GroupEntitlement.fromJson(Map<String, dynamic> jsonSerialization) {
    return GroupEntitlement(
      id: jsonSerialization['id'] as int?,
      shareGroupUuid: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['shareGroupUuid'],
      ),
      entitlementId: jsonSerialization['entitlementId'] as int,
      entitlement: jsonSerialization['entitlement'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.Entitlement>(
              jsonSerialization['entitlement'],
            ),
      balance: (jsonSerialization['balance'] as num).toDouble(),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i1.UuidValue shareGroupUuid;

  int entitlementId;

  _i2.Entitlement? entitlement;

  double balance;

  /// Returns a shallow copy of this [GroupEntitlement]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GroupEntitlement copyWith({
    int? id,
    _i1.UuidValue? shareGroupUuid,
    int? entitlementId,
    _i2.Entitlement? entitlement,
    double? balance,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.GroupEntitlement',
      if (id != null) 'id': id,
      'shareGroupUuid': shareGroupUuid.toJson(),
      'entitlementId': entitlementId,
      if (entitlement != null) 'entitlement': entitlement?.toJson(),
      'balance': balance,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupEntitlementImpl extends GroupEntitlement {
  _GroupEntitlementImpl({
    int? id,
    required _i1.UuidValue shareGroupUuid,
    required int entitlementId,
    _i2.Entitlement? entitlement,
    required double balance,
  }) : super._(
         id: id,
         shareGroupUuid: shareGroupUuid,
         entitlementId: entitlementId,
         entitlement: entitlement,
         balance: balance,
       );

  /// Returns a shallow copy of this [GroupEntitlement]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GroupEntitlement copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? shareGroupUuid,
    int? entitlementId,
    Object? entitlement = _Undefined,
    double? balance,
  }) {
    return GroupEntitlement(
      id: id is int? ? id : this.id,
      shareGroupUuid: shareGroupUuid ?? this.shareGroupUuid,
      entitlementId: entitlementId ?? this.entitlementId,
      entitlement: entitlement is _i2.Entitlement?
          ? entitlement
          : this.entitlement?.copyWith(),
      balance: balance ?? this.balance,
    );
  }
}
