
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

        // Step 4: Generate device keypair and register
        final (_, devicePubKey) = SigningTestHelper.generateKeypair();
        const deviceEncryptedDataKey = 'encrypted_device_data_key_67890';
        const deviceLabel = 'Test Device for Complete Workflow';

        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          account.ultimateSigningPublicKeyHex,
          devicePubKey,
          deviceEncryptedDataKey,
          deviceLabel,
        );

        expect(device.id, isNotNull);
        expect(device.accountId, equals(account.id));
        expect(device.deviceSigningPublicKeyHex, equals(devicePubKey));
        expect(device.isRevoked, isFalse);

        // Step 5: Test challenge generation for device auth
        final challenge = await endpoints.device.generateAuthChallenge(
          sessionBuilder,
          devicePubKey,
        );
        expect(challenge, isNotEmpty);
        expect(challenge.length, greaterThan(10));

        // Step 6: Protected endpoints require authentication
        expect(
          () => endpoints.device.listDevices(sessionBuilder),
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
        expect(
          () => endpoints.device.listDevices(sessionBuilder),
          throwsA(isA<AuthenticationException>()),
        );

        expect(
          () => endpoints.device.revokeDevice(sessionBuilder, 123),
          throwsA(isA<AuthenticationException>()),
        );

        expect(
          () => endpoints.device.authenticateDevice(
            sessionBuilder,
            'test_challenge',
            AuthTestHelper.generateValidSignature(),
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('device registration validation workflow', () async {
        final account = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex:
              'b123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
              '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
        );

        // Successful device registration
        final devicePublicKey = AuthTestHelper.generateValidDeviceKey();
        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          account.ultimateSigningPublicKeyHex,
          devicePublicKey,
          'encrypted_device_data_key',
          'Test Device',
        );

        expect(device.id, isNotNull);
        expect(device.isRevoked, isFalse);

        // Duplicate device registration fails
        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            account.ultimateSigningPublicKeyHex,
            devicePublicKey,
            'encrypted_device_data_key_2',
            'Test Device 2',
          ),
          throwsA(isA<AuthenticationException>()),
        );

        // Non-existent account fails
        const nonExistentKey =
            'ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00'
            'ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00';
        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            nonExistentKey,
            'a123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
                '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
            'encrypted_device_data_key',
            'Test Device',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });
    });
  });
}
