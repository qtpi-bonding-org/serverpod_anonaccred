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
  /// Create new anonymous account with Ed25519 public key identity
  ///
  /// Parameters:
  /// - [publicMasterKey]: Ed25519 public key as hex string (64 chars)
  /// - [encryptedDataKey]: Client-encrypted symmetric data key (never decrypted server-side)
  ///
  /// Returns the created AnonAccount with assigned ID.
  ///
  /// Throws AuthenticationException if public key validation fails.
  /// Throws AnonAccredException for database or system errors.
  Future<AnonAccount> createAccount(
    Session session,
    String publicMasterKey,
    String encryptedDataKey,
  ) async {
    try {
      // Validate input parameters using helper functions
      AnonAccredHelpers.validatePublicKey(publicMasterKey, 'createAccount');
      AnonAccredHelpers.validateNonEmpty(encryptedDataKey, 'encryptedDataKey', 'createAccount');

      // Check if account with this public key already exists
      final existingAccount = await AnonAccount.db.findFirstRow(
        session,
        where: (t) => t.publicMasterKey.equals(publicMasterKey),
      );

      if (existingAccount != null) {
        final exception =
            AnonAccredExceptionFactory.createAuthenticationException(
              code: AnonAccredErrorCodes
                  .authMissingKey, // Using existing error code for duplicate key
              message: 'Account with this public key already exists',
              operation: 'createAccount',
              details: {
                'publicMasterKey': publicMasterKey,
                'existingAccountId': existingAccount.id.toString(),
              },
            );

        throw exception;
      }

      // Create new account - encrypted data is stored as-is without decryption
      final newAccount = AnonAccount(
        publicMasterKey: publicMasterKey,
        encryptedDataKey: encryptedDataKey,
        createdAt: DateTime.now(),
      );

      // Insert account into database
      final createdAccount = await AnonAccount.db.insertRow(
        session,
        newAccount,
      );

      return createdAccount;
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      // Log unexpected error

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
  /// - [publicMasterKey]: Ed25519 public key as hex string (64 chars)
  ///
  /// Returns the AnonAccount if found, null if not found.
  ///
  /// Throws AuthenticationException if public key validation fails.
  /// Throws AnonAccredException for database or system errors.
  Future<AnonAccount?> getAccountByPublicKey(
    Session session,
    String publicMasterKey,
  ) async {
    try {
      // Validate input parameters using helper functions
      AnonAccredHelpers.validatePublicKey(publicMasterKey, 'getAccountByPublicKey');

      // Lookup account by public key
      final account = await AnonAccount.db.findFirstRow(
        session,
        where: (t) => t.publicMasterKey.equals(publicMasterKey),
      );

      return account;
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      // Log unexpected error

      // Wrap unexpected errors in AnonAccred exception
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error during account lookup: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }
}
