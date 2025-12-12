import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:cryptography/cryptography.dart';
import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:anonaccred_server/src/crypto_utils.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Complete Workflow Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    group('Account Creation → Device Registration → Authentication Flow', () {
      test('complete happy path workflow with real Ed25519 signatures', () async {
        // Step 1: Generate Ed25519 key pair for account (simulating client-side)
        final algorithm = Ed25519();
        final accountKeyPair = await algorithm.newKeyPair();
        final accountPublicKey = await accountKeyPair.extractPublicKey();
        final accountPublicKeyHex = CryptoUtils.bytesToHex(
          Uint8List.fromList(accountPublicKey.bytes),
        );

        // Step 2: Create account
        const encryptedDataKey = 'encrypted_account_data_key_12345';
        final account = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKeyHex,
          encryptedDataKey,
        );

        expect(account.id, isNotNull);
        expect(account.publicMasterKey, equals(accountPublicKeyHex));
        expect(account.encryptedDataKey, equals(encryptedDataKey));

        // Step 3: Generate device key pair (simulating client-side)
        final deviceKeyPair = await algorithm.newKeyPair();
        final devicePublicKey = await deviceKeyPair.extractPublicKey();
        final devicePublicKeyHex = CryptoUtils.bytesToHex(
          Uint8List.fromList(devicePublicKey.bytes),
        );

        // Step 4: Register device
        const deviceEncryptedDataKey = 'encrypted_device_data_key_67890';
        const deviceLabel = 'Test Device - Integration';

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

        // Step 5: Generate authentication challenge
        final challenge = await endpoints.device.generateAuthChallenge(
          sessionBuilder,
        );
        expect(challenge, isNotEmpty);
        expect(challenge.length, equals(64)); // 32 bytes as hex

        // Step 6: Sign challenge with device key (simulating client-side)
        final challengeBytes = utf8.encode(challenge);
        final signature = await algorithm.sign(
          challengeBytes,
          keyPair: deviceKeyPair,
        );
        final signatureHex = CryptoUtils.bytesToHex(
          Uint8List.fromList(signature.bytes),
        );

        // Step 7: Authenticate device with signed challenge
        final authResult = await endpoints.device.authenticateDevice(
          sessionBuilder,
          devicePublicKeyHex,
          challenge,
          signatureHex,
        );

        expect(authResult.success, isTrue);
        expect(authResult.errorCode, isNull);
        expect(authResult.errorMessage, isNull);

        // Step 8: Verify device list shows the registered device
        final devices = await endpoints.device.listDevices(
          sessionBuilder,
          account.id!,
        );
        expect(devices, hasLength(1));
        expect(devices.first.id, equals(device.id));
        expect(devices.first.label, equals(deviceLabel));
        expect(devices.first.isRevoked, isFalse);
      });

      test('authentication fails with wrong signature', () async {
        // Create account and device
        final algorithm = Ed25519();
        final accountKeyPair = await algorithm.newKeyPair();
        final accountPublicKey = await accountKeyPair.extractPublicKey();
        final accountPublicKeyHex = CryptoUtils.bytesToHex(
          Uint8List.fromList(accountPublicKey.bytes),
        );

        final account = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKeyHex,
          'encrypted_data_key',
        );

        final deviceKeyPair = await algorithm.newKeyPair();
        final devicePublicKey = await deviceKeyPair.extractPublicKey();
        final devicePublicKeyHex = CryptoUtils.bytesToHex(
          Uint8List.fromList(devicePublicKey.bytes),
        );

        await endpoints.device.registerDevice(
          sessionBuilder,
          account.id!,
          devicePublicKeyHex,
          'device_encrypted_data_key',
          'Test Device',
        );

        // Generate challenge
        final challenge = await endpoints.device.generateAuthChallenge(
          sessionBuilder,
        );

        // Sign challenge with DIFFERENT key (wrong key)
        final wrongKeyPair = await algorithm.newKeyPair();
        final challengeBytes = utf8.encode(challenge);
        final wrongSignature = await algorithm.sign(
          challengeBytes,
          keyPair: wrongKeyPair,
        );
        final wrongSignatureHex = CryptoUtils.bytesToHex(
          Uint8List.fromList(wrongSignature.bytes),
        );

        // Authentication should fail
        final authResult = await endpoints.device.authenticateDevice(
          sessionBuilder,
          devicePublicKeyHex,
          challenge,
          wrongSignatureHex,
        );

        expect(authResult.success, isFalse);
        expect(authResult.errorCode, isNotNull);
        expect(authResult.errorMessage, contains('verification failed'));
      });

      test('authentication fails with non-existent device', () async {
        // Generate a valid key pair but don't register the device
        final algorithm = Ed25519();
        final deviceKeyPair = await algorithm.newKeyPair();
        final devicePublicKey = await deviceKeyPair.extractPublicKey();
        final devicePublicKeyHex = CryptoUtils.bytesToHex(
          Uint8List.fromList(devicePublicKey.bytes),
        );

        // Generate challenge
        final challenge = await endpoints.device.generateAuthChallenge(
          sessionBuilder,
        );

        // Sign challenge with valid key
        final challengeBytes = utf8.encode(challenge);
        final signature = await algorithm.sign(
          challengeBytes,
          keyPair: deviceKeyPair,
        );
        final signatureHex = CryptoUtils.bytesToHex(
          Uint8List.fromList(signature.bytes),
        );

        // Authentication should fail because device is not registered
        final authResult = await endpoints.device.authenticateDevice(
          sessionBuilder,
          devicePublicKeyHex,
          challenge,
          signatureHex,
        );

        expect(authResult.success, isFalse);
        expect(authResult.errorCode, isNotNull);
      });
    });

    group('Device Revocation → Authentication Failure Flow', () {
      test('revoked device cannot authenticate', () async {
        // Step 1: Create account and register device
        final algorithm = Ed25519();
        final accountKeyPair = await algorithm.newKeyPair();
        final accountPublicKey = await accountKeyPair.extractPublicKey();
        final accountPublicKeyHex = CryptoUtils.bytesToHex(
          Uint8List.fromList(accountPublicKey.bytes),
        );

        final account = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKeyHex,
          'encrypted_account_data_key',
        );

        final deviceKeyPair = await algorithm.newKeyPair();
        final devicePublicKey = await deviceKeyPair.extractPublicKey();
        final devicePublicKeyHex = CryptoUtils.bytesToHex(
          Uint8List.fromList(devicePublicKey.bytes),
        );

        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          account.id!,
          devicePublicKeyHex,
          'device_encrypted_data_key',
          'Test Device for Revocation',
        );

        // Step 2: Verify device can authenticate initially
        final initialChallenge = await endpoints.device.generateAuthChallenge(
          sessionBuilder,
        );
        final initialChallengeBytes = utf8.encode(initialChallenge);
        final initialSignature = await algorithm.sign(
          initialChallengeBytes,
          keyPair: deviceKeyPair,
        );
        final initialSignatureHex = CryptoUtils.bytesToHex(
          Uint8List.fromList(initialSignature.bytes),
        );

        final initialAuthResult = await endpoints.device.authenticateDevice(
          sessionBuilder,
          devicePublicKeyHex,
          initialChallenge,
          initialSignatureHex,
        );

        expect(initialAuthResult.success, isTrue);

        // Step 3: Revoke the device
        final revocationResult = await endpoints.device.revokeDevice(
          sessionBuilder,
          account.id!,
          device.id!,
        );

        expect(revocationResult, isTrue);

        // Step 4: Verify device list shows revoked status
        final devicesAfterRevocation = await endpoints.device.listDevices(
          sessionBuilder,
          account.id!,
        );
        expect(devicesAfterRevocation, hasLength(1));
        expect(devicesAfterRevocation.first.isRevoked, isTrue);

        // Step 5: Attempt authentication after revocation (should fail)
        final postRevocationChallenge = await endpoints.device
            .generateAuthChallenge(sessionBuilder);
        final postRevocationChallengeBytes = utf8.encode(
          postRevocationChallenge,
        );
        final postRevocationSignature = await algorithm.sign(
          postRevocationChallengeBytes,
          keyPair: deviceKeyPair,
        );
        final postRevocationSignatureHex = CryptoUtils.bytesToHex(
          Uint8List.fromList(postRevocationSignature.bytes),
        );

        final postRevocationAuthResult = await endpoints.device
            .authenticateDevice(
              sessionBuilder,
              devicePublicKeyHex,
              postRevocationChallenge,
              postRevocationSignatureHex,
            );

        expect(postRevocationAuthResult.success, isFalse);
        expect(postRevocationAuthResult.errorCode, isNotNull);
        expect(postRevocationAuthResult.errorMessage, contains('revoked'));
      });

      test('revocation immediately blocks all authentication attempts', () async {
        // Create account and device
        final algorithm = Ed25519();
        final accountKeyPair = await algorithm.newKeyPair();
        final accountPublicKey = await accountKeyPair.extractPublicKey();
        final accountPublicKeyHex = CryptoUtils.bytesToHex(
          Uint8List.fromList(accountPublicKey.bytes),
        );

        final account = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKeyHex,
          'encrypted_account_data_key',
        );

        final deviceKeyPair = await algorithm.newKeyPair();
        final devicePublicKey = await deviceKeyPair.extractPublicKey();
        final devicePublicKeyHex = CryptoUtils.bytesToHex(
          Uint8List.fromList(devicePublicKey.bytes),
        );

        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          account.id!,
          devicePublicKeyHex,
          'device_encrypted_data_key',
          'Test Device for Immediate Revocation',
        );

        // Revoke device immediately
        await endpoints.device.revokeDevice(
          sessionBuilder,
          account.id!,
          device.id!,
        );

        // Try multiple authentication attempts - all should fail
        for (int i = 0; i < 3; i++) {
          final challenge = await endpoints.device.generateAuthChallenge(
            sessionBuilder,
          );
          final challengeBytes = utf8.encode(challenge);
          final signature = await algorithm.sign(
            challengeBytes,
            keyPair: deviceKeyPair,
          );
          final signatureHex = CryptoUtils.bytesToHex(
            Uint8List.fromList(signature.bytes),
          );

          final authResult = await endpoints.device.authenticateDevice(
            sessionBuilder,
            devicePublicKeyHex,
            challenge,
            signatureHex,
          );

          expect(
            authResult.success,
            isFalse,
            reason:
                'Authentication attempt ${i + 1} should fail for revoked device',
          );
          expect(authResult.errorCode, isNotNull);
        }
      });
    });

    group('Multi-Device Scenarios with Different Keys', () {
      test('multiple devices can authenticate independently', () async {
        // Create account
        final algorithm = Ed25519();
        final accountKeyPair = await algorithm.newKeyPair();
        final accountPublicKey = await accountKeyPair.extractPublicKey();
        final accountPublicKeyHex = CryptoUtils.bytesToHex(
          Uint8List.fromList(accountPublicKey.bytes),
        );

        final account = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKeyHex,
          'encrypted_account_data_key',
        );

        // Register multiple devices with different keys
        final devices = <Map<String, dynamic>>[];

        for (int i = 0; i < 3; i++) {
          final deviceKeyPair = await algorithm.newKeyPair();
          final devicePublicKey = await deviceKeyPair.extractPublicKey();
          final devicePublicKeyHex = CryptoUtils.bytesToHex(
            Uint8List.fromList(devicePublicKey.bytes),
          );

          final device = await endpoints.device.registerDevice(
            sessionBuilder,
            account.id!,
            devicePublicKeyHex,
            'device_${i}_encrypted_data_key',
            'Device $i',
          );

          devices.add({
            'device': device,
            'keyPair': deviceKeyPair,
            'publicKeyHex': devicePublicKeyHex,
          });
        }

        // Verify all devices can authenticate independently
        for (int i = 0; i < devices.length; i++) {
          final deviceData = devices[i];
          final challenge = await endpoints.device.generateAuthChallenge(
            sessionBuilder,
          );
          final challengeBytes = utf8.encode(challenge);
          final signature = await algorithm.sign(
            challengeBytes,
            keyPair: deviceData['keyPair'] as KeyPair,
          );
          final signatureHex = CryptoUtils.bytesToHex(
            Uint8List.fromList(signature.bytes),
          );

          final authResult = await endpoints.device.authenticateDevice(
            sessionBuilder,
            deviceData['publicKeyHex'] as String,
            challenge,
            signatureHex,
          );

          expect(
            authResult.success,
            isTrue,
            reason: 'Device $i should authenticate successfully',
          );
        }

        // Verify device list shows all devices
        final deviceList = await endpoints.device.listDevices(
          sessionBuilder,
          account.id!,
        );
        expect(deviceList, hasLength(3));

        for (int i = 0; i < 3; i++) {
          expect(deviceList.any((d) => d.label == 'Device $i'), isTrue);
        }
      });

      test('revoking one device does not affect others', () async {
        // Create account and register 3 devices
        final algorithm = Ed25519();
        final accountKeyPair = await algorithm.newKeyPair();
        final accountPublicKey = await accountKeyPair.extractPublicKey();
        final accountPublicKeyHex = CryptoUtils.bytesToHex(
          Uint8List.fromList(accountPublicKey.bytes),
        );

        final account = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKeyHex,
          'encrypted_account_data_key',
        );

        final devices = <Map<String, dynamic>>[];

        for (int i = 0; i < 3; i++) {
          final deviceKeyPair = await algorithm.newKeyPair();
          final devicePublicKey = await deviceKeyPair.extractPublicKey();
          final devicePublicKeyHex = CryptoUtils.bytesToHex(
            Uint8List.fromList(devicePublicKey.bytes),
          );

          final device = await endpoints.device.registerDevice(
            sessionBuilder,
            account.id!,
            devicePublicKeyHex,
            'device_${i}_encrypted_data_key',
            'Multi Device $i',
          );

          devices.add({
            'device': device,
            'keyPair': deviceKeyPair,
            'publicKeyHex': devicePublicKeyHex,
          });
        }

        // Revoke the middle device (index 1)
        final deviceToRevoke = devices[1]['device'] as AccountDevice;
        await endpoints.device.revokeDevice(
          sessionBuilder,
          account.id!,
          deviceToRevoke.id!,
        );

        // Verify device 0 and device 2 can still authenticate
        for (final deviceIndex in [0, 2]) {
          final deviceData = devices[deviceIndex];
          final challenge = await endpoints.device.generateAuthChallenge(
            sessionBuilder,
          );
          final challengeBytes = utf8.encode(challenge);
          final signature = await algorithm.sign(
            challengeBytes,
            keyPair: deviceData['keyPair'] as KeyPair,
          );
          final signatureHex = CryptoUtils.bytesToHex(
            Uint8List.fromList(signature.bytes),
          );

          final authResult = await endpoints.device.authenticateDevice(
            sessionBuilder,
            deviceData['publicKeyHex'] as String,
            challenge,
            signatureHex,
          );

          expect(
            authResult.success,
            isTrue,
            reason:
                'Device $deviceIndex should still authenticate after device 1 revocation',
          );
        }

        // Verify revoked device (index 1) cannot authenticate
        final revokedDeviceData = devices[1];
        final revokedChallenge = await endpoints.device.generateAuthChallenge(
          sessionBuilder,
        );
        final revokedChallengeBytes = utf8.encode(revokedChallenge);
        final revokedSignature = await algorithm.sign(
          revokedChallengeBytes,
          keyPair: revokedDeviceData['keyPair'] as KeyPair,
        );
        final revokedSignatureHex = CryptoUtils.bytesToHex(
          Uint8List.fromList(revokedSignature.bytes),
        );

        final revokedAuthResult = await endpoints.device.authenticateDevice(
          sessionBuilder,
          revokedDeviceData['publicKeyHex'] as String,
          revokedChallenge,
          revokedSignatureHex,
        );

        expect(
          revokedAuthResult.success,
          isFalse,
          reason: 'Revoked device should not authenticate',
        );

        // Verify device list shows correct revocation status
        final deviceList = await endpoints.device.listDevices(
          sessionBuilder,
          account.id!,
        );
        expect(deviceList, hasLength(3));

        final revokedDevice = deviceList.firstWhere(
          (d) => d.id == deviceToRevoke.id,
        );
        expect(revokedDevice.isRevoked, isTrue);

        final activeDevices = deviceList.where((d) => !d.isRevoked).toList();
        expect(activeDevices, hasLength(2));
      });

      test(
        'cross-device authentication fails (device A cannot use device B signature)',
        () async {
          // Create account and register 2 devices
          final algorithm = Ed25519();
          final accountKeyPair = await algorithm.newKeyPair();
          final accountPublicKey = await accountKeyPair.extractPublicKey();
          final accountPublicKeyHex = CryptoUtils.bytesToHex(
            Uint8List.fromList(accountPublicKey.bytes),
          );

          final account = await endpoints.account.createAccount(
            sessionBuilder,
            accountPublicKeyHex,
            'encrypted_account_data_key',
          );

          // Device A
          final deviceAKeyPair = await algorithm.newKeyPair();
          final deviceAPublicKey = await deviceAKeyPair.extractPublicKey();
          final deviceAPublicKeyHex = CryptoUtils.bytesToHex(
            Uint8List.fromList(deviceAPublicKey.bytes),
          );

          await endpoints.device.registerDevice(
            sessionBuilder,
            account.id!,
            deviceAPublicKeyHex,
            'device_a_encrypted_data_key',
            'Device A',
          );

          // Device B
          final deviceBKeyPair = await algorithm.newKeyPair();
          final deviceBPublicKey = await deviceBKeyPair.extractPublicKey();
          final deviceBPublicKeyHex = CryptoUtils.bytesToHex(
            Uint8List.fromList(deviceBPublicKey.bytes),
          );

          await endpoints.device.registerDevice(
            sessionBuilder,
            account.id!,
            deviceBPublicKeyHex,
            'device_b_encrypted_data_key',
            'Device B',
          );

          // Generate challenge and sign with Device B's key
          final challenge = await endpoints.device.generateAuthChallenge(
            sessionBuilder,
          );
          final challengeBytes = utf8.encode(challenge);
          final deviceBSignature = await algorithm.sign(
            challengeBytes,
            keyPair: deviceBKeyPair,
          );
          final deviceBSignatureHex = CryptoUtils.bytesToHex(
            Uint8List.fromList(deviceBSignature.bytes),
          );

          // Try to authenticate as Device A using Device B's signature (should fail)
          final crossAuthResult = await endpoints.device.authenticateDevice(
            sessionBuilder,
            deviceAPublicKeyHex, // Device A's public key
            challenge,
            deviceBSignatureHex, // Device B's signature
          );

          expect(
            crossAuthResult.success,
            isFalse,
            reason: 'Cross-device authentication should fail',
          );
          expect(crossAuthResult.errorCode, isNotNull);
          expect(crossAuthResult.errorMessage, contains('verification failed'));
        },
      );
    });

    group('Serverpod Session Management Integration', () {
      test('all endpoints work with Serverpod session lifecycle', () async {
        // This test verifies that all endpoints properly integrate with Serverpod's
        // session management, including transaction handling and error propagation

        final algorithm = Ed25519();
        final accountKeyPair = await algorithm.newKeyPair();
        final accountPublicKey = await accountKeyPair.extractPublicKey();
        final accountPublicKeyHex = CryptoUtils.bytesToHex(
          Uint8List.fromList(accountPublicKey.bytes),
        );

        // Test account creation with session
        final account = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKeyHex,
          'session_test_encrypted_data_key',
        );

        expect(account.id, isNotNull);

        // Test account lookup with session
        final foundAccount = await endpoints.account.getAccountByPublicKey(
          sessionBuilder,
          accountPublicKeyHex,
        );

        expect(foundAccount, isNotNull);
        expect(foundAccount!.id, equals(account.id));

        // Test device registration with session
        final deviceKeyPair = await algorithm.newKeyPair();
        final devicePublicKey = await deviceKeyPair.extractPublicKey();
        final devicePublicKeyHex = CryptoUtils.bytesToHex(
          Uint8List.fromList(devicePublicKey.bytes),
        );

        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          account.id!,
          devicePublicKeyHex,
          'session_test_device_encrypted_data_key',
          'Session Test Device',
        );

        expect(device.id, isNotNull);

        // Test challenge generation with session
        final challenge = await endpoints.device.generateAuthChallenge(
          sessionBuilder,
        );
        expect(challenge, isNotEmpty);

        // Test authentication with session
        final challengeBytes = utf8.encode(challenge);
        final signature = await algorithm.sign(
          challengeBytes,
          keyPair: deviceKeyPair,
        );
        final signatureHex = CryptoUtils.bytesToHex(
          Uint8List.fromList(signature.bytes),
        );

        final authResult = await endpoints.device.authenticateDevice(
          sessionBuilder,
          devicePublicKeyHex,
          challenge,
          signatureHex,
        );

        expect(authResult.success, isTrue);

        // Test device listing with session
        final devices = await endpoints.device.listDevices(
          sessionBuilder,
          account.id!,
        );
        expect(devices, hasLength(1));

        // Test device revocation with session
        final revocationResult = await endpoints.device.revokeDevice(
          sessionBuilder,
          account.id!,
          device.id!,
        );

        expect(revocationResult, isTrue);

        // Verify revocation persisted through session
        final devicesAfterRevocation = await endpoints.device.listDevices(
          sessionBuilder,
          account.id!,
        );
        expect(devicesAfterRevocation.first.isRevoked, isTrue);
      });

      test('error handling works correctly with Serverpod sessions', () async {
        // Test that exceptions are properly propagated through Serverpod sessions

        // Test invalid account creation
        expect(
          () => endpoints.account.createAccount(
            sessionBuilder,
            'invalid_key_format',
            'encrypted_data_key',
          ),
          throwsA(isA<Exception>()),
        );

        // Test non-existent account lookup
        final nonExistentAccount = await endpoints.account.getAccountByPublicKey(
          sessionBuilder,
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        );
        expect(nonExistentAccount, isNull);

        // Test device registration for non-existent account
        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            99999, // Non-existent account ID
            'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
            'encrypted_data_key',
            'Test Device',
          ),
          throwsA(isA<Exception>()),
        );

        // Test authentication with invalid signature format
        final challenge = await endpoints.device.generateAuthChallenge(
          sessionBuilder,
        );
        final authResult = await endpoints.device.authenticateDevice(
          sessionBuilder,
          'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
          challenge,
          'invalid_signature_format',
        );

        expect(authResult.success, isFalse);
        expect(authResult.errorCode, isNotNull);
      });
    });
  });
}
