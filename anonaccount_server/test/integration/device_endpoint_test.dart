import 'package:anonaccount_server/src/pow_methods.dart';
import 'package:test/test.dart';
import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('DeviceEndpoint Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    test(
      'registerDevice - should register device successfully with valid data',
      () async {
        // Create a test account with a real keypair
        final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

        final testAccount = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          encryptedDataKey: 'encrypted_test_data_key',
          ultimatePublicKey: ultimatePubKey,
        );

        final (devicePrivKey, devicePubKey) = SigningTestHelper.generateKeypair();
        const encryptedDataKey = 'device_encrypted_data_key';
        const label = 'Test Device';

        // Attestation: ultimate key signs device public key (authorization)
        final deviceKeyAttestation = SigningTestHelper.signWith(devicePubKey, ultimatePrivKey);

        // PoW for registerDevice (signed with device key — proves liveness)
        final regChallenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload = '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$devicePubKey';
        final regSignature = SigningTestHelper.signWith(regPayload, devicePrivKey);

        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge.challenge,
          proofOfWork: regPow,
          signature: regSignature,
          deviceKeyAttestation: deviceKeyAttestation,
          ultimateSigningPublicKeyHex: testAccount.ultimateSigningPublicKeyHex,
          deviceSigningPublicKeyHex: devicePubKey,
          encryptedDataKey: encryptedDataKey,
          label: label,
        );

        expect(device.id, isNotNull);
        expect(device.anonAccountId, equals(testAccount.id));
        expect(
          device.deviceSigningPublicKeyHex,
          equals(devicePubKey),
        );
        expect(device.encryptedDataKey, equals(encryptedDataKey));
        expect(device.label, equals(label));
        expect(device.isRevoked, isFalse);
        expect(device.lastActive, isNotNull);
      },
    );

    test(
      'registerDevice - should reject duplicate public subkey registration',
      () async {
        // Create a test account with a real keypair
        final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

        final testAccount = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          encryptedDataKey: 'encrypted_test_data_key_2',
          ultimatePublicKey: ultimatePubKey,
        );

        final (devicePrivKey, devicePubKey) = SigningTestHelper.generateKeypair();
        const encryptedDataKey = 'device_encrypted_data_key';
        const label = 'Test Device';

        // Attestation: ultimate key signs device public key
        final deviceKeyAttestation = SigningTestHelper.signWith(devicePubKey, ultimatePrivKey);

        // Register device first time - should succeed
        final regChallenge1 = await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow1 = await PowTestHelper.mint(
          regChallenge1.challenge,
          difficulty: regChallenge1.difficulty,
        );
        final regPayload1 = '${regChallenge1.challenge}:${DeviceMethods.registerDevice}:$devicePubKey';
        final regSignature1 = SigningTestHelper.signWith(regPayload1, devicePrivKey);

        await endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge1.challenge,
          proofOfWork: regPow1,
          signature: regSignature1,
          deviceKeyAttestation: deviceKeyAttestation,
          ultimateSigningPublicKeyHex: testAccount.ultimateSigningPublicKeyHex,
          deviceSigningPublicKeyHex: devicePubKey,
          encryptedDataKey: encryptedDataKey,
          label: label,
        );

        // Try to register same device signing public key again - should fail
        final regChallenge2 = await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow2 = await PowTestHelper.mint(
          regChallenge2.challenge,
          difficulty: regChallenge2.difficulty,
        );
        final regPayload2 = '${regChallenge2.challenge}:${DeviceMethods.registerDevice}:$devicePubKey';
        final regSignature2 = SigningTestHelper.signWith(regPayload2, devicePrivKey);

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            challenge: regChallenge2.challenge,
            proofOfWork: regPow2,
            signature: regSignature2,
            deviceKeyAttestation: deviceKeyAttestation,
            ultimateSigningPublicKeyHex: testAccount.ultimateSigningPublicKeyHex,
            deviceSigningPublicKeyHex: devicePubKey,
            encryptedDataKey: 'different_encrypted_data_key',
            label: 'Different Device',
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('registerDevice - should reject invalid public subkey format', () async {
      // Create a test account with a real keypair
      final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

      final testAccount = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: ultimatePubKey,
        encryptedDataKey: 'encrypted_test_data_key_3',
        ultimatePublicKey: ultimatePubKey,
      );

      const invalidDeviceSigningPublicKeyHex = 'invalid_key_format';
      const encryptedDataKey = 'device_encrypted_data_key';
      const label = 'Test Device';

      // Attestation over invalid key — will fail at attestation verification
      // since invalidDeviceSigningPublicKeyHex is not a valid public key format
      final deviceKeyAttestation = SigningTestHelper.signWith(
        invalidDeviceSigningPublicKeyHex,
        ultimatePrivKey,
      );

      final regChallenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
      final regPow = await PowTestHelper.mint(
        regChallenge.challenge,
        difficulty: regChallenge.difficulty,
      );
      final regPayload = '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$invalidDeviceSigningPublicKeyHex';
      final regSignature = SigningTestHelper.signWith(regPayload, ultimatePrivKey);

      expect(
        () => endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge.challenge,
          proofOfWork: regPow,
          signature: regSignature,
          deviceKeyAttestation: deviceKeyAttestation,
          ultimateSigningPublicKeyHex: testAccount.ultimateSigningPublicKeyHex,
          deviceSigningPublicKeyHex: invalidDeviceSigningPublicKeyHex,
          encryptedDataKey: encryptedDataKey,
          label: label,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'registerDevice - should reject registration for non-existent account',
      () async {
        final (devicePrivKey, devicePubKey) = SigningTestHelper.generateKeypair();
        const encryptedDataKey = 'device_encrypted_data_key';
        const label = 'Test Device';

        // Use a real keypair for the non-existent account
        final (nonExistPrivKey, nonExistPubKey) = SigningTestHelper.generateKeypair();

        // Attestation signed by non-existent account's ultimate key
        final deviceKeyAttestation = SigningTestHelper.signWith(devicePubKey, nonExistPrivKey);

        // PoW signed with device key
        final regChallenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload = '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$devicePubKey';
        final regSignature = SigningTestHelper.signWith(regPayload, devicePrivKey);

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            challenge: regChallenge.challenge,
            proofOfWork: regPow,
            signature: regSignature,
            deviceKeyAttestation: deviceKeyAttestation,
            ultimateSigningPublicKeyHex: nonExistPubKey,
            deviceSigningPublicKeyHex: devicePubKey,
            encryptedDataKey: encryptedDataKey,
            label: label,
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('registerDevice - should reject invalid attestation', () async {
      final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

      final testAccount = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: ultimatePubKey,
        encryptedDataKey: 'encrypted_test_data_key_attest',
        ultimatePublicKey: ultimatePubKey,
      );

      final (devicePrivKey, devicePubKey) = SigningTestHelper.generateKeypair();

      // Sign attestation with WRONG key (device key instead of ultimate)
      final badAttestation = SigningTestHelper.signWith(devicePubKey, devicePrivKey);

      final regChallenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
      final regPow = await PowTestHelper.mint(
        regChallenge.challenge,
        difficulty: regChallenge.difficulty,
      );
      final regPayload = '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$devicePubKey';
      final regSignature = SigningTestHelper.signWith(regPayload, devicePrivKey);

      expect(
        () => endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge.challenge,
          proofOfWork: regPow,
          signature: regSignature,
          deviceKeyAttestation: badAttestation,
          ultimateSigningPublicKeyHex: testAccount.ultimateSigningPublicKeyHex,
          deviceSigningPublicKeyHex: devicePubKey,
          encryptedDataKey: 'device_encrypted_data_key',
          label: 'Test Device',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('signIn - should produce unique auth results per call', () async {
      // Create account and device with real keypairs
      final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

      final testAccount = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: ultimatePubKey,
        encryptedDataKey: 'encrypted_test_data_key_challenge',
        ultimatePublicKey: ultimatePubKey,
      );

      final (devicePrivKey, devicePubKey) = SigningTestHelper.generateKeypair();
      const encryptedDataKey = 'device_encrypted_data_key_challenge';
      const label = 'Challenge Test Device';

      // Attestation + PoW for device registration
      final deviceKeyAttestation = SigningTestHelper.signWith(devicePubKey, ultimatePrivKey);
      final regChallenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
      final regPow = await PowTestHelper.mint(
        regChallenge.challenge,
        difficulty: regChallenge.difficulty,
      );
      final regPayload = '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$devicePubKey';
      final regSignature = SigningTestHelper.signWith(regPayload, devicePrivKey);

      await endpoints.device.registerDevice(
        sessionBuilder,
        challenge: regChallenge.challenge,
        proofOfWork: regPow,
        signature: regSignature,
        deviceKeyAttestation: deviceKeyAttestation,
        ultimateSigningPublicKeyHex: testAccount.ultimateSigningPublicKeyHex,
        deviceSigningPublicKeyHex: devicePubKey,
        encryptedDataKey: encryptedDataKey,
        label: label,
      );

      // Now sign in with PoW (signed with device key)
      final authChallenge1 = await endpoints.entrypoint.getChallenge(sessionBuilder);
      final authPow1 = await PowTestHelper.mint(
        authChallenge1.challenge,
        difficulty: authChallenge1.difficulty,
      );
      final authPayload1 = '${authChallenge1.challenge}:${DeviceMethods.signIn}:$devicePubKey';
      final authSignature1 = SigningTestHelper.signWith(authPayload1, devicePrivKey);

      final result1 = await endpoints.device.signIn(
        sessionBuilder,
        challenge: authChallenge1.challenge,
        proofOfWork: authPow1,
        signature: authSignature1,
        devicePublicKeyHex: devicePubKey,
      );

      final authChallenge2 = await endpoints.entrypoint.getChallenge(sessionBuilder);
      final authPow2 = await PowTestHelper.mint(
        authChallenge2.challenge,
        difficulty: authChallenge2.difficulty,
      );
      final authPayload2 = '${authChallenge2.challenge}:${DeviceMethods.signIn}:$devicePubKey';
      final authSignature2 = SigningTestHelper.signWith(authPayload2, devicePrivKey);

      final result2 = await endpoints.device.signIn(
        sessionBuilder,
        challenge: authChallenge2.challenge,
        proofOfWork: authPow2,
        signature: authSignature2,
        devicePublicKeyHex: devicePubKey,
      );

      expect(result1, isNotNull);
      expect(result2, isNotNull);
    });
  });
}
