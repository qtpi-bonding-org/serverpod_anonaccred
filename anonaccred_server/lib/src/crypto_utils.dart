import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:webcrypto/webcrypto.dart';
import 'exception_factory.dart';

/// Cryptographic utilities for ECDSA P-256 signature verification.
///
/// This class provides server-side cryptographic operations while maintaining strict
/// privacy-by-design principles:
/// - Only handles public keys and signature verification
/// - Never generates, stores, or processes private keys
/// - All operations are stateless and side-effect free
class CryptoUtils {
  // ═══════════════════════════════════════════════════════════════════════════
  // ECDSA P-256 Validation
  // ═══════════════════════════════════════════════════════════════════════════

  /// Validates that a string represents a valid ECDSA P-256 public key format.
  ///
  /// ECDSA P-256 public keys can be:
  /// - 128 hex chars (64 bytes): raw x||y coordinates
  /// - 130 hex chars (65 bytes): uncompressed format with 04 prefix
  ///
  /// Returns true if the key format is valid, false otherwise.
  static bool isValidPublicKey(String publicKey) {
    // Accept both raw (128 hex) and uncompressed with prefix (130 hex)
    if (publicKey.length != 128 && publicKey.length != 130) {
      return false;
    }

    // Check if all characters are valid hexadecimal
    final hexPattern = RegExp(r'^[0-9a-fA-F]+$');
    if (!hexPattern.hasMatch(publicKey)) {
      return false;
    }

    // If 130 chars, must start with '04' (uncompressed point indicator)
    if (publicKey.length == 130 && !publicKey.startsWith('04')) {
      return false;
    }

    return true;
  }

  /// Validates ECDSA P-256 signature format.
  ///
  /// ECDSA P-256 signatures are 64 bytes (r || s) = 128 hex chars.
  ///
  /// Returns true if the signature format is valid, false otherwise.
  static bool isValidSignature(String signature) {
    if (signature.length != 128) {
      return false;
    }

    final hexPattern = RegExp(r'^[0-9a-fA-F]+$');
    return hexPattern.hasMatch(signature);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ECDSA P-256 Signature Verification
  // ═══════════════════════════════════════════════════════════════════════════

  /// Verifies an ECDSA P-256 signature against a message and public key.
  ///
  /// Uses the cryptography library for secure ECDSA signature verification.
  ///
  /// Parameters:
  /// - [message]: The original message that was signed
  /// - [signature]: The ECDSA signature as a hex string (128 chars)
  /// - [publicKey]: The ECDSA P-256 public key as a hex string (128 or 130 chars)
  ///
  /// Returns true if the signature is valid for the given message and public key.
  static Future<bool> verifySignature({
    required String message,
    required String signature,
    required String publicKey,
  }) async {
    // Validate input formats
    if (!isValidPublicKey(publicKey)) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.cryptoInvalidPublicKey,
        message: 'Invalid ECDSA P-256 public key format',
        operation: 'verifySignature',
        details: {
          'publicKeyLength': publicKey.length.toString(),
          'expectedLength': '128 or 130',
        },
      );
    }

    if (!isValidSignature(signature)) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.cryptoInvalidSignature,
        message: 'Invalid ECDSA signature format',
        operation: 'verifySignature',
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
        operation: 'verifySignature',
        details: {'messageLength': '0'},
      );
    }

    try {
      final messageBytes = utf8.encode(message);
      final signatureBytes = hexToBytes(signature);
      
      // Normalize public key to raw format (remove 04 prefix if present)
      String normalizedKey = publicKey;
      if (publicKey.length == 130 && publicKey.startsWith('04')) {
        normalizedKey = publicKey.substring(2);
      }
      final publicKeyBytes = hexToBytes(normalizedKey);

      // webcrypto.dart expects X9.62 format: 0x04 + x + y
      final x9_62_key = Uint8List.fromList([0x04, ...publicKeyBytes]);
      
      // Import public key using webcrypto.dart
      final ecdsaPublicKey = await EcdsaPublicKey.importRawKey(
        x9_62_key,
        EllipticCurve.p256,
      );

      // Perform ECDSA verification with SHA-256
      return await ecdsaPublicKey.verifyBytes(
        signatureBytes,
        messageBytes,
        Hash.sha256,
      );
    } on Exception catch (e) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.cryptoVerificationFailed,
        message: 'ECDSA verification failed: ${e.toString()}',
        operation: 'verifySignature',
        details: {'webCryptoError': e.toString()},
      );
    } catch (e) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.cryptoVerificationFailed,
        message: 'Cryptographic verification failed',
        operation: 'verifySignature',
        details: {'error': e.toString()},
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Utility Methods
  // ═══════════════════════════════════════════════════════════════════════════

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
      for (var i = 0; i < hex.length; i += 2) {
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
  static String bytesToHex(Uint8List bytes) =>
      bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

  /// Generates a cryptographically secure challenge string for authentication.
  ///
  /// Creates a random challenge that can be signed by the client
  /// to prove ownership of a private key. The challenge includes a timestamp
  /// for expiration validation.
  ///
  /// Returns a hex-encoded challenge string with embedded timestamp.
  static String generateChallenge() {
    final random = Random.secure();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Create challenge with timestamp prefix (8 bytes) + random data (24 bytes)
    final timestampBytes = Uint8List(8);
    ByteData.view(timestampBytes.buffer).setUint64(0, timestamp);

    final randomBytes = Uint8List.fromList(
      List.generate(24, (_) => random.nextInt(256)),
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
  /// Returns true if the challenge is still valid, false if expired.
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
      final challengeTimestamp = timestampView.getUint64(0);

      final now = DateTime.now().millisecondsSinceEpoch;
      const challengeValidityDuration = 5 * 60 * 1000; // 5 minutes

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
