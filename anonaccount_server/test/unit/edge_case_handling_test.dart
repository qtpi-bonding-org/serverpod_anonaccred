import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';
import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/test_account_helper.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('Edge Case Handling Tests', (sessionBuilder, endpoints) {
    group('Device Registration Edge Cases', () {
      test('registerDevice - should reject empty public subkey', () async {
        // Use real keypair so PoW signature verification passes
        final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

        final testAccount = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          encryptedDataKey: 'encrypted_test_data_key',
          ultimatePublicKey: ultimatePubKey,
        );

        // Payload must match endpoint: uses deviceSigningPublicKeyHex (empty here)
        const emptyDeviceKey = '';
        final regChallenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload = '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$emptyDeviceKey';
        final regSignature = SigningTestHelper.signWith(regPayload, ultimatePrivKey);
        final deviceKeyAttestation = SigningTestHelper.signWith(emptyDeviceKey, ultimatePrivKey);

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            challenge: regChallenge.challenge,
            proofOfWork: regPow,
            signature: regSignature,
            deviceKeyAttestation: deviceKeyAttestation,
            ultimateSigningPublicKeyHex: testAccount.ultimateSigningPublicKeyHex,
            deviceSigningPublicKeyHex: emptyDeviceKey,
            encryptedDataKey: 'encrypted_data_key',
            label: 'Test Device',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('registerDevice - should reject invalid public subkey format', () async {
        // Use real keypair so PoW signature verification passes
        final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

        final testAccount = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          encryptedDataKey: 'encrypted_test_data_key_2',
          ultimatePublicKey: ultimatePubKey,
        );

        // Payload must match endpoint: uses deviceSigningPublicKeyHex (invalid here)
        const invalidDeviceKey = 'invalid_key_format';
        final regChallenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload = '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$invalidDeviceKey';
        final regSignature = SigningTestHelper.signWith(regPayload, ultimatePrivKey);
        final deviceKeyAttestation = SigningTestHelper.signWith(invalidDeviceKey, ultimatePrivKey);

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            challenge: regChallenge.challenge,
            proofOfWork: regPow,
            signature: regSignature,
            deviceKeyAttestation: deviceKeyAttestation,
            ultimateSigningPublicKeyHex: testAccount.ultimateSigningPublicKeyHex,
            deviceSigningPublicKeyHex: invalidDeviceKey,
            encryptedDataKey: 'encrypted_data_key',
            label: 'Test Device',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });
    });

    group('Device Management Session-Auth Edge Cases', () {
      test('revokeDevice - should fail with invalid PoW credentials', () async {
        // DeviceManagementEndpoint requires PoW + ECDSA signature verification.
        expect(
          () => endpoints.deviceManagement.revokeDevice(
            sessionBuilder,
            challenge: 'invalid',
            proofOfWork: 'invalid',
            publicKeyHex: 'invalid',
            signature: 'invalid',
            deviceId: UuidValue.fromString('a1b2c3d4-e5f6-4a7b-8c9d-e0f1a2b3c4d5'),
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('registerDeviceForAccount - should fail with invalid PoW',
          () async {
        expect(
          () => endpoints.deviceManagement.registerDeviceForAccount(
            sessionBuilder,
            challenge: 'invalid',
            proofOfWork: 'invalid',
            publicKeyHex: 'invalid',
            signature: 'invalid',
            newDeviceSigningPublicKeyHex: 'device_pub_key_hex',
            newDeviceEncryptedDataKey: 'encrypted_data_key',
            label: 'Test Device',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });
    });

    group('Device Revocation Edge Cases', () {
      test('revokeDevice - should fail with invalid PoW', () async {
        expect(
          () => endpoints.deviceManagement.revokeDevice(
            sessionBuilder,
            challenge: 'invalid',
            proofOfWork: 'invalid',
            publicKeyHex: 'invalid',
            signature: 'invalid',
            deviceId: UuidValue.fromString('b2c3d4e5-f6a7-4b8c-9d0e-f1a2b3c4d5e6'),
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('revokeDevice - should fail with invalid device ID', () async {
        expect(
          () => endpoints.deviceManagement.revokeDevice(
            sessionBuilder,
            challenge: 'invalid',
            proofOfWork: 'invalid',
            publicKeyHex: 'invalid',
            signature: 'invalid',
            deviceId: UuidValue.fromString('c3d4e5f6-a7b8-4c9d-ae0f-1a2b3c4d5e6f'),
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });
    });

    group('Device Listing Edge Cases', () {
      test('listDevices - should fail with invalid PoW', () async {
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
  });
}
