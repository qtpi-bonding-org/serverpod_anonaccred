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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class ShardRouting
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ShardRouting._({
    this.id,
    required this.tenantId,
    required this.tenantType,
    String? shardName,
    DateTime? updatedAt,
  }) : shardName = shardName ?? 'shard_01',
       updatedAt = updatedAt ?? DateTime.now();

  factory ShardRouting({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required String tenantType,
    String? shardName,
    DateTime? updatedAt,
  }) = _ShardRoutingImpl;

  factory ShardRouting.fromJson(Map<String, dynamic> jsonSerialization) {
    return ShardRouting(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      tenantType: jsonSerialization['tenantType'] as String,
      shardName: jsonSerialization['shardName'] as String?,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue tenantId;

  String tenantType;

  String shardName;

  DateTime updatedAt;

  /// Returns a shallow copy of this [ShardRouting]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ShardRouting copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    String? tenantType,
    String? shardName,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.ShardRouting',
      if (id != null) 'id': id?.toJson(),
      'tenantId': tenantId.toJson(),
      'tenantType': tenantType,
      'shardName': shardName,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.ShardRouting',
      if (id != null) 'id': id?.toJson(),
      'tenantId': tenantId.toJson(),
      'tenantType': tenantType,
      'shardName': shardName,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ShardRoutingImpl extends ShardRouting {
  _ShardRoutingImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required String tenantType,
    String? shardName,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         tenantId: tenantId,
         tenantType: tenantType,
         shardName: shardName,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [ShardRouting]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ShardRouting copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? tenantId,
    String? tenantType,
    String? shardName,
    DateTime? updatedAt,
  }) {
    return ShardRouting(
      id: id is _isc.UuidValue? ? id : this.id,
      tenantId: tenantId ?? this.tenantId,
      tenantType: tenantType ?? this.tenantType,
      shardName: shardName ?? this.shardName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
