import 'package:serverpod/serverpod.dart';

import '../entitlement_manager.dart';
import '../entitlement_utils.dart';
import 'package:anonaccount_server/anonaccount_server.dart';

import '../generated/protocol.dart';

/// JWT-protected commerce endpoints for entitlement queries and consumption.
class CommerceEndpoint extends JwtEndpoint {
  /// Get entitlements for an account
  Future<List<AccountEntitlement>> getEntitlements(Session session) async {
    return tryOperation(
      session,
      'getEntitlements',
      () async {
        final accountUuid = getAccountUuid(session);

        // Get entitlements using EntitlementManager
        final entitlements = await EntitlementManager.getAccountEntitlements(
          session,
          accountUuid: accountUuid,
        );

        return entitlements;
      },
      onFailure: accountFailure,
      code: AnonAccountErrorCodes.internalError,
    );
  }

  /// Get balance for a specific entitlement tag
  Future<double> getEntitlementBalance(Session session, String tag) async {
    return tryOperation(
      session,
      'getEntitlementBalance',
      () async {
        final accountUuid = getAccountUuid(session);

        // Get balance using EntitlementManager
        final balance = await EntitlementManager.getEntitlementBalance(
          session,
          accountUuid: accountUuid,
          tag: tag,
        );

        return balance;
      },
      onFailure: accountFailure,
      code: AnonAccountErrorCodes.internalError,
    );
  }

  /// Consume entitlement using atomic utilities
  Future<ConsumeResult> consumeEntitlement(
    Session session,
    String tag,
    double quantity,
  ) async {
    return tryOperation(
      session,
      'consumeEntitlement',
      () async {
        final accountUuid = getAccountUuid(session);

        // Attempt consumption using EntitlementUtils
        final result = await EntitlementUtils.tryConsume(
          session,
          accountUuid: accountUuid,
          tag: tag,
          quantity: quantity,
        );

        return result;
      },
      onFailure: accountFailure,
      code: AnonAccountErrorCodes.internalError,
    );
  }
}
