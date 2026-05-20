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
import 'package:anonaccount_client/src/protocol/share_group.dart' as _i9;
import 'package:anonaccount_client/src/protocol/group_member.dart' as _i10;
import 'package:anonaccount_client/src/protocol/group_member_role.dart' as _i11;

/// Account endpoint with PoW + signature protection.
///
/// Extends [SignedPowEndpoint] to inherit `getChallenge()` and `verifySignedPow()`.
///
/// Provides account creation with:
/// - Hashcash proof-of-work for spam prevention
/// - ECDSA P-256 signature verification
/// - Redis-based rate limiting by public key
/// - Atomic first-device registration (account + device in one call)
///
/// Server-only query methods (getAccountById, getAccountByPublicKey) live
/// in [AccountQueryService] — not exposed to clients.
/// {@category Endpoint}
class EndpointAccount extends EndpointSignedPow {
  EndpointAccount(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccount.account';

  /// Create new anonymous account with first device, atomically.
  ///
  /// Creates the account and registers the first device in a single call.
  /// An account without a device is useless, so this ensures they're always
  /// created together. Additional devices use [DeviceEndpoint.registerDevice].
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
    required String deviceKeyAttestation,
    required String deviceSigningPublicKeyHex,
    required String deviceEncryptedDataKey,
    required String deviceLabel,
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
      'deviceKeyAttestation': deviceKeyAttestation,
      'deviceSigningPublicKeyHex': deviceSigningPublicKeyHex,
      'deviceEncryptedDataKey': deviceEncryptedDataKey,
      'deviceLabel': deviceLabel,
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
    required String deviceKeyAttestation,
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
      'deviceKeyAttestation': deviceKeyAttestation,
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

/// SignedPoW-protected device management endpoints.
///
/// All methods require hashcash PoW + ECDSA signature + rate limiting.
/// Handles device revocation, listing, and QR pairing.
/// {@category Endpoint}
class EndpointDeviceManagement extends EndpointSignedPow {
  EndpointDeviceManagement(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccount.deviceManagement';

  /// Revoke device access.
  _i2.Future<bool> revokeDevice({
    required String challenge,
    required String proofOfWork,
    required String publicKeyHex,
    required String signature,
    required _i1.UuidValue deviceId,
  }) => caller.callServerEndpoint<bool>(
    'anonaccount.deviceManagement',
    'revokeDevice',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'publicKeyHex': publicKeyHex,
      'signature': signature,
      'deviceId': deviceId,
    },
  );

  /// List account devices.
  _i2.Future<List<_i6.AccountDevice>> listDevices({
    required String challenge,
    required String proofOfWork,
    required String publicKeyHex,
    required String signature,
  }) => caller.callServerEndpoint<List<_i6.AccountDevice>>(
    'anonaccount.deviceManagement',
    'listDevices',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'publicKeyHex': publicKeyHex,
      'signature': signature,
    },
  );

  /// Register a new device for the caller's account.
  ///
  /// QR code pairing flow: Device A (authenticated) registers Device B.
  _i2.Future<_i6.AccountDevice> registerDeviceForAccount({
    required String challenge,
    required String proofOfWork,
    required String publicKeyHex,
    required String signature,
    required String newDeviceSigningPublicKeyHex,
    required String newDeviceEncryptedDataKey,
    required String label,
  }) => caller.callServerEndpoint<_i6.AccountDevice>(
    'anonaccount.deviceManagement',
    'registerDeviceForAccount',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'publicKeyHex': publicKeyHex,
      'signature': signature,
      'newDeviceSigningPublicKeyHex': newDeviceSigningPublicKeyHex,
      'newDeviceEncryptedDataKey': newDeviceEncryptedDataKey,
      'label': label,
    },
  );

  /// Throws — use [EntrypointEndpoint.getChallenge] instead.
  ///
  /// Overridden without `@doNotGenerate` so the generated client class gets a
  /// concrete implementation, satisfying the abstract [EndpointPow.getChallenge].
  @override
  _i2.Future<_i4.PublicChallengeResponse> getChallenge() =>
      caller.callServerEndpoint<_i4.PublicChallengeResponse>(
        'anonaccount.deviceManagement',
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
    'anonaccount.deviceManagement',
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
    'anonaccount.deviceManagement',
    'verifyHashcash',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
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

/// Three-tier auth model for group operations:
///
/// 1. **Transport (outer envelope):** every call carries a PoW + ECDSA
///    signature from the caller's device key. Same shape as every other
///    `SignedPowEndpoint`. Proves the request is live and from a
///    non-revoked device of some account.
/// 2. **Role (inner signature):** for admin-tier ops where the role is
///    `member`, the caller's group-member signing key signs an
///    operation-specific payload. The server verifies against the row
///    in `group_member` and asserts `role = admin`, not revoked, and
///    account-bound to the device-resolved account.
/// 3. **Owner (inner signature):** for owner-tier ops (creating the
///    group, granting/removing admins), the group's ultimate signing
///    key signs the inner payload. The server verifies against
///    `share_group.ultimateSigningPublicKeyHex`. There is no DB role
///    for "owner" — possession of the ultimate private key IS owner
///    authority.
///
/// Inner payloads are challenge-free so the persisted attestation is
/// reconstructable from row state alone. Outer envelopes keep the
/// challenge for transport replay protection (PoW).
/// {@category Endpoint}
class EndpointGroup extends EndpointSignedPow {
  EndpointGroup(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonaccount.group';

  /// Create a new share group.
  ///
  /// The creator becomes the first `admin`. Possession of the new
  /// group's ultimate signing private key (proven by signing the inner
  /// payload) makes them an "owner" — there is no DB role for that.
  _i2.Future<_i9.ShareGroup> createGroup({
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required String groupUltimateSigningPublicKeyHex,
    required String groupUltimatePublicKey,
    required String groupEncryptedDataKey,
    required String creatorMemberSigningPublicKeyHex,
    required String creatorMemberPublicKey,
    required String creatorMemberEncryptedDataKey,
    required String groupUltimateAttestation,
  }) => caller.callServerEndpoint<_i9.ShareGroup>(
    'anonaccount.group',
    'createGroup',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'signature': signature,
      'callerDeviceSigningPublicKeyHex': callerDeviceSigningPublicKeyHex,
      'groupUltimateSigningPublicKeyHex': groupUltimateSigningPublicKeyHex,
      'groupUltimatePublicKey': groupUltimatePublicKey,
      'groupEncryptedDataKey': groupEncryptedDataKey,
      'creatorMemberSigningPublicKeyHex': creatorMemberSigningPublicKeyHex,
      'creatorMemberPublicKey': creatorMemberPublicKey,
      'creatorMemberEncryptedDataKey': creatorMemberEncryptedDataKey,
      'groupUltimateAttestation': groupUltimateAttestation,
    },
  );

  /// List the caller's non-revoked group memberships.
  _i2.Future<List<_i10.GroupMember>> listMyGroups({
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
  }) => caller.callServerEndpoint<List<_i10.GroupMember>>(
    'anonaccount.group',
    'listMyGroups',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'signature': signature,
      'callerDeviceSigningPublicKeyHex': callerDeviceSigningPublicKeyHex,
    },
  );

  /// Add a new member to a group.
  ///
  /// Auth branches on [role]:
  /// - `member`: requires `callerMemberSigningPublicKeyHex` +
  ///   `memberAuthSignature`. Caller's `group_member` row must be
  ///   `role = admin`, not revoked, and account-bound to the
  ///   device-resolved account.
  /// - `admin`: requires `groupUltimateSignature`. Verified against
  ///   `share_group.ultimateSigningPublicKeyHex`. Member-tier params
  ///   are ignored.
  _i2.Future<_i10.GroupMember> addGroupMember({
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required _i1.UuidValue groupId,
    required _i1.UuidValue newMemberAccountId,
    required _i11.GroupMemberRole role,
    required String memberSigningPublicKeyHex,
    required String memberPublicKey,
    required String encryptedDataKey,
    String? callerMemberSigningPublicKeyHex,
    String? memberAuthSignature,
    String? groupUltimateSignature,
  }) => caller.callServerEndpoint<_i10.GroupMember>(
    'anonaccount.group',
    'addGroupMember',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'signature': signature,
      'callerDeviceSigningPublicKeyHex': callerDeviceSigningPublicKeyHex,
      'groupId': groupId,
      'newMemberAccountId': newMemberAccountId,
      'role': role,
      'memberSigningPublicKeyHex': memberSigningPublicKeyHex,
      'memberPublicKey': memberPublicKey,
      'encryptedDataKey': encryptedDataKey,
      'callerMemberSigningPublicKeyHex': callerMemberSigningPublicKeyHex,
      'memberAuthSignature': memberAuthSignature,
      'groupUltimateSignature': groupUltimateSignature,
    },
  );

  /// Mark a group member as revoked.
  ///
  /// Auth branches on the target row's [role]:
  /// - target `member`: caller's member key must be admin (+ binding check).
  /// - target `admin`: requires `groupUltimateSignature`.
  _i2.Future<bool> removeGroupMember({
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required _i1.UuidValue memberId,
    String? callerMemberSigningPublicKeyHex,
    String? memberAuthSignature,
    String? groupUltimateSignature,
  }) => caller.callServerEndpoint<bool>(
    'anonaccount.group',
    'removeGroupMember',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'signature': signature,
      'callerDeviceSigningPublicKeyHex': callerDeviceSigningPublicKeyHex,
      'memberId': memberId,
      'callerMemberSigningPublicKeyHex': callerMemberSigningPublicKeyHex,
      'memberAuthSignature': memberAuthSignature,
      'groupUltimateSignature': groupUltimateSignature,
    },
  );

  _i2.Stream<_i10.GroupMember> monitorGroupMembership({
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required String memberSigningKeyHex,
  }) =>
      caller.callStreamingServerEndpoint<
        _i2.Stream<_i10.GroupMember>,
        _i10.GroupMember
      >(
        'anonaccount.group',
        'monitorGroupMembership',
        {
          'challenge': challenge,
          'proofOfWork': proofOfWork,
          'signature': signature,
          'callerDeviceSigningPublicKeyHex': callerDeviceSigningPublicKeyHex,
          'memberSigningKeyHex': memberSigningKeyHex,
        },
        {},
      );

  _i2.Future<_i9.ShareGroup> getGroup({
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required _i1.UuidValue groupId,
    required String callerMemberSigningPublicKeyHex,
    required String memberAuthSignature,
  }) => caller.callServerEndpoint<_i9.ShareGroup>(
    'anonaccount.group',
    'getGroup',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'signature': signature,
      'callerDeviceSigningPublicKeyHex': callerDeviceSigningPublicKeyHex,
      'groupId': groupId,
      'callerMemberSigningPublicKeyHex': callerMemberSigningPublicKeyHex,
      'memberAuthSignature': memberAuthSignature,
    },
  );

  _i2.Future<List<_i10.GroupMember>> listGroupMembers({
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required _i1.UuidValue groupId,
    required String callerMemberSigningPublicKeyHex,
    required String memberAuthSignature,
  }) => caller.callServerEndpoint<List<_i10.GroupMember>>(
    'anonaccount.group',
    'listGroupMembers',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'signature': signature,
      'callerDeviceSigningPublicKeyHex': callerDeviceSigningPublicKeyHex,
      'groupId': groupId,
      'callerMemberSigningPublicKeyHex': callerMemberSigningPublicKeyHex,
      'memberAuthSignature': memberAuthSignature,
    },
  );

  _i2.Future<bool> leaveGroup({
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required _i1.UuidValue memberId,
    required String memberSigningPublicKeyHex,
    required String memberAuthSignature,
  }) => caller.callServerEndpoint<bool>(
    'anonaccount.group',
    'leaveGroup',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
      'signature': signature,
      'callerDeviceSigningPublicKeyHex': callerDeviceSigningPublicKeyHex,
      'memberId': memberId,
      'memberSigningPublicKeyHex': memberSigningPublicKeyHex,
      'memberAuthSignature': memberAuthSignature,
    },
  );

  /// Throws — use [EntrypointEndpoint.getChallenge] instead.
  ///
  /// Overridden without `@doNotGenerate` so the generated client class gets a
  /// concrete implementation, satisfying the abstract [EndpointPow.getChallenge].
  @override
  _i2.Future<_i4.PublicChallengeResponse> getChallenge() =>
      caller.callServerEndpoint<_i4.PublicChallengeResponse>(
        'anonaccount.group',
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
    'anonaccount.group',
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
    'anonaccount.group',
    'verifyHashcash',
    {
      'challenge': challenge,
      'proofOfWork': proofOfWork,
    },
  );
}

/// Abstract base class for JWT-protected endpoints.
///
/// Serverpod validates the JWT before the method runs (via `initializeAuthServices`).
/// Subclasses get:
/// - `requireLogin => true` (Serverpod enforces JWT validation)
/// - `getDevicePublicKey()` to extract the device's public key from JWT scopes
/// - `getAccountUuid()` to extract the account's UUID from JWT claims
///
/// Usage:
/// ```dart
/// class MyProtectedEndpoint extends JwtEndpoint {
///   Future<MyData> getData(Session session) async {
///     final accountUuid = getAccountUuid(session);
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
    group = EndpointGroup(this);
  }

  late final EndpointAccount account;

  late final EndpointDataKey dataKey;

  late final EndpointDevice device;

  late final EndpointDeviceManagement deviceManagement;

  late final EndpointEntrypoint entrypoint;

  late final EndpointGroup group;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'anonaccount.account': account,
    'anonaccount.dataKey': dataKey,
    'anonaccount.device': device,
    'anonaccount.deviceManagement': deviceManagement,
    'anonaccount.entrypoint': entrypoint,
    'anonaccount.group': group,
  };
}
