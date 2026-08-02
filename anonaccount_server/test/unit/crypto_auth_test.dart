import 'dart:convert';
import 'dart:typed_data';
import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:test/test.dart';

import '../test_helpers/signing_test_helper.dart';

void main() {
  group('CryptoAuth', () {
    test('isValidPublicKey validates ECDSA P-256 public key format', () {
      // Generate a real keypair (the helper emits 130-char SEC1 keys).
      final (_, validKey) = SigningTestHelper.generateKeypair();
      expect(CryptoAuth.isValidPublicKey(validKey), isTrue);

      // A 130-char SEC1 string with the test helper's pre-generated key
      // (kept as a check that testPublicKeyHex conforms).
      final preGeneratedValid = SigningTestHelper.testPublicKeyHex;
      expect(preGeneratedValid.length, 130);
      expect(CryptoAuth.isValidPublicKey(preGeneratedValid), isTrue);

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
      // Use a real keypair for the format check (must be SEC1 130-hex now).
      final (privKey, validKey) = SigningTestHelper.generateKeypair();
      final data = Uint8List.fromList(utf8.encode('test message'));
      // Real signature, signed by the matching private key, so we get past
      // format checks and verify verification works (it will succeed here).
      final validSignature = SigningTestHelper.signWith(
        'test message',
        privKey,
      );

      // Successful verification — should not throw.
      final ok = await CryptoAuth.verifySignature(validKey, data, validSignature);
      expect(ok, isTrue);

      // Invalid public key format should throw
      expect(
        () async =>
            CryptoAuth.verifySignature('invalid', data, validSignature),
        throwsA(isA<AuthenticationException>()),
      );

      // Invalid signature format should throw
      expect(
        () async => CryptoAuth.verifySignature(validKey, data, 'invalid'),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('verifyChallengeResponse handles invalid inputs gracefully', () async {
      final (privKey, validKey) = SigningTestHelper.generateKeypair();
      // Generate a valid challenge format for testing
      final validChallenge = CryptoAuth.generateChallenge();
      // Valid ECDSA P-256 signature format (128 hex chars)
      final validSignature = SigningTestHelper.signWith(validChallenge, privKey);

      // Invalid public key should return failure result
      final result1 = await CryptoAuth.verifyChallengeResponse(
        'invalid_key',
        validChallenge,
        validSignature,
      );
      expect(result1.success, isFalse);
      expect(result1.errorCode, equals(AnonAccountErrorCodes.cryptoInvalidPublicKey));

      // Invalid signature should return failure result
      final result2 = await CryptoAuth.verifyChallengeResponse(
        validKey,
        validChallenge,
        'invalid_signature',
      );
      expect(result2.success, isFalse);
      expect(result2.errorCode, equals(AnonAccountErrorCodes.cryptoInvalidSignature));

      // Empty challenge should return failure result
      final result3 = await CryptoAuth.verifyChallengeResponse(
        validKey,
        '',
        validSignature,
      );
      expect(result3.success, isFalse);
      expect(result3.errorCode, equals(AnonAccountErrorCodes.cryptoInvalidMessage));
    });

    test('verifyMessageSignature delegates to CryptoUtils', () async {
      final (privKey, validKey) = SigningTestHelper.generateKeypair();
      const message = 'test message';
      final validSignature = SigningTestHelper.signWith(message, privKey);

      // Successful verification — should not throw.
      final ok = await CryptoAuth.verifyMessageSignature(
        validKey,
        message,
        validSignature,
      );
      expect(ok, isTrue);

      // Invalid public key format should throw
      expect(
        () async => CryptoAuth.verifyMessageSignature(
          'invalid',
          message,
          validSignature,
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('AuthenticationResult factory methods work correctly', () {
      // Test success result
      final testDeviceId = UuidValue.fromString('00000000-0000-0000-0000-000000000456');
      final successResult = AuthenticationResultFactory.success(
        deviceId: testDeviceId,
        details: {'test': 'value'},
      );
      expect(successResult.success, isTrue);
      expect(successResult.deviceId, equals(testDeviceId));
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
