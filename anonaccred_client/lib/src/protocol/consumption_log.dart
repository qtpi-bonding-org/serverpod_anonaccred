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

abstract class ConsumptionLog implements _i1.SerializableModel {
  ConsumptionLog._({
    this.id,
    required this.accountUuid,
    required this.entitlementId,
    required this.amount,
    required this.reason,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ConsumptionLog({
    int? id,
    required _i1.UuidValue accountUuid,
    required int entitlementId,
    required double amount,
    required String reason,
    DateTime? timestamp,
  }) = _ConsumptionLogImpl;

  factory ConsumptionLog.fromJson(Map<String, dynamic> jsonSerialization) {
    return ConsumptionLog(
      id: jsonSerialization['id'] as int?,
      accountUuid: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountUuid'],
      ),
      entitlementId: jsonSerialization['entitlementId'] as int,
      amount: (jsonSerialization['amount'] as num).toDouble(),
      reason: jsonSerialization['reason'] as String,
      timestamp: jsonSerialization['timestamp'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['timestamp']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i1.UuidValue accountUuid;

  int entitlementId;

  double amount;

  String reason;

  DateTime timestamp;

  /// Returns a shallow copy of this [ConsumptionLog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ConsumptionLog copyWith({
    int? id,
    _i1.UuidValue? accountUuid,
    int? entitlementId,
    double? amount,
    String? reason,
    DateTime? timestamp,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.ConsumptionLog',
      if (id != null) 'id': id,
      'accountUuid': accountUuid.toJson(),
      'entitlementId': entitlementId,
      'amount': amount,
      'reason': reason,
      'timestamp': timestamp.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ConsumptionLogImpl extends ConsumptionLog {
  _ConsumptionLogImpl({
    int? id,
    required _i1.UuidValue accountUuid,
    required int entitlementId,
    required double amount,
    required String reason,
    DateTime? timestamp,
  }) : super._(
         id: id,
         accountUuid: accountUuid,
         entitlementId: entitlementId,
         amount: amount,
         reason: reason,
         timestamp: timestamp,
       );

  /// Returns a shallow copy of this [ConsumptionLog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ConsumptionLog copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? accountUuid,
    int? entitlementId,
    double? amount,
    String? reason,
    DateTime? timestamp,
  }) {
    return ConsumptionLog(
      id: id is int? ? id : this.id,
      accountUuid: accountUuid ?? this.accountUuid,
      entitlementId: entitlementId ?? this.entitlementId,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
