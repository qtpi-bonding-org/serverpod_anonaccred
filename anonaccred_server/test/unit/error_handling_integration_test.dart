import 'package:test/test.dart';
import '../../lib/src/crypto_auth.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

/// Test error handling and privacy logging integration for Phase 2 authentication
void main() {
  withServerpod('Error Handling Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    group('Authentication Error Handling', () {
      test('should return structured error for invalid public key', () async {
        // Test with invalid public key format
        final invalidPublicKey = 'invalid_key';
        final encryptedDataKey = 'test_encrypted_data';

        try {
          await endpoints.account.createAccount(
            sessionBuilder,
            invalidPublicKey,
            encryptedDataKey,
          );
          fail('Expected AuthenticationException to be thrown');
        } catch (e) {
          expect(e.toString(), contains('CRYPTO_INVALID_PUBLIC_KEY'));
          expect(e.toString(), contains('Invalid Ed25519 public key format'));
        }
      });

      test('should return structured error for device not found', () async {
        final nonExistentPublicKey =
            '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
        final challenge = 'test_challenge';
        final signature =
            '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';

        final result = await endpoints.device.authenticateDevice(
          sessionBuilder,
          nonExistentPublicKey,
          challenge,
          signature,
        );

        expect(result.success, isFalse);
        expect(result.errorCode, equals('AUTH_DEVICE_NOT_FOUND'));
        expect(result.errorMessage, equals('Device not found'));

        // Test basic error structure
        expect(result.success, isFalse);
        expect(result.errorCode, isNotNull);
        expect(result.errorMessage, isNotNull);
      });

      test('should return structured error for account not found', () async {
        final nonExistentAccountId = 99999;

        try {
          await endpoints.device.listDevices(
            sessionBuilder,
            nonExistentAccountId,
          );
          fail('Expected AuthenticationException to be thrown');
        } catch (e) {
          expect(e.toString(), contains('AUTH_ACCOUNT_NOT_FOUND'));
          expect(e.toString(), contains('Account not found'));
        }
      });

      test('should handle duplicate device registration', () async {
        // Create account first
        final accountPublicKey =
            '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
        final accountEncryptedDataKey = 'test_encrypted_account_data';

        final account = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKey,
          accountEncryptedDataKey,
        );

        // Register device
        final devicePublicSubKey =
            'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890';
        final deviceEncryptedDataKey = 'test_encrypted_device_data';
        final deviceLabel = 'Test Device';

        await endpoints.device.registerDevice(
          sessionBuilder,
          account.id!,
          devicePublicSubKey,
          deviceEncryptedDataKey,
          deviceLabel,
        );

        // Try to register the same device again
        try {
          await endpoints.device.registerDevice(
            sessionBuilder,
            account.id!,
            devicePublicSubKey,
            deviceEncryptedDataKey,
            'Duplicate Device',
          );
          fail('Expected AuthenticationException to be thrown');
        } catch (e) {
          expect(e.toString(), contains('AUTH_DUPLICATE_DEVICE'));
          expect(e.toString(), contains('Public subkey already registered'));
        }
      });
    });

    group('AuthenticationResult Error Analysis', () {
      test('should provide comprehensive error analysis for success', () async {
        await endpoints.device.generateAuthChallenge(sessionBuilder);

        // Create a successful result for testing
        final successResult = AuthenticationResultFactory.success(
          accountId: 1,
          deviceId: 1,
          details: {'test': 'data'},
        );

        expect(successResult.success, isTrue);
        expect(successResult.accountId, equals(1));
        expect(successResult.deviceId, equals(1));
        expect(successResult.errorCode, isNull);
        expect(successResult.errorMessage, isNull);
      });

      test('should provide comprehensive error analysis for failure', () async {
        final failureResult = AuthenticationResultFactory.failure(
          errorCode: 'AUTH_INVALID_SIGNATURE',
          errorMessage: 'Signature verification failed',
          details: {'publicKey': 'test_key'},
        );

        expect(failureResult.success, isFalse);
        expect(failureResult.errorCode, equals('AUTH_INVALID_SIGNATURE'));
        expect(
          failureResult.errorMessage,
          equals('Signature verification failed'),
        );
        expect(failureResult.accountId, isNull);
        expect(failureResult.deviceId, isNull);
        expect(failureResult.details, isNotNull);
      });
    });
  });
}
