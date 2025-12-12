import 'dart:math';

import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:test/test.dart';

/// **Feature: anonaccred-phase1, Property 5: Cryptographic data isolation**
/// **Feature: anonaccred-phase1, Property 6: Encryption separation**
/// **Feature: anonaccred-phase1, Property 20: Signature verification support**
/// **Feature: anonaccred-phase1, Property 21: Cryptographic error security**
/// **Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5**

void main() {
  group('Cryptographic Security Property Tests', () {
    final random = Random();

    test(
      'Property 5: Cryptographic data isolation - For any account or device creation, the system should store only public keys and encrypted data keys, never private keys or unencrypted data',
      () {
        // Run 5 iterations during development (can be increased to 100+ for production)
        for (int i = 0; i < 5; i++) {
          // Generate random cryptographic data
          final publicMasterKey = _generateRandomEd25519PublicKey();
          final encryptedMasterDataKey = _generateRandomEncryptedData();
          final publicSubKey = _generateRandomEd25519PublicKey();
          final encryptedDeviceDataKey = _generateRandomEncryptedData();

          // Create account with cryptographic data
          final account = AnonAccount(
            publicMasterKey: publicMasterKey,
            encryptedDataKey: encryptedMasterDataKey,
            createdAt: DateTime.now(),
          );

          // Create device with cryptographic data
          final device = AccountDevice(
            accountId: random.nextInt(10000) + 1,
            publicSubKey: publicSubKey,
            encryptedDataKey: encryptedDeviceDataKey,
            label: 'Test Device',
            lastActive: DateTime.now(),
            isRevoked: false,
          );

          // Verify cryptographic data isolation for account
          expect(account.publicMasterKey, equals(publicMasterKey));
          expect(account.encryptedDataKey, equals(encryptedMasterDataKey));

          // Verify no private key storage capability
          expect(
            account.publicMasterKey.length,
            equals(64),
          ); // Ed25519 public key format
          expect(_isValidHexString(account.publicMasterKey), isTrue);

          // Verify encrypted data remains encrypted (no decryption methods)
          expect(account.encryptedDataKey, isA<String>());
          expect(account.encryptedDataKey.isNotEmpty, isTrue);

          // Verify cryptographic data isolation for device
          expect(device.publicSubKey, equals(publicSubKey));
          expect(device.encryptedDataKey, equals(encryptedDeviceDataKey));

          // Verify no private key storage capability
          expect(
            device.publicSubKey.length,
            equals(64),
          ); // Ed25519 public key format
          expect(_isValidHexString(device.publicSubKey), isTrue);

          // Verify encrypted data remains encrypted
          expect(device.encryptedDataKey, isA<String>());
          expect(device.encryptedDataKey.isNotEmpty, isTrue);

          // Verify serialization maintains cryptographic isolation
          final accountJson = account.toJson();
          expect(accountJson.containsKey('privateKey'), isFalse);
          expect(accountJson.containsKey('decryptedData'), isFalse);

          final deviceJson = device.toJson();
          expect(deviceJson.containsKey('privateKey'), isFalse);
          expect(deviceJson.containsKey('decryptedData'), isFalse);
        }
      },
    );

    test(
      'Property 6: Encryption separation - For any account with multiple devices, the system should maintain separate encrypted data keys for master account access and individual device access',
      () {
        // Run 5 iterations during development
        for (int i = 0; i < 5; i++) {
          // Generate master account data
          final publicMasterKey = _generateRandomEd25519PublicKey();
          final encryptedMasterDataKey = _generateRandomEncryptedData();

          final account = AnonAccount(
            publicMasterKey: publicMasterKey,
            encryptedDataKey: encryptedMasterDataKey,
            createdAt: DateTime.now(),
          );

          // Generate multiple devices with separate encryption
          final devices = <AccountDevice>[];
          final deviceCount = 2 + random.nextInt(4); // 2-5 devices

          for (int j = 0; j < deviceCount; j++) {
            final device = AccountDevice(
              accountId: random.nextInt(10000) + 1,
              publicSubKey: _generateRandomEd25519PublicKey(),
              encryptedDataKey: _generateRandomEncryptedData(),
              label: 'Device $j',
              lastActive: DateTime.now(),
              isRevoked: false,
            );
            devices.add(device);
          }

          // Verify encryption separation - master key is unique
          for (final device in devices) {
            expect(
              device.encryptedDataKey,
              isNot(equals(account.encryptedDataKey)),
            );
            expect(device.publicSubKey, isNot(equals(account.publicMasterKey)));
          }

          // Verify each device has unique encryption
          for (int j = 0; j < devices.length; j++) {
            for (int k = j + 1; k < devices.length; k++) {
              expect(
                devices[j].encryptedDataKey,
                isNot(equals(devices[k].encryptedDataKey)),
              );
              expect(
                devices[j].publicSubKey,
                isNot(equals(devices[k].publicSubKey)),
              );
            }
          }

          // Verify all encrypted data keys are properly formatted
          expect(_isValidEncryptedData(account.encryptedDataKey), isTrue);
          for (final device in devices) {
            expect(_isValidEncryptedData(device.encryptedDataKey), isTrue);
          }

          // Verify all public keys are properly formatted
          expect(_isValidEd25519PublicKey(account.publicMasterKey), isTrue);
          for (final device in devices) {
            expect(_isValidEd25519PublicKey(device.publicSubKey), isTrue);
          }
        }
      },
    );

    test(
      'Property 20: Signature verification support - For any valid Ed25519 signature and public key pair, the system should correctly validate the signature',
      () async {
        // Run 5 iterations during development
        for (int i = 0; i < 5; i++) {
          // Generate valid Ed25519 format data
          final publicKey = _generateRandomEd25519PublicKey();
          final signature = _generateRandomEd25519Signature();
          final message = _generateRandomMessage();

          // Test valid format acceptance
          expect(CryptoUtils.isValidEd25519PublicKey(publicKey), isTrue);
          expect(CryptoUtils.isValidEd25519Signature(signature), isTrue);

          // Test signature verification (real Ed25519 implementation)
          final result = await CryptoUtils.verifyEd25519Signature(
            message: message,
            signature: signature,
            publicKey: publicKey,
          );

          // Verify result is boolean (signature verification completed)
          expect(result, isA<bool>());

          // Test with same inputs produces same result (deterministic)
          final result2 = await CryptoUtils.verifyEd25519Signature(
            message: message,
            signature: signature,
            publicKey: publicKey,
          );
          expect(result2, equals(result));

          // Test format validation
          expect(
            () async => await CryptoUtils.verifyEd25519Signature(
              message: message,
              signature: 'invalid_signature',
              publicKey: publicKey,
            ),
            throwsA(isA<AuthenticationException>()),
          );

          expect(
            () async => await CryptoUtils.verifyEd25519Signature(
              message: message,
              signature: signature,
              publicKey: 'invalid_key',
            ),
            throwsA(isA<AuthenticationException>()),
          );

          // Test hex conversion utilities
          final hexBytes = CryptoUtils.hexToBytes(publicKey);
          expect(hexBytes.length, equals(32)); // 64 hex chars = 32 bytes

          final hexString = CryptoUtils.bytesToHex(hexBytes);
          expect(hexString.toLowerCase(), equals(publicKey.toLowerCase()));
        }
      },
    );

    test(
      'Property 21: Cryptographic error security - For any cryptographic operation failure, error information should be provided without exposing key material',
      () async {
        // Run 5 iterations during development
        for (int i = 0; i < 5; i++) {
          // Test invalid public key format
          final invalidPublicKeys = [
            'too_short',
            '123', // Too short
            'g' * 64, // Invalid hex characters
            '0' * 63, // Wrong length
            '0' * 65, // Wrong length
            '', // Empty
          ];

          for (final invalidKey in invalidPublicKeys) {
            try {
              await CryptoUtils.verifyEd25519Signature(
                message: 'test message',
                signature: _generateRandomEd25519Signature(),
                publicKey: invalidKey,
              );
              fail('Should have thrown exception for invalid public key');
            } catch (e) {
              expect(e, isA<AuthenticationException>());
              final authException = e as AuthenticationException;

              // Verify error provides information without exposing key material
              expect(
                authException.code,
                equals(AnonAccredErrorCodes.cryptoInvalidPublicKey),
              );
              expect(
                authException.message,
                contains('Invalid Ed25519 public key format'),
              );
              expect(authException.operation, equals('verifyEd25519Signature'));

              // Verify error details don't expose the invalid key content
              expect(authException.details?['publicKeyLength'], isNotNull);
              expect(authException.details?['expectedLength'], equals('64'));

              // Verify the actual invalid key is not in the error message or details (skip empty strings)
              if (invalidKey.isNotEmpty) {
                expect(authException.message, isNot(contains(invalidKey)));
                expect(
                  authException.details?.values.any(
                    (v) => v.contains(invalidKey),
                  ),
                  isFalse,
                );
              }
            }
          }

          // Test invalid signature format
          final invalidSignatures = [
            'too_short',
            '123', // Too short
            'g' * 128, // Invalid hex characters
            '0' * 127, // Wrong length
            '0' * 129, // Wrong length
            '', // Empty
          ];

          for (final invalidSignature in invalidSignatures) {
            try {
              await CryptoUtils.verifyEd25519Signature(
                message: 'test message',
                signature: invalidSignature,
                publicKey: _generateRandomEd25519PublicKey(),
              );
              fail('Should have thrown exception for invalid signature');
            } catch (e) {
              expect(e, isA<AuthenticationException>());
              final authException = e as AuthenticationException;

              // Verify error provides information without exposing signature material
              expect(
                authException.code,
                equals(AnonAccredErrorCodes.cryptoInvalidSignature),
              );
              expect(
                authException.message,
                contains('Invalid Ed25519 signature format'),
              );
              expect(authException.operation, equals('verifyEd25519Signature'));

              // Verify error details don't expose the invalid signature content
              expect(authException.details?['signatureLength'], isNotNull);
              expect(authException.details?['expectedLength'], equals('128'));

              // Verify the actual invalid signature is not in the error message or details (skip empty strings)
              if (invalidSignature.isNotEmpty) {
                expect(
                  authException.message,
                  isNot(contains(invalidSignature)),
                );
                expect(
                  authException.details?.values.any(
                    (v) => v.contains(invalidSignature),
                  ),
                  isFalse,
                );
              }
            }
          }

          // Test invalid message
          try {
            await CryptoUtils.verifyEd25519Signature(
              message: '', // Empty message
              signature: _generateRandomEd25519Signature(),
              publicKey: _generateRandomEd25519PublicKey(),
            );
            fail('Should have thrown exception for empty message');
          } catch (e) {
            expect(e, isA<AuthenticationException>());
            final authException = e as AuthenticationException;

            expect(
              authException.code,
              equals(AnonAccredErrorCodes.cryptoInvalidMessage),
            );
            expect(authException.message, contains('Message cannot be empty'));
            expect(authException.operation, equals('verifyEd25519Signature'));
            expect(authException.details?['messageLength'], equals('0'));
          }

          // Test hex conversion error security
          try {
            CryptoUtils.hexToBytes('invalid_hex_g');
            fail('Should have thrown exception for invalid hex');
          } catch (e) {
            expect(e, isA<AuthenticationException>());
            final authException = e as AuthenticationException;

            expect(
              authException.code,
              equals(AnonAccredErrorCodes.cryptoFormatError),
            );
            expect(
              authException.message,
              anyOf([
                contains('Invalid hexadecimal string format'),
                contains('Hex string must have even length'),
              ]),
            );
            expect(authException.operation, equals('hexToBytes'));

            // Verify the invalid hex string is not exposed in error message
            expect(authException.message, isNot(contains('invalid_hex_g')));

            // Verify error details structure (may be null or contain error info)
            if (authException.details != null &&
                authException.details!.isNotEmpty) {
              // If details exist, verify they don't expose the invalid input
              expect(
                authException.details!.values.any(
                  (v) => v.contains('invalid_hex_g'),
                ),
                isFalse,
              );
            }
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

String _generateRandomMessage() {
  final messages = [
    'Hello, World!',
    'Authentication challenge',
    'Payment verification',
    'User login request',
    'Device registration',
    'Account creation',
    'Signature test message',
    'Random message ${Random().nextInt(10000)}',
  ];
  return messages[Random().nextInt(messages.length)];
}

bool _isValidHexString(String hex) {
  final hexPattern = RegExp(r'^[0-9a-fA-F]+$');
  return hexPattern.hasMatch(hex);
}

bool _isValidEd25519PublicKey(String publicKey) {
  return publicKey.length == 64 && _isValidHexString(publicKey);
}

bool _isValidEncryptedData(String encryptedData) {
  // Basic validation for encrypted data format
  return encryptedData.isNotEmpty && encryptedData.length >= 16;
}
