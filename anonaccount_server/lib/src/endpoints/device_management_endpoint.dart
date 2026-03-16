import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../helpers.dart';
import 'signed_pow_endpoint.dart';

/// SignedPoW-protected device management endpoints.
///
/// All methods require hashcash PoW + ECDSA signature + rate limiting.
/// Handles device revocation, listing, and QR pairing.
class DeviceManagementEndpoint extends SignedPowEndpoint {
  @override
  String get endpointType => 'device_management';

  @override
  int get rateLimitPerHour => 20;

  /// Revoke device access.
  Future<bool> revokeDevice(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String publicKeyHex,
    required String signature,
    required int deviceId,
  }) async {
    try {
      if (deviceId <= 0) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authMissingKey,
          message: 'deviceId is required for revokeDevice',
          operation: 'revokeDevice',
          details: {'deviceId': deviceId.toString()},
        );
      }

      await verifySignedPow(
        session,
        challenge,
        proofOfWork,
        publicKeyHex,
        signature,
        '$challenge:revokeDevice:$publicKeyHex',
      );

      final accountUuid = await AnonAccountHelpers.resolveAccountUuid(
        session,
        publicKeyHex,
        'revokeDevice',
      );

      final device = await AccountDevice.db.findFirstRow(
        session,
        where: (t) =>
            t.id.equals(deviceId) & t.accountUuid.equals(accountUuid),
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

      // Revoke any JWTs for this account (security: revoked device can't use existing tokens)
      await AuthServices.instance.tokenManager.revokeAllTokens(
        session,
        authUserId: accountUuid,
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
  Future<List<AccountDevice>> listDevices(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String publicKeyHex,
    required String signature,
  }) async {
    try {
      await verifySignedPow(
        session,
        challenge,
        proofOfWork,
        publicKeyHex,
        signature,
        '$challenge:listDevices:$publicKeyHex',
      );

      final accountUuid = await AnonAccountHelpers.resolveAccountUuid(
        session,
        publicKeyHex,
        'listDevices',
      );

      final devices = await AccountDevice.db.find(
        session,
        where: (t) => t.accountUuid.equals(accountUuid),
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
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String publicKeyHex,
    required String signature,
    required String newDeviceSigningPublicKeyHex,
    required String newDeviceEncryptedDataKey,
    required String label,
  }) async {
    session.log(
      'DeviceManagementEndpoint: registerDeviceForAccount called',
      level: LogLevel.info,
    );
    try {
      await verifySignedPow(
        session,
        challenge,
        proofOfWork,
        publicKeyHex,
        signature,
        '$challenge:registerDeviceForAccount:$publicKeyHex',
      );

      session.log(
        'DeviceManagementEndpoint: Caller device key: ${publicKeyHex.substring(0, 10)}...',
        level: LogLevel.info,
      );

      final callerDevice = await AccountDevice.db.findFirstRow(
        session,
        where: (t) =>
            t.deviceSigningPublicKeyHex.equals(publicKeyHex),
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
          details: {'callerDeviceKey': publicKeyHex},
        );
      }

      session.log(
        'DeviceManagementEndpoint: Registering new device for account UUID: ${callerDevice.accountUuid}',
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
        accountUuid: callerDevice.accountUuid,
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
