
import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('Complete Workflow Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    group('Account Creation → Device Registration → Authentication Flow', () {
      test('complete happy path workflow with real ECDSA P-256 signatures',
          () async {
        // Step 1: Generate keypair for account
        final (privKey, pubKey) = SigningTestHelper.generateKeypair();

        // Step 2: Create account via PoW-protected endpoint
        const encryptedDataKey = 'encrypted_account_data_key_12345';
        const ultimatePublicKey =
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

        final challengeResponse =
            await endpoints.entrypoint.getChallenge(sessionBuilder);
        final proofOfWork = await PowTestHelper.mint(
          challengeResponse.challenge,
          difficulty: challengeResponse.difficulty,
        );
        final payload =
            '${challengeResponse.challenge}:${AccountMethods.createAccount}:$pubKey';
        final signature = SigningTestHelper.signWith(payload, privKey);

        final accountResponse = await endpoints.account.createAccount(
          sessionBuilder,
          challenge: challengeResponse.challenge,
          proofOfWork: proofOfWork,
          signature: signature,
          publicKeyHex: pubKey,
          ultimateSigningPublicKeyHex: pubKey,
          encryptedDataKey: encryptedDataKey,
          ultimatePublicKey: ultimatePublicKey,
        );

        expect(
          accountResponse.ultimateSigningPublicKeyHex,
          equals(pubKey),
        );
        expect(accountResponse.encryptedDataKey, equals(encryptedDataKey));

        // Step 3: Look up account via query service
        final session =
            (sessionBuilder as InternalTestSessionBuilder).internalBuild(
          endpoint: 'test',
          method: 'getAccountByPublicKey',
        );
        AnonAccount? account;
        try {
          account = await AccountQueryService.getAccountByPublicKey(
            session,
            pubKey,
          );
        } finally {
          await session.close();
        }

        expect(account, isNotNull);
        expect(account!.id, isNotNull);

        // Step 4: Generate device keypair and register with PoW
        final (devicePrivKey, devicePubKey) = SigningTestHelper.generateKeypair();
        const deviceEncryptedDataKey = 'encrypted_device_data_key_67890';
        const deviceLabel = 'Test Device for Complete Workflow';

        final regChallenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload = '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$devicePubKey';
        final regSignature = SigningTestHelper.signWith(regPayload, devicePrivKey);
        final deviceKeyAttestation = SigningTestHelper.signWith(devicePubKey, privKey);

        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge.challenge,
          proofOfWork: regPow,
          signature: regSignature,
          deviceKeyAttestation: deviceKeyAttestation,
          ultimateSigningPublicKeyHex: account.ultimateSigningPublicKeyHex,
          deviceSigningPublicKeyHex: devicePubKey,
          encryptedDataKey: deviceEncryptedDataKey,
          label: deviceLabel,
        );

        expect(device.id, isNotNull);
        expect(device.anonAccountId, equals(account.id));
        expect(device.deviceSigningPublicKeyHex, equals(devicePubKey));
        expect(device.isRevoked, isFalse);

        // Step 5: Test sign-in for device auth (PoW-protected)
        final authChallenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
        final authPow = await PowTestHelper.mint(
          authChallenge.challenge,
          difficulty: authChallenge.difficulty,
        );
        final authPayload = '${authChallenge.challenge}:${DeviceMethods.signIn}:$devicePubKey';
        final authSignature = SigningTestHelper.signWith(authPayload, devicePrivKey);

        final authResult = await endpoints.device.signIn(
          sessionBuilder,
          challenge: authChallenge.challenge,
          proofOfWork: authPow,
          signature: authSignature,
          devicePublicKeyHex: devicePubKey,
        );
        expect(authResult, isNotNull);

        // Step 6: Protected endpoints require valid SignedPoW credentials
        // DeviceManagementEndpoint requires PoW + ECDSA signature verification.
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

      test('account lookup workflow', () async {
        // Create account via direct DB insert
        final (_, pubKey) = SigningTestHelper.generateKeypair();
        const encryptedDataKey = 'encrypted_account_data_key_lookup';
        const ultimatePublicKey =
            'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
            'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';

        final account = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: pubKey,
          encryptedDataKey: encryptedDataKey,
          ultimatePublicKey: ultimatePublicKey,
        );

        expect(account.id, isNotNull);

        // Look up via query service
        final session =
            (sessionBuilder as InternalTestSessionBuilder).internalBuild(
          endpoint: 'test',
          method: 'getAccountByPublicKey',
        );
        try {
          final found = await AccountQueryService.getAccountByPublicKey(
            session,
            pubKey,
          );
          expect(found, isNotNull);
          expect(found!.id, equals(account.id));

          // Non-existent key returns null
          const nonExistent =
              'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc'
              'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc';
          final notFound = await AccountQueryService.getAccountByPublicKey(
            session,
            nonExistent,
          );
          expect(notFound, isNull);
        } finally {
          await session.close();
        }
      });

      test('authentication failure scenarios', () async {
        // DeviceManagementEndpoint requires valid SignedPoW credentials.
        // Invalid PoW/signature should cause AuthenticationException.
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

        expect(
          () => endpoints.deviceManagement.revokeDevice(
            sessionBuilder,
            challenge: 'invalid',
            proofOfWork: 'invalid',
            publicKeyHex: 'invalid',
            signature: 'invalid',
            deviceId: 123,
          ),
          throwsA(isA<AuthenticationException>()),
        );

        // authenticateDevice was removed — signIn is now on DeviceEndpoint (PoW-protected, not session-auth).
        // Verify revokeDevice still rejects invalid credentials.
        expect(
          () => endpoints.deviceManagement.revokeDevice(
            sessionBuilder,
            challenge: 'invalid',
            proofOfWork: 'invalid',
            publicKeyHex: 'invalid',
            signature: 'invalid',
            deviceId: 123,
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('device registration succeeds with valid data', () async {
        final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

        await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
        );

        final (devicePrivKey, devicePubKey) = SigningTestHelper.generateKeypair();

        final regChallenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload = '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$devicePubKey';
        final regSignature = SigningTestHelper.signWith(regPayload, devicePrivKey);
        final deviceKeyAttestation = SigningTestHelper.signWith(devicePubKey, ultimatePrivKey);

        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge.challenge,
          proofOfWork: regPow,
          signature: regSignature,
          deviceKeyAttestation: deviceKeyAttestation,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          deviceSigningPublicKeyHex: devicePubKey,
          encryptedDataKey: 'encrypted_device_data_key',
          label: 'Test Device',
        );

        expect(device.id, isNotNull);
        expect(device.isRevoked, isFalse);
      });

      test('duplicate device registration fails', () async {
        final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

        await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
        );

        final (devicePrivKey, devicePubKey) = SigningTestHelper.generateKeypair();

        // Register first
        final regChallenge1 = await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow1 = await PowTestHelper.mint(
          regChallenge1.challenge,
          difficulty: regChallenge1.difficulty,
        );
        final regPayload1 = '${regChallenge1.challenge}:${DeviceMethods.registerDevice}:$devicePubKey';
        final regSignature1 = SigningTestHelper.signWith(regPayload1, devicePrivKey);
        final deviceKeyAttestation1 = SigningTestHelper.signWith(devicePubKey, ultimatePrivKey);

        await endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge1.challenge,
          proofOfWork: regPow1,
          signature: regSignature1,
          deviceKeyAttestation: deviceKeyAttestation1,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          deviceSigningPublicKeyHex: devicePubKey,
          encryptedDataKey: 'encrypted_device_data_key',
          label: 'Test Device',
        );

        // Duplicate should fail
        final regChallenge2 = await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow2 = await PowTestHelper.mint(
          regChallenge2.challenge,
          difficulty: regChallenge2.difficulty,
        );
        final regPayload2 = '${regChallenge2.challenge}:${DeviceMethods.registerDevice}:$devicePubKey';
        final regSignature2 = SigningTestHelper.signWith(regPayload2, devicePrivKey);
        final deviceKeyAttestation2 = SigningTestHelper.signWith(devicePubKey, ultimatePrivKey);

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            challenge: regChallenge2.challenge,
            proofOfWork: regPow2,
            signature: regSignature2,
            deviceKeyAttestation: deviceKeyAttestation2,
            ultimateSigningPublicKeyHex: ultimatePubKey,
            deviceSigningPublicKeyHex: devicePubKey,
            encryptedDataKey: 'encrypted_device_data_key_2',
            label: 'Test Device 2',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('non-existent account registration fails', () async {
        final (nonExistPrivKey, nonExistPubKey) = SigningTestHelper.generateKeypair();
        final (devicePrivKey, devicePubKey) = SigningTestHelper.generateKeypair();

        final regChallenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload = '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$devicePubKey';
        final regSignature = SigningTestHelper.signWith(regPayload, devicePrivKey);
        final deviceKeyAttestation = SigningTestHelper.signWith(devicePubKey, nonExistPrivKey);

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            challenge: regChallenge.challenge,
            proofOfWork: regPow,
            signature: regSignature,
            deviceKeyAttestation: deviceKeyAttestation,
            ultimateSigningPublicKeyHex: nonExistPubKey,
            deviceSigningPublicKeyHex: devicePubKey,
            encryptedDataKey: 'encrypted_device_data_key',
            label: 'Test Device',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });
    });
  });
}
