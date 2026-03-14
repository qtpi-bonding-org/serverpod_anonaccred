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
import 'package:anonaccount_client/src/protocol/account_creation_response.dart'
    as _i3;
import 'package:anonaccount_client/src/protocol/account.dart' as _i4;
import 'package:anonaccount_client/src/protocol/public_challenge_response.dart'
    as _i5;
import 'package:anonaccount_client/src/protocol/account_device.dart' as _i6;
import 'package:anonaccount_client/src/protocol/device_pairing_info.dart'
    as _i7;
import 'package:anonaccount_client/src/protocol/device_pairing_event.dart'
    as _i8;
import 'package:anonaccount_client/src/protocol/authentication_result.dart'
    as _i9;

/// Concrete account endpoint with built-in hashcash PoW spam prevention.
///
/// Extends [PowProtectedEndpoint] to inherit `getChallenge()` and `verifyPow()`.
///
/// Provides account creation and recovery with:
/// - Hashcash proof-of-work for spam prevention
/// - ECDSA P-256 signature verification
/// - Redis-based rate limiting by public key
///
/// Server-only query methods (getAccountById, getAccountByPublicKey) live
/// in [AccountQueryService] — not exposed to clients.
/// {@category Endpoint}
class EndpointAccount extends EndpointPowProtected {
  EndpointAccount(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccount.account';

  /// Create new anonymous account with PoW verification.
  ///
  /// Returns [AccountCreationResponse] — no internal int id exposed to client.
  _i2.Future<_i3.AccountCreationResponse> createAccount({
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String ultimateSigningPublicKeyHex,
    required String encryptedDataKey,
    required String ultimatePublicKey,
  }) => caller.callServerEndpoint<_i3.AccountCreationResponse>(
    'anonaccount.account',
    'createAccount',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'signature': signature,
      'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'ultimatePublicKey': ultimatePublicKey,
    },
  );

  /// Look up account for recovery with PoW verification.
  ///
  /// Requires PoW to prevent brute-force probing of public keys.
  /// Returns [AnonAccount] if found, or `null` if no account matches.
  _i2.Future<_i4.AnonAccount?> getAccountForRecovery({
    required String challenge,
    required String proofOfWork,
    required String ultimatePublicKey,
    required String signature,
  }) => caller.callServerEndpoint<_i4.AnonAccount?>(
    'anonaccount.account',
    'getAccountForRecovery',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'ultimatePublicKey': ultimatePublicKey,
      'signature': signature,
    },
  );

  /// Get challenge for proof-of-work.
  ///
  /// Returns a challenge string, difficulty, and expiration timestamp.
  /// Clients must solve the hashcash puzzle before calling PoW-protected methods.
  @override
  _i2.Future<_i5.PublicChallengeResponse> getChallenge() =>
      caller.callServerEndpoint<_i5.PublicChallengeResponse>(
        'anonaccount.account',
        'getChallenge',
        {},
      );

  /// Verify proof-of-work, ECDSA signature, and apply rate limiting.
  ///
  /// Call this at the top of each PoW-protected endpoint method.
  ///
  /// - [session] Serverpod session
  /// - [challenge] The challenge string from [getChallenge]
  /// - [proofOfWork] The hashcash stamp mined by the client
  /// - [publicKeyHex] The ECDSA P-256 public key (128 hex chars)
  /// - [signature] ECDSA signature over [payload]
  /// - [payload] The signed payload (typically `'$challenge:methodName:$publicKeyHex'`)
  @override
  _i2.Future<void> verifyPow(
    String challenge,
    String proofOfWork,
    String publicKeyHex,
    String signature,
    String payload,
  ) => caller.callServerEndpoint<void>(
    'anonaccount.account',
    'verifyPow',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'publicKeyHex': publicKeyHex,
      'signature': signature,
      'payload': payload,
    },
  );
}

/// Abstract base class for endpoints requiring device-key authentication.
///
/// Subclasses get:
/// - `requireLogin => true` (Serverpod enforces authentication)
/// - `getDevicePublicKey()` to extract the authenticated device's public key
/// - `getAccountId()` to extract the authenticated account's ID
///
/// Usage in consuming projects:
/// ```dart
/// class MyProtectedEndpoint extends AuthenticatedEndpoint {
///   Future<MyData> getData(Session session) async {
///     final deviceKey = getDevicePublicKey(session);
///     final accountId = getAccountId(session);
///     // ... business logic using authenticated identity
///   }
/// }
/// ```
/// {@category Endpoint}
abstract class EndpointAuthenticated extends _i1.EndpointRef {
  EndpointAuthenticated(_i1.EndpointCaller caller) : super(caller);
}

/// Public device endpoints protected by hashcash proof-of-work.
///
/// Extends [PowProtectedEndpoint] to inherit `getChallenge()` and `verifyPow()`.
///
/// Handles unauthenticated device operations:
/// - Device registration
/// - Auth challenge generation
/// - Device pairing lookup and monitoring
///
/// Authenticated device operations (revoke, list, QR pairing) are in
/// [DeviceManagementEndpoint].
/// {@category Endpoint}
class EndpointDevice extends EndpointPowProtected {
  EndpointDevice(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccount.device';

  /// Register new device with account (PoW-protected).
  ///
  /// Creates a new device registration associated with an account.
  /// The account is resolved from the ultimate signing public key.
  _i2.Future<_i6.AccountDevice> registerDevice({
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String ultimateSigningPublicKeyHex,
    required String deviceSigningPublicKeyHex,
    required String encryptedDataKey,
    required String label,
  }) => caller.callServerEndpoint<_i6.AccountDevice>(
    'anonaccount.device',
    'registerDevice',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'signature': signature,
      'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
      'deviceSigningPublicKeyHex': deviceSigningPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'label': label,
    },
  );

  /// Generate authentication challenge (PoW-protected).
  ///
  /// Creates a cryptographically secure challenge string for client use.
  /// The challenge should be signed by the client's private key and returned
  /// for verification via authenticateDevice.
  _i2.Future<String> generateAuthChallenge({
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String devicePublicKey,
  }) => caller.callServerEndpoint<String>(
    'anonaccount.device',
    'generateAuthChallenge',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'signature': signature,
      'devicePublicKey': devicePublicKey,
    },
  );

  /// Get device info by signing public key (PoW-protected).
  ///
  /// Used by Device B during pairing to get its encrypted data key.
  /// Only returns the encrypted blob (useless without Device B's private key).
  _i2.Future<_i7.DevicePairingInfo?> getDeviceBySigningKey({
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String signingPublicKeyHex,
  }) => caller.callServerEndpoint<_i7.DevicePairingInfo?>(
    'anonaccount.device',
    'getDeviceBySigningKey',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'signature': signature,
      'signingPublicKeyHex': signingPublicKeyHex,
    },
  );

  /// Monitor registration status for a specific signing key (PoW-protected).
  ///
  /// Device B (unauthenticated) calls this to wait for Device A to complete
  /// the registration. PoW is verified before opening the stream.
  _i2.Stream<_i8.DevicePairingEvent> monitorRegistration({
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String signingKeyHex,
  }) =>
      caller.callStreamingServerEndpoint<
        _i2.Stream<_i8.DevicePairingEvent>,
        _i8.DevicePairingEvent
      >(
        'anonaccount.device',
        'monitorRegistration',
        {
          'challenge': challenge,
          'proofOfWork': proofOfWork,
          'signature': signature,
          'signingKeyHex': signingKeyHex,
        },
        {},
      );

  /// Get challenge for proof-of-work.
  ///
  /// Returns a challenge string, difficulty, and expiration timestamp.
  /// Clients must solve the hashcash puzzle before calling PoW-protected methods.
  @override
  _i2.Future<_i5.PublicChallengeResponse> getChallenge() =>
      caller.callServerEndpoint<_i5.PublicChallengeResponse>(
        'anonaccount.device',
        'getChallenge',
        {},
      );

  /// Verify proof-of-work, ECDSA signature, and apply rate limiting.
  ///
  /// Call this at the top of each PoW-protected endpoint method.
  ///
  /// - [session] Serverpod session
  /// - [challenge] The challenge string from [getChallenge]
  /// - [proofOfWork] The hashcash stamp mined by the client
  /// - [publicKeyHex] The ECDSA P-256 public key (128 hex chars)
  /// - [signature] ECDSA signature over [payload]
  /// - [payload] The signed payload (typically `'$challenge:methodName:$publicKeyHex'`)
  @override
  _i2.Future<void> verifyPow(
    String challenge,
    String proofOfWork,
    String publicKeyHex,
    String signature,
    String payload,
  ) => caller.callServerEndpoint<void>(
    'anonaccount.device',
    'verifyPow',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'publicKeyHex': publicKeyHex,
      'signature': signature,
      'payload': payload,
    },
  );
}

/// Authenticated device management endpoints.
///
/// All methods require session authentication (device key).
/// Handles device authentication, revocation, listing, and QR pairing.
/// {@category Endpoint}
class EndpointDeviceManagement extends EndpointAuthenticated {
  EndpointDeviceManagement(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccount.deviceManagement';

  /// Authenticate device with challenge-response.
  ///
  /// Performs ECDSA P-256 signature verification.
  /// Updates the device's last active timestamp on success.
  _i2.Future<_i9.AuthenticationResult> authenticateDevice(
    String challenge,
    String signature,
  ) => caller.callServerEndpoint<_i9.AuthenticationResult>(
    'anonaccount.deviceManagement',
    'authenticateDevice',
    {
      'challenge': challenge,
      'signature': signature,
    },
  );

  /// Revoke device access.
  _i2.Future<bool> revokeDevice(int deviceId) =>
      caller.callServerEndpoint<bool>(
        'anonaccount.deviceManagement',
        'revokeDevice',
        {'deviceId': deviceId},
      );

  /// List account devices.
  _i2.Future<List<_i6.AccountDevice>> listDevices() =>
      caller.callServerEndpoint<List<_i6.AccountDevice>>(
        'anonaccount.deviceManagement',
        'listDevices',
        {},
      );

  /// Register a new device for the caller's account.
  ///
  /// QR code pairing flow: Device A (authenticated) registers Device B.
  _i2.Future<_i6.AccountDevice> registerDeviceForAccount(
    String newDeviceSigningPublicKeyHex,
    String newDeviceEncryptedDataKey,
    String label,
  ) => caller.callServerEndpoint<_i6.AccountDevice>(
    'anonaccount.deviceManagement',
    'registerDeviceForAccount',
    {
      'newDeviceSigningPublicKeyHex': newDeviceSigningPublicKeyHex,
      'newDeviceEncryptedDataKey': newDeviceEncryptedDataKey,
      'label': label,
    },
  );
}

/// Abstract base class for unauthenticated endpoints protected by
/// hashcash proof-of-work + ECDSA signature + rate limiting.
///
/// Subclasses get:
/// - `getChallenge()` endpoint method (auto-registered by Serverpod)
/// - `verifyPow()` helper to call at the top of each endpoint method
/// - Configurable rate limiting via `endpointType` and `rateLimitPerHour`
///
/// Usage in consuming projects:
/// ```dart
/// class MyPublicEndpoint extends PowProtectedEndpoint {
///   @override
///   String get endpointType => 'my_endpoint';
///
///   @override
///   int get rateLimitPerHour => 20;
///
///   Future<MyResponse> submitThing(
///     Session session, {
///     required String challenge,
///     required String proofOfWork,
///     required String signature,
///     required String publicKeyHex,
///     required String data,
///   }) async {
///     await verifyPow(session, challenge, proofOfWork, publicKeyHex,
///         signature, '$challenge:submitThing:$publicKeyHex');
///     // ... business logic
///   }
/// }
/// ```
/// {@category Endpoint}
abstract class EndpointPowProtected extends _i1.EndpointRef {
  EndpointPowProtected(_i1.EndpointCaller caller) : super(caller);

  /// Get challenge for proof-of-work.
  ///
  /// Returns a challenge string, difficulty, and expiration timestamp.
  /// Clients must solve the hashcash puzzle before calling PoW-protected methods.
  _i2.Future<_i5.PublicChallengeResponse> getChallenge();

  /// Verify proof-of-work, ECDSA signature, and apply rate limiting.
  ///
  /// Call this at the top of each PoW-protected endpoint method.
  ///
  /// - [session] Serverpod session
  /// - [challenge] The challenge string from [getChallenge]
  /// - [proofOfWork] The hashcash stamp mined by the client
  /// - [publicKeyHex] The ECDSA P-256 public key (128 hex chars)
  /// - [signature] ECDSA signature over [payload]
  /// - [payload] The signed payload (typically `'$challenge:methodName:$publicKeyHex'`)
  _i2.Future<void> verifyPow(
    String challenge,
    String proofOfWork,
    String publicKeyHex,
    String signature,
    String payload,
  );
}

class Caller extends _i1.ModuleEndpointCaller {
  Caller(_i1.ServerpodClientShared client) : super(client) {
    account = EndpointAccount(this);
    device = EndpointDevice(this);
    deviceManagement = EndpointDeviceManagement(this);
  }

  late final EndpointAccount account;

  late final EndpointDevice device;

  late final EndpointDeviceManagement deviceManagement;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'anonaccount.account': account,
    'anonaccount.device': device,
    'anonaccount.deviceManagement': deviceManagement,
  };
}
