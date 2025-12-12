import 'package:test/test.dart';
import 'package:anonaccred_server/anonaccred_server.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Edge Case Handling Tests', (sessionBuilder, endpoints) {
    group('Device Registration Edge Cases', () {
      test('registerDevice - should reject empty public subkey', () async {
        // Create a test account first
        const accountPublicKey =
            'a123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const accountEncryptedDataKey = 'encrypted_test_data_key';

        final testAccount = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKey,
          accountEncryptedDataKey,
        );

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            testAccount.id!,
            '', // Empty public subkey
            'encrypted_data_key',
            'Test Device',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('registerDevice - should reject empty encrypted data key', () async {
        // Create a test account first
        const accountPublicKey =
            'b123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const accountEncryptedDataKey = 'encrypted_test_data_key';

        final testAccount = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKey,
          accountEncryptedDataKey,
        );

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            testAccount.id!,
            'c123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
            '', // Empty encrypted data key
            'Test Device',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('registerDevice - should reject empty device label', () async {
        // Create a test account first
        const accountPublicKey =
            'd123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const accountEncryptedDataKey = 'encrypted_test_data_key';

        final testAccount = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKey,
          accountEncryptedDataKey,
        );

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            testAccount.id!,
            'e123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
            'encrypted_data_key',
            '', // Empty label
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });
    });

    group('Device Authentication Edge Cases', () {
      test('authenticateDevice - should reject empty public subkey', () async {
        final result = await endpoints.device.authenticateDevice(
          sessionBuilder,
          '', // Empty public subkey
          'valid_challenge',
          'valid_signature',
        );

        expect(result.success, isFalse);
        expect(result.errorCode, equals(AnonAccredErrorCodes.authMissingKey));
      });

      test('authenticateDevice - should reject empty challenge', () async {
        final result = await endpoints.device.authenticateDevice(
          sessionBuilder,
          'f123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
          '', // Empty challenge
          'valid_signature',
        );

        expect(result.success, isFalse);
        expect(
          result.errorCode,
          equals(AnonAccredErrorCodes.cryptoInvalidMessage),
        );
      });

      test('authenticateDevice - should reject empty signature', () async {
        final result = await endpoints.device.authenticateDevice(
          sessionBuilder,
          'g123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
          'valid_challenge',
          '', // Empty signature
        );

        expect(result.success, isFalse);
        expect(
          result.errorCode,
          equals(AnonAccredErrorCodes.cryptoInvalidSignature),
        );
      });
    });

    group('Device Revocation Edge Cases', () {
      test(
        'revokeDevice - should throw exception for non-existent account',
        () async {
          const nonExistentAccountId = 99999;
          const deviceId = 1;

          expect(
            () => endpoints.device.revokeDevice(
              sessionBuilder,
              nonExistentAccountId,
              deviceId,
            ),
            throwsA(isA<AuthenticationException>()),
          );
        },
      );

      test(
        'revokeDevice - should throw exception for non-existent device',
        () async {
          // Create a test account first
          const accountPublicKey =
              '1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
          const accountEncryptedDataKey = 'encrypted_test_data_key';

          final testAccount = await endpoints.account.createAccount(
            sessionBuilder,
            accountPublicKey,
            accountEncryptedDataKey,
          );

          const nonExistentDeviceId = 99999;

          expect(
            () => endpoints.device.revokeDevice(
              sessionBuilder,
              testAccount.id!,
              nonExistentDeviceId,
            ),
            throwsA(isA<AuthenticationException>()),
          );
        },
      );
    });

    group('Challenge Expiration Edge Cases', () {
      test('verifyChallengeResponse - should reject expired challenge', () async {
        // Create an expired challenge by manually creating one with old timestamp
        // This simulates a challenge that was created more than 5 minutes ago
        const expiredTimestamp = 1000000000000; // Very old timestamp (2001)
        final timestampHex = expiredTimestamp
            .toRadixString(16)
            .padLeft(16, '0');
        // Take only the last 16 characters to fit the 8-byte timestamp format
        final shortTimestampHex = timestampHex.substring(
          timestampHex.length - 16,
        );
        final expiredChallenge =
            shortTimestampHex +
            '0123456789abcdef0123456789abcdef0123456789abcdef';

        final result = await CryptoAuth.verifyChallengeResponse(
          '2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
          expiredChallenge,
          'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456',
        );

        expect(result.success, isFalse);
        expect(
          result.errorCode,
          equals(AnonAccredErrorCodes.authChallengeExpired),
        );
      });

      test(
        'generateChallenge - should create valid challenges with timestamps',
        () {
          final challenge1 = CryptoAuth.generateChallenge();
          final challenge2 = CryptoAuth.generateChallenge();

          // Challenges should be 64 hex characters
          expect(challenge1.length, equals(64));
          expect(challenge2.length, equals(64));

          // Challenges should be unique
          expect(challenge1, isNot(equals(challenge2)));

          // Challenges should be valid (not expired)
          expect(CryptoUtils.isChallengeValid(challenge1), isTrue);
          expect(CryptoUtils.isChallengeValid(challenge2), isTrue);
        },
      );
    });
  });
}
