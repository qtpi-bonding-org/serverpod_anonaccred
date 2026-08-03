import 'package:anonaccount_client/anonaccount_client.dart' show UuidValue;
import 'package:dart_jwk_duo/dart_jwk_duo.dart' show KeyDuo;

import 'member_key_store.dart';

/// Non-persistent reference store used by SDK tests and trivial consumers.
/// Real apps implement [MemberKeyStore] over secure storage instead.
class InMemoryMemberKeyStore implements MemberKeyStore {
  final _keys = <UuidValue, KeyDuo>{};

  @override
  Future<void> storeMemberKey(UuidValue groupId, KeyDuo key) async =>
      _keys[groupId] = key;

  @override
  Future<KeyDuo?> getMemberKey(UuidValue groupId) async => _keys[groupId];

  @override
  Future<void> removeMemberKey(UuidValue groupId) async => _keys.remove(groupId);
}
