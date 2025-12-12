import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'exception_factory.dart';

/// Cryptographic utilities for Ed25519 signature verification and public key validation.
/// 
/// This class provides server-side cryptographic operations while maintaining strict
/// privacy-by-design principles:
/// - Only handles public keys and signature verification
/// - Never generates, stores, or processes private keys
/// - All operations are stateless and side-effect free
class CryptoUtils {
  /// Validates that a string represents a valid Ed25519 public key format.
  /// 
  /// Ed25519 public keys must be exactly 64 hexadecimal characters (32 bytes).
  /// 
  /// Returns true if the key format is valid, false otherwise.
  /// This validation only checks format, not cryptographic validity.
  static bool isValidEd25519PublicKey(String publicKey) {
    if (publicKey.length != 64) {
      return false;
    }
    
    // Check if all characters are valid hexadecimal
    final hexPattern = RegExp(r'^[0-9a-fA-F]+$');
    return hexPattern.hasMatch(publicKey);
  }
  
  /// Converts a hexadecimal string to bytes.
  /// 
  /// Throws AuthenticationException if the string is not valid hexadecimal.
  static Uint8List hexToBytes(String hex) {
    if (hex.length % 2 != 0) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.cryptoFormatError,
        message: 'Hex string must have even length',
        operation: 'hexToBytes',
        details: {'hexLength': hex.length.toString()},
      );
    }
    
    try {
      final bytes = Uint8List(hex.length ~/ 2);
      for (int i = 0; i < hex.length; i += 2) {
        final hexByte = hex.substring(i, i + 2);
        bytes[i ~/ 2] = int.parse(hexByte, radix: 16);
      }
      return bytes;
    } catch (e) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.cryptoFormatError,
        message: 'Invalid hexadecimal string format',
        operation: 'hexToBytes',
        details: {'error': e.toString()},
      );
    }
  }
  
  /// Converts bytes to a hexadecimal string.
  static String bytesToHex(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
  
  /// Validates Ed25519 signature format.
  /// 
  /// Ed25519 signatures must be exactly 128 hexadecimal characters (64 bytes).
  /// 
  /// Returns true if the signature format is valid, false otherwise.
  static bool isValidEd25519Signature(String signature) {
    if (signature.length != 128) {
      return false;
    }
    
    // Check if all characters are valid hexadecimal
    final hexPattern = RegExp(r'^[0-9a-fA-F]+$');
    return hexPattern.hasMatch(signature);
  }
  
  /// Verifies an Ed25519 signature against a message and public key.
  /// 
  /// Uses the cryptography library for secure Ed25519 signature verification.
  /// 
  /// Parameters:
  /// - [message]: The original message that was signed
  /// - [signature]: The Ed25519 signature as a hex string (128 chars)
  /// - [publicKey]: The Ed25519 public key as a hex string (64 chars)
  /// 
  /// Returns true if the signature is valid for the given message and public key.
  /// 
  /// Throws AuthenticationException if any parameter has invalid format or verification fails.
  static Future<bool> verifyEd25519Signature({
    required String message,
    required String signature,
    required String publicKey,
  }) async {
    // Validate input formats with structured exceptions
    if (!isValidEd25519PublicKey(publicKey)) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.cryptoInvalidPublicKey,
        message: 'Invalid Ed25519 public key format',
        operation: 'verifyEd25519Signature',
        details: {
          'publicKeyLength': publicKey.length.toString(),
          'expectedLength': '64',
        },
      );
    }
    
    if (!isValidEd25519Signature(signature)) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.cryptoInvalidSignature,
        message: 'Invalid Ed25519 signature format',
        operation: 'verifyEd25519Signature',
        details: {
          'signatureLength': signature.length.toString(),
          'expectedLength': '128',
        },
      );
    }
    
    if (message.isEmpty) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.cryptoInvalidMessage,
        message: 'Message cannot be empty',
        operation: 'verifyEd25519Signature',
        details: {'messageLength': '0'},
      );
    }
    
    // Perform real Ed25519 signature verification using cryptography library
    try {
      final algorithm = Ed25519();
      
      final messageBytes = utf8.encode(message);
      final signatureBytes = hexToBytes(signature);
      final publicKeyBytes = hexToBytes(publicKey);
      
      // Create public key object
      final pubKey = SimplePublicKey(
        publicKeyBytes,
        type: KeyPairType.ed25519,
      );
      
      // Create signature object
      final sig = Signature(
        signatureBytes,
        publicKey: pubKey,
      );
      
      // Perform real Ed25519 verification
      return await algorithm.verify(
        messageBytes,
        signature: sig,
      );
      
    } on Exception catch (e) {
      // Handle cryptography library specific errors
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.cryptoVerificationFailed,
        message: 'Ed25519 verification failed: ${e.toString()}',
        operation: 'verifyEd25519Signature',
        details: {'cryptographyError': e.toString()},
      );
      
    } catch (e) {
      // Wrap any unexpected errors in structured exceptions
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.cryptoVerificationFailed,
        message: 'Cryptographic verification failed',
        operation: 'verifyEd25519Signature',
        details: {'error': e.toString()},
      );
    }
  }
  
  /// Generates a cryptographically secure challenge string for authentication purposes.
  /// 
  /// This creates a random challenge that can be signed by the client
  /// to prove ownership of a private key. The challenge includes a timestamp
  /// for expiration validation.
  /// 
  /// Returns a hex-encoded challenge string with embedded timestamp.
  static String generateChallenge() {
    final random = Random.secure(); // Cryptographically secure random number generator
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Create challenge with timestamp prefix (8 bytes) + random data (24 bytes)
    final timestampBytes = Uint8List(8);
    final timestampView = ByteData.view(timestampBytes.buffer);
    timestampView.setUint64(0, timestamp, Endian.big);
    
    final randomBytes = Uint8List.fromList(
      List.generate(24, (_) => random.nextInt(256))
    );
    
    // Combine timestamp and random data
    final challengeBytes = Uint8List.fromList([
      ...timestampBytes,
      ...randomBytes,
    ]);
    
    return bytesToHex(challengeBytes);
  }
  
  /// Validates that a challenge has not expired.
  /// 
  /// Challenges are valid for 5 minutes (300 seconds) from creation.
  /// 
  /// Parameters:
  /// - [challenge]: The challenge string to validate
  /// 
  /// Returns true if the challenge is still valid, false if expired.
  /// 
  /// Throws AuthenticationException if challenge format is invalid.
  static bool isChallengeValid(String challenge) {
    if (challenge.length != 64) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.cryptoFormatError,
        message: 'Invalid challenge format',
        operation: 'isChallengeValid',
        details: {
          'challengeLength': challenge.length.toString(),
          'expectedLength': '64',
        },
      );
    }
    
    try {
      // Extract timestamp from first 8 bytes (16 hex chars)
      final timestampHex = challenge.substring(0, 16);
      final timestampBytes = hexToBytes(timestampHex);
      final timestampView = ByteData.view(timestampBytes.buffer);
      final challengeTimestamp = timestampView.getUint64(0, Endian.big);
      
      final now = DateTime.now().millisecondsSinceEpoch;
      const challengeValidityDuration = 5 * 60 * 1000; // 5 minutes in milliseconds
      
      return (now - challengeTimestamp) <= challengeValidityDuration;
    } catch (e) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.cryptoFormatError,
        message: 'Failed to parse challenge timestamp',
        operation: 'isChallengeValid',
        details: {'error': e.toString()},
      );
    }
  }
}