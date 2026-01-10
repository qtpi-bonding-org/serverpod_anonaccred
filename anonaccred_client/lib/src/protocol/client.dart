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
import 'package:anonaccred_client/src/protocol/transaction.dart' as _i4;
import 'package:anonaccred_client/src/protocol/payment_rail.dart' as _i5;
import 'package:anonaccred_client/src/protocol/inventory.dart' as _i6;
import 'package:anonaccred_client/src/protocol/consume_result.dart' as _i7;
import 'package:anonaccred_client/src/protocol/account_device.dart' as _i8;
import 'package:anonaccred_client/src/protocol/authentication_result.dart'
    as _i9;
import 'package:anonaccred_client/src/protocol/device_pairing_info.dart'
    as _i10;
import 'package:anonaccred_client/src/protocol/payment_request.dart' as _i11;

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
  String get name => 'account';

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
    'account',
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
        'account',
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
    'account',
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
    'account',
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
  String get name => 'commerce';

  /// Register products in the price registry
  ///
  /// Allows parent applications to define custom products with prices.
  /// This endpoint requires authentication and validates all input parameters.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
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
    'commerce',
    'registerProducts',
    {
      'publicKey': publicKey,
      'signature': signature,
      'products': products,
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
        'commerce',
        'getProductCatalog',
        {},
      );

  /// Create a new order for consumable items
  ///
  /// Creates a pending transaction record with the specified items and pricing.
  /// Requires authentication and validates all items against the price registry.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [accountId]: The account ID creating the order
  /// - [items]: Map of consumable types to quantities
  /// - [paymentRail]: Payment method to be used
  ///
  /// Returns: The created TransactionPayment record
  ///
  /// Throws:
  /// - [AuthenticationException] for invalid authentication
  /// - [PaymentException] for invalid order data
  /// - [AnonAccredException] for system errors
  _i2.Future<_i4.TransactionPayment> createOrder(
    String publicKey,
    String signature,
    int accountId,
    Map<String, double> items,
    _i5.PaymentRail paymentRail,
  ) => caller.callServerEndpoint<_i4.TransactionPayment>(
    'commerce',
    'createOrder',
    {
      'publicKey': publicKey,
      'signature': signature,
      'accountId': accountId,
      'items': items,
      'paymentRail': paymentRail,
    },
  );

  /// Get inventory for an account
  ///
  /// Returns all consumable types and their current balances for the specified account.
  /// Requires authentication to ensure only authorized access to inventory data.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [accountId]: The account ID to query inventory for
  ///
  /// Returns: List of AccountInventory records
  ///
  /// Throws:
  /// - [AuthenticationException] for invalid authentication
  /// - [InventoryException] for inventory access errors
  /// - [AnonAccredException] for system errors
  _i2.Future<List<_i6.AccountInventory>> getInventory(
    String publicKey,
    String signature,
    int accountId,
  ) => caller.callServerEndpoint<List<_i6.AccountInventory>>(
    'commerce',
    'getInventory',
    {
      'publicKey': publicKey,
      'signature': signature,
      'accountId': accountId,
    },
  );

  /// Get balance for a specific consumable type
  ///
  /// Returns the current balance for the specified consumable type and account.
  /// Requires authentication to ensure only authorized access to balance data.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [accountId]: The account ID to check balance for
  /// - [consumableType]: The consumable type to check
  ///
  /// Returns: Current balance as double
  ///
  /// Throws:
  /// - [AuthenticationException] for invalid authentication
  /// - [InventoryException] for inventory access errors
  /// - [AnonAccredException] for system errors
  _i2.Future<double> getBalance(
    String publicKey,
    String signature,
    int accountId,
    String consumableType,
  ) => caller.callServerEndpoint<double>(
    'commerce',
    'getBalance',
    {
      'publicKey': publicKey,
      'signature': signature,
      'accountId': accountId,
      'consumableType': consumableType,
    },
  );

  /// Consume inventory using atomic utilities
  ///
  /// Attempts to consume a specified quantity from account inventory using
  /// the optional InventoryUtils. This endpoint provides atomic consumption
  /// operations for parent applications that choose to use them.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [accountId]: The account ID to consume inventory from
  /// - [consumableType]: The consumable type to consume
  /// - [quantity]: Amount to consume (must be positive)
  ///
  /// Returns: ConsumeResult with operation outcome and balance information
  ///
  /// Throws:
  /// - [AuthenticationException] for invalid authentication
  /// - [InventoryException] for invalid consumption parameters
  /// - [AnonAccredException] for system errors
  _i2.Future<_i7.ConsumeResult> consumeInventory(
    String publicKey,
    String signature,
    int accountId,
    String consumableType,
    double quantity,
  ) => caller.callServerEndpoint<_i7.ConsumeResult>(
    'commerce',
    'consumeInventory',
    {
      'publicKey': publicKey,
      'signature': signature,
      'accountId': accountId,
      'consumableType': consumableType,
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
  /// - [publicKey]: Ed25519 public key for authentication
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
    'commerce',
    'getProductCatalogWithX402',
    {
      'publicKey': publicKey,
      'signature': signature,
      'headers': headers,
    },
  );

  /// Get inventory balance with X402 pay-per-query integration
  ///
  /// Demonstrates X402 integration for inventory queries with micropayments.
  /// Supports autonomous systems that need to check balances programmatically.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [accountId]: Account ID to check balance for
  /// - [consumableType]: Consumable type to check
  /// - [headers]: HTTP headers (may contain X-PAYMENT)
  ///
  /// Returns: Either HTTP 402 payment requirement or balance information
  ///
  /// Requirements 5.4, 5.5: Support AI agents with pay-per-use model
  _i2.Future<Map<String, dynamic>> getBalanceWithX402(
    String publicKey,
    String signature,
    int accountId,
    String consumableType, {
    Map<String, String>? headers,
  }) => caller.callServerEndpoint<Map<String, dynamic>>(
    'commerce',
    'getBalanceWithX402',
    {
      'publicKey': publicKey,
      'signature': signature,
      'accountId': accountId,
      'consumableType': consumableType,
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
  String get name => 'device';

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
    'device',
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
    'device',
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
  /// Returns a hex-encoded challenge string.
  _i2.Future<String> generateAuthChallenge() =>
      caller.callServerEndpoint<String>(
        'device',
        'generateAuthChallenge',
        {},
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
        'device',
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
        'device',
        'listDevices',
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
    'device',
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
  _i2.Future<_i10.DevicePairingInfo?> getDeviceBySigningKey(
    String signingPublicKeyHex,
  ) => caller.callServerEndpoint<_i10.DevicePairingInfo?>(
    'device',
    'getDeviceBySigningKey',
    {'signingPublicKeyHex': signingPublicKeyHex},
  );
}

/// In-App Purchase endpoint for Apple and Google IAP validation
///
/// Provides server-side validation of mobile app store purchases while maintaining
/// privacy-first architecture. Integrates with existing inventory management and
/// transaction recording systems.
///
/// Requirements 1.1, 1.4: Mobile IAP validation with inventory fulfillment
/// {@category Endpoint}
class EndpointIAP extends _i1.EndpointRef {
  EndpointIAP(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'iAP';

  /// Validate Apple App Store receipt and fulfill purchase
  ///
  /// Validates iOS app receipt using Apple's verifyReceipt API and adds
  /// purchased consumables to user inventory upon successful validation.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [receiptData]: Base64-encoded receipt from iOS app
  /// - [orderId]: Order ID for transaction tracking
  /// - [accountId]: Account ID for inventory management
  /// - [consumableType]: Type of consumable being purchased
  /// - [quantity]: Quantity of consumables purchased
  ///
  /// Returns: Validation result with transaction details or error information
  ///
  /// Requirements 2.1, 2.2, 2.3: Apple receipt validation
  /// Requirements 1.4: Inventory fulfillment integration
  _i2.Future<Map<String, dynamic>> validateAppleReceipt(
    String publicKey,
    String signature,
    String receiptData,
    String orderId,
    int accountId,
    String consumableType,
    double quantity,
  ) => caller.callServerEndpoint<Map<String, dynamic>>(
    'iAP',
    'validateAppleReceipt',
    {
      'publicKey': publicKey,
      'signature': signature,
      'receiptData': receiptData,
      'orderId': orderId,
      'accountId': accountId,
      'consumableType': consumableType,
      'quantity': quantity,
    },
  );

  /// Validate Google Play purchase and fulfill purchase
  ///
  /// Validates Android app purchase using Google Play Developer API and adds
  /// purchased consumables to user inventory upon successful validation.
  /// Also acknowledges the purchase as required by Google.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [packageName]: Android app package name
  /// - [productId]: In-app product ID (SKU)
  /// - [purchaseToken]: Purchase token from Android app
  /// - [orderId]: Order ID for transaction tracking
  /// - [accountId]: Account ID for inventory management
  /// - [consumableType]: Type of consumable being purchased
  /// - [quantity]: Quantity of consumables purchased
  ///
  /// Returns: Validation result with transaction details or error information
  ///
  /// Requirements 3.1, 3.2, 3.3: Google purchase validation and acknowledgment
  /// Requirements 1.4: Inventory fulfillment integration
  _i2.Future<Map<String, dynamic>> validateGooglePurchase(
    String publicKey,
    String signature,
    String packageName,
    String productId,
    String purchaseToken,
    String orderId,
    int accountId,
    String consumableType,
    double quantity,
  ) => caller.callServerEndpoint<Map<String, dynamic>>(
    'iAP',
    'validateGooglePurchase',
    {
      'publicKey': publicKey,
      'signature': signature,
      'packageName': packageName,
      'productId': productId,
      'purchaseToken': purchaseToken,
      'orderId': orderId,
      'accountId': accountId,
      'consumableType': consumableType,
      'quantity': quantity,
    },
  );

  /// Handle Apple server-to-server notifications (webhook)
  ///
  /// Processes webhook notifications from Apple about purchase events.
  /// This is a placeholder for future webhook implementation.
  ///
  /// Parameters:
  /// - [webhookData]: Webhook payload from Apple
  ///
  /// Returns: Acknowledgment of webhook processing
  ///
  /// Requirements 8.1: Process Apple server-to-server notifications
  _i2.Future<Map<String, dynamic>> handleAppleWebhook(
    Map<String, dynamic> webhookData,
  ) => caller.callServerEndpoint<Map<String, dynamic>>(
    'iAP',
    'handleAppleWebhook',
    {'webhookData': webhookData},
  );

  /// Handle Google Real-time Developer Notifications (webhook)
  ///
  /// Processes webhook notifications from Google about purchase events.
  /// This is a placeholder for future webhook implementation.
  ///
  /// Parameters:
  /// - [webhookData]: Webhook payload from Google
  ///
  /// Returns: Acknowledgment of webhook processing
  ///
  /// Requirements 8.2: Process Google Real-time Developer Notifications
  _i2.Future<Map<String, dynamic>> handleGoogleWebhook(
    Map<String, dynamic> webhookData,
  ) => caller.callServerEndpoint<Map<String, dynamic>>(
    'iAP',
    'handleGoogleWebhook',
    {'webhookData': webhookData},
  );
}

/// Basic IAP webhook endpoint for Apple and Google notifications
///
/// Provides minimal webhook support for future expansion.
/// Handles basic webhook routing and signature validation.
///
/// Requirements 8.1: Create placeholder webhook endpoints
/// Requirements 8.2: Add basic webhook signature validation
/// {@category Endpoint}
class EndpointIAPWebhook extends _i1.EndpointRef {
  EndpointIAPWebhook(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'iAPWebhook';

  /// Handle Apple App Store Server Notifications
  ///
  /// Basic webhook handler for Apple's server-to-server notifications.
  /// Currently provides minimal processing for future expansion.
  ///
  /// Requirements 8.1: Apple webhook endpoint
  _i2.Future<String> handleAppleWebhook(Map<String, dynamic> webhookData) =>
      caller.callServerEndpoint<String>(
        'iAPWebhook',
        'handleAppleWebhook',
        {'webhookData': webhookData},
      );

  /// Handle Google Play Real-time Developer Notifications
  ///
  /// Basic webhook handler for Google's real-time notifications.
  /// Currently provides minimal processing for future expansion.
  ///
  /// Requirements 8.1: Google webhook endpoint
  _i2.Future<String> handleGoogleWebhook(Map<String, dynamic> webhookData) =>
      caller.callServerEndpoint<String>(
        'iAPWebhook',
        'handleGoogleWebhook',
        {'webhookData': webhookData},
      );
}

/// {@category Endpoint}
class EndpointModule extends _i1.EndpointRef {
  EndpointModule(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'module';

  _i2.Future<String> hello(String name) => caller.callServerEndpoint<String>(
    'module',
    'hello',
    {'name': name},
  );

  /// Authenticates a user using Ed25519 signature verification
  /// Throws AuthenticationException on failure
  _i2.Future<bool> authenticateUser(
    String publicKey,
    String signature,
    String challenge,
  ) => caller.callServerEndpoint<bool>(
    'module',
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
    String orderId,
    String paymentRail,
    double amount,
  ) => caller.callServerEndpoint<String>(
    'module',
    'processPayment',
    {
      'orderId': orderId,
      'paymentRail': paymentRail,
      'amount': amount,
    },
  );

  /// Manages inventory operations (check balance, add consumables)
  /// Throws InventoryException on failure
  _i2.Future<int> manageInventory(
    int accountId,
    String consumableType,
    String operation,
    int? quantity,
  ) => caller.callServerEndpoint<int>(
    'module',
    'manageInventory',
    {
      'accountId': accountId,
      'consumableType': consumableType,
      'operation': operation,
      'quantity': quantity,
    },
  );
}

/// Payment endpoints for AnonAccred Phase 4 payment rail architecture
///
/// Provides endpoints for payment initiation, status checking, and webhook processing
/// while maintaining the established authentication and error handling patterns.
/// {@category Endpoint}
class EndpointPayment extends _i1.EndpointRef {
  EndpointPayment(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'payment';

  /// Initiate a payment using the specified payment rail
  ///
  /// Creates a payment request through the appropriate payment rail and updates
  /// the transaction with payment reference information.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [orderId]: External order ID for the transaction
  /// - [railType]: Payment rail to use for processing
  ///
  /// Returns: PaymentRequest with payment details and rail-specific metadata
  ///
  /// Throws:
  /// - [AuthenticationException] for invalid authentication
  /// - [PaymentException] for payment processing errors
  /// - [AnonAccredException] for system errors
  ///
  /// Requirements 6.1: Create payment requests using specified rail
  _i2.Future<_i11.PaymentRequest> initiatePayment(
    String publicKey,
    String signature,
    String orderId,
    _i5.PaymentRail railType,
  ) => caller.callServerEndpoint<_i11.PaymentRequest>(
    'payment',
    'initiatePayment',
    {
      'publicKey': publicKey,
      'signature': signature,
      'orderId': orderId,
      'railType': railType,
    },
  );

  /// Check the status of a payment transaction
  ///
  /// Returns the current status and details of a payment transaction.
  /// Requires authentication to ensure only authorized access to payment data.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [orderId]: External order ID to check status for
  ///
  /// Returns: TransactionPayment with current status and payment details
  ///
  /// Throws:
  /// - [AuthenticationException] for invalid authentication
  /// - [PaymentException] for transaction not found
  /// - [AnonAccredException] for system errors
  ///
  /// Requirements 6.2: Return current transaction and payment status
  _i2.Future<_i4.TransactionPayment> checkPaymentStatus(
    String publicKey,
    String signature,
    String orderId,
  ) => caller.callServerEndpoint<_i4.TransactionPayment>(
    'payment',
    'checkPaymentStatus',
    {
      'publicKey': publicKey,
      'signature': signature,
      'orderId': orderId,
    },
  );

  /// Process webhook for Monero payment rail
  ///
  /// Handles webhook callbacks from Monero payment services.
  /// This endpoint does not require authentication as it's called by external services.
  ///
  /// Parameters:
  /// - [webhookData]: Raw webhook payload from Monero service
  ///
  /// Returns: Success message
  ///
  /// Requirements 6.4: Process callbacks and update transaction status
  _i2.Future<String> processMoneroWebhook(Map<String, dynamic> webhookData) =>
      caller.callServerEndpoint<String>(
        'payment',
        'processMoneroWebhook',
        {'webhookData': webhookData},
      );

  /// Process webhook for X402 HTTP payment rail
  ///
  /// Handles webhook callbacks from X402 HTTP payment services.
  /// This endpoint does not require authentication as it's called by external services.
  ///
  /// Parameters:
  /// - [webhookData]: Raw webhook payload from X402 service
  ///
  /// Returns: Success message
  ///
  /// Requirements 6.4: Process callbacks and update transaction status
  _i2.Future<String> processX402Webhook(Map<String, dynamic> webhookData) =>
      caller.callServerEndpoint<String>(
        'payment',
        'processX402Webhook',
        {'webhookData': webhookData},
      );

  /// Process webhook for Apple IAP payment rail
  ///
  /// Handles webhook callbacks from Apple In-App Purchase services.
  /// This endpoint does not require authentication as it's called by external services.
  ///
  /// Parameters:
  /// - [webhookData]: Raw webhook payload from Apple IAP service
  ///
  /// Returns: Success message
  ///
  /// Requirements 6.4: Process callbacks and update transaction status
  _i2.Future<String> processAppleIAPWebhook(Map<String, dynamic> webhookData) =>
      caller.callServerEndpoint<String>(
        'payment',
        'processAppleIAPWebhook',
        {'webhookData': webhookData},
      );

  /// Process webhook for Google IAP payment rail
  ///
  /// Handles webhook callbacks from Google In-App Purchase services.
  /// This endpoint does not require authentication as it's called by external services.
  ///
  /// Parameters:
  /// - [webhookData]: Raw webhook payload from Google IAP service
  ///
  /// Returns: Success message
  ///
  /// Requirements 6.4: Process callbacks and update transaction status
  _i2.Future<String> processGoogleIAPWebhook(
    Map<String, dynamic> webhookData,
  ) => caller.callServerEndpoint<String>(
    'payment',
    'processGoogleIAPWebhook',
    {'webhookData': webhookData},
  );

  /// Request payment status with X402 integration
  ///
  /// Demonstrates X402 integration with existing payment endpoints.
  /// This endpoint can be accessed with or without payment, showcasing
  /// the X402 protocol flow for pay-per-use API access.
  ///
  /// Parameters:
  /// - [publicKey]: Ed25519 public key for authentication
  /// - [signature]: Signature of the request data
  /// - [orderId]: Order ID to check status for
  /// - [headers]: HTTP headers (may contain X-PAYMENT)
  ///
  /// Returns: Either HTTP 402 payment requirement or payment status
  ///
  /// Requirements 5.1, 5.2, 5.3: X402 endpoint integration
  _i2.Future<Map<String, dynamic>> requestPaymentStatusWithX402(
    String publicKey,
    String signature,
    String orderId, {
    Map<String, String>? headers,
  }) => caller.callServerEndpoint<Map<String, dynamic>>(
    'payment',
    'requestPaymentStatusWithX402',
    {
      'publicKey': publicKey,
      'signature': signature,
      'orderId': orderId,
      'headers': headers,
    },
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
  String get name => 'x402';

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
  /// - [publicKey]: Ed25519 public key for authentication
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
    'x402',
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
  /// - [publicKey]: Ed25519 public key for authentication
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
    String consumableType,
    double quantity,
    int accountId, {
    Map<String, String>? headers,
  }) => caller.callServerEndpoint<Map<String, dynamic>>(
    'x402',
    'requestConsumableAccess',
    {
      'publicKey': publicKey,
      'signature': signature,
      'consumableType': consumableType,
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
    'account': account,
    'commerce': commerce,
    'device': device,
    'iAP': iAP,
    'iAPWebhook': iAPWebhook,
    'module': module,
    'payment': payment,
    'x402': x402,
  };
}
