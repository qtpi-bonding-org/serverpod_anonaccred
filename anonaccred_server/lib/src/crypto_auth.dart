import 'dart:typed_data';
import 'crypto_utils.dart';
import 'exception_factory.dart';
import 'generated/protocol.dart';
import 'error_classification.dart';



/// Factory methods for creating AuthenticationResult instances
class AuthenticationResultFactory {
  /// Create a successful authentication result
  static AuthenticationResult success({
    int? accountId,
    int? deviceId,
    Map<String, String>? details,
  }) {
    return AuthenticationResult(
      success: true,
      accountId: accountId,
      deviceId: deviceId,
      details: details,
    );
  }

  /// Create a failed authentication result
  static AuthenticationResult failure({
    required String errorCode,
    required String errorMessage,
    Map<String, String>? details,
  }) {
    return AuthenticationResult(
      success: false,
      errorCode: errorCode,
      errorMessage: errorMessage,
      details: details,
    );
  }
}

/// Cryptographic authentication core for Ed25519 operations
/// 
/// This class provides high-level authentication operations using Ed25519
/// cryptography while maintaining strict privacy-by-design principles:
/// - Only handles public keys and signature verification
/// - Never generates, stores, or processes private keys
/// - All operations are stateless and side-effect free
class CryptoAuth {
  /// Verify Ed25519 signature with public key and data
  /// 
  /// Parameters:
  /// - [publicKeyHex]: Ed25519 public key as hex string (64 chars)
  /// - [data]: The original data that was signed
  /// - [signatureHex]: Ed25519 signature as hex string (128 chars)
  /// 
  /// Returns true if the signature is valid for the given data and public key.
  /// 
  /// Throws AuthenticationException if any parameter has invalid format.
  static Future<bool> verifySignature(
    String publicKeyHex,
    Uint8List data,
    String signatureHex,
  ) async {
    // Convert data to string for CryptoUtils compatibility
    final message = String.fromCharCodes(data);
    
    return await CryptoUtils.verifyEd25519Signature(
      message: message,
      signature: signatureHex,
      publicKey: publicKeyHex,
    );
  }

  /// Validate Ed25519 public key format (32 bytes hex)
  /// 
  /// Returns true if the key format is valid, false otherwise.
  static bool isValidPublicKey(String publicKeyHex) {
    return CryptoUtils.isValidEd25519PublicKey(publicKeyHex);
  }

  /// Generate cryptographically secure challenge
  /// 
  /// Returns a hex-encoded random challenge string for authentication.
  static String generateChallenge() {
    return CryptoUtils.generateChallenge();
  }

  /// Verify challenge response signature
  /// 
  /// This is the core challenge-response authentication method.
  /// 
  /// Parameters:
  /// - [publicKeyHex]: Ed25519 public key as hex string (64 chars)
  /// - [challenge]: The challenge string that was signed
  /// - [signatureHex]: Ed25519 signature of the challenge (128 chars)
  /// 
  /// Returns AuthenticationResult with success/failure information.
  static Future<AuthenticationResult> verifyChallengeResponse(
    String publicKeyHex,
    String challenge,
    String signatureHex,
  ) async {
    try {
      // Validate inputs first
      if (!isValidPublicKey(publicKeyHex)) {
        return AuthenticationResultFactory.failure(
          errorCode: AnonAccredErrorCodes.cryptoInvalidPublicKey,
          errorMessage: 'Invalid Ed25519 public key format',
          details: {
            'publicKeyLength': publicKeyHex.length.toString(),
            'expectedLength': '64',
          },
        );
      }

      if (!CryptoUtils.isValidEd25519Signature(signatureHex)) {
        return AuthenticationResultFactory.failure(
          errorCode: AnonAccredErrorCodes.cryptoInvalidSignature,
          errorMessage: 'Invalid Ed25519 signature format',
          details: {
            'signatureLength': signatureHex.length.toString(),
            'expectedLength': '128',
          },
        );
      }

      if (challenge.isEmpty) {
        return AuthenticationResultFactory.failure(
          errorCode: AnonAccredErrorCodes.cryptoInvalidMessage,
          errorMessage: 'Challenge cannot be empty',
          details: {'challengeLength': '0'},
        );
      }

      // Validate challenge expiration
      try {
        if (!CryptoUtils.isChallengeValid(challenge)) {
          return AuthenticationResultFactory.failure(
            errorCode: AnonAccredErrorCodes.authChallengeExpired,
            errorMessage: 'Authentication challenge has expired',
            details: {
              'challenge': challenge,
              'validityDuration': '5 minutes',
            },
          );
        }
      } on AuthenticationException catch (e) {
        // Challenge format validation failed
        return AuthenticationResultFactory.failure(
          errorCode: e.code,
          errorMessage: e.message,
          details: e.details,
        );
      }

      // Perform signature verification
      final isValid = await CryptoUtils.verifyEd25519Signature(
        message: challenge,
        signature: signatureHex,
        publicKey: publicKeyHex,
      );

      if (isValid) {
        return AuthenticationResultFactory.success(
          details: {
            'publicKey': publicKeyHex,
            'challengeLength': challenge.length.toString(),
          },
        );
      } else {
        return AuthenticationResultFactory.failure(
          errorCode: AnonAccredErrorCodes.authInvalidSignature,
          errorMessage: 'Signature verification failed',
          details: {
            'publicKey': publicKeyHex,
            'challengeLength': challenge.length.toString(),
          },
        );
      }
    } on AuthenticationException {
      // Re-throw authentication exceptions as-is
      rethrow;
    } catch (e) {
      // Wrap unexpected errors in authentication result
      return AuthenticationResultFactory.failure(
        errorCode: AnonAccredErrorCodes.cryptoVerificationFailed,
        errorMessage: 'Cryptographic verification failed: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }

  /// Verify signature with string message (convenience method)
  /// 
  /// Parameters:
  /// - [publicKeyHex]: Ed25519 public key as hex string (64 chars)
  /// - [message]: The original message that was signed
  /// - [signatureHex]: Ed25519 signature as hex string (128 chars)
  /// 
  /// Returns true if the signature is valid for the given message and public key.
  static Future<bool> verifyMessageSignature(
    String publicKeyHex,
    String message,
    String signatureHex,
  ) async {
    return await CryptoUtils.verifyEd25519Signature(
      message: message,
      signature: signatureHex,
      publicKey: publicKeyHex,
    );
  }
}