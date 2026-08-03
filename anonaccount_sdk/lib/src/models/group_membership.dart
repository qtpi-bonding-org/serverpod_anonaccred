// A single row from [AnonaccountGroups.listMyGroups] — the *view* the
// server returns. The data key is delivered in two wrapped forms:
//
// - `memberEncryptedDataKey`: wrapped to the *member* key (the per-group
//   identity root). Useful only to a device that holds the member key
//   — e.g. the joining device, when it's also the holder.
// - `deviceEncryptedDataKey`: wrapped to the *calling device*'s own
//   encryption key. Null for a device that has not yet been granted
//   access to this membership — and that is no longer an error, the
//   state the SDK now has to handle. Wrapped to different keys; the
//   two blobs are not interchangeable.
//
// No `displayName` field: the wire `ShareGroup` does not carry one.
// Consumers maintain their own `{groupId → label}` cache.

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

/// Top-level wrapper for [UuidValueJsonExtension.toJson] — `@JsonKey(toJson:)`>
/// needs a tear-off-able function; the extension method itself is an
/// instance method, not a static one.
String _uuidValueToJson(UuidValue value) => value.toJson();

@freezed
abstract class GroupMembership with _$GroupMembership {
  const factory GroupMembership({
    required String groupId,
    @JsonKey(
      fromJson: UuidValueJsonExtension.fromJson,
      toJson: _uuidValueToJson,
    )
    required UuidValue memberId,
    @_GroupMemberRoleConverter() required GroupMemberRole role,
    required String memberSigningPublicKeyHex,
    required String memberEncryptedDataKey,
    required String? deviceEncryptedDataKey,
    required DateTime joinedAt,
    /// This membership's member key pair, encrypted with the account's
    /// ultimate encryption public key. Opaque here — only recoverAccount,
    /// holding the user's backup, can decrypt it.
    required String encryptedMemberKey,
  }) = _GroupMembership;

  factory GroupMembership.fromJson(Map<String, dynamic> json) =>
      _$GroupMembershipFromJson(json);
}
