import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod/serverpod.dart';
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
  });
}
