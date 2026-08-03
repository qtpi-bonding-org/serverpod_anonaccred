import 'package:anonaccount_client/anonaccount_client.dart' show UuidValue;
import 'package:dart_jwk_duo/dart_jwk_duo.dart' show KeyDuo;

import 'group_owner_key_store.dart';

class InMemoryGroupOwnerKeyStore implements GroupOwnerKeyStore {
  final _keys = <UuidValue, KeyDuo>{};

  @override
  Future<void> storeOwnerKey(UuidValue groupId, KeyDuo key) async {
    _keys[groupId] = key;
  }

  @override
  Future<KeyDuo?> getOwnerKey(UuidValue groupId) async => _keys[groupId];

  @override
  Future<void> removeOwnerKey(UuidValue groupId) async {
    _keys.remove(groupId);
  }
}
