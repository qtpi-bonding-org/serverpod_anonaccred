import 'dart:typed_data';
import 'package:anonaccount_sdk/src/crypto/signing.dart';
import 'package:dart_jwk_duo/dart_jwk_duo.dart';
import 'package:test/test.dart';
import 'package:webcrypto/webcrypto.dart';

Future<KeyDuo> _testKeyDuo() async {
  final signing = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
  final encryption = await EcdhPrivateKey.generateKey(EllipticCurve.p256);
  return KeyDuo(
    signing: SigningKeyPair(
      privateKey: signing.privateKey,
      publicKey: signing.publicKey,
    ),
    encryption: EncryptionKeyPair(
      privateKey: encryption.privateKey,
      publicKey: encryption.publicKey,
    ),
  );
}

void main() {
  test('signChallenge/verifyChallenge round-trip', () async {
    final keyDuo = await _testKeyDuo();
    final sig = await SigningCrypto.signChallenge('hello', keyDuo);
    expect(sig, matches(RegExp(r'^[0-9a-f]+$')));
    final ok = await SigningCrypto.verifyChallenge('hello', sig, keyDuo);
    expect(ok, isTrue);
  });

  test('verifyChallenge returns false on tampered signature', () async {
    final keyDuo = await _testKeyDuo();
    final sig = await SigningCrypto.signChallenge('hello', keyDuo);
    // Flip the last hex nibble.
    final tampered = sig.substring(0, sig.length - 1) +
        (sig[sig.length - 1] == '0' ? '1' : '0');
    final ok = await SigningCrypto.verifyChallenge('hello', tampered, keyDuo);
    expect(ok, isFalse);
  });

  test('signBytes/verifyBytes round-trip', () async {
    final keyDuo = await _testKeyDuo();
    final data = Uint8List.fromList([1, 2, 3, 4, 5]);
    final sig = await SigningCrypto.signBytes(data, keyDuo);
    final ok = await SigningCrypto.verifyBytes(data, sig, keyDuo);
    expect(ok, isTrue);
  });
}
