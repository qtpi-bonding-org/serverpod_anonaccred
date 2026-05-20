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

  /// Resolve the account UUID from either a device key or ultimate key.
  ///
  /// Tries device key first, then ultimate key. Useful for endpoints
  /// that should accept either (e.g., listDevices).
  static Future<UuidValue> resolveAccountUuidByAnyKey(
    Session session,
    String publicKeyHex,
    String operation,
  ) async {
    // Try device key first
    final device = await AccountDevice.db.findFirstRow(
      session,
      where: (t) => t.deviceSigningPublicKeyHex.equals(publicKeyHex),
    );
    if (device != null) {
      return device.anonAccountId;
    }

    // Try ultimate key
    final account = await AnonAccount.db.findFirstRow(
      session,
      where: (t) => t.ultimateSigningPublicKeyHex.equals(publicKeyHex),
    );
    if (account != null) {
      return account.id!;
    }

    throw AnonAccountExceptionFactory.createAuthenticationException(
      code: AnonAccountErrorCodes.authAccountNotFound,
      message: 'No account found for public key',
      operation: operation,
      details: {'publicKeyHex': publicKeyHex},
    );
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

  // === DEVICE REGISTRATION ===

  /// Register a device for an account (validate + duplicate check + insert).
  ///
  /// Shared by [AccountEndpoint.createAccount] (first device) and
  /// [DeviceEndpoint.registerDevice] (additional devices).
  /// Callers are responsible for PoW verification and attestation checks.
  static Future<AccountDevice> insertDevice(
    Session session, {
    required UuidValue accountId,
    required String deviceSigningPublicKeyHex,
    required String encryptedDataKey,
    required String label,
    required String operation,
  }) async {
    validatePublicKey(deviceSigningPublicKeyHex, operation);
    validateNonEmpty(encryptedDataKey, 'encryptedDataKey', operation);
    validateNonEmpty(label, 'label', operation);

    final existing = await AccountDevice.db.findFirstRow(
      session,
      where: (t) =>
          t.deviceSigningPublicKeyHex.equals(deviceSigningPublicKeyHex),
    );
    if (existing != null) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authDuplicateDevice,
        message: 'Device signing public key already registered',
        operation: operation,
        details: {
          'deviceSigningPublicKeyHex': deviceSigningPublicKeyHex,
        },
      );
    }

    final device = AccountDevice(
      anonAccountId: accountId,
      deviceSigningPublicKeyHex: deviceSigningPublicKeyHex,
      encryptedDataKey: encryptedDataKey,
      label: label,
      lastActive: roundToMinute(DateTime.now()),
      isRevoked: false,
    );

    return await AccountDevice.db.insertRow(session, device);
  }

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
