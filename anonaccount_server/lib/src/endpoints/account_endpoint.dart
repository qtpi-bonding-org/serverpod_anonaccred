import '../pow_methods.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../crypto_utils.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../helpers.dart';
import 'signed_pow_endpoint.dart';

/// Account endpoint with PoW + signature protection.
///
/// Extends [SignedPowEndpoint] to inherit `getChallenge()` and `verifySignedPow()`.
///
/// Provides account creation with:
/// - Hashcash proof-of-work for spam prevention
/// - ECDSA P-256 signature verification
/// - Redis-based rate limiting by public key
/// - Atomic first-device registration (account + device in one call)
///
/// Server-only query methods (getAccountById, getAccountByPublicKey) live
/// in [AccountQueryService] — not exposed to clients.
class AccountEndpoint extends SignedPowEndpoint {
  @override
  String get endpointType => 'account';

  /// Create new anonymous account with first device, atomically.
  ///
  /// Creates the account and registers the first device in a single call.
  /// An account without a device is useless, so this ensures they're always
  /// created together. Additional devices use [DeviceEndpoint.registerDevice].
  ///
  /// Returns [AccountCreationResponse] — no internal int id exposed to client.
  Future<AccountCreationResponse> createAccount(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String publicKeyHex,
    required PublicKeyDuo ultimateKeys,
    required String encryptedDataKey,
    required PublicKeyDuo deviceKeys,
    required String deviceKeyAttestation,
    required String deviceEncryptedDataKey,
    required String deviceLabel,
  }) async {
    try {
      // Task 6 widens the parameter shape to PublicKeyDuo for both ultimate
      // and device keys. The single-signing-key envelope/attestation logic
      // stays exactly as-is for now — Tasks 7-9 will upgrade it to sign
      // over both halves of the duo.
      final ultimateSigningPublicKeyHex = ultimateKeys.signingPublicKeyHex;
      final ultimateEncryptionPublicKeyHex =
          ultimateKeys.encryptionPublicKeyHex;
      final deviceSigningPublicKeyHex = deviceKeys.signingPublicKeyHex;

      final payload =
          '$challenge:${AccountMethods.createAccount}:$ultimateSigningPublicKeyHex';

      await verifySignedPow(
        session,
        challenge,
        proofOfWork,
        publicKeyHex,
        signature,
        payload,
      );

      // Validate account params
      AnonAccountHelpers.validatePublicKey(
        ultimateSigningPublicKeyHex,
        'createAccount',
      );
      AnonAccountHelpers.validatePublicKey(
        ultimateEncryptionPublicKeyHex,
        'createAccount',
      );
      AnonAccountHelpers.validateNonEmpty(
        encryptedDataKey,
        'encryptedDataKey',
        'createAccount',
      );

      // Verify attestation: ultimate key authorized this device key
      // Task 7 upgrades this to verify over both halves of deviceKeys; for
      // now the existing single-signing-key check stands.
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
          operation: 'createAccount',
        );
      }

      // Check for duplicate account (using the renamed encryption field).
      final existingByDevice = await AnonAccount.db.findFirstRow(
        session,
        where: (t) => t.ultimateSigningPublicKeyHex
            .equals(ultimateSigningPublicKeyHex),
      );

      if (existingByDevice != null) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authDuplicateDevice,
          message: 'Account with this device public key already exists',
          operation: 'createAccount',
          details: {
            'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
          },
        );
      }

      final existingByUltimate = await AnonAccount.db.findFirstRow(
        session,
        where: (t) => t.ultimateEncryptionPublicKeyHex.equals(
          ultimateEncryptionPublicKeyHex,
        ),
      );

      if (existingByUltimate != null) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authDuplicateDevice,
          message: 'Account with this ultimate key already exists',
          operation: 'createAccount',
          details: {
            'ultimateEncryptionPublicKeyHex': ultimateEncryptionPublicKeyHex,
          },
        );
      }

      // Create Serverpod AuthUser (generates UUID for JWT identity)
      final authUser = await AuthServices.instance.authUsers.create(session);

      final now = DateTime.now();
      final newAccount = AnonAccount(
        id: authUser.id,
        ultimateSigningPublicKeyHex: ultimateSigningPublicKeyHex,
        encryptedDataKey: encryptedDataKey,
        ultimateEncryptionPublicKeyHex: ultimateEncryptionPublicKeyHex,
        createdAt: now,
      );

      await AnonAccount.db.insertRow(session, newAccount);

      // Insert the first device via the shared helper. Task 6 widens the
      // helper's required parameters (now also accepts the encryption key,
      // signer pubkey, and attestation); the atomic-write path that signs
      // over the actual duo belongs to Tasks 7-9. For Task 6 we just
      // thread the duo through unchanged.
      await AnonAccountHelpers.insertDevice(
        session,
        accountId: authUser.id,
        deviceKeys: deviceKeys,
        encryptedDataKey: deviceEncryptedDataKey,
        label: deviceLabel,
        addedBySignerPublicKeyHex: ultimateSigningPublicKeyHex,
        addedByAttestation: deviceKeyAttestation,
        operation: 'createAccount',
      );

      session.log(
        'AccountEndpoint: Account + first device created successfully',
        level: LogLevel.info,
      );
      return AccountCreationResponse(
        ultimateSigningPublicKeyHex: ultimateSigningPublicKeyHex,
        encryptedDataKey: encryptedDataKey,
        ultimateEncryptionPublicKeyHex: ultimateEncryptionPublicKeyHex,
        createdAt: now,
      );
    } on AuthenticationException {
      rethrow;
    } catch (e, stackTrace) {
      session.log(
        'AccountEndpoint: Unexpected error: $e\n$stackTrace',
        level: LogLevel.error,
      );
      throw AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.internalError,
        message: 'Unexpected error during account creation: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }
}