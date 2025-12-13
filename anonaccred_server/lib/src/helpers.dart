import 'crypto_auth.dart';
import 'exception_factory.dart';
import 'generated/protocol.dart';

/// Simple static helper functions to reduce code duplication
/// No complex abstractions, caching, or infrastructure
class AnonAccredHelpers {
  
  // === VALIDATION HELPERS ===
  
  /// Validate non-empty string, throw if empty/null
  /// Reduces 4-5 lines to 1 line
  static void validateNonEmpty(String? value, String fieldName, String operation) {
    if (value == null || value.isEmpty) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.authMissingKey,
        message: '$fieldName is required for $operation',
        operation: operation,
        details: {fieldName: value == null ? 'null' : 'empty'},
      );
    }
  }
  
  /// Validate Ed25519 public key format, throw if invalid
  /// Reduces 4-5 lines to 1 line
  static void validatePublicKey(String? publicKey, String operation) {
    validateNonEmpty(publicKey, 'publicKey', operation);
    if (!CryptoAuth.isValidPublicKey(publicKey!)) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.cryptoInvalidPublicKey,
        message: 'Invalid Ed25519 public key format',
        operation: operation,
        details: {
          'publicKeyLength': publicKey.length.toString(),
          'expectedLength': '64',
        },
      );
    }
  }
  
  // === DATABASE HELPERS ===
  
  /// Require entity to exist, throw if null
  /// Reduces 3-4 lines to 1 line
  static T requireEntity<T>(
    T? entity, 
    String errorCode, 
    String message, 
    String operation,
    Map<String, String> details,
  ) {
    if (entity == null) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: errorCode,
        message: message,
        operation: operation,
        details: details,
      );
    }
    return entity;
  }
  
  /// Require account to exist, throw if null
  /// Reduces 3-4 lines to 1 line
  static AnonAccount requireAccount(
    AnonAccount? account, 
    int accountId, 
    String operation,
  ) => requireEntity(
    account,
    AnonAccredErrorCodes.authAccountNotFound,
    'Account not found',
    operation,
    {'accountId': accountId.toString()},
  );
  
  /// Require device to exist, throw if null
  /// Reduces 3-4 lines to 1 line
  static AccountDevice requireDevice(
    AccountDevice? device, 
    String publicKey, 
    String operation,
  ) => requireEntity(
    device,
    AnonAccredErrorCodes.authDeviceNotFound,
    'Device not found',
    operation,
    {'publicSubKey': publicKey},
  );
  
  /// Require active device (exists and not revoked)
  /// Reduces 4-5 lines to 1 line
  static AccountDevice requireActiveDevice(
    AccountDevice? device, 
    String publicKey, 
    String operation,
  ) {
    final foundDevice = requireDevice(device, publicKey, operation);
    if (foundDevice.isRevoked) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.authDeviceRevoked,
        message: 'Device has been revoked',
        operation: operation,
        details: {
          'deviceId': foundDevice.id.toString(),
          'publicSubKey': publicKey,
        },
      );
    }
    return foundDevice;
  }
  

}