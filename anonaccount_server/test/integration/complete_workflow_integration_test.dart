
import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'test_tools/auth_test_helper.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
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
            await endpoints.account.getChallenge(sessionBuilder);
        final proofOfWork = await PowTestHelper.mint(
          challengeResponse.challenge,
          difficulty: challengeResponse.difficulty,
        );
        final payload =
            '${challengeResponse.challenge}:createAccount:$pubKey';
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

        final regChallenge = await endpoints.device.getChallenge(sessionBuilder);
        final regPow = await PowTestHelper.mint(
          regChallenge.challenge,
          difficulty: regChallenge.difficulty,
        );
        final regPayload = '${regChallenge.challenge}:registerDevice:${account.ultimateSigningPublicKeyHex}';
        final regSignature = SigningTestHelper.signWith(regPayload, privKey);

        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          challenge: regChallenge.challenge,
          proofOfWork: regPow,
          signature: regSignature,
          ultimateSigningPublicKeyHex: account.ultimateSigningPublicKeyHex,
          deviceSigningPublicKeyHex: devicePubKey,
          encryptedDataKey: deviceEncryptedDataKey,
          label: deviceLabel,
        );

        expect(device.id, isNotNull);
        expect(device.accountId, equals(account.id));
        expect(device.deviceSigningPublicKeyHex, equals(devicePubKey));
        expect(device.isRevoked, isFalse);

        // Step 5: Test challenge generation for device auth (PoW-protected)
        final authChallenge = await endpoints.device.getChallenge(sessionBuilder);
        final authPow = await PowTestHelper.mint(
          authChallenge.challenge,
          difficulty: authChallenge.difficulty,
        );
        final authPayload = '${authChallenge.challenge}:generateAuthChallenge:$devicePubKey';
        final authSignature = SigningTestHelper.signWith(authPayload, devicePrivKey);

        final challenge = await endpoints.device.generateAuthChallenge(
          sessionBuilder,
          challenge: authChallenge.challenge,
          proofOfWork: authPow,
          signature: authSignature,
          devicePublicKey: devicePubKey,
        );
        expect(challenge, isNotEmpty);
        expect(challenge.length, greaterThan(10));

        // Step 6: Protected endpoints require authentication
        // DeviceManagementEndpoint requires login — Serverpod enforces this
        // at the framework level before endpoint code runs.
        expect(
          () => endpoints.deviceManagement.listDevices(sessionBuilder),
          throwsA(isA<ServerpodUnauthenticatedException>()),
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
        // DeviceManagementEndpoint requires login — Serverpod enforces this
        // at the framework level before endpoint code runs.
        expect(
          () => endpoints.deviceManagement.listDevices(sessionBuilder),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );

        expect(
          () => endpoints.deviceManagement.revokeDevice(sessionBuilder, 123),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );

        expect(
          () => endpoints.deviceManagement.authenticateDevice(
            sessionBuilder,
            'test_challenge',
            AuthTestHelper.generateValidSignature(),
          ),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });

      test('device registration succeeds with valid data', () async {
        final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

        await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
        );

        final (_, devicePubKey) = SigningTestHelper.generateKeypair();

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

        final (_, devicePubKey) = SigningTestHelper.generateKeypair();

        // Register first
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
          ultimateSigningPublicKeyHex: ultimatePubKey,
          deviceSigningPublicKeyHex: devicePubKey,
          encryptedDataKey: 'encrypted_device_data_key',
          label: 'Test Device',
        );

        // Duplicate should fail
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
            deviceSigningPublicKeyHex:
                'a123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
                '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
            encryptedDataKey: 'encrypted_device_data_key',
            label: 'Test Device',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });
    });
  });
}
