import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:test/test.dart';

void main() {
  final groupA = UuidValue.fromString('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa');
  final groupB = UuidValue.fromString('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb');

  test('returns null for a group with no stored key', () async {
    final store = InMemoryMemberKeyStore();
    expect(await store.getMemberKey(groupA), isNull);
  });

  test('returns the stored key for that group', () async {
    final store = InMemoryMemberKeyStore();
    final key = await KeyGen.generateDeviceKey();
    await store.storeMemberKey(groupA, key);
    expect(await store.getMemberKey(groupA), same(key));
  });

  test('keys are scoped per group', () async {
    final store = InMemoryMemberKeyStore();
    await store.storeMemberKey(groupA, await KeyGen.generateDeviceKey());
    expect(await store.getMemberKey(groupB), isNull);
  });

  test('storeMemberKey replaces an existing key for the same group', () async {
    // Rejoining a group mints a fresh member key under the same group id.
    final store = InMemoryMemberKeyStore();
    final first = await KeyGen.generateDeviceKey();
    final second = await KeyGen.generateDeviceKey();
    await store.storeMemberKey(groupA, first);
    await store.storeMemberKey(groupA, second);
    expect(await store.getMemberKey(groupA), same(second));
  });

  test('returns null after removeMemberKey', () async {
    final store = InMemoryMemberKeyStore();
    await store.storeMemberKey(groupA, await KeyGen.generateDeviceKey());
    await store.removeMemberKey(groupA);
    expect(await store.getMemberKey(groupA), isNull);
  });

  test('removeMemberKey on an absent group does not throw', () async {
    final store = InMemoryMemberKeyStore();
    await expectLater(store.removeMemberKey(groupA), completes);
  });

  test('removeMemberKey leaves other groups intact', () async {
    final store = InMemoryMemberKeyStore();
    final key = await KeyGen.generateDeviceKey();
    await store.storeMemberKey(groupA, await KeyGen.generateDeviceKey());
    await store.storeMemberKey(groupB, key);
    await store.removeMemberKey(groupA);
    expect(await store.getMemberKey(groupB), same(key));
  });
}
