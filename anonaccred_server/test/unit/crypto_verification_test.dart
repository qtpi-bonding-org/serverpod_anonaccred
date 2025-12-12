import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:cryptography/cryptography.dart';
import '../../lib/src/crypto_utils.dart';
import '../../lib/src/generated/protocol.dart';

void main() {
  group('CryptoUtils Verification Tests', () {
    test('challenge generation produces unique values', () {
      // Generate multiple challenges
      final challenges = <String>{};
      for (int i = 0; i < 10; i++) {
        final challenge = CryptoUtils.generateChallenge();
        
        // Each challenge should be 64 hex characters (32 bytes)
        expect(challenge.length, equals(64));
        
        // Each challenge should be unique
        expect(challenges.contains(challenge), isFalse);
        challenges.add(challenge);
        
        // Should be valid hex
        expect(RegExp(r'^[0-9a-fA-F]+$').hasMatch(challenge), isTrue);
      }
    });

    test('Ed25519 signature verification with real cryptography', () async {
      // Generate a real Ed25519 key pair for testing
      final algorithm = Ed25519();
      final keyPair = await algorithm.newKeyPair();
      
      // Get the public key bytes
      final publicKey = await keyPair.extractPublicKey();
      final publicKeyBytes = publicKey.bytes;
      final publicKeyHex = CryptoUtils.bytesToHex(Uint8List.fromList(publicKeyBytes));
      
      // Create a test message
      const message = 'test message for signature verification';
      final messageBytes = utf8.encode(message);
      
      // Sign the message
      final signature = await algorithm.sign(messageBytes, keyPair: keyPair);
      final signatureHex = CryptoUtils.bytesToHex(Uint8List.fromList(signature.bytes));
      
      // Verify the signature using our utility
      final isValid = await CryptoUtils.verifyEd25519Signature(
        message: message,
        signature: signatureHex,
        publicKey: publicKeyHex,
      );
      
      expect(isValid, isTrue);
    });

    test('Ed25519 signature verification rejects invalid signatures', () async {
      // Generate a real Ed25519 key pair for testing
      final algorithm = Ed25519();
      final keyPair = await algorithm.newKeyPair();
      
      // Get the public key bytes
      final publicKey = await keyPair.extractPublicKey();
      final publicKeyBytes = publicKey.bytes;
      final publicKeyHex = CryptoUtils.bytesToHex(Uint8List.fromList(publicKeyBytes));
      
      // Create a test message
      const message = 'test message for signature verification';
      
      // Create an invalid signature (all zeros)
      final invalidSignature = '0' * 128;
      
      // Verify the invalid signature
      final isValid = await CryptoUtils.verifyEd25519Signature(
        message: message,
        signature: invalidSignature,
        publicKey: publicKeyHex,
      );
      
      expect(isValid, isFalse);
    });

    test('public key validation works correctly', () {
      // Valid key (64 hex characters)
      final validKey = 'a' * 64;
      expect(CryptoUtils.isValidEd25519PublicKey(validKey), isTrue);
      
      // Invalid length
      expect(CryptoUtils.isValidEd25519PublicKey('short'), isFalse);
      expect(CryptoUtils.isValidEd25519PublicKey(''), isFalse);
      
      // Invalid hex characters
      final invalidHex = 'g' * 64;
      expect(CryptoUtils.isValidEd25519PublicKey(invalidHex), isFalse);
      
      // Mixed case should work
      final mixedCase = 'A1b2C3d4' * 8; // 64 characters
      expect(CryptoUtils.isValidEd25519PublicKey(mixedCase), isTrue);
    });

    test('signature format validation works correctly', () {
      // Valid signature (128 hex characters)
      final validSignature = 'a' * 128;
      expect(CryptoUtils.isValidEd25519Signature(validSignature), isTrue);
      
      // Invalid length
      expect(CryptoUtils.isValidEd25519Signature('short'), isFalse);
      expect(CryptoUtils.isValidEd25519Signature(''), isFalse);
      
      // Invalid hex characters
      final invalidHex = 'g' * 128;
      expect(CryptoUtils.isValidEd25519Signature(invalidHex), isFalse);
      
      // Mixed case should work
      final mixedCase = 'A1b2C3d4' * 16; // 128 characters
      expect(CryptoUtils.isValidEd25519Signature(mixedCase), isTrue);
    });

    test('hex conversion utilities work correctly', () {
      // Test hex to bytes conversion
      final hexString = 'deadbeef';
      final bytes = CryptoUtils.hexToBytes(hexString);
      expect(bytes, equals([0xde, 0xad, 0xbe, 0xef]));
      
      // Test bytes to hex conversion
      final testBytes = Uint8List.fromList([0xde, 0xad, 0xbe, 0xef]);
      final hex = CryptoUtils.bytesToHex(testBytes);
      expect(hex, equals('deadbeef'));
      
      // Round trip should preserve data
      final originalHex = 'abcdef123456';
      final roundTripHex = CryptoUtils.bytesToHex(CryptoUtils.hexToBytes(originalHex));
      expect(roundTripHex, equals(originalHex));
    });

    test('error handling for invalid inputs', () async {
      // Invalid public key format should throw
      expect(
        () async => await CryptoUtils.verifyEd25519Signature(
          message: 'test',
          signature: 'a' * 128,
          publicKey: 'invalid',
        ),
        throwsA(isA<AuthenticationException>()),
      );
      
      // Invalid signature format should throw
      expect(
        () async => await CryptoUtils.verifyEd25519Signature(
          message: 'test',
          signature: 'invalid',
          publicKey: 'a' * 64,
        ),
        throwsA(isA<AuthenticationException>()),
      );
      
      // Empty message should throw
      expect(
        () async => await CryptoUtils.verifyEd25519Signature(
          message: '',
          signature: 'a' * 128,
          publicKey: 'a' * 64,
        ),
        throwsA(isA<AuthenticationException>()),
      );
      
      // Invalid hex string should throw
      expect(
        () => CryptoUtils.hexToBytes('invalid_hex'),
        throwsA(isA<AuthenticationException>()),
      );
      
      // Odd length hex string should throw
      expect(
        () => CryptoUtils.hexToBytes('abc'),
        throwsA(isA<AuthenticationException>()),
      );
    });
  });
}