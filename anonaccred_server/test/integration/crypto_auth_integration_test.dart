import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:cryptography/cryptography.dart';
import 'package:anonaccred_server/anonaccred_server.dart';

void main() {
  group('CryptoAuth Integration Tests', () {
    test('verifies real Ed25519 signatures correctly', () async {
      // Generate a real Ed25519 key pair for testing
      final algorithm = Ed25519();
      final keyPair = await algorithm.newKeyPair();
      final publicKey = await keyPair.extractPublicKey();
      final publicKeyBytes = publicKey.bytes;
      final publicKeyHex = publicKeyBytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();

      // Create a test message
      const message = 'test challenge message';
      final messageBytes = utf8.encode(message);

      // Sign the message with the private key
      final signature = await algorithm.sign(messageBytes, keyPair: keyPair);
      final signatureBytes = signature.bytes;
      final signatureHex = signatureBytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();

      // Test CryptoAuth.verifySignature with real signature
      final messageUint8List = Uint8List.fromList(messageBytes);
      final isValid = await CryptoAuth.verifySignature(
        publicKeyHex,
        messageUint8List,
        signatureHex,
      );
      expect(
        isValid,
        isTrue,
        reason: 'Real Ed25519 signature should verify correctly',
      );

      // Test CryptoAuth.verifyMessageSignature with real signature
      final isValidMessage = await CryptoAuth.verifyMessageSignature(
        publicKeyHex,
        message,
        signatureHex,
      );
      expect(
        isValidMessage,
        isTrue,
        reason: 'Real Ed25519 message signature should verify correctly',
      );

      // Test CryptoAuth.verifyChallengeResponse with real challenge
      // Generate a proper challenge and sign it
      final challenge = CryptoAuth.generateChallenge();
      final challengeBytes = utf8.encode(challenge);
      final challengeSignature = await algorithm.sign(
        challengeBytes,
        keyPair: keyPair,
      );
      final challengeSignatureHex = challengeSignature.bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();

      final result = await CryptoAuth.verifyChallengeResponse(
        publicKeyHex,
        challenge,
        challengeSignatureHex,
      );
      expect(
        result.success,
        isTrue,
        reason: 'Real Ed25519 challenge response should succeed',
      );
      expect(result.errorCode, isNull);
      expect(result.errorMessage, isNull);
    });

    test('rejects invalid signatures correctly', () async {
      // Generate a real Ed25519 key pair for testing
      final algorithm = Ed25519();
      final keyPair = await algorithm.newKeyPair();
      final publicKey = await keyPair.extractPublicKey();
      final publicKeyBytes = publicKey.bytes;
      final publicKeyHex = publicKeyBytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();

      // Generate a proper challenge
      final challenge = CryptoAuth.generateChallenge();

      // Create an invalid signature (all zeros)
      const invalidSignature =
          '0000000000000000000000000000000000000000000000000000000000000000' +
          '0000000000000000000000000000000000000000000000000000000000000000';

      // Test that invalid signature is rejected
      final result = await CryptoAuth.verifyChallengeResponse(
        publicKeyHex,
        challenge,
        invalidSignature,
      );
      expect(
        result.success,
        isFalse,
        reason: 'Invalid signature should be rejected',
      );
      expect(
        result.errorCode,
        equals(AnonAccredErrorCodes.authInvalidSignature),
      );
    });

    test('challenge generation produces unique values', () {
      final challenges = <String>{};

      // Generate multiple challenges and ensure they're unique
      for (int i = 0; i < 10; i++) {
        final challenge = CryptoAuth.generateChallenge();
        expect(
          challenge.length,
          equals(64),
          reason: 'Challenge should be 64 hex characters',
        );
        expect(
          challenges.contains(challenge),
          isFalse,
          reason: 'Challenges should be unique',
        );
        challenges.add(challenge);
      }
    });

    test('public key validation works correctly', () {
      // Valid 128-character hex string
      const validKey =
          'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';
      expect(CryptoAuth.isValidPublicKey(validKey), isTrue);

      // Invalid cases
      expect(CryptoAuth.isValidPublicKey(''), isFalse);
      expect(CryptoAuth.isValidPublicKey('abc123'), isFalse);
      expect(
        CryptoAuth.isValidPublicKey(
          'g1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456',
        ),
        isFalse,
      );
    });
  });
}
