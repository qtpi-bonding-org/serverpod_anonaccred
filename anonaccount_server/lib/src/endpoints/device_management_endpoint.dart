import 'package:serverpod/serverpod.dart';
import '../protocol_failures.dart';
import '../try_operation.dart';
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
    return tryOperation(
      session,
      'revokeDevice',
      () async {
        await verifySignedPow(
          session,
          challenge,
          proofOfWork,
          publicKeyHex,
          signature,
          '$challenge:revokeDevice:$publicKeyHex',
        );

        final accountUuid =
            await AnonAccountHelpers.resolveAccountUuidByUltimateKey(
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

        await session.db.transaction((tx) async {
          if (!foundDevice.isRevoked) {
            final activeDevices =
                await ActiveRows.activeDevicesForAccountForUpdate(
                  session,
                  accountUuid,
                  transaction: tx,
                );
            if (activeDevices.length == 1 &&
                activeDevices.first.id == foundDevice.id) {
              throw AnonAccountExceptionFactory.createAuthenticationException(
                code: AnonAccountErrorCodes.deviceOperationNotAllowed,
                message: "Cannot revoke the account's last active device.",
                operation: 'revokeDevice',
                details: {'deviceId': foundDevice.id.toString()},
              );
            }
          }

          await AccountDevice.db.updateRow(
            session,
            foundDevice.copyWith(
              isRevoked: true,
              revokedAt: AnonAccountHelpers.roundToMinute(DateTime.now()),
            ),
            transaction: tx,
          );
        });

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
      },
      onFailure: authFailure,
      code: AnonAccountErrorCodes.databaseError,
      extraDetails: {'deviceId': deviceId.toString()},
    );
  }

  /// List account devices.
  Future<List<AccountDevice>> listDevices(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String publicKeyHex,
    required String signature,
  }) async {
    return tryOperation(
      session,
      'listDevices',
      () async {
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
      },
      onFailure: authFailure,
      code: AnonAccountErrorCodes.databaseError,
    );
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
    required String ultimateEncryptionPublicKeyHex,
    required String ultimateSigningPublicKeyHex,
  }) async {
    session.log(
      'DeviceManagementEndpoint: registerDeviceForAccount called',
      level: LogLevel.info,
    );
    return tryOperation(
      session,
      'registerDeviceForAccount',
      () async {
        final activeCaller = await guard(
          session,
          challenge: challenge,
          proofOfWork: proofOfWork,
          signature: signature,
          callerDeviceSigningPublicKeyHex: publicKeyHex,
          methodName: 'registerDeviceForAccount',
        );

        session.log(
          'DeviceManagementEndpoint: Registering new device for account UUID: ${activeCaller.accountId}',
          level: LogLevel.info,
        );

        final keys = AnonAccountHelpers.validateKeyDuo(
          newDeviceKeys,
          'registerDeviceForAccount',
        );
        // validateNonEmpty, not validatePublicKey: the latter hardcodes
        // 'publicKey' as the field name in its error, so two adjacent
        // failures on these would be indistinguishable.
        AnonAccountHelpers.validateNonEmpty(
          ultimateEncryptionPublicKeyHex,
          'ultimateEncryptionPublicKeyHex',
          'registerDeviceForAccount',
        );
        AnonAccountHelpers.validateNonEmpty(
          ultimateSigningPublicKeyHex,
          'ultimateSigningPublicKeyHex',
          'registerDeviceForAccount',
        );
        final attestationValid = await CryptoUtils.verifySignature(
          message: AccountInnerPayloads.pairDevice(keys),
          signature: pairingAttestation,
          publicKey: activeCaller.signingPublicKeyHex,
        );
        if (!attestationValid) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.cryptoInvalidSignature,
            message:
                'Invalid pairing attestation — the calling device did not '
                'authorize this device key pair',
            operation: 'registerDeviceForAccount',
          );
        }

        final insertedDevice = await AnonAccountHelpers.insertDevice(
          session,
          accountId: activeCaller.accountId,
          deviceKeys: keys,
          encryptedDataKey: newDeviceEncryptedDataKey,
          label: label,
          addedByAttestorPublicKeyHex: activeCaller.signingPublicKeyHex,
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
            ultimateEncryptionPublicKeyHex: ultimateEncryptionPublicKeyHex,
            ultimateSigningPublicKeyHex: ultimateSigningPublicKeyHex,
          ),
        );

        return insertedDevice;
      },
      onFailure: authFailure,
      code: AnonAccountErrorCodes.databaseError,
    );
  }
}
