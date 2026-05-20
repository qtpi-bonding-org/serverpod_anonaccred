import 'package:serverpod/serverpod.dart';

import '../entitlement_manager.dart';
import '../entitlement_utils.dart';
import 'package:anonaccount_server/anonaccount_server.dart';

import '../generated/protocol.dart';

/// JWT-protected commerce endpoints for entitlement queries and consumption.
class CommerceEndpoint extends JwtEndpoint {
  /// Get entitlements for an account
  Future<List<AccountEntitlement>> getEntitlements(
    Session session,
  ) async {
    try {
      final accountUuid = getAccountUuid(session);

      // Get entitlements using EntitlementManager
      final entitlements = await EntitlementManager.getAccountEntitlements(
        session,
        accountUuid: accountUuid,
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
      final accountUuid = getAccountUuid(session);

      // Get balance using EntitlementManager
      final balance = await EntitlementManager.getEntitlementBalance(
        session,
        accountUuid: accountUuid,
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
      final accountUuid = getAccountUuid(session);

      // Attempt consumption using EntitlementUtils
      final result = await EntitlementUtils.tryConsume(
        session,
        accountUuid: accountUuid,
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
