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

abstract class EphemeralAccreditation implements _i1.SerializableModel {
  EphemeralAccreditation._({
    this.id,
    required this.accountId,
    required this.transactionTimestamp,
  });

  factory EphemeralAccreditation({
    int? id,
    required int accountId,
    required DateTime transactionTimestamp,
  }) = _EphemeralAccreditationImpl;

  factory EphemeralAccreditation.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return EphemeralAccreditation(
      id: jsonSerialization['id'] as int?,
      accountId: jsonSerialization['accountId'] as int,
      transactionTimestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['transactionTimestamp'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int accountId;

  DateTime transactionTimestamp;

  /// Returns a shallow copy of this [EphemeralAccreditation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EphemeralAccreditation copyWith({
    int? id,
    int? accountId,
    DateTime? transactionTimestamp,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.EphemeralAccreditation',
      if (id != null) 'id': id,
      'accountId': accountId,
      'transactionTimestamp': transactionTimestamp.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EphemeralAccreditationImpl extends EphemeralAccreditation {
  _EphemeralAccreditationImpl({
    int? id,
    required int accountId,
    required DateTime transactionTimestamp,
  }) : super._(
         id: id,
         accountId: accountId,
         transactionTimestamp: transactionTimestamp,
       );

  /// Returns a shallow copy of this [EphemeralAccreditation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EphemeralAccreditation copyWith({
    Object? id = _Undefined,
    int? accountId,
    DateTime? transactionTimestamp,
  }) {
    return EphemeralAccreditation(
      id: id is int? ? id : this.id,
      accountId: accountId ?? this.accountId,
      transactionTimestamp: transactionTimestamp ?? this.transactionTimestamp,
    );
  }
}
