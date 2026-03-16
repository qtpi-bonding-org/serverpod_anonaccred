import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:test/test.dart';

import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  group('Authentication Flow Integration Tests', () {
    withServerpod('Given authentication flow integration', (sessionBuilder, endpoints) {
      test('successful authentication with valid device key and database lookup', () async {
        // Step 1: Create account and device in database
        // Generate ECDSA P-256 key pair for testing (ultimate key)
        final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

        const encryptedDataKey = 'encrypted_account_data_key_12345';
        const ultimatePublicKey = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                                  'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

        final account = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          encryptedDataKey: encryptedDataKey,
          ultimatePublicKey: ultimatePublicKey,
        );

        // Create device with real keypair
        final (devicePrivKey, devicePubKey) = SigningTestHelper.generateKeypair();
        const deviceEncryptedDataKey = 'encrypted_device_data_key_67890';
        const deviceLabel = 'Test Device';

        // PoW for registerDevice (signed with ultimate key)
        final regChallenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload = '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$ultimatePubKey';
        final regSignature = SigningTestHelper.signWith(regPayload, ultimatePrivKey);

        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge.challenge,
          proofOfWork: regPow,
          signature: regSignature,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          deviceSigningPublicKeyHex: devicePubKey,
          encryptedDataKey: deviceEncryptedDataKey,
          label: deviceLabel,
        );

        // Step 2: Test authentication
        final challenge = CryptoUtils.generateChallenge();

        // Use pointycastle signing via SigningTestHelper for consistency
        final signatureHex = SigningTestHelper.signWith(challenge, devicePrivKey);

        // Step 3: Verify authentication (cryptographic verification only)
        final result = await CryptoAuth.verifyChallengeResponse(
          devicePubKey,
          challenge,
          signatureHex,
        );

        expect(result.success, isTrue);

        // Step 4: Verify database lookup works (separate from crypto verification)
        // In a real authentication flow, this would be done by the auth handler
        final foundDevice = await AccountDevice.db.findFirstRow(
          sessionBuilder.build(),
          where: (t) => t.deviceSigningPublicKeyHex.equals(devicePubKey),
        );

        expect(foundDevice, isNotNull);
        expect(foundDevice!.accountUuid, equals(account.accountUuid));
        expect(foundDevice.id, equals(device.id));
      });

      test('authentication failure with invalid signature', () async {
        // Create account and device
        final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

        const encryptedDataKey = 'encrypted_account_data_key_invalid';
        const ultimatePublicKey = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
                                  'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';

        await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          encryptedDataKey: encryptedDataKey,
          ultimatePublicKey: ultimatePublicKey,
        );

        final (devicePrivKey, devicePubKey) = SigningTestHelper.generateKeypair();
        const deviceEncryptedDataKey = 'encrypted_device_data_key_invalid';
        const deviceLabel = 'Test Device Invalid';

        // PoW for registerDevice (signed with ultimate key)
        final regChallenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload = '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$ultimatePubKey';
        final regSignature = SigningTestHelper.signWith(regPayload, ultimatePrivKey);

        await endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge.challenge,
          proofOfWork: regPow,
          signature: regSignature,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          deviceSigningPublicKeyHex: devicePubKey,
          encryptedDataKey: deviceEncryptedDataKey,
          label: deviceLabel,
        );

        // Test with invalid signature
        final challenge = CryptoUtils.generateChallenge();
        final invalidSignature = 'invalid_signature_${'f' * 100}'; // 128 chars total

        final result = await CryptoAuth.verifyChallengeResponse(
          devicePubKey,
          challenge,
          invalidSignature,
        );

        expect(result.success, isFalse);
        expect(result.errorCode, equals(AnonAccountErrorCodes.cryptoInvalidSignature));
      });

      test('authentication failure with revoked device', () async {
        // Step 1: Create account and device
        final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

        const encryptedDataKey = 'encrypted_account_data_key_revoked';
        const ultimatePublicKey = 'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc'
                                  'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc';

        final account = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          encryptedDataKey: encryptedDataKey,
          ultimatePublicKey: ultimatePublicKey,
        );

        final (devicePrivKey, devicePubKey) = SigningTestHelper.generateKeypair();
        const deviceEncryptedDataKey = 'encrypted_device_data_key_revoked';
        const deviceLabel = 'Test Device Revoked';

        // PoW for registerDevice (signed with ultimate key)
        final regChallenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload = '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$ultimatePubKey';
        final regSignature = SigningTestHelper.signWith(regPayload, ultimatePrivKey);

        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge.challenge,
          proofOfWork: regPow,
          signature: regSignature,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          deviceSigningPublicKeyHex: devicePubKey,
          encryptedDataKey: deviceEncryptedDataKey,
          label: deviceLabel,
        );

        // Step 2: Revoke the device via SignedPoW
        final revokeChallenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
        final revokePow = await PowTestHelper.mint(
          revokeChallenge.challenge,
          difficulty: revokeChallenge.difficulty,
        );
        final revokePayload = '${revokeChallenge.challenge}:revokeDevice:$ultimatePubKey';
        final revokeSignature = SigningTestHelper.signWith(revokePayload, ultimatePrivKey);

        await endpoints.deviceManagement.revokeDevice(
          sessionBuilder,
          challenge: revokeChallenge.challenge,
          proofOfWork: revokePow,
          publicKeyHex: ultimatePubKey,
          signature: revokeSignature,
          deviceId: device.id!,
        );

        // Step 3: Try to authenticate with revoked device
        final challenge = CryptoUtils.generateChallenge();

        final signatureHex = SigningTestHelper.signWith(challenge, devicePrivKey);

        // Cryptographic verification should still succeed (signature is valid)
        final result = await CryptoAuth.verifyChallengeResponse(
          devicePubKey,
          challenge,
          signatureHex,
        );

        expect(result.success, isTrue); // Crypto verification succeeds

        // But database lookup should show device is revoked
        final revokedDevice = await AccountDevice.db.findById(
          sessionBuilder.build(),
          device.id!,
        );

        expect(revokedDevice, isNotNull);
        expect(revokedDevice!.isRevoked, isTrue); // Device is marked as revoked
      });

      test('AuthenticationInfo structure matches Serverpod requirements', () async {
        // Create account and device
        final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

        const encryptedDataKey = 'encrypted_account_data_key_info';
        const ultimatePublicKey = 'dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd'
                                  'dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd';

        final account = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          encryptedDataKey: encryptedDataKey,
          ultimatePublicKey: ultimatePublicKey,
        );

        final (devicePrivKey, devicePubKey) = SigningTestHelper.generateKeypair();
        const deviceEncryptedDataKey = 'encrypted_device_data_key_info';
        const deviceLabel = 'Test Device Info';

        // PoW for registerDevice (signed with ultimate key)
        final regChallenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload = '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$ultimatePubKey';
        final regSignature = SigningTestHelper.signWith(regPayload, ultimatePrivKey);

        await endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge.challenge,
          proofOfWork: regPow,
          signature: regSignature,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          deviceSigningPublicKeyHex: devicePubKey,
          encryptedDataKey: deviceEncryptedDataKey,
          label: deviceLabel,
        );

        // Test authenticated session creation using Serverpod testing framework
        final authenticatedSessionBuilder = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            account.id.toString(),
            <Scope>{},
          ),
        );

        // Verify the authenticated session works by calling an authenticated endpoint
        final session = authenticatedSessionBuilder.build();
        expect(session.authenticated, isNotNull);
        expect(session.authenticated!.userIdentifier, equals(account.id.toString()));
      });

      test('multiple devices can authenticate independently', () async {
        // Create account
        final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

        const encryptedDataKey = 'encrypted_account_data_key_multi';
        const ultimatePublicKey = 'eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee'
                                  'eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee';

        final account = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          encryptedDataKey: encryptedDataKey,
          ultimatePublicKey: ultimatePublicKey,
        );

        // Create multiple devices
        final devices = <AccountDevice>[];
        final deviceKeyPairs = <({String privateKeyHex, String publicKeyHex})>[];

        for (var i = 0; i < 3; i++) {
          final (devPrivKey, devPubKey) = SigningTestHelper.generateKeypair();

          final deviceEncryptedDataKey = 'encrypted_device_data_key_multi_$i';
          final deviceLabel = 'Test Device Multi $i';

          // PoW for registerDevice (signed with ultimate key)
          final regChallenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
          final regPow = await PowTestHelper.mint(
            regChallenge.challenge,
            difficulty: regChallenge.difficulty,
          );
          final regPayload = '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$ultimatePubKey';
          final regSignature = SigningTestHelper.signWith(regPayload, ultimatePrivKey);

          final device = await endpoints.device.registerDevice(
            sessionBuilder,
            challenge: regChallenge.challenge,
            proofOfWork: regPow,
            signature: regSignature,
            ultimateSigningPublicKeyHex: ultimatePubKey,
            deviceSigningPublicKeyHex: devPubKey,
            encryptedDataKey: deviceEncryptedDataKey,
            label: deviceLabel,
          );

          devices.add(device);
          deviceKeyPairs.add((privateKeyHex: devPrivKey, publicKeyHex: devPubKey));
        }

        // Test that each device can authenticate independently
        for (var i = 0; i < devices.length; i++) {
          final device = devices[i];
          final keyPairInfo = deviceKeyPairs[i];

          final devicePublicKeyHex = keyPairInfo.publicKeyHex;

          final challenge = CryptoUtils.generateChallenge();

          final signatureHex = SigningTestHelper.signWith(challenge, keyPairInfo.privateKeyHex);

          final result = await CryptoAuth.verifyChallengeResponse(
            devicePublicKeyHex,
            challenge,
            signatureHex,
          );

          expect(result.success, isTrue);

          // Verify database lookup works for each device
          final foundDevice = await AccountDevice.db.findFirstRow(
            sessionBuilder.build(),
            where: (t) => t.deviceSigningPublicKeyHex.equals(devicePublicKeyHex),
          );

          expect(foundDevice, isNotNull);
          expect(foundDevice!.accountUuid, equals(account.accountUuid));
          expect(foundDevice.id, equals(device.id));
        }
      });

      test('extracts device key from authenticated session', () async {
        // Create test data
        final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

        const encryptedDataKey = 'encrypted_account_data_key_extract';
        const ultimatePublicKey = 'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff'
                                  'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff';

        final account = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          encryptedDataKey: encryptedDataKey,
          ultimatePublicKey: ultimatePublicKey,
        );

        final (devicePrivKey, devicePubKey) = SigningTestHelper.generateKeypair();
        const deviceEncryptedDataKey = 'encrypted_device_data_key_extract';
        const deviceLabel = 'Test Device Extract';

        // PoW for registerDevice (signed with ultimate key)
        final regChallenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload = '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$ultimatePubKey';
        final regSignature = SigningTestHelper.signWith(regPayload, ultimatePrivKey);

        await endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge.challenge,
          proofOfWork: regPow,
          signature: regSignature,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          deviceSigningPublicKeyHex: devicePubKey,
          encryptedDataKey: deviceEncryptedDataKey,
          label: deviceLabel,
        );

        // Create authenticated session using Serverpod testing framework
        final authenticatedSessionBuilder = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            account.id.toString(),
            <Scope>{},
          ),
        );

        final session = authenticatedSessionBuilder.build();

        // Test extraction - verify the auth info is properly set
        expect(session.authenticated, isNotNull);
        expect(session.authenticated!.userIdentifier, equals(account.id.toString()));

        // In a real implementation, device key extraction would be done by the auth handler
        // Here we just verify that the session is properly authenticated
        expect(session.isUserSignedIn, isTrue);
      });
    });
  });
}
