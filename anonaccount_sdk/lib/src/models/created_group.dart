import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:webcrypto/webcrypto.dart';

part 'created_group.freezed.dart';

/// Returned by [AnonaccountGroups.createGroup]. Contains the live
/// `AesGcmSecretKey` because the caller just generated it locally —
/// no need to round-trip through the server.
///
/// Not JSON-serializable: [groupDataKey] is a runtime handle. Consumers
/// persist the JWK form (`exportJsonWebKey`) themselves.
///
/// The creator's member key is not here — `createGroup` writes it to the
/// caller's `MemberKeyStore` instead, so custody is a compiler-checked
/// obligation rather than a field the caller may quietly drop.
@freezed
abstract class CreatedGroup with _$CreatedGroup {
  const CreatedGroup._();

  const factory CreatedGroup({
    required String groupId,
    required String displayName,
    required AesGcmSecretKey groupDataKey,
    required DateTime createdAt,
  }) = _CreatedGroup;

  /// Written by hand because [groupDataKey] holds live secret material. It
  /// prints opaquely today only because webcrypto uses a default toString —
  /// a third-party detail this should not depend on.
  @override
  String toString() => 'CreatedGroup(groupId: $groupId, '
      'displayName: $displayName, groupDataKey: <AesGcmSecretKey>, '
      'createdAt: $createdAt)';
}
