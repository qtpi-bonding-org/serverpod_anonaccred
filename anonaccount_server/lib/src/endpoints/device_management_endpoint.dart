import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:anonaccount_protocol/anonaccount_protocol.dart' hide Protocol;
import '../crypto_utils.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../helpers.dart';
import '../queries/active_rows.dart';
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
    required UuidValue deviceId,
  }) async {
    try {
      await verifySignedPow(
        session,
        challenge,
        proofOfWork,
        publicKeyHex,
        signature,
        '$challenge:revokeDevice:$publicKeyHex',
      );

      final accountUuid = await AnonAccountHelpers.resolveAccountUuidByUltimateKey(
        session,
        publicKeyHex,
        'revokeDevice',
      );

      final device = await AllRows.deviceByIdForAccountIncludingRevoked(
        session,
        deviceId,
        accountUuid,
      );

      final foundDevice = AnonAccountHelpers.requireDevice(
        device,
        'deviceId:$deviceId',
        'revokeDevice',
      );

      await AccountDevice.db.updateRow(
        session,
        foundDevice.copyWith(
          isRevoked: true,
          revokedAt: AnonAccountHelpers.roundToMinute(DateTime.now()),
        ),
      );

      // Best-effort: revoke any JWTs for this account
      try {
        await AuthServices.instance.tokenManager.revokeAllTokens(
          session,
          authUserId: accountUuid,
        );
      } catch (e) {
        session.log(
          'Warning: could not revoke tokens after device revocation: $e',
          level: LogLevel.warning,
        );
      }

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

      final accountUuid = await AnonAccountHelpers.resolveAccountUuidByAnyKey(
        session,
        publicKeyHex,
        'listDevices',
      );

      final devices = await AllRows.devicesForAccountIncludingRevoked(
        session,
        accountUuid,
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
    required PublicKeyDuo newDeviceKeys,
    required String pairingAttestation,
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

      final callerDevice = await AllRows.deviceBySigningKeyIncludingRevoked(
        session,
        publicKeyHex,
      );

      // Not just "exists" — an active device. A revoked device pairing new
      // devices would defeat revocation entirely, and we are about to
      // persist a signed record of the grant.
      final activeCaller = AnonAccountHelpers.requireActiveDevice(
        callerDevice,
        publicKeyHex,
        'registerDeviceForAccount',
      );

      session.log(
        'DeviceManagementEndpoint: Registering new device for account UUID: ${activeCaller.anonAccountId}',
        level: LogLevel.info,
      );

      final keys = AnonAccountHelpers.validateKeyDuo(
        newDeviceKeys,
        'registerDeviceForAccount',
      );
      final attestationValid = await CryptoUtils.verifySignature(
        message: AccountInnerPayloads.pairDevice(keys),
        signature: pairingAttestation,
        publicKey: activeCaller.deviceSigningPublicKeyHex,
      );
      if (!attestationValid) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.cryptoInvalidSignature,
          message: 'Invalid pairing attestation — the calling device did not '
              'authorize this device key pair',
          operation: 'registerDeviceForAccount',
        );
      }

      final insertedDevice = await AnonAccountHelpers.insertDevice(
        session,
        accountId: activeCaller.anonAccountId,
        deviceKeys: keys,
        encryptedDataKey: newDeviceEncryptedDataKey,
        label: label,
        addedByAttestorPublicKeyHex: activeCaller.deviceSigningPublicKeyHex,
        addedByAttestation: pairingAttestation,
        operation: 'registerDeviceForAccount',
      );

      final channelName =
          'pairing-updates-${newDeviceKeys.signingPublicKeyHex}';
      session.messages.postMessage(
        channelName,
        DevicePairingEvent(
          encryptedDataKey: newDeviceEncryptedDataKey,
          signingKeyHex: newDeviceKeys.signingPublicKeyHex,
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