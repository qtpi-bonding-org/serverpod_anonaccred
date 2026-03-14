import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:test/test.dart';
import '../integration/test_tools/auth_test_helper.dart';
import '../integration/test_tools/serverpod_test_tools.dart';
import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/test_account_helper.dart';

/// Test error handling and privacy logging integration
void main() {
  withServerpod('Error Handling Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    group('Authentication Error Handling', () {
      test('should return structured error for invalid signature on createAccount',
          () async {
        final challengeResponse =
            await endpoints.account.getChallenge(sessionBuilder);
        final proofOfWork = await PowTestHelper.mint(
          challengeResponse.challenge,
          difficulty: challengeResponse.difficulty,
        );

        // Use valid public key format but wrong signature
        const publicKey =
            'a123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
            'a123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const ultimatePublicKey =
            'f123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
            'f123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        // Wrong signature (valid format but doesn't match payload)
        const wrongSignature =
            '0000000000000000000000000000000000000000000000000000000000000001'
            '0000000000000000000000000000000000000000000000000000000000000001';

        expect(
          () => endpoints.account.createAccount(
            sessionBuilder,
            challenge: challengeResponse.challenge,
            proofOfWork: proofOfWork,
            signature: wrongSignature,
            ultimateSigningPublicKeyHex: publicKey,
            encryptedDataKey: 'test_encrypted_data',
            ultimatePublicKey: ultimatePublicKey,
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('should return structured error for device authentication without auth',
          () async {
        expect(
          () => endpoints.device.authenticateDevice(
            sessionBuilder,
            'test_challenge',
            AuthTestHelper.generateValidSignature(),
          ),
          throwsA(
            allOf(
              isA<AuthenticationException>(),
              predicate<AuthenticationException>(
                (e) =>
                    e.toString().contains('AUTH_MISSING_KEY') &&
                    e.toString().contains('Authentication required'),
              ),
            ),
          ),
        );
      });

      test('should return structured error for device revocation without auth',
          () async {
        expect(
          () => endpoints.device.revokeDevice(sessionBuilder, 123),
          throwsA(
            allOf(
              isA<AuthenticationException>(),
              predicate<AuthenticationException>(
                (e) =>
                    e.toString().contains('AUTH_MISSING_KEY') &&
                    e.toString().contains('Authentication required'),
              ),
            ),
          ),
        );
      });

      test('should return structured error for device listing without auth',
          () async {
        expect(
          () => endpoints.device.listDevices(sessionBuilder),
          throwsA(
            allOf(
              isA<AuthenticationException>(),
              predicate<AuthenticationException>(
                (e) =>
                    e.toString().contains('AUTH_MISSING_KEY') &&
                    e.toString().contains('Authentication required'),
              ),
            ),
          ),
        );
      });
    });

    group('Device Registration Error Analysis', () {
      test('should provide structured errors for device registration failures',
          () async {
        final testAccount = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex:
              'a123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
              'a123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
        );

        // Empty device key
        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            testAccount.ultimateSigningPublicKeyHex,
            '',
            'encrypted_data_key',
            'Test Device',
          ),
          throwsA(
            allOf(
              isA<AuthenticationException>(),
              predicate<AuthenticationException>(
                (e) =>
                    e.toString().contains('AUTH_MISSING_KEY') &&
                    e.toString().contains(
                        'publicKey is required for registerDevice'),
              ),
            ),
          ),
        );

        // Invalid device key format
        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            testAccount.ultimateSigningPublicKeyHex,
            'invalid_format',
            'encrypted_data_key',
            'Test Device',
          ),
          throwsA(
            allOf(
              isA<AuthenticationException>(),
              predicate<AuthenticationException>(
                (e) =>
                    e.toString().contains('CRYPTO_INVALID_PUBLIC_KEY') &&
                    e.toString().contains(
                        'Invalid ECDSA P-256 public key format'),
              ),
            ),
          ),
        );

        // Duplicate device registration
        final validDeviceKey = AuthTestHelper.generateValidDeviceKey();
        await endpoints.device.registerDevice(
          sessionBuilder,
          testAccount.ultimateSigningPublicKeyHex,
          validDeviceKey,
          'encrypted_data_key',
          'Test Device',
        );

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            testAccount.ultimateSigningPublicKeyHex,
            validDeviceKey,
            'encrypted_data_key_2',
            'Test Device 2',
          ),
          throwsA(
            allOf(
              isA<AuthenticationException>(),
              predicate<AuthenticationException>(
                (e) =>
                    e.toString().contains('AUTH_DUPLICATE_DEVICE') &&
                    e.toString().contains(
                        'Device signing public key already registered'),
              ),
            ),
          ),
        );
      });
    });
  });
}
