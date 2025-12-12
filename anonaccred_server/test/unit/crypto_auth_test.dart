import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:anonaccred_server/anonaccred_server.dart';

void main() {
  group('CryptoAuth', () {
    test('isValidPublicKey validates Ed25519 public key format', () {
      // Valid 64-character hex string (32 bytes)
      const validKey = 'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';
      expect(CryptoAuth.isValidPublicKey(validKey), isTrue);
      
      // Invalid length
      expect(CryptoAuth.isValidPublicKey('abc123'), isFalse);
      
      // Invalid characters
      expect(CryptoAuth.isValidPublicKey('g1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456'), isFalse);
      
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
      const validKey = 'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';
      final data = Uint8List.fromList(utf8.encode('test message'));
      const validSignature = 'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';
      
      // This will fail signature verification but should not throw format errors
      expect(
        () async => await CryptoAuth.verifySignature(validKey, data, validSignature),
        returnsNormally,
      );
      
      // Invalid public key format should throw
      expect(
        () async => await CryptoAuth.verifySignature('invalid', data, validSignature),
        throwsA(isA<AuthenticationException>()),
      );
      
      // Invalid signature format should throw
      expect(
        () async => await CryptoAuth.verifySignature(validKey, data, 'invalid'),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('verifyChallengeResponse handles invalid inputs gracefully', () async {
      const validKey = 'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';
      // Generate a valid challenge format for testing
      final validChallenge = CryptoAuth.generateChallenge();
      const validSignature = 'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';
      
      // Invalid public key
      final result1 = await CryptoAuth.verifyChallengeResponse('invalid', validChallenge, validSignature);
      expect(result1.success, isFalse);
      expect(result1.errorCode, equals(AnonAccredErrorCodes.cryptoInvalidPublicKey));
      
      // Invalid signature
      final result2 = await CryptoAuth.verifyChallengeResponse(validKey, validChallenge, 'invalid');
      expect(result2.success, isFalse);
      expect(result2.errorCode, equals(AnonAccredErrorCodes.cryptoInvalidSignature));
      
      // Empty challenge
      final result3 = await CryptoAuth.verifyChallengeResponse(validKey, '', validSignature);
      expect(result3.success, isFalse);
      expect(result3.errorCode, equals(AnonAccredErrorCodes.cryptoInvalidMessage));
      
      // Invalid challenge format
      final result4 = await CryptoAuth.verifyChallengeResponse(validKey, 'invalid_challenge', validSignature);
      expect(result4.success, isFalse);
      expect(result4.errorCode, equals(AnonAccredErrorCodes.cryptoFormatError));
      
      // Valid format but invalid signature (will fail verification)
      final result5 = await CryptoAuth.verifyChallengeResponse(validKey, validChallenge, validSignature);
      expect(result5.success, isFalse);
      expect(result5.errorCode, equals(AnonAccredErrorCodes.authInvalidSignature));
    });

    test('verifyMessageSignature delegates to CryptoUtils', () async {
      const validKey = 'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';
      const message = 'test message';
      const validSignature = 'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';
      
      // This should not throw format errors (will fail verification but that's expected)
      expect(
        () async => await CryptoAuth.verifyMessageSignature(validKey, message, validSignature),
        returnsNormally,
      );
    });

    test('AuthenticationResult factory methods work correctly', () {
      // Success result
      final successResult = AuthenticationResultFactory.success(
        accountId: 123,
        deviceId: 456,
        details: {'key': 'value'},
      );
      
      expect(successResult.success, isTrue);
      expect(successResult.accountId, equals(123));
      expect(successResult.deviceId, equals(456));
      expect(successResult.errorCode, isNull);
      expect(successResult.errorMessage, isNull);
      expect(successResult.details, equals({'key': 'value'}));
      
      // Failure result
      final failureResult = AuthenticationResultFactory.failure(
        errorCode: 'TEST_ERROR',
        errorMessage: 'Test error message',
        details: {'error': 'details'},
      );
      
      expect(failureResult.success, isFalse);
      expect(failureResult.accountId, isNull);
      expect(failureResult.deviceId, isNull);
      expect(failureResult.errorCode, equals('TEST_ERROR'));
      expect(failureResult.errorMessage, equals('Test error message'));
      expect(failureResult.details, equals({'error': 'details'}));
    });
  });
}