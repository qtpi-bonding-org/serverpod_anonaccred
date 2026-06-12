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

abstract class ShareGroup implements _i1.SerializableModel {
  ShareGroup._({
    this.id,
    required this.ultimateSigningPublicKeyHex,
    required this.ultimatePublicKey,
    required this.encryptedDataKey,
    DateTime? createdAt,
    int? keyEpoch,
  }) : createdAt = createdAt ?? DateTime.now(),
       keyEpoch = keyEpoch ?? 0;

  factory ShareGroup({
    _i1.UuidValue? id,
    required String ultimateSigningPublicKeyHex,
    required String ultimatePublicKey,
    required String encryptedDataKey,
    DateTime? createdAt,
    int? keyEpoch,
  }) = _ShareGroupImpl;

  factory ShareGroup.fromJson(Map<String, dynamic> jsonSerialization) {
    return ShareGroup(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ultimateSigningPublicKeyHex:
          jsonSerialization['ultimateSigningPublicKeyHex'] as String,
      ultimatePublicKey: jsonSerialization['ultimatePublicKey'] as String,
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      keyEpoch: jsonSerialization['keyEpoch'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  String ultimateSigningPublicKeyHex;

  String ultimatePublicKey;

  String encryptedDataKey;

  DateTime createdAt;

  int keyEpoch;

  /// Returns a shallow copy of this [ShareGroup]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ShareGroup copyWith({
    _i1.UuidValue? id,
    String? ultimateSigningPublicKeyHex,
    String? ultimatePublicKey,
    String? encryptedDataKey,
    DateTime? createdAt,
    int? keyEpoch,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.ShareGroup',
      if (id != null) 'id': id?.toJson(),
      'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
      'ultimatePublicKey': ultimatePublicKey,
      'encryptedDataKey': encryptedDataKey,
      'createdAt': createdAt.toJson(),
      'keyEpoch': keyEpoch,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ShareGroupImpl extends ShareGroup {
  _ShareGroupImpl({
    _i1.UuidValue? id,
    required String ultimateSigningPublicKeyHex,
    required String ultimatePublicKey,
    required String encryptedDataKey,
    DateTime? createdAt,
    int? keyEpoch,
  }) : super._(
         id: id,
         ultimateSigningPublicKeyHex: ultimateSigningPublicKeyHex,
         ultimatePublicKey: ultimatePublicKey,
         encryptedDataKey: encryptedDataKey,
         createdAt: createdAt,
         keyEpoch: keyEpoch,
       );

  /// Returns a shallow copy of this [ShareGroup]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ShareGroup copyWith({
    Object? id = _Undefined,
    String? ultimateSigningPublicKeyHex,
    String? ultimatePublicKey,
    String? encryptedDataKey,
    DateTime? createdAt,
    int? keyEpoch,
  }) {
    return ShareGroup(
      id: id is _i1.UuidValue? ? id : this.id,
      ultimateSigningPublicKeyHex:
          ultimateSigningPublicKeyHex ?? this.ultimateSigningPublicKeyHex,
      ultimatePublicKey: ultimatePublicKey ?? this.ultimatePublicKey,
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      createdAt: createdAt ?? this.createdAt,
      keyEpoch: keyEpoch ?? this.keyEpoch,
    );
  }
}
