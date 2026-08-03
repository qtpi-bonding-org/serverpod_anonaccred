import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:test/test.dart';

void main() {
  final groupA = UuidValue.fromString('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa');
  final groupB = UuidValue.fromString('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb');

  test('stores, replaces, scopes, and removes owner keys', () async {
    final store = InMemoryGroupOwnerKeyStore();
    final first = await KeyGen.generateUltimateKey();
    final second = await KeyGen.generateUltimateKey();
    await store.storeOwnerKey(groupA, first);
    expect(await store.getOwnerKey(groupA), same(first));
    expect(await store.getOwnerKey(groupB), isNull);
    await store.storeOwnerKey(groupA, second);
    expect(await store.getOwnerKey(groupA), same(second));
    await store.removeOwnerKey(groupA);
    expect(await store.getOwnerKey(groupA), isNull);
    await expectLater(store.removeOwnerKey(groupA), completes);
  });
}
