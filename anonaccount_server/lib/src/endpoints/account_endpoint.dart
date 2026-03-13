import 'package:serverpod/serverpod.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../helpers.dart';

/// Account management endpoints for anonymous identity operations.
///
/// Abstract so consuming projects must provide a concrete subclass with
/// their own spam-prevention strategy (e.g. proof-of-work) on createAccount.
/// Query methods (getAccountById, getAccountByPublicKey, getAccountForRecovery)
/// are inherited as-is.
abstract class AccountEndpoint extends Endpoint {
  /// Create new anonymous account with ECDSA P-256 public key identity.
  ///
  /// Returns [AccountCreationResponse] — no internal int id exposed to client.
  Future<AccountCreationResponse> createAccount(
    Session session,
    String ultimateSigningPublicKeyHex,
    String encryptedDataKey,
    String ultimatePublicKey,
  ) async {
    try {
      AnonAccountHelpers.validatePublicKey(ultimateSigningPublicKeyHex, 'createAccount');
      AnonAccountHelpers.validatePublicKey(ultimatePublicKey, 'createAccount');
      AnonAccountHelpers.validateNonEmpty(encryptedDataKey, 'encryptedDataKey', 'createAccount');

      final existingByDevice = await AnonAccount.db.findFirstRow(
        session,
        where: (t) => t.ultimateSigningPublicKeyHex.equals(ultimateSigningPublicKeyHex),
      );

      if (existingByDevice != null) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authDuplicateDevice,
          message: 'Account with this device public key already exists',
          operation: 'createAccount',
          details: {'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex},
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

      final now = DateTime.now();
      final newAccount = AnonAccount(
        ultimateSigningPublicKeyHex: ultimateSigningPublicKeyHex,
        encryptedDataKey: encryptedDataKey,
        ultimatePublicKey: ultimatePublicKey,
        createdAt: now,
      );

      await AnonAccount.db.insertRow(session, newAccount);

      session.log('AccountEndpoint: Account created successfully', level: LogLevel.info);
      return AccountCreationResponse(
        ultimateSigningPublicKeyHex: ultimateSigningPublicKeyHex,
        encryptedDataKey: encryptedDataKey,
        ultimatePublicKey: ultimatePublicKey,
        createdAt: now,
      );
    } on AuthenticationException {
      rethrow;
    } catch (e, stackTrace) {
      session.log('AccountEndpoint: Unexpected error: $e\n$stackTrace', level: LogLevel.error);
      throw AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.internalError,
        message: 'Unexpected error during account creation: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }

  /// Get account by ID, requiring it to exist
  Future<AnonAccount> getAccountById(
    Session session,
    int accountId,
  ) async {
    try {
      final account = await AnonAccount.db.findById(session, accountId);
      return AnonAccountHelpers.requireAccount(account, accountId, 'getAccountById');
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.internalError,
        message: 'Unexpected error during account lookup: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }

  /// Get account by public master key lookup
  Future<AnonAccount?> getAccountByPublicKey(
    Session session,
    String ultimateSigningPublicKeyHex,
  ) async {
    try {
      AnonAccountHelpers.validatePublicKey(ultimateSigningPublicKeyHex, 'getAccountByPublicKey');
      final account = await AnonAccount.db.findFirstRow(
        session,
        where: (t) => t.ultimateSigningPublicKeyHex.equals(ultimateSigningPublicKeyHex),
      );
      return account;
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.internalError,
        message: 'Unexpected error during account lookup: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }

  /// Get account for recovery by ultimate public key
  Future<AnonAccount?> getAccountForRecovery(
    Session session,
    String ultimatePublicKey,
  ) async {
    try {
      AnonAccountHelpers.validatePublicKey(ultimatePublicKey, 'getAccountForRecovery');
      final account = await AnonAccount.db.findFirstRow(
        session,
        where: (t) => t.ultimatePublicKey.equals(ultimatePublicKey),
      );
      return account;
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.internalError,
        message: 'Unexpected error during recovery lookup: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }
}
