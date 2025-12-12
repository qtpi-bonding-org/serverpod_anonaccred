import 'dart:math';

import 'package:test/test.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

/// **Feature: anonaccred-phase2, Property 6: Revocation enforcement**
/// **Validates: Requirements 3.5, 4.2**

void main() {
  withServerpod('Device Revocation Property Tests', (
    sessionBuilder,
    endpoints,
  ) {
    final random = Random();

    test(
      'Property 6: Revocation enforcement - For any device that has been revoked, all subsequent authentication attempts should fail with a revoked device error',
      () async {
        // Run 5 iterations during development (can be increased to 100+ for production)
        for (int i = 0; i < 5; i++) {
          // Generate random test data
          final accountPublicKey = _generateRandomEd25519PublicKey();
          final accountEncryptedDataKey = _generateRandomEncryptedData();
          final devicePublicSubKey = _generateRandomEd25519PublicKey();
          final deviceEncryptedDataKey = _generateRandomEncryptedData();
          final deviceLabel = 'Test Device ${random.nextInt(10000)}';

          // Create account
          final account = await endpoints.account.createAccount(
            sessionBuilder,
            accountPublicKey,
            accountEncryptedDataKey,
          );

          // Register device
          final device = await endpoints.device.registerDevice(
            sessionBuilder,
            account.id!,
            devicePublicSubKey,
            deviceEncryptedDataKey,
            deviceLabel,
          );

          // Verify device is initially not revoked and can authenticate
          expect(device.isRevoked, isFalse);

          // Generate challenge for authentication
          final challenge = await endpoints.device.generateAuthChallenge(
            sessionBuilder,
          );

          // Create a valid signature (for testing purposes, we'll use a random signature)
          // In real usage, this would be signed by the client's private key
          final signature = _generateRandomEd25519Signature();

          // Test authentication before revocation (may succeed or fail based on signature validity)
          final authResultBefore = await endpoints.device.authenticateDevice(
            sessionBuilder,
            devicePublicSubKey,
            challenge,
            signature,
          );

          // If authentication failed before revocation, it should be due to signature verification, not revocation
          if (!authResultBefore.success) {
            expect(
              authResultBefore.errorCode,
              isNot(equals('AUTH_DEVICE_REVOKED')),
            );
          }

          // Revoke the device
          final revocationResult = await endpoints.device.revokeDevice(
            sessionBuilder,
            account.id!,
            device.id!,
          );
          expect(revocationResult, isTrue);

          // Verify device appears as revoked in device listing
          final devices = await endpoints.device.listDevices(
            sessionBuilder,
            account.id!,
          );
          final revokedDevice = devices.firstWhere((d) => d.id == device.id);
          expect(revokedDevice.isRevoked, isTrue);

          // Test authentication after revocation - should ALWAYS fail with DEVICE_REVOKED
          final authResultAfter = await endpoints.device.authenticateDevice(
            sessionBuilder,
            devicePublicSubKey,
            challenge,
            signature,
          );

          // Property assertion: Revoked device authentication must fail with specific error
          expect(authResultAfter.success, isFalse);
          expect(authResultAfter.errorCode, equals('AUTH_DEVICE_REVOKED'));
          expect(authResultAfter.errorMessage, contains('revoked'));

          // Test with different challenges - revocation should still be enforced
          final newChallenge = await endpoints.device.generateAuthChallenge(
            sessionBuilder,
          );
          final newSignature = _generateRandomEd25519Signature();

          final authResultNewChallenge = await endpoints.device
              .authenticateDevice(
                sessionBuilder,
                devicePublicSubKey,
                newChallenge,
                newSignature,
              );

          expect(authResultNewChallenge.success, isFalse);
          expect(
            authResultNewChallenge.errorCode,
            equals('AUTH_DEVICE_REVOKED'),
          );

          // Verify revocation is persistent - multiple authentication attempts should all fail
          for (int j = 0; j < 3; j++) {
            final persistentChallenge = await endpoints.device
                .generateAuthChallenge(sessionBuilder);
            final persistentSignature = _generateRandomEd25519Signature();

            final persistentAuthResult = await endpoints.device
                .authenticateDevice(
                  sessionBuilder,
                  devicePublicSubKey,
                  persistentChallenge,
                  persistentSignature,
                );

            expect(persistentAuthResult.success, isFalse);
            expect(
              persistentAuthResult.errorCode,
              equals('AUTH_DEVICE_REVOKED'),
            );
          }
        }
      },
    );
  });
}

// Test data generators
String _generateRandomEd25519PublicKey() {
  // Generate a valid Ed25519 public key format (64 hex characters)
  final random = Random();
  const chars = '0123456789abcdef';
  return List.generate(
    64,
    (index) => chars[random.nextInt(chars.length)],
  ).join();
}

String _generateRandomEd25519Signature() {
  // Generate a valid Ed25519 signature format (128 hex characters)
  final random = Random();
  const chars = '0123456789abcdef';
  return List.generate(
    128,
    (index) => chars[random.nextInt(chars.length)],
  ).join();
}

String _generateRandomEncryptedData() {
  // Generate random encrypted data (base64-like string)
  final random = Random();
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  final length = 32 + random.nextInt(64); // 32-96 characters
  return List.generate(
    length,
    (index) => chars[random.nextInt(chars.length)],
  ).join();
}
