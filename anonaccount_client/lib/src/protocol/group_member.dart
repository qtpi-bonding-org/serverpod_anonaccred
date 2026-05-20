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
    required this.memberPublicKey,
    required this.encryptedDataKey,
    DateTime? joinedAt,
    DateTime? lastActive,
    bool? isRevoked,
    this.addedBySignerPublicKeyHex,
    this.addedByAttestation,
    this.revokedBySignerPublicKeyHex,
    this.revokedByAttestation,
  }) : joinedAt = joinedAt ?? DateTime.now(),
       lastActive = lastActive ?? DateTime.now(),
       isRevoked = isRevoked ?? false;

  factory GroupMember({
    _i1.UuidValue? id,
    required _i1.UuidValue shareGroupId,
    _i2.ShareGroup? shareGroup,
    required _i1.UuidValue anonAccountId,
    _i3.AnonAccount? anonAccount,
    required _i4.GroupMemberRole role,
    required String memberSigningPublicKeyHex,
    required String memberPublicKey,
    required String encryptedDataKey,
    DateTime? joinedAt,
    DateTime? lastActive,
    bool? isRevoked,
    String? addedBySignerPublicKeyHex,
    String? addedByAttestation,
    String? revokedBySignerPublicKeyHex,
    String? revokedByAttestation,
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
      memberPublicKey: jsonSerialization['memberPublicKey'] as String,
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
      lastActive: jsonSerialization['lastActive'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastActive']),
      isRevoked: jsonSerialization['isRevoked'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isRevoked']),
      addedBySignerPublicKeyHex:
          jsonSerialization['addedBySignerPublicKeyHex'] as String?,
      addedByAttestation: jsonSerialization['addedByAttestation'] as String?,
      revokedBySignerPublicKeyHex:
          jsonSerialization['revokedBySignerPublicKeyHex'] as String?,
      revokedByAttestation:
          jsonSerialization['revokedByAttestation'] as String?,
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

  String memberPublicKey;

  String encryptedDataKey;

  DateTime joinedAt;

  DateTime lastActive;

  bool isRevoked;

  String? addedBySignerPublicKeyHex;

  String? addedByAttestation;

  String? revokedBySignerPublicKeyHex;

  String? revokedByAttestation;

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
    String? memberPublicKey,
    String? encryptedDataKey,
    DateTime? joinedAt,
    DateTime? lastActive,
    bool? isRevoked,
    String? addedBySignerPublicKeyHex,
    String? addedByAttestation,
    String? revokedBySignerPublicKeyHex,
    String? revokedByAttestation,
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
      'memberPublicKey': memberPublicKey,
      'encryptedDataKey': encryptedDataKey,
      'joinedAt': joinedAt.toJson(),
      'lastActive': lastActive.toJson(),
      'isRevoked': isRevoked,
      if (addedBySignerPublicKeyHex != null)
        'addedBySignerPublicKeyHex': addedBySignerPublicKeyHex,
      if (addedByAttestation != null) 'addedByAttestation': addedByAttestation,
      if (revokedBySignerPublicKeyHex != null)
        'revokedBySignerPublicKeyHex': revokedBySignerPublicKeyHex,
      if (revokedByAttestation != null)
        'revokedByAttestation': revokedByAttestation,
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
    required String memberPublicKey,
    required String encryptedDataKey,
    DateTime? joinedAt,
    DateTime? lastActive,
    bool? isRevoked,
    String? addedBySignerPublicKeyHex,
    String? addedByAttestation,
    String? revokedBySignerPublicKeyHex,
    String? revokedByAttestation,
  }) : super._(
         id: id,
         shareGroupId: shareGroupId,
         shareGroup: shareGroup,
         anonAccountId: anonAccountId,
         anonAccount: anonAccount,
         role: role,
         memberSigningPublicKeyHex: memberSigningPublicKeyHex,
         memberPublicKey: memberPublicKey,
         encryptedDataKey: encryptedDataKey,
         joinedAt: joinedAt,
         lastActive: lastActive,
         isRevoked: isRevoked,
         addedBySignerPublicKeyHex: addedBySignerPublicKeyHex,
         addedByAttestation: addedByAttestation,
         revokedBySignerPublicKeyHex: revokedBySignerPublicKeyHex,
         revokedByAttestation: revokedByAttestation,
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
    String? memberPublicKey,
    String? encryptedDataKey,
    DateTime? joinedAt,
    DateTime? lastActive,
    bool? isRevoked,
    Object? addedBySignerPublicKeyHex = _Undefined,
    Object? addedByAttestation = _Undefined,
    Object? revokedBySignerPublicKeyHex = _Undefined,
    Object? revokedByAttestation = _Undefined,
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
      memberPublicKey: memberPublicKey ?? this.memberPublicKey,
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActive: lastActive ?? this.lastActive,
      isRevoked: isRevoked ?? this.isRevoked,
      addedBySignerPublicKeyHex: addedBySignerPublicKeyHex is String?
          ? addedBySignerPublicKeyHex
          : this.addedBySignerPublicKeyHex,
      addedByAttestation: addedByAttestation is String?
          ? addedByAttestation
          : this.addedByAttestation,
      revokedBySignerPublicKeyHex: revokedBySignerPublicKeyHex is String?
          ? revokedBySignerPublicKeyHex
          : this.revokedBySignerPublicKeyHex,
      revokedByAttestation: revokedByAttestation is String?
          ? revokedByAttestation
          : this.revokedByAttestation,
    );
  }
}
