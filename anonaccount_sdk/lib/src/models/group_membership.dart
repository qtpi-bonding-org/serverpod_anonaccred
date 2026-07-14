// ignore: implementation_imports
import 'package:anonaccount_client/anonaccount_client.dart'
    show UuidValue, UuidValueJsonExtension;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/group_member_role.dart'
    show GroupMemberRole;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_membership.freezed.dart';
part 'group_membership.g.dart';

/// Serializes [GroupMemberRole] as its `.name` string (the same format
/// used by the Serverpod wire protocol).
class _GroupMemberRoleConverter
    implements JsonConverter<GroupMemberRole, String> {
  const _GroupMemberRoleConverter();

  @override
  GroupMemberRole fromJson(String json) => GroupMemberRole.fromJson(json);

  @override
  String toJson(GroupMemberRole object) => object.toJson();
}

/// Top-level wrapper for [UuidValueJsonExtension.toJson] — `@JsonKey(toJson:)`
/// needs a tear-off-able function; the extension method itself is an
/// instance method, not a static one.
String _uuidValueToJson(UuidValue value) => value.toJson();

/// A single row from [AnonaccountGroups.listMyGroups]. The data key
/// is delivered encrypted — the consumer unwraps it with
/// [AsymmetricCrypto.unwrap] using the recipient's **per-group member
/// key** (the device-key analogue; see the consuming app's
/// GroupKeyService), not the account's encryption key.
///
/// No `displayName` field: the wire `ShareGroup` does not carry one.
/// Consumers maintain their own `{groupId → label}` cache.
@freezed
class GroupMembership with _$GroupMembership {
  const factory GroupMembership({
    required String groupId,
    @JsonKey(
      fromJson: UuidValueJsonExtension.fromJson,
      toJson: _uuidValueToJson,
    )
    required UuidValue memberId, // NEW — the GroupMember row id, needed by leaveGroup/removeGroupMember
    @_GroupMemberRoleConverter() required GroupMemberRole role,
    required String encryptedDataKey,
    required DateTime joinedAt,
    required bool isRevoked,
  }) = _GroupMembership;

  factory GroupMembership.fromJson(Map<String, dynamic> json) =>
      _$GroupMembershipFromJson(json);
}
