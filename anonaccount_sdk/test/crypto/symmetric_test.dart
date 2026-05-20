import 'dart:convert';
import 'dart:typed_data';
import 'package:anonaccount_sdk/src/auth/exceptions.dart';
import 'package:anonaccount_sdk/src/crypto/symmetric.dart';
import 'package:test/test.dart';
import 'package:webcrypto/webcrypto.dart';

void main() {
  late AesGcmSecretKey key;

  setUpAll(() async {
    key = await AesGcmSecretKey.generateKey(256);
  });

  test('encrypt/decrypt round-trips arbitrary plaintext', () async {
    final plaintext = utf8.encode('hello world 🚀');
    final ct = await SymmetricCrypto.encrypt(Uint8List.fromList(plaintext), key);
    expect(ct.length, greaterThanOrEqualTo(plaintext.length + 12));
    final pt = await SymmetricCrypto.decrypt(ct, key);
    expect(utf8.decode(pt), 'hello world 🚀');
  });

  test('encrypt produces fresh IV per call (different ciphertext for same input)', () async {
    final plaintext = Uint8List.fromList(utf8.encode('same'));
    final a = await SymmetricCrypto.encrypt(plaintext, key);
    final b = await SymmetricCrypto.encrypt(plaintext, key);
    expect(a, isNot(equals(b)));
  });

  test('decrypt throws CryptoOperationException if blob shorter than IV', () async {
    expect(
      () => SymmetricCrypto.decrypt(Uint8List(8), key),
      throwsA(isA<CryptoOperationException>()),
    );
  });
}
