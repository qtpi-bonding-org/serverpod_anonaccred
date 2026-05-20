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

abstract class EphemeralAccreditationGroup implements _i1.SerializableModel {
  EphemeralAccreditationGroup._({
    this.id,
    required this.accountUuid,
    required this.shareGroupUuid,
    required this.transactionTimestamp,
  });

  factory EphemeralAccreditationGroup({
    int? id,
    required _i1.UuidValue accountUuid,
    required _i1.UuidValue shareGroupUuid,
    required DateTime transactionTimestamp,
  }) = _EphemeralAccreditationGroupImpl;

  factory EphemeralAccreditationGroup.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return EphemeralAccreditationGroup(
      id: jsonSerialization['id'] as int?,
      accountUuid: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountUuid'],
      ),
      shareGroupUuid: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['shareGroupUuid'],
      ),
      transactionTimestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['transactionTimestamp'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i1.UuidValue accountUuid;

  _i1.UuidValue shareGroupUuid;

  DateTime transactionTimestamp;

  /// Returns a shallow copy of this [EphemeralAccreditationGroup]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EphemeralAccreditationGroup copyWith({
    int? id,
    _i1.UuidValue? accountUuid,
    _i1.UuidValue? shareGroupUuid,
    DateTime? transactionTimestamp,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.EphemeralAccreditationGroup',
      if (id != null) 'id': id,
      'accountUuid': accountUuid.toJson(),
      'shareGroupUuid': shareGroupUuid.toJson(),
      'transactionTimestamp': transactionTimestamp.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EphemeralAccreditationGroupImpl extends EphemeralAccreditationGroup {
  _EphemeralAccreditationGroupImpl({
    int? id,
    required _i1.UuidValue accountUuid,
    required _i1.UuidValue shareGroupUuid,
    required DateTime transactionTimestamp,
  }) : super._(
         id: id,
         accountUuid: accountUuid,
         shareGroupUuid: shareGroupUuid,
         transactionTimestamp: transactionTimestamp,
       );

  /// Returns a shallow copy of this [EphemeralAccreditationGroup]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EphemeralAccreditationGroup copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? accountUuid,
    _i1.UuidValue? shareGroupUuid,
    DateTime? transactionTimestamp,
  }) {
    return EphemeralAccreditationGroup(
      id: id is int? ? id : this.id,
      accountUuid: accountUuid ?? this.accountUuid,
      shareGroupUuid: shareGroupUuid ?? this.shareGroupUuid,
      transactionTimestamp: transactionTimestamp ?? this.transactionTimestamp,
    );
  }
}
