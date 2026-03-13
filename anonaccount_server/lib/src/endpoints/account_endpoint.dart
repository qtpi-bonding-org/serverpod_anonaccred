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
  /// Create new anonymous account with ECDSA P-256 public key identity
  Future<AnonAccount> createAccount(
    Session session,
    String ultimateSigningPublicKeyHex,
    String encryptedDataKey,
    String ultimatePublicKey,
  ) async {
    session.log('AccountEndpoint: createAccount called', level: LogLevel.info);
    session.log('AccountEndpoint: ultimateSigningPublicKeyHex length: ${ultimateSigningPublicKeyHex.length}', level: LogLevel.info);
    session.log('AccountEndpoint: ultimateSigningPublicKeyHex prefix: ${ultimateSigningPublicKeyHex.length > 20 ? ultimateSigningPublicKeyHex.substring(0, 20) : ultimateSigningPublicKeyHex}...', level: LogLevel.info);
    session.log('AccountEndpoint: encryptedDataKey length: ${encryptedDataKey.length}', level: LogLevel.info);
    session.log('AccountEndpoint: ultimatePublicKey length: ${ultimatePublicKey.length}', level: LogLevel.info);

    try {
      session.log('AccountEndpoint: Validating input parameters...', level: LogLevel.info);
      AnonAccountHelpers.validatePublicKey(ultimateSigningPublicKeyHex, 'createAccount');
      AnonAccountHelpers.validatePublicKey(ultimatePublicKey, 'createAccount');
      AnonAccountHelpers.validateNonEmpty(encryptedDataKey, 'encryptedDataKey', 'createAccount');
      session.log('AccountEndpoint: Input validation passed', level: LogLevel.info);

      session.log('AccountEndpoint: Checking for existing account by device key...', level: LogLevel.info);
      final existingByDevice = await AnonAccount.db.findFirstRow(
        session,
        where: (t) => t.ultimateSigningPublicKeyHex.equals(ultimateSigningPublicKeyHex),
      );

      if (existingByDevice != null) {
        session.log('AccountEndpoint: ERROR - Account with device key already exists, ID: ${existingByDevice.id}', level: LogLevel.error);
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authDuplicateDevice,
          message: 'Account with this device public key already exists',
          operation: 'createAccount',
          details: {
            'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
            'existingAccountId': existingByDevice.id.toString(),
          },
        );
      }
      session.log('AccountEndpoint: No existing account found by device key', level: LogLevel.info);

      session.log('AccountEndpoint: Checking for existing account by ultimate key...', level: LogLevel.info);
      final existingByUltimate = await AnonAccount.db.findFirstRow(
        session,
        where: (t) => t.ultimatePublicKey.equals(ultimatePublicKey),
      );

      if (existingByUltimate != null) {
        session.log('AccountEndpoint: ERROR - Account with ultimate key already exists, ID: ${existingByUltimate.id}', level: LogLevel.error);
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authDuplicateDevice,
          message: 'Account with this ultimate key already exists',
          operation: 'createAccount',
          details: {
            'ultimatePublicKey': ultimatePublicKey,
            'existingAccountId': existingByUltimate.id.toString(),
          },
        );
      }
      session.log('AccountEndpoint: No existing account found by ultimate key', level: LogLevel.info);

      session.log('AccountEndpoint: Creating new account...', level: LogLevel.info);
      final newAccount = AnonAccount(
        ultimateSigningPublicKeyHex: ultimateSigningPublicKeyHex,
        encryptedDataKey: encryptedDataKey,
        ultimatePublicKey: ultimatePublicKey,
        createdAt: DateTime.now(),
      );

      session.log('AccountEndpoint: Inserting account into database...', level: LogLevel.info);
      final createdAccount = await AnonAccount.db.insertRow(
        session,
        newAccount,
      );

      session.log('AccountEndpoint: Account created successfully with ID: ${createdAccount.id}', level: LogLevel.info);
      return createdAccount;
    } on AuthenticationException catch (e) {
      session.log('AccountEndpoint: Authentication exception: $e', level: LogLevel.error);
      rethrow;
    } catch (e, stackTrace) {
      session.log('AccountEndpoint: Unexpected error: $e', level: LogLevel.error);
      session.log('AccountEndpoint: Stack trace: $stackTrace', level: LogLevel.error);
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
