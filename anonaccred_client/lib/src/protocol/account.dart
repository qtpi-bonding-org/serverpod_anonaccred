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

abstract class AnonAccount implements _i1.SerializableModel {
  AnonAccount._({
    this.id,
    required this.publicMasterKey,
    required this.encryptedDataKey,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AnonAccount({
    int? id,
    required String publicMasterKey,
    required String encryptedDataKey,
    DateTime? createdAt,
  }) = _AnonAccountImpl;

  factory AnonAccount.fromJson(Map<String, dynamic> jsonSerialization) {
    return AnonAccount(
      id: jsonSerialization['id'] as int?,
      publicMasterKey: jsonSerialization['publicMasterKey'] as String,
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String publicMasterKey;

  String encryptedDataKey;

  DateTime createdAt;

  /// Returns a shallow copy of this [AnonAccount]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AnonAccount copyWith({
    int? id,
    String? publicMasterKey,
    String? encryptedDataKey,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.AnonAccount',
      if (id != null) 'id': id,
      'publicMasterKey': publicMasterKey,
      'encryptedDataKey': encryptedDataKey,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AnonAccountImpl extends AnonAccount {
  _AnonAccountImpl({
    int? id,
    required String publicMasterKey,
    required String encryptedDataKey,
    DateTime? createdAt,
  }) : super._(
         id: id,
         publicMasterKey: publicMasterKey,
         encryptedDataKey: encryptedDataKey,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AnonAccount]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AnonAccount copyWith({
    Object? id = _Undefined,
    String? publicMasterKey,
    String? encryptedDataKey,
    DateTime? createdAt,
  }) {
    return AnonAccount(
      id: id is int? ? id : this.id,
      publicMasterKey: publicMasterKey ?? this.publicMasterKey,
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
