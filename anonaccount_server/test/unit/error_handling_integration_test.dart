import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:test/test.dart';
import '../integration/test_tools/serverpod_test_tools.dart';
import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
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
            publicKeyHex: publicKey,
            ultimateSigningPublicKeyHex: publicKey,
            encryptedDataKey: 'test_encrypted_data',
            ultimatePublicKey: ultimatePublicKey,
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('should reject unauthenticated device management',
          () async {
        // DeviceManagementEndpoint requires login — Serverpod enforces this
        // at the framework level before endpoint code runs.
        expect(
          () => endpoints.deviceManagement.registerDeviceForAccount(
            sessionBuilder,
            'device_pub_key_hex',
            'encrypted_data_key',
            'Test Device',
          ),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });

      test('should reject unauthenticated device revocation',
          () async {
        expect(
          () => endpoints.deviceManagement.revokeDevice(sessionBuilder, 123),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });

      test('should reject unauthenticated device listing',
          () async {
        expect(
          () => endpoints.deviceManagement.listDevices(sessionBuilder),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });
    });

    group('Device Registration Error Analysis', () {
      test('should reject empty device key with structured error', () async {
        final (ultimatePrivKey, ultimatePubKey) =
            SigningTestHelper.generateKeypair();

        final testAccount = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
        );

        final regChallenge =
            await endpoints.device.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload =
            '${regChallenge.challenge}:registerDevice:$ultimatePubKey';
        final regSignature =
            SigningTestHelper.signWith(regPayload, ultimatePrivKey);

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            challenge: regChallenge.challenge,
            proofOfWork: regPow,
            signature: regSignature,
            ultimateSigningPublicKeyHex:
                testAccount.ultimateSigningPublicKeyHex,
            deviceSigningPublicKeyHex: '',
            encryptedDataKey: 'encrypted_data_key',
            label: 'Test Device',
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
      });

      test('should reject invalid device key format with structured error',
          () async {
        final (ultimatePrivKey, ultimatePubKey) =
            SigningTestHelper.generateKeypair();

        final testAccount = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
        );

        final regChallenge =
            await endpoints.device.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload =
            '${regChallenge.challenge}:registerDevice:$ultimatePubKey';
        final regSignature =
            SigningTestHelper.signWith(regPayload, ultimatePrivKey);

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            challenge: regChallenge.challenge,
            proofOfWork: regPow,
            signature: regSignature,
            ultimateSigningPublicKeyHex:
                testAccount.ultimateSigningPublicKeyHex,
            deviceSigningPublicKeyHex: 'invalid_format',
            encryptedDataKey: 'encrypted_data_key',
            label: 'Test Device',
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
      });

      test('should reject duplicate device registration with structured error',
          () async {
        final (ultimatePrivKey, ultimatePubKey) =
            SigningTestHelper.generateKeypair();

        final testAccount = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
        );

        final (_, validDevicePubKey) = SigningTestHelper.generateKeypair();

        // Register first time
        final regChallenge1 =
            await endpoints.device.getChallenge(sessionBuilder);
        final regPow1 = await PowTestHelper.mint(
          regChallenge1.challenge,
          difficulty: regChallenge1.difficulty,
        );
        final regPayload1 =
            '${regChallenge1.challenge}:registerDevice:$ultimatePubKey';
        final regSignature1 =
            SigningTestHelper.signWith(regPayload1, ultimatePrivKey);

        await endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge1.challenge,
          proofOfWork: regPow1,
          signature: regSignature1,
          ultimateSigningPublicKeyHex:
              testAccount.ultimateSigningPublicKeyHex,
          deviceSigningPublicKeyHex: validDevicePubKey,
          encryptedDataKey: 'encrypted_data_key',
          label: 'Test Device',
        );

        // Duplicate should fail
        final regChallenge2 =
            await endpoints.device.getChallenge(sessionBuilder);
        final regPow2 = await PowTestHelper.mint(
          regChallenge2.challenge,
          difficulty: regChallenge2.difficulty,
        );
        final regPayload2 =
            '${regChallenge2.challenge}:registerDevice:$ultimatePubKey';
        final regSignature2 =
            SigningTestHelper.signWith(regPayload2, ultimatePrivKey);

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            challenge: regChallenge2.challenge,
            proofOfWork: regPow2,
            signature: regSignature2,
            ultimateSigningPublicKeyHex:
                testAccount.ultimateSigningPublicKeyHex,
            deviceSigningPublicKeyHex: validDevicePubKey,
            encryptedDataKey: 'encrypted_data_key_2',
            label: 'Test Device 2',
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
