import 'dart:convert';

// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/client.dart' show Caller;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/group_member.dart'
    show GroupMember;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/group_member_role.dart'
    show GroupMemberRole;
import 'package:anonaccount_client/anonaccount_client.dart' show UuidValue;
import 'package:dart_jwk_duo/dart_jwk_duo.dart' show KeyDuo;
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

    final groupUltimateSigningPublicKeyHex =
        await groupUltimate.signingKeyPair.exportPublicKeyHex();
    final groupUltimatePublicKey = jsonEncode(
      await groupUltimate.encryptionKeyPair.publicKey.exportJsonWebKey(),
    );
    final creatorMemberSigningPublicKeyHex =
        await creatorMember.signingKeyPair.exportPublicKeyHex();
    final creatorMemberPublicKey = jsonEncode(
      await creatorMember.encryptionKeyPair.publicKey.exportJsonWebKey(),
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
    final innerPayload =
        'createGroup:$groupUltimateSigningPublicKeyHex:$groupUltimatePublicKey'
        ':$creatorMemberSigningPublicKeyHex:$creatorMemberPublicKey';
    final groupUltimateAttestation =
        await SigningCrypto.signChallenge(innerPayload, groupUltimate);

    // Outer envelope signed by the user's device key.
    final callerDeviceSigningPublicKeyHex =
        await callerDeviceKey.signingKeyPair.exportPublicKeyHex();
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
      groupUltimateSigningPublicKeyHex: groupUltimateSigningPublicKeyHex,
      groupUltimatePublicKey: groupUltimatePublicKey,
      groupEncryptedDataKey: groupEncryptedDataKey,
      creatorMemberSigningPublicKeyHex: creatorMemberSigningPublicKeyHex,
      creatorMemberPublicKey: creatorMemberPublicKey,
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
        await callerDeviceKey.signingKeyPair.exportPublicKeyHex();
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
            role: r.role,
            encryptedDataKey: r.encryptedDataKey,
            joinedAt: r.joinedAt,
            isRevoked: r.isRevoked,
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
    required String newMemberPublicKeyJwk,
    required String newMemberEncryptedDataKey,
    required KeyDuo callerMemberKey,
    required KeyDuo callerDeviceKey,
  }) async {
    final callerMemberSigningPublicKeyHex =
        await callerMemberKey.signingKeyPair.exportPublicKeyHex();
    final callerDeviceSigningPublicKeyHex =
        await callerDeviceKey.signingKeyPair.exportPublicKeyHex();

    // Inner payload — signed by the caller's member key.
    final innerPayload =
        'addGroupMember:$groupId:$newMemberAccountId:${role.name}'
        ':$newMemberSigningPubkeyHex:$newMemberPublicKeyJwk';
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
      memberSigningPublicKeyHex: newMemberSigningPubkeyHex,
      memberPublicKey: newMemberPublicKeyJwk,
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
        await callerMemberKey.signingKeyPair.exportPublicKeyHex();
    final callerDeviceSigningPublicKeyHex =
        await callerDeviceKey.signingKeyPair.exportPublicKeyHex();

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
        await callerMemberKey.signingKeyPair.exportPublicKeyHex();
    final callerDeviceSigningPublicKeyHex =
        await callerDeviceKey.signingKeyPair.exportPublicKeyHex();

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
}
