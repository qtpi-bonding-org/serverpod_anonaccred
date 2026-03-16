import '../pow_methods.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../helpers.dart';
import 'signed_pow_endpoint.dart';

/// Account endpoint with PoW + signature protection.
///
/// Extends [SignedPowEndpoint] to inherit `getChallenge()` and `verifySignedPow()`.
///
/// Provides account creation and recovery with:
/// - Hashcash proof-of-work for spam prevention
/// - ECDSA P-256 signature verification
/// - Redis-based rate limiting by public key
///
/// Server-only query methods (getAccountById, getAccountByPublicKey) live
/// in [AccountQueryService] — not exposed to clients.
class AccountEndpoint extends SignedPowEndpoint {
  @override
  String get endpointType => 'account';

  /// Create new anonymous account with PoW verification.
  ///
  /// Returns [AccountCreationResponse] — no internal int id exposed to client.
  Future<AccountCreationResponse> createAccount(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String publicKeyHex,
    required String ultimateSigningPublicKeyHex,
    required String encryptedDataKey,
    required String ultimatePublicKey,
  }) async {
    try {
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

      AnonAccountHelpers.validatePublicKey(
        ultimateSigningPublicKeyHex,
        'createAccount',
      );
      AnonAccountHelpers.validatePublicKey(
        ultimatePublicKey,
        'createAccount',
      );
      AnonAccountHelpers.validateNonEmpty(
        encryptedDataKey,
        'encryptedDataKey',
        'createAccount',
      );

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
        where: (t) => t.ultimatePublicKey.equals(ultimatePublicKey),
      );

      if (existingByUltimate != null) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authDuplicateDevice,
          message: 'Account with this ultimate key already exists',
          operation: 'createAccount',
          details: {'ultimatePublicKey': ultimatePublicKey},
        );
      }

      // Create Serverpod AuthUser (generates UUID for JWT identity)
      final authUser = await AuthServices.instance.authUsers.create(session);

      final now = DateTime.now();
      final newAccount = AnonAccount(
        id: authUser.id,
        ultimateSigningPublicKeyHex: ultimateSigningPublicKeyHex,
        encryptedDataKey: encryptedDataKey,
        ultimatePublicKey: ultimatePublicKey,
        createdAt: now,
      );

      await AnonAccount.db.insertRow(session, newAccount);

      session.log(
        'AccountEndpoint: Account created successfully',
        level: LogLevel.info,
      );
      return AccountCreationResponse(
        ultimateSigningPublicKeyHex: ultimateSigningPublicKeyHex,
        encryptedDataKey: encryptedDataKey,
        ultimatePublicKey: ultimatePublicKey,
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
