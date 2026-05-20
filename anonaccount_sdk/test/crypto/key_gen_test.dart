import 'dart:convert';
import 'package:anonaccount_sdk/src/crypto/key_gen.dart';
import 'package:anonaccount_sdk/src/models/account_keys.dart';
import 'package:dart_jwk_duo/dart_jwk_duo.dart';
import 'package:test/test.dart';

void main() {
  test('generateUltimateKey returns a usable KeyDuo', () async {
    final duo = await KeyGen.generateUltimateKey();
    expect(duo, isA<KeyDuo>());
    expect(duo.signingKeyPair, isNotNull);
    expect(duo.encryptionKeyPair, isNotNull);
  });

  test('generateDeviceKey returns a distinct KeyDuo each call', () async {
    final a = await KeyGen.generateDeviceKey();
    final b = await KeyGen.generateDeviceKey();
    final serializer = KeyDuoSerializer();
    final aJwk = await serializer.exportKeyDuo(a);
    final bJwk = await serializer.exportKeyDuo(b);
    expect(aJwk, isNot(equals(bJwk)));
  });

  test('generateSymmetricKeyJwk returns a parseable JWK', () async {
    final jwk = await KeyGen.generateSymmetricKeyJwk();
    final parsed = jsonDecode(jwk) as Map<String, dynamic>;
    expect(parsed['kty'], 'oct');
    expect(parsed['alg'], anyOf('A256GCM', 'A256CBC'));
    expect(parsed['k'], isA<String>());
  });

  test('generateAccountKeys bundles all three', () async {
    final keys = await KeyGen.generateAccountKeys();
    expect(keys, isA<AccountKeys>());
    expect(keys.ultimateKey, isNotNull);
    expect(keys.deviceKey, isNotNull);
    expect(keys.symmetricKeyJwk, isNotEmpty);
  });
}
