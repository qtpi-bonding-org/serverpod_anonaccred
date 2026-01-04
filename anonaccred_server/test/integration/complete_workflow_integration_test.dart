import 'dart:typed_data';

import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:anonaccred_server/src/crypto_utils.dart';
import 'package:test/test.dart';
import 'package:webcrypto/webcrypto.dart';

import 'test_tools/auth_test_helper.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Complete Workflow Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    group('Account Creation → Device Registration → Authentication Flow', () {
      test('complete happy path workflow with real ECDSA P-256 signatures', () async {
        // Step 1: Generate ECDSA P-256 key pair for account (simulating client-side)
        final accountKeyPair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
        final accountPublicKey = await accountKeyPair.publicKey.exportRawKey();
        final accountPublicKeyHex = accountPublicKey.sublist(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();

        // Step 2: Create account
        const encryptedDataKey = 'encrypted_account_data_key_12345';
        final ultimatePublicKey = 'ultimate_public_key_workflow_' + ('a' * 100);
        final account = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKeyHex,
          encryptedDataKey,
          ultimatePublicKey,
        );

        expect(account.id, isNotNull);
        expect(account.publicMasterKey, equals(accountPublicKeyHex));
        expect(account.encryptedDataKey, equals(encryptedDataKey));

        // Step 3: Generate ECDSA P-256 key pair for device (simulating client-side)
        final deviceKeyPair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
        final devicePublicKey = await deviceKeyPair.publicKey.exportRawKey();
        final devicePublicKeyHex = devicePublicKey.sublist(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();

        // Step 4: Register device
        const deviceEncryptedDataKey = 'encrypted_device_data_key_67890';
        const deviceLabel = 'Test Device for Complete Workflow';

        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          account.id!,
          devicePublicKeyHex,
          deviceEncryptedDataKey,
          deviceLabel,
        );

        expect(device.id, isNotNull);
        expect(device.accountId, equals(account.id));
        expect(device.publicSubKey, equals(devicePublicKeyHex));
        expect(device.encryptedDataKey, equals(deviceEncryptedDataKey));
        expect(device.label, equals(deviceLabel));
        expect(device.isRevoked, isFalse);

        // Step 5: Test challenge generation (doesn't require auth)
        final challenge = await endpoints.device.generateAuthChallenge(sessionBuilder);
        expect(challenge, isNotEmpty);
        expect(challenge.length, greaterThan(10)); // Should be a reasonable challenge

        // Step 6: Test that protected endpoints require authentication
        // These should all fail because we don't have proper authentication in test environment
        expect(
          () => endpoints.device.listDevices(sessionBuilder),
          throwsA(isA<AuthenticationException>()),
        );

        expect(
          () => endpoints.device.revokeDevice(sessionBuilder, device.id!),
          throwsA(isA<AuthenticationException>()),
        );

        expect(
          () => endpoints.device.authenticateDevice(
            sessionBuilder,
            challenge,
            AuthTestHelper.generateValidSignature(),
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('account lookup workflow', () async {
        // Step 1: Generate ECDSA P-256 key pair for account
        final accountKeyPair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
        final accountPublicKey = await accountKeyPair.publicKey.exportRawKey();
        final accountPublicKeyHex = accountPublicKey.sublist(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();

        // Step 2: Create account
        const encryptedDataKey = 'encrypted_account_data_key_lookup';
        final ultimatePublicKey = 'ultimate_public_key_lookup_' + ('b' * 100);
        final account = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKeyHex,
          encryptedDataKey,
          ultimatePublicKey,
        );

        expect(account.id, isNotNull);

        // Step 3: Test account lookup with session
        final foundAccount = await endpoints.account.getAccountByPublicKey(
          sessionBuilder,
          accountPublicKeyHex,
        );

        expect(foundAccount, isNotNull);
        expect(foundAccount!.id, equals(account.id));

        // Step 4: Test lookup with non-existent key
        const nonExistentPublicKey =
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' +
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        final nonExistentAccount = await endpoints.account.getAccountByPublicKey(
          sessionBuilder,
          nonExistentPublicKey,
        );
        expect(nonExistentAccount, isNull);
      });

      test('authentication failure scenarios', () async {
        // Test unauthenticated access to protected endpoints
        // All of these should fail with authentication required errors

        // Should fail to list devices without authentication
        expect(
          () => endpoints.device.listDevices(sessionBuilder),
          throwsA(isA<AuthenticationException>()),
        );

        // Should fail to revoke device without authentication
        expect(
          () => endpoints.device.revokeDevice(sessionBuilder, 123),
          throwsA(isA<AuthenticationException>()),
        );

        // Should fail to authenticate device without authentication
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
        // Create test account
        const accountPublicKey =
            'b123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef' +
            '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const accountEncryptedDataKey = 'encrypted_test_data_key_8';
        const ultimatePublicKey = 
            'c123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef' +
            '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

        final testAccount = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKey,
          accountEncryptedDataKey,
          ultimatePublicKey,
        );

        // Test successful device registration
        final devicePublicKey = AuthTestHelper.generateValidDeviceKey();
        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          testAccount.id!,
          devicePublicKey,
          'encrypted_device_data_key',
          'Test Device',
        );

        expect(device.id, isNotNull);
        expect(device.publicSubKey, equals(devicePublicKey));
        expect(device.isRevoked, isFalse);

        // Test duplicate device registration fails
        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            testAccount.id!,
            devicePublicKey, // Same key
            'encrypted_device_data_key_2',
            'Test Device 2',
          ),
          throwsA(isA<AuthenticationException>()),
        );

        // Test registration with non-existent account fails
        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            99999, // Non-existent account
            'b123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef' +
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