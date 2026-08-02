import 'dart:convert';

// ignore: implementation_imports
import 'package:anonaccount_client/anonaccount_client.dart' as wire;
// ignore: implementation_imports
import 'package:anonaccount_client/src/pow_methods.dart'
    show GroupMethods, GroupInnerPayloads;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/client.dart' show Caller;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/grant_member_device_result.dart'
    show GrantMemberDeviceResult;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/grant_tier.dart'
    show GrantTier;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/group_member.dart'
    show GroupMember;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/group_member_role.dart'
    show GroupMemberRole;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/member_device_grant.dart'
    show MemberDeviceGrant;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/public_key_duo.dart'
    show PublicKeyDuo;
import 'package:anonaccount_client/anonaccount_client.dart' show UuidValue;
import 'package:dart_jwk_duo/dart_jwk_duo.dart'
    show
        EncryptionKeyPair,
        EncryptionPublicKeyHex,
        KeyDuo,
        SigningKeyPair,
        SigningPublicKeyHex;
import 'package:webcrypto/webcrypto.dart';

import '../crypto/asymmetric.dart';
import '../crypto/key_gen.dart';
import '../crypto/signing.dart';
import '../models/created_group.dart';
import '../models/group_membership.dart';
import 'pow_signer.dart';

/// High-level group lifecycle wrapper. Stateless. Each method takes the
/// keys it needs explicitly — the SDK does not retain state between calls.
class AnonaccountGroups {
  AnonaccountGroups(this._caller, {this.difficulty = PowSigner.defaultDifficulty});

  final Caller _caller;
  // ignore: unused_field
  final int difficulty;

  /// Creates a new group. Generates a fresh group ultimate KeyDuo, a
  /// fresh creator-member KeyDuo, and a fresh AES-GCM data key locally.
  /// Wraps the data key to both keypairs and posts to the server.
  Future<CreatedGroup> createGroup({
    required String displayName,
    required KeyDuo callerDeviceKey,
  }) async {
    // Group-scoped key material.
    final groupUltimate = await KeyGen.generateUltimateKey();
    final creatorMember = await KeyGen.generateDeviceKey();
    final dataKey = await AesGcmSecretKey.generateKey(256);

    final dataKeyJwk = jsonEncode(await dataKey.exportJsonWebKey());

    final groupUltimateKeys = await groupUltimate.exportPublicKeyDuo();
    final creatorMemberKeys = await creatorMember.exportPublicKeyDuo();
    final groupKeysWire = PublicKeyDuo(
      signingPublicKeyHex: groupUltimateKeys.signing.value,
      encryptionPublicKeyHex: groupUltimateKeys.encryption.value,
    );
    final memberKeysWire = PublicKeyDuo(
      signingPublicKeyHex: creatorMemberKeys.signing.value,
      encryptionPublicKeyHex: creatorMemberKeys.encryption.value,
    );

    final groupEncryptedDataKey = await AsymmetricCrypto.wrapForRecipient(
      dataKeyJwk,
      groupUltimate.encryptionKeyPair.publicKey,
    );
    final creatorMemberEncryptedDataKey =
        await AsymmetricCrypto.wrapForRecipient(
      dataKeyJwk,
      creatorMember.encryptionKeyPair.publicKey,
    );

    // Inner attestation: group's ultimate key signs the inner payload.
    // Matches GroupInnerPayloads.createGroup on the server byte-for-byte.
    final innerPayload =
        'createGroup:${groupKeysWire.signingPublicKeyHex}'
        ':${groupKeysWire.encryptionPublicKeyHex}'
        ':${memberKeysWire.signingPublicKeyHex}'
        ':${memberKeysWire.encryptionPublicKeyHex}';
    final groupUltimateAttestation =
        await SigningCrypto.signChallenge(innerPayload, groupUltimate);

    // Outer envelope signed by the user's device key.
    final callerDeviceSigningPublicKeyHex =
        (await callerDeviceKey.signingKeyPair.exportPublicKeySec1Hex()).value;
    final challengeResp = await _caller.entrypoint.getChallenge();
    final envelope = await PowSigner.build(
      challenge: challengeResp.challenge,
      methodName: 'createGroup',
      signingKey: callerDeviceKey,
      publicKeyHex: callerDeviceSigningPublicKeyHex,
      difficulty: challengeResp.difficulty,
    );

    final share = await _caller.group.createGroup(
      challenge: envelope.challenge,
      proofOfWork: envelope.proofOfWork,
      signature: envelope.signature,
      callerDeviceSigningPublicKeyHex: envelope.publicKeyHex,
      groupUltimateKeys: groupKeysWire,
      groupEncryptedDataKey: groupEncryptedDataKey,
      creatorMemberKeys: memberKeysWire,
      creatorMemberEncryptedDataKey: creatorMemberEncryptedDataKey,
      groupUltimateAttestation: groupUltimateAttestation,
    );

    return CreatedGroup(
      groupId: share.id!.toString(),
      displayName: displayName,
      groupDataKey: dataKey,
      memberKey: creatorMember, // was discarded; now surfaced for persistence
      createdAt: share.createdAt,
    );
  }

  /// Lists all non-revoked group memberships for the calling device's account.
  Future<List<GroupMembership>> listMyGroups({
    required KeyDuo callerDeviceKey,
  }) async {
    final callerDeviceSigningPublicKeyHex =
        (await callerDeviceKey.signingKeyPair.exportPublicKeySec1Hex()).value;
    final challengeResp = await _caller.entrypoint.getChallenge();
    final envelope = await PowSigner.build(
      challenge: challengeResp.challenge,
      methodName: 'listMyGroups',
      signingKey: callerDeviceKey,
      publicKeyHex: callerDeviceSigningPublicKeyHex,
      difficulty: challengeResp.difficulty,
    );

    final rows = await _caller.group.listMyGroups(
      challenge: envelope.challenge,
      proofOfWork: envelope.proofOfWork,
      signature: envelope.signature,
      callerDeviceSigningPublicKeyHex: envelope.publicKeyHex,
    );

    return rows
        .map(
          (r) => GroupMembership(
            groupId: r.shareGroupId.toString(),
            memberId: r.memberId,
            role: r.role,
            memberSigningPublicKeyHex: r.memberSigningPublicKeyHex,
            memberEncryptedDataKey: r.memberEncryptedDataKey,
            deviceEncryptedDataKey: r.deviceEncryptedDataKey,
            joinedAt: r.joinedAt,
          ),
        )
        .toList();
  }

  /// Adds a new member to a group (admin-tier auth branch only).
  ///
  /// The caller must be an existing admin of the group. The caller signs
  /// the inner payload with their own member key ([callerMemberKey]).
  /// The new member's encrypted data key must be wrapped externally before
  /// passing it here.
  Future<GroupMember> addGroupMember({
    required UuidValue groupId,
    required UuidValue newMemberAccountId,
    required GroupMemberRole role,
    required String newMemberSigningPubkeyHex,
    required String newMemberEncryptionPublicKeyHex,
    required String newMemberEncryptedDataKey,
    required KeyDuo callerMemberKey,
    required KeyDuo callerDeviceKey,
  }) async {
    final callerMemberSigningPublicKeyHex =
        (await callerMemberKey.signingKeyPair.exportPublicKeySec1Hex()).value;
    final callerDeviceSigningPublicKeyHex =
        (await callerDeviceKey.signingKeyPair.exportPublicKeySec1Hex()).value;
    final memberKeysWire = PublicKeyDuo(
      signingPublicKeyHex: newMemberSigningPubkeyHex,
      encryptionPublicKeyHex: newMemberEncryptionPublicKeyHex,
    );

    // Inner payload — signed by the caller's member key. Matches
    // GroupInnerPayloads.addGroupMember on the server byte-for-byte.
    final innerPayload =
        'addGroupMember:$groupId:$newMemberAccountId:${role.name}'
        ':${memberKeysWire.signingPublicKeyHex}'
        ':${memberKeysWire.encryptionPublicKeyHex}';
    final memberAuthSignature =
        await SigningCrypto.signChallenge(innerPayload, callerMemberKey);

    // Outer envelope — signed by the caller's device key.
    final challengeResp = await _caller.entrypoint.getChallenge();
    final envelope = await PowSigner.build(
      challenge: challengeResp.challenge,
      methodName: 'addGroupMember',
      signingKey: callerDeviceKey,
      publicKeyHex: callerDeviceSigningPublicKeyHex,
      difficulty: challengeResp.difficulty,
    );

    return _caller.group.addGroupMember(
      challenge: envelope.challenge,
      proofOfWork: envelope.proofOfWork,
      signature: envelope.signature,
      callerDeviceSigningPublicKeyHex: envelope.publicKeyHex,
      groupId: groupId,
      newMemberAccountId: newMemberAccountId,
      role: role,
      memberKeys: memberKeysWire,
      encryptedDataKey: newMemberEncryptedDataKey,
      callerMemberSigningPublicKeyHex: callerMemberSigningPublicKeyHex,
      memberAuthSignature: memberAuthSignature,
      groupUltimateSignature: null,
    );
  }

  /// Removes (revokes) a group member (admin-tier auth branch only).
  ///
  /// The caller must be an admin. Signs the inner payload with their
  /// own member key ([callerMemberKey]).
  Future<bool> removeGroupMember({
    required UuidValue memberId,
    required KeyDuo callerMemberKey,
    required KeyDuo callerDeviceKey,
  }) async {
    final callerMemberSigningPublicKeyHex =
        (await callerMemberKey.signingKeyPair.exportPublicKeySec1Hex()).value;
    final callerDeviceSigningPublicKeyHex =
        (await callerDeviceKey.signingKeyPair.exportPublicKeySec1Hex()).value;

    // Inner payload — signed by the caller's member key.
    final innerPayload = 'removeGroupMember:$memberId';
    final memberAuthSignature =
        await SigningCrypto.signChallenge(innerPayload, callerMemberKey);

    // Outer envelope — signed by the caller's device key.
    final challengeResp = await _caller.entrypoint.getChallenge();
    final envelope = await PowSigner.build(
      challenge: challengeResp.challenge,
      methodName: 'removeGroupMember',
      signingKey: callerDeviceKey,
      publicKeyHex: callerDeviceSigningPublicKeyHex,
      difficulty: challengeResp.difficulty,
    );

    return _caller.group.removeGroupMember(
      challenge: envelope.challenge,
      proofOfWork: envelope.proofOfWork,
      signature: envelope.signature,
      callerDeviceSigningPublicKeyHex: envelope.publicKeyHex,
      memberId: memberId,
      callerMemberSigningPublicKeyHex: callerMemberSigningPublicKeyHex,
      memberAuthSignature: memberAuthSignature,
      groupUltimateSignature: null,
    );
  }

  /// Leaves a group — the caller removes themselves using their member key.
  Future<bool> leaveGroup({
    required UuidValue memberId,
    required KeyDuo callerMemberKey,
    required KeyDuo callerDeviceKey,
  }) async {
    final memberSigningPublicKeyHex =
        (await callerMemberKey.signingKeyPair.exportPublicKeySec1Hex()).value;
    final callerDeviceSigningPublicKeyHex =
        (await callerDeviceKey.signingKeyPair.exportPublicKeySec1Hex()).value;

    // Inner payload — signed by the caller's member key.
    final innerPayload = 'leaveGroup:$memberId';
    final memberAuthSignature =
        await SigningCrypto.signChallenge(innerPayload, callerMemberKey);

    // Outer envelope — signed by the caller's device key.
    final challengeResp = await _caller.entrypoint.getChallenge();
    final envelope = await PowSigner.build(
      challenge: challengeResp.challenge,
      methodName: 'leaveGroup',
      signingKey: callerDeviceKey,
      publicKeyHex: callerDeviceSigningPublicKeyHex,
      difficulty: challengeResp.difficulty,
    );

    return _caller.group.leaveGroup(
      challenge: envelope.challenge,
      proofOfWork: envelope.proofOfWork,
      signature: envelope.signature,
      callerDeviceSigningPublicKeyHex: envelope.publicKeyHex,
      memberId: memberId,
      memberSigningPublicKeyHex: memberSigningPublicKeyHex,
      memberAuthSignature: memberAuthSignature,
    );
  }

  /// Low-level forwarder: sends a batch of already-attested
  /// [MemberDeviceGrant]s to the server.
  ///
  /// Each grant's `attestation` must already be signed by the appropriate
  /// key (the membership's member key for `root` tier, or an already-
  /// granted device's key for `peer` tier) over
  /// `GroupInnerPayloads.grantMemberDevice(groupMemberId, deviceKeys,
  /// encryptedDataKey)` — this method does not build or alter attestations,
  /// since it never receives the per-membership member key. [grantAllDevices]
  /// and [grantNewDevice] are the callers that hold that key and do the
  /// signing before calling here.
  Future<GrantMemberDeviceResult> grantMemberDevice({
    required List<MemberDeviceGrant> grants,
    required KeyDuo callerDeviceKey,
  }) async {
    final callerDeviceSigningPublicKeyHex =
        (await callerDeviceKey.signingKeyPair.exportPublicKeySec1Hex()).value;

    final challengeResp = await _caller.entrypoint.getChallenge();
    final envelope = await PowSigner.build(
      challenge: challengeResp.challenge,
      methodName: GroupMethods.grantMemberDevice,
      signingKey: callerDeviceKey,
      publicKeyHex: callerDeviceSigningPublicKeyHex,
      difficulty: challengeResp.difficulty,
    );

    return _caller.group.grantMemberDevice(
      challenge: envelope.challenge,
      proofOfWork: envelope.proofOfWork,
      signature: envelope.signature,
      callerDeviceSigningPublicKeyHex: envelope.publicKeyHex,
      grants: grants,
    );
  }

  /// Join-time fan-out: wraps the group data key to every non-revoked
  /// device on the account, **including the caller itself** (the
  /// self-grant invariant — see spec §"The two grant moments"), and
  /// sends one batched `grantMemberDevice` call attested at `root`
  /// tier by [memberKey].
  ///
  /// `listDevices` does not filter revoked devices
  /// (`device_management_endpoint.dart:114-119`), so this method does.
  Future<GrantMemberDeviceResult> grantAllDevices({
    required UuidValue memberId,
    required AesGcmSecretKey groupDataKey,
    required KeyDuo memberKey,
    required KeyDuo callerDeviceKey,
  }) async {
    // 1. List every device on the account and filter out revoked.
    final callerDeviceSigningPublicKeyHex =
        (await callerDeviceKey.signingKeyPair.exportPublicKeySec1Hex()).value;
    final listChallenge = await _caller.entrypoint.getChallenge();
    final listEnvelope = await PowSigner.build(
      challenge: listChallenge.challenge,
      methodName: 'listDevices',
      signingKey: callerDeviceKey,
      publicKeyHex: callerDeviceSigningPublicKeyHex,
      difficulty: listChallenge.difficulty,
    );
    final devices = await _caller.deviceManagement.listDevices(
      challenge: listEnvelope.challenge,
      proofOfWork: listEnvelope.proofOfWork,
      publicKeyHex: listEnvelope.publicKeyHex,
      signature: listEnvelope.signature,
    );
    final liveDevices =
        devices.where((d) => !(d.isRevoked)).toList(growable: false);

    // 2. Build one MemberDeviceGrant per non-revoked device. The caller
    //    device is included unconditionally — every AccountDevice row
    //    returned by listDevices counts as "non-revoked" if its
    //    `isRevoked` is false, and the caller's own row meets that
    //    bar. This is the self-grant invariant.
    final memberSigningPublicKeyHex =
        (await memberKey.signingKeyPair.exportPublicKeySec1Hex()).value;
    final dataKeyJwk = jsonEncode(await groupDataKey.exportJsonWebKey());
    final grants = <MemberDeviceGrant>[];
    for (final device in liveDevices) {
      final deviceId = device.id;
      if (deviceId == null) {
        // listDevices always returns persisted rows, but a defensive
        // skip costs nothing and keeps the batch FK-shaped.
        continue;
      }
      final encryptionPubkey = await EncryptionKeyPair.importPublicKeySec1Hex(
        EncryptionPublicKeyHex(device.deviceEncryptionPublicKeyHex),
      );
      final wrappedBlob = await AsymmetricCrypto.wrapForRecipient(
        dataKeyJwk,
        encryptionPubkey.publicKey,
      );
      final deviceDuo = PublicKeyDuo(
        signingPublicKeyHex: device.deviceSigningPublicKeyHex,
        encryptionPublicKeyHex: device.deviceEncryptionPublicKeyHex,
      );
      final attestation = await SigningCrypto.signChallenge(
        GroupInnerPayloads.grantMemberDevice(
          memberId,
          deviceDuo,
          wrappedBlob,
        ),
        memberKey,
      );
      grants.add(
        MemberDeviceGrant(
          groupMemberId: memberId,
          accountDeviceId: deviceId,
          encryptedDataKey: wrappedBlob,
          attestorSigningPublicKeyHex: memberSigningPublicKeyHex,
          tier: GrantTier.root,
          attestation: attestation,
        ),
      );
    }

    // 3. Forward the batch.
    return grantMemberDevice(
      grants: grants,
      callerDeviceKey: callerDeviceKey,
    );
  }

  /// Pair-time fan-out: grant one [newDevice] access to every
  /// membership the caller holds.
  ///
  /// For each membership, the tier is per item: `root` when the caller
  /// holds that membership's member key (look it up in [memberKeys] by
  /// the membership's id), and `peer` when the caller only holds a
  /// device-level grant (i.e., no member key). The `peer` attestation
  /// is signed by [callerDeviceKey] — the only key the caller has
  /// standing in for that membership.
  ///
  /// The data key for each membership is taken from the membership's
  /// `deviceEncryptedDataKey` (the caller device's own grant row) and
  /// re-wrapped to the new device's encryption key. The caller MUST
  /// therefore have a grant on every membership in [memberships];
  /// passing a membership it has not been granted on is a programmer
  /// error and surfaces as an [ArgumentError] before any wire call.
  Future<GrantMemberDeviceResult> grantNewDevice({
    required wire.AccountDevice newDevice,
    required List<wire.GroupMembershipView> memberships,
    required Map<UuidValue, KeyDuo> memberKeys,
    required KeyDuo callerDeviceKey,
  }) async {
    if (newDevice.id == null) {
      throw ArgumentError(
        'grantNewDevice: newDevice must have an id; received a row '
        'with id == null (likely the wire stub for a not-yet-inserted '
        'device).',
      );
    }
    final newDeviceSigningHex =
        (await (await _newDeviceSigningKeyPair(newDevice))
                .exportPublicKeySec1Hex())
            .value;
    final newDeviceEncryptionPubkey =
        await EncryptionKeyPair.importPublicKeySec1Hex(
      EncryptionPublicKeyHex(newDevice.deviceEncryptionPublicKeyHex),
    );
    final newDeviceDuo = PublicKeyDuo(
      signingPublicKeyHex: newDeviceSigningHex,
      encryptionPublicKeyHex: newDevice.deviceEncryptionPublicKeyHex,
    );
    final callerDeviceSigningPublicKeyHex =
        (await callerDeviceKey.signingKeyPair.exportPublicKeySec1Hex()).value;

    final grants = <MemberDeviceGrant>[];
    for (final m in memberships) {
      final callerBlob = m.deviceEncryptedDataKey;
      if (callerBlob == null) {
        throw ArgumentError(
          'grantNewDevice: membership ${m.memberId} has no '
          'deviceEncryptedDataKey for the caller — the caller has not '
          'been granted on this membership and cannot extend access to '
          'a new device from it.',
        );
      }
      // Re-wrap the caller's grant blob to the new device's encryption
      // key. We unwrap with the caller's *device* private key, then
      // wrap to the new device's encryption pubkey.
      final callerDevicePrivate =
          callerDeviceKey.encryptionKeyPair.privateKey;
      if (callerDevicePrivate == null) {
        throw ArgumentError(
          'grantNewDevice: caller device key has no private encryption '
          'half; cannot unwrap the per-device grant blob to re-wrap it.',
        );
      }
      final dataKeyJwk =
          await AsymmetricCrypto.unwrap(callerBlob, callerDevicePrivate);
      final newWrapped =
          await AsymmetricCrypto.wrapForRecipient(
        dataKeyJwk,
        newDeviceEncryptionPubkey.publicKey,
      );

      final memberKey = memberKeys[m.memberId];
      final GrantTier tier;
      final KeyDuo attestor;
      if (memberKey != null) {
        tier = GrantTier.root;
        attestor = memberKey;
      } else {
        tier = GrantTier.peer;
        attestor = callerDeviceKey;
      }
      final attestorSigningPublicKeyHex =
          (await attestor.signingKeyPair.exportPublicKeySec1Hex()).value;
      final attestation = await SigningCrypto.signChallenge(
        GroupInnerPayloads.grantMemberDevice(
          m.memberId,
          newDeviceDuo,
          newWrapped,
        ),
        attestor,
      );
      grants.add(
        MemberDeviceGrant(
          groupMemberId: m.memberId,
          accountDeviceId: newDevice.id!,
          encryptedDataKey: newWrapped,
          attestorSigningPublicKeyHex: attestorSigningPublicKeyHex,
          tier: tier,
          attestation: attestation,
        ),
      );
    }

    return grantMemberDevice(
      grants: grants,
      callerDeviceKey: callerDeviceKey,
    );
  }

  // Internal helper: re-derives the new device's ECDSA signing pubkey
  // from its SEC1 hex. The wire type only carries the hex, but we
  // need an EcdsaPublicKey object to pass to
  // `SigningKeyPair.exportPublicKeySec1Hex` so that the value comes
  // back with the typed wrapper.
  static Future<SigningKeyPair> _newDeviceSigningKeyPair(
    wire.AccountDevice newDevice,
  ) =>
      SigningKeyPair.importPublicKeySec1Hex(
        SigningPublicKeyHex(newDevice.deviceSigningPublicKeyHex),
      );
}
