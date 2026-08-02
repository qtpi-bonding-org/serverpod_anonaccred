// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupMembershipImpl _$$GroupMembershipImplFromJson(
        Map<String, dynamic> json) =>
    _$GroupMembershipImpl(
      groupId: json['groupId'] as String,
      memberId: UuidValueJsonExtension.fromJson(json['memberId']),
      role: const _GroupMemberRoleConverter().fromJson(json['role'] as String),
      memberSigningPublicKeyHex: json['memberSigningPublicKeyHex'] as String,
      memberEncryptedDataKey: json['memberEncryptedDataKey'] as String,
      deviceEncryptedDataKey: json['deviceEncryptedDataKey'] as String?,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$$GroupMembershipImplToJson(
        _$GroupMembershipImpl instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'memberId': _uuidValueToJson(instance.memberId),
      'role': const _GroupMemberRoleConverter().toJson(instance.role),
      'memberSigningPublicKeyHex': instance.memberSigningPublicKeyHex,
      'memberEncryptedDataKey': instance.memberEncryptedDataKey,
      'deviceEncryptedDataKey': instance.deviceEncryptedDataKey,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };
