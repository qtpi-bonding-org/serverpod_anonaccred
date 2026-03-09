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
import 'package:anonaccount_client/src/protocol/account.dart' as _i3;
import 'package:anonaccount_client/src/protocol/account_device.dart' as _i4;
import 'package:anonaccount_client/src/protocol/authentication_result.dart'
    as _i5;
import 'package:anonaccount_client/src/protocol/device_pairing_event.dart'
    as _i6;
import 'package:anonaccount_client/src/protocol/device_pairing_info.dart'
    as _i7;

/// Account management endpoints for anonymous identity operations
/// {@category Endpoint}
class EndpointAccount extends _i1.EndpointRef {
  EndpointAccount(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccount.account';

  /// Create new anonymous account with ECDSA P-256 public key identity
  _i2.Future<_i3.AnonAccount> createAccount(
    String ultimateSigningPublicKeyHex,
    String encryptedDataKey,
    String ultimatePublicKey,
  ) => caller.callServerEndpoint<_i3.AnonAccount>(
    'anonaccount.account',
    'createAccount',
    {
      'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'ultimatePublicKey': ultimatePublicKey,
    },
  );

  /// Get account by ID, requiring it to exist
  _i2.Future<_i3.AnonAccount> getAccountById(int accountId) =>
      caller.callServerEndpoint<_i3.AnonAccount>(
        'anonaccount.account',
        'getAccountById',
        {'accountId': accountId},
      );

  /// Get account by public master key lookup
  _i2.Future<_i3.AnonAccount?> getAccountByPublicKey(
    String ultimateSigningPublicKeyHex,
  ) => caller.callServerEndpoint<_i3.AnonAccount?>(
    'anonaccount.account',
    'getAccountByPublicKey',
    {'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex},
  );

  /// Get account for recovery by ultimate public key
  _i2.Future<_i3.AnonAccount?> getAccountForRecovery(
    String ultimatePublicKey,
  ) => caller.callServerEndpoint<_i3.AnonAccount?>(
    'anonaccount.account',
    'getAccountForRecovery',
    {'ultimatePublicKey': ultimatePublicKey},
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
  String get name => 'anonaccount.device';

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
  _i2.Future<_i4.AccountDevice> registerDevice(
    int accountId,
    String deviceSigningPublicKeyHex,
    String encryptedDataKey,
    String label,
  ) => caller.callServerEndpoint<_i4.AccountDevice>(
    'anonaccount.device',
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
  _i2.Future<_i5.AuthenticationResult> authenticateDevice(
    String challenge,
    String signature,
  ) => caller.callServerEndpoint<_i5.AuthenticationResult>(
    'anonaccount.device',
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
        'anonaccount.device',
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
        'anonaccount.device',
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
  _i2.Future<List<_i4.AccountDevice>> listDevices() =>
      caller.callServerEndpoint<List<_i4.AccountDevice>>(
        'anonaccount.device',
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
  _i2.Stream<_i6.DevicePairingEvent> monitorRegistration(
    String signingKeyHex,
  ) =>
      caller.callStreamingServerEndpoint<
        _i2.Stream<_i6.DevicePairingEvent>,
        _i6.DevicePairingEvent
      >(
        'anonaccount.device',
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
  _i2.Future<_i4.AccountDevice> registerDeviceForAccount(
    String newDeviceSigningPublicKeyHex,
    String newDeviceEncryptedDataKey,
    String label,
  ) => caller.callServerEndpoint<_i4.AccountDevice>(
    'anonaccount.device',
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
  _i2.Future<_i7.DevicePairingInfo?> getDeviceBySigningKey(
    String signingPublicKeyHex,
  ) => caller.callServerEndpoint<_i7.DevicePairingInfo?>(
    'anonaccount.device',
    'getDeviceBySigningKey',
    {'signingPublicKeyHex': signingPublicKeyHex},
  );
}

class Caller extends _i1.ModuleEndpointCaller {
  Caller(_i1.ServerpodClientShared client) : super(client) {
    account = EndpointAccount(this);
    device = EndpointDevice(this);
  }

  late final EndpointAccount account;

  late final EndpointDevice device;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'anonaccount.account': account,
    'anonaccount.device': device,
  };
}
