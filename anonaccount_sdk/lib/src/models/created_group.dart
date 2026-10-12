import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dart_jwk_duo/dart_jwk_duo.dart' show SymmetricKey;

part 'created_group.freezed.dart';

/// Returned by [AnonaccountGroups.createGroup]. Contains the live
/// [SymmetricKey] because the caller just generated it locally — no need to
/// round-trip through the server. The caller owns it and disposes it when
/// done.
///
/// Not JSON-serializable: [groupDataKey] is a native handle. Consumers
/// persist the JWK form (`toJwk`) themselves.
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
    required SymmetricKey groupDataKey,
    required DateTime createdAt,
  }) = _CreatedGroup;

  /// Written by hand because [groupDataKey] holds live secret material, and
  /// its printed form should not depend on the library's toString.
  @override
  String toString() => 'CreatedGroup(groupId: $groupId, '
      'displayName: $displayName, groupDataKey: <SymmetricKey>, '
      'createdAt: $createdAt)';
}
