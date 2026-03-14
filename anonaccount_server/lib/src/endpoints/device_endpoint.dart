import 'package:serverpod/serverpod.dart';
import '../auth_handler.dart';
import '../challenge_storage.dart';
import '../crypto_auth.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../helpers.dart';
import '../services/public_challenge_service.dart';

/// Device management endpoints for ECDSA P-256 device registration and authentication.
///
/// Security model: every method is protected by either:
/// - **Session auth** (authenticated device key) — for operations on own account
/// - **PoW + rate limit** — for unauthenticated public operations
class DeviceEndpoint extends Endpoint {
  @override
  bool get requireLogin => false; // Methods handle authentication individually

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC METHODS (PoW + rate limited)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Register new device with account (PoW-protected).
  ///
  /// Creates a new device registration associated with an account.
  /// The account is resolved from the ultimate signing public key.
  Future<AccountDevice> registerDevice(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String ultimateSigningPublicKeyHex,
    required String deviceSigningPublicKeyHex,
    required String encryptedDataKey,
    required String label,
  }) async {
    try {
      // Verify PoW + signature + rate limit
      final payload =
          '$challenge:registerDevice:$ultimateSigningPublicKeyHex';

      await PublicChallengeService.verifyAndRateLimit(
        session,
        challenge,
        proofOfWork,
        ultimateSigningPublicKeyHex,
        signature,
        payload,
      );

      // Validate input parameters
      AnonAccountHelpers.validatePublicKey(
        ultimateSigningPublicKeyHex,
        'registerDevice',
      );
      AnonAccountHelpers.validatePublicKey(
        deviceSigningPublicKeyHex,
        'registerDevice',
      );
      AnonAccountHelpers.validateNonEmpty(
        encryptedDataKey,
        'encryptedDataKey',
        'registerDevice',
      );
      AnonAccountHelpers.validateNonEmpty(label, 'label', 'registerDevice');

      // Resolve account from ultimate signing public key
      final account = await AnonAccount.db.findFirstRow(
        session,
        where: (t) => t.ultimateSigningPublicKeyHex
            .equals(ultimateSigningPublicKeyHex),
      );
      if (account == null) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authAccountNotFound,
          message: 'Account not found for ultimate signing key',
          operation: 'registerDevice',
          details: {
            'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
          },
        );
      }

      // Check for duplicate device signing public key
      final existingDevice = await AccountDevice.db.findFirstRow(
        session,
        where: (t) =>
            t.deviceSigningPublicKeyHex.equals(deviceSigningPublicKeyHex),
      );

      if (existingDevice != null) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authDuplicateDevice,
          message: 'Device signing public key already registered',
          operation: 'registerDevice',
          details: {
            'deviceSigningPublicKeyHex': deviceSigningPublicKeyHex,
            'existingDeviceId': existingDevice.id.toString(),
          },
        );
      }

      // Create new device
      final device = AccountDevice(
        accountId: account.id!,
        deviceSigningPublicKeyHex: deviceSigningPublicKeyHex,
        encryptedDataKey: encryptedDataKey,
        label: label,
        lastActive: _roundToMinute(DateTime.now()),
        isRevoked: false,
      );

      final insertedDevice =
          await AccountDevice.db.insertRow(session, device);

      session.log(
        'DeviceEndpoint: Device registered successfully with ID: ${insertedDevice.id}',
        level: LogLevel.info,
      );
      return insertedDevice;
    } on AuthenticationException {
      rethrow;
    } catch (e, stackTrace) {
      session.log(
        'DeviceEndpoint: Unexpected error: $e\n$stackTrace',
        level: LogLevel.error,
      );

      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Failed to register device: ${e.toString()}',
        operation: 'registerDevice',
        details: {'error': e.toString()},
      );
    }
  }

  /// Generate authentication challenge (PoW-protected).
  ///
  /// Creates a cryptographically secure challenge string for client use.
  /// The challenge should be signed by the client's private key and returned
  /// for verification via authenticateDevice.
  Future<String> generateAuthChallenge(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String devicePublicKey,
  }) async {
    try {
      // Verify PoW + signature + rate limit
      final payload =
          '$challenge:generateAuthChallenge:$devicePublicKey';

      await PublicChallengeService.verifyAndRateLimit(
        session,
        challenge,
        proofOfWork,
        devicePublicKey,
        signature,
        payload,
      );

      // Validate device exists and is active
      final device = await AccountDevice.db.findFirstRow(
        session,
        where: (t) => t.deviceSigningPublicKeyHex.equals(devicePublicKey),
      );

      if (device == null) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authDeviceNotFound,
          message: 'Device not found',
          operation: 'generateAuthChallenge',
          details: {'devicePublicKey': devicePublicKey},
        );
      }

      if (device.isRevoked) {
        final deviceIdStr =
            device.id != null ? device.id.toString() : 'unknown';
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authDeviceRevoked,
          message: 'Device has been revoked',
          operation: 'generateAuthChallenge',
          details: {'deviceId': deviceIdStr},
        );
      }

      // Generate and store challenge in Redis with 5-minute TTL
      final challengeStorage = DeviceChallengeStorage(session);
      return await challengeStorage
          .generateAndStoreChallenge(devicePublicKey);
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Failed to generate auth challenge: ${e.toString()}',
        operation: 'generateAuthChallenge',
        details: {'error': e.toString()},
      );
    }
  }

  /// Get device info by signing public key (PoW-protected).
  ///
  /// Used by Device B during pairing to get its encrypted data key.
  /// Only returns the encrypted blob (useless without Device B's private key).
  Future<DevicePairingInfo?> getDeviceBySigningKey(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String signingPublicKeyHex,
  }) async {
    try {
      // Verify PoW + signature + rate limit
      final payload =
          '$challenge:getDeviceBySigningKey:$signingPublicKeyHex';

      await PublicChallengeService.verifyAndRateLimit(
        session,
        challenge,
        proofOfWork,
        signingPublicKeyHex,
        signature,
        payload,
      );

      AnonAccountHelpers.validatePublicKey(
        signingPublicKeyHex,
        'getDeviceBySigningKey',
      );

      final device = await AccountDevice.db.findFirstRow(
        session,
        where: (t) =>
            t.deviceSigningPublicKeyHex.equals(signingPublicKeyHex),
      );

      if (device == null) return null;

      return DevicePairingInfo(encryptedDataKey: device.encryptedDataKey);
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Failed to get device by signing key: ${e.toString()}',
        operation: 'getDeviceBySigningKey',
        details: {'error': e.toString()},
      );
    }
  }

  /// Monitor registration status for a specific signing key (PoW-protected).
  ///
  /// Device B (unauthenticated) calls this to wait for Device A to complete
  /// the registration. PoW is verified before opening the stream.
  Stream<DevicePairingEvent> monitorRegistration(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String signingKeyHex,
  }) async* {
    // Verify PoW + signature + rate limit before opening stream
    final payload =
        '$challenge:monitorRegistration:$signingKeyHex';

    await PublicChallengeService.verifyAndRateLimit(
      session,
      challenge,
      proofOfWork,
      signingKeyHex,
      signature,
      payload,
    );

    session.log(
      'DeviceEndpoint: monitorRegistration info $signingKeyHex',
      level: LogLevel.info,
    );

    final channelName = 'pairing-updates-$signingKeyHex';
    final stream = session.messages.createStream<DevicePairingEvent>(
      channelName,
    );

    await for (final event in stream) {
      yield event;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED: PoW challenge generation (used by all public device methods)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get challenge for proof-of-work (shared by all public device methods).
  Future<PublicChallengeResponse> getChallenge(Session session) async {
    return await PublicChallengeService.generateChallenge(session);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTHENTICATED METHODS (session auth)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Authenticate device with challenge-response.
  ///
  /// Requires session auth. Performs ECDSA P-256 signature verification.
  /// Updates the device's last active timestamp on success.
  Future<AuthenticationResult> authenticateDevice(
    Session session,
    String challenge,
    String signature,
  ) async {
    try {
      if (session.authenticated == null) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authMissingKey,
          message: 'Authentication required for device authentication',
          operation: 'authenticateDevice',
          details: {},
        );
      }

      final publicKey =
          AnonAccountAuthHandler.getDevicePublicKey(session);

      AnonAccountHelpers.validateNonEmpty(
        challenge,
        'challenge',
        'authenticateDevice',
      );
      AnonAccountHelpers.validateNonEmpty(
        signature,
        'signature',
        'authenticateDevice',
      );

      final device = await AccountDevice.db.findFirstRow(
        session,
        where: (t) => t.deviceSigningPublicKeyHex.equals(publicKey),
      );

      final activeDevice = AnonAccountHelpers.requireActiveDevice(
        device,
        publicKey,
        'authenticateDevice',
      );

      final challengeStorage = DeviceChallengeStorage(session);
      final challengeValid = await challengeStorage.verifyAndConsume(
        publicKey,
        challenge,
      );

      if (!challengeValid) {
        return AuthenticationResultFactory.failure(
          errorCode: AnonAccountErrorCodes.authChallengeExpired,
          errorMessage: 'Invalid or expired challenge',
          details: {'challenge': challenge},
        );
      }

      final verificationResult =
          await CryptoAuth.verifyChallengeResponse(
        publicKey,
        challenge,
        signature,
        skipTimestampValidation: true,
      );

      if (verificationResult.success) {
        final updatedDevice = await AccountDevice.db.updateRow(
          session,
          activeDevice.copyWith(
            lastActive: _roundToMinute(DateTime.now()),
          ),
        );

        return AuthenticationResultFactory.success(
          deviceId: activeDevice.id,
          details: {
            'deviceSigningPublicKeyHex': publicKey,
            'lastActive': updatedDevice.lastActive.toIso8601String(),
          },
        );
      } else {
        return verificationResult;
      }
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Authentication failed: ${e.toString()}',
        operation: 'authenticateDevice',
        details: {'error': e.toString()},
      );
    }
  }

  /// Revoke device access (session auth required).
  Future<bool> revokeDevice(Session session, int deviceId) async {
    try {
      if (session.authenticated == null) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authMissingKey,
          message: 'Authentication required for device revocation',
          operation: 'revokeDevice',
          details: {},
        );
      }

      if (deviceId <= 0) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authMissingKey,
          message: 'deviceId is required for revokeDevice',
          operation: 'revokeDevice',
          details: {'deviceId': deviceId.toString()},
        );
      }

      final accountId =
          int.parse(session.authenticated!.userIdentifier);

      final device = await AccountDevice.db.findFirstRow(
        session,
        where: (t) =>
            t.id.equals(deviceId) & t.accountId.equals(accountId),
      );

      final foundDevice = AnonAccountHelpers.requireDevice(
        device,
        'deviceId:$deviceId',
        'revokeDevice',
      );

      await AccountDevice.db.updateRow(
        session,
        foundDevice.copyWith(isRevoked: true),
      );

      return true;
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Failed to revoke device: ${e.toString()}',
        operation: 'revokeDevice',
        details: {
          'error': e.toString(),
          'deviceId': deviceId.toString(),
        },
      );
    }
  }

  /// List account devices (session auth required).
  Future<List<AccountDevice>> listDevices(Session session) async {
    try {
      if (session.authenticated == null) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authMissingKey,
          message: 'Authentication required for listing devices',
          operation: 'listDevices',
          details: {},
        );
      }

      final accountId =
          int.parse(session.authenticated!.userIdentifier);

      final devices = await AccountDevice.db.find(
        session,
        where: (t) => t.accountId.equals(accountId),
        orderBy: (t) => t.lastActive,
        orderDescending: true,
      );

      return devices;
    } catch (e) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Failed to list devices: ${e.toString()}',
        operation: 'listDevices',
        details: {'error': e.toString()},
      );
    }
  }

  /// Register a new device for the caller's account (session auth required).
  ///
  /// QR code pairing flow: Device A (authenticated) registers Device B.
  Future<AccountDevice> registerDeviceForAccount(
    Session session,
    String newDeviceSigningPublicKeyHex,
    String newDeviceEncryptedDataKey,
    String label,
  ) async {
    session.log(
      'DeviceEndpoint: registerDeviceForAccount called',
      level: LogLevel.info,
    );
    try {
      if (session.authenticated == null) {
        session.log(
          'DeviceEndpoint: ERROR - Not authenticated',
          level: LogLevel.error,
        );
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authMissingKey,
          message: 'Authentication required to register new device',
          operation: 'registerDeviceForAccount',
          details: {},
        );
      }

      final callerDeviceKey =
          AnonAccountAuthHandler.getDevicePublicKey(session);
      session.log(
        'DeviceEndpoint: Caller device key: ${callerDeviceKey.substring(0, 10)}...',
        level: LogLevel.info,
      );

      final callerDevice = await AccountDevice.db.findFirstRow(
        session,
        where: (t) =>
            t.deviceSigningPublicKeyHex.equals(callerDeviceKey),
      );

      if (callerDevice == null) {
        session.log(
          'DeviceEndpoint: ERROR - Caller device not found in DB',
          level: LogLevel.error,
        );
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authDeviceNotFound,
          message: 'Caller device not found',
          operation: 'registerDeviceForAccount',
          details: {'callerDeviceKey': callerDeviceKey},
        );
      }

      session.log(
        'DeviceEndpoint: Registering new device for account ID: ${callerDevice.accountId}',
        level: LogLevel.info,
      );

      AnonAccountHelpers.validatePublicKey(
        newDeviceSigningPublicKeyHex,
        'registerDeviceForAccount',
      );
      AnonAccountHelpers.validateNonEmpty(
        newDeviceEncryptedDataKey,
        'newDeviceEncryptedDataKey',
        'registerDeviceForAccount',
      );
      AnonAccountHelpers.validateNonEmpty(
        label,
        'label',
        'registerDeviceForAccount',
      );

      final existing = await AccountDevice.db.findFirstRow(
        session,
        where: (t) => t.deviceSigningPublicKeyHex
            .equals(newDeviceSigningPublicKeyHex),
      );
      if (existing != null) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authDuplicateDevice,
          message: 'Device already registered',
          operation: 'registerDeviceForAccount',
          details: {
            'newDeviceSigningPublicKeyHex': newDeviceSigningPublicKeyHex,
          },
        );
      }

      final newDevice = AccountDevice(
        accountId: callerDevice.accountId,
        deviceSigningPublicKeyHex: newDeviceSigningPublicKeyHex,
        encryptedDataKey: newDeviceEncryptedDataKey,
        label: label,
        lastActive: _roundToMinute(DateTime.now()),
        isRevoked: false,
      );

      final insertedDevice = await AccountDevice.db.insertRow(
        session,
        newDevice,
      );

      final channelName =
          'pairing-updates-$newDeviceSigningPublicKeyHex';
      session.messages.postMessage(
        channelName,
        DevicePairingEvent(
          encryptedDataKey: newDeviceEncryptedDataKey,
          signingKeyHex: newDeviceSigningPublicKeyHex,
        ),
      );

      return insertedDevice;
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.databaseError,
        message:
            'Failed to register device for account: ${e.toString()}',
        operation: 'registerDeviceForAccount',
        details: {'error': e.toString()},
      );
    }
  }

  /// Rounds a DateTime to the nearest minute for privacy hardening.
  DateTime _roundToMinute(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute);
}
