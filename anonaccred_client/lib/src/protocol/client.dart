/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;
import 'package:anonaccount_client/anonaccount_client.dart' as _i3nzkmxo;
import 'package:anonaccred_client/src/protocol/account_entitlement.dart'
    as _iwyotwlc;
import 'package:anonaccred_client/src/protocol/consume_result.dart'
    as _iq3bsyur;
import 'package:anonaccred_client/src/protocol/group_entitlement.dart'
    as _iskjyox1;
import 'package:anonaccred_client/src/protocol/iap_validation_response.dart'
    as _iz7u1zuc;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// JWT-protected commerce endpoints for entitlement queries and consumption.
/// {@category Endpoint}
class EndpointCommerce extends _i3nzkmxo.EndpointJwt {
  EndpointCommerce(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccred.commerce';

  /// Get entitlements for an account
  _ida.Future<List<_iwyotwlc.AccountEntitlement>> getEntitlements() =>
      caller.callServerEndpoint<List<_iwyotwlc.AccountEntitlement>>(
        'anonaccred.commerce',
        'getEntitlements',
        {},
      );

  /// Get balance for a specific entitlement tag
  _ida.Future<double> getEntitlementBalance(String tag) =>
      caller.callServerEndpoint<double>(
        'anonaccred.commerce',
        'getEntitlementBalance',
        {'tag': tag},
      );

  /// Consume entitlement using atomic utilities
  _ida.Future<_iq3bsyur.ConsumeResult> consumeEntitlement(
    String tag,
    double quantity,
  ) => caller.callServerEndpoint<_iq3bsyur.ConsumeResult>(
    'anonaccred.commerce',
    'consumeEntitlement',
    {'tag': tag, 'quantity': quantity},
  );
}

/// JWT-protected group commerce endpoints.
///
/// Mirrors the account-level commerce endpoint for the per-group
/// entitlement layer. The authenticated caller is the acting member;
/// the target group is supplied as a parameter. Authorization (caller
/// must be an active member of the group) is enforced via
/// `[_requireGroupMember]`.
///
/// The acting member's account UUID is attached to consumption events
/// as `consumingAccountUuid` for in-app attribution (e.g., "Bob used
/// 200MB of this group's quota"). Billing correctness does not depend
/// on that field.
/// {@category Endpoint}
class EndpointGroupCommerce extends _i3nzkmxo.EndpointJwt {
  EndpointGroupCommerce(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccred.groupCommerce';

  /// Get all entitlement balances for a group. Caller must be a member.
  _ida.Future<List<_iskjyox1.GroupEntitlement>> getGroupEntitlements(
    _isc.UuidValue shareGroupUuid,
  ) => caller.callServerEndpoint<List<_iskjyox1.GroupEntitlement>>(
    'anonaccred.groupCommerce',
    'getGroupEntitlements',
    {'shareGroupUuid': shareGroupUuid},
  );

  /// Get the balance for a single entitlement tag in this group. Caller
  /// must be a member.
  _ida.Future<double> getGroupEntitlementBalance(
    _isc.UuidValue shareGroupUuid,
    String tag,
  ) => caller.callServerEndpoint<double>(
    'anonaccred.groupCommerce',
    'getGroupEntitlementBalance',
    {'shareGroupUuid': shareGroupUuid, 'tag': tag},
  );

  /// Consume from a group's entitlement balance.
  ///
  /// The acting member (resolved from JWT) is recorded as
  /// `consumingAccountUuid` on the log row for UI attribution. Returns
  /// a [ConsumeResult] (does not throw on insufficient balance).
  _ida.Future<_iq3bsyur.ConsumeResult> consumeGroupEntitlement(
    _isc.UuidValue shareGroupUuid,
    String tag,
    double quantity,
  ) => caller.callServerEndpoint<_iq3bsyur.ConsumeResult>(
    'anonaccred.groupCommerce',
    'consumeGroupEntitlement',
    {'shareGroupUuid': shareGroupUuid, 'tag': tag, 'quantity': quantity},
  );
}

/// JWT-protected In-App Purchase endpoint for Apple and Google IAP validation.
///
/// Implements a "Reactive & Anonymous" fulfillment flow.
/// 1. Identity-Linked Inventory: Adds coins directly to the account balance.
/// 2. Identity-Free Financials: Records the payment in TransactionPayment without an accountUuid.
/// 3. The Bridge: EphemeralAuditLog links the two for 7 days, then breaks.
/// {@category Endpoint}
class EndpointIAP extends _i3nzkmxo.EndpointJwt {
  EndpointIAP(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccred.iAP';

  /// Validate Apple App Store transaction and fulfill purchase.
  ///
  /// This endpoint is reactive: if no order exists, it creates the financial
  /// record on-the-fly from the verified receipt.
  ///
  /// Parameters:
  /// - [transactionId]: Apple transaction ID from the app
  /// - [productId]: Apple product ID (SKU)
  /// - [internalTransactionId]: Optional client-generated reference (e.g. UUID)
  _ida.Future<_iz7u1zuc.IapValidationResponse> validateAppleTransaction(
    String transactionId,
    String productId, {
    String? internalTransactionId,
  }) => caller.callServerEndpoint<_iz7u1zuc.IapValidationResponse>(
    'anonaccred.iAP',
    'validateAppleTransaction',
    {
      'transactionId': transactionId,
      'productId': productId,
      'internalTransactionId': internalTransactionId,
    },
  );

  /// Validate Google Play purchase and fulfill purchase.
  ///
  /// This endpoint is reactive: if no order exists, it creates the financial
  /// record on-the-fly from the verified purchase token.
  ///
  /// Parameters:
  /// - [packageName]: Android app package name
  /// - [productId]: Google product ID (SKU)
  /// - [purchaseToken]: Google purchase token
  /// - [internalTransactionId]: Optional client-generated reference (e.g. UUID)
  _ida.Future<_iz7u1zuc.IapValidationResponse> validateGooglePurchase(
    String packageName,
    String productId,
    String purchaseToken, {
    String? internalTransactionId,
  }) => caller.callServerEndpoint<_iz7u1zuc.IapValidationResponse>(
    'anonaccred.iAP',
    'validateGooglePurchase',
    {
      'packageName': packageName,
      'productId': productId,
      'purchaseToken': purchaseToken,
      'internalTransactionId': internalTransactionId,
    },
  );
}

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
/// {@category Endpoint}
class EndpointPolar extends _i3nzkmxo.EndpointJwt {
  EndpointPolar(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccred.polar';

  /// Validate a Polar license key and credit the redemption target.
  ///
  /// Returns [IapValidationResponse]. `productId` carries the Polar
  /// benefit UUID. `tag` / `amount` come from the first granted
  /// entitlement. `fromCache=true` indicates an idempotent replay.
  _ida.Future<_iz7u1zuc.IapValidationResponse> redeemLicenseKey(
    String licenseKey, {
    _isc.UuidValue? shareGroupUuid,
    String? internalTransactionId,
  }) => caller.callServerEndpoint<_iz7u1zuc.IapValidationResponse>(
    'anonaccred.polar',
    'redeemLicenseKey',
    {
      'licenseKey': licenseKey,
      'shareGroupUuid': shareGroupUuid,
      'internalTransactionId': internalTransactionId,
    },
  );
}

class Caller extends _isc.ModuleEndpointCaller {
  Caller(_isc.ServerpodClientShared client) : super(client) {
    commerce = EndpointCommerce(this);
    groupCommerce = EndpointGroupCommerce(this);
    iAP = EndpointIAP(this);
    polar = EndpointPolar(this);
  }

  late final EndpointCommerce commerce;

  late final EndpointGroupCommerce groupCommerce;

  late final EndpointIAP iAP;

  late final EndpointPolar polar;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'anonaccred.commerce': commerce,
    'anonaccred.groupCommerce': groupCommerce,
    'anonaccred.iAP': iAP,
    'anonaccred.polar': polar,
  };
}
