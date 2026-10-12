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
    final aJwk = await serializer.exportKeyDuoJwk(a);
    final bJwk = await serializer.exportKeyDuoJwk(b);
    expect(aJwk, isNot(equals(bJwk)));
  });

  test('generateSymmetricKeyJwk returns a 256-bit AES-GCM JWK that 3.0 imports',
      () async {
    final jwk = await KeyGen.generateSymmetricKeyJwk();
    final parsed = jsonDecode(jwk) as Map<String, dynamic>;
    expect(parsed['kty'], 'oct');
    expect(parsed['alg'], 'A256GCM');
    expect(base64Url.decode(base64Url.normalize(parsed['k'] as String)),
        hasLength(32));
    final key = await SymmetricKey.fromJwk(jwk);
    expect(await key.toJwk(), jwk);
    key.dispose();
  });

  test('generateAccountKeys bundles all three', () async {
    final keys = await KeyGen.generateAccountKeys();
    expect(keys, isA<AccountKeys>());
    expect(keys.ultimateKey, isNotNull);
    expect(keys.deviceKey, isNotNull);
    expect(keys.symmetricKeyJwk, isNotEmpty);
  });
}
