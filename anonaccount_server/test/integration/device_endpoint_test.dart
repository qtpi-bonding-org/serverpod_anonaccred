import 'package:test/test.dart';
import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('DeviceEndpoint Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    test(
      'registerDevice - should register device successfully with valid data',
      () async {
        // Create a test account with a real keypair (for PoW signing)
        final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

        final testAccount = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          encryptedDataKey: 'encrypted_test_data_key',
          ultimatePublicKey: ultimatePubKey,
        );

        final (_, devicePubKey) = SigningTestHelper.generateKeypair();
        const encryptedDataKey = 'device_encrypted_data_key';
        const label = 'Test Device';

        // PoW for registerDevice (signed with ultimate key)
        final regChallenge = await endpoints.device.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload = '${regChallenge.challenge}:registerDevice:$ultimatePubKey';
        final regSignature = SigningTestHelper.signWith(regPayload, ultimatePrivKey);

        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge.challenge,
          proofOfWork: regPow,
          signature: regSignature,
          ultimateSigningPublicKeyHex: testAccount.ultimateSigningPublicKeyHex,
          deviceSigningPublicKeyHex: devicePubKey,
          encryptedDataKey: encryptedDataKey,
          label: label,
        );

        expect(device.id, isNotNull);
        expect(device.accountId, equals(testAccount.id));
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

        final (_, devicePubKey) = SigningTestHelper.generateKeypair();
        const encryptedDataKey = 'device_encrypted_data_key';
        const label = 'Test Device';

        // Register device first time - should succeed
        final regChallenge1 = await endpoints.device.getChallenge(sessionBuilder);
        final regPow1 = await PowTestHelper.mint(
          regChallenge1.challenge,
          difficulty: regChallenge1.difficulty,
        );
        final regPayload1 = '${regChallenge1.challenge}:registerDevice:$ultimatePubKey';
        final regSignature1 = SigningTestHelper.signWith(regPayload1, ultimatePrivKey);

        await endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge1.challenge,
          proofOfWork: regPow1,
          signature: regSignature1,
          ultimateSigningPublicKeyHex: testAccount.ultimateSigningPublicKeyHex,
          deviceSigningPublicKeyHex: devicePubKey,
          encryptedDataKey: encryptedDataKey,
          label: label,
        );

        // Try to register same device signing public key again - should fail
        final regChallenge2 = await endpoints.device.getChallenge(sessionBuilder);
        final regPow2 = await PowTestHelper.mint(
          regChallenge2.challenge,
          difficulty: regChallenge2.difficulty,
        );
        final regPayload2 = '${regChallenge2.challenge}:registerDevice:$ultimatePubKey';
        final regSignature2 = SigningTestHelper.signWith(regPayload2, ultimatePrivKey);

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            challenge: regChallenge2.challenge,
            proofOfWork: regPow2,
            signature: regSignature2,
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

      // PoW for registerDevice (signed with ultimate key)
      final regChallenge = await endpoints.device.getChallenge(sessionBuilder);
      final regPow = await PowTestHelper.mint(
        regChallenge.challenge,
        difficulty: regChallenge.difficulty,
      );
      final regPayload = '${regChallenge.challenge}:registerDevice:$ultimatePubKey';
      final regSignature = SigningTestHelper.signWith(regPayload, ultimatePrivKey);

      expect(
        () => endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge.challenge,
          proofOfWork: regPow,
          signature: regSignature,
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
        final (_, devicePubKey) = SigningTestHelper.generateKeypair();
        const encryptedDataKey = 'device_encrypted_data_key';
        const label = 'Test Device';

        // Use a real keypair for the non-existent account (so PoW passes)
        final (nonExistPrivKey, nonExistPubKey) = SigningTestHelper.generateKeypair();

        final regChallenge = await endpoints.device.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload = '${regChallenge.challenge}:registerDevice:$nonExistPubKey';
        final regSignature = SigningTestHelper.signWith(regPayload, nonExistPrivKey);

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            challenge: regChallenge.challenge,
            proofOfWork: regPow,
            signature: regSignature,
            ultimateSigningPublicKeyHex: nonExistPubKey,
            deviceSigningPublicKeyHex: devicePubKey,
            encryptedDataKey: encryptedDataKey,
            label: label,
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('generateAuthChallenge - should generate unique challenges', () async {
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

      // Register the device with PoW
      final regChallenge = await endpoints.device.getChallenge(sessionBuilder);
      final regPow = await PowTestHelper.mint(
        regChallenge.challenge,
        difficulty: regChallenge.difficulty,
      );
      final regPayload = '${regChallenge.challenge}:registerDevice:$ultimatePubKey';
      final regSignature = SigningTestHelper.signWith(regPayload, ultimatePrivKey);

      await endpoints.device.registerDevice(
        sessionBuilder,
        challenge: regChallenge.challenge,
        proofOfWork: regPow,
        signature: regSignature,
        ultimateSigningPublicKeyHex: testAccount.ultimateSigningPublicKeyHex,
        deviceSigningPublicKeyHex: devicePubKey,
        encryptedDataKey: encryptedDataKey,
        label: label,
      );

      // Now generate challenges with PoW (signed with device key)
      final authChallenge1 = await endpoints.device.getChallenge(sessionBuilder);
      final authPow1 = await PowTestHelper.mint(
        authChallenge1.challenge,
        difficulty: authChallenge1.difficulty,
      );
      final authPayload1 = '${authChallenge1.challenge}:generateAuthChallenge:$devicePubKey';
      final authSignature1 = SigningTestHelper.signWith(authPayload1, devicePrivKey);

      final challenge1 = await endpoints.device.generateAuthChallenge(
        sessionBuilder,
        challenge: authChallenge1.challenge,
        proofOfWork: authPow1,
        signature: authSignature1,
        devicePublicKey: devicePubKey,
      );

      final authChallenge2 = await endpoints.device.getChallenge(sessionBuilder);
      final authPow2 = await PowTestHelper.mint(
        authChallenge2.challenge,
        difficulty: authChallenge2.difficulty,
      );
      final authPayload2 = '${authChallenge2.challenge}:generateAuthChallenge:$devicePubKey';
      final authSignature2 = SigningTestHelper.signWith(authPayload2, devicePrivKey);

      final challenge2 = await endpoints.device.generateAuthChallenge(
        sessionBuilder,
        challenge: authChallenge2.challenge,
        proofOfWork: authPow2,
        signature: authSignature2,
        devicePublicKey: devicePubKey,
      );

      expect(challenge1, isNotEmpty);
      expect(challenge2, isNotEmpty);
      expect(challenge1, isNot(equals(challenge2)));
    });
  });
}
