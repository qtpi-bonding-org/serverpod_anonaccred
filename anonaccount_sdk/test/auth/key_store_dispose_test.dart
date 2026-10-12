import 'dart:typed_data';

import 'package:anonaccount_client/anonaccount_client.dart' show UuidValue;
import 'package:anonaccount_sdk/src/auth/in_memory_account_key_store.dart';
import 'package:anonaccount_sdk/src/auth/in_memory_group_owner_key_store.dart';
import 'package:anonaccount_sdk/src/auth/in_memory_member_key_store.dart';
import 'package:anonaccount_sdk/src/crypto/key_gen.dart';
import 'package:dart_jwk_duo/dart_jwk_duo.dart' show KeyDuo;
import 'package:test/test.dart';

// Probed through signBytes, which reaches native code. A public-key export
// reads a Dart-side cache and would still succeed on a disposed key.
Future<void> _expectDisposed(KeyDuo k) => expectLater(
      k.signingKeyPair.signBytes(Uint8List(1)),
      throwsA(isA<StateError>()),
    );

Future<void> _expectLive(KeyDuo k) async =>
    expect(await k.signingKeyPair.signBytes(Uint8List(1)), hasLength(64));

void main() {
  final groupA = UuidValue.fromString('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa');

  group('InMemoryAccountKeyStore owns and disposes what it drops', () {
    test('a device key replaced by generateAndStoreDeviceKey', () async {
      final store = InMemoryAccountKeyStore();
      await store.generateAccountKeys();
      final old = (await store.getDeviceKey())!;
      await store.generateAndStoreDeviceKey();
      await _expectDisposed(old);
      await _expectLive((await store.getDeviceKey())!);
    });

    test('both keys replaced by a second generateAccountKeys', () async {
      final store = InMemoryAccountKeyStore();
      await store.generateAccountKeys();
      final oldDevice = (await store.getDeviceKey())!;
      final jwk = (await store.getUltimateKeyJwkOnce())!;
      final oldUltimate = await store.importUltimateKeyJwk(jwk);
      await store.generateAccountKeys();
      await _expectDisposed(oldDevice);
      await _expectDisposed(oldUltimate);
    });

    test('the ultimate key after getUltimateKeyJwkOnce', () async {
      final seed = InMemoryAccountKeyStore();
      await seed.generateAccountKeys();
      final jwk = (await seed.getUltimateKeyJwkOnce())!;
      final store = InMemoryAccountKeyStore();
      final ultimate = await store.importUltimateKeyJwk(jwk);
      await _expectLive(ultimate);
      await store.getUltimateKeyJwkOnce();
      await _expectDisposed(ultimate);
    });

    test('the first ultimate key after a second importUltimateKeyJwk', () async {
      final seed = InMemoryAccountKeyStore();
      await seed.generateAccountKeys();
      final jwk = (await seed.getUltimateKeyJwkOnce())!;
      final store = InMemoryAccountKeyStore();
      final first = await store.importUltimateKeyJwk(jwk);
      final second = await store.importUltimateKeyJwk(jwk);
      await _expectDisposed(first);
      await _expectLive(second);
    });
  });

  group('InMemoryMemberKeyStore', () {
    test('disposes a replaced key and a removed key', () async {
      final store = InMemoryMemberKeyStore();
      final first = await KeyGen.generateDeviceKey();
      final second = await KeyGen.generateDeviceKey();
      await store.storeMemberKey(groupA, first);
      await store.storeMemberKey(groupA, second);
      await _expectDisposed(first);
      await _expectLive(second);
      await store.removeMemberKey(groupA);
      await _expectDisposed(second);
    });

    test('storing the identical object again leaves it usable', () async {
      final store = InMemoryMemberKeyStore();
      final key = await KeyGen.generateDeviceKey();
      await store.storeMemberKey(groupA, key);
      await store.storeMemberKey(groupA, key);
      await _expectLive(key);
    });
  });

  group('InMemoryGroupOwnerKeyStore', () {
    test('disposes a replaced key and a removed key', () async {
      final store = InMemoryGroupOwnerKeyStore();
      final first = await KeyGen.generateUltimateKey();
      final second = await KeyGen.generateUltimateKey();
      await store.storeOwnerKey(groupA, first);
      await store.storeOwnerKey(groupA, second);
      await _expectDisposed(first);
      await _expectLive(second);
      await store.removeOwnerKey(groupA);
      await _expectDisposed(second);
    });

    test('storing the identical object again leaves it usable', () async {
      final store = InMemoryGroupOwnerKeyStore();
      final key = await KeyGen.generateUltimateKey();
      await store.storeOwnerKey(groupA, key);
      await store.storeOwnerKey(groupA, key);
      await _expectLive(key);
    });
  });
}
