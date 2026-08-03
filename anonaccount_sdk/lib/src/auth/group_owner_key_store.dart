import 'package:anonaccount_client/anonaccount_client.dart' show UuidValue;
import 'package:dart_jwk_duo/dart_jwk_duo.dart' show KeyDuo;

abstract interface class GroupOwnerKeyStore {
  Future<void> storeOwnerKey(UuidValue groupId, KeyDuo key);
  Future<KeyDuo?> getOwnerKey(UuidValue groupId);
  Future<void> removeOwnerKey(UuidValue groupId);
}
