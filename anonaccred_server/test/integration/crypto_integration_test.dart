import 'dart:convert';
import 'dart:typed_data';

import 'package:anonaccred_server/src/crypto_utils.dart';
import 'package:test/test.dart';
import 'package:webcrypto/webcrypto.dart';

void main() {
  group('Crypto Integration Tests', () {
    test('complete challenge-response authentication flow', () async {
      // Step 1: Generate a challenge (server-side)
      final challenge = CryptoUtils.generateChallenge();
      expect(challenge.length, equals(64)); // 32 bytes as hex

      // Step 2: Client generates ECDSA P-256 key pair (simulated)
      final keyPair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
      final publicKey = await keyPair.publicKey.exportRawKey();
      final publicKeyHex = publicKey.sublist(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();

      // Step 3: Client signs the challenge (simulated)
      final challengeBytes = Uint8List.fromList(utf8.encode(challenge));
      final signatureBytes = await keyPair.privateKey.signBytes(challengeBytes, Hash.sha256);
      final signatureHex = signatureBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

      // Step 4: Server verifies the signature
      final isValid = await CryptoUtils.verifySignature(
        message: challenge,
        signature: signatureHex,
        publicKey: publicKeyHex,
      );

      expect(isValid, isTrue);
    });

    test('challenge-response fails with wrong key', () async {
      // Generate a challenge
      final challenge = CryptoUtils.generateChallenge();

      // Client A generates key pair
      final keyPairA = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
      final publicKeyA = await keyPairA.publicKey.exportRawKey();
      final publicKeyAHex = publicKeyA.sublist(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();

      // Client B generates different key pair
      final keyPairB = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);

      // Client B signs the challenge with their key
      final challengeBytes = Uint8List.fromList(utf8.encode(challenge));
      final signatureBytes = await keyPairB.privateKey.signBytes(challengeBytes, Hash.sha256);
      final signatureHex = signatureBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

      // Server tries to verify with Client A's public key (should fail)
      final isValid = await CryptoUtils.verifySignature(
        message: challenge,
        signature: signatureHex,
        publicKey: publicKeyAHex,
      );

      expect(isValid, isFalse);
    });

    test('multiple challenges are unique', () {
      final challenges = <String>{};

      // Generate 100 challenges and ensure they're all unique
      for (var i = 0; i < 100; i++) {
        final challenge = CryptoUtils.generateChallenge();
        expect(
          challenges.contains(challenge),
          isFalse,
          reason: 'Challenge $i was not unique: $challenge',
        );
        challenges.add(challenge);
      }

      expect(challenges.length, equals(100));
    });
  });
}
