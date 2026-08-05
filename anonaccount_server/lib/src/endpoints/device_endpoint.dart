import 'package:anonaccount_protocol/anonaccount_protocol.dart' hide Protocol;
import '../protocol_failures.dart';
import '../try_operation.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../crypto_auth.dart';
import '../crypto_utils.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../queries/active_rows.dart';
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
    required PublicKeyDuo deviceKeys,
    required String encryptedDataKey,
    required String label,
  }) async {
    return tryOperation(
      session,
      'registerDevice',
      () async {
        final keys = AnonAccountHelpers.validateKeyDuo(
          deviceKeys,
          'registerDevice',
        );
        final deviceSigningPublicKeyHex = keys.signingPublicKeyHex;

        // 1. Verify attestation: ultimate key authorized this device key pair.
        // Covers BOTH halves — the encryption key becomes a wrap target, so
        // it must be inside the signature rather than beside it.
        final attestationValid = await CryptoUtils.verifySignature(
          message: AccountInnerPayloads.registerDevice(keys),
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

        // Validate ultimate key and resolve account.
        AnonAccountHelpers.validatePublicKey(
          ultimateSigningPublicKeyHex,
          'registerDevice',
        );

        final account = await AnonAccount.db.findFirstRow(
          session,
          where: (t) =>
              t.ultimateSigningPublicKeyHex.equals(ultimateSigningPublicKeyHex),
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

        final insertedDevice = await AnonAccountHelpers.insertDevice(
          session,
          accountId: account.id!,
          deviceKeys: keys,
          encryptedDataKey: encryptedDataKey,
          label: label,
          addedByAttestorPublicKeyHex: ultimateSigningPublicKeyHex,
          addedByAttestation: deviceKeyAttestation,
          operation: 'registerDevice',
        );

        session.log(
          'DeviceEndpoint: Device registered successfully with ID: ${insertedDevice.id}',
          level: LogLevel.info,
        );
        return insertedDevice;
      },
      onFailure: authFailure,
      code: AnonAccountErrorCodes.databaseError,
    );
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
    return tryOperation(
      session,
      'signIn',
      () async {
        final activeDevice = (await guard(
          session,
          challenge: challenge,
          proofOfWork: proofOfWork,
          signature: signature,
          callerDeviceSigningPublicKeyHex: devicePublicKeyHex,
          methodName: DeviceMethods.signIn,
        )).device;

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
      },
      onFailure: authFailure,
      code: AnonAccountErrorCodes.databaseError,
    );
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
    // Subscribe before doing anything else, including PoW verification.
    // session.messages is fire-and-forget: a postMessage with no current
    // subscriber on the channel is dropped, not queued. createStream() is a
    // cheap, synchronous, in-memory registration — it exposes no data and
    // costs nothing extra to open early, so there's no tradeoff in doing it
    // before verification instead of after. Any later ordering (verify then
    // subscribe) leaves a real gap: a registration landing during PoW
    // verification would be lost forever, with the caller waiting on a
    // stream event that already happened.
    final channelName = 'pairing-updates-$signingKeyHex';
    final stream = session.messages.createStream<DevicePairingEvent>(
      channelName,
    );

    // Verify PoW + signature + rate limit before returning any data.
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

    final existingDevice = await ActiveRows.deviceBySigningKey(
      session,
      signingKeyHex,
    );
    if (existingDevice != null) {
      final account = await AnonAccount.db.findById(
        session,
        existingDevice.anonAccountId,
      );
      yield DevicePairingEvent(
        encryptedDataKey: existingDevice.encryptedDataKey,
        signingKeyHex: existingDevice.deviceSigningPublicKeyHex,
        ultimateEncryptionPublicKeyHex: account!.ultimateEncryptionPublicKeyHex,
        ultimateSigningPublicKeyHex: account.ultimateSigningPublicKeyHex,
      );
      return;
    }

    // Only one insert ever posts to this channel, so the first event is the
    // only one that will ever arrive — without an explicit stop, this
    // generator keeps its subscription (and DB session) alive forever
    // waiting for a second event that will never come.
    yield await stream.first;
  }
}
