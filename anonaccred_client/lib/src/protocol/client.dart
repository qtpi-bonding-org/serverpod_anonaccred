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

  /// Create new anonymous account with Ed25519 public key identity
  ///
  /// Parameters:
  /// - [publicMasterKey]: Ed25519 public key as hex string (64 chars)
  /// - [encryptedDataKey]: Client-encrypted symmetric data key (never decrypted server-side)
  ///
  /// Returns the created AnonAccount with assigned ID.
  ///
  /// Throws AuthenticationException if public key validation fails.
  /// Throws AnonAccredException for database or system errors.
  _i2.Future<_i3.AnonAccount> createAccount(
    String publicMasterKey,
    String encryptedDataKey,
  ) => caller.callServerEndpoint<_i3.AnonAccount>(
    'anonaccred.account',
    'createAccount',
    {
      'publicMasterKey': publicMasterKey,
      'encryptedDataKey': encryptedDataKey,
    },
  );

  /// Get account by public master key lookup
  ///
  /// Parameters:
  /// - [publicMasterKey]: Ed25519 public key as hex string (64 chars)
  ///
  /// Returns the AnonAccount if found, null if not found.
  ///
  /// Throws AuthenticationException if public key validation fails.
  /// Throws AnonAccredException for database or system errors.
  _i2.Future<_i3.AnonAccount?> getAccountByPublicKey(String publicMasterKey) =>
      caller.callServerEndpoint<_i3.AnonAccount?>(
        'anonaccred.account',
        'getAccountByPublicKey',
        {'publicMasterKey': publicMasterKey},
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
    'anonaccred.commerce',
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
        'anonaccred.commerce',
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
    'anonaccred.commerce',
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
    'anonaccred.commerce',
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
    'anonaccred.commerce',
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
    'anonaccred.commerce',
    'consumeInventory',
    {
      'publicKey': publicKey,
      'signature': signature,
      'accountId': accountId,
      'consumableType': consumableType,
      'quantity': quantity,
    },
  );
}

/// Device management endpoints for Ed25519-based device registration and authentication
///
/// This endpoint provides device management functionality including:
/// - Device registration with Ed25519 subkeys
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
  /// The device is identified by its Ed25519 public subkey.
  ///
  /// Parameters:
  /// - [accountId]: The account to associate the device with
  /// - [publicSubKey]: Ed25519 public key for the device (64 hex chars)
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
    String publicSubKey,
    String encryptedDataKey,
    String label,
  ) => caller.callServerEndpoint<_i8.AccountDevice>(
    'anonaccred.device',
    'registerDevice',
    {
      'accountId': accountId,
      'publicSubKey': publicSubKey,
      'encryptedDataKey': encryptedDataKey,
      'label': label,
    },
    authenticated: false,
  );

  /// Authenticate device with challenge-response
  ///
  /// Performs Ed25519 signature verification for device authentication.
  /// Updates the device's last active timestamp on successful authentication.
  /// Authentication already validated by Serverpod - device key extracted from session.
  ///
  /// Parameters:
  /// - [challenge]: The challenge string that was signed
  /// - [signature]: Ed25519 signature of the challenge
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
  /// Returns a hex-encoded challenge string.
  _i2.Future<String> generateAuthChallenge() =>
      caller.callServerEndpoint<String>(
        'anonaccred.device',
        'generateAuthChallenge',
        {},
        authenticated: false,
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

  /// Authenticates a user using Ed25519 signature verification
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
    String orderId,
    String paymentRail,
    double amount,
  ) => caller.callServerEndpoint<String>(
    'anonaccred.module',
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
    'anonaccred.module',
    'manageInventory',
    {
      'accountId': accountId,
      'consumableType': consumableType,
      'operation': operation,
      'quantity': quantity,
    },
  );
}

class Caller extends _i1.ModuleEndpointCaller {
  Caller(_i1.ServerpodClientShared client) : super(client) {
    account = EndpointAccount(this);
    commerce = EndpointCommerce(this);
    device = EndpointDevice(this);
    module = EndpointModule(this);
  }

  late final EndpointAccount account;

  late final EndpointCommerce commerce;

  late final EndpointDevice device;

  late final EndpointModule module;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'anonaccred.account': account,
    'anonaccred.commerce': commerce,
    'anonaccred.device': device,
    'anonaccred.module': module,
  };
}
