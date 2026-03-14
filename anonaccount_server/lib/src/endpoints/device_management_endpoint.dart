import 'package:serverpod/serverpod.dart';
import '../challenge_storage.dart';
import '../crypto_auth.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../helpers.dart';
import 'authenticated_endpoint.dart';

/// Authenticated device management endpoints.
///
/// All methods require session authentication (device key).
/// Handles device authentication, revocation, listing, and QR pairing.
class DeviceManagementEndpoint extends AuthenticatedEndpoint {
  /// Authenticate device with challenge-response.
  ///
  /// Performs ECDSA P-256 signature verification.
  /// Updates the device's last active timestamp on success.
  Future<AuthenticationResult> authenticateDevice(
    Session session,
    String challenge,
    String signature,
  ) async {
    try {
      final publicKey = getDevicePublicKey(session);

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
            lastActive: AnonAccountHelpers.roundToMinute(DateTime.now()),
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

  /// Revoke device access.
  Future<bool> revokeDevice(Session session, int deviceId) async {
    try {
      if (deviceId <= 0) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authMissingKey,
          message: 'deviceId is required for revokeDevice',
          operation: 'revokeDevice',
          details: {'deviceId': deviceId.toString()},
        );
      }

      final accountId = getAccountId(session);

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

  /// List account devices.
  Future<List<AccountDevice>> listDevices(Session session) async {
    try {
      final accountId = getAccountId(session);

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

  /// Register a new device for the caller's account.
  ///
  /// QR code pairing flow: Device A (authenticated) registers Device B.
  Future<AccountDevice> registerDeviceForAccount(
    Session session,
    String newDeviceSigningPublicKeyHex,
    String newDeviceEncryptedDataKey,
    String label,
  ) async {
    session.log(
      'DeviceManagementEndpoint: registerDeviceForAccount called',
      level: LogLevel.info,
    );
    try {
      final callerDeviceKey = getDevicePublicKey(session);
      session.log(
        'DeviceManagementEndpoint: Caller device key: ${callerDeviceKey.substring(0, 10)}...',
        level: LogLevel.info,
      );

      final callerDevice = await AccountDevice.db.findFirstRow(
        session,
        where: (t) =>
            t.deviceSigningPublicKeyHex.equals(callerDeviceKey),
      );

      if (callerDevice == null) {
        session.log(
          'DeviceManagementEndpoint: ERROR - Caller device not found in DB',
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
        'DeviceManagementEndpoint: Registering new device for account ID: ${callerDevice.accountId}',
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
        lastActive: AnonAccountHelpers.roundToMinute(DateTime.now()),
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
}
