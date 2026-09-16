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
import 'package:serverpod/serverpod.dart' as _is;
import 'group_member_role.dart' as _imgpb098;

/// What one member may see about another. Deliberately omits
/// encryptedMemberKey and encryptedDataKey: both are ciphertext only that
/// member can open, so publishing them to the group buys nothing and
/// invites harvesting against a future backup leak.
abstract class GroupMemberView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  GroupMemberView._({
    required this.memberId,
    required this.shareGroupId,
    required this.anonAccountId,
    required this.role,
    required this.memberSigningPublicKeyHex,
    required this.memberEncryptionPublicKeyHex,
    required this.joinedAt,
  });

  factory GroupMemberView({
    required _is.UuidValue memberId,
    required _is.UuidValue shareGroupId,
    required _is.UuidValue anonAccountId,
    required _imgpb098.GroupMemberRole role,
    required String memberSigningPublicKeyHex,
    required String memberEncryptionPublicKeyHex,
    required DateTime joinedAt,
  }) = _GroupMemberViewImpl;

  factory GroupMemberView.fromJson(Map<String, dynamic> jsonSerialization) {
    return GroupMemberView(
      memberId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['memberId'],
      ),
      shareGroupId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['shareGroupId'],
      ),
      anonAccountId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['anonAccountId'],
      ),
      role: _imgpb098.GroupMemberRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      memberSigningPublicKeyHex:
          jsonSerialization['memberSigningPublicKeyHex'] as String,
      memberEncryptionPublicKeyHex:
          jsonSerialization['memberEncryptionPublicKeyHex'] as String,
      joinedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['joinedAt'],
      ),
    );
  }

  _is.UuidValue memberId;

  _is.UuidValue shareGroupId;

  _is.UuidValue anonAccountId;

  _imgpb098.GroupMemberRole role;

  String memberSigningPublicKeyHex;

  String memberEncryptionPublicKeyHex;

  DateTime joinedAt;

  /// Returns a shallow copy of this [GroupMemberView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  GroupMemberView copyWith({
    _is.UuidValue? memberId,
    _is.UuidValue? shareGroupId,
    _is.UuidValue? anonAccountId,
    _imgpb098.GroupMemberRole? role,
    String? memberSigningPublicKeyHex,
    String? memberEncryptionPublicKeyHex,
    DateTime? joinedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.GroupMemberView',
      'memberId': memberId.toJson(),
      'shareGroupId': shareGroupId.toJson(),
      'anonAccountId': anonAccountId.toJson(),
      'role': role.toJson(),
      'memberSigningPublicKeyHex': memberSigningPublicKeyHex,
      'memberEncryptionPublicKeyHex': memberEncryptionPublicKeyHex,
      'joinedAt': joinedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.GroupMemberView',
      'memberId': memberId.toJson(),
      'shareGroupId': shareGroupId.toJson(),
      'anonAccountId': anonAccountId.toJson(),
      'role': role.toJson(),
      'memberSigningPublicKeyHex': memberSigningPublicKeyHex,
      'memberEncryptionPublicKeyHex': memberEncryptionPublicKeyHex,
      'joinedAt': joinedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _GroupMemberViewImpl extends GroupMemberView {
  _GroupMemberViewImpl({
    required _is.UuidValue memberId,
    required _is.UuidValue shareGroupId,
    required _is.UuidValue anonAccountId,
    required _imgpb098.GroupMemberRole role,
    required String memberSigningPublicKeyHex,
    required String memberEncryptionPublicKeyHex,
    required DateTime joinedAt,
  }) : super._(
         memberId: memberId,
         shareGroupId: shareGroupId,
         anonAccountId: anonAccountId,
         role: role,
         memberSigningPublicKeyHex: memberSigningPublicKeyHex,
         memberEncryptionPublicKeyHex: memberEncryptionPublicKeyHex,
         joinedAt: joinedAt,
       );

  /// Returns a shallow copy of this [GroupMemberView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  GroupMemberView copyWith({
    _is.UuidValue? memberId,
    _is.UuidValue? shareGroupId,
    _is.UuidValue? anonAccountId,
    _imgpb098.GroupMemberRole? role,
    String? memberSigningPublicKeyHex,
    String? memberEncryptionPublicKeyHex,
    DateTime? joinedAt,
  }) {
    return GroupMemberView(
      memberId: memberId ?? this.memberId,
      shareGroupId: shareGroupId ?? this.shareGroupId,
      anonAccountId: anonAccountId ?? this.anonAccountId,
      role: role ?? this.role,
      memberSigningPublicKeyHex:
          memberSigningPublicKeyHex ?? this.memberSigningPublicKeyHex,
      memberEncryptionPublicKeyHex:
          memberEncryptionPublicKeyHex ?? this.memberEncryptionPublicKeyHex,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
