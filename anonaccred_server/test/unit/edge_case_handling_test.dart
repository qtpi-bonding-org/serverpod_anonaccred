import 'package:test/test.dart';
import 'package:anonaccred_server/anonaccred_server.dart';
import '../integration/test_tools/serverpod_test_tools.dart';
import '../integration/test_tools/auth_test_helper.dart';

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

      test('registerDevice - should reject invalid public subkey format', () async {
        // Create a test account first
        const accountPublicKey =
            'b123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const accountEncryptedDataKey = 'encrypted_test_data_key_2';

        final testAccount = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKey,
          accountEncryptedDataKey,
        );

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            testAccount.id!,
            'invalid_key_format', // Invalid format
            'encrypted_data_key',
            'Test Device',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });
    });

    group('Device Authentication Edge Cases', () {
      test('authenticateDevice - should fail without authentication', () async {
        const challenge = 'test_challenge_12345';
        final signature = AuthTestHelper.generateValidSignature();

        expect(
          () => endpoints.device.authenticateDevice(
            sessionBuilder,
            challenge,
            signature,
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('authenticateDevice - should fail with empty challenge', () async {
        expect(
          () => endpoints.device.authenticateDevice(
            sessionBuilder,
            '', // Empty challenge
            AuthTestHelper.generateValidSignature(),
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('authenticateDevice - should fail with empty signature', () async {
        expect(
          () => endpoints.device.authenticateDevice(
            sessionBuilder,
            'test_challenge',
            '', // Empty signature
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });
    });

    group('Device Revocation Edge Cases', () {
      test('revokeDevice - should fail without authentication', () async {
        expect(
          () => endpoints.device.revokeDevice(
            sessionBuilder,
            123, // Any device ID
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('revokeDevice - should fail with invalid device ID', () async {
        expect(
          () => endpoints.device.revokeDevice(
            sessionBuilder,
            -1, // Invalid device ID
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });
    });

    group('Device Listing Edge Cases', () {
      test('listDevices - should fail without authentication', () async {
        expect(
          () => endpoints.device.listDevices(sessionBuilder),
          throwsA(isA<AuthenticationException>()),
        );
      });
    });
  });
}