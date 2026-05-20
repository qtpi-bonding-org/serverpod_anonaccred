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

abstract class GroupConsumptionLog implements _i1.SerializableModel {
  GroupConsumptionLog._({
    this.id,
    required this.shareGroupUuid,
    required this.entitlementId,
    required this.amount,
    required this.reason,
    DateTime? timestamp,
    this.consumingAccountUuid,
  }) : timestamp = timestamp ?? DateTime.now();

  factory GroupConsumptionLog({
    int? id,
    required _i1.UuidValue shareGroupUuid,
    required int entitlementId,
    required double amount,
    required String reason,
    DateTime? timestamp,
    _i1.UuidValue? consumingAccountUuid,
  }) = _GroupConsumptionLogImpl;

  factory GroupConsumptionLog.fromJson(Map<String, dynamic> jsonSerialization) {
    return GroupConsumptionLog(
      id: jsonSerialization['id'] as int?,
      shareGroupUuid: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['shareGroupUuid'],
      ),
      entitlementId: jsonSerialization['entitlementId'] as int,
      amount: (jsonSerialization['amount'] as num).toDouble(),
      reason: jsonSerialization['reason'] as String,
      timestamp: jsonSerialization['timestamp'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['timestamp']),
      consumingAccountUuid: jsonSerialization['consumingAccountUuid'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['consumingAccountUuid'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i1.UuidValue shareGroupUuid;

  int entitlementId;

  double amount;

  String reason;

  DateTime timestamp;

  _i1.UuidValue? consumingAccountUuid;

  /// Returns a shallow copy of this [GroupConsumptionLog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GroupConsumptionLog copyWith({
    int? id,
    _i1.UuidValue? shareGroupUuid,
    int? entitlementId,
    double? amount,
    String? reason,
    DateTime? timestamp,
    _i1.UuidValue? consumingAccountUuid,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.GroupConsumptionLog',
      if (id != null) 'id': id,
      'shareGroupUuid': shareGroupUuid.toJson(),
      'entitlementId': entitlementId,
      'amount': amount,
      'reason': reason,
      'timestamp': timestamp.toJson(),
      if (consumingAccountUuid != null)
        'consumingAccountUuid': consumingAccountUuid?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupConsumptionLogImpl extends GroupConsumptionLog {
  _GroupConsumptionLogImpl({
    int? id,
    required _i1.UuidValue shareGroupUuid,
    required int entitlementId,
    required double amount,
    required String reason,
    DateTime? timestamp,
    _i1.UuidValue? consumingAccountUuid,
  }) : super._(
         id: id,
         shareGroupUuid: shareGroupUuid,
         entitlementId: entitlementId,
         amount: amount,
         reason: reason,
         timestamp: timestamp,
         consumingAccountUuid: consumingAccountUuid,
       );

  /// Returns a shallow copy of this [GroupConsumptionLog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GroupConsumptionLog copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? shareGroupUuid,
    int? entitlementId,
    double? amount,
    String? reason,
    DateTime? timestamp,
    Object? consumingAccountUuid = _Undefined,
  }) {
    return GroupConsumptionLog(
      id: id is int? ? id : this.id,
      shareGroupUuid: shareGroupUuid ?? this.shareGroupUuid,
      entitlementId: entitlementId ?? this.entitlementId,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
      consumingAccountUuid: consumingAccountUuid is _i1.UuidValue?
          ? consumingAccountUuid
          : this.consumingAccountUuid,
    );
  }
}
