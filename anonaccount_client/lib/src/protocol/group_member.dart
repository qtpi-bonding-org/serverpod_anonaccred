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
import 'share_group.dart' as _i2;
import 'account.dart' as _i3;
import 'group_member_role.dart' as _i4;
import 'package:anonaccount_client/src/protocol/protocol.dart' as _i5;

abstract class GroupMember implements _i1.SerializableModel {
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
    _i1.UuidValue? id,
    required _i1.UuidValue shareGroupId,
    _i2.ShareGroup? shareGroup,
    required _i1.UuidValue anonAccountId,
    _i3.AnonAccount? anonAccount,
    required _i4.GroupMemberRole role,
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
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      shareGroupId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['shareGroupId'],
      ),
      shareGroup: jsonSerialization['shareGroup'] == null
          ? null
          : _i5.Protocol().deserialize<_i2.ShareGroup>(
              jsonSerialization['shareGroup'],
            ),
      anonAccountId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['anonAccountId'],
      ),
      anonAccount: jsonSerialization['anonAccount'] == null
          ? null
          : _i5.Protocol().deserialize<_i3.AnonAccount>(
              jsonSerialization['anonAccount'],
            ),
      role: _i4.GroupMemberRole.fromJson((jsonSerialization['role'] as String)),
      memberSigningPublicKeyHex:
          jsonSerialization['memberSigningPublicKeyHex'] as String,
      memberEncryptionPublicKeyHex:
          jsonSerialization['memberEncryptionPublicKeyHex'] as String,
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      encryptedMemberKey: jsonSerialization['encryptedMemberKey'] as String,
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
      isRevoked: jsonSerialization['isRevoked'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isRevoked']),
      addedByAttestorPublicKeyHex:
          jsonSerialization['addedByAttestorPublicKeyHex'] as String,
      addedByAttestation: jsonSerialization['addedByAttestation'] as String,
      revokedByAttestorPublicKeyHex:
          jsonSerialization['revokedByAttestorPublicKeyHex'] as String?,
      revokedByAttestation:
          jsonSerialization['revokedByAttestation'] as String?,
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
      keyEpoch: jsonSerialization['keyEpoch'] as int?,
      roleChangedAt: jsonSerialization['roleChangedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
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
  _i1.UuidValue? id;

  _i1.UuidValue shareGroupId;

  _i2.ShareGroup? shareGroup;

  _i1.UuidValue anonAccountId;

  _i3.AnonAccount? anonAccount;

  _i4.GroupMemberRole role;

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
  @_i1.useResult
  GroupMember copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? shareGroupId,
    _i2.ShareGroup? shareGroup,
    _i1.UuidValue? anonAccountId,
    _i3.AnonAccount? anonAccount,
    _i4.GroupMemberRole? role,
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
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupMemberImpl extends GroupMember {
  _GroupMemberImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue shareGroupId,
    _i2.ShareGroup? shareGroup,
    required _i1.UuidValue anonAccountId,
    _i3.AnonAccount? anonAccount,
    required _i4.GroupMemberRole role,
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
  @_i1.useResult
  @override
  GroupMember copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? shareGroupId,
    Object? shareGroup = _Undefined,
    _i1.UuidValue? anonAccountId,
    Object? anonAccount = _Undefined,
    _i4.GroupMemberRole? role,
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
      id: id is _i1.UuidValue? ? id : this.id,
      shareGroupId: shareGroupId ?? this.shareGroupId,
      shareGroup: shareGroup is _i2.ShareGroup?
          ? shareGroup
          : this.shareGroup?.copyWith(),
      anonAccountId: anonAccountId ?? this.anonAccountId,
      anonAccount: anonAccount is _i3.AnonAccount?
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
