import 'package:test/test.dart';
import 'package:anonaccred_server/anonaccred_server.dart';
import '../integration/test_tools/serverpod_test_tools.dart';
import '../integration/test_tools/auth_test_helper.dart';

/// Test error handling and privacy logging integration for Phase 2 authentication
void main() {
  withServerpod('Error Handling Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    group('Authentication Error Handling', () {
      test('should return structured error for invalid public key', () async {
        // Test with invalid public key format
        const invalidPublicKey = 'invalid_key';
        const encryptedDataKey = 'test_encrypted_data';

        try {
          await endpoints.account.createAccount(
            sessionBuilder,
            invalidPublicKey,
            encryptedDataKey,
          );
          fail('Expected AuthenticationException to be thrown');
        } on AuthenticationException catch (e) {
          expect(e.toString(), contains('CRYPTO_INVALID_PUBLIC_KEY'));
          expect(e.toString(), contains('Invalid Ed25519 public key format'));
        }
      });

      test('should return structured error for device authentication without auth', () async {
        expect(
          () => endpoints.device.authenticateDevice(
            sessionBuilder,
            'test_challenge',
            AuthTestHelper.generateValidSignature(),
          ),
          throwsA(
            allOf(
              isA<AuthenticationException>(),
              predicate<AuthenticationException>((e) => 
                e.toString().contains('AUTH_MISSING_KEY') &&
                e.toString().contains('Authentication required')
              ),
            ),
          ),
        );
      });

      test('should return structured error for device revocation without auth', () async {
        expect(
          () => endpoints.device.revokeDevice(
            sessionBuilder,
            123, // Any device ID
          ),
          throwsA(
            allOf(
              isA<AuthenticationException>(),
              predicate<AuthenticationException>((e) => 
                e.toString().contains('AUTH_MISSING_KEY') &&
                e.toString().contains('Authentication required')
              ),
            ),
          ),
        );
      });

      test('should return structured error for device listing without auth', () async {
        expect(
          () => endpoints.device.listDevices(sessionBuilder),
          throwsA(
            allOf(
              isA<AuthenticationException>(),
              predicate<AuthenticationException>((e) => 
                e.toString().contains('AUTH_MISSING_KEY') &&
                e.toString().contains('Authentication required')
              ),
            ),
          ),
        );
      });

      test('should return structured error for empty challenge', () async {
        expect(
          () => endpoints.device.authenticateDevice(
            sessionBuilder,
            '', // Empty challenge
            AuthTestHelper.generateValidSignature(),
          ),
          throwsA(
            allOf(
              isA<AuthenticationException>(),
              predicate<AuthenticationException>((e) => 
                e.toString().contains('AUTH_MISSING_KEY') ||
                e.toString().contains('challenge')
              ),
            ),
          ),
        );
      });
    });

    group('Device Registration Error Analysis', () {
      test('should provide structured errors for device registration failures', () async {
        // Create test account
        const accountPublicKey =
            'a123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const accountEncryptedDataKey = 'encrypted_test_data_key_7';

        final testAccount = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKey,
          accountEncryptedDataKey,
        );

        // Test empty device key
        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            testAccount.id!,
            '', // Empty device key
            'encrypted_data_key',
            'Test Device',
          ),
          throwsA(
            allOf(
              isA<AuthenticationException>(),
              predicate<AuthenticationException>((e) => 
                e.toString().contains('AUTH_MISSING_KEY') &&
                e.toString().contains('Public subkey is required')
              ),
            ),
          ),
        );

        // Test invalid device key format
        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            testAccount.id!,
            'invalid_format', // Invalid format
            'encrypted_data_key',
            'Test Device',
          ),
          throwsA(
            allOf(
              isA<AuthenticationException>(),
              predicate<AuthenticationException>((e) => 
                e.toString().contains('CRYPTO_INVALID_PUBLIC_KEY') &&
                e.toString().contains('Invalid Ed25519 public subkey format')
              ),
            ),
          ),
        );

        // Test duplicate device registration
        final validDeviceKey = AuthTestHelper.generateValidDeviceKey();
        
        // First registration should succeed
        await endpoints.device.registerDevice(
          sessionBuilder,
          testAccount.id!,
          validDeviceKey,
          'encrypted_data_key',
          'Test Device',
        );

        // Second registration with same key should fail
        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            testAccount.id!,
            validDeviceKey, // Duplicate key
            'encrypted_data_key_2',
            'Test Device 2',
          ),
          throwsA(
            allOf(
              isA<AuthenticationException>(),
              predicate<AuthenticationException>((e) => 
                e.toString().contains('AUTH_DUPLICATE_DEVICE') &&
                e.toString().contains('Public subkey already registered')
              ),
            ),
          ),
        );
      });
    });
  });
}