import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:cryptography/cryptography.dart';
import '../../lib/src/crypto_utils.dart';

void main() {
  group('Crypto Integration Tests', () {
    test('complete challenge-response authentication flow', () async {
      // Step 1: Generate a challenge (server-side)
      final challenge = CryptoUtils.generateChallenge();
      expect(challenge.length, equals(64)); // 32 bytes as hex

      // Step 2: Client generates key pair (simulated)
      final algorithm = Ed25519();
      final keyPair = await algorithm.newKeyPair();
      final publicKey = await keyPair.extractPublicKey();
      final publicKeyHex = CryptoUtils.bytesToHex(
        Uint8List.fromList(publicKey.bytes),
      );

      // Step 3: Client signs the challenge (simulated)
      final challengeBytes = utf8.encode(challenge);
      final signature = await algorithm.sign(challengeBytes, keyPair: keyPair);
      final signatureHex = CryptoUtils.bytesToHex(
        Uint8List.fromList(signature.bytes),
      );

      // Step 4: Server verifies the signature
      final isValid = await CryptoUtils.verifyEd25519Signature(
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
      final algorithm = Ed25519();
      final keyPairA = await algorithm.newKeyPair();
      final publicKeyA = await keyPairA.extractPublicKey();
      final publicKeyAHex = CryptoUtils.bytesToHex(
        Uint8List.fromList(publicKeyA.bytes),
      );

      // Client B generates different key pair
      final keyPairB = await algorithm.newKeyPair();

      // Client B signs the challenge with their key
      final challengeBytes = utf8.encode(challenge);
      final signature = await algorithm.sign(challengeBytes, keyPair: keyPairB);
      final signatureHex = CryptoUtils.bytesToHex(
        Uint8List.fromList(signature.bytes),
      );

      // Server tries to verify with Client A's public key (should fail)
      final isValid = await CryptoUtils.verifyEd25519Signature(
        message: challenge,
        signature: signatureHex,
        publicKey: publicKeyAHex,
      );

      expect(isValid, isFalse);
    });

    test('multiple challenges are unique', () {
      final challenges = <String>{};

      // Generate 100 challenges and ensure they're all unique
      for (int i = 0; i < 100; i++) {
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
