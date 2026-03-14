import 'package:serverpod/serverpod.dart';

import '../entitlement_manager.dart';
import '../entitlement_utils.dart';
import 'package:anonaccount_server/anonaccount_server.dart';

import '../generated/protocol.dart';

/// Commerce endpoints for entitlement queries and consumption.
///
/// Provides authenticated access to entitlement balances and consumption.
class CommerceEndpoint extends Endpoint {
  /// Get entitlements for an account
  Future<List<AccountEntitlement>> getEntitlements(
    Session session,
    String publicKey,
    String signature,
  ) async {
    try {
      // Validate authentication
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'getEntitlements',
      );

      // Resolve accountId from device public key
      final accountId = await AnonAccountHelpers.resolveAccountId(
        session, publicKey, 'getEntitlements',
      );

      // Get entitlements using EntitlementManager
      final entitlements = await EntitlementManager.getAccountEntitlements(
        session,
        accountId: accountId,
      );

      return entitlements;
    } on AuthenticationException {
      rethrow;
    } on InventoryException {
      rethrow;
    } catch (e) {
      throw AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.internalError,
        message: 'Unexpected error getting entitlements: ${e.toString()}',
      );
    }
  }

  /// Get balance for a specific entitlement tag
  Future<double> getEntitlementBalance(
    Session session,
    String publicKey,
    String signature,
    String tag,
  ) async {
    try {
      // Validate authentication
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'getEntitlementBalance',
      );

      // Resolve accountId from device public key
      final accountId = await AnonAccountHelpers.resolveAccountId(
        session, publicKey, 'getEntitlementBalance',
      );

      // Get balance using EntitlementManager
      final balance = await EntitlementManager.getEntitlementBalance(
        session,
        accountId: accountId,
        tag: tag,
      );

      return balance;
    } on AuthenticationException {
      rethrow;
    } on InventoryException {
      rethrow;
    } catch (e) {
      throw AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.internalError,
        message: 'Unexpected error getting balance: ${e.toString()}',
      );
    }
  }

  /// Consume entitlement using atomic utilities
  Future<ConsumeResult> consumeEntitlement(
    Session session,
    String publicKey,
    String signature,
    String tag,
    double quantity,
  ) async {
    try {
      // Validate authentication
      await _validateAuthentication(
        session,
        publicKey,
        signature,
        'consumeEntitlement',
      );

      // Resolve accountId from device public key
      final accountId = await AnonAccountHelpers.resolveAccountId(
        session, publicKey, 'consumeEntitlement',
      );

      // Attempt consumption using EntitlementUtils
      final result = await EntitlementUtils.tryConsume(
        session,
        accountId: accountId,
        tag: tag,
        quantity: quantity,
      );

      return result;
    } on AuthenticationException {
      rethrow;
    } on InventoryException {
      rethrow;
    } catch (e) {
      throw AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.internalError,
        message:
            'Unexpected error during entitlement consumption: ${e.toString()}',
      );
    }
  }

  /// Validates authentication using ECDSA P-256 signature verification
  ///
  /// This is a simplified authentication check that validates the public key format
  /// and signature. In a production system, this would include more sophisticated
  /// challenge-response authentication.
  ///
  /// Parameters:
  /// - [session]: Serverpod session for logging
  /// - [publicKey]: ECDSA P-256 public key as hex string
  /// - [signature]: Signature to verify
  /// - [operation]: Operation name for logging
  ///
  /// Throws:
  /// - [AuthenticationException] for invalid authentication
  Future<void> _validateAuthentication(
    Session session,
    String publicKey,
    String signature,
    String operation,
  ) async {
    // Validate public key format
    if (publicKey.isEmpty) {
      final exception =
          AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.authMissingKey,
            message: 'Public key is required for authentication',
            operation: operation,
            details: {'publicKey': 'empty'},
          );

      throw exception;
    }

    if (!CryptoAuth.isValidPublicKey(publicKey)) {
      final exception =
          AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.cryptoInvalidPublicKey,
            message: 'Invalid ECDSA P-256 public key format',
            operation: operation,
            details: {
              'publicKeyLength': publicKey.length.toString(),
              'expectedLength': '64',
            },
          );

      throw exception;
    }

    // Validate signature format
    if (signature.isEmpty) {
      final exception =
          AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.authInvalidSignature,
            message: 'Signature is required for authentication',
            operation: operation,
            details: {'signature': 'empty'},
          );

      throw exception;
    }
  }
}
