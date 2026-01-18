import 'package:serverpod/serverpod.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../helpers.dart';

/// Account management endpoints for anonymous identity operations
///
/// This endpoint provides cryptographic account creation and lookup functionality
/// while maintaining strict zero-PII architecture:
/// - Only handles public keys and encrypted data
/// - Never generates, stores, or processes private keys
/// - All encrypted data is stored as-is without decryption attempts
class AccountEndpoint extends Endpoint {
  /// Create new anonymous account with ECDSA P-256 public key identity
  ///
  /// Parameters:
  /// - [ultimateSigningPublicKeyHex]: Ultimate ECDSA P-256 public key (128 hex chars, x||y coordinates)
  /// - [encryptedDataKey]: Recovery blob (symmetric key encrypted with ultimate public key)
  /// - [ultimatePublicKey]: Ultimate ECDSA P-256 public key (128 hex chars) for recovery lookup
  ///
  /// Returns the created AnonAccount with assigned ID.
  ///
  /// Throws AuthenticationException if public key validation fails or duplicate key exists.
  /// Throws AnonAccredException for database or system errors.
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
      // Validate input parameters using helper functions
      session.log('AccountEndpoint: Validating input parameters...', level: LogLevel.info);
      AnonAccredHelpers.validatePublicKey(ultimateSigningPublicKeyHex, 'createAccount');
      AnonAccredHelpers.validatePublicKey(ultimatePublicKey, 'createAccount');
      AnonAccredHelpers.validateNonEmpty(encryptedDataKey, 'encryptedDataKey', 'createAccount');
      session.log('AccountEndpoint: Input validation passed', level: LogLevel.info);

      // Check if account with this device public key already exists
      session.log('AccountEndpoint: Checking for existing account by device key...', level: LogLevel.info);
      final existingByDevice = await AnonAccount.db.findFirstRow(
        session,
        where: (t) => t.ultimateSigningPublicKeyHex.equals(ultimateSigningPublicKeyHex),
      );

      if (existingByDevice != null) {
        session.log('AccountEndpoint: ERROR - Account with device key already exists, ID: ${existingByDevice.id}', level: LogLevel.error);
        throw AnonAccredExceptionFactory.createAuthenticationException(
          code: AnonAccredErrorCodes.authDuplicateDevice,
          message: 'Account with this device public key already exists',
          operation: 'createAccount',
          details: {
            'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
            'existingAccountId': existingByDevice.id.toString(),
          },
        );
      }
      session.log('AccountEndpoint: No existing account found by device key', level: LogLevel.info);

      // Check if account with this ultimate public key already exists
      session.log('AccountEndpoint: Checking for existing account by ultimate key...', level: LogLevel.info);
      final existingByUltimate = await AnonAccount.db.findFirstRow(
        session,
        where: (t) => t.ultimatePublicKey.equals(ultimatePublicKey),
      );

      if (existingByUltimate != null) {
        session.log('AccountEndpoint: ERROR - Account with ultimate key already exists, ID: ${existingByUltimate.id}', level: LogLevel.error);
        throw AnonAccredExceptionFactory.createAuthenticationException(
          code: AnonAccredErrorCodes.authDuplicateDevice,
          message: 'Account with this ultimate key already exists',
          operation: 'createAccount',
          details: {
            'ultimatePublicKey': ultimatePublicKey,
            'existingAccountId': existingByUltimate.id.toString(),
          },
        );
      }
      session.log('AccountEndpoint: No existing account found by ultimate key', level: LogLevel.info);

      // Create new account - encrypted data is stored as-is without decryption
      session.log('AccountEndpoint: Creating new account...', level: LogLevel.info);
      final newAccount = AnonAccount(
        ultimateSigningPublicKeyHex: ultimateSigningPublicKeyHex,
        encryptedDataKey: encryptedDataKey,
        ultimatePublicKey: ultimatePublicKey,
        createdAt: DateTime.now(),
      );

      // Insert account into database
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
      // Wrap unexpected errors in AnonAccred exception
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error during account creation: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }

  /// Get account by ID, requiring it to exist
  ///
  /// Parameters:
  /// - [accountId]: The account ID to lookup
  ///
  /// Returns the AnonAccount if found.
  ///
  /// Throws AuthenticationException if account is not found.
  /// Throws AnonAccredException for database or system errors.
  Future<AnonAccount> getAccountById(
    Session session,
    int accountId,
  ) async {
    try {
      // Lookup account by ID
      final account = await AnonAccount.db.findById(session, accountId);
      
      // Use helper to require account exists, throw if null
      return AnonAccredHelpers.requireAccount(account, accountId, 'getAccountById');
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      // Wrap unexpected errors in AnonAccred exception
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error during account lookup: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }

  /// Get account by public master key lookup
  ///
  /// Parameters:
  /// - [ultimateSigningPublicKeyHex]: ECDSA P-256 public key as hex string (128 chars, x||y coordinates)
  ///
  /// Returns the AnonAccount if found, null if not found.
  ///
  /// Throws AuthenticationException if public key validation fails.
  /// Throws AnonAccredException for database or system errors.
  Future<AnonAccount?> getAccountByPublicKey(
    Session session,
    String ultimateSigningPublicKeyHex,
  ) async {
    try {
      // Validate input parameters using helper functions
      AnonAccredHelpers.validatePublicKey(ultimateSigningPublicKeyHex, 'getAccountByPublicKey');

      // Lookup account by public key
      final account = await AnonAccount.db.findFirstRow(
        session,
        where: (t) => t.ultimateSigningPublicKeyHex.equals(ultimateSigningPublicKeyHex),
      );

      return account;
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      // Wrap unexpected errors in AnonAccred exception
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error during account lookup: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }

  /// Get account for recovery by ultimate public key
  ///
  /// This endpoint is used during account recovery when a user has lost all devices
  /// but has their ultimate private key backup. The ultimate public key is derived
  /// from the backup and used to look up the account.
  ///
  /// Parameters:
  /// - [ultimatePublicKey]: ECDSA P-256 public key from ultimate JWK (128 hex chars)
  ///
  /// Returns the AnonAccount with recovery blob if found, null if not found.
  /// The recovery blob (encryptedDataKey) can be decrypted with the ultimate private key.
  ///
  /// SECURITY: This endpoint is unauthenticated (user has no device).
  /// Only returns data that requires the ultimate private key to decrypt.
  ///
  /// Throws AuthenticationException if public key validation fails.
  /// Throws AnonAccredException for database or system errors.
  Future<AnonAccount?> getAccountForRecovery(
    Session session,
    String ultimatePublicKey,
  ) async {
    try {
      // Validate input parameters using helper functions
      AnonAccredHelpers.validatePublicKey(ultimatePublicKey, 'getAccountForRecovery');

      // Lookup account by ultimate public key
      final account = await AnonAccount.db.findFirstRow(
        session,
        where: (t) => t.ultimatePublicKey.equals(ultimatePublicKey),
      );

      return account;
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      // Wrap unexpected errors in AnonAccred exception
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error during recovery lookup: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }
}
