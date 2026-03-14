import 'package:serverpod/serverpod.dart';

import '../entitlement_manager.dart';
import '../entitlement_utils.dart';
import 'package:anonaccount_server/anonaccount_server.dart';

import '../generated/protocol.dart';

/// Commerce endpoints for entitlement queries and consumption.
///
/// Requires device-key authentication via [AuthenticatedEndpoint].
class CommerceEndpoint extends AuthenticatedEndpoint {
  /// Get entitlements for an account
  Future<List<AccountEntitlement>> getEntitlements(
    Session session,
  ) async {
    try {
      final accountId = getAccountId(session);

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
    String tag,
  ) async {
    try {
      final accountId = getAccountId(session);

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
    String tag,
    double quantity,
  ) async {
    try {
      final accountId = getAccountId(session);

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
}
