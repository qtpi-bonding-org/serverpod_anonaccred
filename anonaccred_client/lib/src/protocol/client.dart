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
import 'package:anonaccred_client/src/protocol/account.dart' as _i3;
import 'package:anonaccred_client/src/protocol/transaction_payment.dart' as _i4;
import 'package:anonaccred_client/src/protocol/payment_rail.dart' as _i5;
import 'package:anonaccred_client/src/protocol/account_entitlement.dart' as _i6;
import 'package:anonaccred_client/src/protocol/consume_result.dart' as _i7;
import 'package:anonaccred_client/src/protocol/account_device.dart' as _i8;
import 'package:anonaccred_client/src/protocol/authentication_result.dart'
    as _i9;
import 'package:anonaccred_client/src/protocol/device_pairing_event.dart'
    as _i10;
import 'package:anonaccred_client/src/protocol/device_pairing_info.dart'
    as _i11;

/// Account management endpoints for anonymous identity operations
///
/// This endpoint provides cryptographic account creation and lookup functionality
/// while maintaining strict zero-PII architecture:
/// - Only handles public keys and encrypted data
/// - Never generates, stores, or processes private keys
/// - All encrypted data is stored as-is without decryption attempts
/// {@category Endpoint}
class EndpointAccount extends _i1.EndpointRef {
  EndpointAccount(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccred.account';

  /// Create new anonymous account with ECDSA P-256 public key identity
  ///
  /// Parameters:
  /// - [ultimateSigningPublicKeyHex]: Ultimate ECDSA P-256 public key (128 hex chars, x||y coordinates)
  /// - [encryptedDataKey]: Recovery blob (symmetric key encrypted with ultimate public key)
  /// - [ultimatePublicKey]: Ultimate ECDSA P-256 public key (128 hex chars) for recovery lookup
  ///
  /// Returns the created AnonAccount with assigned ID.
  ///
  /// Throws AuthenticationException if public key validation fails or duplicate key exists.
  /// Throws AnonAccredException for database or system errors.
  _i2.Future<_i3.AnonAccount> createAccount(
    String ultimateSigningPublicKeyHex,
    String encryptedDataKey,
    String ultimatePublicKey,
  ) => caller.callServerEndpoint<_i3.AnonAccount>(
    'anonaccred.account',
    'createAccount',
    {
      'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'ultimatePublicKey': ultimatePublicKey,
    },
  );

  /// Get account by ID, requiring it to exist
  ///
  /// Parameters:
  /// - [accountId]: The account ID to lookup
  ///
  /// Returns the AnonAccount if found.
  ///
  /// Throws AuthenticationException if account is not found.
  /// Throws AnonAccredException for database or system errors.
  _i2.Future<_i3.AnonAccount> getAccountById(int accountId) =>
      caller.callServerEndpoint<_i3.AnonAccount>(
        'anonaccred.account',
        'getAccountById',
        {'accountId': accountId},
      );

  /// Get account by public master key lookup
  ///
  /// Parameters:
  /// - [ultimateSigningPublicKeyHex]: ECDSA P-256 public key as hex string (128 chars, x||y coordinates)
  ///
  /// Returns the AnonAccount if found, null if not found.
  ///
  /// Throws AuthenticationException if public key validation fails.
  /// Throws AnonAccredException for database or system errors.
  _i2.Future<_i3.AnonAccount?> getAccountByPublicKey(
    String ultimateSigningPublicKeyHex,
  ) => caller.callServerEndpoint<_i3.AnonAccount?>(
    'anonaccred.account',
    'getAccountByPublicKey',
    {'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex},
  );

  /// Get account for recovery by ultimate public key
  ///
  /// This endpoint is used during account recovery when a user has lost all devices
  /// but has their ultimate private key backup. The ultimate public key is derived
  /// from the backup and used to look up the account.
  ///
  /// Parameters:
  /// - [ultimatePublicKey]: ECDSA P-256 public key from ultimate JWK (128 hex chars)
  ///
  /// Returns the AnonAccount with recovery blob if found, null if not found.
  /// The recovery blob (encryptedDataKey) can be decrypted with the ultimate private key.
  ///
  /// SECURITY: This endpoint is unauthenticated (user has no device).
  /// Only returns data that requires the ultimate private key to decrypt.
  ///
  /// Throws AuthenticationException if public key validation fails.
  /// Throws AnonAccredException for database or system errors.
  _i2.Future<_i3.AnonAccount?> getAccountForRecovery(
    String ultimatePublicKey,
  ) => caller.callServerEndpoint<_i3.AnonAccount?>(
    'anonaccred.account',
    'getAccountForRecovery',
    {'ultimatePublicKey': ultimatePublicKey},
  );
}

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
  /// - [AnonAccredException] for system errors
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
  _i2.Future<_i4.TransactionPayment> initiatePayment(
    String publicKey,
    String signature,
    int accountId,
    _i5.PaymentRail rail,
    String storeProductId, {
    String? clientReference,
    double? customPrice,
  }) => caller.callServerEndpoint<_i4.TransactionPayment>(
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
  /// - [AnonAccredException] for system errors
  _i2.Future<Map<String, double>> getProductCatalog() =>
      caller.callServerEndpoint<Map<String, double>>(
        'anonaccred.commerce',
        'getProductCatalog',
        {},
      );

  /// Get entitlements for an account
  _i2.Future<List<_i6.AccountEntitlement>> getEntitlements(
    String publicKey,
    String signature,
    int accountId,
  ) => caller.callServerEndpoint<List<_i6.AccountEntitlement>>(
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
  _i2.Future<_i7.ConsumeResult> consumeEntitlement(
    String publicKey,
    String signature,
    int accountId,
    String tag,
    double quantity,
  ) => caller.callServerEndpoint<_i7.ConsumeResult>(
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
  _i2.Future<Map<String, dynamic>> getProductCatalogWithX402(
    String publicKey,
    String signature, {
    Map<String, String>? headers,
  }) => caller.callServerEndpoint<Map<String, dynamic>>(
    'anonaccred.commerce',
    'getProductCatalogWithX402',
    {
      'publicKey': publicKey,
      'signature': signature,
      'headers': headers,
    },
  );

  /// Get entitlement balance with X402 pay-per-query integration
  _i2.Future<Map<String, dynamic>> getEntitlementBalanceWithX402(
    String publicKey,
    String signature,
    int accountId,
    String tag, {
    Map<String, String>? headers,
  }) => caller.callServerEndpoint<Map<String, dynamic>>(
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

/// Device management endpoints for ECDSA P-256 device registration and authentication
///
/// This endpoint provides device management functionality including:
/// - Device registration with ECDSA P-256 subkeys
/// - Challenge-response authentication
/// - Device revocation and listing
/// - Integration with existing AccountDevice model from Phase 1
/// {@category Endpoint}
class EndpointDevice extends _i1.EndpointRef {
  EndpointDevice(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccred.device';

  /// Register new device with account
  ///
  /// Creates a new device registration associated with an account.
  /// The device is identified by its ECDSA P-256 device signing public key.
  ///
  /// Parameters:
  /// - [accountId]: The account to associate the device with
  /// - [deviceSigningPublicKeyHex]: ECDSA P-256 public key for the device (128 hex chars, x||y coordinates)
  /// - [encryptedDataKey]: Device-encrypted SDK (never decrypted server-side)
  /// - [label]: Human-readable device name
  ///
  /// Returns the created AccountDevice with assigned ID.
  ///
  /// Throws AuthenticationException if:
  /// - Public subkey format is invalid
  /// - Account does not exist
  /// - Public subkey is already registered
  /// - Required parameters are empty
  _i2.Future<_i8.AccountDevice> registerDevice(
    int accountId,
    String deviceSigningPublicKeyHex,
    String encryptedDataKey,
    String label,
  ) => caller.callServerEndpoint<_i8.AccountDevice>(
    'anonaccred.device',
    'registerDevice',
    {
      'accountId': accountId,
      'deviceSigningPublicKeyHex': deviceSigningPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'label': label,
    },
  );

  /// Authenticate device with challenge-response
  ///
  /// Performs ECDSA P-256 signature verification for device authentication.
  /// Updates the device's last active timestamp on successful authentication.
  /// Authentication already validated by Serverpod - device key extracted from session.
  ///
  /// Parameters:
  /// - [challenge]: The challenge string that was signed
  /// - [signature]: ECDSA P-256 signature of the challenge (128 hex chars, r||s format)
  ///
  /// Returns AuthenticationResult with success/failure information.
  _i2.Future<_i9.AuthenticationResult> authenticateDevice(
    String challenge,
    String signature,
  ) => caller.callServerEndpoint<_i9.AuthenticationResult>(
    'anonaccred.device',
    'authenticateDevice',
    {
      'challenge': challenge,
      'signature': signature,
    },
  );

  /// Generate authentication challenge
  ///
  /// Creates a cryptographically secure challenge string for client use.
  /// The challenge should be signed by the client's private key and returned
  /// for verification via authenticateDevice.
  ///
  /// Parameters:
  /// - [devicePublicKey]: The device's ECDSA P-256 signing public key (128 hex chars)
  ///
  /// Returns a hex-encoded challenge string.
  ///
  /// Throws AuthenticationException if device is not found or is revoked.
  _i2.Future<String> generateAuthChallenge(String devicePublicKey) =>
      caller.callServerEndpoint<String>(
        'anonaccred.device',
        'generateAuthChallenge',
        {'devicePublicKey': devicePublicKey},
      );

  /// Revoke device access
  ///
  /// Marks a device as revoked, preventing future authentication attempts.
  /// The device record is preserved for audit purposes.
  /// Account ownership automatically verified through authentication.
  ///
  /// Parameters:
  /// - [deviceId]: The device to revoke
  ///
  /// Returns true if revocation succeeded.
  ///
  /// Throws AuthenticationException if device validation fails or device not found.
  _i2.Future<bool> revokeDevice(int deviceId) =>
      caller.callServerEndpoint<bool>(
        'anonaccred.device',
        'revokeDevice',
        {'deviceId': deviceId},
      );

  /// List account devices
  ///
  /// Returns all devices registered to the authenticated account with complete metadata.
  /// Includes both active and revoked devices for management purposes.
  /// Account ownership automatically verified through authentication.
  ///
  /// Returns list of AccountDevice objects with metadata.
  /// Returns empty list if no devices are registered.
  _i2.Future<List<_i8.AccountDevice>> listDevices() =>
      caller.callServerEndpoint<List<_i8.AccountDevice>>(
        'anonaccred.device',
        'listDevices',
        {},
      );

  /// Monitor registration status for a specific signing key.
  ///
  /// Device B (unauthenticated) calls this to wait for Device A to complete the registration.
  /// The stream will emit a [DevicePairingEvent] when registration is complete.
  ///
  /// Parameters:
  /// - [signingKeyHex]: Device B's ECDSA P-256 signing public key (128 hex)
  _i2.Stream<_i10.DevicePairingEvent> monitorRegistration(
    String signingKeyHex,
  ) =>
      caller.callStreamingServerEndpoint<
        _i2.Stream<_i10.DevicePairingEvent>,
        _i10.DevicePairingEvent
      >(
        'anonaccred.device',
        'monitorRegistration',
        {'signingKeyHex': signingKeyHex},
        {},
      );

  /// Register a new device for the caller's account (QR code pairing flow).
  ///
  /// Device A (authenticated) calls this to register Device B.
  /// Server derives accountId from Device A's authenticated session.
  ///
  /// SECURITY: Caller must be authenticated with an active (non-revoked) device.
  /// The auth handler already enforces this via requireActiveDevice().
  ///
  /// Parameters:
  /// - [newDeviceSigningPublicKeyHex]: Device B's ECDSA P-256 signing public key (128 hex)
  /// - [newDeviceEncryptedDataKey]: SDK encrypted with Device B's RSA public key
  /// - [label]: Human-readable device name
  ///
  /// Returns the created AccountDevice.
  ///
  /// Throws AuthenticationException if:
  /// - Caller is not authenticated
  /// - Caller's device not found
  /// - New device public key format is invalid
  /// - New device public key already registered
  _i2.Future<_i8.AccountDevice> registerDeviceForAccount(
    String newDeviceSigningPublicKeyHex,
    String newDeviceEncryptedDataKey,
    String label,
  ) => caller.callServerEndpoint<_i8.AccountDevice>(
    'anonaccred.device',
    'registerDeviceForAccount',
    {
      'newDeviceSigningPublicKeyHex': newDeviceSigningPublicKeyHex,
      'newDeviceEncryptedDataKey': newDeviceEncryptedDataKey,
      'label': label,
    },
  );

  /// Get device info by signing public key (for pairing completion).
  ///
  /// UNAUTHENTICATED - Device B doesn't have credentials yet.
  /// Only returns the encrypted blob needed to complete pairing.
  ///
  /// SECURITY:
  /// - Only returns encryptedDataKey (useless without Device B's private key)
  /// - No account identifiers exposed
  /// - 128-hex key is not enumerable (2^512 possibilities)
  ///
  /// Parameters:
  /// - [signingPublicKeyHex]: Device's ECDSA P-256 signing public key (128 hex)
  ///
  /// Returns DevicePairingInfo if device is registered, null otherwise.
  _i2.Future<_i11.DevicePairingInfo?> getDeviceBySigningKey(
    String signingPublicKeyHex,
  ) => caller.callServerEndpoint<_i11.DevicePairingInfo?>(
    'anonaccred.device',
    'getDeviceBySigningKey',
    {'signingPublicKeyHex': signingPublicKeyHex},
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
  _i2.Future<Map<String, dynamic>> validateAppleTransaction(
    String publicKey,
    String signature,
    String transactionId,
    String productId,
    int accountId, {
    String? internalTransactionId,
  }) => caller.callServerEndpoint<Map<String, dynamic>>(
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
  _i2.Future<Map<String, dynamic>> validateGooglePurchase(
    String publicKey,
    String signature,
    String packageName,
    String productId,
    String purchaseToken,
    int accountId, {
    String? internalTransactionId,
  }) => caller.callServerEndpoint<Map<String, dynamic>>(
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
  _i2.Future<String> handleAppleWebhook(Map<String, dynamic> webhookData) =>
      caller.callServerEndpoint<String>(
        'anonaccred.iAPWebhook',
        'handleAppleWebhook',
        {'webhookData': webhookData},
      );

  /// Handle Google Play Real-time Developer Notifications
  _i2.Future<String> handleGoogleWebhook(Map<String, dynamic> webhookData) =>
      caller.callServerEndpoint<String>(
        'anonaccred.iAPWebhook',
        'handleGoogleWebhook',
        {'webhookData': webhookData},
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
  _i2.Future<_i4.TransactionPayment> checkPaymentStatus(
    String publicKey,
    String signature,
    String internalTransactionId,
  ) => caller.callServerEndpoint<_i4.TransactionPayment>(
    'anonaccred.payment',
    'checkPaymentStatus',
    {
      'publicKey': publicKey,
      'signature': signature,
      'internalTransactionId': internalTransactionId,
    },
  );

  /// Process Monero webhook.
  _i2.Future<String> processMoneroWebhook(Map<String, dynamic> webhookData) =>
      caller.callServerEndpoint<String>(
        'anonaccred.payment',
        'processMoneroWebhook',
        {'webhookData': webhookData},
      );

  /// Process X402 webhook.
  _i2.Future<String> processX402Webhook(Map<String, dynamic> webhookData) =>
      caller.callServerEndpoint<String>(
        'anonaccred.payment',
        'processX402Webhook',
        {'webhookData': webhookData},
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
  /// Returns: Either X402PaymentResponse (HTTP 402) or the requested resource data
  ///
  /// Requirements 5.1: Standard client-server communication flow
  /// Requirements 5.2: HTTP 402 response when payment required
  /// Requirements 5.3: Verify payment and provide resource
  _i2.Future<Map<String, dynamic>> requestPaidResource(
    String publicKey,
    String signature,
    String resourceId,
    int accountId, {
    Map<String, String>? headers,
  }) => caller.callServerEndpoint<Map<String, dynamic>>(
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
  /// - [consumableType]: Type of consumable to access
  /// - [quantity]: Amount to consume
  /// - [accountId]: Account ID for inventory management
  ///
  /// Returns: Either X402PaymentResponse (HTTP 402) or consumption result
  ///
  /// Requirements 5.4: Support AI agents and autonomous systems
  /// Requirements 5.5: Pay-per-use model charging per API call
  _i2.Future<Map<String, dynamic>> requestConsumableAccess(
    String publicKey,
    String signature,
    String tag,
    double quantity,
    int accountId, {
    Map<String, String>? headers,
  }) => caller.callServerEndpoint<Map<String, dynamic>>(
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
    account = EndpointAccount(this);
    commerce = EndpointCommerce(this);
    device = EndpointDevice(this);
    iAP = EndpointIAP(this);
    iAPWebhook = EndpointIAPWebhook(this);
    module = EndpointModule(this);
    payment = EndpointPayment(this);
    x402 = EndpointX402(this);
  }

  late final EndpointAccount account;

  late final EndpointCommerce commerce;

  late final EndpointDevice device;

  late final EndpointIAP iAP;

  late final EndpointIAPWebhook iAPWebhook;

  late final EndpointModule module;

  late final EndpointPayment payment;

  late final EndpointX402 x402;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'anonaccred.account': account,
    'anonaccred.commerce': commerce,
    'anonaccred.device': device,
    'anonaccred.iAP': iAP,
    'anonaccred.iAPWebhook': iAPWebhook,
    'anonaccred.module': module,
    'anonaccred.payment': payment,
    'anonaccred.x402': x402,
  };
}
