import '../pow_methods.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../crypto_auth.dart';
import '../crypto_utils.dart';
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
    required String deviceKeyAttestation,
    required String ultimateSigningPublicKeyHex,
    required String deviceSigningPublicKeyHex,
    required String encryptedDataKey,
    required String label,
  }) async {
    try {
      // 1. Verify attestation: ultimate key authorized this device key
      final attestationValid = await CryptoUtils.verifySignature(
        message: AccountInnerPayloads.deviceAttestation(deviceSigningPublicKeyHex),
        signature: deviceKeyAttestation,
        publicKey: ultimateSigningPublicKeyHex,
      );
      if (!attestationValid) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.cryptoInvalidSignature,
          message:
              'Invalid device key attestation — ultimate key did not authorize this device',
          operation: 'registerDevice',
        );
      }

      // 2. Verify PoW + signature + rate limit (device key proves liveness)
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

      // Validate ultimate key and resolve account
      AnonAccountHelpers.validatePublicKey(
        ultimateSigningPublicKeyHex,
        'registerDevice',
      );

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

      // Validate + duplicate check + insert via shared helper
      final insertedDevice = await AnonAccountHelpers.insertDevice(
        session,
        accountId: account.id!,
        deviceSigningPublicKeyHex: deviceSigningPublicKeyHex,
        encryptedDataKey: encryptedDataKey,
        label: label,
        operation: 'registerDevice',
      );

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

      // Look up account to get ultimate public key hex for client
      final account = await AnonAccount.db.findById(
        session,
        activeDevice.anonAccountId,
      );

      // Issue JWT via Serverpod's built-in token manager
      final authSuccess = await AuthServices.instance.tokenManager.issueToken(
        session,
        authUserId: activeDevice.anonAccountId,
        method: 'anonaccount',
        scopes: {Scope('device:$devicePublicKeyHex')},
      );

      return AuthenticationResultFactory.success(
        deviceId: activeDevice.id,
        accountPublicKeyHex: account?.ultimateSigningPublicKeyHex,
        details: {
          'token': authSuccess.token,
          if (authSuccess.tokenExpiresAt != null)
            'tokenExpiresAt': authSuccess.tokenExpiresAt!.toIso8601String(),
          if (authSuccess.refreshToken != null)
            'refreshToken': authSuccess.refreshToken!,
          'authUserId': activeDevice.anonAccountId.toString(),
          'authStrategy': authSuccess.authStrategy,
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
