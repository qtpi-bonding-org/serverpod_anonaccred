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
import 'package:anonaccount_client/src/protocol/public_challenge_response.dart'
    as _i4;
import 'package:anonaccount_client/src/protocol/encrypted_data_key_response.dart'
    as _i5;
import 'package:anonaccount_client/src/protocol/account_device.dart' as _i6;
import 'package:anonaccount_client/src/protocol/authentication_result.dart'
    as _i7;
import 'package:anonaccount_client/src/protocol/device_pairing_event.dart'
    as _i8;

/// Account endpoint with PoW + signature protection.
///
/// Extends [SignedPowEndpoint] to inherit `getChallenge()` and `verifySignedPow()`.
///
/// Provides account creation and recovery with:
/// - Hashcash proof-of-work for spam prevention
/// - ECDSA P-256 signature verification
/// - Redis-based rate limiting by public key
///
/// Server-only query methods (getAccountById, getAccountByPublicKey) live
/// in [AccountQueryService] — not exposed to clients.
/// {@category Endpoint}
class EndpointAccount extends EndpointSignedPow {
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
    required String publicKeyHex,
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
      'publicKeyHex': publicKeyHex,
      'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'ultimatePublicKey': ultimatePublicKey,
    },
  );

  /// Throws — use [EntrypointEndpoint.getChallenge] instead.
  ///
  /// Overridden without `@doNotGenerate` so the generated client class gets a
  /// concrete implementation, satisfying the abstract [EndpointPow.getChallenge].
  @override
  _i2.Future<_i4.PublicChallengeResponse> getChallenge() =>
      caller.callServerEndpoint<_i4.PublicChallengeResponse>(
        'anonaccount.account',
        'getChallenge',
        {},
      );

  /// Verify PoW + ECDSA signature + rate limit.
  ///
  /// Call this at the top of each protected endpoint method.
  ///
  /// - [session] Serverpod session
  /// - [challenge] The challenge string from [getChallenge]
  /// - [proofOfWork] The hashcash stamp mined by the client
  /// - [publicKeyHex] The ECDSA P-256 public key (128 hex chars)
  /// - [signature] ECDSA signature over [payload]
  /// - [payload] The signed payload (typically `'$challenge:methodName:$publicKeyHex'`)
  @override
  _i2.Future<void> verifySignedPow(
    String challenge,
    String proofOfWork,
    String publicKeyHex,
    String signature,
    String payload,
  ) => caller.callServerEndpoint<void>(
    'anonaccount.account',
    'verifySignedPow',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'publicKeyHex': publicKeyHex,
      'signature': signature,
      'payload': payload,
    },
  );

  /// Verify hashcash proof-of-work only (no signature, no rate limit).
  ///
  /// Checks stamp format, challenge existence, and hash quality.
  /// Consumes the challenge (one-time use).
  @override
  _i2.Future<void> verifyHashcash(
    String challenge,
    String proofOfWork,
  ) => caller.callServerEndpoint<void>(
    'anonaccount.account',
    'verifyHashcash',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
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

/// PoW-protected endpoint for fetching a device's encrypted data key.
///
/// Two paths:
/// - [retrieveEncryptedDataKey]: device proves ownership → returns
///   [AccountDevice.encryptedDataKey]. Fails if device is revoked.
/// - [recoverEncryptedDataKey]: ultimate key proves ownership → returns
///   [AnonAccount.encryptedDataKey]. Used for account recovery when all
///   devices are lost.
///
/// `signIn` intentionally does NOT return the key — this endpoint is called
/// only when the in-memory key is unavailable (fresh install, memory cleared).
/// {@category Endpoint}
class EndpointDataKey extends EndpointSignedPow {
  EndpointDataKey(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccount.dataKey';

  /// Retrieve encrypted data key for a registered, non-revoked device.
  _i2.Future<_i5.EncryptedDataKeyResponse> retrieveEncryptedDataKey({
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String deviceSigningPublicKeyHex,
  }) => caller.callServerEndpoint<_i5.EncryptedDataKeyResponse>(
    'anonaccount.dataKey',
    'retrieveEncryptedDataKey',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'signature': signature,
      'deviceSigningPublicKeyHex': deviceSigningPublicKeyHex,
    },
  );

  /// Recover encrypted data key using the account's ultimate signing key.
  _i2.Future<_i5.EncryptedDataKeyResponse> recoverEncryptedDataKey({
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String ultimateSigningPublicKeyHex,
  }) => caller.callServerEndpoint<_i5.EncryptedDataKeyResponse>(
    'anonaccount.dataKey',
    'recoverEncryptedDataKey',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'signature': signature,
      'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
    },
  );

  /// Throws — use [EntrypointEndpoint.getChallenge] instead.
  ///
  /// Overridden without `@doNotGenerate` so the generated client class gets a
  /// concrete implementation, satisfying the abstract [EndpointPow.getChallenge].
  @override
  _i2.Future<_i4.PublicChallengeResponse> getChallenge() =>
      caller.callServerEndpoint<_i4.PublicChallengeResponse>(
        'anonaccount.dataKey',
        'getChallenge',
        {},
      );

  /// Verify PoW + ECDSA signature + rate limit.
  ///
  /// Call this at the top of each protected endpoint method.
  ///
  /// - [session] Serverpod session
  /// - [challenge] The challenge string from [getChallenge]
  /// - [proofOfWork] The hashcash stamp mined by the client
  /// - [publicKeyHex] The ECDSA P-256 public key (128 hex chars)
  /// - [signature] ECDSA signature over [payload]
  /// - [payload] The signed payload (typically `'$challenge:methodName:$publicKeyHex'`)
  @override
  _i2.Future<void> verifySignedPow(
    String challenge,
    String proofOfWork,
    String publicKeyHex,
    String signature,
    String payload,
  ) => caller.callServerEndpoint<void>(
    'anonaccount.dataKey',
    'verifySignedPow',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'publicKeyHex': publicKeyHex,
      'signature': signature,
      'payload': payload,
    },
  );

  /// Verify hashcash proof-of-work only (no signature, no rate limit).
  ///
  /// Checks stamp format, challenge existence, and hash quality.
  /// Consumes the challenge (one-time use).
  @override
  _i2.Future<void> verifyHashcash(
    String challenge,
    String proofOfWork,
  ) => caller.callServerEndpoint<void>(
    'anonaccount.dataKey',
    'verifyHashcash',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
    },
  );
}

/// Public device endpoints protected by hashcash proof-of-work.
///
/// Extends [SignedPowEndpoint] to inherit `getChallenge()` and `verifySignedPow()`.
///
/// Handles unauthenticated device operations:
/// - Device registration
/// - Auth challenge generation
/// - Device pairing lookup and monitoring
///
/// Authenticated device operations (revoke, list, QR pairing) are in
/// [DeviceManagementEndpoint].
/// {@category Endpoint}
class EndpointDevice extends EndpointSignedPow {
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

  /// Sign in with a registered device (PoW-protected).
  ///
  /// Verifies PoW + ECDSA signature, looks up the device, and issues
  /// an authentication token via the host-configured token issuer.
  ///
  /// Returns an [AuthenticationResult] containing the token on success.
  _i2.Future<_i7.AuthenticationResult> signIn({
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String devicePublicKeyHex,
  }) => caller.callServerEndpoint<_i7.AuthenticationResult>(
    'anonaccount.device',
    'signIn',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'signature': signature,
      'devicePublicKeyHex': devicePublicKeyHex,
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

  /// Throws — use [EntrypointEndpoint.getChallenge] instead.
  ///
  /// Overridden without `@doNotGenerate` so the generated client class gets a
  /// concrete implementation, satisfying the abstract [EndpointPow.getChallenge].
  @override
  _i2.Future<_i4.PublicChallengeResponse> getChallenge() =>
      caller.callServerEndpoint<_i4.PublicChallengeResponse>(
        'anonaccount.device',
        'getChallenge',
        {},
      );

  /// Verify PoW + ECDSA signature + rate limit.
  ///
  /// Call this at the top of each protected endpoint method.
  ///
  /// - [session] Serverpod session
  /// - [challenge] The challenge string from [getChallenge]
  /// - [proofOfWork] The hashcash stamp mined by the client
  /// - [publicKeyHex] The ECDSA P-256 public key (128 hex chars)
  /// - [signature] ECDSA signature over [payload]
  /// - [payload] The signed payload (typically `'$challenge:methodName:$publicKeyHex'`)
  @override
  _i2.Future<void> verifySignedPow(
    String challenge,
    String proofOfWork,
    String publicKeyHex,
    String signature,
    String payload,
  ) => caller.callServerEndpoint<void>(
    'anonaccount.device',
    'verifySignedPow',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'publicKeyHex': publicKeyHex,
      'signature': signature,
      'payload': payload,
    },
  );

  /// Verify hashcash proof-of-work only (no signature, no rate limit).
  ///
  /// Checks stamp format, challenge existence, and hash quality.
  /// Consumes the challenge (one-time use).
  @override
  _i2.Future<void> verifyHashcash(
    String challenge,
    String proofOfWork,
  ) => caller.callServerEndpoint<void>(
    'anonaccount.device',
    'verifyHashcash',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
    },
  );
}

/// JWT-protected device management endpoints.
///
/// All methods require a valid JWT (obtained via [DeviceEndpoint.signIn]).
/// Handles device revocation, listing, and QR pairing.
/// {@category Endpoint}
class EndpointDeviceManagement extends EndpointJwt {
  EndpointDeviceManagement(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccount.deviceManagement';

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

/// Single entrypoint for PoW challenge issuance.
///
/// Exposes only [getChallenge] — clients call `entrypoint.getChallenge()`
/// to get a challenge before calling any [SignedPowEndpoint] method.
/// {@category Endpoint}
class EndpointEntrypoint extends EndpointPow {
  EndpointEntrypoint(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccount.entrypoint';

  /// Get challenge for proof-of-work.
  ///
  /// Returns a challenge string, difficulty, and expiration timestamp.
  /// Clients must solve the hashcash puzzle before calling protected methods.
  @override
  _i2.Future<_i4.PublicChallengeResponse> getChallenge() =>
      caller.callServerEndpoint<_i4.PublicChallengeResponse>(
        'anonaccount.entrypoint',
        'getChallenge',
        {},
      );

  /// Verify hashcash proof-of-work only (no signature, no rate limit).
  ///
  /// Checks stamp format, challenge existence, and hash quality.
  /// Consumes the challenge (one-time use).
  @override
  _i2.Future<void> verifyHashcash(
    String challenge,
    String proofOfWork,
  ) => caller.callServerEndpoint<void>(
    'anonaccount.entrypoint',
    'verifyHashcash',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
    },
  );
}

/// Abstract base class for JWT-protected endpoints.
///
/// Serverpod validates the JWT before the method runs.
/// Subclasses get:
/// - `requireLogin => true` (Serverpod enforces JWT validation)
/// - `getDevicePublicKey()` to extract the device's public key from JWT scopes
/// - `getAccountId()` to extract the account ID from JWT claims
///
/// Usage:
/// ```dart
/// class MyProtectedEndpoint extends JwtEndpoint {
///   Future<MyData> getData(Session session) async {
///     final accountId = getAccountId(session);
///     // ... business logic using authenticated identity
///   }
/// }
/// ```
/// {@category Endpoint}
abstract class EndpointJwt extends _i1.EndpointRef {
  EndpointJwt(_i1.EndpointCaller caller) : super(caller);
}

/// Base endpoint with light hashcash protection.
///
/// Provides:
/// - `getChallenge()` to issue PoW puzzles
/// - `verifyHashcash()` to verify a solved puzzle (no signature, no rate limit)
/// - Configurable difficulty via [hashcashDifficulty]
///
/// Use for entrypoint endpoints that need spam prevention but don't
/// require identity verification (e.g., challenge issuance).
/// {@category Endpoint}
abstract class EndpointPow extends _i1.EndpointRef {
  EndpointPow(_i1.EndpointCaller caller) : super(caller);

  /// Get challenge for proof-of-work.
  ///
  /// Returns a challenge string, difficulty, and expiration timestamp.
  /// Clients must solve the hashcash puzzle before calling protected methods.
  _i2.Future<_i4.PublicChallengeResponse> getChallenge();

  /// Verify hashcash proof-of-work only (no signature, no rate limit).
  ///
  /// Checks stamp format, challenge existence, and hash quality.
  /// Consumes the challenge (one-time use).
  _i2.Future<void> verifyHashcash(
    String challenge,
    String proofOfWork,
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
  _i2.Future<_i4.PublicChallengeResponse> getChallenge();

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

/// Endpoint with full PoW + ECDSA signature verification + rate limiting.
///
/// Extends [PowEndpoint] to add:
/// - ECDSA P-256 signature verification (proves private key ownership)
/// - Per-public-key rate limiting (no IP tracking)
///
/// Subclasses call [verifySignedPow] at the top of each endpoint method.
///
/// Note: [getChallenge] throws — clients use [EntrypointEndpoint.getChallenge]
/// instead of per-endpoint challenges.
/// {@category Endpoint}
abstract class EndpointSignedPow extends EndpointPow {
  EndpointSignedPow(_i1.EndpointCaller caller) : super(caller);

  /// Throws — use [EntrypointEndpoint.getChallenge] instead.
  ///
  /// Overridden without `@doNotGenerate` so the generated client class gets a
  /// concrete implementation, satisfying the abstract [EndpointPow.getChallenge].
  @override
  _i2.Future<_i4.PublicChallengeResponse> getChallenge();

  /// Verify PoW + ECDSA signature + rate limit.
  ///
  /// Call this at the top of each protected endpoint method.
  ///
  /// - [session] Serverpod session
  /// - [challenge] The challenge string from [getChallenge]
  /// - [proofOfWork] The hashcash stamp mined by the client
  /// - [publicKeyHex] The ECDSA P-256 public key (128 hex chars)
  /// - [signature] ECDSA signature over [payload]
  /// - [payload] The signed payload (typically `'$challenge:methodName:$publicKeyHex'`)
  _i2.Future<void> verifySignedPow(
    String challenge,
    String proofOfWork,
    String publicKeyHex,
    String signature,
    String payload,
  );

  /// Verify hashcash proof-of-work only (no signature, no rate limit).
  ///
  /// Checks stamp format, challenge existence, and hash quality.
  /// Consumes the challenge (one-time use).
  @override
  _i2.Future<void> verifyHashcash(
    String challenge,
    String proofOfWork,
  );
}

class Caller extends _i1.ModuleEndpointCaller {
  Caller(_i1.ServerpodClientShared client) : super(client) {
    account = EndpointAccount(this);
    dataKey = EndpointDataKey(this);
    device = EndpointDevice(this);
    deviceManagement = EndpointDeviceManagement(this);
    entrypoint = EndpointEntrypoint(this);
  }

  late final EndpointAccount account;

  late final EndpointDataKey dataKey;

  late final EndpointDevice device;

  late final EndpointDeviceManagement deviceManagement;

  late final EndpointEntrypoint entrypoint;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'anonaccount.account': account,
    'anonaccount.dataKey': dataKey,
    'anonaccount.device': device,
    'anonaccount.deviceManagement': deviceManagement,
    'anonaccount.entrypoint': entrypoint,
  };
}
