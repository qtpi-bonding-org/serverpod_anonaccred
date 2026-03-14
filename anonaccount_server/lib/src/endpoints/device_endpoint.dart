import 'package:serverpod/serverpod.dart';
import '../challenge_storage.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../helpers.dart';
import 'pow_protected_endpoint.dart';

/// Public device endpoints protected by hashcash proof-of-work.
///
/// Extends [PowProtectedEndpoint] to inherit `getChallenge()` and `verifyPow()`.
///
/// Handles unauthenticated device operations:
/// - Device registration
/// - Auth challenge generation
/// - Device pairing lookup and monitoring
///
/// Authenticated device operations (revoke, list, QR pairing) are in
/// [DeviceManagementEndpoint].
class DeviceEndpoint extends PowProtectedEndpoint {
  @override
  String get endpointType => 'device';

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

      await verifyPow(
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
        lastActive: AnonAccountHelpers.roundToMinute(DateTime.now()),
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

      await verifyPow(
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

      await verifyPow(
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

    await verifyPow(
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
}
