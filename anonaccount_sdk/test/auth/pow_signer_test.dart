import 'package:anonaccount_sdk/src/auth/pow_signer.dart';
import 'package:anonaccount_sdk/src/crypto/key_gen.dart';
import 'package:anonaccount_sdk/src/crypto/signing.dart';
import 'package:test/test.dart';

void main() {
  test('build composes challenge + hashcash + ECDSA signature', () async {
    final keyDuo = await KeyGen.generateDeviceKey();
    final pubkeyHex = await keyDuo.signingKeyPair.exportPublicKeyHex();
    final envelope = await PowSigner.build(
      challenge: 'CHAL-123',
      methodName: 'createAccount',
      signingKey: keyDuo,
      publicKeyHex: pubkeyHex,
      difficulty: 8,
    );

    expect(envelope.challenge, 'CHAL-123');
    expect(envelope.publicKeyHex, pubkeyHex);
    expect(envelope.proofOfWork.startsWith('1:8:CHAL-123:'), isTrue);

    final outerPayload = 'CHAL-123:createAccount:$pubkeyHex';
    expect(
      await SigningCrypto.verifyChallenge(outerPayload, envelope.signature, keyDuo),
      isTrue,
    );
  });
}
