import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

/// Test error handling and privacy logging integration
void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('Error Handling Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    group('Authentication Error Handling', () {
      test('should return structured error for invalid signature on createAccount',
          () async {
        final challengeResponse =
            await endpoints.entrypoint.getChallenge(sessionBuilder);
        final proofOfWork = await PowTestHelper.mint(
          challengeResponse.challenge,
          difficulty: challengeResponse.difficulty,
        );

        // Use valid public key format but wrong signature
        const publicKey =
            'a123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
            'a123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const ultimateEncryptionPublicKeyHex =
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
            ultimateKeys: PublicKeyDuo(
              signingPublicKeyHex: publicKey,
              encryptionPublicKeyHex: ultimateEncryptionPublicKeyHex,
            ),
            encryptedDataKey: 'test_encrypted_data',
            deviceKeys: PublicKeyDuo(
              signingPublicKeyHex: publicKey,
              encryptionPublicKeyHex: publicKey,
            ),
            deviceKeyAttestation: 'dummy-attestation',
            deviceEncryptedDataKey: 'dummy-device-key',
            deviceLabel: 'dummy-device',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('should reject invalid PoW for device management',
          () async {
        // DeviceManagementEndpoint requires SignedPoW verification.
        expect(
          () => endpoints.deviceManagement.registerDeviceForAccount(
            sessionBuilder,
            challenge: 'invalid',
            proofOfWork: 'invalid',
            publicKeyHex: 'invalid',
            signature: 'invalid',
            newDeviceKeys: PublicKeyDuo(
              signingPublicKeyHex: 'device_pub_key_hex',
              encryptionPublicKeyHex: 'device_enc_pub_key_hex',
            ),
            pairingAttestation: 'invalid',
            newDeviceEncryptedDataKey: 'encrypted_data_key',
            label: 'Test Device',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('should reject invalid PoW for device revocation',
          () async {
        expect(
          () => endpoints.deviceManagement.revokeDevice(
            sessionBuilder,
            challenge: 'invalid',
            proofOfWork: 'invalid',
            publicKeyHex: 'invalid',
            signature: 'invalid',
            deviceId: UuidValue.fromString('d4e5f6a7-b8c9-4d0e-af1a-2b3c4d5e6f7a'),
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('should reject invalid PoW for device listing',
          () async {
        expect(
          () => endpoints.deviceManagement.listDevices(
            sessionBuilder,
            challenge: 'invalid',
            proofOfWork: 'invalid',
            publicKeyHex: 'invalid',
            signature: 'invalid',
          ),
          throwsA(isA<AuthenticationException>()),
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

        // Payload must match what the endpoint constructs (device key in payload)
        const emptyDeviceKey = '';
        final regChallenge =
            await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload =
            '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$emptyDeviceKey';
        final regSignature =
            SigningTestHelper.signWith(regPayload, ultimatePrivKey);
        final deviceKeyAttestation =
            SigningTestHelper.signWith(emptyDeviceKey, ultimatePrivKey);

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            challenge: regChallenge.challenge,
            proofOfWork: regPow,
            signature: regSignature,
            deviceKeyAttestation: deviceKeyAttestation,
            ultimateSigningPublicKeyHex:
                testAccount.ultimateSigningPublicKeyHex,
            deviceKeys: PublicKeyDuo(
              signingPublicKeyHex: emptyDeviceKey,
              encryptionPublicKeyHex: emptyDeviceKey,
            ),
            encryptedDataKey: 'encrypted_data_key',
            label: 'Test Device',
          ),
          throwsA(
            allOf(
              isA<AuthenticationException>(),
              predicate<AuthenticationException>(
                // Task 8: validateKeyDuo now runs before attestation
                // verification, so a malformed/empty key is rejected as a
                // format error rather than reaching signature verification
                // (which used to fail on an empty message first).
                (e) =>
                    e.toString().contains('CRYPTO_INVALID_PUBLIC_KEY') &&
                    e.toString().contains('is not a valid public key'),
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

        // Payload must match what the endpoint constructs (device key in payload)
        const invalidDeviceKey = 'invalid_format';
        final regChallenge =
            await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload =
            '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$invalidDeviceKey';
        final regSignature =
            SigningTestHelper.signWith(regPayload, ultimatePrivKey);
        final deviceKeyAttestation =
            SigningTestHelper.signWith(invalidDeviceKey, ultimatePrivKey);

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            challenge: regChallenge.challenge,
            proofOfWork: regPow,
            signature: regSignature,
            deviceKeyAttestation: deviceKeyAttestation,
            ultimateSigningPublicKeyHex:
                testAccount.ultimateSigningPublicKeyHex,
            deviceKeys: PublicKeyDuo(
              signingPublicKeyHex: invalidDeviceKey,
              encryptionPublicKeyHex: invalidDeviceKey,
            ),
            encryptedDataKey: 'encrypted_data_key',
            label: 'Test Device',
          ),
          throwsA(
            allOf(
              isA<AuthenticationException>(),
              predicate<AuthenticationException>(
                (e) =>
                    e.toString().contains('CRYPTO_INVALID_PUBLIC_KEY') &&
                    e.toString().contains('is not a valid public key'),
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

        final (validDevicePrivKey, validDevicePubKey) = SigningTestHelper.generateKeypair();
        final (_, validDeviceEncPubKey) = SigningTestHelper.generateKeypair();

        // Register first time — payload must use device key (matches endpoint)
        final regChallenge1 =
            await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow1 = await PowTestHelper.mint(
          regChallenge1.challenge,
          difficulty: regChallenge1.difficulty,
        );
        final regPayload1 =
            '${regChallenge1.challenge}:${DeviceMethods.registerDevice}:$validDevicePubKey';
        final regSignature1 =
            SigningTestHelper.signWith(regPayload1, validDevicePrivKey);
        final deviceKeyAttestation1 = SigningTestHelper.signWith(
          AccountInnerPayloads.registerDevice(
            PublicKeyDuo(
              signingPublicKeyHex: validDevicePubKey,
              encryptionPublicKeyHex: validDeviceEncPubKey,
            ),
          ),
          ultimatePrivKey,
        );

        await endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge1.challenge,
          proofOfWork: regPow1,
          signature: regSignature1,
          deviceKeyAttestation: deviceKeyAttestation1,
          ultimateSigningPublicKeyHex:
              testAccount.ultimateSigningPublicKeyHex,
          deviceKeys: PublicKeyDuo(
            signingPublicKeyHex: validDevicePubKey,
            encryptionPublicKeyHex: validDeviceEncPubKey,
          ),
          encryptedDataKey: 'encrypted_data_key',
          label: 'Test Device',
        );

        // Duplicate should fail
        final regChallenge2 =
            await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow2 = await PowTestHelper.mint(
          regChallenge2.challenge,
          difficulty: regChallenge2.difficulty,
        );
        final regPayload2 =
            '${regChallenge2.challenge}:${DeviceMethods.registerDevice}:$validDevicePubKey';
        final regSignature2 =
            SigningTestHelper.signWith(regPayload2, validDevicePrivKey);
        final deviceKeyAttestation2 = SigningTestHelper.signWith(
          AccountInnerPayloads.registerDevice(
            PublicKeyDuo(
              signingPublicKeyHex: validDevicePubKey,
              encryptionPublicKeyHex: validDeviceEncPubKey,
            ),
          ),
          ultimatePrivKey,
        );

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            challenge: regChallenge2.challenge,
            proofOfWork: regPow2,
            signature: regSignature2,
            deviceKeyAttestation: deviceKeyAttestation2,
            ultimateSigningPublicKeyHex:
                testAccount.ultimateSigningPublicKeyHex,
            deviceKeys: PublicKeyDuo(
              signingPublicKeyHex: validDevicePubKey,
              encryptionPublicKeyHex: validDeviceEncPubKey,
            ),
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