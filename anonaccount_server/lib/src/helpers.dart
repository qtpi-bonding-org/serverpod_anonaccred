import 'package:serverpod/serverpod.dart';
import 'package:anonaccount_protocol/anonaccount_protocol.dart';

import 'crypto_auth.dart';
import 'crypto_utils.dart';
import 'exception_factory.dart';
import 'generated/protocol.dart';
import 'authenticated_caller.dart';
import 'key_format.dart';
import 'queries/active_rows.dart';

/// Simple static helper functions to reduce code duplication
/// No complex abstractions, caching, or infrastructure
class AnonAccountHelpers {
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
        details: {'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex},
      );
    }
    return account.id!;
  }

  /// Resolve the account UUID from either an active device key or an ultimate
  /// key. A revoked device key is rejected rather than falling through to the
  /// ultimate-key branch.
  static Future<UuidValue> resolveAccountUuidByAnyKey(
    Session session,
    String publicKeyHex,
    String operation,
  ) async {
    // Try device key first. If a row matches, it must be active.
    final device = await AllRows.deviceBySigningKeyIncludingRevoked(
      session,
      publicKeyHex,
    );
    if (device != null) {
      return requireActiveDevice(device, publicKeyHex, operation).anonAccountId;
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
  static void validateNonEmpty(
    String? value,
    String fieldName,
    String operation,
  ) {
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

  /// Validates both halves of a principal's key pair and returns the
  /// normalised duo.
  ///
  /// The distinctness check is the one that catches the realistic mistake:
  /// the same key pasted into both slots. It cannot catch some *other* wrong
  /// key — nothing can, since the two key types are byte-indistinguishable.
  static PublicKeyDuo validateKeyDuo(PublicKeyDuo duo, String operation) {
    final signing = _normalizeKey(
      duo.signingPublicKeyHex,
      'signingPublicKeyHex',
      operation,
    );
    final encryption = _normalizeKey(
      duo.encryptionPublicKeyHex,
      'encryptionPublicKeyHex',
      operation,
    );

    if (signing == encryption) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.cryptoInvalidPublicKey,
        message:
            'signingPublicKeyHex and encryptionPublicKeyHex must be different '
            'keys',
        operation: operation,
      );
    }

    return PublicKeyDuo(
      signingPublicKeyHex: signing,
      encryptionPublicKeyHex: encryption,
    );
  }

  static String _normalizeKey(
    String value,
    String fieldName,
    String operation,
  ) {
    try {
      return PublicKeyFormat.normalize(value);
    } on FormatException catch (e) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.cryptoInvalidPublicKey,
        message: '$fieldName is not a valid public key: ${e.message}',
        operation: operation,
        details: {'field': fieldName},
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
    required PublicKeyDuo deviceKeys,
    required String encryptedDataKey,
    required String label,
    required String addedByAttestorPublicKeyHex,
    required String addedByAttestation,
    required String operation,
    Transaction? transaction,
  }) async {
    final keys = validateKeyDuo(deviceKeys, operation);
    validateNonEmpty(encryptedDataKey, 'encryptedDataKey', operation);
    validateNonEmpty(label, 'label', operation);
    validateNonEmpty(
      addedByAttestorPublicKeyHex,
      'addedByAttestorPublicKeyHex',
      operation,
    );
    validateNonEmpty(addedByAttestation, 'addedByAttestation', operation);

    final existing = await AllRows.deviceBySigningKeyIncludingRevoked(
      session,
      keys.signingPublicKeyHex,
      transaction: transaction,
    );
    if (existing != null) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authDuplicateDevice,
        message: 'Device signing public key already registered',
        operation: operation,
        details: {'deviceSigningPublicKeyHex': keys.signingPublicKeyHex},
      );
    }

    final now = roundToMinute(DateTime.now());
    return await AccountDevice.db.insertRow(
      session,
      AccountDevice(
        anonAccountId: accountId,
        deviceSigningPublicKeyHex: keys.signingPublicKeyHex,
        deviceEncryptionPublicKeyHex: keys.encryptionPublicKeyHex,
        encryptedDataKey: encryptedDataKey,
        label: label,
        addedByAttestorPublicKeyHex: addedByAttestorPublicKeyHex,
        addedByAttestation: addedByAttestation,
        createdAt: now,
        lastActive: now,
        isRevoked: false,
      ),
      transaction: transaction,
    );
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

  /// Require an active group membership so revoked and unknown keys can be
  /// reported distinctly.
  static GroupMember requireActiveMember(
    GroupMember? member,
    String memberSigningPublicKeyHex,
    String operation,
  ) {
    final found = requireEntity(
      member,
      AnonAccountErrorCodes.authAccountNotFound,
      'No membership found for this member key',
      operation,
      {'memberSigningPublicKeyHex': memberSigningPublicKeyHex},
    );
    if (found.isRevoked) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authAccountRevoked,
        message: 'Membership has been revoked',
        operation: operation,
        details: {'memberId': found.id.toString()},
      );
    }
    return found;
  }

  /// Resolves a caller device and requires it to be active.
  static Future<AuthenticatedCaller> requireCaller(
    Session session,
    String deviceSigningPublicKeyHex,
    String operation, {
    Transaction? transaction,
  }) async {
    final device = await AllRows.deviceBySigningKeyIncludingRevoked(
      session,
      deviceSigningPublicKeyHex,
      transaction: transaction,
    );
    return AuthenticatedCaller(
      requireActiveDevice(device, deviceSigningPublicKeyHex, operation),
    );
  }

  /// Verifies an attestation and throws a consistent authentication error.
  static Future<void> requireAttestation({
    required String message,
    required String signature,
    required String publicKey,
    required String operation,
    required String failureMessage,
  }) async {
    final valid = await CryptoUtils.verifySignature(
      message: message,
      signature: signature,
      publicKey: publicKey,
    );
    if (!valid) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.cryptoInvalidSignature,
        message: failureMessage,
        operation: operation,
      );
    }
  }

  /// Requires an active membership belonging to the caller's account.
  static Future<GroupMember> requireMemberStanding(
    Session session,
    AuthenticatedCaller caller,
    String memberSigningPublicKeyHex,
    UuidValue groupId,
    String operation, {
    Transaction? transaction,
  }) async {
    final row = await AllRows.memberBySigningKeyIncludingRevoked(
      session,
      groupId,
      memberSigningPublicKeyHex,
      transaction: transaction,
    );
    final membership = requireActiveMember(
      row,
      memberSigningPublicKeyHex,
      operation,
    );
    if (membership.anonAccountId != caller.accountId) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authInvalidSignature,
        message:
            'Caller member key is not bound to the device-resolved account',
        operation: operation,
      );
    }
    return membership;
  }
}
