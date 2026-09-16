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
import 'package:anonaccount_client/src/protocol/protocol.dart' as _iki990kh;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'account.dart' as _iulmo8pc;
import 'share_group.dart' as _i97quwy2;

abstract class GroupOwner
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  GroupOwner._({
    this.id,
    required this.shareGroupId,
    this.shareGroup,
    required this.anonAccountId,
    this.anonAccount,
    required this.encryptedUltimateKey,
    required this.addedByAttestorPublicKeyHex,
    required this.addedByAttestation,
    int? keyEpoch,
    DateTime? createdAt,
    bool? isRevoked,
    this.revokedAt,
    this.revokedByAttestorPublicKeyHex,
    this.revokedByAttestation,
  }) : keyEpoch = keyEpoch ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       isRevoked = isRevoked ?? false;

  factory GroupOwner({
    _isc.UuidValue? id,
    required _isc.UuidValue shareGroupId,
    _i97quwy2.ShareGroup? shareGroup,
    required _isc.UuidValue anonAccountId,
    _iulmo8pc.AnonAccount? anonAccount,
    required String encryptedUltimateKey,
    required String addedByAttestorPublicKeyHex,
    required String addedByAttestation,
    int? keyEpoch,
    DateTime? createdAt,
    bool? isRevoked,
    DateTime? revokedAt,
    String? revokedByAttestorPublicKeyHex,
    String? revokedByAttestation,
  }) = _GroupOwnerImpl;

  factory GroupOwner.fromJson(Map<String, dynamic> jsonSerialization) {
    return GroupOwner(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      shareGroupId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['shareGroupId'],
      ),
      shareGroup: jsonSerialization['shareGroup'] == null
          ? null
          : _iki990kh.Protocol().deserialize<_i97quwy2.ShareGroup>(
              jsonSerialization['shareGroup'],
            ),
      anonAccountId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['anonAccountId'],
      ),
      anonAccount: jsonSerialization['anonAccount'] == null
          ? null
          : _iki990kh.Protocol().deserialize<_iulmo8pc.AnonAccount>(
              jsonSerialization['anonAccount'],
            ),
      encryptedUltimateKey: jsonSerialization['encryptedUltimateKey'] as String,
      addedByAttestorPublicKeyHex:
          jsonSerialization['addedByAttestorPublicKeyHex'] as String,
      addedByAttestation: jsonSerialization['addedByAttestation'] as String,
      keyEpoch: jsonSerialization['keyEpoch'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      isRevoked: jsonSerialization['isRevoked'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isRevoked']),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
      revokedByAttestorPublicKeyHex:
          jsonSerialization['revokedByAttestorPublicKeyHex'] as String?,
      revokedByAttestation:
          jsonSerialization['revokedByAttestation'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue shareGroupId;

  _i97quwy2.ShareGroup? shareGroup;

  _isc.UuidValue anonAccountId;

  _iulmo8pc.AnonAccount? anonAccount;

  String encryptedUltimateKey;

  String addedByAttestorPublicKeyHex;

  String addedByAttestation;

  int keyEpoch;

  DateTime createdAt;

  bool isRevoked;

  DateTime? revokedAt;

  String? revokedByAttestorPublicKeyHex;

  String? revokedByAttestation;

  /// Returns a shallow copy of this [GroupOwner]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  GroupOwner copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? shareGroupId,
    _i97quwy2.ShareGroup? shareGroup,
    _isc.UuidValue? anonAccountId,
    _iulmo8pc.AnonAccount? anonAccount,
    String? encryptedUltimateKey,
    String? addedByAttestorPublicKeyHex,
    String? addedByAttestation,
    int? keyEpoch,
    DateTime? createdAt,
    bool? isRevoked,
    DateTime? revokedAt,
    String? revokedByAttestorPublicKeyHex,
    String? revokedByAttestation,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.GroupOwner',
      if (id != null) 'id': id?.toJson(),
      'shareGroupId': shareGroupId.toJson(),
      if (shareGroup != null) 'shareGroup': shareGroup?.toJson(),
      'anonAccountId': anonAccountId.toJson(),
      if (anonAccount != null) 'anonAccount': anonAccount?.toJson(),
      'encryptedUltimateKey': encryptedUltimateKey,
      'addedByAttestorPublicKeyHex': addedByAttestorPublicKeyHex,
      'addedByAttestation': addedByAttestation,
      'keyEpoch': keyEpoch,
      'createdAt': createdAt.toJson(),
      'isRevoked': isRevoked,
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      if (revokedByAttestorPublicKeyHex != null)
        'revokedByAttestorPublicKeyHex': revokedByAttestorPublicKeyHex,
      if (revokedByAttestation != null)
        'revokedByAttestation': revokedByAttestation,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.GroupOwner',
      if (id != null) 'id': id?.toJson(),
      'shareGroupId': shareGroupId.toJson(),
      if (shareGroup != null) 'shareGroup': shareGroup?.toJsonForProtocol(),
      'anonAccountId': anonAccountId.toJson(),
      if (anonAccount != null) 'anonAccount': anonAccount?.toJsonForProtocol(),
      'encryptedUltimateKey': encryptedUltimateKey,
      'addedByAttestorPublicKeyHex': addedByAttestorPublicKeyHex,
      'addedByAttestation': addedByAttestation,
      'keyEpoch': keyEpoch,
      'createdAt': createdAt.toJson(),
      'isRevoked': isRevoked,
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      if (revokedByAttestorPublicKeyHex != null)
        'revokedByAttestorPublicKeyHex': revokedByAttestorPublicKeyHex,
      if (revokedByAttestation != null)
        'revokedByAttestation': revokedByAttestation,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupOwnerImpl extends GroupOwner {
  _GroupOwnerImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue shareGroupId,
    _i97quwy2.ShareGroup? shareGroup,
    required _isc.UuidValue anonAccountId,
    _iulmo8pc.AnonAccount? anonAccount,
    required String encryptedUltimateKey,
    required String addedByAttestorPublicKeyHex,
    required String addedByAttestation,
    int? keyEpoch,
    DateTime? createdAt,
    bool? isRevoked,
    DateTime? revokedAt,
    String? revokedByAttestorPublicKeyHex,
    String? revokedByAttestation,
  }) : super._(
         id: id,
         shareGroupId: shareGroupId,
         shareGroup: shareGroup,
         anonAccountId: anonAccountId,
         anonAccount: anonAccount,
         encryptedUltimateKey: encryptedUltimateKey,
         addedByAttestorPublicKeyHex: addedByAttestorPublicKeyHex,
         addedByAttestation: addedByAttestation,
         keyEpoch: keyEpoch,
         createdAt: createdAt,
         isRevoked: isRevoked,
         revokedAt: revokedAt,
         revokedByAttestorPublicKeyHex: revokedByAttestorPublicKeyHex,
         revokedByAttestation: revokedByAttestation,
       );

  /// Returns a shallow copy of this [GroupOwner]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  GroupOwner copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? shareGroupId,
    Object? shareGroup = _Undefined,
    _isc.UuidValue? anonAccountId,
    Object? anonAccount = _Undefined,
    String? encryptedUltimateKey,
    String? addedByAttestorPublicKeyHex,
    String? addedByAttestation,
    int? keyEpoch,
    DateTime? createdAt,
    bool? isRevoked,
    Object? revokedAt = _Undefined,
    Object? revokedByAttestorPublicKeyHex = _Undefined,
    Object? revokedByAttestation = _Undefined,
  }) {
    return GroupOwner(
      id: id is _isc.UuidValue? ? id : this.id,
      shareGroupId: shareGroupId ?? this.shareGroupId,
      shareGroup: shareGroup is _i97quwy2.ShareGroup?
          ? shareGroup
          : this.shareGroup?.copyWith(),
      anonAccountId: anonAccountId ?? this.anonAccountId,
      anonAccount: anonAccount is _iulmo8pc.AnonAccount?
          ? anonAccount
          : this.anonAccount?.copyWith(),
      encryptedUltimateKey: encryptedUltimateKey ?? this.encryptedUltimateKey,
      addedByAttestorPublicKeyHex:
          addedByAttestorPublicKeyHex ?? this.addedByAttestorPublicKeyHex,
      addedByAttestation: addedByAttestation ?? this.addedByAttestation,
      keyEpoch: keyEpoch ?? this.keyEpoch,
      createdAt: createdAt ?? this.createdAt,
      isRevoked: isRevoked ?? this.isRevoked,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
      revokedByAttestorPublicKeyHex: revokedByAttestorPublicKeyHex is String?
          ? revokedByAttestorPublicKeyHex
          : this.revokedByAttestorPublicKeyHex,
      revokedByAttestation: revokedByAttestation is String?
          ? revokedByAttestation
          : this.revokedByAttestation,
    );
  }
}
