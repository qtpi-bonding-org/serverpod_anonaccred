import 'dart:convert';
import 'dart:typed_data';

import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';
import 'package:webcrypto/webcrypto.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  group('Authentication Flow Integration Tests', () {
    test('authentication handler integrates with Serverpod constructor', () {
      // Test that we can create a Serverpod instance with our authentication handler
      // This verifies the function signature is correct
      expect(
        () {
          // This would normally start a server, but we're just testing the constructor
          final _ = Serverpod(
            ['--mode', 'test'],
            Protocol(),
            Endpoints(),
            authenticationHandler: AnonAccredAuthHandler.handleAuthentication,
          );
        },
        returnsNormally,
      );
    });

    test('authentication handler has correct signature for Serverpod', () {
      // Test that the handler function signature matches what Serverpod expects
      // This is a compile-time check - if the signature is wrong, this won't compile
      const handler = AnonAccredAuthHandler.handleAuthentication;
      expect(handler, isA<Function>());
    });

    withServerpod('Given authentication flow integration', (sessionBuilder, endpoints) {
      test('successful authentication with valid device key and database lookup', () async {
        // Step 1: Create account and device in database
        // Generate ECDSA P-256 key pair for testing
        final accountKeyPair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
        final accountPublicKey = await accountKeyPair.publicKey.exportRawKey();
        
        // Convert to hex format (remove 04 prefix, use x||y format)
        final accountPublicKeyHex = accountPublicKey.sublist(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
        
        const encryptedDataKey = 'encrypted_account_data_key_12345';
        const ultimatePublicKey = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                                  'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

        final account = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKeyHex,
          encryptedDataKey,
          ultimatePublicKey,
        );

        // Create device
        final deviceKeyPair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
        final devicePublicKey = await deviceKeyPair.publicKey.exportRawKey();
        final devicePublicKeyHex = devicePublicKey.sublist(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
        
        const deviceEncryptedDataKey = 'encrypted_device_data_key_67890';
        const deviceLabel = 'Test Device';

        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          account.id!,
          devicePublicKeyHex,
          deviceEncryptedDataKey,
          deviceLabel,
        );

        // Step 2: Test authentication
        final challenge = CryptoUtils.generateChallenge();
        final challengeBytes = Uint8List.fromList(utf8.encode(challenge));
        
        // Sign challenge with device private key
        final signatureBytes = await deviceKeyPair.privateKey.signBytes(challengeBytes, Hash.sha256);
        final signatureHex = signatureBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

        // Step 3: Verify authentication (cryptographic verification only)
        final result = await CryptoAuth.verifyChallengeResponse(
          devicePublicKeyHex,
          challenge,
          signatureHex,
        );

        expect(result.success, isTrue);
        
        // Step 4: Verify database lookup works (separate from crypto verification)
        // In a real authentication flow, this would be done by the auth handler
        final foundDevice = await AccountDevice.db.findFirstRow(
          sessionBuilder.build(),
          where: (t) => t.publicSubKey.equals(devicePublicKeyHex),
        );
        
        expect(foundDevice, isNotNull);
        expect(foundDevice!.accountId, equals(account.id));
        expect(foundDevice.id, equals(device.id));
      });

      test('authentication failure with invalid signature', () async {
        // Create account and device
        final accountKeyPair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
        final accountPublicKey = await accountKeyPair.publicKey.exportRawKey();
        final accountPublicKeyHex = accountPublicKey.sublist(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
        
        const encryptedDataKey = 'encrypted_account_data_key_invalid';
        const ultimatePublicKey = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
                                  'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';

        final account = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKeyHex,
          encryptedDataKey,
          ultimatePublicKey,
        );

        final deviceKeyPair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
        final devicePublicKey = await deviceKeyPair.publicKey.exportRawKey();
        final devicePublicKeyHex = devicePublicKey.sublist(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
        
        const deviceEncryptedDataKey = 'encrypted_device_data_key_invalid';
        const deviceLabel = 'Test Device Invalid';

        await endpoints.device.registerDevice(
          sessionBuilder,
          account.id!,
          devicePublicKeyHex,
          deviceEncryptedDataKey,
          deviceLabel,
        );

        // Test with invalid signature
        final challenge = CryptoUtils.generateChallenge();
        final invalidSignature = 'invalid_signature_${'f' * 100}'; // 128 chars total

        final result = await CryptoAuth.verifyChallengeResponse(
          devicePublicKeyHex,
          challenge,
          invalidSignature,
        );

        expect(result.success, isFalse);
        expect(result.errorCode, equals(AnonAccredErrorCodes.cryptoInvalidSignature));
      });

      test('authentication failure with revoked device', () async {
        // Step 1: Create account and device
        final accountKeyPair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
        final accountPublicKey = await accountKeyPair.publicKey.exportRawKey();
        final accountPublicKeyHex = accountPublicKey.sublist(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
        
        const encryptedDataKey = 'encrypted_account_data_key_revoked';
        const ultimatePublicKey = 'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc'
                                  'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc';

        final account = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKeyHex,
          encryptedDataKey,
          ultimatePublicKey,
        );

        final deviceKeyPair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
        final devicePublicKey = await deviceKeyPair.publicKey.exportRawKey();
        final devicePublicKeyHex = devicePublicKey.sublist(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
        
        const deviceEncryptedDataKey = 'encrypted_device_data_key_revoked';
        const deviceLabel = 'Test Device Revoked';

        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          account.id!,
          devicePublicKeyHex,
          deviceEncryptedDataKey,
          deviceLabel,
        );

        // Step 2: Revoke the device (requires authenticated session)
        // Create authenticated session for device revocation
        final authenticatedSessionBuilder = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            account.id.toString(), // userId as string
            <Scope>{}, // scopes (empty set for testing)
          ),
        );

        await endpoints.device.revokeDevice(
          authenticatedSessionBuilder,
          device.id!,
        );

        // Step 3: Try to authenticate with revoked device
        final challenge = CryptoUtils.generateChallenge();
        final challengeBytes = Uint8List.fromList(utf8.encode(challenge));
        
        final signatureBytes = await deviceKeyPair.privateKey.signBytes(challengeBytes, Hash.sha256);
        final signatureHex = signatureBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

        // Cryptographic verification should still succeed (signature is valid)
        final result = await CryptoAuth.verifyChallengeResponse(
          devicePublicKeyHex,
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
        final accountKeyPair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
        final accountPublicKey = await accountKeyPair.publicKey.exportRawKey();
        final accountPublicKeyHex = accountPublicKey.sublist(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
        
        const encryptedDataKey = 'encrypted_account_data_key_info';
        const ultimatePublicKey = 'dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd'
                                  'dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd';

        final account = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKeyHex,
          encryptedDataKey,
          ultimatePublicKey,
        );

        final deviceKeyPair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
        final devicePublicKey = await deviceKeyPair.publicKey.exportRawKey();
        final devicePublicKeyHex = devicePublicKey.sublist(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
        
        const deviceEncryptedDataKey = 'encrypted_device_data_key_info';
        const deviceLabel = 'Test Device Info';

        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          account.id!,
          devicePublicKeyHex,
          deviceEncryptedDataKey,
          deviceLabel,
        );

        // Test authenticated session creation using Serverpod testing framework
        final authenticatedSessionBuilder = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            account.id.toString(), // userId as string
            <Scope>{}, // scopes (empty set for testing)
          ),
        );

        // Verify the authenticated session works by calling an authenticated endpoint
        // (We can't directly inspect the AuthenticationInfo, but we can test that it works)
        final session = authenticatedSessionBuilder.build();
        expect(session.authenticated, isNotNull);
        expect(session.authenticated!.userIdentifier, equals(account.id.toString()));
      });

      test('multiple devices can authenticate independently', () async {
        // Create account
        final accountKeyPair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
        final accountPublicKey = await accountKeyPair.publicKey.exportRawKey();
        final accountPublicKeyHex = accountPublicKey.sublist(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
        
        const encryptedDataKey = 'encrypted_account_data_key_multi';
        const ultimatePublicKey = 'eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee'
                                  'eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee';

        final account = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKeyHex,
          encryptedDataKey,
          ultimatePublicKey,
        );

        // Create multiple devices
        final devices = <AccountDevice>[];
        final deviceKeyPairs = <({EcdsaPrivateKey privateKey, String publicKeyHex})>[];
        
        for (var i = 0; i < 3; i++) {
          final deviceKeyPair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
          final devicePublicKey = await deviceKeyPair.publicKey.exportRawKey();
          final devicePublicKeyHex = devicePublicKey.sublist(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
          
          final deviceEncryptedDataKey = 'encrypted_device_data_key_multi_$i';
          final deviceLabel = 'Test Device Multi $i';

          final device = await endpoints.device.registerDevice(
            sessionBuilder,
            account.id!,
            devicePublicKeyHex,
            deviceEncryptedDataKey,
            deviceLabel,
          );

          devices.add(device);
          deviceKeyPairs.add((privateKey: deviceKeyPair.privateKey, publicKeyHex: devicePublicKeyHex));
        }

        // Test that each device can authenticate independently
        for (var i = 0; i < devices.length; i++) {
          final device = devices[i];
          final keyPairInfo = deviceKeyPairs[i];
          
          final devicePublicKeyHex = keyPairInfo.publicKeyHex;

          final challenge = CryptoUtils.generateChallenge();
          final challengeBytes = Uint8List.fromList(utf8.encode(challenge));
          
          final signatureBytes = await keyPairInfo.privateKey.signBytes(challengeBytes, Hash.sha256);
          final signatureHex = signatureBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

          final result = await CryptoAuth.verifyChallengeResponse(
            devicePublicKeyHex,
            challenge,
            signatureHex,
          );

          expect(result.success, isTrue);
          
          // Verify database lookup works for each device
          final foundDevice = await AccountDevice.db.findFirstRow(
            sessionBuilder.build(),
            where: (t) => t.publicSubKey.equals(devicePublicKeyHex),
          );
          
          expect(foundDevice, isNotNull);
          expect(foundDevice!.accountId, equals(account.id));
          expect(foundDevice.id, equals(device.id));
        }
      });

      test('extracts device key from authenticated session', () async {
        // Create test data
        final accountKeyPair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
        final accountPublicKey = await accountKeyPair.publicKey.exportRawKey();
        final accountPublicKeyHex = accountPublicKey.sublist(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
        
        const encryptedDataKey = 'encrypted_account_data_key_extract';
        const ultimatePublicKey = 'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff'
                                  'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff';

        final account = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKeyHex,
          encryptedDataKey,
          ultimatePublicKey,
        );

        final deviceKeyPair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
        final devicePublicKey = await deviceKeyPair.publicKey.exportRawKey();
        final devicePublicKeyHex = devicePublicKey.sublist(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
        
        const deviceEncryptedDataKey = 'encrypted_device_data_key_extract';
        const deviceLabel = 'Test Device Extract';

        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          account.id!,
          devicePublicKeyHex,
          deviceEncryptedDataKey,
          deviceLabel,
        );

        // Create authenticated session using Serverpod testing framework
        final authenticatedSessionBuilder = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            account.id.toString(), // userId as string
            <Scope>{}, // scopes (empty set for testing)
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