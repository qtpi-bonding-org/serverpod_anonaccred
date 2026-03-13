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
import 'package:anonaccred_client/src/protocol/transaction_payment.dart' as _i3;
import 'package:anonaccred_client/src/protocol/payment_rail.dart' as _i4;
import 'package:anonaccred_client/src/protocol/account_entitlement.dart' as _i5;
import 'package:anonaccred_client/src/protocol/consume_result.dart' as _i6;
import 'package:anonaccred_client/src/protocol/api_response.dart' as _i7;
import 'package:anonaccred_client/src/protocol/iap_validation_response.dart'
    as _i8;

/// Commerce endpoints for AnonAccred Phase 3 commerce foundation
///
/// Provides endpoints for product registration, order creation, and inventory
/// management while maintaining the established authentication and error
/// handling patterns from the AnonAccred module.
/// {@category Endpoint}
class EndpointCommerce extends _i1.EndpointRef {
  EndpointCommerce(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccred.commerce';

  /// Register products in the price registry
  ///
  /// Allows parent applications to define custom products with prices.
  /// This endpoint requires authentication and validates all input parameters.
  ///
  /// Parameters:
  /// - [publicKey]: ECDSA P-256 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [products]: Map of product SKUs to USD prices
  ///
  /// Returns: Map of registered products with their prices
  ///
  /// Throws:
  /// - [AuthenticationException] for invalid authentication
  /// - [PaymentException] for invalid product data
  /// - [AnonAccountException] for system errors
  _i2.Future<Map<String, double>> registerProducts(
    String publicKey,
    String signature,
    Map<String, double> products,
  ) => caller.callServerEndpoint<Map<String, double>>(
    'anonaccred.commerce',
    'registerProducts',
    {
      'publicKey': publicKey,
      'signature': signature,
      'products': products,
    },
  );

  /// Initiate a transaction payment
  ///
  /// Wraps CommerceManager.initiateTransactionPayment to provide endpoint access.
  _i2.Future<_i3.TransactionPayment> initiatePayment(
    String publicKey,
    String signature,
    int accountId,
    _i4.PaymentRail rail,
    String storeProductId, {
    String? clientReference,
    double? customPrice,
  }) => caller.callServerEndpoint<_i3.TransactionPayment>(
    'anonaccred.commerce',
    'initiatePayment',
    {
      'publicKey': publicKey,
      'signature': signature,
      'accountId': accountId,
      'rail': rail,
      'storeProductId': storeProductId,
      'clientReference': clientReference,
      'customPrice': customPrice,
    },
  );

  /// Get active store product IDs for a given payment rail.
  ///
  /// Returns the list of storeProductId strings from the rail_product table
  /// where isActive is true and the rail matches. No authentication required
  /// since product IDs are public information (same as what the stores expose).
  ///
  /// Parameters:
  /// - [railName]: Payment rail name (e.g. 'apple_iap', 'google_iap')
  ///
  /// Returns: List of active store product ID strings for the given rail.
  _i2.Future<List<String>> getActiveStoreProductIds(String railName) =>
      caller.callServerEndpoint<List<String>>(
        'anonaccred.commerce',
        'getActiveStoreProductIds',
        {'railName': railName},
      );

  /// Get the complete product catalog
  ///
  /// Returns all registered products with their current prices.
  /// This endpoint does not require authentication as it provides public
  /// product information.
  ///
  /// Returns: Map of all products with SKUs as keys and USD prices as values
  ///
  /// Throws:
  /// - [PaymentException] for price registry errors
  /// - [AnonAccountException] for system errors
  _i2.Future<Map<String, double>> getProductCatalog() =>
      caller.callServerEndpoint<Map<String, double>>(
        'anonaccred.commerce',
        'getProductCatalog',
        {},
      );

  /// Get entitlements for an account
  _i2.Future<List<_i5.AccountEntitlement>> getEntitlements(
    String publicKey,
    String signature,
    int accountId,
  ) => caller.callServerEndpoint<List<_i5.AccountEntitlement>>(
    'anonaccred.commerce',
    'getEntitlements',
    {
      'publicKey': publicKey,
      'signature': signature,
      'accountId': accountId,
    },
  );

  /// Get balance for a specific entitlement tag
  _i2.Future<double> getEntitlementBalance(
    String publicKey,
    String signature,
    int accountId,
    String tag,
  ) => caller.callServerEndpoint<double>(
    'anonaccred.commerce',
    'getEntitlementBalance',
    {
      'publicKey': publicKey,
      'signature': signature,
      'accountId': accountId,
      'tag': tag,
    },
  );

  /// Consume entitlement using atomic utilities
  _i2.Future<_i6.ConsumeResult> consumeEntitlement(
    String publicKey,
    String signature,
    int accountId,
    String tag,
    double quantity,
  ) => caller.callServerEndpoint<_i6.ConsumeResult>(
    'anonaccred.commerce',
    'consumeEntitlement',
    {
      'publicKey': publicKey,
      'signature': signature,
      'accountId': accountId,
      'tag': tag,
      'quantity': quantity,
    },
  );

  /// Get product catalog with X402 pay-per-access integration
  ///
  /// Demonstrates X402 integration with commerce endpoints for pay-per-use access.
  /// This endpoint can be accessed with or without payment, showcasing micropayments
  /// for AI agents and autonomous systems.
  ///
  /// Parameters:
  /// - [publicKey]: ECDSA P-256 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [headers]: HTTP headers (may contain X-PAYMENT)
  ///
  /// Returns: Either HTTP 402 payment requirement or product catalog
  ///
  /// Requirements 5.4, 5.5: Support AI agents with pay-per-use model
  _i2.Future<_i7.ApiResponse> getProductCatalogWithX402(
    String publicKey,
    String signature, {
    Map<String, String>? headers,
  }) => caller.callServerEndpoint<_i7.ApiResponse>(
    'anonaccred.commerce',
    'getProductCatalogWithX402',
    {
      'publicKey': publicKey,
      'signature': signature,
      'headers': headers,
    },
  );

  /// Get entitlement balance with X402 pay-per-query integration
  _i2.Future<_i7.ApiResponse> getEntitlementBalanceWithX402(
    String publicKey,
    String signature,
    int accountId,
    String tag, {
    Map<String, String>? headers,
  }) => caller.callServerEndpoint<_i7.ApiResponse>(
    'anonaccred.commerce',
    'getEntitlementBalanceWithX402',
    {
      'publicKey': publicKey,
      'signature': signature,
      'accountId': accountId,
      'tag': tag,
      'headers': headers,
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
  /// - [accountId]: Account ID for inventory management
  /// - [internalTransactionId]: Optional client-generated reference (e.g. UUID)
  _i2.Future<_i8.IapValidationResponse> validateAppleTransaction(
    String publicKey,
    String signature,
    String transactionId,
    String productId,
    int accountId, {
    String? internalTransactionId,
  }) => caller.callServerEndpoint<_i8.IapValidationResponse>(
    'anonaccred.iAP',
    'validateAppleTransaction',
    {
      'publicKey': publicKey,
      'signature': signature,
      'transactionId': transactionId,
      'productId': productId,
      'accountId': accountId,
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
  /// - [accountId]: Account ID for inventory management
  /// - [internalTransactionId]: Optional client-generated reference (e.g. UUID)
  _i2.Future<_i8.IapValidationResponse> validateGooglePurchase(
    String publicKey,
    String signature,
    String packageName,
    String productId,
    String purchaseToken,
    int accountId, {
    String? internalTransactionId,
  }) => caller.callServerEndpoint<_i8.IapValidationResponse>(
    'anonaccred.iAP',
    'validateGooglePurchase',
    {
      'publicKey': publicKey,
      'signature': signature,
      'packageName': packageName,
      'productId': productId,
      'purchaseToken': purchaseToken,
      'accountId': accountId,
      'internalTransactionId': internalTransactionId,
    },
  );
}

/// IAP webhook endpoint for Apple and Google notifications.
///
/// Uses PaymentManager.getRail() to get initialized rail instances,
/// injects the session into callbackData so rails can access the database.
/// {@category Endpoint}
class EndpointIAPWebhook extends _i1.EndpointRef {
  EndpointIAPWebhook(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccred.iAPWebhook';

  /// Handle Apple App Store Server Notifications
  _i2.Future<String> handleAppleWebhook(String webhookDataJson) =>
      caller.callServerEndpoint<String>(
        'anonaccred.iAPWebhook',
        'handleAppleWebhook',
        {'webhookDataJson': webhookDataJson},
      );

  /// Handle Google Play Real-time Developer Notifications
  _i2.Future<String> handleGoogleWebhook(String webhookDataJson) =>
      caller.callServerEndpoint<String>(
        'anonaccred.iAPWebhook',
        'handleGoogleWebhook',
        {'webhookDataJson': webhookDataJson},
      );
}

/// {@category Endpoint}
class EndpointModule extends _i1.EndpointRef {
  EndpointModule(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccred.module';

  _i2.Future<String> hello(String name) => caller.callServerEndpoint<String>(
    'anonaccred.module',
    'hello',
    {'name': name},
  );

  /// Authenticates a user using ECDSA P-256 signature verification
  /// Throws AuthenticationException on failure
  _i2.Future<bool> authenticateUser(
    String publicKey,
    String signature,
    String challenge,
  ) => caller.callServerEndpoint<bool>(
    'anonaccred.module',
    'authenticateUser',
    {
      'publicKey': publicKey,
      'signature': signature,
      'challenge': challenge,
    },
  );

  /// Processes a payment through specified payment rail
  /// Throws PaymentException on failure
  _i2.Future<String> processPayment(
    String internalTransactionId,
    String paymentRail,
    double amount,
  ) => caller.callServerEndpoint<String>(
    'anonaccred.module',
    'processPayment',
    {
      'internalTransactionId': internalTransactionId,
      'paymentRail': paymentRail,
      'amount': amount,
    },
  );

  /// Manages entitlement operations (check balance, grant)
  /// Throws InventoryException on failure
  _i2.Future<double> manageEntitlements(
    int accountId,
    String tag,
    String operation,
    double? quantity,
  ) => caller.callServerEndpoint<double>(
    'anonaccred.module',
    'manageEntitlements',
    {
      'accountId': accountId,
      'tag': tag,
      'operation': operation,
      'quantity': quantity,
    },
  );
}

/// Payment endpoints for managing non-IAP rails (Monero, X402, etc).
///
/// Note: IAP rails (Apple/Google) are now handled via IAPEndpoint for better
/// reactive fulfillment coupling.
/// {@category Endpoint}
class EndpointPayment extends _i1.EndpointRef {
  EndpointPayment(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccred.payment';

  /// Check the status of a payment transaction.
  ///
  /// Uses internalTransactionId for the check.
  _i2.Future<_i3.TransactionPayment> checkPaymentStatus(
    String publicKey,
    String signature,
    String internalTransactionId,
  ) => caller.callServerEndpoint<_i3.TransactionPayment>(
    'anonaccred.payment',
    'checkPaymentStatus',
    {
      'publicKey': publicKey,
      'signature': signature,
      'internalTransactionId': internalTransactionId,
    },
  );

  /// Process Monero webhook.
  _i2.Future<String> processMoneroWebhook(String webhookDataJson) =>
      caller.callServerEndpoint<String>(
        'anonaccred.payment',
        'processMoneroWebhook',
        {'webhookDataJson': webhookDataJson},
      );

  /// Process X402 webhook.
  _i2.Future<String> processX402Webhook(String webhookDataJson) =>
      caller.callServerEndpoint<String>(
        'anonaccred.payment',
        'processX402Webhook',
        {'webhookDataJson': webhookDataJson},
      );
}

/// X402 HTTP Payment Rail endpoint integration
///
/// Demonstrates X402 protocol integration with AnonAccred endpoints.
/// Supports the standard client-server communication flow where clients
/// can request resources and receive HTTP 402 responses when payment is required.
///
/// Requirements 5.1, 5.2, 5.3: X402 endpoint integration with request interception
/// {@category Endpoint}
class EndpointX402 extends _i1.EndpointRef {
  EndpointX402(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccred.x402';

  /// Request a paid resource with X402 payment integration
  ///
  /// This endpoint demonstrates the X402 protocol flow:
  /// 1. Client requests resource without payment -> HTTP 402 response
  /// 2. Client resubmits with X-PAYMENT header -> verify and deliver resource
  ///
  /// This endpoint supports AI agents and autonomous systems by enabling
  /// micropayments without human intervention.
  ///
  /// Parameters:
  /// - [publicKey]: ECDSA P-256 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [resourceId]: The resource being requested
  /// - [accountId]: Account ID for inventory management
  ///
  /// Returns: Either ApiResponse with HTTP 402 or the requested resource data
  ///
  /// Requirements 5.1: Standard client-server communication flow
  /// Requirements 5.2: HTTP 402 response when payment required
  /// Requirements 5.3: Verify payment and provide resource
  _i2.Future<_i7.ApiResponse> requestPaidResource(
    String publicKey,
    String signature,
    String resourceId,
    int accountId, {
    Map<String, String>? headers,
  }) => caller.callServerEndpoint<_i7.ApiResponse>(
    'anonaccred.x402',
    'requestPaidResource',
    {
      'publicKey': publicKey,
      'signature': signature,
      'resourceId': resourceId,
      'accountId': accountId,
      'headers': headers,
    },
  );

  /// Request consumable inventory with X402 payment integration
  ///
  /// Demonstrates pay-per-use model where each API call consumes inventory.
  /// Supports micropayments for AI agents and autonomous systems.
  ///
  /// Parameters:
  /// - [publicKey]: ECDSA P-256 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [tag]: Type of consumable to access
  /// - [quantity]: Amount to consume
  /// - [accountId]: Account ID for inventory management
  ///
  /// Returns: Either ApiResponse with HTTP 402 or consumption result
  ///
  /// Requirements 5.4: Support AI agents and autonomous systems
  /// Requirements 5.5: Pay-per-use model charging per API call
  _i2.Future<_i7.ApiResponse> requestConsumableAccess(
    String publicKey,
    String signature,
    String tag,
    double quantity,
    int accountId, {
    Map<String, String>? headers,
  }) => caller.callServerEndpoint<_i7.ApiResponse>(
    'anonaccred.x402',
    'requestConsumableAccess',
    {
      'publicKey': publicKey,
      'signature': signature,
      'tag': tag,
      'quantity': quantity,
      'accountId': accountId,
      'headers': headers,
    },
  );
}

class Caller extends _i1.ModuleEndpointCaller {
  Caller(_i1.ServerpodClientShared client) : super(client) {
    commerce = EndpointCommerce(this);
    iAP = EndpointIAP(this);
    iAPWebhook = EndpointIAPWebhook(this);
    module = EndpointModule(this);
    payment = EndpointPayment(this);
    x402 = EndpointX402(this);
  }

  late final EndpointCommerce commerce;

  late final EndpointIAP iAP;

  late final EndpointIAPWebhook iAPWebhook;

  late final EndpointModule module;

  late final EndpointPayment payment;

  late final EndpointX402 x402;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'anonaccred.commerce': commerce,
    'anonaccred.iAP': iAP,
    'anonaccred.iAPWebhook': iAPWebhook,
    'anonaccred.module': module,
    'anonaccred.payment': payment,
    'anonaccred.x402': x402,
  };
}
