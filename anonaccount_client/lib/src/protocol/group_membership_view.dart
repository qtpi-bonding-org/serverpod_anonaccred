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
import 'group_member_role.dart' as _imgpb098;

abstract class GroupMembershipView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  GroupMembershipView._({
    required this.memberId,
    required this.shareGroupId,
    required this.role,
    required this.memberSigningPublicKeyHex,
    required this.groupUltimateSigningPublicKeyHex,
    required this.memberEncryptedDataKey,
    this.deviceEncryptedDataKey,
    required this.joinedAt,
    required this.encryptedMemberKey,
    this.encryptedUltimateKey,
  });

  factory GroupMembershipView({
    required _isc.UuidValue memberId,
    required _isc.UuidValue shareGroupId,
    required _imgpb098.GroupMemberRole role,
    required String memberSigningPublicKeyHex,
    required String groupUltimateSigningPublicKeyHex,
    required String memberEncryptedDataKey,
    String? deviceEncryptedDataKey,
    required DateTime joinedAt,
    required String encryptedMemberKey,
    String? encryptedUltimateKey,
  }) = _GroupMembershipViewImpl;

  factory GroupMembershipView.fromJson(Map<String, dynamic> jsonSerialization) {
    return GroupMembershipView(
      memberId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['memberId'],
      ),
      shareGroupId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['shareGroupId'],
      ),
      role: _imgpb098.GroupMemberRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      memberSigningPublicKeyHex:
          jsonSerialization['memberSigningPublicKeyHex'] as String,
      groupUltimateSigningPublicKeyHex:
          jsonSerialization['groupUltimateSigningPublicKeyHex'] as String,
      memberEncryptedDataKey:
          jsonSerialization['memberEncryptedDataKey'] as String,
      deviceEncryptedDataKey:
          jsonSerialization['deviceEncryptedDataKey'] as String?,
      joinedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['joinedAt'],
      ),
      encryptedMemberKey: jsonSerialization['encryptedMemberKey'] as String,
      encryptedUltimateKey:
          jsonSerialization['encryptedUltimateKey'] as String?,
    );
  }

  _isc.UuidValue memberId;

  _isc.UuidValue shareGroupId;

  _imgpb098.GroupMemberRole role;

  String memberSigningPublicKeyHex;

  String groupUltimateSigningPublicKeyHex;

  String memberEncryptedDataKey;

  String? deviceEncryptedDataKey;

  DateTime joinedAt;

  String encryptedMemberKey;

  String? encryptedUltimateKey;

  /// Returns a shallow copy of this [GroupMembershipView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  GroupMembershipView copyWith({
    _isc.UuidValue? memberId,
    _isc.UuidValue? shareGroupId,
    _imgpb098.GroupMemberRole? role,
    String? memberSigningPublicKeyHex,
    String? groupUltimateSigningPublicKeyHex,
    String? memberEncryptedDataKey,
    String? deviceEncryptedDataKey,
    DateTime? joinedAt,
    String? encryptedMemberKey,
    String? encryptedUltimateKey,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.GroupMembershipView',
      'memberId': memberId.toJson(),
      'shareGroupId': shareGroupId.toJson(),
      'role': role.toJson(),
      'memberSigningPublicKeyHex': memberSigningPublicKeyHex,
      'groupUltimateSigningPublicKeyHex': groupUltimateSigningPublicKeyHex,
      'memberEncryptedDataKey': memberEncryptedDataKey,
      if (deviceEncryptedDataKey != null)
        'deviceEncryptedDataKey': deviceEncryptedDataKey,
      'joinedAt': joinedAt.toJson(),
      'encryptedMemberKey': encryptedMemberKey,
      if (encryptedUltimateKey != null)
        'encryptedUltimateKey': encryptedUltimateKey,
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
      'groupUltimateSigningPublicKeyHex': groupUltimateSigningPublicKeyHex,
      'memberEncryptedDataKey': memberEncryptedDataKey,
      if (deviceEncryptedDataKey != null)
        'deviceEncryptedDataKey': deviceEncryptedDataKey,
      'joinedAt': joinedAt.toJson(),
      'encryptedMemberKey': encryptedMemberKey,
      if (encryptedUltimateKey != null)
        'encryptedUltimateKey': encryptedUltimateKey,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupMembershipViewImpl extends GroupMembershipView {
  _GroupMembershipViewImpl({
    required _isc.UuidValue memberId,
    required _isc.UuidValue shareGroupId,
    required _imgpb098.GroupMemberRole role,
    required String memberSigningPublicKeyHex,
    required String groupUltimateSigningPublicKeyHex,
    required String memberEncryptedDataKey,
    String? deviceEncryptedDataKey,
    required DateTime joinedAt,
    required String encryptedMemberKey,
    String? encryptedUltimateKey,
  }) : super._(
         memberId: memberId,
         shareGroupId: shareGroupId,
         role: role,
         memberSigningPublicKeyHex: memberSigningPublicKeyHex,
         groupUltimateSigningPublicKeyHex: groupUltimateSigningPublicKeyHex,
         memberEncryptedDataKey: memberEncryptedDataKey,
         deviceEncryptedDataKey: deviceEncryptedDataKey,
         joinedAt: joinedAt,
         encryptedMemberKey: encryptedMemberKey,
         encryptedUltimateKey: encryptedUltimateKey,
       );

  /// Returns a shallow copy of this [GroupMembershipView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  GroupMembershipView copyWith({
    _isc.UuidValue? memberId,
    _isc.UuidValue? shareGroupId,
    _imgpb098.GroupMemberRole? role,
    String? memberSigningPublicKeyHex,
    String? groupUltimateSigningPublicKeyHex,
    String? memberEncryptedDataKey,
    Object? deviceEncryptedDataKey = _Undefined,
    DateTime? joinedAt,
    String? encryptedMemberKey,
    Object? encryptedUltimateKey = _Undefined,
  }) {
    return GroupMembershipView(
      memberId: memberId ?? this.memberId,
      shareGroupId: shareGroupId ?? this.shareGroupId,
      role: role ?? this.role,
      memberSigningPublicKeyHex:
          memberSigningPublicKeyHex ?? this.memberSigningPublicKeyHex,
      groupUltimateSigningPublicKeyHex:
          groupUltimateSigningPublicKeyHex ??
          this.groupUltimateSigningPublicKeyHex,
      memberEncryptedDataKey:
          memberEncryptedDataKey ?? this.memberEncryptedDataKey,
      deviceEncryptedDataKey: deviceEncryptedDataKey is String?
          ? deviceEncryptedDataKey
          : this.deviceEncryptedDataKey,
      joinedAt: joinedAt ?? this.joinedAt,
      encryptedMemberKey: encryptedMemberKey ?? this.encryptedMemberKey,
      encryptedUltimateKey: encryptedUltimateKey is String?
          ? encryptedUltimateKey
          : this.encryptedUltimateKey,
    );
  }
}
