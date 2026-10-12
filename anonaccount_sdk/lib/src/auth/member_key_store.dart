import 'package:anonaccount_client/anonaccount_client.dart' show UuidValue;
import 'package:dart_jwk_duo/dart_jwk_duo.dart' show KeyDuo;

/// Custody surface for per-group member keys.
///
/// Separate from `AccountKeyStore` because that interface is the account +
/// pairing surface, satisfied by an app's existing key repository without
/// adding methods; member keys are group-scoped and map-shaped, and folding
/// them in would falsify both properties. A consumer wanting a single custody
/// object writes `implements AccountKeyStore, MemberKeyStore`.
///
/// Keyed by group rather than by member because a member id does not exist at
/// creation time — `createGroup` returns a `ShareGroup`, which carries no
/// member row.
///
/// One key per group, so this signature has no way to express the two
/// generations a `keyEpoch` rotation (D23) would need. Epoch-aware custody is
/// deferred and this shape changes when it arrives.
///
/// The store owns the keys it holds: a key returned by a getter is the
/// store's own object, usable until the store replaces or removes that
/// group's entry, at which point the store disposes it.
abstract interface class MemberKeyStore {
  /// Replaces any key already stored for [groupId].
  ///
  /// Overwrite rather than reject, because rejoining a group mints a fresh
  /// member key under the same group id, and a store that refused would
  /// strand the caller holding a key it cannot file.
  Future<void> storeMemberKey(UuidValue groupId, KeyDuo key);

  Future<KeyDuo?> getMemberKey(UuidValue groupId);

  Future<void> removeMemberKey(UuidValue groupId);
}
