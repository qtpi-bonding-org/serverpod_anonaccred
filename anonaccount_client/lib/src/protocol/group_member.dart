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
import 'group_member_role.dart' as _imgpb098;
import 'share_group.dart' as _i97quwy2;

abstract class GroupMember
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  GroupMember._({
    this.id,
    required this.shareGroupId,
    this.shareGroup,
    required this.anonAccountId,
    this.anonAccount,
    required this.role,
    required this.memberSigningPublicKeyHex,
    required this.memberEncryptionPublicKeyHex,
    required this.encryptedDataKey,
    required this.encryptedMemberKey,
    DateTime? joinedAt,
    bool? isRevoked,
    required this.addedByAttestorPublicKeyHex,
    required this.addedByAttestation,
    this.revokedByAttestorPublicKeyHex,
    this.revokedByAttestation,
    this.revokedAt,
    int? keyEpoch,
    this.roleChangedAt,
    this.roleChangedByAttestorPublicKeyHex,
    this.roleChangedByAttestation,
  }) : joinedAt = joinedAt ?? DateTime.now(),
       isRevoked = isRevoked ?? false,
       keyEpoch = keyEpoch ?? 0;

  factory GroupMember({
    _isc.UuidValue? id,
    required _isc.UuidValue shareGroupId,
    _i97quwy2.ShareGroup? shareGroup,
    required _isc.UuidValue anonAccountId,
    _iulmo8pc.AnonAccount? anonAccount,
    required _imgpb098.GroupMemberRole role,
    required String memberSigningPublicKeyHex,
    required String memberEncryptionPublicKeyHex,
    required String encryptedDataKey,
    required String encryptedMemberKey,
    DateTime? joinedAt,
    bool? isRevoked,
    required String addedByAttestorPublicKeyHex,
    required String addedByAttestation,
    String? revokedByAttestorPublicKeyHex,
    String? revokedByAttestation,
    DateTime? revokedAt,
    int? keyEpoch,
    DateTime? roleChangedAt,
    String? roleChangedByAttestorPublicKeyHex,
    String? roleChangedByAttestation,
  }) = _GroupMemberImpl;

  factory GroupMember.fromJson(Map<String, dynamic> jsonSerialization) {
    return GroupMember(
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
      role: _imgpb098.GroupMemberRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      memberSigningPublicKeyHex:
          jsonSerialization['memberSigningPublicKeyHex'] as String,
      memberEncryptionPublicKeyHex:
          jsonSerialization['memberEncryptionPublicKeyHex'] as String,
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      encryptedMemberKey: jsonSerialization['encryptedMemberKey'] as String,
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
      isRevoked: jsonSerialization['isRevoked'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isRevoked']),
      addedByAttestorPublicKeyHex:
          jsonSerialization['addedByAttestorPublicKeyHex'] as String,
      addedByAttestation: jsonSerialization['addedByAttestation'] as String,
      revokedByAttestorPublicKeyHex:
          jsonSerialization['revokedByAttestorPublicKeyHex'] as String?,
      revokedByAttestation:
          jsonSerialization['revokedByAttestation'] as String?,
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
      keyEpoch: jsonSerialization['keyEpoch'] as int?,
      roleChangedAt: jsonSerialization['roleChangedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['roleChangedAt'],
            ),
      roleChangedByAttestorPublicKeyHex:
          jsonSerialization['roleChangedByAttestorPublicKeyHex'] as String?,
      roleChangedByAttestation:
          jsonSerialization['roleChangedByAttestation'] as String?,
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

  _imgpb098.GroupMemberRole role;

  String memberSigningPublicKeyHex;

  String memberEncryptionPublicKeyHex;

  String encryptedDataKey;

  String encryptedMemberKey;

  DateTime joinedAt;

  bool isRevoked;

  String addedByAttestorPublicKeyHex;

  String addedByAttestation;

  String? revokedByAttestorPublicKeyHex;

  String? revokedByAttestation;

  DateTime? revokedAt;

  int keyEpoch;

  DateTime? roleChangedAt;

  String? roleChangedByAttestorPublicKeyHex;

  String? roleChangedByAttestation;

  /// Returns a shallow copy of this [GroupMember]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  GroupMember copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? shareGroupId,
    _i97quwy2.ShareGroup? shareGroup,
    _isc.UuidValue? anonAccountId,
    _iulmo8pc.AnonAccount? anonAccount,
    _imgpb098.GroupMemberRole? role,
    String? memberSigningPublicKeyHex,
    String? memberEncryptionPublicKeyHex,
    String? encryptedDataKey,
    String? encryptedMemberKey,
    DateTime? joinedAt,
    bool? isRevoked,
    String? addedByAttestorPublicKeyHex,
    String? addedByAttestation,
    String? revokedByAttestorPublicKeyHex,
    String? revokedByAttestation,
    DateTime? revokedAt,
    int? keyEpoch,
    DateTime? roleChangedAt,
    String? roleChangedByAttestorPublicKeyHex,
    String? roleChangedByAttestation,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.GroupMember',
      if (id != null) 'id': id?.toJson(),
      'shareGroupId': shareGroupId.toJson(),
      if (shareGroup != null) 'shareGroup': shareGroup?.toJson(),
      'anonAccountId': anonAccountId.toJson(),
      if (anonAccount != null) 'anonAccount': anonAccount?.toJson(),
      'role': role.toJson(),
      'memberSigningPublicKeyHex': memberSigningPublicKeyHex,
      'memberEncryptionPublicKeyHex': memberEncryptionPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'encryptedMemberKey': encryptedMemberKey,
      'joinedAt': joinedAt.toJson(),
      'isRevoked': isRevoked,
      'addedByAttestorPublicKeyHex': addedByAttestorPublicKeyHex,
      'addedByAttestation': addedByAttestation,
      if (revokedByAttestorPublicKeyHex != null)
        'revokedByAttestorPublicKeyHex': revokedByAttestorPublicKeyHex,
      if (revokedByAttestation != null)
        'revokedByAttestation': revokedByAttestation,
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      'keyEpoch': keyEpoch,
      if (roleChangedAt != null) 'roleChangedAt': roleChangedAt?.toJson(),
      if (roleChangedByAttestorPublicKeyHex != null)
        'roleChangedByAttestorPublicKeyHex': roleChangedByAttestorPublicKeyHex,
      if (roleChangedByAttestation != null)
        'roleChangedByAttestation': roleChangedByAttestation,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.GroupMember',
      if (id != null) 'id': id?.toJson(),
      'shareGroupId': shareGroupId.toJson(),
      if (shareGroup != null) 'shareGroup': shareGroup?.toJsonForProtocol(),
      'anonAccountId': anonAccountId.toJson(),
      if (anonAccount != null) 'anonAccount': anonAccount?.toJsonForProtocol(),
      'role': role.toJson(),
      'memberSigningPublicKeyHex': memberSigningPublicKeyHex,
      'memberEncryptionPublicKeyHex': memberEncryptionPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'encryptedMemberKey': encryptedMemberKey,
      'joinedAt': joinedAt.toJson(),
      'isRevoked': isRevoked,
      'addedByAttestorPublicKeyHex': addedByAttestorPublicKeyHex,
      'addedByAttestation': addedByAttestation,
      if (revokedByAttestorPublicKeyHex != null)
        'revokedByAttestorPublicKeyHex': revokedByAttestorPublicKeyHex,
      if (revokedByAttestation != null)
        'revokedByAttestation': revokedByAttestation,
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      'keyEpoch': keyEpoch,
      if (roleChangedAt != null) 'roleChangedAt': roleChangedAt?.toJson(),
      if (roleChangedByAttestorPublicKeyHex != null)
        'roleChangedByAttestorPublicKeyHex': roleChangedByAttestorPublicKeyHex,
      if (roleChangedByAttestation != null)
        'roleChangedByAttestation': roleChangedByAttestation,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupMemberImpl extends GroupMember {
  _GroupMemberImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue shareGroupId,
    _i97quwy2.ShareGroup? shareGroup,
    required _isc.UuidValue anonAccountId,
    _iulmo8pc.AnonAccount? anonAccount,
    required _imgpb098.GroupMemberRole role,
    required String memberSigningPublicKeyHex,
    required String memberEncryptionPublicKeyHex,
    required String encryptedDataKey,
    required String encryptedMemberKey,
    DateTime? joinedAt,
    bool? isRevoked,
    required String addedByAttestorPublicKeyHex,
    required String addedByAttestation,
    String? revokedByAttestorPublicKeyHex,
    String? revokedByAttestation,
    DateTime? revokedAt,
    int? keyEpoch,
    DateTime? roleChangedAt,
    String? roleChangedByAttestorPublicKeyHex,
    String? roleChangedByAttestation,
  }) : super._(
         id: id,
         shareGroupId: shareGroupId,
         shareGroup: shareGroup,
         anonAccountId: anonAccountId,
         anonAccount: anonAccount,
         role: role,
         memberSigningPublicKeyHex: memberSigningPublicKeyHex,
         memberEncryptionPublicKeyHex: memberEncryptionPublicKeyHex,
         encryptedDataKey: encryptedDataKey,
         encryptedMemberKey: encryptedMemberKey,
         joinedAt: joinedAt,
         isRevoked: isRevoked,
         addedByAttestorPublicKeyHex: addedByAttestorPublicKeyHex,
         addedByAttestation: addedByAttestation,
         revokedByAttestorPublicKeyHex: revokedByAttestorPublicKeyHex,
         revokedByAttestation: revokedByAttestation,
         revokedAt: revokedAt,
         keyEpoch: keyEpoch,
         roleChangedAt: roleChangedAt,
         roleChangedByAttestorPublicKeyHex: roleChangedByAttestorPublicKeyHex,
         roleChangedByAttestation: roleChangedByAttestation,
       );

  /// Returns a shallow copy of this [GroupMember]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  GroupMember copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? shareGroupId,
    Object? shareGroup = _Undefined,
    _isc.UuidValue? anonAccountId,
    Object? anonAccount = _Undefined,
    _imgpb098.GroupMemberRole? role,
    String? memberSigningPublicKeyHex,
    String? memberEncryptionPublicKeyHex,
    String? encryptedDataKey,
    String? encryptedMemberKey,
    DateTime? joinedAt,
    bool? isRevoked,
    String? addedByAttestorPublicKeyHex,
    String? addedByAttestation,
    Object? revokedByAttestorPublicKeyHex = _Undefined,
    Object? revokedByAttestation = _Undefined,
    Object? revokedAt = _Undefined,
    int? keyEpoch,
    Object? roleChangedAt = _Undefined,
    Object? roleChangedByAttestorPublicKeyHex = _Undefined,
    Object? roleChangedByAttestation = _Undefined,
  }) {
    return GroupMember(
      id: id is _isc.UuidValue? ? id : this.id,
      shareGroupId: shareGroupId ?? this.shareGroupId,
      shareGroup: shareGroup is _i97quwy2.ShareGroup?
          ? shareGroup
          : this.shareGroup?.copyWith(),
      anonAccountId: anonAccountId ?? this.anonAccountId,
      anonAccount: anonAccount is _iulmo8pc.AnonAccount?
          ? anonAccount
          : this.anonAccount?.copyWith(),
      role: role ?? this.role,
      memberSigningPublicKeyHex:
          memberSigningPublicKeyHex ?? this.memberSigningPublicKeyHex,
      memberEncryptionPublicKeyHex:
          memberEncryptionPublicKeyHex ?? this.memberEncryptionPublicKeyHex,
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      encryptedMemberKey: encryptedMemberKey ?? this.encryptedMemberKey,
      joinedAt: joinedAt ?? this.joinedAt,
      isRevoked: isRevoked ?? this.isRevoked,
      addedByAttestorPublicKeyHex:
          addedByAttestorPublicKeyHex ?? this.addedByAttestorPublicKeyHex,
      addedByAttestation: addedByAttestation ?? this.addedByAttestation,
      revokedByAttestorPublicKeyHex: revokedByAttestorPublicKeyHex is String?
          ? revokedByAttestorPublicKeyHex
          : this.revokedByAttestorPublicKeyHex,
      revokedByAttestation: revokedByAttestation is String?
          ? revokedByAttestation
          : this.revokedByAttestation,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
      keyEpoch: keyEpoch ?? this.keyEpoch,
      roleChangedAt: roleChangedAt is DateTime?
          ? roleChangedAt
          : this.roleChangedAt,
      roleChangedByAttestorPublicKeyHex:
          roleChangedByAttestorPublicKeyHex is String?
          ? roleChangedByAttestorPublicKeyHex
          : this.roleChangedByAttestorPublicKeyHex,
      roleChangedByAttestation: roleChangedByAttestation is String?
          ? roleChangedByAttestation
          : this.roleChangedByAttestation,
    );
  }
}
