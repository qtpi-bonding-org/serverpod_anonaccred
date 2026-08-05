import 'dart:convert';

import 'package:anonaccount_protocol/anonaccount_protocol.dart'
    show GroupInnerPayloads;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/grant_member_device_result.dart'
    show GrantMemberDeviceResult;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/group_member_view.dart'
    show GroupMemberView;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:dart_jwk_duo/dart_jwk_duo.dart'
    show EncryptionKeyPair, EncryptionPublicKeyHex, KeyDuoSerializer;

import 'sdk_test_caller.dart';
import 'serverpod_test_tools.dart';

/// A complete fake identity backed by the real SDK key stores and crypto.
class SimulatedUser {
  SimulatedUser(
    TestSessionBuilder sessionBuilder,
    TestEndpoints endpoints, {
    required this.label,
  }) : caller = SdkTestCaller(sessionBuilder, endpoints) {
    auth = AnonaccountAuth(caller, _store, memberKeys, ownerKeys);
    groups = AnonaccountGroups(caller, memberKeys, ownerKeys);
    pairing = AnonaccountPairing(caller, _store);
  }

  final String label;
  final SdkTestCaller caller;
  final InMemoryAccountKeyStore _store = InMemoryAccountKeyStore();
  final InMemoryMemberKeyStore memberKeys = InMemoryMemberKeyStore();
  final InMemoryGroupOwnerKeyStore ownerKeys = InMemoryGroupOwnerKeyStore();
  final _groupDataKeys = <String, AesGcmSecretKey>{};

  late final AnonaccountAuth auth;
  late final AnonaccountGroups groups;
  late final AnonaccountPairing pairing;

  UuidValue? accountId;
  String? ultimateBackupJwk;

  Future<void> onboard() async {
    final result = await auth.createAccount(
      deviceLabel: '$label-primary',
      createdAt: DateTime.utc(2026, 8, 3),
    );
    await auth.registerAccount(result.payload, deviceLabel: '$label-primary');
    ultimateBackupJwk = await _store.getUltimateKeyJwkOnce();
    accountId = (await listDevices()).single.anonAccountId;
  }

  Future<KeyDuo> get deviceKey async => (await _store.getDeviceKey())!;

  Future<String> deviceKeyHex() async =>
      (await _store.getDeviceSigningPublicKeyHex())!;

  Future<List<AccountDevice>> listDevices() async {
    final key = await deviceKey;
    final hex = await deviceKeyHex();
    final envelope = await caller.buildEnvelope(
      methodName: 'listDevices',
      signingKey: key,
      publicKeyHex: hex,
    );
    return caller.deviceManagement.listDevices(
      challenge: envelope.challenge,
      proofOfWork: envelope.proofOfWork,
      publicKeyHex: hex,
      signature: envelope.signature,
    );
  }

  Future<UuidValue> primaryDeviceId() async {
    final hex = await deviceKeyHex();
    return (await listDevices())
        .singleWhere((d) => d.deviceSigningPublicKeyHex == hex)
        .id!;
  }

  // registerPairedDevice runs to completion before monitorRegistration is
  // called at all — both are server calls sharing the single test-harness
  // transaction (see TestDatabaseProxy), which only tolerates one call's DB
  // work in flight at a time. Racing them (starting the monitor call and
  // awaiting registration concurrently, as real clients do over separate
  // connections) intermittently throws ConcurrentTransactionsException here.
  // Calling registration first means monitorRegistration's own DB lookup
  // always finds the now-existing device and returns immediately via its
  // no-wait replay path, so nothing here ever touches the live stream.
  Future<UuidValue> addDeviceViaPairing({required String label}) async {
    final sideBStore = InMemoryAccountKeyStore();
    final sideBPairing = AnonaccountPairing(caller, sideBStore);
    final qr = await sideBPairing.beginPairing(deviceLabel: label);
    final registered = await pairing.registerPairedDevice(
      scanned: pairing.parseQr(qr.qrPayloadJson),
      label: label,
    );
    final event = await sideBPairing
        .monitorRegistration(qr.signingPubkeyHex)
        .first;
    await sideBPairing.completePairing(wrappedKey: event.encryptedDataKey);
    return registered.id!;
  }

  Future<bool> revokeDevice(UuidValue deviceId) => auth.revokeDevice(
    deviceId: deviceId,
    ultimateBackupJwk: ultimateBackupJwk!,
  );

  Future<String> createGroup(String displayName) async {
    final created = await groups.createGroup(
      displayName: displayName,
      callerDeviceKey: await deviceKey,
      myAnonAccountId: accountId!,
      ultimateEncryptionPublicKeyHex: (await _store
          .getUltimateEncryptionPublicKeyHex())!,
    );
    _groupDataKeys[created.groupId] = created.groupDataKey;
    return created.groupId;
  }

  Future<List<GroupMembership>> listMyGroups() async =>
      groups.listMyGroups(callerDeviceKey: await deviceKey);

  Future<AesGcmSecretKey> groupDataKeyFor(String groupId) async {
    final cached = _groupDataKeys[groupId];
    if (cached != null) return cached;
    final membership = (await listMyGroups()).singleWhere(
      (row) => row.groupId == groupId,
    );
    final memberKey = (await memberKeys.getMemberKey(
      UuidValue.fromString(groupId),
    ))!;
    final jwk = await AsymmetricCrypto.unwrap(
      membership.memberEncryptedDataKey,
      memberKey.encryptionKeyPair.privateKey!,
    );
    final key = await AesGcmSecretKey.importJsonWebKey(
      jsonDecode(jwk) as Map<String, dynamic>,
    );
    _groupDataKeys[groupId] = key;
    return key;
  }

  Future<ShareGroup> getGroup(String groupId) async {
    final member = (await memberKeys.getMemberKey(
      UuidValue.fromString(groupId),
    ))!;
    final memberHex = await member.signingKeyPair.exportPublicKeySec1Hex();
    final signature = await SigningCrypto.signChallenge(
      GroupInnerPayloads.getGroup(UuidValue.fromString(groupId)),
      member,
    );
    final deviceHex = await deviceKeyHex();
    final envelope = await caller.buildEnvelope(
      methodName: 'getGroup',
      signingKey: await deviceKey,
      publicKeyHex: deviceHex,
    );
    return caller.endpointGetGroupRaw(
      groupId: groupId,
      envelope: envelope,
      callerDeviceSigningPublicKeyHex: deviceHex,
      callerMemberSigningPublicKeyHex: memberHex.value,
      memberAuthSignature: signature,
    );
  }

  Future<String> memberSigningKeyHex(String groupId) async {
    final member = (await memberKeys.getMemberKey(
      UuidValue.fromString(groupId),
    ))!;
    return (await member.signingKeyPair.exportPublicKeySec1Hex()).value;
  }

  Future<String> signGroupInnerPayload(String groupId) async {
    final member = (await memberKeys.getMemberKey(
      UuidValue.fromString(groupId),
    ))!;
    return SigningCrypto.signChallenge(
      GroupInnerPayloads.monitorGroupMembership(UuidValue.fromString(groupId)),
      member,
    );
  }

  Future<List<GroupMemberView>> listGroupMembers(String groupId) async {
    final member = (await memberKeys.getMemberKey(
      UuidValue.fromString(groupId),
    ))!;
    final memberHex =
        (await member.signingKeyPair.exportPublicKeySec1Hex()).value;
    final signature = await SigningCrypto.signChallenge(
      GroupInnerPayloads.listGroupMembers(UuidValue.fromString(groupId)),
      member,
    );
    final deviceHex = await deviceKeyHex();
    final envelope = await caller.buildEnvelope(
      methodName: 'listGroupMembers',
      signingKey: await deviceKey,
      publicKeyHex: deviceHex,
    );
    return caller.endpointListGroupMembersRaw(
      groupId: groupId,
      envelope: envelope,
      callerDeviceSigningPublicKeyHex: deviceHex,
      callerMemberSigningPublicKeyHex: memberHex,
      memberAuthSignature: signature,
    );
  }

  Future<
    ({
      String signingPubkeyHex,
      String encryptionPubkeyHex,
      String encryptedMemberKey,
      String encryptedMemberKeyAttestation,
    })
  >
  _prepareJoin(String groupId, String groupUltimateSigningPublicKeyHex) async {
    final member = await KeyGen.generateDeviceKey();
    await memberKeys.storeMemberKey(UuidValue.fromString(groupId), member);
    final publicDuo = await member.exportPublicKeyDuo();
    final ultimate = await EncryptionKeyPair.importPublicKeySec1Hex(
      EncryptionPublicKeyHex(
        (await _store.getUltimateEncryptionPublicKeyHex())!,
      ),
    );
    final encrypted = await AsymmetricCrypto.wrapForRecipient(
      await const KeyDuoSerializer().exportKeyDuoJwk(member),
      ultimate.publicKey,
    );
    final attestation = await SigningCrypto.signChallenge(
      GroupInnerPayloads.setEncryptedMemberKey(
        groupUltimateSigningPublicKeyHex,
        accountId!,
        publicDuo.signing.value,
        encrypted,
      ),
      member,
    );
    return (
      signingPubkeyHex: publicDuo.signing.value,
      encryptionPubkeyHex: publicDuo.encryption.value,
      encryptedMemberKey: encrypted,
      encryptedMemberKeyAttestation: attestation,
    );
  }

  Future<void> inviteAndJoin(
    SimulatedUser invitee, {
    required String groupId,
    required GroupMemberRole role,
  }) async {
    final group = await getGroup(groupId);
    final prep = await invitee._prepareJoin(
      groupId,
      group.ultimateSigningPublicKeyHex,
    );
    final recipient = await EncryptionKeyPair.importPublicKeySec1Hex(
      EncryptionPublicKeyHex(prep.encryptionPubkeyHex),
    );
    final wrappedDataKey = await AsymmetricCrypto.wrapForRecipient(
      jsonEncode(await (await groupDataKeyFor(groupId)).exportJsonWebKey()),
      recipient.publicKey,
    );
    if (role == GroupMemberRole.admin) {
      await groups.addGroupMemberAsOwner(
        groupId: UuidValue.fromString(groupId),
        newMemberAccountId: invitee.accountId!,
        newMemberSigningPubkeyHex: prep.signingPubkeyHex,
        newMemberEncryptionPublicKeyHex: prep.encryptionPubkeyHex,
        newMemberEncryptedDataKey: wrappedDataKey,
        callerDeviceKey: await deviceKey,
        encryptedMemberKey: prep.encryptedMemberKey,
        encryptedMemberKeyAttestation: prep.encryptedMemberKeyAttestation,
      );
    } else {
      await groups.addGroupMember(
        groupId: UuidValue.fromString(groupId),
        newMemberAccountId: invitee.accountId!,
        role: role,
        newMemberSigningPubkeyHex: prep.signingPubkeyHex,
        newMemberEncryptionPublicKeyHex: prep.encryptionPubkeyHex,
        newMemberEncryptedDataKey: wrappedDataKey,
        callerDeviceKey: await deviceKey,
        encryptedMemberKey: prep.encryptedMemberKey,
        encryptedMemberKeyAttestation: prep.encryptedMemberKeyAttestation,
      );
    }
  }

  Future<void> changeRole(
    String groupId,
    UuidValue memberId,
    GroupMemberRole role,
  ) async {
    final key = await deviceKey;
    if (role == GroupMemberRole.admin) {
      await groups.promoteToAdmin(
        groupId: UuidValue.fromString(groupId),
        memberId: memberId,
        callerDeviceKey: key,
      );
    } else {
      await groups.demoteToMember(
        groupId: UuidValue.fromString(groupId),
        memberId: memberId,
        callerDeviceKey: key,
      );
    }
  }

  Future<void> removeMember(String groupId, UuidValue memberId) async {
    final target = (await listGroupMembers(
      groupId,
    )).singleWhere((m) => m.memberId == memberId);
    if (target.role == GroupMemberRole.admin) {
      await groups.removeGroupMemberAsOwner(
        groupId: UuidValue.fromString(groupId),
        memberId: memberId,
        callerDeviceKey: await deviceKey,
      );
    } else {
      await groups.removeGroupMember(
        groupId: UuidValue.fromString(groupId),
        memberId: memberId,
        callerDeviceKey: await deviceKey,
      );
    }
  }

  Future<void> leaveGroupMembership(String groupId, UuidValue memberId) async {
    await groups.leaveGroup(
      groupId: UuidValue.fromString(groupId),
      memberId: memberId,
      callerDeviceKey: await deviceKey,
    );
  }

  Future<GrantMemberDeviceResult> grantAllDevicesToSelf(
    String groupId,
    UuidValue memberId,
    AesGcmSecretKey dataKey,
  ) async => groups.grantAllDevices(
    groupId: UuidValue.fromString(groupId),
    memberId: memberId,
    groupDataKey: dataKey,
    callerDeviceKey: await deviceKey,
  );

  Future<List<RecoveredMembership>> recoverAccount({
    required String deviceLabel,
  }) => auth.recoverAccount(
    ultimateKeyJwk: ultimateBackupJwk!,
    deviceLabel: deviceLabel,
  );
}
