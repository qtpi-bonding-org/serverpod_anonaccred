import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('AnonAccountHelpers.requireMemberStanding', (
    sessionBuilder,
    endpoints,
  ) {
    Future<AuthenticatedCaller> callerFor(UuidValue accountId) async {
      final (_, devicePub) = SigningTestHelper.generateKeypair();
      final session = (sessionBuilder as InternalTestSessionBuilder)
          .internalBuild(endpoint: 'test', method: 'setup');
      try {
        await AccountDevice.db.insertRow(
          session,
          AccountDevice(
            anonAccountId: accountId,
            deviceSigningPublicKeyHex: devicePub,
            deviceEncryptionPublicKeyHex: devicePub,
            encryptedDataKey: 'x',
            label: 'x',
            addedByAttestorPublicKeyHex: devicePub,
            addedByAttestation: 'x',
            lastActive: DateTime.now(),
            isRevoked: false,
          ),
        );
      } finally {
        await session.close();
      }
      return AnonAccountHelpers.requireCaller(
        (sessionBuilder as InternalTestSessionBuilder).internalBuild(
          endpoint: 'test',
          method: 'call',
        ),
        devicePub,
        'testOp',
      );
    }

    Future<({UuidValue groupId, String memberPub})> membershipFor(
      UuidValue accountId,
    ) async {
      final (_, groupKey) = SigningTestHelper.generateKeypair();
      final session = (sessionBuilder as InternalTestSessionBuilder)
          .internalBuild(endpoint: 'test', method: 'setupGroup');
      try {
        final group = await ShareGroup.db.insertRow(
          session,
          ShareGroup(
            ultimateSigningPublicKeyHex: groupKey,
            ultimateEncryptionPublicKeyHex: groupKey,
            encryptedDataKey: 'x',
            createdAt: DateTime.now(),
          ),
        );
        final (_, memberPub) = SigningTestHelper.generateKeypair();
        await GroupMember.db.insertRow(
          session,
          GroupMember(
            shareGroupId: group.id!,
            anonAccountId: accountId,
            role: GroupMemberRole.admin,
            memberSigningPublicKeyHex: memberPub,
            memberEncryptionPublicKeyHex: memberPub,
            encryptedDataKey: 'x',
            encryptedMemberKey: 'x',
            joinedAt: DateTime.now(),
            isRevoked: false,
            addedByAttestorPublicKeyHex: groupKey,
            addedByAttestation: 'x',
          ),
        );
        return (groupId: group.id!, memberPub: memberPub);
      } finally {
        await session.close();
      }
    }

    test('returns the active membership for the caller account', () async {
      final (_, ultimatePub) = SigningTestHelper.generateKeypair();
      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: ultimatePub,
        ultimateEncryptionPublicKeyHex: ultimatePub,
      );
      final caller = await callerFor(account.id!);
      final membership = await membershipFor(account.id!);

      final result = await AnonAccountHelpers.requireMemberStanding(
        (sessionBuilder as InternalTestSessionBuilder).internalBuild(
          endpoint: 'test',
          method: 'call',
        ),
        caller,
        membership.memberPub,
        membership.groupId,
        'testOp',
      );

      expect(result.anonAccountId, account.id);
    });

    test('rejects an unknown member key', () async {
      final (_, ultimatePub) = SigningTestHelper.generateKeypair();
      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: ultimatePub,
        ultimateEncryptionPublicKeyHex: ultimatePub,
      );
      final caller = await callerFor(account.id!);
      final membership = await membershipFor(account.id!);
      final (_, unknownMemberPub) = SigningTestHelper.generateKeypair();

      await expectLater(
        AnonAccountHelpers.requireMemberStanding(
          (sessionBuilder as InternalTestSessionBuilder).internalBuild(
            endpoint: 'test',
            method: 'call',
          ),
          caller,
          unknownMemberPub,
          membership.groupId,
          'testOp',
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('rejects a membership in another group', () async {
      final (_, ultimatePub) = SigningTestHelper.generateKeypair();
      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: ultimatePub,
        ultimateEncryptionPublicKeyHex: ultimatePub,
      );
      final caller = await callerFor(account.id!);
      final membership = await membershipFor(account.id!);
      final other = await membershipFor(account.id!);

      await expectLater(
        AnonAccountHelpers.requireMemberStanding(
          (sessionBuilder as InternalTestSessionBuilder).internalBuild(
            endpoint: 'test',
            method: 'call',
          ),
          caller,
          membership.memberPub,
          other.groupId,
          'testOp',
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('rejects a membership belonging to another account', () async {
      final (_, ultimatePubA) = SigningTestHelper.generateKeypair();
      final accountA = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: ultimatePubA,
        ultimateEncryptionPublicKeyHex: ultimatePubA,
      );
      final (_, ultimatePubB) = SigningTestHelper.generateKeypair();
      final accountB = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: ultimatePubB,
        ultimateEncryptionPublicKeyHex: ultimatePubB,
      );
      final caller = await callerFor(accountA.id!);
      final membership = await membershipFor(accountB.id!);

      await expectLater(
        AnonAccountHelpers.requireMemberStanding(
          (sessionBuilder as InternalTestSessionBuilder).internalBuild(
            endpoint: 'test',
            method: 'call',
          ),
          caller,
          membership.memberPub,
          membership.groupId,
          'testOp',
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('throws authAccountRevoked for a revoked membership', () async {
      final (_, ultimatePub) = SigningTestHelper.generateKeypair();
      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: ultimatePub,
        ultimateEncryptionPublicKeyHex: ultimatePub,
      );
      final caller = await callerFor(account.id!);
      final membership = await membershipFor(account.id!);
      final session = (sessionBuilder as InternalTestSessionBuilder)
          .internalBuild(endpoint: 'test', method: 'revoke');
      try {
        final row = (await GroupMember.db.findFirstRow(
          session,
          where: (t) =>
              t.shareGroupId.equals(membership.groupId) &
              t.memberSigningPublicKeyHex.equals(membership.memberPub),
        ))!;
        await GroupMember.db.updateRow(session, row.copyWith(isRevoked: true));
      } finally {
        await session.close();
      }

      expect(
        () => AnonAccountHelpers.requireMemberStanding(
          (sessionBuilder as InternalTestSessionBuilder).internalBuild(
            endpoint: 'test',
            method: 'call',
          ),
          caller,
          membership.memberPub,
          membership.groupId,
          'testOp',
        ),
        throwsA(
          isA<AuthenticationException>().having(
            (e) => e.code,
            'code',
            AnonAccountErrorCodes.authAccountRevoked,
          ),
        ),
      );
    });
  });
}
