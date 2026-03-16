import 'package:serverpod/serverpod.dart';

import 'crypto_auth.dart';
import 'exception_factory.dart';
import 'generated/protocol.dart';

/// Simple static helper functions to reduce code duplication
/// No complex abstractions, caching, or infrastructure
class AnonAccountHelpers {

  /// Resolve the account UUID from a device signing public key.
  ///
  /// Looks up the device by its signing key and returns the associated accountUuid.
  /// Used for JWT token management (issuance, revocation).
  static Future<UuidValue> resolveAccountUuid(
    Session session,
    String identifier,
    String operation,
  ) async {
    final device = await AccountDevice.db.findFirstRow(
      session,
      where: (t) => t.deviceSigningPublicKeyHex.equals(identifier),
    );
    if (device == null) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authDeviceNotFound,
        message: 'Device not found for public key',
        operation: operation,
        details: {'deviceSigningPublicKeyHex': identifier},
      );
    }
    return device.anonAccountId;
  }

  /// Resolve the account UUID from the ultimate signing public key.
  ///
  /// Looks up the account directly by its ultimate signing key.
  /// Used by owner-level endpoints (revokeDevice, listDevices).
  static Future<UuidValue> resolveAccountUuidByUltimateKey(
    Session session,
    String ultimateSigningPublicKeyHex,
    String operation,
  ) async {
    final account = await AnonAccount.db.findFirstRow(
      session,
      where: (t) =>
          t.ultimateSigningPublicKeyHex.equals(ultimateSigningPublicKeyHex),
    );
    if (account == null) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authAccountNotFound,
        message: 'Account not found for ultimate key',
        operation: operation,
        details: {
          'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
        },
      );
    }
    return account.id!;
  }


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
    String identifier,
    String operation,
  ) => requireEntity(
    account,
    AnonAccountErrorCodes.authAccountNotFound,
    'Account not found',
    operation,
    {'identifier': identifier},
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

  // === TIME HELPERS ===

  /// Round DateTime to the nearest minute for privacy hardening.
  ///
  /// Strips seconds and milliseconds from timestamps to reduce
  /// timing-based fingerprinting of device activity.
  static DateTime roundToMinute(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute);

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
