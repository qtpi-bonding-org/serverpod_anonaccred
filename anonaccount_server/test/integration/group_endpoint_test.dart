import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/revocation_test_helper.dart';
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
      deviceEncryptionPublicKeyHex: deviceSigningPublicKeyHex,
      encryptedDataKey: 'test-device-encrypted-data-key',
      label: 'test-device',
      addedByAttestorPublicKeyHex: deviceSigningPublicKeyHex,
      addedByAttestation: 'test-attestation',
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

/// A valid `setEncryptedMemberKey` blob + attestation for `addGroupMember`
/// tests. The server never decrypts the blob, only verifies the signature
/// over it — so a fixed placeholder string is sufficient content.
({String blob, String attestation}) _memberKeyBackup({
  required String groupUltimateSigningPublicKeyHex,
  required UuidValue anonAccountId,
  required String memberSigningPublicKeyHex,
  required String memberSigningPrivateKeyHex,
}) {
  const blob = 'wrapped-member-key';
  final attestation = SigningTestHelper.signWith(
    GroupInnerPayloads.setEncryptedMemberKey(
      groupUltimateSigningPublicKeyHex,
      anonAccountId,
      memberSigningPublicKeyHex,
      blob,
    ),
    memberSigningPrivateKeyHex,
  );
  return (blob: blob, attestation: attestation);
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
  })
>
_bootstrapOwnerWithGroup(
  TestSessionBuilder sessionBuilder,
  TestEndpoints endpoints,
) async {
  final (_, accUltPub) = SigningTestHelper.generateKeypair();
  final account = await createTestAccount(
    sessionBuilder,
    ultimateSigningPublicKeyHex: accUltPub,
    ultimateEncryptionPublicKeyHex: accUltPub,
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
  final backupAttestation = SigningTestHelper.signWith(
    GroupInnerPayloads.setEncryptedMemberKey(
      groupUltSigPub,
      account.id!,
      creatorMemberSigPub,
      'wrapped-member-key',
    ),
    creatorMemberSigPriv,
  );

  final group = await endpoints.group.createGroup(
    sessionBuilder,
    challenge: outer.challenge,
    proofOfWork: outer.pow,
    signature: outer.signature,
    callerDeviceSigningPublicKeyHex: devicePub,
    groupUltimateKeys: PublicKeyDuo(
      signingPublicKeyHex: groupUltSigPub,
      encryptionPublicKeyHex: groupUltEnc,
    ),
    groupEncryptedDataKey: 'wrapped',
    creatorMemberKeys: PublicKeyDuo(
      signingPublicKeyHex: creatorMemberSigPub,
      encryptionPublicKeyHex: creatorMemberEnc,
    ),
    creatorMemberEncryptedDataKey: 'wrapped',
    groupUltimateAttestation: attestation,
    creatorEncryptedMemberKey: 'wrapped-member-key',
    creatorEncryptedMemberKeyAttestation: backupAttestation,
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

  withServerpod('GroupEndpoint Integration Tests', (sessionBuilder, endpoints) {
    test(
      'listMyGroups: returns THIS device\'s grant, not a sibling\'s',
      () async {
        // Two devices of the same account, each granted on the same
        // membership with a DIFFERENT wrapped blob. The single most
        // important assertion in the unit — without it, the read test
        // passes even if the server returns an arbitrary grant row.
        final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

        // Second device of the same account, set up directly.
        final (m2DevicePriv, m2DevicePub) = SigningTestHelper.generateKeypair();
        final m2Device = await createTestDevice(
          sessionBuilder,
          anonAccountId: s.account.id!,
          deviceSigningPublicKeyHex: m2DevicePub,
        );

        // Insert the two GroupMemberDevice grants directly via DB, the same
        // way `grant_member_device_test.dart` does. We bypass the
        // attestation flow because the read-side bug is independent of how
        // the row got there.
        final setupSession = (sessionBuilder as InternalTestSessionBuilder)
            .internalBuild(endpoint: 'test', method: 'setupGrants');
        try {
          // Find the creator's GroupMember row (the only membership for
          // this account after _bootstrapOwnerWithGroup).
          final creatorMember = (await GroupMember.db.findFirstRow(
            setupSession,
            where: (t) =>
                t.shareGroupId.equals(s.group.id!) &
                t.anonAccountId.equals(s.account.id!),
          ))!;
          // Find the creator's own AccountDevice row (s.devicePub was
          // registered by _bootstrapOwnerWithGroup).
          final creatorDevice = (await AccountDevice.db.findFirstRow(
            setupSession,
            where: (t) => t.deviceSigningPublicKeyHex.equals(s.devicePub),
          ))!;

          await GroupMemberDevice.db.insertRow(
            setupSession,
            GroupMemberDevice(
              groupMemberId: creatorMember.id!,
              accountDeviceId: creatorDevice.id!,
              encryptedDataKey: 'blob-for-d1',
              addedByAttestorPublicKeyHex: s.creatorMemberSigPub,
              addedByAttestation: 'attestation-d1',
            ),
          );
          await GroupMemberDevice.db.insertRow(
            setupSession,
            GroupMemberDevice(
              groupMemberId: creatorMember.id!,
              accountDeviceId: m2Device.id!,
              encryptedDataKey: 'blob-for-d2',
              addedByAttestorPublicKeyHex: s.creatorMemberSigPub,
              addedByAttestation: 'attestation-d2',
            ),
          );
        } finally {
          await setupSession.close();
        }

        // Caller D1 — should see its own blob, not the sibling's.
        final outerD1 = await _outer(
          sessionBuilder,
          endpoints,
          'listMyGroups',
          s.devicePub,
          s.devicePriv,
        );
        final asD1 = await endpoints.group.listMyGroups(
          sessionBuilder,
          challenge: outerD1.challenge,
          proofOfWork: outerD1.pow,
          signature: outerD1.signature,
          callerDeviceSigningPublicKeyHex: s.devicePub,
        );
        expect(asD1, hasLength(1));
        expect(asD1.single.deviceEncryptedDataKey, equals('blob-for-d1'));

        // Caller D2 — should see its own blob, not D1's.
        final outerD2 = await _outer(
          sessionBuilder,
          endpoints,
          'listMyGroups',
          m2DevicePub,
          m2DevicePriv,
        );
        final asD2 = await endpoints.group.listMyGroups(
          sessionBuilder,
          challenge: outerD2.challenge,
          proofOfWork: outerD2.pow,
          signature: outerD2.signature,
          callerDeviceSigningPublicKeyHex: m2DevicePub,
        );
        expect(asD2, hasLength(1));
        expect(asD2.single.deviceEncryptedDataKey, equals('blob-for-d2'));
      },
    );

    test('listMyGroups: an ungranted device gets null, not an error', () async {
      // A device that has not been granted access to the membership
      // receives `deviceEncryptedDataKey == null` — that is the expected
      // state for a freshly-paired device, not an error. The member-level
      // blob (memberEncryptedDataKey) is still returned because that one
      // is identity-bound to the membership, not the device.
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

      final (siblingPriv, siblingPub) = SigningTestHelper.generateKeypair();
      await createTestDevice(
        sessionBuilder,
        anonAccountId: s.account.id!,
        deviceSigningPublicKeyHex: siblingPub,
      );

      final outer = await _outer(
        sessionBuilder,
        endpoints,
        'listMyGroups',
        siblingPub,
        siblingPriv,
      );
      final rows = await endpoints.group.listMyGroups(
        sessionBuilder,
        challenge: outer.challenge,
        proofOfWork: outer.pow,
        signature: outer.signature,
        callerDeviceSigningPublicKeyHex: siblingPub,
      );
      expect(rows, hasLength(1));
      expect(rows.single.deviceEncryptedDataKey, isNull);
      // Member-level blob is still present — that one is identity-bound
      // to the membership, not the device.
      expect(rows.single.memberEncryptedDataKey, isNotNull);
    });

    test('listMyGroups: a revoked device is rejected', () async {
      // Unit A creates this hole: the returned blob is now wrapped to the
      // CALLING device's own key, so a revoked device would otherwise
      // recover group data keys for every group it was ever granted.
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

      // Mark the creator's device as revoked.
      final revokeSession = (sessionBuilder as InternalTestSessionBuilder)
          .internalBuild(endpoint: 'test', method: 'revokeCreatorDevice');
      try {
        final creatorDevice = (await AccountDevice.db.findFirstRow(
          revokeSession,
          where: (t) => t.deviceSigningPublicKeyHex.equals(s.devicePub),
        ))!;
        await AccountDevice.db.updateRow(
          revokeSession,
          creatorDevice.copyWith(isRevoked: true, revokedAt: DateTime.now()),
        );
      } finally {
        await revokeSession.close();
      }

      final outer = await _outer(
        sessionBuilder,
        endpoints,
        'listMyGroups',
        s.devicePub,
        s.devicePriv,
      );
      await expectLater(
        endpoints.group.listMyGroups(
          sessionBuilder,
          challenge: outer.challenge,
          proofOfWork: outer.pow,
          signature: outer.signature,
          callerDeviceSigningPublicKeyHex: s.devicePub,
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

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

      // addedByAttestorPublicKeyHex/addedByAttestation are not part of
      // GroupMembershipView (Task 5) — verify attestation provenance
      // directly against the underlying GroupMember row instead.
      final verifySession = (sessionBuilder as InternalTestSessionBuilder)
          .internalBuild(endpoint: 'test', method: 'verifyCreatorMember');
      try {
        final memberRow = await GroupMember.db.findById(
          verifySession,
          memberships.single.memberId,
        );
        expect(memberRow, isNotNull);
        expect(
          memberRow!.addedByAttestorPublicKeyHex,
          equals(s.groupUltSigPub),
        );
        expect(memberRow.addedByAttestation, isNotNull);
      } finally {
        await verifySession.close();
      }
    });

    test(
      'createGroup rejects a member duo whose halves are the same key',
      () async {
        final (_, accUltPub) = SigningTestHelper.generateKeypair();
        final account = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: accUltPub,
          ultimateEncryptionPublicKeyHex: accUltPub,
        );
        final (devicePriv, devicePub) = SigningTestHelper.generateKeypair();
        await createTestDevice(
          sessionBuilder,
          anonAccountId: account.id!,
          deviceSigningPublicKeyHex: devicePub,
        );

        final (groupUltSigPriv, groupUltSigPub) =
            SigningTestHelper.generateKeypair();
        final (_, groupUltEnc) = SigningTestHelper.generateKeypair();
        // Same key pasted into both member duo slots — the distinctness
        // check in AnonAccountHelpers.validateKeyDuo must reject this.
        final (_, dup) = SigningTestHelper.generateKeypair();

        final outer = await _outer(
          sessionBuilder,
          endpoints,
          'createGroup',
          devicePub,
          devicePriv,
        );
        final innerPayload =
            'createGroup:$groupUltSigPub:$groupUltEnc:$dup:$dup';
        final attestation = SigningTestHelper.signWith(
          innerPayload,
          groupUltSigPriv,
        );

        await expectLater(
          endpoints.group.createGroup(
            sessionBuilder,
            challenge: outer.challenge,
            proofOfWork: outer.pow,
            signature: outer.signature,
            callerDeviceSigningPublicKeyHex: devicePub,
            groupUltimateKeys: PublicKeyDuo(
              signingPublicKeyHex: groupUltSigPub,
              encryptionPublicKeyHex: groupUltEnc,
            ),
            creatorMemberKeys: PublicKeyDuo(
              signingPublicKeyHex: dup,
              encryptionPublicKeyHex: dup,
            ),
            groupEncryptedDataKey: 'wrapped',
            creatorMemberEncryptedDataKey: 'wrapped',
            groupUltimateAttestation: attestation,
            creatorEncryptedMemberKey: 'wrapped-member-key',
            creatorEncryptedMemberKeyAttestation: 'irrelevant',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      },
    );

    test('createGroup rejected when group-ultimate attestation is bad', () async {
      final (_, accUltPub) = SigningTestHelper.generateKeypair();
      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: accUltPub,
        ultimateEncryptionPublicKeyHex: accUltPub,
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
      final badAttestation = SigningTestHelper.signWith(
        innerPayload,
        foreignPriv,
      );

      expect(
        () => endpoints.group.createGroup(
          sessionBuilder,
          challenge: outer.challenge,
          proofOfWork: outer.pow,
          signature: outer.signature,
          callerDeviceSigningPublicKeyHex: devicePub,
          groupUltimateKeys: PublicKeyDuo(
            signingPublicKeyHex: groupUltSigPub,
            encryptionPublicKeyHex: groupUltEnc,
          ),
          groupEncryptedDataKey: 'wrapped',
          creatorMemberKeys: PublicKeyDuo(
            signingPublicKeyHex: creatorMemberSigPub,
            encryptionPublicKeyHex: creatorMemberEnc,
          ),
          creatorMemberEncryptedDataKey: 'wrapped',
          groupUltimateAttestation: badAttestation,
          creatorEncryptedMemberKey: 'wrapped-member-key',
          creatorEncryptedMemberKeyAttestation: 'irrelevant',
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
        ultimateEncryptionPublicKeyHex: inviteeUltPub,
      );
      final (inviteeMemberPriv, inviteeMemberSig) =
          SigningTestHelper.generateKeypair();
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
      final innerSig = SigningTestHelper.signWith(
        innerPayload,
        s.creatorMemberSigPriv,
      );
      final backup = _memberKeyBackup(
        groupUltimateSigningPublicKeyHex: s.groupUltSigPub,
        anonAccountId: invitee.id!,
        memberSigningPublicKeyHex: inviteeMemberSig,
        memberSigningPrivateKeyHex: inviteeMemberPriv,
      );

      final member = await endpoints.group.addGroupMember(
        sessionBuilder,
        challenge: outer.challenge,
        proofOfWork: outer.pow,
        signature: outer.signature,
        callerDeviceSigningPublicKeyHex: s.devicePub,
        groupId: s.group.id!,
        newMemberAccountId: invitee.id!,
        role: role,
        memberKeys: PublicKeyDuo(
          signingPublicKeyHex: inviteeMemberSig,
          encryptionPublicKeyHex: inviteeMemberEnc,
        ),
        encryptedDataKey: 'wrapped-for-invitee',
        callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
        memberAuthSignature: innerSig,
        encryptedMemberKey: backup.blob,
        encryptedMemberKeyAttestation: backup.attestation,
      );
      expect(member.role, equals(GroupMemberRole.member));
      expect(member.addedByAttestorPublicKeyHex, equals(s.creatorMemberSigPub));
      expect(member.addedByAttestation, equals(innerSig));
    });

    test(
      'addGroupMember(role=member): rejected when caller is not admin',
      () async {
        final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

        // Add a regular member first, then have that member try to invite.
        final (_, m2UltPub) = SigningTestHelper.generateKeypair();
        final m2Account = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: m2UltPub,
          ultimateEncryptionPublicKeyHex: m2UltPub,
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
        final addSig = SigningTestHelper.signWith(
          addPayload,
          s.creatorMemberSigPriv,
        );
        final m2Backup = _memberKeyBackup(
          groupUltimateSigningPublicKeyHex: s.groupUltSigPub,
          anonAccountId: m2Account.id!,
          memberSigningPublicKeyHex: m2MemberPub,
          memberSigningPrivateKeyHex: m2MemberPriv,
        );
        await endpoints.group.addGroupMember(
          sessionBuilder,
          challenge: outerAdd.challenge,
          proofOfWork: outerAdd.pow,
          signature: outerAdd.signature,
          callerDeviceSigningPublicKeyHex: s.devicePub,
          groupId: s.group.id!,
          newMemberAccountId: m2Account.id!,
          role: GroupMemberRole.member,
          memberKeys: PublicKeyDuo(
            signingPublicKeyHex: m2MemberPub,
            encryptionPublicKeyHex: m2MemberEnc,
          ),
          encryptedDataKey: 'wrapped',
          callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
          memberAuthSignature: addSig,
          encryptedMemberKey: m2Backup.blob,
          encryptedMemberKeyAttestation: m2Backup.attestation,
        );

        // Now m2 (a non-admin member) tries to add an invitee.
        final (_, victimUltPub) = SigningTestHelper.generateKeypair();
        final victim = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: victimUltPub,
          ultimateEncryptionPublicKeyHex: victimUltPub,
        );
        final (vMemberPriv, vMemberSig) = SigningTestHelper.generateKeypair();
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
        final backup = _memberKeyBackup(
          groupUltimateSigningPublicKeyHex: s.groupUltSigPub,
          anonAccountId: victim.id!,
          memberSigningPublicKeyHex: vMemberSig,
          memberSigningPrivateKeyHex: vMemberPriv,
        );

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
            memberKeys: PublicKeyDuo(
              signingPublicKeyHex: vMemberSig,
              encryptionPublicKeyHex: vMemberEnc,
            ),
            encryptedDataKey: 'wrapped',
            callerMemberSigningPublicKeyHex: m2MemberPub,
            memberAuthSignature: innerSig,
            encryptedMemberKey: backup.blob,
            encryptedMemberKeyAttestation: backup.attestation,
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test(
      'addGroupMember(role=member): rejected on account-binding mismatch',
      () async {
        final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

        // A different account with its own device.
        final (_, otherUltPub) = SigningTestHelper.generateKeypair();
        final otherAccount = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: otherUltPub,
          ultimateEncryptionPublicKeyHex: otherUltPub,
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
          ultimateEncryptionPublicKeyHex: vUltPub,
        );
        final (vMemberPriv, vMemberSig) = SigningTestHelper.generateKeypair();
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
        final innerSig = SigningTestHelper.signWith(
          innerPayload,
          s.creatorMemberSigPriv,
        );
        final backup = _memberKeyBackup(
          groupUltimateSigningPublicKeyHex: s.groupUltSigPub,
          anonAccountId: victim.id!,
          memberSigningPublicKeyHex: vMemberSig,
          memberSigningPrivateKeyHex: vMemberPriv,
        );

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
            memberKeys: PublicKeyDuo(
              signingPublicKeyHex: vMemberSig,
              encryptionPublicKeyHex: vMemberEnc,
            ),
            encryptedDataKey: 'wrapped',
            callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
            memberAuthSignature: innerSig,
            encryptedMemberKey: backup.blob,
            encryptedMemberKeyAttestation: backup.attestation,
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('addGroupMember(role=admin): requires owner ultimate sig', () async {
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

      // Invitee account.
      final (_, inviteeUltPub) = SigningTestHelper.generateKeypair();
      final invitee = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: inviteeUltPub,
        ultimateEncryptionPublicKeyHex: inviteeUltPub,
      );
      final (inviteeMemberPriv, inviteeMemberSig) =
          SigningTestHelper.generateKeypair();
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
      final ownerSig = SigningTestHelper.signWith(
        innerPayload,
        s.groupUltSigPriv,
      );
      final backup = _memberKeyBackup(
        groupUltimateSigningPublicKeyHex: s.groupUltSigPub,
        anonAccountId: invitee.id!,
        memberSigningPublicKeyHex: inviteeMemberSig,
        memberSigningPrivateKeyHex: inviteeMemberPriv,
      );

      final member = await endpoints.group.addGroupMember(
        sessionBuilder,
        challenge: outer.challenge,
        proofOfWork: outer.pow,
        signature: outer.signature,
        callerDeviceSigningPublicKeyHex: s.devicePub,
        groupId: s.group.id!,
        newMemberAccountId: invitee.id!,
        role: GroupMemberRole.admin,
        memberKeys: PublicKeyDuo(
          signingPublicKeyHex: inviteeMemberSig,
          encryptionPublicKeyHex: inviteeMemberEnc,
        ),
        encryptedDataKey: 'wrapped',
        groupUltimateSignature: ownerSig,
        encryptedMemberKey: backup.blob,
        encryptedMemberKeyAttestation: backup.attestation,
      );
      expect(member.role, equals(GroupMemberRole.admin));
      expect(member.addedByAttestorPublicKeyHex, equals(s.groupUltSigPub));
    });

    test('addGroupMember(role=admin): rejected without owner sig', () async {
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

      final (_, inviteeUltPub) = SigningTestHelper.generateKeypair();
      final invitee = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: inviteeUltPub,
        ultimateEncryptionPublicKeyHex: inviteeUltPub,
      );
      final (inviteeMemberPriv, inviteeMemberSig) =
          SigningTestHelper.generateKeypair();
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
      final memberSig = SigningTestHelper.signWith(
        innerPayload,
        s.creatorMemberSigPriv,
      );
      final backup = _memberKeyBackup(
        groupUltimateSigningPublicKeyHex: s.groupUltSigPub,
        anonAccountId: invitee.id!,
        memberSigningPublicKeyHex: inviteeMemberSig,
        memberSigningPrivateKeyHex: inviteeMemberPriv,
      );

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
          memberKeys: PublicKeyDuo(
            signingPublicKeyHex: inviteeMemberSig,
            encryptionPublicKeyHex: inviteeMemberEnc,
          ),
          encryptedDataKey: 'wrapped',
          callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
          memberAuthSignature: memberSig,
          encryptedMemberKey: backup.blob,
          encryptedMemberKeyAttestation: backup.attestation,
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
        ultimateEncryptionPublicKeyHex: vUltPub,
      );
      final (vMemberPriv, vMemberSig) = SigningTestHelper.generateKeypair();
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
      final addSig = SigningTestHelper.signWith(
        addPayload,
        s.creatorMemberSigPriv,
      );
      final backup = _memberKeyBackup(
        groupUltimateSigningPublicKeyHex: s.groupUltSigPub,
        anonAccountId: victim.id!,
        memberSigningPublicKeyHex: vMemberSig,
        memberSigningPrivateKeyHex: vMemberPriv,
      );
      final victimRow = await endpoints.group.addGroupMember(
        sessionBuilder,
        challenge: outerAdd.challenge,
        proofOfWork: outerAdd.pow,
        signature: outerAdd.signature,
        callerDeviceSigningPublicKeyHex: s.devicePub,
        groupId: s.group.id!,
        newMemberAccountId: victim.id!,
        role: GroupMemberRole.member,
        memberKeys: PublicKeyDuo(
          signingPublicKeyHex: vMemberSig,
          encryptionPublicKeyHex: vMemberEnc,
        ),
        encryptedDataKey: 'wrapped',
        callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
        memberAuthSignature: addSig,
        encryptedMemberKey: backup.blob,
        encryptedMemberKeyAttestation: backup.attestation,
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
      final rmSig = SigningTestHelper.signWith(
        rmPayload,
        s.creatorMemberSigPriv,
      );

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
          after.revokedByAttestorPublicKeyHex,
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
        sessionBuilder,
        endpoints,
        'getGroup',
        s.devicePub,
        s.devicePriv,
      );
      final innerPayload = GroupInnerPayloads.getGroup(s.group.id!);
      final innerSig = SigningTestHelper.signWith(
        innerPayload,
        s.creatorMemberSigPriv,
      );

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
        sessionBuilder,
        endpoints,
        'getGroup',
        s.devicePub,
        s.devicePriv,
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

    test(
      'getGroup: rejected when caller is not a member of the group',
      () async {
        final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

        // A separate account with no membership.
        final (_, outsiderUltPub) = SigningTestHelper.generateKeypair();
        final outsider = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: outsiderUltPub,
          ultimateEncryptionPublicKeyHex: outsiderUltPub,
        );
        final (outsiderDevicePriv, outsiderDevicePub) =
            SigningTestHelper.generateKeypair();
        await createTestDevice(
          sessionBuilder,
          anonAccountId: outsider.id!,
          deviceSigningPublicKeyHex: outsiderDevicePub,
        );
        final (outsiderMemberPriv, outsiderMemberPub) =
            SigningTestHelper.generateKeypair();

        final outer = await _outer(
          sessionBuilder,
          endpoints,
          'getGroup',
          outsiderDevicePub,
          outsiderDevicePriv,
        );
        final innerPayload = GroupInnerPayloads.getGroup(s.group.id!);
        final innerSig = SigningTestHelper.signWith(
          innerPayload,
          outsiderMemberPriv,
        );

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
      },
    );

    test('listGroupMembers: returns active members only', () async {
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

      // Add a second member.
      final (_, m2UltPub) = SigningTestHelper.generateKeypair();
      final m2 = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: m2UltPub,
        ultimateEncryptionPublicKeyHex: m2UltPub,
      );
      final (m2MemberPriv, m2MemberSig) = SigningTestHelper.generateKeypair();
      final (_, m2MemberEnc) = SigningTestHelper.generateKeypair();

      final outerAdd = await _outer(
        sessionBuilder,
        endpoints,
        'addGroupMember',
        s.devicePub,
        s.devicePriv,
      );
      final addInner = GroupInnerPayloads.addGroupMember(
        s.group.id!,
        m2.id!,
        GroupMemberRole.member.name,
        PublicKeyDuo(
          signingPublicKeyHex: m2MemberSig,
          encryptionPublicKeyHex: m2MemberEnc,
        ),
      );
      final addSig = SigningTestHelper.signWith(
        addInner,
        s.creatorMemberSigPriv,
      );
      final backup = _memberKeyBackup(
        groupUltimateSigningPublicKeyHex: s.groupUltSigPub,
        anonAccountId: m2.id!,
        memberSigningPublicKeyHex: m2MemberSig,
        memberSigningPrivateKeyHex: m2MemberPriv,
      );
      await endpoints.group.addGroupMember(
        sessionBuilder,
        challenge: outerAdd.challenge,
        proofOfWork: outerAdd.pow,
        signature: outerAdd.signature,
        callerDeviceSigningPublicKeyHex: s.devicePub,
        groupId: s.group.id!,
        newMemberAccountId: m2.id!,
        role: GroupMemberRole.member,
        memberKeys: PublicKeyDuo(
          signingPublicKeyHex: m2MemberSig,
          encryptionPublicKeyHex: m2MemberEnc,
        ),
        encryptedDataKey: 'wrapped',
        callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
        memberAuthSignature: addSig,
        encryptedMemberKey: backup.blob,
        encryptedMemberKeyAttestation: backup.attestation,
      );

      final outer = await _outer(
        sessionBuilder,
        endpoints,
        'listGroupMembers',
        s.devicePub,
        s.devicePriv,
      );
      final innerPayload = GroupInnerPayloads.listGroupMembers(s.group.id!);
      final innerSig = SigningTestHelper.signWith(
        innerPayload,
        s.creatorMemberSigPriv,
      );

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
      // No isRevoked field on GroupMemberView — the query already filters to
      // active rows, and a hardcoded security flag on every row would be a
      // constant, worse than an absent one.
      final json = members.map((m) => m.toJson().keys).expand((k) => k).toSet();
      expect(json, isNot(contains('isRevoked')));
    });

    test('listGroupMembers: rejected when caller is not a member', () async {
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

      final (_, outsiderUltPub) = SigningTestHelper.generateKeypair();
      final outsider = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: outsiderUltPub,
        ultimateEncryptionPublicKeyHex: outsiderUltPub,
      );
      final (outsiderDevicePriv, outsiderDevicePub) =
          SigningTestHelper.generateKeypair();
      await createTestDevice(
        sessionBuilder,
        anonAccountId: outsider.id!,
        deviceSigningPublicKeyHex: outsiderDevicePub,
      );
      final (outsiderMemberPriv, outsiderMemberPub) =
          SigningTestHelper.generateKeypair();

      final outer = await _outer(
        sessionBuilder,
        endpoints,
        'listGroupMembers',
        outsiderDevicePub,
        outsiderDevicePriv,
      );
      final innerPayload = GroupInnerPayloads.listGroupMembers(s.group.id!);
      final innerSig = SigningTestHelper.signWith(
        innerPayload,
        outsiderMemberPriv,
      );

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

    test(
      'leaveGroup: member removes themselves, row is self-attested',
      () async {
        final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

        // Add a second member to leave.
        final (_, m2UltPub) = SigningTestHelper.generateKeypair();
        final m2 = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: m2UltPub,
          ultimateEncryptionPublicKeyHex: m2UltPub,
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
          sessionBuilder,
          endpoints,
          'addGroupMember',
          s.devicePub,
          s.devicePriv,
        );
        final addInner = GroupInnerPayloads.addGroupMember(
          s.group.id!,
          m2.id!,
          GroupMemberRole.member.name,
          PublicKeyDuo(
            signingPublicKeyHex: m2MemberPub,
            encryptionPublicKeyHex: m2MemberEnc,
          ),
        );
        final addSig = SigningTestHelper.signWith(
          addInner,
          s.creatorMemberSigPriv,
        );
        final backup = _memberKeyBackup(
          groupUltimateSigningPublicKeyHex: s.groupUltSigPub,
          anonAccountId: m2.id!,
          memberSigningPublicKeyHex: m2MemberPub,
          memberSigningPrivateKeyHex: m2MemberPriv,
        );
        final m2Row = await endpoints.group.addGroupMember(
          sessionBuilder,
          challenge: outerAdd.challenge,
          proofOfWork: outerAdd.pow,
          signature: outerAdd.signature,
          callerDeviceSigningPublicKeyHex: s.devicePub,
          groupId: s.group.id!,
          newMemberAccountId: m2.id!,
          role: GroupMemberRole.member,
          memberKeys: PublicKeyDuo(
            signingPublicKeyHex: m2MemberPub,
            encryptionPublicKeyHex: m2MemberEnc,
          ),
          encryptedDataKey: 'wrapped',
          callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
          memberAuthSignature: addSig,
          encryptedMemberKey: backup.blob,
          encryptedMemberKeyAttestation: backup.attestation,
        );

        // m2 leaves.
        final outer = await _outer(
          sessionBuilder,
          endpoints,
          'leaveGroup',
          m2DevicePub,
          m2DevicePriv,
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
          expect(after.revokedByAttestorPublicKeyHex, equals(m2MemberPub));
          expect(after.revokedByAttestation, equals(innerSig));
        } finally {
          await dbSession.close();
        }

        // Group still exists — creator is still an admin.
        final dbSession2 = (sessionBuilder as InternalTestSessionBuilder)
            .internalBuild(endpoint: 'test', method: 'verify');
        try {
          final groupAfter = await ShareGroup.db.findById(
            dbSession2,
            s.group.id!,
          );
          expect(groupAfter, isNotNull);
        } finally {
          await dbSession2.close();
        }
      },
    );

    test(
      'leaveGroup: last admin with other members present cannot leave (guard blocks)',
      () async {
        final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

        // Add a second (plain) member so the creator's admin seat is the sole
        // admin while the group is non-empty otherwise.
        final (_, m2UltPub) = SigningTestHelper.generateKeypair();
        final m2 = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: m2UltPub,
          ultimateEncryptionPublicKeyHex: m2UltPub,
        );
        final (_, m2DevicePub) = SigningTestHelper.generateKeypair();
        await createTestDevice(
          sessionBuilder,
          anonAccountId: m2.id!,
          deviceSigningPublicKeyHex: m2DevicePub,
        );
        final (m2MemberPriv, m2MemberPub) = SigningTestHelper.generateKeypair();
        final (_, m2MemberEnc) = SigningTestHelper.generateKeypair();

        final outerAdd = await _outer(
          sessionBuilder,
          endpoints,
          'addGroupMember',
          s.devicePub,
          s.devicePriv,
        );
        final addInner = GroupInnerPayloads.addGroupMember(
          s.group.id!,
          m2.id!,
          GroupMemberRole.member.name,
          PublicKeyDuo(
            signingPublicKeyHex: m2MemberPub,
            encryptionPublicKeyHex: m2MemberEnc,
          ),
        );
        final addSig = SigningTestHelper.signWith(
          addInner,
          s.creatorMemberSigPriv,
        );
        final backup = _memberKeyBackup(
          groupUltimateSigningPublicKeyHex: s.groupUltSigPub,
          anonAccountId: m2.id!,
          memberSigningPublicKeyHex: m2MemberPub,
          memberSigningPrivateKeyHex: m2MemberPriv,
        );
        await endpoints.group.addGroupMember(
          sessionBuilder,
          challenge: outerAdd.challenge,
          proofOfWork: outerAdd.pow,
          signature: outerAdd.signature,
          callerDeviceSigningPublicKeyHex: s.devicePub,
          groupId: s.group.id!,
          newMemberAccountId: m2.id!,
          role: GroupMemberRole.member,
          memberKeys: PublicKeyDuo(
            signingPublicKeyHex: m2MemberPub,
            encryptionPublicKeyHex: m2MemberEnc,
          ),
          encryptedDataKey: 'wrapped',
          callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
          memberAuthSignature: addSig,
          encryptedMemberKey: backup.blob,
          encryptedMemberKeyAttestation: backup.attestation,
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
          sessionBuilder,
          endpoints,
          'leaveGroup',
          s.devicePub,
          s.devicePriv,
        );
        final innerPayload = GroupInnerPayloads.leaveGroup(creatorRow.id!);
        final innerSig = SigningTestHelper.signWith(
          innerPayload,
          s.creatorMemberSigPriv,
        );

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
          final groupAfter = await ShareGroup.db.findById(
            dbSession,
            s.group.id!,
          );
          expect(groupAfter, isNotNull);
          final creatorAfter = await GroupMember.db.findById(
            dbSession,
            creatorRow.id!,
          );
          expect(creatorAfter!.isRevoked, isFalse);
        } finally {
          await dbSession.close();
        }
      },
    );

    test(
      'concurrent two-admin leaveGroup: exactly one wins, state stays consistent',
      () async {},
      skip:
          'The serverpod_test harness (RollbackDatabase.afterEach by default) '
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

    test(
      'leaveGroup: last admin leaving deletes the group and all members',
      () async {
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
          sessionBuilder,
          endpoints,
          'leaveGroup',
          s.devicePub,
          s.devicePriv,
        );
        final innerPayload = GroupInnerPayloads.leaveGroup(creatorRow.id!);
        final innerSig = SigningTestHelper.signWith(
          innerPayload,
          s.creatorMemberSigPriv,
        );

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
          final groupAfter = await ShareGroup.db.findById(
            dbSession,
            s.group.id!,
          );
          expect(groupAfter, isNull);
        } finally {
          await dbSession.close();
        }
      },
    );

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
        sessionBuilder,
        endpoints,
        'leaveGroup',
        s.devicePub,
        s.devicePriv,
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
      final challengeResp = await endpoints.entrypoint.getChallenge(
        sessionBuilder,
      );
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

      expect(() async => await stream.first, throwsA(isA<Exception>()));
    });

    test(
      'monitorGroupMembership: opens without throwing for valid device',
      () async {
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
      },
    );

    test(
      'removeGroupMember: rejected when removing an admin without owner sig',
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
        final memberSig = SigningTestHelper.signWith(
          innerPayload,
          s.creatorMemberSigPriv,
        );

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
      },
    );

    test('addGroupMember: a revoked caller device is rejected', () async {
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);
      final (_, ultimatePub) = SigningTestHelper.generateKeypair();
      final invitee = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: ultimatePub,
        ultimateEncryptionPublicKeyHex: ultimatePub,
      );
      final (memberPriv, memberPub) = SigningTestHelper.generateKeypair();
      final (_, memberEnc) = SigningTestHelper.generateKeypair();
      final backup = _memberKeyBackup(
        groupUltimateSigningPublicKeyHex: s.groupUltSigPub,
        anonAccountId: invitee.id!,
        memberSigningPublicKeyHex: memberPub,
        memberSigningPrivateKeyHex: memberPriv,
      );
      final outer = await _outer(
        sessionBuilder,
        endpoints,
        'addGroupMember',
        s.devicePub,
        s.devicePriv,
      );
      final innerSig = SigningTestHelper.signWith(
        GroupInnerPayloads.addGroupMember(
          s.group.id!,
          invitee.id!,
          GroupMemberRole.member.name,
          PublicKeyDuo(
            signingPublicKeyHex: memberPub,
            encryptionPublicKeyHex: memberEnc,
          ),
        ),
        s.creatorMemberSigPriv,
      );
      await RevocationTestHelper.revokeDevice(sessionBuilder, s.devicePub);

      await expectLater(
        endpoints.group.addGroupMember(
          sessionBuilder,
          challenge: outer.challenge,
          proofOfWork: outer.pow,
          signature: outer.signature,
          callerDeviceSigningPublicKeyHex: s.devicePub,
          groupId: s.group.id!,
          newMemberAccountId: invitee.id!,
          role: GroupMemberRole.member,
          memberKeys: PublicKeyDuo(
            signingPublicKeyHex: memberPub,
            encryptionPublicKeyHex: memberEnc,
          ),
          encryptedDataKey: 'wrapped',
          encryptedMemberKey: backup.blob,
          encryptedMemberKeyAttestation: backup.attestation,
          callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
          memberAuthSignature: innerSig,
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('removeGroupMember: a revoked caller device is rejected', () async {
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);
      final (_, ultimatePub) = SigningTestHelper.generateKeypair();
      final victim = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: ultimatePub,
        ultimateEncryptionPublicKeyHex: ultimatePub,
      );
      final (memberPriv, memberPub) = SigningTestHelper.generateKeypair();
      final (_, memberEnc) = SigningTestHelper.generateKeypair();
      final backup = _memberKeyBackup(
        groupUltimateSigningPublicKeyHex: s.groupUltSigPub,
        anonAccountId: victim.id!,
        memberSigningPublicKeyHex: memberPub,
        memberSigningPrivateKeyHex: memberPriv,
      );
      final addOuter = await _outer(
        sessionBuilder,
        endpoints,
        'addGroupMember',
        s.devicePub,
        s.devicePriv,
      );
      final addSig = SigningTestHelper.signWith(
        GroupInnerPayloads.addGroupMember(
          s.group.id!,
          victim.id!,
          GroupMemberRole.member.name,
          PublicKeyDuo(
            signingPublicKeyHex: memberPub,
            encryptionPublicKeyHex: memberEnc,
          ),
        ),
        s.creatorMemberSigPriv,
      );
      final added = await endpoints.group.addGroupMember(
        sessionBuilder,
        challenge: addOuter.challenge,
        proofOfWork: addOuter.pow,
        signature: addOuter.signature,
        callerDeviceSigningPublicKeyHex: s.devicePub,
        groupId: s.group.id!,
        newMemberAccountId: victim.id!,
        role: GroupMemberRole.member,
        memberKeys: PublicKeyDuo(
          signingPublicKeyHex: memberPub,
          encryptionPublicKeyHex: memberEnc,
        ),
        encryptedDataKey: 'wrapped',
        encryptedMemberKey: backup.blob,
        encryptedMemberKeyAttestation: backup.attestation,
        callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
        memberAuthSignature: addSig,
      );
      await RevocationTestHelper.revokeDevice(sessionBuilder, s.devicePub);
      final removeOuter = await _outer(
        sessionBuilder,
        endpoints,
        'removeGroupMember',
        s.devicePub,
        s.devicePriv,
      );
      final removeSig = SigningTestHelper.signWith(
        'removeGroupMember:${added.id!}',
        s.creatorMemberSigPriv,
      );

      await expectLater(
        endpoints.group.removeGroupMember(
          sessionBuilder,
          challenge: removeOuter.challenge,
          proofOfWork: removeOuter.pow,
          signature: removeOuter.signature,
          callerDeviceSigningPublicKeyHex: s.devicePub,
          memberId: added.id!,
          callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
          memberAuthSignature: removeSig,
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('getGroup: a revoked caller device is rejected', () async {
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);
      await RevocationTestHelper.revokeDevice(sessionBuilder, s.devicePub);
      final outer = await _outer(
        sessionBuilder,
        endpoints,
        'getGroup',
        s.devicePub,
        s.devicePriv,
      );
      final innerSig = SigningTestHelper.signWith(
        GroupInnerPayloads.getGroup(s.group.id!),
        s.creatorMemberSigPriv,
      );

      await expectLater(
        endpoints.group.getGroup(
          sessionBuilder,
          challenge: outer.challenge,
          proofOfWork: outer.pow,
          signature: outer.signature,
          callerDeviceSigningPublicKeyHex: s.devicePub,
          groupId: s.group.id!,
          callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
          memberAuthSignature: innerSig,
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('listGroupMembers: a revoked caller device is rejected', () async {
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);
      await RevocationTestHelper.revokeDevice(sessionBuilder, s.devicePub);
      final outer = await _outer(
        sessionBuilder,
        endpoints,
        'listGroupMembers',
        s.devicePub,
        s.devicePriv,
      );
      final innerSig = SigningTestHelper.signWith(
        GroupInnerPayloads.listGroupMembers(s.group.id!),
        s.creatorMemberSigPriv,
      );

      await expectLater(
        endpoints.group.listGroupMembers(
          sessionBuilder,
          challenge: outer.challenge,
          proofOfWork: outer.pow,
          signature: outer.signature,
          callerDeviceSigningPublicKeyHex: s.devicePub,
          groupId: s.group.id!,
          callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
          memberAuthSignature: innerSig,
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('leaveGroup: a revoked caller device is rejected', () async {
      final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);
      final session = (sessionBuilder as InternalTestSessionBuilder)
          .internalBuild(endpoint: 'test', method: 'findCreator');
      late GroupMember creator;
      try {
        creator = (await GroupMember.db.findFirstRow(
          session,
          where: (t) =>
              t.shareGroupId.equals(s.group.id!) &
              t.memberSigningPublicKeyHex.equals(s.creatorMemberSigPub),
        ))!;
      } finally {
        await session.close();
      }
      await RevocationTestHelper.revokeDevice(sessionBuilder, s.devicePub);
      final outer = await _outer(
        sessionBuilder,
        endpoints,
        'leaveGroup',
        s.devicePub,
        s.devicePriv,
      );
      final innerSig = SigningTestHelper.signWith(
        GroupInnerPayloads.leaveGroup(creator.id!),
        s.creatorMemberSigPriv,
      );

      await expectLater(
        endpoints.group.leaveGroup(
          sessionBuilder,
          challenge: outer.challenge,
          proofOfWork: outer.pow,
          signature: outer.signature,
          callerDeviceSigningPublicKeyHex: s.devicePub,
          memberId: creator.id!,
          memberSigningPublicKeyHex: s.creatorMemberSigPub,
          memberAuthSignature: innerSig,
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });
  });
}
