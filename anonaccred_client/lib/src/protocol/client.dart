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
import 'package:anonaccount_client/anonaccount_client.dart' as _i1;
import 'package:serverpod_client/serverpod_client.dart' as _i2;
import 'dart:async' as _i3;
import 'package:anonaccred_client/src/protocol/account_entitlement.dart' as _i4;
import 'package:anonaccred_client/src/protocol/consume_result.dart' as _i5;
import 'package:anonaccred_client/src/protocol/group_entitlement.dart' as _i6;
import 'package:anonaccred_client/src/protocol/iap_validation_response.dart'
    as _i7;

/// JWT-protected commerce endpoints for entitlement queries and consumption.
/// {@category Endpoint}
class EndpointCommerce extends _i1.EndpointJwt {
  EndpointCommerce(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccred.commerce';

  /// Get entitlements for an account
  _i3.Future<List<_i4.AccountEntitlement>> getEntitlements() =>
      caller.callServerEndpoint<List<_i4.AccountEntitlement>>(
        'anonaccred.commerce',
        'getEntitlements',
        {},
      );

  /// Get balance for a specific entitlement tag
  _i3.Future<double> getEntitlementBalance(String tag) =>
      caller.callServerEndpoint<double>(
        'anonaccred.commerce',
        'getEntitlementBalance',
        {'tag': tag},
      );

  /// Consume entitlement using atomic utilities
  _i3.Future<_i5.ConsumeResult> consumeEntitlement(
    String tag,
    double quantity,
  ) => caller.callServerEndpoint<_i5.ConsumeResult>(
    'anonaccred.commerce',
    'consumeEntitlement',
    {
      'tag': tag,
      'quantity': quantity,
    },
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
class EndpointGroupCommerce extends _i1.EndpointJwt {
  EndpointGroupCommerce(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccred.groupCommerce';

  /// Get all entitlement balances for a group. Caller must be a member.
  _i3.Future<List<_i6.GroupEntitlement>> getGroupEntitlements(
    _i2.UuidValue shareGroupUuid,
  ) => caller.callServerEndpoint<List<_i6.GroupEntitlement>>(
    'anonaccred.groupCommerce',
    'getGroupEntitlements',
    {'shareGroupUuid': shareGroupUuid},
  );

  /// Get the balance for a single entitlement tag in this group. Caller
  /// must be a member.
  _i3.Future<double> getGroupEntitlementBalance(
    _i2.UuidValue shareGroupUuid,
    String tag,
  ) => caller.callServerEndpoint<double>(
    'anonaccred.groupCommerce',
    'getGroupEntitlementBalance',
    {
      'shareGroupUuid': shareGroupUuid,
      'tag': tag,
    },
  );

  /// Consume from a group's entitlement balance.
  ///
  /// The acting member (resolved from JWT) is recorded as
  /// `consumingAccountUuid` on the log row for UI attribution. Returns
  /// a [ConsumeResult] (does not throw on insufficient balance).
  _i3.Future<_i5.ConsumeResult> consumeGroupEntitlement(
    _i2.UuidValue shareGroupUuid,
    String tag,
    double quantity,
  ) => caller.callServerEndpoint<_i5.ConsumeResult>(
    'anonaccred.groupCommerce',
    'consumeGroupEntitlement',
    {
      'shareGroupUuid': shareGroupUuid,
      'tag': tag,
      'quantity': quantity,
    },
  );
}

/// JWT-protected In-App Purchase endpoint for Apple and Google IAP validation.
///
/// Implements a "Reactive & Anonymous" fulfillment flow.
/// 1. Identity-Linked Inventory: Adds coins directly to the account balance.
/// 2. Identity-Free Financials: Records the payment in TransactionPayment without an accountUuid.
/// 3. The Bridge: EphemeralAuditLog links the two for 7 days, then breaks.
/// {@category Endpoint}
class EndpointIAP extends _i1.EndpointJwt {
  EndpointIAP(_i2.EndpointCaller caller) : super(caller);

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
  _i3.Future<_i7.IapValidationResponse> validateAppleTransaction(
    String transactionId,
    String productId, {
    String? internalTransactionId,
  }) => caller.callServerEndpoint<_i7.IapValidationResponse>(
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
  _i3.Future<_i7.IapValidationResponse> validateGooglePurchase(
    String packageName,
    String productId,
    String purchaseToken, {
    String? internalTransactionId,
  }) => caller.callServerEndpoint<_i7.IapValidationResponse>(
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

class Caller extends _i2.ModuleEndpointCaller {
  Caller(_i2.ServerpodClientShared client) : super(client) {
    commerce = EndpointCommerce(this);
    groupCommerce = EndpointGroupCommerce(this);
    iAP = EndpointIAP(this);
  }

  late final EndpointCommerce commerce;

  late final EndpointGroupCommerce groupCommerce;

  late final EndpointIAP iAP;

  @override
  Map<String, _i2.EndpointRef> get endpointRefLookup => {
    'anonaccred.commerce': commerce,
    'anonaccred.groupCommerce': groupCommerce,
    'anonaccred.iAP': iAP,
  };
}
