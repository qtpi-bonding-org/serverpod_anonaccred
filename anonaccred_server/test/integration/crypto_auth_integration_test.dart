import 'dart:convert';
import 'dart:typed_data';
import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:test/test.dart';
import 'package:webcrypto/webcrypto.dart';

void main() {
  group('CryptoAuth Integration Tests', () {
    test('verifies real ECDSA P-256 signatures correctly', () async {
      // Generate a real ECDSA P-256 key pair for testing
      final keyPair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
      final publicKey = await keyPair.publicKey.exportRawKey();
      
      // Convert to hex format (remove 04 prefix, use x||y format)
      final publicKeyHex = publicKey.sublist(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();

      // Create a test message
      const message = 'test challenge message';
      final messageBytes = utf8.encode(message);

      // Sign the message with the private key
      final signatureBytes = await keyPair.privateKey.signBytes(Uint8List.fromList(messageBytes), Hash.sha256);
      final signatureHex = signatureBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

      // Test CryptoUtils.verifySignature with real signature
      final isValid = await CryptoUtils.verifySignature(
        message: message,
        signature: signatureHex,
        publicKey: publicKeyHex,
      );
      expect(
        isValid,
        isTrue,
        reason: 'Real ECDSA P-256 signature should verify correctly',
      );

      // Test CryptoAuth.verifyChallengeResponse with real challenge
      // Generate a proper challenge and sign it
      final challenge = CryptoUtils.generateChallenge();
      final challengeBytes = utf8.encode(challenge);
      final challengeSignatureBytes = await keyPair.privateKey.signBytes(Uint8List.fromList(challengeBytes), Hash.sha256);
      final challengeSignatureHex = challengeSignatureBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

      final result = await CryptoAuth.verifyChallengeResponse(
        publicKeyHex,
        challenge,
        challengeSignatureHex,
      );
      expect(
        result.success,
        isTrue,
        reason: 'Real ECDSA P-256 challenge response should succeed',
      );
      expect(result.errorCode, isNull);
      expect(result.errorMessage, isNull);
    });

    test('rejects invalid signatures correctly', () async {
      // Generate a real ECDSA P-256 key pair for testing
      final keyPair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
      final publicKey = await keyPair.publicKey.exportRawKey();
      final publicKeyHex = publicKey.sublist(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();

      // Generate a proper challenge
      final challenge = CryptoUtils.generateChallenge();

      // Create an invalid signature (all zeros)
      const invalidSignature = '0000000000000000000000000000000000000000000000000000000000000000'
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
      for (var i = 0; i < 10; i++) {
        final challenge = CryptoUtils.generateChallenge();
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
      const validKey = 'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456'
                       'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';
      expect(CryptoUtils.isValidPublicKey(validKey), isTrue);

      // Invalid cases
      expect(CryptoUtils.isValidPublicKey(''), isFalse);
      expect(CryptoUtils.isValidPublicKey('abc123'), isFalse);
      expect(
        CryptoUtils.isValidPublicKey(
          'g1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456',
        ),
        isFalse,
      );
    });
  });
}
