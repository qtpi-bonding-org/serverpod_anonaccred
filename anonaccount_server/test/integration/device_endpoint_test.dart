import 'package:anonaccount_server/src/generated/protocol.dart';
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
          ultimateEncryptionPublicKeyHex: ultimatePubKey,
        );

        final (devicePrivKey, devicePubKey) = SigningTestHelper.generateKeypair();
        final (_, deviceEncPubKey) = SigningTestHelper.generateKeypair();
        const encryptedDataKey = 'device_encrypted_data_key';
        const label = 'Test Device';

        // Attestation covers BOTH halves of the device duo (Task 8).
        final deviceKeyAttestation = SigningTestHelper.signWith(
          AccountInnerPayloads.registerDevice(
            PublicKeyDuo(
              signingPublicKeyHex: devicePubKey,
              encryptionPublicKeyHex: deviceEncPubKey,
            ),
          ),
          ultimatePrivKey,
        );

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
          deviceKeys: PublicKeyDuo(
            signingPublicKeyHex: devicePubKey,
            encryptionPublicKeyHex: deviceEncPubKey,
          ),
          encryptedDataKey: encryptedDataKey,
          label: label,
        );

        expect(device.id, isNotNull);
        expect(device.anonAccountId, equals(testAccount.id));
        expect(
          device.deviceSigningPublicKeyHex,
          equals(devicePubKey),
        );
        expect(device.label, equals(label));
        expect(device.isRevoked, isFalse);
        expect(device.lastActive, isNotNull);
      },
    );

    test(
      'registerDevice persists the encryption key and its attestation',
      () async {
        // Build a fresh account + device pair so this test does not depend on
        // the order it runs in within the withServerpod group.
        final (ultimatePrivKey, ultimatePubKey) =
            SigningTestHelper.generateKeypair();
        final testAccount = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          encryptedDataKey: 'encrypted_test_data_key_roundtrip',
          ultimateEncryptionPublicKeyHex: ultimatePubKey,
        );

        final (devicePrivKey, devicePubKey) =
            SigningTestHelper.generateKeypair();
        final (_, deviceEncPubKey) = SigningTestHelper.generateKeypair();
        const encryptedDataKey = 'device_encrypted_data_key_roundtrip';
        const label = 'Roundtrip Test Device';

        // Attestation covers BOTH halves of the device duo (Task 8).
        final deviceKeyAttestation = SigningTestHelper.signWith(
          AccountInnerPayloads.registerDevice(
            PublicKeyDuo(
              signingPublicKeyHex: devicePubKey,
              encryptionPublicKeyHex: deviceEncPubKey,
            ),
          ),
          ultimatePrivKey,
        );

        final regChallenge =
            await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload =
            '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$devicePubKey';
        final regSignature = SigningTestHelper.signWith(regPayload, devicePrivKey);

        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge.challenge,
          proofOfWork: regPow,
          signature: regSignature,
          deviceKeyAttestation: deviceKeyAttestation,
          ultimateSigningPublicKeyHex: testAccount.ultimateSigningPublicKeyHex,
          deviceKeys: PublicKeyDuo(
            signingPublicKeyHex: devicePubKey,
            encryptionPublicKeyHex: deviceEncPubKey,
          ),
          encryptedDataKey: encryptedDataKey,
          label: label,
        );

        expect(device.deviceEncryptionPublicKeyHex, hasLength(130));
        expect(device.addedByAttestation, isNotEmpty);
        expect(device.addedBySignerPublicKeyHex, ultimatePubKey);
        expect(device.createdAt, isNotNull);
        expect(device.revokedAt, isNull);
      },
    );

    test(
      'rejects an attestation that covers a different encryption key',
      () async {
        final (ultimatePrivKey, ultimatePubKey) =
            SigningTestHelper.generateKeypair();
        final testAccount = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          encryptedDataKey: 'encrypted_test_data_key_mismatch',
          ultimateEncryptionPublicKeyHex: ultimatePubKey,
        );

        final (devicePrivKey, devicePubKey) =
            SigningTestHelper.generateKeypair();
        final (_, deviceEncPubKey) = SigningTestHelper.generateKeypair();
        // Attestation computed over the real duo...
        final deviceKeyAttestation = SigningTestHelper.signWith(
          AccountInnerPayloads.registerDevice(
            PublicKeyDuo(
              signingPublicKeyHex: devicePubKey,
              encryptionPublicKeyHex: deviceEncPubKey,
            ),
          ),
          ultimatePrivKey,
        );
        // ...but a THIRD key is sent as the encryption half in the request.
        final (_, substitutedEncPubKey) = SigningTestHelper.generateKeypair();

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

        await expectLater(
          endpoints.device.registerDevice(
            sessionBuilder,
            challenge: regChallenge.challenge,
            proofOfWork: regPow,
            signature: regSignature,
            deviceKeyAttestation: deviceKeyAttestation,
            ultimateSigningPublicKeyHex:
                testAccount.ultimateSigningPublicKeyHex,
            deviceKeys: PublicKeyDuo(
              signingPublicKeyHex: devicePubKey,
              encryptionPublicKeyHex: substitutedEncPubKey,
            ),
            encryptedDataKey: 'device_encrypted_data_key_mismatch',
            label: 'Mismatch Test Device',
          ),
          throwsA(isA<AuthenticationException>()),
        );
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
          ultimateEncryptionPublicKeyHex: ultimatePubKey,
        );

        final (devicePrivKey, devicePubKey) = SigningTestHelper.generateKeypair();
        final (_, deviceEncPubKey) = SigningTestHelper.generateKeypair();
        const encryptedDataKey = 'device_encrypted_data_key';
        const label = 'Test Device';

        // Attestation: ultimate key signs device public key
        final deviceKeyAttestation = SigningTestHelper.signWith(
        AccountInnerPayloads.registerDevice(
          PublicKeyDuo(
            signingPublicKeyHex: devicePubKey,
            encryptionPublicKeyHex: deviceEncPubKey,
          ),
        ),
        ultimatePrivKey,
      );

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
          deviceKeys: PublicKeyDuo(
            signingPublicKeyHex: devicePubKey,
            encryptionPublicKeyHex: deviceEncPubKey,
          ),
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
            deviceKeys: PublicKeyDuo(
              signingPublicKeyHex: devicePubKey,
              encryptionPublicKeyHex: deviceEncPubKey,
            ),
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
        ultimateEncryptionPublicKeyHex: ultimatePubKey,
      );

      const invalidDeviceSigningPublicKeyHex = 'invalid_key_format';
      const invalidDeviceEncryptionPublicKeyHex = 'invalid_key_format';
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
          deviceKeys: PublicKeyDuo(
            signingPublicKeyHex: invalidDeviceSigningPublicKeyHex,
            encryptionPublicKeyHex: invalidDeviceEncryptionPublicKeyHex,
          ),
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
        final (_, deviceEncPubKey) = SigningTestHelper.generateKeypair();
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
            deviceKeys: PublicKeyDuo(
              signingPublicKeyHex: devicePubKey,
              encryptionPublicKeyHex: deviceEncPubKey,
            ),
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
        ultimateEncryptionPublicKeyHex: ultimatePubKey,
      );

      final (devicePrivKey, devicePubKey) = SigningTestHelper.generateKeypair();
      final (_, deviceEncPubKey) = SigningTestHelper.generateKeypair();

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
          deviceKeys: PublicKeyDuo(
            signingPublicKeyHex: devicePubKey,
            encryptionPublicKeyHex: deviceEncPubKey,
          ),
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
        ultimateEncryptionPublicKeyHex: ultimatePubKey,
      );

      final (devicePrivKey, devicePubKey) = SigningTestHelper.generateKeypair();
      final (_, deviceEncPubKey) = SigningTestHelper.generateKeypair();
      const encryptedDataKey = 'device_encrypted_data_key_challenge';
      const label = 'Challenge Test Device';

      // Attestation + PoW for device registration
      final deviceKeyAttestation = SigningTestHelper.signWith(
        AccountInnerPayloads.registerDevice(
          PublicKeyDuo(
            signingPublicKeyHex: devicePubKey,
            encryptionPublicKeyHex: deviceEncPubKey,
          ),
        ),
        ultimatePrivKey,
      );
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
        deviceKeys: PublicKeyDuo(
          signingPublicKeyHex: devicePubKey,
          encryptionPublicKeyHex: deviceEncPubKey,
        ),
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