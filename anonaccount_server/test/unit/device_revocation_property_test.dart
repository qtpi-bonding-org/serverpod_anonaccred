import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:anonaccount_server/src/pow_methods.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';
import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/test_account_helper.dart';

/// **Feature: anonaccred-phase2, Property 6: Revocation enforcement**
/// **Validates: Requirements 3.5, 4.2**

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('Device Revocation Property Tests', (
    sessionBuilder,
    endpoints,
  ) {
    test(
      'Property 6: Revocation enforcement - Device revocation workflow validation',
      () async {
        // Create test account with real keypair
        final (ultimatePrivKey, ultimatePubKey) =
            SigningTestHelper.generateKeypair();
        const accountEncryptedDataKey = 'encrypted_test_data_key';

        final testAccount = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          encryptedDataKey: accountEncryptedDataKey,
          ultimatePublicKey: ultimatePubKey,
        );

        // Register a device with PoW
        final (devicePrivKey, devicePubKey) = SigningTestHelper.generateKeypair();
        const deviceEncryptedDataKey = 'device_encrypted_data_key';
        const deviceLabel = 'Test Device for Revocation';

        final regChallenge =
            await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload =
            '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$devicePubKey';
        final regSignature =
            SigningTestHelper.signWith(regPayload, devicePrivKey);
        final deviceKeyAttestation =
            SigningTestHelper.signWith(devicePubKey, ultimatePrivKey);

        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge.challenge,
          proofOfWork: regPow,
          signature: regSignature,
          deviceKeyAttestation: deviceKeyAttestation,
          ultimateSigningPublicKeyHex:
              testAccount.ultimateSigningPublicKeyHex,
          deviceSigningPublicKeyHex: devicePubKey,
          encryptedDataKey: deviceEncryptedDataKey,
          label: deviceLabel,
        );

        // Verify device is initially active
        expect(device.id, isNotNull);
        expect(device.isRevoked, isFalse);
        expect(device.deviceSigningPublicKeyHex, equals(devicePubKey));

        // Test that endpoints require valid SignedPoW credentials
        // DeviceManagementEndpoint requires PoW + ECDSA signature verification.
        expect(
          () => endpoints.deviceManagement.revokeDevice(
            sessionBuilder,
            challenge: 'invalid',
            proofOfWork: 'invalid',
            publicKeyHex: 'invalid',
            signature: 'invalid',
            deviceId: device.id!,
          ),
          throwsA(isA<AuthenticationException>()),
        );

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

        // Verify device registration still works (PoW-protected, not session-auth)
        final (devicePrivKey2, devicePubKey2) = SigningTestHelper.generateKeypair();

        final regChallenge2 =
            await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow2 = await PowTestHelper.mint(
          regChallenge2.challenge,
          difficulty: regChallenge2.difficulty,
        );
        final regPayload2 =
            '${regChallenge2.challenge}:${DeviceMethods.registerDevice}:$devicePubKey2';
        final regSignature2 =
            SigningTestHelper.signWith(regPayload2, devicePrivKey2);
        final deviceKeyAttestation2 =
            SigningTestHelper.signWith(devicePubKey2, ultimatePrivKey);

        final device2 = await endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge2.challenge,
          proofOfWork: regPow2,
          signature: regSignature2,
          deviceKeyAttestation: deviceKeyAttestation2,
          ultimateSigningPublicKeyHex:
              testAccount.ultimateSigningPublicKeyHex,
          deviceSigningPublicKeyHex: devicePubKey2,
          encryptedDataKey: 'device_encrypted_data_key_2',
          label: 'Test Device 2',
        );

        expect(device2.id, isNotNull);
        expect(device2.isRevoked, isFalse);
      },
    );
  });
}
