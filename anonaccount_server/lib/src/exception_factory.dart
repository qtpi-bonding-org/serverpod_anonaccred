import 'generated/protocol.dart';

/// Factory methods for creating AnonAccount exceptions with consistent structure
class AnonAccountExceptionFactory {
  /// Creates a base AnonAccount exception
  static AnonAccountException createException({
    required String code,
    required String message,
    Map<String, String>? details,
  }) => AnonAccountException(code: code, message: message, details: details);

  /// Creates an authentication exception
  static AuthenticationException createAuthenticationException({
    required String code,
    required String message,
    String? operation,
    Map<String, String>? details,
  }) => AuthenticationException(
    code: code,
    message: message,
    operation: operation,
    details: details,
  );
}

/// Common error codes for AnonAccount operations
class AnonAccountErrorCodes {
  // Authentication error codes
  static const String authInvalidSignature = 'AUTH_INVALID_SIGNATURE';
  static const String authExpiredChallenge = 'AUTH_EXPIRED_CHALLENGE';
  static const String authMissingKey = 'AUTH_MISSING_KEY';
  static const String authDeviceNotFound = 'AUTH_DEVICE_NOT_FOUND';
  static const String authDeviceRevoked = 'AUTH_DEVICE_REVOKED';
  static const String authAccountNotFound = 'AUTH_ACCOUNT_NOT_FOUND';
  static const String authDuplicateDevice = 'AUTH_DUPLICATE_DEVICE';
  static const String authChallengeExpired = 'AUTH_CHALLENGE_EXPIRED';

  // Cryptographic error codes
  static const String cryptoInvalidPublicKey = 'CRYPTO_INVALID_PUBLIC_KEY';
  static const String cryptoInvalidSignature = 'CRYPTO_INVALID_SIGNATURE';
  static const String cryptoInvalidMessage = 'CRYPTO_INVALID_MESSAGE';
  static const String cryptoVerificationFailed = 'CRYPTO_VERIFICATION_FAILED';
  static const String cryptoFormatError = 'CRYPTO_FORMAT_ERROR';

  // Proof-of-work error codes
  static const String powInvalidStamp = 'POW_INVALID_STAMP';
  static const String powChallengeExpired = 'POW_CHALLENGE_EXPIRED';
  static const String powInsufficientWork = 'POW_INSUFFICIENT_WORK';
  static const String powVerificationFailed = 'POW_VERIFICATION_FAILED';
  static const String rateLimitExceeded = 'RATE_LIMIT_EXCEEDED';

  // Group operation error codes
  static const String groupOperationNotAllowed = 'GROUP_OPERATION_NOT_ALLOWED';

  // General error codes
  static const String networkTimeout = 'NETWORK_TIMEOUT';
  static const String databaseError = 'DATABASE_ERROR';
  static const String internalError = 'INTERNAL_ERROR';
}
