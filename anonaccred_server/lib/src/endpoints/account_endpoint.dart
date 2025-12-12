import 'package:serverpod/serverpod.dart';
import '../crypto_auth.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../privacy_logger.dart';

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
      // Validate input parameters
      if (publicMasterKey.isEmpty) {
        final exception = AnonAccredExceptionFactory.createAuthenticationException(
          code: AnonAccredErrorCodes.authMissingKey,
          message: 'Public master key is required for account creation',
          operation: 'createAccount',
          details: {'publicMasterKey': 'empty'},
        );
        
        // Log account creation failure with privacy-safe information
        PrivacyLogger.logOperation(
          session,
          operation: 'createAccount',
          success: false,
          category: 'account_management',
          errorCode: AnonAccredErrorCodes.authMissingKey,
          safeData: {'publicMasterKey': 'empty'},
        );
        
        throw exception;
      }

      if (encryptedDataKey.isEmpty) {
        final exception = AnonAccredExceptionFactory.createAuthenticationException(
          code: AnonAccredErrorCodes.cryptoInvalidMessage,
          message: 'Encrypted data key is required for account creation',
          operation: 'createAccount',
          details: {'encryptedDataKey': 'empty'},
        );
        
        // Log account creation failure with privacy-safe information
        PrivacyLogger.logOperation(
          session,
          operation: 'createAccount',
          success: false,
          category: 'account_management',
          errorCode: AnonAccredErrorCodes.cryptoInvalidMessage,
          safeData: {'encryptedDataKey': 'empty'},
        );
        
        throw exception;
      }

      // Validate Ed25519 public key format using cryptographic utilities
      if (!CryptoAuth.isValidPublicKey(publicMasterKey)) {
        final exception = AnonAccredExceptionFactory.createAuthenticationException(
          code: AnonAccredErrorCodes.cryptoInvalidPublicKey,
          message: 'Invalid Ed25519 public key format',
          operation: 'createAccount',
          details: {
            'publicKeyLength': publicMasterKey.length.toString(),
            'expectedLength': '64',
          },
        );
        
        // Log account creation failure with privacy-safe information
        PrivacyLogger.logOperation(
          session,
          operation: 'createAccount',
          success: false,
          category: 'account_management',
          errorCode: AnonAccredErrorCodes.cryptoInvalidPublicKey,
          safeData: {
            'publicKeyLength': publicMasterKey.length.toString(),
            'expectedLength': '64',
          },
        );
        
        throw exception;
      }

      // Check if account with this public key already exists
      final existingAccount = await AnonAccount.db.findFirstRow(
        session,
        where: (t) => t.publicMasterKey.equals(publicMasterKey),
      );

      if (existingAccount != null) {
        final exception = AnonAccredExceptionFactory.createAuthenticationException(
          code: AnonAccredErrorCodes.authMissingKey, // Using existing error code for duplicate key
          message: 'Account with this public key already exists',
          operation: 'createAccount',
          details: {
            'publicMasterKey': publicMasterKey,
            'existingAccountId': existingAccount.id.toString(),
          },
        );
        
        // Log account creation failure with privacy-safe information
        PrivacyLogger.logOperation(
          session,
          operation: 'createAccount',
          success: false,
          category: 'account_management',
          errorCode: AnonAccredErrorCodes.authMissingKey,
          safeData: {
            'publicMasterKey': publicMasterKey,
            'reason': 'duplicate_key',
          },
        );
        
        throw exception;
      }

      // Log cryptographic validation success
      PrivacyLogger.logCryptographic(
        session,
        operation: 'public_key_validation',
        success: true,
        algorithm: 'Ed25519',
        keyType: 'public',
      );

      // Create new account - encrypted data is stored as-is without decryption
      final newAccount = AnonAccount(
        publicMasterKey: publicMasterKey,
        encryptedDataKey: encryptedDataKey,
        createdAt: DateTime.now(),
      );

      // Insert account into database
      final createdAccount = await AnonAccount.db.insertRow(session, newAccount);

      // Log successful account creation with privacy-safe information
      PrivacyLogger.logOperation(
        session,
        operation: 'createAccount',
        success: true,
        category: 'account_management',
        safeData: {
          'accountId': createdAccount.id.toString(),
          'publicMasterKey': publicMasterKey,
          'encryptedDataKeyLength': encryptedDataKey.length.toString(),
        },
      );

      return createdAccount;
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      // Log unexpected error
      PrivacyLogger.logOperation(
        session,
        operation: 'createAccount',
        success: false,
        category: 'account_management',
        errorCode: AnonAccredErrorCodes.internalError,
        safeData: {'error': e.toString()},
      );
      
      // Wrap unexpected errors in AnonAccred exception
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error during account creation: ${e.toString()}',
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
      // Validate input parameters
      if (publicMasterKey.isEmpty) {
        final exception = AnonAccredExceptionFactory.createAuthenticationException(
          code: AnonAccredErrorCodes.authMissingKey,
          message: 'Public master key is required for account lookup',
          operation: 'getAccountByPublicKey',
          details: {'publicMasterKey': 'empty'},
        );
        
        // Log account lookup failure with privacy-safe information
        PrivacyLogger.logOperation(
          session,
          operation: 'getAccountByPublicKey',
          success: false,
          category: 'account_management',
          errorCode: AnonAccredErrorCodes.authMissingKey,
          safeData: {'publicMasterKey': 'empty'},
        );
        
        throw exception;
      }

      // Validate Ed25519 public key format using cryptographic utilities
      if (!CryptoAuth.isValidPublicKey(publicMasterKey)) {
        final exception = AnonAccredExceptionFactory.createAuthenticationException(
          code: AnonAccredErrorCodes.cryptoInvalidPublicKey,
          message: 'Invalid Ed25519 public key format',
          operation: 'getAccountByPublicKey',
          details: {
            'publicKeyLength': publicMasterKey.length.toString(),
            'expectedLength': '64',
          },
        );
        
        // Log account lookup failure with privacy-safe information
        PrivacyLogger.logOperation(
          session,
          operation: 'getAccountByPublicKey',
          success: false,
          category: 'account_management',
          errorCode: AnonAccredErrorCodes.cryptoInvalidPublicKey,
          safeData: {
            'publicKeyLength': publicMasterKey.length.toString(),
            'expectedLength': '64',
          },
        );
        
        throw exception;
      }

      // Log cryptographic validation success
      PrivacyLogger.logCryptographic(
        session,
        operation: 'public_key_validation',
        success: true,
        algorithm: 'Ed25519',
        keyType: 'public',
      );

      // Lookup account by public key
      final account = await AnonAccount.db.findFirstRow(
        session,
        where: (t) => t.publicMasterKey.equals(publicMasterKey),
      );

      // Log account lookup result with privacy-safe information
      PrivacyLogger.logOperation(
        session,
        operation: 'getAccountByPublicKey',
        success: true,
        category: 'account_management',
        safeData: {
          'publicMasterKey': publicMasterKey,
          'accountFound': account != null ? 'true' : 'false',
          'accountId': account?.id?.toString() ?? 'null',
        },
      );

      return account;
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      // Log unexpected error
      PrivacyLogger.logOperation(
        session,
        operation: 'getAccountByPublicKey',
        success: false,
        category: 'account_management',
        errorCode: AnonAccredErrorCodes.internalError,
        safeData: {'error': e.toString()},
      );
      
      // Wrap unexpected errors in AnonAccred exception
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Unexpected error during account lookup: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }
}