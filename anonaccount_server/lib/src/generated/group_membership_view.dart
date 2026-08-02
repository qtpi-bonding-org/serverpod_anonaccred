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
import 'package:serverpod/serverpod.dart' as _i1;
import 'group_member_role.dart' as _i2;

abstract class GroupMembershipView
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  GroupMembershipView._({
    required this.memberId,
    required this.shareGroupId,
    required this.role,
    required this.memberSigningPublicKeyHex,
    required this.memberEncryptedDataKey,
    this.deviceEncryptedDataKey,
    required this.joinedAt,
  });

  factory GroupMembershipView({
    required _i1.UuidValue memberId,
    required _i1.UuidValue shareGroupId,
    required _i2.GroupMemberRole role,
    required String memberSigningPublicKeyHex,
    required String memberEncryptedDataKey,
    String? deviceEncryptedDataKey,
    required DateTime joinedAt,
  }) = _GroupMembershipViewImpl;

  factory GroupMembershipView.fromJson(Map<String, dynamic> jsonSerialization) {
    return GroupMembershipView(
      memberId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['memberId'],
      ),
      shareGroupId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['shareGroupId'],
      ),
      role: _i2.GroupMemberRole.fromJson((jsonSerialization['role'] as String)),
      memberSigningPublicKeyHex:
          jsonSerialization['memberSigningPublicKeyHex'] as String,
      memberEncryptedDataKey:
          jsonSerialization['memberEncryptedDataKey'] as String,
      deviceEncryptedDataKey:
          jsonSerialization['deviceEncryptedDataKey'] as String?,
      joinedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['joinedAt'],
      ),
    );
  }

  _i1.UuidValue memberId;

  _i1.UuidValue shareGroupId;

  _i2.GroupMemberRole role;

  String memberSigningPublicKeyHex;

  String memberEncryptedDataKey;

  String? deviceEncryptedDataKey;

  DateTime joinedAt;

  /// Returns a shallow copy of this [GroupMembershipView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GroupMembershipView copyWith({
    _i1.UuidValue? memberId,
    _i1.UuidValue? shareGroupId,
    _i2.GroupMemberRole? role,
    String? memberSigningPublicKeyHex,
    String? memberEncryptedDataKey,
    String? deviceEncryptedDataKey,
    DateTime? joinedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.GroupMembershipView',
      'memberId': memberId.toJson(),
      'shareGroupId': shareGroupId.toJson(),
      'role': role.toJson(),
      'memberSigningPublicKeyHex': memberSigningPublicKeyHex,
      'memberEncryptedDataKey': memberEncryptedDataKey,
      if (deviceEncryptedDataKey != null)
        'deviceEncryptedDataKey': deviceEncryptedDataKey,
      'joinedAt': joinedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.GroupMembershipView',
      'memberId': memberId.toJson(),
      'shareGroupId': shareGroupId.toJson(),
      'role': role.toJson(),
      'memberSigningPublicKeyHex': memberSigningPublicKeyHex,
      'memberEncryptedDataKey': memberEncryptedDataKey,
      if (deviceEncryptedDataKey != null)
        'deviceEncryptedDataKey': deviceEncryptedDataKey,
      'joinedAt': joinedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupMembershipViewImpl extends GroupMembershipView {
  _GroupMembershipViewImpl({
    required _i1.UuidValue memberId,
    required _i1.UuidValue shareGroupId,
    required _i2.GroupMemberRole role,
    required String memberSigningPublicKeyHex,
    required String memberEncryptedDataKey,
    String? deviceEncryptedDataKey,
    required DateTime joinedAt,
  }) : super._(
         memberId: memberId,
         shareGroupId: shareGroupId,
         role: role,
         memberSigningPublicKeyHex: memberSigningPublicKeyHex,
         memberEncryptedDataKey: memberEncryptedDataKey,
         deviceEncryptedDataKey: deviceEncryptedDataKey,
         joinedAt: joinedAt,
       );

  /// Returns a shallow copy of this [GroupMembershipView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GroupMembershipView copyWith({
    _i1.UuidValue? memberId,
    _i1.UuidValue? shareGroupId,
    _i2.GroupMemberRole? role,
    String? memberSigningPublicKeyHex,
    String? memberEncryptedDataKey,
    Object? deviceEncryptedDataKey = _Undefined,
    DateTime? joinedAt,
  }) {
    return GroupMembershipView(
      memberId: memberId ?? this.memberId,
      shareGroupId: shareGroupId ?? this.shareGroupId,
      role: role ?? this.role,
      memberSigningPublicKeyHex:
          memberSigningPublicKeyHex ?? this.memberSigningPublicKeyHex,
      memberEncryptedDataKey:
          memberEncryptedDataKey ?? this.memberEncryptedDataKey,
      deviceEncryptedDataKey: deviceEncryptedDataKey is String?
          ? deviceEncryptedDataKey
          : this.deviceEncryptedDataKey,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
