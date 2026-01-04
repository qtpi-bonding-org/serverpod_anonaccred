import 'dart:convert';
import 'dart:typed_data';
import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:test/test.dart';

void main() {
  group('CryptoAuth', () {
    test('isValidPublicKey validates ECDSA P-256 public key format', () {
      // Valid 128-character hex string (64 bytes = 32 bytes x + 32 bytes y)
      const validKey =
          'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';
      expect(CryptoAuth.isValidPublicKey(validKey), isTrue);

      // Valid 130-character hex string with 04 prefix
      const validKeyWithPrefix =
          '04a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';
      expect(CryptoAuth.isValidPublicKey(validKeyWithPrefix), isTrue);

      // Invalid length (Ed25519 format - too short)
      const ed25519Key = 'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';
      expect(CryptoAuth.isValidPublicKey(ed25519Key), isFalse);

      // Invalid length (too short)
      expect(CryptoAuth.isValidPublicKey('abc123'), isFalse);

      // Invalid characters
      expect(
        CryptoAuth.isValidPublicKey(
          'g1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456',
        ),
        isFalse,
      );

      // Empty string
      expect(CryptoAuth.isValidPublicKey(''), isFalse);
    });

    test('generateChallenge creates unique challenges', () {
      final challenge1 = CryptoAuth.generateChallenge();
      final challenge2 = CryptoAuth.generateChallenge();

      // Challenges should be different
      expect(challenge1, isNot(equals(challenge2)));

      // Challenges should be 64 hex characters (32 bytes)
      expect(challenge1.length, equals(64));
      expect(challenge2.length, equals(64));

      // Challenges should be valid hex
      final hexPattern = RegExp(r'^[0-9a-fA-F]+$');
      expect(hexPattern.hasMatch(challenge1), isTrue);
      expect(hexPattern.hasMatch(challenge2), isTrue);
    });

    test('verifySignature validates input formats', () async {
      // Valid ECDSA P-256 public key (128 hex chars)
      const validKey =
          'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';
      final data = Uint8List.fromList(utf8.encode('test message'));
      // Valid ECDSA P-256 signature format (128 hex chars = r + s)
      const validSignature =
          'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';

      // This will fail signature verification but should not throw format errors
      // We expect it to return false or throw a verification error, not a format error
      try {
        await CryptoAuth.verifySignature(validKey, data, validSignature);
        // If it doesn't throw, that's fine - it just means verification completed
      } on AuthenticationException catch (e) {
        // Should be a verification failure, not a format error
        expect(e.code, anyOf([
          AnonAccredErrorCodes.cryptoVerificationFailed,
          AnonAccredErrorCodes.authInvalidSignature,
        ]));
      }

      // Invalid public key format should throw
      expect(
        () async =>
            await CryptoAuth.verifySignature('invalid', data, validSignature),
        throwsA(isA<AuthenticationException>()),
      );

      // Invalid signature format should throw
      expect(
        () async => await CryptoAuth.verifySignature(validKey, data, 'invalid'),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('verifyChallengeResponse handles invalid inputs gracefully', () async {
      // Valid ECDSA P-256 public key (128 hex chars)
      const validKey =
          'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';
      // Generate a valid challenge format for testing
      final validChallenge = CryptoAuth.generateChallenge();
      // Valid ECDSA P-256 signature format (128 hex chars)
      const validSignature =
          'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';

      // Invalid public key should return failure result
      final result1 = await CryptoAuth.verifyChallengeResponse(
        'invalid_key',
        validChallenge,
        validSignature,
      );
      expect(result1.success, isFalse);
      expect(result1.errorCode, equals(AnonAccredErrorCodes.cryptoInvalidPublicKey));

      // Invalid signature should return failure result
      final result2 = await CryptoAuth.verifyChallengeResponse(
        validKey,
        validChallenge,
        'invalid_signature',
      );
      expect(result2.success, isFalse);
      expect(result2.errorCode, equals(AnonAccredErrorCodes.cryptoInvalidSignature));

      // Empty challenge should return failure result
      final result3 = await CryptoAuth.verifyChallengeResponse(
        validKey,
        '',
        validSignature,
      );
      expect(result3.success, isFalse);
      expect(result3.errorCode, equals(AnonAccredErrorCodes.cryptoInvalidMessage));
    });

    test('verifyMessageSignature delegates to CryptoUtils', () async {
      // Valid ECDSA P-256 public key (128 hex chars)
      const validKey =
          'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';
      const message = 'test message';
      // Valid ECDSA P-256 signature format (128 hex chars)
      const validSignature =
          'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';

      // This will fail signature verification but should not throw format errors
      try {
        await CryptoAuth.verifyMessageSignature(
          validKey,
          message,
          validSignature,
        );
        // If it doesn't throw, that's fine - it just means verification completed
      } on AuthenticationException catch (e) {
        // Should be a verification failure, not a format error
        expect(e.code, anyOf([
          AnonAccredErrorCodes.cryptoVerificationFailed,
          AnonAccredErrorCodes.authInvalidSignature,
        ]));
      }

      // Invalid public key format should throw
      expect(
        () async => await CryptoAuth.verifyMessageSignature(
          'invalid',
          message,
          validSignature,
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('AuthenticationResult factory methods work correctly', () {
      // Test success result
      final successResult = AuthenticationResultFactory.success(
        accountId: 123,
        deviceId: 456,
        details: {'test': 'value'},
      );
      expect(successResult.success, isTrue);
      expect(successResult.accountId, equals(123));
      expect(successResult.deviceId, equals(456));
      expect(successResult.details?['test'], equals('value'));

      // Test failure result
      final failureResult = AuthenticationResultFactory.failure(
        errorCode: 'TEST_ERROR',
        errorMessage: 'Test error message',
        details: {'error': 'details'},
      );
      expect(failureResult.success, isFalse);
      expect(failureResult.errorCode, equals('TEST_ERROR'));
      expect(failureResult.errorMessage, equals('Test error message'));
      expect(failureResult.details?['error'], equals('details'));
    });
  });
}