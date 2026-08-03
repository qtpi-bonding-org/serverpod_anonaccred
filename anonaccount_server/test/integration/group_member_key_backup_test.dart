import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'group_endpoint_test.dart' show createTestDevice;
import 'test_tools/serverpod_test_tools.dart';

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

/// Creates an account, device, and group, all with a valid backup at
/// createGroup time. Task 4's tests need an existing group to invite into;
/// they don't exercise createGroup itself, so any valid backup suffices.
Future<
    ({
      String devicePriv,
      String devicePub,
      ShareGroup group,
      String groupUltSigPub,
      String creatorMemberPriv,
      String creatorMemberPub,
    })> _bootstrapGroup(
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

  final (groupUltSigPriv, groupUltSigPub) =
      SigningTestHelper.generateKeypair();
  final (_, groupUltEnc) = SigningTestHelper.generateKeypair();
  final (creatorMemberPriv, creatorMemberPub) =
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
      'createGroup:$groupUltSigPub:$groupUltEnc:$creatorMemberPub:$creatorMemberEnc';
  final groupAttestation =
      SigningTestHelper.signWith(innerPayload, groupUltSigPriv);
  final backupAttestation = SigningTestHelper.signWith(
    GroupInnerPayloads.setEncryptedMemberKey(
      groupUltSigPub,
      account.id!,
      creatorMemberPub,
      'CREATOR-BLOB',
    ),
    creatorMemberPriv,
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
      signingPublicKeyHex: creatorMemberPub,
      encryptionPublicKeyHex: creatorMemberEnc,
    ),
    creatorMemberEncryptedDataKey: 'wrapped',
    groupUltimateAttestation: groupAttestation,
    creatorEncryptedMemberKey: 'CREATOR-BLOB',
    creatorEncryptedMemberKeyAttestation: backupAttestation,
  );

  return (
    devicePriv: devicePriv,
    devicePub: devicePub,
    group: group,
    groupUltSigPub: groupUltSigPub,
    creatorMemberPriv: creatorMemberPriv,
    creatorMemberPub: creatorMemberPub,
  );
}

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('Group member key backup', (sessionBuilder, endpoints) {
    test('createGroup persists the creator member key backup', () async {
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
      final (creatorMemberPriv, creatorMemberPub) =
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
          'createGroup:$groupUltSigPub:$groupUltEnc:$creatorMemberPub:$creatorMemberEnc';
      final groupAttestation =
          SigningTestHelper.signWith(innerPayload, groupUltSigPriv);

      final blob = 'CREATOR-BLOB';
      final backupAttestation = SigningTestHelper.signWith(
        GroupInnerPayloads.setEncryptedMemberKey(
          groupUltSigPub,
          account.id!,
          creatorMemberPub,
          blob,
        ),
        creatorMemberPriv,
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
          signingPublicKeyHex: creatorMemberPub,
          encryptionPublicKeyHex: creatorMemberEnc,
        ),
        creatorMemberEncryptedDataKey: 'wrapped',
        groupUltimateAttestation: groupAttestation,
        creatorEncryptedMemberKey: blob,
        creatorEncryptedMemberKeyAttestation: backupAttestation,
      );

      final row = await GroupMember.db.findFirstRow(
        sessionBuilder.build(),
        where: (t) => t.shareGroupId.equals(group.id!),
      );
      expect(row!.encryptedMemberKey, blob);
    });

    test('createGroup rejects a backup not signed by the creator member key',
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
      final (_, creatorMemberPub) = SigningTestHelper.generateKeypair();
      final (_, creatorMemberEnc) = SigningTestHelper.generateKeypair();
      final (wrongPriv, _) = SigningTestHelper.generateKeypair();

      final outer = await _outer(
        sessionBuilder,
        endpoints,
        'createGroup',
        devicePub,
        devicePriv,
      );
      final innerPayload =
          'createGroup:$groupUltSigPub:$groupUltEnc:$creatorMemberPub:$creatorMemberEnc';
      final groupAttestation =
          SigningTestHelper.signWith(innerPayload, groupUltSigPriv);

      // Signed by a key that is not the creator member key.
      final backupAttestation = SigningTestHelper.signWith(
        GroupInnerPayloads.setEncryptedMemberKey(
          groupUltSigPub,
          account.id!,
          creatorMemberPub,
          'CREATOR-BLOB',
        ),
        wrongPriv,
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
          groupEncryptedDataKey: 'wrapped',
          creatorMemberKeys: PublicKeyDuo(
            signingPublicKeyHex: creatorMemberPub,
            encryptionPublicKeyHex: creatorMemberEnc,
          ),
          creatorMemberEncryptedDataKey: 'wrapped',
          groupUltimateAttestation: groupAttestation,
          creatorEncryptedMemberKey: 'CREATOR-BLOB',
          creatorEncryptedMemberKeyAttestation: backupAttestation,
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('addGroupMember persists the invitee backup the admin relayed',
        () async {
      final s = await _bootstrapGroup(sessionBuilder, endpoints);

      final (_, inviteeUltPub) = SigningTestHelper.generateKeypair();
      final invitee = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: inviteeUltPub,
        ultimateEncryptionPublicKeyHex: inviteeUltPub,
      );
      final (inviteeMemberPriv, inviteeMemberPub) =
          SigningTestHelper.generateKeypair();
      final (_, inviteeMemberEnc) = SigningTestHelper.generateKeypair();

      final outer = await _outer(
        sessionBuilder,
        endpoints,
        'addGroupMember',
        s.devicePub,
        s.devicePriv,
      );
      final innerPayload = GroupInnerPayloads.addGroupMember(
        s.group.id!,
        invitee.id!,
        GroupMemberRole.member.name,
        PublicKeyDuo(
          signingPublicKeyHex: inviteeMemberPub,
          encryptionPublicKeyHex: inviteeMemberEnc,
        ),
      );
      final innerSig =
          SigningTestHelper.signWith(innerPayload, s.creatorMemberPriv);

      final blob = 'INVITEE-BLOB';
      final backupAttestation = SigningTestHelper.signWith(
        GroupInnerPayloads.setEncryptedMemberKey(
          s.groupUltSigPub,
          invitee.id!,
          inviteeMemberPub,
          blob,
        ),
        inviteeMemberPriv,
      );

      final row = await endpoints.group.addGroupMember(
        sessionBuilder,
        challenge: outer.challenge,
        proofOfWork: outer.pow,
        signature: outer.signature,
        callerDeviceSigningPublicKeyHex: s.devicePub,
        groupId: s.group.id!,
        newMemberAccountId: invitee.id!,
        role: GroupMemberRole.member,
        memberKeys: PublicKeyDuo(
          signingPublicKeyHex: inviteeMemberPub,
          encryptionPublicKeyHex: inviteeMemberEnc,
        ),
        encryptedDataKey: 'wrapped',
        callerMemberSigningPublicKeyHex: s.creatorMemberPub,
        memberAuthSignature: innerSig,
        encryptedMemberKey: blob,
        encryptedMemberKeyAttestation: backupAttestation,
      );

      expect(row.encryptedMemberKey, blob);
    });

    test('a relaying admin cannot substitute a different backup', () async {
      final s = await _bootstrapGroup(sessionBuilder, endpoints);

      final (_, inviteeUltPub) = SigningTestHelper.generateKeypair();
      final invitee = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: inviteeUltPub,
        ultimateEncryptionPublicKeyHex: inviteeUltPub,
      );
      final (inviteeMemberPriv, inviteeMemberPub) =
          SigningTestHelper.generateKeypair();
      final (_, inviteeMemberEnc) = SigningTestHelper.generateKeypair();

      final outer = await _outer(
        sessionBuilder,
        endpoints,
        'addGroupMember',
        s.devicePub,
        s.devicePriv,
      );
      final innerPayload = GroupInnerPayloads.addGroupMember(
        s.group.id!,
        invitee.id!,
        GroupMemberRole.member.name,
        PublicKeyDuo(
          signingPublicKeyHex: inviteeMemberPub,
          encryptionPublicKeyHex: inviteeMemberEnc,
        ),
      );
      final innerSig =
          SigningTestHelper.signWith(innerPayload, s.creatorMemberPriv);

      // Signature is over the invitee's real blob; the admin sends another.
      final backupAttestation = SigningTestHelper.signWith(
        GroupInnerPayloads.setEncryptedMemberKey(
          s.groupUltSigPub,
          invitee.id!,
          inviteeMemberPub,
          'INVITEE-BLOB',
        ),
        inviteeMemberPriv,
      );

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
            signingPublicKeyHex: inviteeMemberPub,
            encryptionPublicKeyHex: inviteeMemberEnc,
          ),
          encryptedDataKey: 'wrapped',
          callerMemberSigningPublicKeyHex: s.creatorMemberPub,
          memberAuthSignature: innerSig,
          encryptedMemberKey: 'ADMIN-SUBSTITUTED-BLOB',
          encryptedMemberKeyAttestation: backupAttestation,
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('the admin member key cannot authorize the invitee backup',
        () async {
      final s = await _bootstrapGroup(sessionBuilder, endpoints);

      final (_, inviteeUltPub) = SigningTestHelper.generateKeypair();
      final invitee = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: inviteeUltPub,
        ultimateEncryptionPublicKeyHex: inviteeUltPub,
      );
      final (_, inviteeMemberPub) = SigningTestHelper.generateKeypair();
      final (_, inviteeMemberEnc) = SigningTestHelper.generateKeypair();

      final outer = await _outer(
        sessionBuilder,
        endpoints,
        'addGroupMember',
        s.devicePub,
        s.devicePriv,
      );
      final innerPayload = GroupInnerPayloads.addGroupMember(
        s.group.id!,
        invitee.id!,
        GroupMemberRole.member.name,
        PublicKeyDuo(
          signingPublicKeyHex: inviteeMemberPub,
          encryptionPublicKeyHex: inviteeMemberEnc,
        ),
      );
      final innerSig =
          SigningTestHelper.signWith(innerPayload, s.creatorMemberPriv);

      // Signed by the ADMIN's member key, not the invitee's.
      final backupAttestation = SigningTestHelper.signWith(
        GroupInnerPayloads.setEncryptedMemberKey(
          s.groupUltSigPub,
          invitee.id!,
          inviteeMemberPub,
          'INVITEE-BLOB',
        ),
        s.creatorMemberPriv,
      );

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
            signingPublicKeyHex: inviteeMemberPub,
            encryptionPublicKeyHex: inviteeMemberEnc,
          ),
          encryptedDataKey: 'wrapped',
          callerMemberSigningPublicKeyHex: s.creatorMemberPub,
          memberAuthSignature: innerSig,
          encryptedMemberKey: 'INVITEE-BLOB',
          encryptedMemberKeyAttestation: backupAttestation,
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });
  });
}
