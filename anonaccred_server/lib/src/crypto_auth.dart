import 'dart:typed_data';
import 'crypto_utils.dart';
import 'exception_factory.dart';
import 'generated/protocol.dart';

/// Factory methods for creating AuthenticationResult instances
class AuthenticationResultFactory {
  /// Create a successful authentication result
  static AuthenticationResult success({
    int? accountId,
    int? deviceId,
    Map<String, String>? details,
  }) => AuthenticationResult(
    success: true,
    accountId: accountId,
    deviceId: deviceId,
    details: details,
  );

  /// Create a failed authentication result
  static AuthenticationResult failure({
    required String errorCode,
    required String errorMessage,
    Map<String, String>? details,
  }) => AuthenticationResult(
    success: false,
    errorCode: errorCode,
    errorMessage: errorMessage,
    details: details,
  );
}

/// Cryptographic authentication core for ECDSA P-256 signature operations.
///
/// This class provides high-level authentication operations while maintaining 
/// strict privacy-by-design principles:
/// - Only handles public keys and signature verification
/// - Never generates, stores, or processes private keys
/// - All operations are stateless and side-effect free
class CryptoAuth {
  /// Verify ECDSA P-256 signature with public key and data.
  ///
  /// Parameters:
  /// - [publicKeyHex]: ECDSA P-256 public key as hex string (128-130 chars)
  /// - [data]: The original data that was signed
  /// - [signatureHex]: Signature as hex string (128 chars)
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

    return CryptoUtils.verifySignature(
      message: message,
      signature: signatureHex,
      publicKey: publicKeyHex,
    );
  }

  /// Validate ECDSA P-256 public key format.
  ///
  /// Returns true if the key format is valid (128-130 hex chars), false otherwise.
  static bool isValidPublicKey(String publicKeyHex) =>
      CryptoUtils.isValidPublicKey(publicKeyHex);

  /// Generate cryptographically secure challenge
  ///
  /// Returns a hex-encoded random challenge string for authentication.
  static String generateChallenge() => CryptoUtils.generateChallenge();

  /// Verify ECDSA P-256 challenge response signature.
  ///
  /// This is the core challenge-response authentication method.
  ///
  /// Parameters:
  /// - [publicKeyHex]: ECDSA P-256 public key as hex string (128-130 chars)
  /// - [challenge]: The challenge string that was signed
  /// - [signatureHex]: Signature of the challenge (128 hex chars)
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
          errorMessage: 'Invalid ECDSA P-256 public key format',
          details: {
            'publicKeyLength': publicKeyHex.length.toString(),
            'expectedLength': '128 or 130',
          },
        );
      }

      if (!CryptoUtils.isValidSignature(signatureHex)) {
        return AuthenticationResultFactory.failure(
          errorCode: AnonAccredErrorCodes.cryptoInvalidSignature,
          errorMessage: 'Invalid signature format',
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
            details: {'challenge': challenge, 'validityDuration': '5 minutes'},
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

      // Perform signature verification (auto-detects algorithm)
      final isValid = await CryptoUtils.verifySignature(
        message: challenge,
        signature: signatureHex,
        publicKey: publicKeyHex,
      );

      if (isValid) {
        return AuthenticationResultFactory.success(
          details: {
            'publicKey': publicKeyHex,
            'challengeLength': challenge.length.toString(),
            'algorithm': 'ECDSA-P256',
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
    } on Exception catch (e) {
      // Wrap unexpected errors in authentication result
      return AuthenticationResultFactory.failure(
        errorCode: AnonAccredErrorCodes.cryptoVerificationFailed,
        errorMessage: 'Cryptographic verification failed: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }

  /// Verify ECDSA P-256 signature with string message.
  ///
  /// Parameters:
  /// - [publicKeyHex]: ECDSA P-256 public key as hex string (128-130 chars)
  /// - [message]: The original message that was signed
  /// - [signatureHex]: Signature as hex string (128 chars)
  ///
  /// Returns true if the signature is valid for the given message and public key.
  static Future<bool> verifyMessageSignature(
    String publicKeyHex,
    String message,
    String signatureHex,
  ) => CryptoUtils.verifySignature(
    message: message,
    signature: signatureHex,
    publicKey: publicKeyHex,
  );
}
