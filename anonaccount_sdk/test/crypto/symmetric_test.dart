import 'dart:convert';
import 'dart:typed_data';

import 'package:anonaccount_sdk/src/auth/exceptions.dart';
import 'package:anonaccount_sdk/src/crypto/symmetric.dart';
import 'package:dart_jwk_duo/dart_jwk_duo.dart' show GenerationService, SymmetricKey;
import 'package:test/test.dart';

void main() {
  late SymmetricKey key;

  setUpAll(() async {
    key = await GenerationService.generateSymmetricKey();
  });
  tearDownAll(() => key.dispose());

  test('encrypt/decrypt round-trips arbitrary plaintext', () async {
    final plaintext = utf8.encode('hello world 🚀');
    final ct = await SymmetricCrypto.encrypt(Uint8List.fromList(plaintext), key);
    expect(ct.length, greaterThanOrEqualTo(plaintext.length + 28));
    final pt = await SymmetricCrypto.decrypt(ct, key);
    expect(utf8.decode(pt), 'hello world 🚀');
  });

  test('encrypt produces fresh IV per call (different ciphertext for same input)',
      () async {
    final plaintext = Uint8List.fromList(utf8.encode('same'));
    final a = await SymmetricCrypto.encrypt(plaintext, key);
    final b = await SymmetricCrypto.encrypt(plaintext, key);
    expect(a, isNot(equals(b)));
  });

  test('decrypt throws CryptoOperationException for a blob shorter than 28 bytes',
      () async {
    await expectLater(
      SymmetricCrypto.decrypt(Uint8List(27), key),
      throwsA(isA<CryptoOperationException>()),
    );
  });

  test('aad round-trips, and a different aad fails', () async {
    final pt = Uint8List.fromList(utf8.encode('bound'));
    final aad = Uint8List.fromList(utf8.encode('row-1'));
    final ct = await SymmetricCrypto.encrypt(pt, key, aad: aad);
    expect(await SymmetricCrypto.decrypt(ct, key, aad: aad), pt);
    await expectLater(
      SymmetricCrypto.decrypt(ct, key, aad: Uint8List.fromList(utf8.encode('row-2'))),
      throwsA(isA<CryptoOperationException>()),
    );
    await expectLater(
      SymmetricCrypto.decrypt(ct, key),
      throwsA(isA<CryptoOperationException>()),
    );
  });

  test('a tampered byte fails', () async {
    final ct = await SymmetricCrypto.encrypt(
        Uint8List.fromList(utf8.encode('x')), key);
    ct[ct.length - 1] ^= 1;
    await expectLater(
      SymmetricCrypto.decrypt(ct, key),
      throwsA(isA<CryptoOperationException>()),
    );
  });
}
