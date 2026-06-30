import 'dart:convert';
import 'dart:typed_data';
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:test/test.dart';

void main() {
  test('generateAccountKeys populates device, symmetric, ultimate', () async {
    final store = InMemoryAccountKeyStore();
    await store.generateAccountKeys();
    expect(await store.getDeviceSigningPublicKeyHex(), hasLength(128));
    expect(await store.getUltimateSigningPublicKeyHex(), hasLength(128));
    expect(await store.getSymmetricDataKeyJwk(), isNotNull);
    expect(await store.getDevicePublicKey(), isNotNull);
    expect(await store.getUltimatePublicKey(), isNotNull);
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
}
