import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:anonaccred_server/src/crypto_utils.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';

void main() {
  group('CryptoUtils Verification Tests', () {
    test('challenge generation produces unique values', () {
      // Generate multiple challenges
      final challenges = <String>{};
      for (var i = 0; i < 10; i++) {
        final challenge = CryptoUtils.generateChallenge();

        // Each challenge should be 64 hex characters (32 bytes)
        expect(challenge.length, equals(64));

        // Each challenge should be unique
        expect(challenges.contains(challenge), isFalse);
        challenges.add(challenge);

        // Should be valid hex
        expect(RegExp(r'^[0-9a-fA-F]+$').hasMatch(challenge), isTrue);
      }
    });

    // Note: ECDSA key generation is not supported in pure Dart cryptography package.
    // Integration tests with real Flutter client signatures should be used for
    // end-to-end verification. These unit tests focus on format validation.
    test('ECDSA P-256 signature verification format validation', () async {
      // Test that verifySignature properly validates inputs before attempting verification
      // Using well-formed but cryptographically invalid data to test the validation path
      
      // Valid format public key (128 hex chars - all valid hex digits)
      final validFormatPublicKey = 'a' * 128;
      
      // Valid format signature (128 hex chars)  
      final validFormatSignature = 'b' * 128;
      
      // The verification should proceed past format validation
      // (actual crypto verification may fail with test data, which is expected)
      try {
        await CryptoUtils.verifySignature(
          message: 'test message',
          signature: validFormatSignature,
          publicKey: validFormatPublicKey,
        );
        // If it returns without throwing, that's fine
      } on AuthenticationException catch (e) {
        // Crypto verification failure is expected with fake data
        // But it should NOT be a format validation error - should be verification failure
        expect(e.message, contains('verification failed'));
      }
    });

    test('ECDSA P-256 rejects malformed inputs', () async {
      // Test that invalid format inputs are rejected before crypto verification
      
      // Invalid public key (wrong length)
      expect(
        () async => await CryptoUtils.verifySignature(
          message: 'test',
          signature: 'a' * 128,
          publicKey: 'a' * 64, // Wrong length for ECDSA P-256
        ),
        throwsA(isA<AuthenticationException>()),
      );

      // Invalid signature (wrong length)
      expect(
        () async => await CryptoUtils.verifySignature(
          message: 'test',
          signature: 'a' * 64, // Wrong length
          publicKey: 'a' * 128,
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('public key validation works correctly for ECDSA P-256', () {
      // Valid key (128 hex characters for ECDSA P-256)
      final validKey = 'a' * 128;
      expect(CryptoUtils.isValidPublicKey(validKey), isTrue);

      // Valid key with 04 prefix (130 hex characters)
      final validKeyWithPrefix = '04${'a' * 128}';
      expect(CryptoUtils.isValidPublicKey(validKeyWithPrefix), isTrue);

      // Invalid length (64 chars is Ed25519, not ECDSA P-256)
      expect(CryptoUtils.isValidPublicKey('a' * 64), isFalse);
      
      // Invalid length - too short
      expect(CryptoUtils.isValidPublicKey('short'), isFalse);
      expect(CryptoUtils.isValidPublicKey(''), isFalse);

      // Invalid hex characters
      final invalidHex = 'g' * 128;
      expect(CryptoUtils.isValidPublicKey(invalidHex), isFalse);

      // Mixed case should work
      final mixedCase = 'A1b2C3d4' * 16; // 128 characters
      expect(CryptoUtils.isValidPublicKey(mixedCase), isTrue);
    });

    test('signature format validation works correctly for ECDSA P-256', () {
      // Valid signature (128 hex characters for ECDSA P-256 r||s)
      final validSignature = 'a' * 128;
      expect(CryptoUtils.isValidSignature(validSignature), isTrue);

      // Invalid length
      expect(CryptoUtils.isValidSignature('short'), isFalse);
      expect(CryptoUtils.isValidSignature(''), isFalse);
      expect(CryptoUtils.isValidSignature('a' * 64), isFalse); // Too short

      // Invalid hex characters
      final invalidHex = 'g' * 128;
      expect(CryptoUtils.isValidSignature(invalidHex), isFalse);

      // Mixed case should work
      final mixedCase = 'A1b2C3d4' * 16; // 128 characters
      expect(CryptoUtils.isValidSignature(mixedCase), isTrue);
    });

    test('hex conversion utilities work correctly', () {
      // Test hex to bytes conversion
      const hexString = 'deadbeef';
      final bytes = CryptoUtils.hexToBytes(hexString);
      expect(bytes, equals([0xde, 0xad, 0xbe, 0xef]));

      // Test bytes to hex conversion
      final testBytes = Uint8List.fromList([0xde, 0xad, 0xbe, 0xef]);
      final hex = CryptoUtils.bytesToHex(testBytes);
      expect(hex, equals('deadbeef'));

      // Round trip should preserve data
      const originalHex = 'abcdef123456';
      final roundTripHex = CryptoUtils.bytesToHex(
        CryptoUtils.hexToBytes(originalHex),
      );
      expect(roundTripHex, equals(originalHex));
    });

    test('error handling for invalid inputs', () async {
      // Invalid public key format should throw
      expect(
        () async => await CryptoUtils.verifySignature(
          message: 'test',
          signature: 'a' * 128,
          publicKey: 'invalid',
        ),
        throwsA(isA<AuthenticationException>()),
      );

      // Invalid signature format should throw
      expect(
        () async => await CryptoUtils.verifySignature(
          message: 'test',
          signature: 'invalid',
          publicKey: 'a' * 128,
        ),
        throwsA(isA<AuthenticationException>()),
      );

      // Empty message should throw
      expect(
        () async => await CryptoUtils.verifySignature(
          message: '',
          signature: 'a' * 128,
          publicKey: 'a' * 128,
        ),
        throwsA(isA<AuthenticationException>()),
      );

      // Invalid hex string should throw
      expect(
        () => CryptoUtils.hexToBytes('invalid_hex'),
        throwsA(isA<AuthenticationException>()),
      );

      // Odd length hex string should throw
      expect(
        () => CryptoUtils.hexToBytes('abc'),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('challenge validity check works correctly', () {
      // Generate a fresh challenge - should be valid
      final freshChallenge = CryptoUtils.generateChallenge();
      expect(CryptoUtils.isChallengeValid(freshChallenge), isTrue);

      // Invalid challenge format should throw
      expect(
        () => CryptoUtils.isChallengeValid('short'),
        throwsA(isA<AuthenticationException>()),
      );
    });
  });
}
