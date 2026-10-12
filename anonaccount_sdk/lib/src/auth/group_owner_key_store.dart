import 'package:anonaccount_client/anonaccount_client.dart' show UuidValue;
import 'package:dart_jwk_duo/dart_jwk_duo.dart' show KeyDuo;

/// The store owns the keys it holds: a key returned by a getter is the
/// store's own object, usable until the store replaces or removes that
/// group's entry, at which point the store disposes it.
abstract interface class GroupOwnerKeyStore {
  Future<void> storeOwnerKey(UuidValue groupId, KeyDuo key);
  Future<KeyDuo?> getOwnerKey(UuidValue groupId);
  Future<void> removeOwnerKey(UuidValue groupId);
}
