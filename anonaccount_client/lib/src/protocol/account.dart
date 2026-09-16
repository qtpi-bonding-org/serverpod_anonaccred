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

abstract class AnonAccount
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AnonAccount._({
    this.id,
    required this.ultimateSigningPublicKeyHex,
    required this.encryptedDataKey,
    required this.ultimateEncryptionPublicKeyHex,
    DateTime? createdAt,
    int? keyEpoch,
  }) : createdAt = createdAt ?? DateTime.now(),
       keyEpoch = keyEpoch ?? 0;

  factory AnonAccount({
    _isc.UuidValue? id,
    required String ultimateSigningPublicKeyHex,
    required String encryptedDataKey,
    required String ultimateEncryptionPublicKeyHex,
    DateTime? createdAt,
    int? keyEpoch,
  }) = _AnonAccountImpl;

  factory AnonAccount.fromJson(Map<String, dynamic> jsonSerialization) {
    return AnonAccount(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ultimateSigningPublicKeyHex:
          jsonSerialization['ultimateSigningPublicKeyHex'] as String,
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      ultimateEncryptionPublicKeyHex:
          jsonSerialization['ultimateEncryptionPublicKeyHex'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      keyEpoch: jsonSerialization['keyEpoch'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  String ultimateSigningPublicKeyHex;

  String encryptedDataKey;

  String ultimateEncryptionPublicKeyHex;

  DateTime createdAt;

  int keyEpoch;

  /// Returns a shallow copy of this [AnonAccount]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AnonAccount copyWith({
    _isc.UuidValue? id,
    String? ultimateSigningPublicKeyHex,
    String? encryptedDataKey,
    String? ultimateEncryptionPublicKeyHex,
    DateTime? createdAt,
    int? keyEpoch,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.AnonAccount',
      if (id != null) 'id': id?.toJson(),
      'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'ultimateEncryptionPublicKeyHex': ultimateEncryptionPublicKeyHex,
      'createdAt': createdAt.toJson(),
      'keyEpoch': keyEpoch,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.AnonAccount',
      if (id != null) 'id': id?.toJson(),
      'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'ultimateEncryptionPublicKeyHex': ultimateEncryptionPublicKeyHex,
      'createdAt': createdAt.toJson(),
      'keyEpoch': keyEpoch,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AnonAccountImpl extends AnonAccount {
  _AnonAccountImpl({
    _isc.UuidValue? id,
    required String ultimateSigningPublicKeyHex,
    required String encryptedDataKey,
    required String ultimateEncryptionPublicKeyHex,
    DateTime? createdAt,
    int? keyEpoch,
  }) : super._(
         id: id,
         ultimateSigningPublicKeyHex: ultimateSigningPublicKeyHex,
         encryptedDataKey: encryptedDataKey,
         ultimateEncryptionPublicKeyHex: ultimateEncryptionPublicKeyHex,
         createdAt: createdAt,
         keyEpoch: keyEpoch,
       );

  /// Returns a shallow copy of this [AnonAccount]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AnonAccount copyWith({
    Object? id = _Undefined,
    String? ultimateSigningPublicKeyHex,
    String? encryptedDataKey,
    String? ultimateEncryptionPublicKeyHex,
    DateTime? createdAt,
    int? keyEpoch,
  }) {
    return AnonAccount(
      id: id is _isc.UuidValue? ? id : this.id,
      ultimateSigningPublicKeyHex:
          ultimateSigningPublicKeyHex ?? this.ultimateSigningPublicKeyHex,
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      ultimateEncryptionPublicKeyHex:
          ultimateEncryptionPublicKeyHex ?? this.ultimateEncryptionPublicKeyHex,
      createdAt: createdAt ?? this.createdAt,
      keyEpoch: keyEpoch ?? this.keyEpoch,
    );
  }
}
