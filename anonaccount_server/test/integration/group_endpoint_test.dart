import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'test_tools/serverpod_test_tools.dart';

Future<AccountDevice> createTestDevice(
  TestSessionBuilder sessionBuilder, {
  required UuidValue anonAccountId,
  required String deviceSigningPublicKeyHex,
}) async {
  final session = (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: 'createTestDevice',
  );
  try {
    final device = AccountDevice(
      anonAccountId: anonAccountId,
      deviceSigningPublicKeyHex: deviceSigningPublicKeyHex,
      encryptedDataKey: 'test-device-encrypted-data-key',
      label: 'test-device',
      lastActive: DateTime.now(),
      isRevoked: false,
    );
    return await AccountDevice.db.insertRow(session, device);
  } finally {
    await session.close();
  }
}

Future<({String challenge, String pow, String signature})> _outer(
  TestSessionBuilder sessionBuilder,
  TestEndpoints endpoints,
  String methodName,
  String pubKey,
  String privKey,
) async {
  final c = await endpoints.entrypoint.getChallenge(sessionBuilder);
  final pow = await PowTestHelper.mint(c.challenge, difficulty: c.difficulty);
  final payload = '${c.challenge}:$methodName:$pubKey';
  final sig = SigningTestHelper.signWith(payload, privKey);
  return (challenge: c.challenge, pow: pow, signature: sig);
}

/// One-stop bootstrap: account + device + a created group.
/// Returns everything the caller needs to make further authorized calls.
Future<
    ({
      AnonAccount account,
      String devicePriv,
      String devicePub,
      ShareGroup group,
      String groupUltSigPriv,
      String groupUltSigPub,
      String creatorMemberSigPriv,
      String creatorMemberSigPub,
    })> _bootstrapOwnerWithGroup(
  TestSessionBuilder sessionBuilder,
  TestEndpoints endpoints,
) async {
  final (_, accUltPub) = SigningTestHelper.generateKeypair();
  final account = await createTestAccount(
    sessionBuilder,
    ultimateSigningPublicKeyHex: accUltPub,
    ultimatePublicKey: accUltPub,
  );
  final (devicePriv, devicePub) = SigningTestHelper.generateKeypair();
  await createTestDevice(
    sessionBuilder,
    anonAccountId: account.id!,
    deviceSigningPublicKeyHex: devicePub,
  );

  final (groupUltSigPriv, groupUltSigPub) = SigningTestHelper.generateKeypair();
  final (_, groupUltEnc) = SigningTestHelper.generateKeypair();
  final (creatorMemberSigPriv, creatorMemberSigPub) =
      SigningTestHelper.generateKeypair();
  final (_, creatorMemberEnc) = SigningTestHelper.generateKeypair();

  final outer = await _outer(
    sessionBuilder,
    endpoints,
    'createGroup',
    devicePub,
    devicePriv,
  );
  final innerPayload =
      'createGroup:$groupUltSigPub:$groupUltEnc:$creatorMemberSigPub:$creatorMemberEnc';
  final attestation = SigningTestHelper.signWith(innerPayload, groupUltSigPriv);

  final group = await endpoints.group.createGroup(
    sessionBuilder,
    challenge: outer.challenge,
    proofOfWork: outer.pow,
    signature: outer.signature,
    callerDeviceSigningPublicKeyHex: devicePub,
    groupUltimateSigningPublicKeyHex: groupUltSigPub,
    groupUltimatePublicKey: groupUltEnc,
    groupEncryptedDataKey: 'wrapped',
    creatorMemberSigningPublicKeyHex: creatorMemberSigPub,
    creatorMemberPublicKey: creatorMemberEnc,
    creatorMemberEncryptedDataKey: 'wrapped',
    groupUltimateAttestation: attestation,
  );

  return (
    account: account,
    devicePriv: devicePriv,
    devicePub: devicePub,
    group: group,
    groupUltSigPriv: groupUltSigPriv,
    groupUltSigPub: groupUltSigPub,
    creatorMemberSigPriv: creatorMemberSigPriv,
    creatorMemberSigPub: creatorMemberSigPub,
  );
}

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('GroupEndpoint Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    test('createGroup happy path: creator becomes admin', () async {
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);
      expect(s.group.id, isNotNull);

      final outer = await _outer(
        sessionBuilder,
        endpoints,
        'listMyGroups',
        s.devicePub,
        s.devicePriv,
      );
      final memberships = await endpoints.group.listMyGroups(
        sessionBuilder,
        challenge: outer.challenge,
        proofOfWork: outer.pow,
        signature: outer.signature,
        callerDeviceSigningPublicKeyHex: s.devicePub,
      );
      expect(memberships, hasLength(1));
      expect(memberships.single.role, equals(GroupMemberRole.admin));
      expect(
        memberships.single.addedBySignerPublicKeyHex,
        equals(s.groupUltSigPub),
      );
      expect(memberships.single.addedByAttestation, isNotNull);
    });

    test('createGroup rejected when group-ultimate attestation is bad',
        () async {
      final (_, accUltPub) = SigningTestHelper.generateKeypair();
      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: accUltPub,
        ultimatePublicKey: accUltPub,
      );
      final (devicePriv, devicePub) = SigningTestHelper.generateKeypair();
      await createTestDevice(
        sessionBuilder,
        anonAccountId: account.id!,
        deviceSigningPublicKeyHex: devicePub,
      );

      final (_, groupUltSigPub) = SigningTestHelper.generateKeypair();
      final (_, groupUltEnc) = SigningTestHelper.generateKeypair();
      final (_, creatorMemberSigPub) = SigningTestHelper.generateKeypair();
      final (_, creatorMemberEnc) = SigningTestHelper.generateKeypair();

      final outer = await _outer(
        sessionBuilder,
        endpoints,
        'createGroup',
        devicePub,
        devicePriv,
      );
      // Sign the inner payload with a foreign key (not the claimed group
      // ultimate priv) — server must reject.
      final (foreignPriv, _) = SigningTestHelper.generateKeypair();
      final innerPayload =
          'createGroup:$groupUltSigPub:$groupUltEnc:$creatorMemberSigPub:$creatorMemberEnc';
      final badAttestation =
          SigningTestHelper.signWith(innerPayload, foreignPriv);

      expect(
        () => endpoints.group.createGroup(
          sessionBuilder,
          challenge: outer.challenge,
          proofOfWork: outer.pow,
          signature: outer.signature,
          callerDeviceSigningPublicKeyHex: devicePub,
          groupUltimateSigningPublicKeyHex: groupUltSigPub,
          groupUltimatePublicKey: groupUltEnc,
          groupEncryptedDataKey: 'wrapped',
          creatorMemberSigningPublicKeyHex: creatorMemberSigPub,
          creatorMemberPublicKey: creatorMemberEnc,
          creatorMemberEncryptedDataKey: 'wrapped',
          groupUltimateAttestation: badAttestation,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('addGroupMember(role=member): admin can add', () async {
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

      final (_, inviteeUltPub) = SigningTestHelper.generateKeypair();
      final invitee = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: inviteeUltPub,
        ultimatePublicKey: inviteeUltPub,
      );
      final (_, inviteeMemberSig) = SigningTestHelper.generateKeypair();
      final (_, inviteeMemberEnc) = SigningTestHelper.generateKeypair();

      final outer = await _outer(
        sessionBuilder,
        endpoints,
        'addGroupMember',
        s.devicePub,
        s.devicePriv,
      );
      final role = GroupMemberRole.member;
      final innerPayload =
          'addGroupMember:${s.group.id!}:${invitee.id!}:${role.name}:$inviteeMemberSig:$inviteeMemberEnc';
      final innerSig =
          SigningTestHelper.signWith(innerPayload, s.creatorMemberSigPriv);

      final member = await endpoints.group.addGroupMember(
        sessionBuilder,
        challenge: outer.challenge,
        proofOfWork: outer.pow,
        signature: outer.signature,
        callerDeviceSigningPublicKeyHex: s.devicePub,
        groupId: s.group.id!,
        newMemberAccountId: invitee.id!,
        role: role,
        memberSigningPublicKeyHex: inviteeMemberSig,
        memberPublicKey: inviteeMemberEnc,
        encryptedDataKey: 'wrapped-for-invitee',
        callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
        memberAuthSignature: innerSig,
      );
      expect(member.role, equals(GroupMemberRole.member));
      expect(member.addedBySignerPublicKeyHex, equals(s.creatorMemberSigPub));
      expect(member.addedByAttestation, equals(innerSig));
    });

    test('addGroupMember(role=member): rejected when caller is not admin',
        () async {
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

      // Add a regular member first, then have that member try to invite.
      final (_, m2UltPub) = SigningTestHelper.generateKeypair();
      final m2Account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: m2UltPub,
        ultimatePublicKey: m2UltPub,
      );
      final (m2DevicePriv, m2DevicePub) = SigningTestHelper.generateKeypair();
      await createTestDevice(
        sessionBuilder,
        anonAccountId: m2Account.id!,
        deviceSigningPublicKeyHex: m2DevicePub,
      );
      final (m2MemberPriv, m2MemberPub) = SigningTestHelper.generateKeypair();
      final (_, m2MemberEnc) = SigningTestHelper.generateKeypair();

      // Admin adds m2 as a member.
      final outerAdd = await _outer(
        sessionBuilder,
        endpoints,
        'addGroupMember',
        s.devicePub,
        s.devicePriv,
      );
      final addPayload =
          'addGroupMember:${s.group.id!}:${m2Account.id!}:${GroupMemberRole.member.name}:$m2MemberPub:$m2MemberEnc';
      final addSig =
          SigningTestHelper.signWith(addPayload, s.creatorMemberSigPriv);
      await endpoints.group.addGroupMember(
        sessionBuilder,
        challenge: outerAdd.challenge,
        proofOfWork: outerAdd.pow,
        signature: outerAdd.signature,
        callerDeviceSigningPublicKeyHex: s.devicePub,
        groupId: s.group.id!,
        newMemberAccountId: m2Account.id!,
        role: GroupMemberRole.member,
        memberSigningPublicKeyHex: m2MemberPub,
        memberPublicKey: m2MemberEnc,
        encryptedDataKey: 'wrapped',
        callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
        memberAuthSignature: addSig,
      );

      // Now m2 (a non-admin member) tries to add an invitee.
      final (_, victimUltPub) = SigningTestHelper.generateKeypair();
      final victim = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: victimUltPub,
        ultimatePublicKey: victimUltPub,
      );
      final (_, vMemberSig) = SigningTestHelper.generateKeypair();
      final (_, vMemberEnc) = SigningTestHelper.generateKeypair();

      final outer = await _outer(
        sessionBuilder,
        endpoints,
        'addGroupMember',
        m2DevicePub,
        m2DevicePriv,
      );
      final innerPayload =
          'addGroupMember:${s.group.id!}:${victim.id!}:${GroupMemberRole.member.name}:$vMemberSig:$vMemberEnc';
      final innerSig = SigningTestHelper.signWith(innerPayload, m2MemberPriv);

      expect(
        () => endpoints.group.addGroupMember(
          sessionBuilder,
          challenge: outer.challenge,
          proofOfWork: outer.pow,
          signature: outer.signature,
          callerDeviceSigningPublicKeyHex: m2DevicePub,
          groupId: s.group.id!,
          newMemberAccountId: victim.id!,
          role: GroupMemberRole.member,
          memberSigningPublicKeyHex: vMemberSig,
          memberPublicKey: vMemberEnc,
          encryptedDataKey: 'wrapped',
          callerMemberSigningPublicKeyHex: m2MemberPub,
          memberAuthSignature: innerSig,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('addGroupMember(role=member): rejected on account-binding mismatch',
        () async {
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

      // A different account with its own device.
      final (_, otherUltPub) = SigningTestHelper.generateKeypair();
      final otherAccount = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: otherUltPub,
        ultimatePublicKey: otherUltPub,
      );
      final (otherDevicePriv, otherDevicePub) =
          SigningTestHelper.generateKeypair();
      await createTestDevice(
        sessionBuilder,
        anonAccountId: otherAccount.id!,
        deviceSigningPublicKeyHex: otherDevicePub,
      );

      // Other account's device submits an addGroupMember signed by the
      // admin's (someone else's) member key — server must reject because
      // the member key is not account-bound to the device.
      final (_, vUltPub) = SigningTestHelper.generateKeypair();
      final victim = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: vUltPub,
        ultimatePublicKey: vUltPub,
      );
      final (_, vMemberSig) = SigningTestHelper.generateKeypair();
      final (_, vMemberEnc) = SigningTestHelper.generateKeypair();

      final outer = await _outer(
        sessionBuilder,
        endpoints,
        'addGroupMember',
        otherDevicePub,
        otherDevicePriv,
      );
      final innerPayload =
          'addGroupMember:${s.group.id!}:${victim.id!}:${GroupMemberRole.member.name}:$vMemberSig:$vMemberEnc';
      final innerSig =
          SigningTestHelper.signWith(innerPayload, s.creatorMemberSigPriv);

      expect(
        () => endpoints.group.addGroupMember(
          sessionBuilder,
          challenge: outer.challenge,
          proofOfWork: outer.pow,
          signature: outer.signature,
          callerDeviceSigningPublicKeyHex: otherDevicePub,
          groupId: s.group.id!,
          newMemberAccountId: victim.id!,
          role: GroupMemberRole.member,
          memberSigningPublicKeyHex: vMemberSig,
          memberPublicKey: vMemberEnc,
          encryptedDataKey: 'wrapped',
          callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
          memberAuthSignature: innerSig,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('addGroupMember(role=admin): requires owner ultimate sig', () async {
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

      // Invitee account.
      final (_, inviteeUltPub) = SigningTestHelper.generateKeypair();
      final invitee = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: inviteeUltPub,
        ultimatePublicKey: inviteeUltPub,
      );
      final (_, inviteeMemberSig) = SigningTestHelper.generateKeypair();
      final (_, inviteeMemberEnc) = SigningTestHelper.generateKeypair();

      final outer = await _outer(
        sessionBuilder,
        endpoints,
        'addGroupMember',
        s.devicePub,
        s.devicePriv,
      );
      final innerPayload =
          'addGroupMember:${s.group.id!}:${invitee.id!}:${GroupMemberRole.admin.name}:$inviteeMemberSig:$inviteeMemberEnc';
      final ownerSig =
          SigningTestHelper.signWith(innerPayload, s.groupUltSigPriv);

      final member = await endpoints.group.addGroupMember(
        sessionBuilder,
        challenge: outer.challenge,
        proofOfWork: outer.pow,
        signature: outer.signature,
        callerDeviceSigningPublicKeyHex: s.devicePub,
        groupId: s.group.id!,
        newMemberAccountId: invitee.id!,
        role: GroupMemberRole.admin,
        memberSigningPublicKeyHex: inviteeMemberSig,
        memberPublicKey: inviteeMemberEnc,
        encryptedDataKey: 'wrapped',
        groupUltimateSignature: ownerSig,
      );
      expect(member.role, equals(GroupMemberRole.admin));
      expect(member.addedBySignerPublicKeyHex, equals(s.groupUltSigPub));
    });

    test('addGroupMember(role=admin): rejected without owner sig', () async {
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

      final (_, inviteeUltPub) = SigningTestHelper.generateKeypair();
      final invitee = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: inviteeUltPub,
        ultimatePublicKey: inviteeUltPub,
      );
      final (_, inviteeMemberSig) = SigningTestHelper.generateKeypair();
      final (_, inviteeMemberEnc) = SigningTestHelper.generateKeypair();

      final outer = await _outer(
        sessionBuilder,
        endpoints,
        'addGroupMember',
        s.devicePub,
        s.devicePriv,
      );
      // Caller supplies only the member-key path; server must reject
      // because role=admin requires owner sig.
      final innerPayload =
          'addGroupMember:${s.group.id!}:${invitee.id!}:${GroupMemberRole.admin.name}:$inviteeMemberSig:$inviteeMemberEnc';
      final memberSig =
          SigningTestHelper.signWith(innerPayload, s.creatorMemberSigPriv);

      expect(
        () => endpoints.group.addGroupMember(
          sessionBuilder,
          challenge: outer.challenge,
          proofOfWork: outer.pow,
          signature: outer.signature,
          callerDeviceSigningPublicKeyHex: s.devicePub,
          groupId: s.group.id!,
          newMemberAccountId: invitee.id!,
          role: GroupMemberRole.admin,
          memberSigningPublicKeyHex: inviteeMemberSig,
          memberPublicKey: inviteeMemberEnc,
          encryptedDataKey: 'wrapped',
          callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
          memberAuthSignature: memberSig,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('removeGroupMember: admin removes a member', () async {
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

      // Add a victim member first.
      final (_, vUltPub) = SigningTestHelper.generateKeypair();
      final victim = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: vUltPub,
        ultimatePublicKey: vUltPub,
      );
      final (_, vMemberSig) = SigningTestHelper.generateKeypair();
      final (_, vMemberEnc) = SigningTestHelper.generateKeypair();

      final outerAdd = await _outer(
        sessionBuilder,
        endpoints,
        'addGroupMember',
        s.devicePub,
        s.devicePriv,
      );
      final addPayload =
          'addGroupMember:${s.group.id!}:${victim.id!}:${GroupMemberRole.member.name}:$vMemberSig:$vMemberEnc';
      final addSig =
          SigningTestHelper.signWith(addPayload, s.creatorMemberSigPriv);
      final victimRow = await endpoints.group.addGroupMember(
        sessionBuilder,
        challenge: outerAdd.challenge,
        proofOfWork: outerAdd.pow,
        signature: outerAdd.signature,
        callerDeviceSigningPublicKeyHex: s.devicePub,
        groupId: s.group.id!,
        newMemberAccountId: victim.id!,
        role: GroupMemberRole.member,
        memberSigningPublicKeyHex: vMemberSig,
        memberPublicKey: vMemberEnc,
        encryptedDataKey: 'wrapped',
        callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
        memberAuthSignature: addSig,
      );

      // Admin removes the member.
      final outerRm = await _outer(
        sessionBuilder,
        endpoints,
        'removeGroupMember',
        s.devicePub,
        s.devicePriv,
      );
      final rmPayload = 'removeGroupMember:${victimRow.id!}';
      final rmSig =
          SigningTestHelper.signWith(rmPayload, s.creatorMemberSigPriv);

      final ok = await endpoints.group.removeGroupMember(
        sessionBuilder,
        challenge: outerRm.challenge,
        proofOfWork: outerRm.pow,
        signature: outerRm.signature,
        callerDeviceSigningPublicKeyHex: s.devicePub,
        memberId: victimRow.id!,
        callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
        memberAuthSignature: rmSig,
      );
      expect(ok, isTrue);

      // Confirm row is revoked and has revokedBy* persisted.
      final session = (sessionBuilder as InternalTestSessionBuilder)
          .internalBuild(endpoint: 'test', method: 'verify');
      try {
        final after = await GroupMember.db.findById(session, victimRow.id!);
        expect(after!.isRevoked, isTrue);
        expect(
          after.revokedBySignerPublicKeyHex,
          equals(s.creatorMemberSigPub),
        );
        expect(after.revokedByAttestation, equals(rmSig));
      } finally {
        await session.close();
      }
    });

    test('getGroup: returns group details for active member', () async {
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

      final outer = await _outer(
        sessionBuilder, endpoints, 'getGroup', s.devicePub, s.devicePriv,
      );
      final innerPayload = GroupInnerPayloads.getGroup(s.group.id!);
      final innerSig = SigningTestHelper.signWith(innerPayload, s.creatorMemberSigPriv);

      final result = await endpoints.group.getGroup(
        sessionBuilder,
        challenge: outer.challenge,
        proofOfWork: outer.pow,
        signature: outer.signature,
        callerDeviceSigningPublicKeyHex: s.devicePub,
        groupId: s.group.id!,
        callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
        memberAuthSignature: innerSig,
      );

      expect(result.id, equals(s.group.id));
      expect(result.ultimateSigningPublicKeyHex, equals(s.groupUltSigPub));
    });

    test('getGroup: rejected when member sig is wrong', () async {
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

      final outer = await _outer(
        sessionBuilder, endpoints, 'getGroup', s.devicePub, s.devicePriv,
      );
      final innerPayload = GroupInnerPayloads.getGroup(s.group.id!);
      final (foreignPriv, _) = SigningTestHelper.generateKeypair();
      final badSig = SigningTestHelper.signWith(innerPayload, foreignPriv);

      expect(
        () => endpoints.group.getGroup(
          sessionBuilder,
          challenge: outer.challenge,
          proofOfWork: outer.pow,
          signature: outer.signature,
          callerDeviceSigningPublicKeyHex: s.devicePub,
          groupId: s.group.id!,
          callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
          memberAuthSignature: badSig,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('getGroup: rejected when caller is not a member of the group', () async {
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

      // A separate account with no membership.
      final (_, outsiderUltPub) = SigningTestHelper.generateKeypair();
      final outsider = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: outsiderUltPub,
        ultimatePublicKey: outsiderUltPub,
      );
      final (outsiderDevicePriv, outsiderDevicePub) = SigningTestHelper.generateKeypair();
      await createTestDevice(
        sessionBuilder,
        anonAccountId: outsider.id!,
        deviceSigningPublicKeyHex: outsiderDevicePub,
      );
      final (outsiderMemberPriv, outsiderMemberPub) = SigningTestHelper.generateKeypair();

      final outer = await _outer(
        sessionBuilder, endpoints, 'getGroup', outsiderDevicePub, outsiderDevicePriv,
      );
      final innerPayload = GroupInnerPayloads.getGroup(s.group.id!);
      final innerSig = SigningTestHelper.signWith(innerPayload, outsiderMemberPriv);

      expect(
        () => endpoints.group.getGroup(
          sessionBuilder,
          challenge: outer.challenge,
          proofOfWork: outer.pow,
          signature: outer.signature,
          callerDeviceSigningPublicKeyHex: outsiderDevicePub,
          groupId: s.group.id!,
          callerMemberSigningPublicKeyHex: outsiderMemberPub,
          memberAuthSignature: innerSig,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('listGroupMembers: returns active members only', () async {
  final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

  // Add a second member.
  final (_, m2UltPub) = SigningTestHelper.generateKeypair();
  final m2 = await createTestAccount(
    sessionBuilder,
    ultimateSigningPublicKeyHex: m2UltPub,
    ultimatePublicKey: m2UltPub,
  );
  final (_, m2MemberSig) = SigningTestHelper.generateKeypair();
  final (_, m2MemberEnc) = SigningTestHelper.generateKeypair();

  final outerAdd = await _outer(
    sessionBuilder, endpoints, 'addGroupMember', s.devicePub, s.devicePriv,
  );
  final addInner = GroupInnerPayloads.addGroupMember(
    s.group.id!, m2.id!, GroupMemberRole.member, m2MemberSig, m2MemberEnc,
  );
  final addSig = SigningTestHelper.signWith(addInner, s.creatorMemberSigPriv);
  await endpoints.group.addGroupMember(
    sessionBuilder,
    challenge: outerAdd.challenge,
    proofOfWork: outerAdd.pow,
    signature: outerAdd.signature,
    callerDeviceSigningPublicKeyHex: s.devicePub,
    groupId: s.group.id!,
    newMemberAccountId: m2.id!,
    role: GroupMemberRole.member,
    memberSigningPublicKeyHex: m2MemberSig,
    memberPublicKey: m2MemberEnc,
    encryptedDataKey: 'wrapped',
    callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
    memberAuthSignature: addSig,
  );

  final outer = await _outer(
    sessionBuilder, endpoints, 'listGroupMembers', s.devicePub, s.devicePriv,
  );
  final innerPayload = GroupInnerPayloads.listGroupMembers(s.group.id!);
  final innerSig = SigningTestHelper.signWith(innerPayload, s.creatorMemberSigPriv);

  final members = await endpoints.group.listGroupMembers(
    sessionBuilder,
    challenge: outer.challenge,
    proofOfWork: outer.pow,
    signature: outer.signature,
    callerDeviceSigningPublicKeyHex: s.devicePub,
    groupId: s.group.id!,
    callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
    memberAuthSignature: innerSig,
  );

  expect(members, hasLength(2));
  expect(members.any((m) => m.role == GroupMemberRole.admin), isTrue);
  expect(members.any((m) => m.role == GroupMemberRole.member), isTrue);
  expect(members.every((m) => !m.isRevoked), isTrue);
});

test('listGroupMembers: rejected when caller is not a member', () async {
  final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

  final (_, outsiderUltPub) = SigningTestHelper.generateKeypair();
  final outsider = await createTestAccount(
    sessionBuilder,
    ultimateSigningPublicKeyHex: outsiderUltPub,
    ultimatePublicKey: outsiderUltPub,
  );
  final (outsiderDevicePriv, outsiderDevicePub) = SigningTestHelper.generateKeypair();
  await createTestDevice(
    sessionBuilder,
    anonAccountId: outsider.id!,
    deviceSigningPublicKeyHex: outsiderDevicePub,
  );
  final (outsiderMemberPriv, outsiderMemberPub) = SigningTestHelper.generateKeypair();

  final outer = await _outer(
    sessionBuilder, endpoints, 'listGroupMembers', outsiderDevicePub, outsiderDevicePriv,
  );
  final innerPayload = GroupInnerPayloads.listGroupMembers(s.group.id!);
  final innerSig = SigningTestHelper.signWith(innerPayload, outsiderMemberPriv);

  expect(
    () => endpoints.group.listGroupMembers(
      sessionBuilder,
      challenge: outer.challenge,
      proofOfWork: outer.pow,
      signature: outer.signature,
      callerDeviceSigningPublicKeyHex: outsiderDevicePub,
      groupId: s.group.id!,
      callerMemberSigningPublicKeyHex: outsiderMemberPub,
      memberAuthSignature: innerSig,
    ),
    throwsA(isA<Exception>()),
  );
});

    test('leaveGroup: member removes themselves, row is self-attested', () async {
  final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

  // Add a second member to leave.
  final (_, m2UltPub) = SigningTestHelper.generateKeypair();
  final m2 = await createTestAccount(
    sessionBuilder,
    ultimateSigningPublicKeyHex: m2UltPub,
    ultimatePublicKey: m2UltPub,
  );
  final (m2DevicePriv, m2DevicePub) = SigningTestHelper.generateKeypair();
  await createTestDevice(
    sessionBuilder,
    anonAccountId: m2.id!,
    deviceSigningPublicKeyHex: m2DevicePub,
  );
  final (m2MemberPriv, m2MemberPub) = SigningTestHelper.generateKeypair();
  final (_, m2MemberEnc) = SigningTestHelper.generateKeypair();

  final outerAdd = await _outer(
    sessionBuilder, endpoints, 'addGroupMember', s.devicePub, s.devicePriv,
  );
  final addInner = GroupInnerPayloads.addGroupMember(
    s.group.id!, m2.id!, GroupMemberRole.member, m2MemberPub, m2MemberEnc,
  );
  final addSig = SigningTestHelper.signWith(addInner, s.creatorMemberSigPriv);
  final m2Row = await endpoints.group.addGroupMember(
    sessionBuilder,
    challenge: outerAdd.challenge,
    proofOfWork: outerAdd.pow,
    signature: outerAdd.signature,
    callerDeviceSigningPublicKeyHex: s.devicePub,
    groupId: s.group.id!,
    newMemberAccountId: m2.id!,
    role: GroupMemberRole.member,
    memberSigningPublicKeyHex: m2MemberPub,
    memberPublicKey: m2MemberEnc,
    encryptedDataKey: 'wrapped',
    callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
    memberAuthSignature: addSig,
  );

  // m2 leaves.
  final outer = await _outer(
    sessionBuilder, endpoints, 'leaveGroup', m2DevicePub, m2DevicePriv,
  );
  final innerPayload = GroupInnerPayloads.leaveGroup(m2Row.id!);
  final innerSig = SigningTestHelper.signWith(innerPayload, m2MemberPriv);

  final ok = await endpoints.group.leaveGroup(
    sessionBuilder,
    challenge: outer.challenge,
    proofOfWork: outer.pow,
    signature: outer.signature,
    callerDeviceSigningPublicKeyHex: m2DevicePub,
    memberId: m2Row.id!,
    memberSigningPublicKeyHex: m2MemberPub,
    memberAuthSignature: innerSig,
  );
  expect(ok, isTrue);

  // Verify row is self-attested revocation.
  final dbSession = (sessionBuilder as InternalTestSessionBuilder)
      .internalBuild(endpoint: 'test', method: 'verify');
  try {
    final after = await GroupMember.db.findById(dbSession, m2Row.id!);
    expect(after!.isRevoked, isTrue);
    expect(after.revokedBySignerPublicKeyHex, equals(m2MemberPub));
    expect(after.revokedByAttestation, equals(innerSig));
  } finally {
    await dbSession.close();
  }

  // Group still exists — creator is still an admin.
  final dbSession2 = (sessionBuilder as InternalTestSessionBuilder)
      .internalBuild(endpoint: 'test', method: 'verify');
  try {
    final groupAfter = await ShareGroup.db.findById(dbSession2, s.group.id!);
    expect(groupAfter, isNotNull);
  } finally {
    await dbSession2.close();
  }
});

test('leaveGroup: last admin with other members present cannot leave (guard blocks)',
    () async {
  final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

  // Add a second (plain) member so the creator's admin seat is the sole
  // admin while the group is non-empty otherwise.
  final (_, m2UltPub) = SigningTestHelper.generateKeypair();
  final m2 = await createTestAccount(
    sessionBuilder,
    ultimateSigningPublicKeyHex: m2UltPub,
    ultimatePublicKey: m2UltPub,
  );
  final (_, m2DevicePub) = SigningTestHelper.generateKeypair();
  await createTestDevice(
    sessionBuilder,
    anonAccountId: m2.id!,
    deviceSigningPublicKeyHex: m2DevicePub,
  );
  final (_, m2MemberPub) = SigningTestHelper.generateKeypair();
  final (_, m2MemberEnc) = SigningTestHelper.generateKeypair();

  final outerAdd = await _outer(
    sessionBuilder, endpoints, 'addGroupMember', s.devicePub, s.devicePriv,
  );
  final addInner = GroupInnerPayloads.addGroupMember(
    s.group.id!, m2.id!, GroupMemberRole.member, m2MemberPub, m2MemberEnc,
  );
  final addSig = SigningTestHelper.signWith(addInner, s.creatorMemberSigPriv);
  await endpoints.group.addGroupMember(
    sessionBuilder,
    challenge: outerAdd.challenge,
    proofOfWork: outerAdd.pow,
    signature: outerAdd.signature,
    callerDeviceSigningPublicKeyHex: s.devicePub,
    groupId: s.group.id!,
    newMemberAccountId: m2.id!,
    role: GroupMemberRole.member,
    memberSigningPublicKeyHex: m2MemberPub,
    memberPublicKey: m2MemberEnc,
    encryptedDataKey: 'wrapped',
    callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
    memberAuthSignature: addSig,
  );

  // Find the creator's (sole admin's) member row.
  final lookupSession = (sessionBuilder as InternalTestSessionBuilder)
      .internalBuild(endpoint: 'test', method: 'findCreator');
  late final GroupMember creatorRow;
  try {
    creatorRow = (await GroupMember.db.findFirstRow(
      lookupSession,
      where: (t) =>
          t.shareGroupId.equals(s.group.id!) &
          t.anonAccountId.equals(s.account.id!),
    ))!;
  } finally {
    await lookupSession.close();
  }

  final outer = await _outer(
    sessionBuilder, endpoints, 'leaveGroup', s.devicePub, s.devicePriv,
  );
  final innerPayload = GroupInnerPayloads.leaveGroup(creatorRow.id!);
  final innerSig = SigningTestHelper.signWith(innerPayload, s.creatorMemberSigPriv);

  expect(
    () => endpoints.group.leaveGroup(
      sessionBuilder,
      challenge: outer.challenge,
      proofOfWork: outer.pow,
      signature: outer.signature,
      callerDeviceSigningPublicKeyHex: s.devicePub,
      memberId: creatorRow.id!,
      memberSigningPublicKeyHex: s.creatorMemberSigPub,
      memberAuthSignature: innerSig,
    ),
    throwsA(isA<Exception>()),
  );

  // The group must still exist and the creator must still be active
  // (unrevoked) — the guard must block before any mutation, not partially
  // apply then throw.
  final dbSession = (sessionBuilder as InternalTestSessionBuilder)
      .internalBuild(endpoint: 'test', method: 'verify');
  try {
    final groupAfter = await ShareGroup.db.findById(dbSession, s.group.id!);
    expect(groupAfter, isNotNull);
    final creatorAfter = await GroupMember.db.findById(dbSession, creatorRow.id!);
    expect(creatorAfter!.isRevoked, isFalse);
  } finally {
    await dbSession.close();
  }
});

test(
  'concurrent two-admin leaveGroup: exactly one wins, state stays consistent',
  () async {},
  skip: 'The serverpod_test harness (RollbackDatabase.afterEach by default) '
      'serializes all DB calls through one TestDatabaseProxy and throws '
      'InvalidConfigurationException on concurrent session.db.transaction() '
      'calls within a single withServerpod test — so a real two-admin race '
      'cannot be exercised in-pod without two independently-opened '
      'connections/sessions bypassing the test proxy, which this harness '
      'does not expose a supported way to do. The shipped guarantee is: (1) '
      'the deterministic guard-logic tests above (blocked-with-members / '
      'dissolved-when-sole-admin) pass both before and after the fix, and '
      '(2) the fix itself uses LockMode.forUpdate on the active-admin read '
      'inside session.db.transaction() in group_endpoint.dart, which is the '
      'standard Postgres SELECT ... FOR UPDATE pattern for serializing a '
      'check-then-act race — verified by code review against '
      'serverpod-3.4.1\'s database.dart (LockMode.forUpdate requires a '
      'transaction and blocks a second locker until the first commits, then '
      're-reads the current row versions). Do not delete this test without '
      'either standing up a real dual-connection harness or removing this '
      'documented rationale along with it.',
);

test('leaveGroup: last admin leaving deletes the group and all members', () async {
  final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

  // Find the creator's member row.
  final lookupSession = (sessionBuilder as InternalTestSessionBuilder)
      .internalBuild(endpoint: 'test', method: 'findCreator');
  late final GroupMember creatorRow;
  try {
    creatorRow = (await GroupMember.db.findFirstRow(
      lookupSession,
      where: (t) =>
          t.shareGroupId.equals(s.group.id!) &
          t.anonAccountId.equals(s.account.id!),
    ))!;
  } finally {
    await lookupSession.close();
  }

  final outer = await _outer(
    sessionBuilder, endpoints, 'leaveGroup', s.devicePub, s.devicePriv,
  );
  final innerPayload = GroupInnerPayloads.leaveGroup(creatorRow.id!);
  final innerSig = SigningTestHelper.signWith(innerPayload, s.creatorMemberSigPriv);

  final ok = await endpoints.group.leaveGroup(
    sessionBuilder,
    challenge: outer.challenge,
    proofOfWork: outer.pow,
    signature: outer.signature,
    callerDeviceSigningPublicKeyHex: s.devicePub,
    memberId: creatorRow.id!,
    memberSigningPublicKeyHex: s.creatorMemberSigPub,
    memberAuthSignature: innerSig,
  );
  expect(ok, isTrue);

  // Group must be deleted.
  final dbSession = (sessionBuilder as InternalTestSessionBuilder)
      .internalBuild(endpoint: 'test', method: 'verify');
  try {
    final groupAfter = await ShareGroup.db.findById(dbSession, s.group.id!);
    expect(groupAfter, isNull);
  } finally {
    await dbSession.close();
  }
});

test('leaveGroup: rejected when inner sig is wrong', () async {
  final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

  final lookupSession = (sessionBuilder as InternalTestSessionBuilder)
      .internalBuild(endpoint: 'test', method: 'findCreator');
  late final GroupMember creatorRow;
  try {
    creatorRow = (await GroupMember.db.findFirstRow(
      lookupSession,
      where: (t) =>
          t.shareGroupId.equals(s.group.id!) &
          t.anonAccountId.equals(s.account.id!),
    ))!;
  } finally {
    await lookupSession.close();
  }

  final outer = await _outer(
    sessionBuilder, endpoints, 'leaveGroup', s.devicePub, s.devicePriv,
  );
  final innerPayload = GroupInnerPayloads.leaveGroup(creatorRow.id!);
  final (foreignPriv, _) = SigningTestHelper.generateKeypair();
  final badSig = SigningTestHelper.signWith(innerPayload, foreignPriv);

  expect(
    () => endpoints.group.leaveGroup(
      sessionBuilder,
      challenge: outer.challenge,
      proofOfWork: outer.pow,
      signature: outer.signature,
      callerDeviceSigningPublicKeyHex: s.devicePub,
      memberId: creatorRow.id!,
      memberSigningPublicKeyHex: s.creatorMemberSigPub,
      memberAuthSignature: badSig,
    ),
    throwsA(isA<Exception>()),
  );
});

    test('monitorGroupMembership: rejected for invalid device key', () async {
  final (memberPriv, memberPub) = SigningTestHelper.generateKeypair();
  final (_, unknownPub) = SigningTestHelper.generateKeypair();

  // Build outer with an unknown device key — no DB row exists for it.
  final challengeResp = await endpoints.entrypoint.getChallenge(sessionBuilder);
  final pow = await PowTestHelper.mint(
    challengeResp.challenge,
    difficulty: challengeResp.difficulty,
  );
  final payload =
      '${challengeResp.challenge}:${GroupMethods.monitorGroupMembership}:$unknownPub';
  final sig = SigningTestHelper.signWith(payload, memberPriv);

  final stream = endpoints.group.monitorGroupMembership(
    sessionBuilder,
    challenge: challengeResp.challenge,
    proofOfWork: pow,
    signature: sig,
    callerDeviceSigningPublicKeyHex: unknownPub,
    memberSigningKeyHex: memberPub,
  );

  expect(
    () async => await stream.first,
    throwsA(isA<Exception>()),
  );
});

test('monitorGroupMembership: opens without throwing for valid device', () async {
  final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);
  final (_, freshMemberPub) = SigningTestHelper.generateKeypair();

  final outer = await _outer(
    sessionBuilder,
    endpoints,
    GroupMethods.monitorGroupMembership,
    s.devicePub,
    s.devicePriv,
  );

  final stream = endpoints.group.monitorGroupMembership(
    sessionBuilder,
    challenge: outer.challenge,
    proofOfWork: outer.pow,
    signature: outer.signature,
    callerDeviceSigningPublicKeyHex: s.devicePub,
    memberSigningKeyHex: freshMemberPub,
  );
  expect(stream, isNotNull);
});

    test('removeGroupMember: rejected when removing an admin without owner sig',
        () async {
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

      // Find the creator's admin membership row.
      final session = (sessionBuilder as InternalTestSessionBuilder)
          .internalBuild(endpoint: 'test', method: 'findCreator');
      late final GroupMember creatorRow;
      try {
        creatorRow = (await GroupMember.db.findFirstRow(
          session,
          where: (t) =>
              t.shareGroupId.equals(s.group.id!) &
              t.anonAccountId.equals(s.account.id!),
        ))!;
      } finally {
        await session.close();
      }

      // Caller (the creator/admin) tries to remove themselves using the
      // member-key path — must fail because target.role = admin.
      final outer = await _outer(
        sessionBuilder,
        endpoints,
        'removeGroupMember',
        s.devicePub,
        s.devicePriv,
      );
      final innerPayload = 'removeGroupMember:${creatorRow.id!}';
      final memberSig =
          SigningTestHelper.signWith(innerPayload, s.creatorMemberSigPriv);

      expect(
        () => endpoints.group.removeGroupMember(
          sessionBuilder,
          challenge: outer.challenge,
          proofOfWork: outer.pow,
          signature: outer.signature,
          callerDeviceSigningPublicKeyHex: s.devicePub,
          memberId: creatorRow.id!,
          callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
          memberAuthSignature: memberSig,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
