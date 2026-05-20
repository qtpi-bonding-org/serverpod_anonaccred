import 'package:serverpod/serverpod.dart';

import 'package:anonaccount_server/anonaccount_server.dart';

import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../payments/rails/polar_rail.dart';
import '../payments/redemption_target.dart';

/// JWT-protected Polar license-key redemption endpoint.
///
/// Mirrors [IAPEndpoint] in shape but supports both account and group
/// redemption targets via the same method.
///
///   * Buyer identity comes from the JWT (`getAccountUuid(session)`)
///   * Optional [shareGroupUuid] switches to group target — the
///     endpoint enforces that the buyer is an active [GroupMember]
///     before letting the rail credit the group
///   * Returns [IapValidationResponse] (reused for parity with the IAP
///     rails; no new protocol model needed)
class PolarEndpoint extends JwtEndpoint {
  /// Validate a Polar license key and credit the redemption target.
  ///
  /// Returns [IapValidationResponse]. `productId` carries the Polar
  /// benefit UUID. `tag` / `amount` come from the first granted
  /// entitlement. `fromCache=true` indicates an idempotent replay.
  Future<IapValidationResponse> redeemLicenseKey(
    Session session,
    String licenseKey, {
    UuidValue? shareGroupUuid,
    String? internalTransactionId,
  }) async {
    try {
      final accountUuid = getAccountUuid(session);

      if (licenseKey.isEmpty) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.polarValidationFailed,
          message: 'License key is required',
          internalTransactionId: internalTransactionId,
        );
      }

      final RedemptionTarget target;
      if (shareGroupUuid == null) {
        target = AccountTarget(accountUuid);
      } else {
        // Verify membership before letting the rail credit the group.
        final membership = await GroupMember.db.findFirstRow(
          session,
          where: (t) =>
              t.shareGroupId.equals(shareGroupUuid) &
              t.anonAccountId.equals(accountUuid) &
              t.isRevoked.equals(false),
        );
        if (membership == null) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.authAccountNotFound,
            message: 'Caller is not an active member of the requested group',
            operation: 'redeemLicenseKey',
            details: {
              'accountUuid': accountUuid.toString(),
              'shareGroupUuid': shareGroupUuid.toString(),
            },
          );
        }
        target = GroupTarget(
          shareGroupUuid: shareGroupUuid,
          buyerAccountUuid: accountUuid,
        );
      }

      final rail = PolarRail.fromEnvironment();
      final result = await rail.validateLicenseKey(
        session: session,
        licenseKey: licenseKey,
        target: target,
        internalTransactionId: internalTransactionId,
      );

      session.log(
        'Polar license redeemed: ${result.licenseKeyId} '
        '(benefit=${result.benefitId}, '
        'target=${shareGroupUuid == null ? "account" : "group $shareGroupUuid"})',
        level: LogLevel.info,
      );

      return IapValidationResponse(
        success: true,
        productId: result.benefitId,
        tag: result.tag,
        amount: result.quantity,
        fromCache: result.fromCache,
      );
    } on AuthenticationException {
      rethrow;
    } on PaymentException {
      rethrow;
    } catch (e) {
      throw AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.internalError,
        message: 'Unexpected error redeeming Polar license: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }
}
