import '../pow_methods.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../crypto_auth.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../helpers.dart';
import 'signed_pow_endpoint.dart';

/// Public device endpoints protected by hashcash proof-of-work.
///
/// Extends [SignedPowEndpoint] to inherit `getChallenge()` and `verifySignedPow()`.
///
/// Handles unauthenticated device operations:
/// - Device registration
/// - Auth challenge generation
/// - Device pairing lookup and monitoring
///
/// Authenticated device operations (revoke, list, QR pairing) are in
/// [DeviceManagementEndpoint].
class DeviceEndpoint extends SignedPowEndpoint {
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
      // Verify PoW + signature + rate limit (device key signs the challenge)
      final payload =
          '$challenge:${DeviceMethods.registerDevice}:$deviceSigningPublicKeyHex';

      await verifySignedPow(
        session,
        challenge,
        proofOfWork,
        deviceSigningPublicKeyHex,
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
        accountUuid: account.accountUuid,
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

  /// Sign in with a registered device (PoW-protected).
  ///
  /// Verifies PoW + ECDSA signature, looks up the device, and issues
  /// an authentication token via the host-configured token issuer.
  ///
  /// Returns an [AuthenticationResult] containing the token on success.
  Future<AuthenticationResult> signIn(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String devicePublicKeyHex,
  }) async {
    try {
      // Verify PoW + signature + rate limit
      final payload = '$challenge:${DeviceMethods.signIn}:$devicePublicKeyHex';

      await verifySignedPow(
        session,
        challenge,
        proofOfWork,
        devicePublicKeyHex,
        signature,
        payload,
      );

      // Look up device and verify it's active
      final device = await AccountDevice.db.findFirstRow(
        session,
        where: (t) =>
            t.deviceSigningPublicKeyHex.equals(devicePublicKeyHex),
      );

      final activeDevice = AnonAccountHelpers.requireActiveDevice(
        device,
        devicePublicKeyHex,
        'signIn',
      );

      // Update last active timestamp
      await AccountDevice.db.updateRow(
        session,
        activeDevice.copyWith(
          lastActive: AnonAccountHelpers.roundToMinute(DateTime.now()),
        ),
      );

      // Issue JWT via Serverpod's built-in token manager
      final authSuccess = await AuthServices.instance.tokenManager.issueToken(
        session,
        authUserId: activeDevice.accountUuid,
        method: 'anonaccount',
        scopes: {Scope('device:$devicePublicKeyHex')},
      );

      return AuthenticationResultFactory.success(
        deviceId: activeDevice.id,
        details: {
          'token': authSuccess.token,
          if (authSuccess.refreshToken != null)
            'refreshToken': authSuccess.refreshToken!,
          'deviceSigningPublicKeyHex': devicePublicKeyHex,
        },
      );
    } on AuthenticationException {
      rethrow;
    } catch (e, stackTrace) {
      session.log(
        'DeviceEndpoint: signIn error: $e\n$stackTrace',
        level: LogLevel.error,
      );
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Sign in failed: ${e.toString()}',
        operation: 'signIn',
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
        '$challenge:${DeviceMethods.monitorRegistration}:$signingKeyHex';

    await verifySignedPow(
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
