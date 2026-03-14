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
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:anonaccred_client/src/protocol/account_entitlement.dart' as _i3;
import 'package:anonaccred_client/src/protocol/consume_result.dart' as _i4;
import 'package:anonaccred_client/src/protocol/iap_validation_response.dart'
    as _i5;

/// Commerce endpoints for entitlement queries and consumption.
///
/// Provides authenticated access to entitlement balances and consumption.
/// {@category Endpoint}
class EndpointCommerce extends _i1.EndpointRef {
  EndpointCommerce(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccred.commerce';

  /// Get entitlements for an account
  _i2.Future<List<_i3.AccountEntitlement>> getEntitlements(
    String publicKey,
    String signature,
  ) => caller.callServerEndpoint<List<_i3.AccountEntitlement>>(
    'anonaccred.commerce',
    'getEntitlements',
    {
      'publicKey': publicKey,
      'signature': signature,
    },
  );

  /// Get balance for a specific entitlement tag
  _i2.Future<double> getEntitlementBalance(
    String publicKey,
    String signature,
    String tag,
  ) => caller.callServerEndpoint<double>(
    'anonaccred.commerce',
    'getEntitlementBalance',
    {
      'publicKey': publicKey,
      'signature': signature,
      'tag': tag,
    },
  );

  /// Consume entitlement using atomic utilities
  _i2.Future<_i4.ConsumeResult> consumeEntitlement(
    String publicKey,
    String signature,
    String tag,
    double quantity,
  ) => caller.callServerEndpoint<_i4.ConsumeResult>(
    'anonaccred.commerce',
    'consumeEntitlement',
    {
      'publicKey': publicKey,
      'signature': signature,
      'tag': tag,
      'quantity': quantity,
    },
  );
}

/// In-App Purchase endpoint for Apple and Google IAP validation.
///
/// Implements a "Reactive & Anonymous" fulfillment flow.
/// 1. Identity-Linked Inventory: Adds coins directly to the account balance.
/// 2. Identity-Free Financials: Records the payment in TransactionPayment without an accountId.
/// 3. The Bridge: EphemeralAuditLog links the two for 7 days, then breaks.
/// {@category Endpoint}
class EndpointIAP extends _i1.EndpointRef {
  EndpointIAP(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccred.iAP';

  /// Validate Apple App Store transaction and fulfill purchase.
  ///
  /// This endpoint is reactive: if no order exists, it creates the financial
  /// record on-the-fly from the verified receipt.
  ///
  /// Parameters:
  /// - [publicKey]: ECDSA P-256 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [transactionId]: Apple transaction ID from the app
  /// - [productId]: Apple product ID (SKU)
  /// - [internalTransactionId]: Optional client-generated reference (e.g. UUID)
  _i2.Future<_i5.IapValidationResponse> validateAppleTransaction(
    String publicKey,
    String signature,
    String transactionId,
    String productId, {
    String? internalTransactionId,
  }) => caller.callServerEndpoint<_i5.IapValidationResponse>(
    'anonaccred.iAP',
    'validateAppleTransaction',
    {
      'publicKey': publicKey,
      'signature': signature,
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
  /// - [publicKey]: ECDSA P-256 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [packageName]: Android app package name
  /// - [productId]: Google product ID (SKU)
  /// - [purchaseToken]: Google purchase token
  /// - [internalTransactionId]: Optional client-generated reference (e.g. UUID)
  _i2.Future<_i5.IapValidationResponse> validateGooglePurchase(
    String publicKey,
    String signature,
    String packageName,
    String productId,
    String purchaseToken, {
    String? internalTransactionId,
  }) => caller.callServerEndpoint<_i5.IapValidationResponse>(
    'anonaccred.iAP',
    'validateGooglePurchase',
    {
      'publicKey': publicKey,
      'signature': signature,
      'packageName': packageName,
      'productId': productId,
      'purchaseToken': purchaseToken,
      'internalTransactionId': internalTransactionId,
    },
  );
}

class Caller extends _i1.ModuleEndpointCaller {
  Caller(_i1.ServerpodClientShared client) : super(client) {
    commerce = EndpointCommerce(this);
    iAP = EndpointIAP(this);
  }

  late final EndpointCommerce commerce;

  late final EndpointIAP iAP;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'anonaccred.commerce': commerce,
    'anonaccred.iAP': iAP,
  };
}
