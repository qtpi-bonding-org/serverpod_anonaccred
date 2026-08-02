import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'test_tools/serverpod_test_tools.dart';

/// Local fixture helper — `createTestDevice` is a file-private function in
/// `group_endpoint_test.dart`, so we replicate its pattern here.
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
      addedBySignerPublicKeyHex: deviceSigningPublicKeyHex,
      addedByAttestation: 'test-attestation',
      lastActive: DateTime.now(),
      isRevoked: false,
    );
    return await AccountDevice.db.insertRow(session, device);
  } finally {
    await session.close();
  }
}

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('GroupMemberDevice schema', (sessionBuilder, endpoints) {
    test('a grant row round-trips and defaults to not revoked', () async {
      final session = sessionBuilder.build();

      // Bootstrap a membership row directly via DB so we have its id and
      // memberSigningPublicKeyHex available without going through the full
      // PoW-signed endpoint chain — the schema invariant under test is the
      // row itself, not the createGroup flow.
      final lookupSession =
          (sessionBuilder as InternalTestSessionBuilder).internalBuild(
        endpoint: 'test',
        method: 'lookupCreator',
      );
      late final GroupMember member;
      late final AccountDevice device;
      try {
        final (_, accUltPub) = SigningTestHelper.generateKeypair();
        final account = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: accUltPub,
          ultimateEncryptionPublicKeyHex: accUltPub,
        );
        final (_, devicePub) = SigningTestHelper.generateKeypair();
        device = await createTestDevice(
          sessionBuilder,
          anonAccountId: account.id!,
          deviceSigningPublicKeyHex: devicePub,
        );
        final (_, groupUltSigPub) = SigningTestHelper.generateKeypair();
        final (_, groupUltEnc) = SigningTestHelper.generateKeypair();
        final (_, creatorMemberSigPub) = SigningTestHelper.generateKeypair();
        final (_, creatorMemberEnc) = SigningTestHelper.generateKeypair();

        final group = await ShareGroup.db.insertRow(
          lookupSession,
          ShareGroup(
            ultimateSigningPublicKeyHex: groupUltSigPub,
            ultimateEncryptionPublicKeyHex: groupUltEnc,
            encryptedDataKey: 'wrapped',
          ),
        );
        member = await GroupMember.db.insertRow(
          lookupSession,
          GroupMember(
            shareGroupId: group.id!,
            anonAccountId: account.id!,
            role: GroupMemberRole.admin,
            memberSigningPublicKeyHex: creatorMemberSigPub,
            memberEncryptionPublicKeyHex: creatorMemberEnc,
            encryptedDataKey: 'wrapped',
            addedBySignerPublicKeyHex: groupUltSigPub,
            addedByAttestation: 'sig',
          ),
        );
      } finally {
        await lookupSession.close();
      }

      final row = await GroupMemberDevice.db.insertRow(
        session,
        GroupMemberDevice(
          groupMemberId: member.id!,
          accountDeviceId: device.id!,
          encryptedDataKey: 'wrapped-to-device',
          addedBySignerPublicKeyHex: member.memberSigningPublicKeyHex,
          addedByAttestation: 'sig',
        ),
      );

      expect(row.isRevoked, isFalse);
      expect(row.revokedAt, isNull);
      expect(row.createdAt, isNotNull);
      expect(row.encryptedDataKey, equals('wrapped-to-device'));
      expect(
        row.addedBySignerPublicKeyHex,
        equals(member.memberSigningPublicKeyHex),
      );
    });

    test('the unique index is partial: a revoked pair can be re-granted',
        () async {
      final session = sessionBuilder.build();

      final lookupSession =
          (sessionBuilder as InternalTestSessionBuilder).internalBuild(
        endpoint: 'test',
        method: 'lookupCreator',
      );
      late final GroupMember member;
      late final AccountDevice device;
      try {
        final (_, accUltPub) = SigningTestHelper.generateKeypair();
        final account = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: accUltPub,
          ultimateEncryptionPublicKeyHex: accUltPub,
        );
        final (_, devicePub) = SigningTestHelper.generateKeypair();
        device = await createTestDevice(
          sessionBuilder,
          anonAccountId: account.id!,
          deviceSigningPublicKeyHex: devicePub,
        );
        final (_, groupUltSigPub) = SigningTestHelper.generateKeypair();
        final (_, groupUltEnc) = SigningTestHelper.generateKeypair();
        final (_, creatorMemberSigPub) = SigningTestHelper.generateKeypair();
        final (_, creatorMemberEnc) = SigningTestHelper.generateKeypair();

        final group = await ShareGroup.db.insertRow(
          lookupSession,
          ShareGroup(
            ultimateSigningPublicKeyHex: groupUltSigPub,
            ultimateEncryptionPublicKeyHex: groupUltEnc,
            encryptedDataKey: 'wrapped',
          ),
        );
        member = await GroupMember.db.insertRow(
          lookupSession,
          GroupMember(
            shareGroupId: group.id!,
            anonAccountId: account.id!,
            role: GroupMemberRole.admin,
            memberSigningPublicKeyHex: creatorMemberSigPub,
            memberEncryptionPublicKeyHex: creatorMemberEnc,
            encryptedDataKey: 'wrapped',
            addedBySignerPublicKeyHex: groupUltSigPub,
            addedByAttestation: 'sig',
          ),
        );
      } finally {
        await lookupSession.close();
      }

      // First grant.
      final first = await GroupMemberDevice.db.insertRow(
        session,
        GroupMemberDevice(
          groupMemberId: member.id!,
          accountDeviceId: device.id!,
          encryptedDataKey: 'blob-v1',
          addedBySignerPublicKeyHex: member.memberSigningPublicKeyHex,
          addedByAttestation: 'sig-1',
        ),
      );

      // Revoke the first grant — without the partial index the second
      // insert would hit the unconditional unique constraint.
      await GroupMemberDevice.db.updateRow(
        session,
        first.copyWith(isRevoked: true, revokedAt: DateTime.now()),
      );

      // Same (groupMemberId, accountDeviceId) pair — must succeed because
      // the unique index is partial on isRevoked = false.
      final second = await GroupMemberDevice.db.insertRow(
        session,
        GroupMemberDevice(
          groupMemberId: member.id!,
          accountDeviceId: device.id!,
          encryptedDataKey: 'blob-v2',
          addedBySignerPublicKeyHex: member.memberSigningPublicKeyHex,
          addedByAttestation: 'sig-2',
        ),
      );

      expect(second.id, isNot(equals(first.id)));
      expect(second.encryptedDataKey, equals('blob-v2'));
      expect(second.isRevoked, isFalse);
    });
  });
}