import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../integration/test_tools/auth_test_helper.dart';
import '../integration/test_tools/serverpod_test_tools.dart';
import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/test_account_helper.dart';

void main() {
  withServerpod('Edge Case Handling Tests', (sessionBuilder, endpoints) {
    group('Device Registration Edge Cases', () {
      test('registerDevice - should reject empty public subkey', () async {
        // Use real keypair so PoW signature verification passes
        final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

        final testAccount = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          encryptedDataKey: 'encrypted_test_data_key',
          ultimatePublicKey: ultimatePubKey,
        );

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
            deviceSigningPublicKeyHex: '', // Empty public subkey
            encryptedDataKey: 'encrypted_data_key',
            label: 'Test Device',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('registerDevice - should reject invalid public subkey format', () async {
        // Use real keypair so PoW signature verification passes
        final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

        final testAccount = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          encryptedDataKey: 'encrypted_test_data_key_2',
          ultimatePublicKey: ultimatePubKey,
        );

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
            deviceSigningPublicKeyHex: 'invalid_key_format', // Invalid format
            encryptedDataKey: 'encrypted_data_key',
            label: 'Test Device',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });
    });

    group('Device Authentication Edge Cases', () {
      test('authenticateDevice - should fail without authentication', () async {
        const challenge = 'test_challenge_12345';
        final signature = AuthTestHelper.generateValidSignature();

        // DeviceManagementEndpoint requires login — Serverpod enforces this
        // at the framework level before endpoint code runs.
        expect(
          () => endpoints.deviceManagement.authenticateDevice(
            sessionBuilder,
            challenge,
            signature,
          ),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });

      test('authenticateDevice - should fail with empty challenge', () async {
        // Unauthenticated — Serverpod rejects before endpoint code runs.
        expect(
          () => endpoints.deviceManagement.authenticateDevice(
            sessionBuilder,
            '', // Empty challenge
            AuthTestHelper.generateValidSignature(),
          ),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });

      test('authenticateDevice - should fail with empty signature', () async {
        // Unauthenticated — Serverpod rejects before endpoint code runs.
        expect(
          () => endpoints.deviceManagement.authenticateDevice(
            sessionBuilder,
            'test_challenge',
            '', // Empty signature
          ),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });
    });

    group('Device Revocation Edge Cases', () {
      test('revokeDevice - should fail without authentication', () async {
        expect(
          () => endpoints.deviceManagement.revokeDevice(
            sessionBuilder,
            123, // Any device ID
          ),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });

      test('revokeDevice - should fail with invalid device ID', () async {
        expect(
          () => endpoints.deviceManagement.revokeDevice(
            sessionBuilder,
            -1, // Invalid device ID
          ),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });
    });

    group('Device Listing Edge Cases', () {
      test('listDevices - should fail without authentication', () async {
        expect(
          () => endpoints.deviceManagement.listDevices(sessionBuilder),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });
    });
  });
}
