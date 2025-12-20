import 'dart:convert';
import 'dart:typed_data';

import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:cryptography/cryptography.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

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
      // Verify the authentication handler matches Serverpod's expected signature
      const handler = AnonAccredAuthHandler.handleAuthentication;
      
      // Should be a function that takes Session and String and returns Future<AuthenticationInfo?>
      expect(handler, isA<Future<AuthenticationInfo?> Function(Session, String)>());
    });

    test('authentication flow rejects invalid device key formats', () async {
      final mockSession = _MockSession();
      
      final testCases = [
        '', // empty
        'short', // too short
        'invalid-characters!@#', // invalid characters
        'a' * 63, // too short by 1
        'a' * 65, // too long by 1
      ];
      
      for (final invalidKey in testCases) {
        final result = await AnonAccredAuthHandler.handleAuthentication(
          mockSession,
          invalidKey,
        );
        
        expect(result, isNull, reason: 'Should reject invalid key: $invalidKey');
      }
    });

    test('getDevicePublicKey works with authenticated session', () {
      final mockSession = _MockSession();
      const deviceKey = 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890';
      
      // Set up authenticated session as would be created by handleAuthentication
      mockSession.authenticated = AuthenticationInfo(
        '123', // account ID
        {const Scope('device:$deviceKey')},
        authId: deviceKey,
      );
      
      final extractedKey = AnonAccredAuthHandler.getDevicePublicKey(mockSession);
      expect(extractedKey, equals(deviceKey));
    });

    test('authentication handler logs appropriate messages', () async {
      final mockSession = _MockSession();
      
      // Test with empty token
      await AnonAccredAuthHandler.handleAuthentication(mockSession, '');
      expect(mockSession.loggedMessages, contains('Authentication failed: Missing device public key in both header (X-QUANITYA-DEVICE-PUBKEY) and token'));
      
      // Reset and test with invalid format
      mockSession.loggedMessages.clear();
      await AnonAccredAuthHandler.handleAuthentication(mockSession, 'invalid');
      expect(mockSession.loggedMessages.any((msg) => msg.contains('Authentication')), isTrue);
    });
  });

  // End-to-End Authentication Flow Tests with Real Database
  withServerpod('End-to-End Authentication Flow Tests', (sessionBuilder, endpoints) {
    group('Authentication Handler with Database Integration', () {
      test('successful authentication with valid device key and database lookup', () async {
        // Step 1: Create account and device in database
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
          'Test Device for Auth Handler',
        );

        // Step 2: Test authentication handler with real session and database
        final testSession = sessionBuilder.build();
        final authInfo = await AnonAccredAuthHandler.handleAuthentication(
          testSession,
          devicePublicKeyHex,
        );

        // Step 3: Verify AuthenticationInfo is properly created
        expect(authInfo, isNotNull);
        expect(authInfo!.authId, equals(devicePublicKeyHex));
        expect(authInfo.scopes, hasLength(1));
        expect(authInfo.scopes.first.name, equals('device:$devicePublicKeyHex'));

        // Step 4: Verify getDevicePublicKey works with real AuthenticationInfo
        final mockSessionWithAuth = _MockSession();
        mockSessionWithAuth.authenticated = authInfo;
        final extractedKey = AnonAccredAuthHandler.getDevicePublicKey(mockSessionWithAuth);
        expect(extractedKey, equals(devicePublicKeyHex));
      });

      test('authentication failure with missing device key', () async {
        final testSession = sessionBuilder.build();
        
        // Test with empty token
        final authInfo = await AnonAccredAuthHandler.handleAuthentication(
          testSession,
          '',
        );
        
        expect(authInfo, isNull);
      });

      test('authentication failure with invalid device key format', () async {
        final testSession = sessionBuilder.build();
        
        final invalidKeys = [
          'short',
          'invalid-characters!@#',
          'a' * 63, // too short
          'a' * 65, // too long
        ];
        
        for (final invalidKey in invalidKeys) {
          final authInfo = await AnonAccredAuthHandler.handleAuthentication(
            testSession,
            invalidKey,
          );
          
          expect(authInfo, isNull, reason: 'Should reject invalid key: $invalidKey');
        }
      });

      test('authentication failure with non-existent device', () async {
        final testSession = sessionBuilder.build();
        
        // Use a valid format key that doesn't exist in database
        const nonExistentKey = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        
        final authInfo = await AnonAccredAuthHandler.handleAuthentication(
          testSession,
          nonExistentKey,
        );
        
        expect(authInfo, isNull);
      });

      test('authentication failure with revoked device', () async {
        // Step 1: Create account and device
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

        // Step 2: Manually revoke the device in database (since revokeDevice endpoint requires auth)
        final session = sessionBuilder.build();
        await AccountDevice.db.updateRow(
          session,
          device.copyWith(isRevoked: true),
        );

        // Step 3: Test authentication with revoked device
        final testSession = sessionBuilder.build();
        final authInfo = await AnonAccredAuthHandler.handleAuthentication(
          testSession,
          devicePublicKeyHex,
        );

        // Should return null for revoked device
        expect(authInfo, isNull);
      });

      test('AuthenticationInfo structure matches Serverpod requirements', () async {
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

        await endpoints.device.registerDevice(
          sessionBuilder,
          account.id!,
          devicePublicKeyHex,
          'device_encrypted_data_key',
          'Test Device for AuthInfo Structure',
        );

        // Test authentication
        final testSession = sessionBuilder.build();
        final authInfo = await AnonAccredAuthHandler.handleAuthentication(
          testSession,
          devicePublicKeyHex,
        );

        // Verify AuthenticationInfo structure
        expect(authInfo, isNotNull);
        expect(authInfo!.authId, isA<String>());
        expect(authInfo.authId, equals(devicePublicKeyHex));
        expect(authInfo.scopes, isA<Set<Scope>>());
        expect(authInfo.scopes, hasLength(1));
        expect(authInfo.scopes.first.name, startsWith('device:'));
        
        // Verify the scope contains the device public key
        final scopeName = authInfo.scopes.first.name;
        expect(scopeName, equals('device:$devicePublicKeyHex'));
      });

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

        // Create multiple devices
        final deviceKeys = <String>[];
        for (var i = 0; i < 3; i++) {
          final deviceKeyPair = await algorithm.newKeyPair();
          final devicePublicKey = await deviceKeyPair.extractPublicKey();
          final devicePublicKeyHex = CryptoUtils.bytesToHex(
            Uint8List.fromList(devicePublicKey.bytes),
          );

          await endpoints.device.registerDevice(
            sessionBuilder,
            account.id!,
            devicePublicKeyHex,
            'device_${i}_encrypted_data_key',
            'Test Device $i',
          );

          deviceKeys.add(devicePublicKeyHex);
        }

        // Test that each device can authenticate independently
        for (var i = 0; i < deviceKeys.length; i++) {
          final testSession = sessionBuilder.build();
          final authInfo = await AnonAccredAuthHandler.handleAuthentication(
            testSession,
            deviceKeys[i],
          );

          expect(authInfo, isNotNull, reason: 'Device $i should authenticate');
          expect(authInfo!.authId, equals(deviceKeys[i]));
          expect(authInfo.scopes.first.name, equals('device:${deviceKeys[i]}'));
        }
      });

      test('authentication handler error handling with database exceptions', () async {
        final testSession = sessionBuilder.build();
        
        // Test with malformed but valid-length key that might cause database issues
        const malformedKey = 'gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        
        // Should handle gracefully and return null
        final authInfo = await AnonAccredAuthHandler.handleAuthentication(
          testSession,
          malformedKey,
        );
        
        expect(authInfo, isNull);
      });
    });

    group('getDevicePublicKey Helper Function Tests', () {
      test('extracts device key from authenticated session', () async {
        // Create test data
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

        await endpoints.device.registerDevice(
          sessionBuilder,
          account.id!,
          devicePublicKeyHex,
          'device_encrypted_data_key',
          'Test Device for Key Extraction',
        );

        // Authenticate and get AuthenticationInfo
        final testSession = sessionBuilder.build();
        final authInfo = await AnonAccredAuthHandler.handleAuthentication(
          testSession,
          devicePublicKeyHex,
        );

        // Test getDevicePublicKey with real AuthenticationInfo
        final mockSession = _MockSession();
        mockSession.authenticated = authInfo;
        
        final extractedKey = AnonAccredAuthHandler.getDevicePublicKey(mockSession);
        expect(extractedKey, equals(devicePublicKeyHex));
      });

      test('returns empty string for unauthenticated session', () {
        final mockSession = _MockSession();
        // No authenticated info set
        
        final extractedKey = AnonAccredAuthHandler.getDevicePublicKey(mockSession);
        expect(extractedKey, equals(''));
      });

      test('returns empty string for session without device scope', () {
        final mockSession = _MockSession();
        mockSession.authenticated = AuthenticationInfo(
          '123',
          {const Scope('other:scope')}, // No device scope
          authId: 'test123',
        );
        
        final extractedKey = AnonAccredAuthHandler.getDevicePublicKey(mockSession);
        expect(extractedKey, equals(''));
      });

      test('handles multiple scopes correctly', () {
        final mockSession = _MockSession();
        const deviceKey = 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890';
        
        mockSession.authenticated = AuthenticationInfo(
          '123',
          {
            const Scope('other:scope'),
            const Scope('device:$deviceKey'),
            const Scope('another:scope'),
          },
          authId: deviceKey,
        );
        
        final extractedKey = AnonAccredAuthHandler.getDevicePublicKey(mockSession);
        expect(extractedKey, equals(deviceKey));
      });
    });
  });
}

// Enhanced mock session for testing
class _MockSession implements Session {
  @override
  AuthenticationInfo? authenticated;
  
  final List<String> loggedMessages = [];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #log) {
      final message = invocation.positionalArguments[0] as String;
      loggedMessages.add(message);
      return null;
    }
    return null;
  }
}