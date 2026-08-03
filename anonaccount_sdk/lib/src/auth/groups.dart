import 'dart:convert';

// ignore: implementation_imports
import 'package:anonaccount_client/anonaccount_client.dart' as wire;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/client.dart' show Caller;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/grant_member_device_result.dart'
    show GrantMemberDeviceResult;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/grant_attestor.dart'
    show GrantAttestor;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/group_member.dart'
    show GroupMember;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/group_member_role.dart'
    show GroupMemberRole;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/member_device_grant.dart'
    show MemberDeviceGrant;
import 'package:anonaccount_protocol/anonaccount_protocol.dart'
    show GroupMethods, GroupInnerPayloads, PublicKeyDuo;
import 'package:anonaccount_client/anonaccount_client.dart' show UuidValue;
import 'package:dart_jwk_duo/dart_jwk_duo.dart'
    show
        EncryptionKeyPair,
        EncryptionPublicKeyHex,
        KeyDuo,
        KeyDuoSerializer,
        SigningKeyPair,
        SigningPublicKeyHex;
import 'package:webcrypto/webcrypto.dart';

import '../crypto/asymmetric.dart';
import '../crypto/key_gen.dart';
import '../crypto/signing.dart';
import '../models/created_group.dart';
import '../models/group_membership.dart';
import 'member_key_store.dart';
import 'group_owner_key_store.dart';
import 'pow_signer.dart';

/// High-level group lifecycle wrapper.
///
/// Holds no key material: [_memberKeys] is a handle to the consumer's store,
/// and the device key is still passed per call. The consumer owns every
/// private key this class touches.
class AnonaccountGroups {
  AnonaccountGroups(
    this._caller,
    this._memberKeys,
    this._ownerKeys, {
    this.difficulty = PowSigner.defaultDifficulty,
  });

  final Caller _caller;
  final MemberKeyStore _memberKeys;
  final GroupOwnerKeyStore _ownerKeys;
  // ignore: unused_field
  final int difficulty;

  /// Reads the member key an operation requires, or throws.
  ///
  /// [StateError] rather than [ArgumentError] because an absent key is not
  /// caller-supplied bad input: the ArgumentErrors elsewhere in this class
  /// mark arguments that are wrong, and this marks a precondition that is
  /// missing.
  Future<KeyDuo> _requireMemberKey(UuidValue groupId, String operation) async {
    final key = await _memberKeys.getMemberKey(groupId);
    if (key == null) {
      throw StateError(
        '$operation: no member key stored for group $groupId. The member key '
        'for a group is written to the MemberKeyStore at createGroup and must '
        'be restored there after a reinstall before group operations can be '
        'signed.',
      );
    }
    return key;
  }

  Future<KeyDuo> _requireOwnerKey(UuidValue groupId, String operation) async {
    final key = await _ownerKeys.getOwnerKey(groupId);
    if (key == null) {
      throw StateError(
        '$operation: no owner key stored for group $groupId. Restore it '
        'with recoverAccount before owner-tier operations.',
      );
    }
    return key;
  }

  /// Creates a new group. Generates a fresh group ultimate KeyDuo, a
  /// fresh creator-member KeyDuo, and a fresh AES-GCM data key locally.
  /// Wraps the data key to both keypairs and posts to the server.
  Future<CreatedGroup> createGroup({
    required String displayName,
    required KeyDuo callerDeviceKey,
    required UuidValue myAnonAccountId,
    required String ultimateEncryptionPublicKeyHex,
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
    final innerPayload = GroupInnerPayloads.createGroup(
      groupKeysWire,
      memberKeysWire,
    );
    final groupUltimateAttestation = await SigningCrypto.signChallenge(
      innerPayload,
      groupUltimate,
    );

    // The member key pair itself, encrypted with the account's ultimate
    // encryption public key. Only the user's written-down backup can
    // decrypt it — not this device, not the server, not the data keys.
    final creatorMemberKeyJwk = await const KeyDuoSerializer().exportKeyDuoJwk(
      creatorMember,
    );
    final ultimateEncryptionKeyPair =
        await EncryptionKeyPair.importPublicKeySec1Hex(
          EncryptionPublicKeyHex(ultimateEncryptionPublicKeyHex),
        );
    final creatorEncryptedMemberKey = await AsymmetricCrypto.wrapForRecipient(
      creatorMemberKeyJwk,
      ultimateEncryptionKeyPair.publicKey,
    );
    final creatorEncryptedMemberKeyAttestation =
        await SigningCrypto.signChallenge(
          GroupInnerPayloads.setEncryptedMemberKey(
            groupKeysWire.signingPublicKeyHex,
            myAnonAccountId,
            memberKeysWire.signingPublicKeyHex,
            creatorEncryptedMemberKey,
          ),
          creatorMember,
        );

    final groupUltimateKeyJwk = await const KeyDuoSerializer().exportKeyDuoJwk(
      groupUltimate,
    );
    final creatorEncryptedUltimateKey = await AsymmetricCrypto.wrapForRecipient(
      groupUltimateKeyJwk,
      ultimateEncryptionKeyPair.publicKey,
    );
    final creatorEncryptedUltimateKeyAttestation =
        await SigningCrypto.signChallenge(
          GroupInnerPayloads.setEncryptedUltimateKey(
            groupKeysWire.signingPublicKeyHex,
            myAnonAccountId,
            creatorEncryptedUltimateKey,
          ),
          groupUltimate,
        );

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
      creatorEncryptedMemberKey: creatorEncryptedMemberKey,
      creatorEncryptedMemberKeyAttestation:
          creatorEncryptedMemberKeyAttestation,
      creatorEncryptedUltimateKey: creatorEncryptedUltimateKey,
      creatorEncryptedUltimateKeyAttestation:
          creatorEncryptedUltimateKeyAttestation,
    );

    await _memberKeys.storeMemberKey(share.id!, creatorMember);
    await _ownerKeys.storeOwnerKey(share.id!, groupUltimate);

    return CreatedGroup(
      groupId: share.id!.toString(),
      displayName: displayName,
      groupDataKey: dataKey,
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
            encryptedMemberKey: r.encryptedMemberKey,
            encryptedUltimateKey: r.encryptedUltimateKey,
          ),
        )
        .toList();
  }

  /// Adds a new member to a group (admin-tier auth branch only).
  ///
  /// The caller must be an existing admin of the group. The caller signs the
  /// inner payload with the member key its store holds for [groupId]. The new
  /// member's encrypted data key must be wrapped externally before passing it
  /// here.
  ///
  /// [encryptedMemberKey] and [encryptedMemberKeyAttestation] are the
  /// invitee's own member-key backup, produced and signed by the invitee
  /// before this call — this method only relays them. The admin's SDK
  /// cannot construct these: it holds neither the invitee's member private
  /// key nor their account's ultimate public key.
  Future<GroupMember> addGroupMember({
    required UuidValue groupId,
    required UuidValue newMemberAccountId,
    required GroupMemberRole role,
    required String newMemberSigningPubkeyHex,
    required String newMemberEncryptionPublicKeyHex,
    required String newMemberEncryptedDataKey,
    required KeyDuo callerDeviceKey,
    required String encryptedMemberKey,
    required String encryptedMemberKeyAttestation,
  }) async {
    final memberKey = await _requireMemberKey(groupId, 'addGroupMember');
    final callerMemberSigningPublicKeyHex =
        (await memberKey.signingKeyPair.exportPublicKeySec1Hex()).value;
    final callerDeviceSigningPublicKeyHex =
        (await callerDeviceKey.signingKeyPair.exportPublicKeySec1Hex()).value;
    final memberKeysWire = PublicKeyDuo(
      signingPublicKeyHex: newMemberSigningPubkeyHex,
      encryptionPublicKeyHex: newMemberEncryptionPublicKeyHex,
    );

    // Inner payload — signed by the caller's member key.
    final innerPayload = GroupInnerPayloads.addGroupMember(
      groupId,
      newMemberAccountId,
      role.name,
      memberKeysWire,
    );
    final memberAuthSignature = await SigningCrypto.signChallenge(
      innerPayload,
      memberKey,
    );

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
      encryptedMemberKey: encryptedMemberKey,
      encryptedMemberKeyAttestation: encryptedMemberKeyAttestation,
    );
  }

  /// Removes (revokes) a group member (admin-tier auth branch only).
  ///
  /// The caller must be an admin. Signs the inner payload with the member key
  /// its store holds for [groupId].
  Future<bool> removeGroupMember({
    required UuidValue groupId,
    required UuidValue memberId,
    required KeyDuo callerDeviceKey,
  }) async {
    final memberKey = await _requireMemberKey(groupId, 'removeGroupMember');
    final callerMemberSigningPublicKeyHex =
        (await memberKey.signingKeyPair.exportPublicKeySec1Hex()).value;
    final callerDeviceSigningPublicKeyHex =
        (await callerDeviceKey.signingKeyPair.exportPublicKeySec1Hex()).value;

    // Inner payload — signed by the caller's member key.
    final innerPayload = GroupInnerPayloads.removeGroupMember(memberId);
    final memberAuthSignature = await SigningCrypto.signChallenge(
      innerPayload,
      memberKey,
    );

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

  Future<GroupMember> addGroupMemberAsOwner({
    required UuidValue groupId,
    required UuidValue newMemberAccountId,
    required String newMemberSigningPubkeyHex,
    required String newMemberEncryptionPublicKeyHex,
    required String newMemberEncryptedDataKey,
    required KeyDuo callerDeviceKey,
    required String encryptedMemberKey,
    required String encryptedMemberKeyAttestation,
  }) async {
    final ownerKey = await _requireOwnerKey(groupId, 'addGroupMemberAsOwner');
    final callerDeviceSigningPublicKeyHex =
        (await callerDeviceKey.signingKeyPair.exportPublicKeySec1Hex()).value;
    final memberKeysWire = PublicKeyDuo(
      signingPublicKeyHex: newMemberSigningPubkeyHex,
      encryptionPublicKeyHex: newMemberEncryptionPublicKeyHex,
    );
    final innerPayload = GroupInnerPayloads.addGroupMember(
      groupId,
      newMemberAccountId,
      GroupMemberRole.admin.name,
      memberKeysWire,
    );
    final groupUltimateSignature = await SigningCrypto.signChallenge(
      innerPayload,
      ownerKey,
    );
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
      role: GroupMemberRole.admin,
      memberKeys: memberKeysWire,
      encryptedDataKey: newMemberEncryptedDataKey,
      encryptedMemberKey: encryptedMemberKey,
      encryptedMemberKeyAttestation: encryptedMemberKeyAttestation,
      callerMemberSigningPublicKeyHex: null,
      memberAuthSignature: null,
      groupUltimateSignature: groupUltimateSignature,
    );
  }

  Future<bool> removeGroupMemberAsOwner({
    required UuidValue groupId,
    required UuidValue memberId,
    required KeyDuo callerDeviceKey,
  }) async {
    final ownerKey = await _requireOwnerKey(
      groupId,
      'removeGroupMemberAsOwner',
    );
    final callerDeviceSigningPublicKeyHex =
        (await callerDeviceKey.signingKeyPair.exportPublicKeySec1Hex()).value;
    final groupUltimateSignature = await SigningCrypto.signChallenge(
      GroupInnerPayloads.removeGroupMember(memberId),
      ownerKey,
    );
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
      callerMemberSigningPublicKeyHex: null,
      memberAuthSignature: null,
      groupUltimateSignature: groupUltimateSignature,
    );
  }

  /// Leaves a group — the caller removes themselves using their member key.
  Future<bool> leaveGroup({
    required UuidValue groupId,
    required UuidValue memberId,
    required KeyDuo callerDeviceKey,
  }) async {
    final memberKey = await _requireMemberKey(groupId, 'leaveGroup');
    final memberSigningPublicKeyHex =
        (await memberKey.signingKeyPair.exportPublicKeySec1Hex()).value;
    final callerDeviceSigningPublicKeyHex =
        (await callerDeviceKey.signingKeyPair.exportPublicKeySec1Hex()).value;

    // Inner payload — signed by the caller's member key.
    final innerPayload = GroupInnerPayloads.leaveGroup(memberId);
    final memberAuthSignature = await SigningCrypto.signChallenge(
      innerPayload,
      memberKey,
    );

    // Outer envelope — signed by the caller's device key.
    final challengeResp = await _caller.entrypoint.getChallenge();
    final envelope = await PowSigner.build(
      challenge: challengeResp.challenge,
      methodName: 'leaveGroup',
      signingKey: callerDeviceKey,
      publicKeyHex: callerDeviceSigningPublicKeyHex,
      difficulty: challengeResp.difficulty,
    );

    final left = await _caller.group.leaveGroup(
      challenge: envelope.challenge,
      proofOfWork: envelope.proofOfWork,
      signature: envelope.signature,
      callerDeviceSigningPublicKeyHex: envelope.publicKeyHex,
      memberId: memberId,
      memberSigningPublicKeyHex: memberSigningPublicKeyHex,
      memberAuthSignature: memberAuthSignature,
    );
    // A throw from the wire call skips this, leaving custody intact.
    await _memberKeys.removeMemberKey(groupId);
    return left;
  }

  /// Low-level forwarder: sends a batch of already-attested
  /// [MemberDeviceGrant]s to the server.
  ///
  /// Each grant's `attestation` must already be signed by the appropriate
  /// key (the membership's member key, or an already-granted device's
  /// key) over
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
  /// sends one batched `grantMemberDevice` call attested by the member key
  /// the caller's store holds for [groupId].
  ///
  /// `listDevices` does not filter revoked devices, so this method does.
  Future<GrantMemberDeviceResult> grantAllDevices({
    required UuidValue groupId,
    required UuidValue memberId,
    required AesGcmSecretKey groupDataKey,
    required KeyDuo callerDeviceKey,
  }) async {
    final memberKey = await _requireMemberKey(groupId, 'grantAllDevices');

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
    final liveDevices = devices
        .where((d) => !(d.isRevoked))
        .toList(growable: false);

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
        GroupInnerPayloads.grantMemberDevice(memberId, deviceDuo, wrappedBlob),
        memberKey,
      );
      grants.add(
        MemberDeviceGrant(
          groupMemberId: memberId,
          accountDeviceId: deviceId,
          encryptedDataKey: wrappedBlob,
          attestorSigningPublicKeyHex: memberSigningPublicKeyHex,
          attestor: GrantAttestor.memberKey,
          attestation: attestation,
        ),
      );
    }

    // 3. Forward the batch.
    return grantMemberDevice(grants: grants, callerDeviceKey: callerDeviceKey);
  }

  /// Pair-time fan-out: grant one [newDevice] access to every
  /// membership the caller holds.
  ///
  /// For each membership, the attestor is per item: `memberKey` when the
  /// caller's store holds that group's member key, and `grantedDevice` when it
  /// does not — an account reaching a membership through a device grant rather
  /// than by being the member holds no member key for it. That attestation is
  /// signed by [callerDeviceKey], the only key the caller has standing in for
  /// that membership.
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
    required KeyDuo callerDeviceKey,
  }) async {
    if (newDevice.id == null) {
      throw ArgumentError(
        'grantNewDevice: newDevice must have an id; received a row '
        'with id == null (likely the wire stub for a not-yet-inserted '
        'device).',
      );
    }
    final newDeviceSigningHex = (await (await _newDeviceSigningKeyPair(
      newDevice,
    )).exportPublicKeySec1Hex()).value;
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
      final callerDevicePrivate = callerDeviceKey.encryptionKeyPair.privateKey;
      if (callerDevicePrivate == null) {
        throw ArgumentError(
          'grantNewDevice: caller device key has no private encryption '
          'half; cannot unwrap the per-device grant blob to re-wrap it.',
        );
      }
      final dataKeyJwk = await AsymmetricCrypto.unwrap(
        callerBlob,
        callerDevicePrivate,
      );
      final newWrapped = await AsymmetricCrypto.wrapForRecipient(
        dataKeyJwk,
        newDeviceEncryptionPubkey.publicKey,
      );

      final stored = await _memberKeys.getMemberKey(m.shareGroupId);
      final GrantAttestor attestor;
      final KeyDuo attestorKey;
      if (stored != null) {
        // Compared with != rather than case-insensitively: both sides come
        // from exportPublicKeySec1Hex, so a casing difference would mean two
        // different encoders produced them — a defect worth surfacing.
        final storedHex =
            (await stored.signingKeyPair.exportPublicKeySec1Hex()).value;
        if (storedHex != m.memberSigningPublicKeyHex) {
          throw StateError(
            'grantNewDevice: the member key stored for group ${m.shareGroupId} '
            'is stale — its signing public key does not match membership '
            '${m.memberId}. Rejoining a group mints a fresh member key under '
            'the same group id; store the new one to replace it.',
          );
        }
        attestor = GrantAttestor.memberKey;
        attestorKey = stored;
      } else {
        attestor = GrantAttestor.grantedDevice;
        attestorKey = callerDeviceKey;
      }
      final attestorSigningPublicKeyHex =
          (await attestorKey.signingKeyPair.exportPublicKeySec1Hex()).value;
      final attestation = await SigningCrypto.signChallenge(
        GroupInnerPayloads.grantMemberDevice(
          m.memberId,
          newDeviceDuo,
          newWrapped,
        ),
        attestorKey,
      );
      grants.add(
        MemberDeviceGrant(
          groupMemberId: m.memberId,
          accountDeviceId: newDevice.id!,
          encryptedDataKey: newWrapped,
          attestorSigningPublicKeyHex: attestorSigningPublicKeyHex,
          attestor: attestor,
          attestation: attestation,
        ),
      );
    }

    return grantMemberDevice(grants: grants, callerDeviceKey: callerDeviceKey);
  }

  // Internal helper: re-derives the new device's ECDSA signing pubkey
  // from its SEC1 hex. The wire type only carries the hex, but we
  // need an EcdsaPublicKey object to pass to
  // `SigningKeyPair.exportPublicKeySec1Hex` so that the value comes
  // back with the typed wrapper.
  static Future<SigningKeyPair> _newDeviceSigningKeyPair(
    wire.AccountDevice newDevice,
  ) => SigningKeyPair.importPublicKeySec1Hex(
    SigningPublicKeyHex(newDevice.deviceSigningPublicKeyHex),
  );
}
