import 'dart:typed_data';
import 'crypto_utils.dart';
import 'exception_factory.dart';
import 'generated/protocol.dart';

/// Factory methods for creating AuthenticationResult instances
class AuthenticationResultFactory {
  /// Create a successful authentication result
  static AuthenticationResult success({
    int? deviceId,
    Map<String, String>? details,
  }) => AuthenticationResult(
    success: true,
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
  static Future<bool> verifySignature(
    String publicKeyHex,
    Uint8List data,
    String signatureHex,
  ) async {
    final message = String.fromCharCodes(data);

    return CryptoUtils.verifySignature(
      message: message,
      signature: signatureHex,
      publicKey: publicKeyHex,
    );
  }

  /// Validate ECDSA P-256 public key format.
  static bool isValidPublicKey(String publicKeyHex) =>
      CryptoUtils.isValidPublicKey(publicKeyHex);

  /// Generate cryptographically secure challenge
  static String generateChallenge() => CryptoUtils.generateChallenge();

  /// Verify ECDSA P-256 challenge response signature.
  static Future<AuthenticationResult> verifyChallengeResponse(
    String publicKeyHex,
    String challenge,
    String signatureHex, {
    bool skipTimestampValidation = false,
  }) async {
    try {
      if (!isValidPublicKey(publicKeyHex)) {
        return AuthenticationResultFactory.failure(
          errorCode: AnonAccountErrorCodes.cryptoInvalidPublicKey,
          errorMessage: 'Invalid ECDSA P-256 public key format',
          details: {
            'publicKeyLength': publicKeyHex.length.toString(),
            'expectedLength': '128 or 130',
          },
        );
      }

      if (!CryptoUtils.isValidSignature(signatureHex)) {
        return AuthenticationResultFactory.failure(
          errorCode: AnonAccountErrorCodes.cryptoInvalidSignature,
          errorMessage: 'Invalid signature format',
          details: {
            'signatureLength': signatureHex.length.toString(),
            'expectedLength': '128',
          },
        );
      }

      if (challenge.isEmpty) {
        return AuthenticationResultFactory.failure(
          errorCode: AnonAccountErrorCodes.cryptoInvalidMessage,
          errorMessage: 'Challenge cannot be empty',
          details: {'challengeLength': '0'},
        );
      }

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
          errorCode: AnonAccountErrorCodes.authInvalidSignature,
          errorMessage: 'Signature verification failed',
          details: {
            'publicKey': publicKeyHex,
            'challengeLength': challenge.length.toString(),
          },
        );
      }
    } on AuthenticationException {
      rethrow;
    } on Exception catch (e) {
      return AuthenticationResultFactory.failure(
        errorCode: AnonAccountErrorCodes.cryptoVerificationFailed,
        errorMessage: 'Cryptographic verification failed: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }

  /// Verify ECDSA P-256 signature with string message.
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
