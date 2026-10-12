import 'dart:convert';
import 'dart:typed_data';
import 'package:anonaccount_sdk/src/auth/in_memory_account_key_store.dart';
import 'package:test/test.dart';

void main() {
  test('generateAccountKeys populates device, symmetric, ultimate', () async {
    final store = InMemoryAccountKeyStore();
    await store.generateAccountKeys();
    expect(await store.getDeviceSigningPublicKeyHex(), hasLength(130));
    expect(await store.getUltimateSigningPublicKeyHex(), hasLength(130));
    expect(await store.getSymmetricDataKeyJwk(), isNotNull);
    expect(await store.getDeviceEncryptionPublicKeyHex(),
        matches(RegExp(r'^04[0-9a-f]{128}$')));
    expect(await store.getDeviceEncryptionPublicKeyHex(),
        isNot(await store.getDeviceSigningPublicKeyHex()));
  });

  test('signWithUltimateKey works then getUltimateKeyJwkOnce wipes', () async {
    final store = InMemoryAccountKeyStore();
    await store.generateAccountKeys();
    final data = Uint8List.fromList(utf8.encode('hello'));
    expect(await store.signWithUltimateKey(data), isNotNull);
    final backup = await store.getUltimateKeyJwkOnce();
    expect(backup, isNotNull);
    expect(await store.signWithUltimateKey(data), isNull); // wiped
    expect(await store.getUltimateSigningPublicKeyHex(), isNotNull); // hex cached
  });

  test('importUltimateKeyJwk restores signing', () async {
    final seed = InMemoryAccountKeyStore();
    await seed.generateAccountKeys();
    final jwk = (await seed.getUltimateKeyJwkOnce())!;
    final store = InMemoryAccountKeyStore();
    await store.importUltimateKeyJwk(jwk);
    final data = Uint8List.fromList(utf8.encode('x'));
    expect(await store.signWithUltimateKey(data), isNotNull);
  });

  test('ultimate encryption public key hex survives the one-time wipe',
      () async {
    final store = InMemoryAccountKeyStore();
    await store.generateAccountKeys();

    final before = await store.getUltimateEncryptionPublicKeyHex();
    expect(before, isNotNull);
    expect(before, matches(RegExp(r'^04[0-9a-f]{128}$')));

    // The private halves go away here. The public half must not.
    await store.getUltimateKeyJwkOnce();

    expect(
        await store.signWithUltimateKey(Uint8List.fromList(utf8.encode('x'))),
        isNull,
        reason: 'the private-bearing KeyDuo is wiped');
    expect(await store.getUltimateEncryptionPublicKeyHex(), before,
        reason: 'a public key is not secret and is needed to write '
            'group membership backups long after the wipe');
  });

  test('importUltimateKeyJwk repopulates the encryption public key hex',
      () async {
    final seed = InMemoryAccountKeyStore();
    await seed.generateAccountKeys();
    final expected = await seed.getUltimateEncryptionPublicKeyHex();
    final jwk = (await seed.getUltimateKeyJwkOnce())!;

    final restored = InMemoryAccountKeyStore();
    expect(await restored.getUltimateEncryptionPublicKeyHex(), isNull);
    await restored.importUltimateKeyJwk(jwk);
    expect(await restored.getUltimateEncryptionPublicKeyHex(), expected);
  });

  test('generateAndStoreDeviceKey refreshes both device hexes', () async {
    final store = InMemoryAccountKeyStore();
    await store.generateAccountKeys();
    final sig = await store.getDeviceSigningPublicKeyHex();
    final enc = await store.getDeviceEncryptionPublicKeyHex();
    await store.generateAndStoreDeviceKey();
    expect(await store.getDeviceSigningPublicKeyHex(), isNot(sig));
    expect(await store.getDeviceEncryptionPublicKeyHex(), isNot(enc));
    final device = (await store.getDeviceKey())!;
    expect(await store.getDeviceEncryptionPublicKeyHex(),
        (await device.encryptionKeyPair.exportPublicKeySec1Hex()).value);
  });
}
