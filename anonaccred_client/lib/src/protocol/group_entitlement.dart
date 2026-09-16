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
import 'package:anonaccred_client/src/protocol/protocol.dart' as _ivk60r4t;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'entitlement.dart' as _ico1e66l;

abstract class GroupEntitlement
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  GroupEntitlement._({
    this.id,
    required this.shareGroupUuid,
    required this.entitlementId,
    this.entitlement,
    required this.balance,
  });

  factory GroupEntitlement({
    int? id,
    required _isc.UuidValue shareGroupUuid,
    required int entitlementId,
    _ico1e66l.Entitlement? entitlement,
    required double balance,
  }) = _GroupEntitlementImpl;

  factory GroupEntitlement.fromJson(Map<String, dynamic> jsonSerialization) {
    return GroupEntitlement(
      id: jsonSerialization['id'] as int?,
      shareGroupUuid: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['shareGroupUuid'],
      ),
      entitlementId: jsonSerialization['entitlementId'] as int,
      entitlement: jsonSerialization['entitlement'] == null
          ? null
          : _ivk60r4t.Protocol().deserialize<_ico1e66l.Entitlement>(
              jsonSerialization['entitlement'],
            ),
      balance: (jsonSerialization['balance'] as num).toDouble(),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _isc.UuidValue shareGroupUuid;

  int entitlementId;

  _ico1e66l.Entitlement? entitlement;

  double balance;

  /// Returns a shallow copy of this [GroupEntitlement]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  GroupEntitlement copyWith({
    int? id,
    _isc.UuidValue? shareGroupUuid,
    int? entitlementId,
    _ico1e66l.Entitlement? entitlement,
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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.GroupEntitlement',
      if (id != null) 'id': id,
      'shareGroupUuid': shareGroupUuid.toJson(),
      'entitlementId': entitlementId,
      if (entitlement != null) 'entitlement': entitlement?.toJsonForProtocol(),
      'balance': balance,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupEntitlementImpl extends GroupEntitlement {
  _GroupEntitlementImpl({
    int? id,
    required _isc.UuidValue shareGroupUuid,
    required int entitlementId,
    _ico1e66l.Entitlement? entitlement,
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
  @_isc.useResult
  @override
  GroupEntitlement copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? shareGroupUuid,
    int? entitlementId,
    Object? entitlement = _Undefined,
    double? balance,
  }) {
    return GroupEntitlement(
      id: id is int? ? id : this.id,
      shareGroupUuid: shareGroupUuid ?? this.shareGroupUuid,
      entitlementId: entitlementId ?? this.entitlementId,
      entitlement: entitlement is _ico1e66l.Entitlement?
          ? entitlement
          : this.entitlement?.copyWith(),
      balance: balance ?? this.balance,
    );
  }
}
