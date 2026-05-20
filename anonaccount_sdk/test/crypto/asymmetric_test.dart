import 'package:anonaccount_sdk/src/crypto/asymmetric.dart';
import 'package:test/test.dart';
import 'package:webcrypto/webcrypto.dart';

void main() {
  test('wrapForRecipient → unwrap round-trips a JWK string', () async {
    final pair = await EcdhPrivateKey.generateKey(EllipticCurve.p256);
    const plaintext = '{"kty":"oct","k":"BASE64-FAKE","alg":"A256GCM"}';
    final blob = await AsymmetricCrypto.wrapForRecipient(plaintext, pair.publicKey);
    expect(blob, isNotEmpty);
    final out = await AsymmetricCrypto.unwrap(blob, pair.privateKey);
    expect(out, plaintext);
  });

  test('unwrap with wrong private key fails', () async {
    final a = await EcdhPrivateKey.generateKey(EllipticCurve.p256);
    final b = await EcdhPrivateKey.generateKey(EllipticCurve.p256);
    final blob = await AsymmetricCrypto.wrapForRecipient('secret', a.publicKey);
    await expectLater(
      AsymmetricCrypto.unwrap(blob, b.privateKey),
      throwsA(isA<Exception>()),
    );
  });
}
