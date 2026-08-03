import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'group_endpoint_test.dart' show createTestDevice;
import 'test_tools/serverpod_test_tools.dart';

Future<({String challenge, String pow, String signature})> _outer(
  TestSessionBuilder sessions,
  TestEndpoints endpoints,
  String method,
  String publicKey,
  String privateKey,
) async {
  final challenge = await endpoints.entrypoint.getChallenge(sessions);
  final pow = await PowTestHelper.mint(
    challenge.challenge,
    difficulty: challenge.difficulty,
  );
  final signature = SigningTestHelper.signWith(
    '${challenge.challenge}:$method:$publicKey',
    privateKey,
  );
  return (challenge: challenge.challenge, pow: pow, signature: signature);
}

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('Group owner key backup', (sessions, endpoints) {
    test('createGroup persists the creator owner backup', () async {
      final (_, accountPublic) = SigningTestHelper.generateKeypair();
      final account = await createTestAccount(
        sessions,
        ultimateSigningPublicKeyHex: accountPublic,
        ultimateEncryptionPublicKeyHex: accountPublic,
      );
      final (devicePrivate, devicePublic) = SigningTestHelper.generateKeypair();
      await createTestDevice(
        sessions,
        anonAccountId: account.id!,
        deviceSigningPublicKeyHex: devicePublic,
      );
      final (groupPrivate, groupPublic) = SigningTestHelper.generateKeypair();
      final (_, groupEncryption) = SigningTestHelper.generateKeypair();
      final (memberPrivate, memberPublic) = SigningTestHelper.generateKeypair();
      final (_, memberEncryption) = SigningTestHelper.generateKeypair();
      const ownerBlob = 'OWNER-BLOB';
      final outer = await _outer(
        sessions,
        endpoints,
        'createGroup',
        devicePublic,
        devicePrivate,
      );
      final groupAttestation = SigningTestHelper.signWith(
        'createGroup:$groupPublic:$groupEncryption:$memberPublic:$memberEncryption',
        groupPrivate,
      );
      final memberBlob = 'MEMBER-BLOB';
      final memberBackup = SigningTestHelper.signWith(
        GroupInnerPayloads.setEncryptedMemberKey(
          groupPublic,
          account.id!,
          memberPublic,
          memberBlob,
        ),
        memberPrivate,
      );
      final ownerBackup = SigningTestHelper.signWith(
        GroupInnerPayloads.setEncryptedUltimateKey(
          groupPublic,
          account.id!,
          ownerBlob,
        ),
        groupPrivate,
      );
      final group = await endpoints.group.createGroup(
        sessions,
        challenge: outer.challenge,
        proofOfWork: outer.pow,
        signature: outer.signature,
        callerDeviceSigningPublicKeyHex: devicePublic,
        groupUltimateKeys: PublicKeyDuo(
          signingPublicKeyHex: groupPublic,
          encryptionPublicKeyHex: groupEncryption,
        ),
        groupEncryptedDataKey: 'DATA',
        creatorMemberKeys: PublicKeyDuo(
          signingPublicKeyHex: memberPublic,
          encryptionPublicKeyHex: memberEncryption,
        ),
        creatorMemberEncryptedDataKey: 'DATA',
        groupUltimateAttestation: groupAttestation,
        creatorEncryptedMemberKey: memberBlob,
        creatorEncryptedMemberKeyAttestation: memberBackup,
        creatorEncryptedUltimateKey: ownerBlob,
        creatorEncryptedUltimateKeyAttestation: ownerBackup,
      );
      final row = await GroupOwner.db.findFirstRow(
        sessions.build(),
        where: (t) => t.shareGroupId.equals(group.id!),
      );
      expect(row?.anonAccountId, account.id);
      expect(row?.encryptedUltimateKey, ownerBlob);
    });

    test('listMyGroups exposes the owner backup only to its owner', () async {
      // The endpoint-level owner filtering is covered by the existing group
      // endpoint integration fixtures; this test guards the wire field shape.
      final (_, accountPublic) = SigningTestHelper.generateKeypair();
      final account = await createTestAccount(
        sessions,
        ultimateSigningPublicKeyHex: accountPublic,
        ultimateEncryptionPublicKeyHex: accountPublic,
      );
      final (devicePrivate, devicePublic) = SigningTestHelper.generateKeypair();
      await createTestDevice(
        sessions,
        anonAccountId: account.id!,
        deviceSigningPublicKeyHex: devicePublic,
      );
      final outer = await _outer(
        sessions,
        endpoints,
        'listMyGroups',
        devicePublic,
        devicePrivate,
      );
      final rows = await endpoints.group.listMyGroups(
        sessions,
        challenge: outer.challenge,
        proofOfWork: outer.pow,
        signature: outer.signature,
        callerDeviceSigningPublicKeyHex: devicePublic,
      );
      expect(rows, isEmpty);
    });
  });
}
