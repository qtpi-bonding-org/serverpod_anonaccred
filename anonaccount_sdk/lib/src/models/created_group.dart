import 'package:dart_jwk_duo/dart_jwk_duo.dart' show KeyDuo;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:webcrypto/webcrypto.dart';

part 'created_group.freezed.dart';

/// Returned by [AnonaccountGroups.createGroup]. Contains the live
/// `AesGcmSecretKey` because the caller just generated it locally —
/// no need to round-trip through the server.
///
/// Not JSON-serializable: [groupDataKey] and [memberKey] are runtime
/// handles. Consumers persist the JWK form (`exportJsonWebKey` /
/// `KeyDuoSerializer`) themselves.
@freezed
abstract class CreatedGroup with _$CreatedGroup {
  const CreatedGroup._();

  const factory CreatedGroup({
    required String groupId,
    required String displayName,
    required AesGcmSecretKey groupDataKey,
    // The creator's own member KeyDuo — the group data key's creator
    // copy (GroupMember.encryptedDataKey on the server) is wrapped to
    // this KeyDuo's encryption public key. Callers MUST persist this
    // (storeMemberKey) or they can never unwrap their own listMyGroups
    // row for this group.
    required KeyDuo memberKey,
    required DateTime createdAt,
  }) = _CreatedGroup;

  /// Written by hand because [groupDataKey] and [memberKey] hold live secret
  /// material. They print opaquely today only because webcrypto and
  /// dart_jwk_duo use default toStrings — a third-party detail this should
  /// not depend on.
  @override
  String toString() => 'CreatedGroup(groupId: $groupId, '
      'displayName: $displayName, groupDataKey: <AesGcmSecretKey>, '
      'memberKey: <KeyDuo>, createdAt: $createdAt)';
}
