import 'crypto_auth.dart';
import 'exception_factory.dart';
import 'generated/protocol.dart';

/// Simple static helper functions to reduce code duplication
/// No complex abstractions, caching, or infrastructure
class AnonAccountHelpers {

  // === VALIDATION HELPERS ===

  /// Validate non-empty string, throw if empty/null
  static void validateNonEmpty(String? value, String fieldName, String operation) {
    if (value == null || value.isEmpty) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authMissingKey,
        message: '$fieldName is required for $operation',
        operation: operation,
        details: {fieldName: value == null ? 'null' : 'empty'},
      );
    }
  }

  /// Validate ECDSA P-256 public key format, throw if invalid.
  static void validatePublicKey(String? publicKey, String operation) {
    validateNonEmpty(publicKey, 'publicKey', operation);
    if (!CryptoAuth.isValidPublicKey(publicKey!)) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.cryptoInvalidPublicKey,
        message: 'Invalid ECDSA P-256 public key format',
        operation: operation,
        details: {
          'publicKeyLength': publicKey.length.toString(),
          'expectedLength': '128 or 130',
        },
      );
    }
  }

  // === DATABASE HELPERS ===

  /// Require entity to exist, throw if null
  static T requireEntity<T>(
    T? entity,
    String errorCode,
    String message,
    String operation,
    Map<String, String> details,
  ) {
    if (entity == null) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: errorCode,
        message: message,
        operation: operation,
        details: details,
      );
    }
    return entity;
  }

  /// Require account to exist, throw if null
  static AnonAccount requireAccount(
    AnonAccount? account,
    int accountId,
    String operation,
  ) => requireEntity(
    account,
    AnonAccountErrorCodes.authAccountNotFound,
    'Account not found',
    operation,
    {'accountId': accountId.toString()},
  );

  /// Require device to exist, throw if null
  static AccountDevice requireDevice(
    AccountDevice? device,
    String publicKey,
    String operation,
  ) => requireEntity(
    device,
    AnonAccountErrorCodes.authDeviceNotFound,
    'Device not found',
    operation,
    {'deviceSigningPublicKeyHex': publicKey},
  );

  /// Require active device (exists and not revoked)
  static AccountDevice requireActiveDevice(
    AccountDevice? device,
    String publicKey,
    String operation,
  ) {
    final foundDevice = requireDevice(device, publicKey, operation);
    if (foundDevice.isRevoked) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authDeviceRevoked,
        message: 'Device has been revoked',
        operation: operation,
        details: {
          'deviceId': foundDevice.id.toString(),
          'deviceSigningPublicKeyHex': publicKey,
        },
      );
    }
    return foundDevice;
  }
}
