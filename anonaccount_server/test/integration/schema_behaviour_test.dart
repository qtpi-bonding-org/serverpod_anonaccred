import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'test_tools/serverpod_test_tools.dart';

// These tests assert behaviour, not declarations: that the partial unique
// indexes from the P0 schema batch actually permit re-adding a row after
// revocation, while still rejecting two simultaneously-active rows for the
// same pair.

String _uniqueHex() {
  final tag = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
  return tag.padRight(128, '0').substring(0, 128);
}

Future<ShareGroup> _seedGroup(TestSessionBuilder sessionBuilder) async {
  final session =
      (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: '_seedGroup',
  );
  try {
    return await ShareGroup.db.insertRow(
      session,
      ShareGroup(
        ultimateSigningPublicKeyHex: _uniqueHex(),
        ultimateEncryptionPublicKeyHex: _uniqueHex(),
        encryptedDataKey: 'wrapped',
      ),
    );
  } finally {
    await session.close();
  }
}

Future<GroupMember> _insertMember(
  TestSessionBuilder sessionBuilder, {
  required UuidValue shareGroupId,
  required UuidValue accountId,
  bool isRevoked = false,
}) async {
  final session =
      (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: '_insertMember',
  );
  try {
    final hex = _uniqueHex();
    return await GroupMember.db.insertRow(
      session,
      GroupMember(
        shareGroupId: shareGroupId,
        anonAccountId: accountId,
        role: GroupMemberRole.member,
        memberSigningPublicKeyHex: hex,
        memberEncryptionPublicKeyHex: hex,
        encryptedDataKey: 'wrapped',
        encryptedMemberKey: 'wrapped',
        addedByAttestorPublicKeyHex: hex,
        addedByAttestation: 'attestation',
        isRevoked: isRevoked,
      ),
    );
  } finally {
    await session.close();
  }
}

Future<void> _revokeMember(
  TestSessionBuilder sessionBuilder,
  UuidValue id,
) async {
  final session =
      (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: '_revokeMember',
  );
  try {
    final row = (await GroupMember.db.findById(session, id))!;
    await GroupMember.db.updateRow(
      session,
      row.copyWith(isRevoked: true, revokedAt: DateTime.now()),
    );
  } finally {
    await session.close();
  }
}

Future<GroupOwner> _insertOwner(
  TestSessionBuilder sessionBuilder, {
  required UuidValue shareGroupId,
  required UuidValue accountId,
  bool isRevoked = false,
}) async {
  final session =
      (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: '_insertOwner',
  );
  try {
    return await GroupOwner.db.insertRow(
      session,
      GroupOwner(
        shareGroupId: shareGroupId,
        anonAccountId: accountId,
        encryptedUltimateKey: 'wrapped',
        addedByAttestorPublicKeyHex: _uniqueHex(),
        addedByAttestation: 'attestation',
        isRevoked: isRevoked,
      ),
    );
  } finally {
    await session.close();
  }
}

Future<void> _revokeOwner(TestSessionBuilder sessionBuilder, UuidValue id) async {
  final session =
      (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: '_revokeOwner',
  );
  try {
    final row = (await GroupOwner.db.findById(session, id))!;
    await GroupOwner.db.updateRow(
      session,
      row.copyWith(isRevoked: true, revokedAt: DateTime.now()),
    );
  } finally {
    await session.close();
  }
}

Future<AccountDevice> _insertDevice(
  TestSessionBuilder sessionBuilder, {
  required UuidValue accountId,
  bool isRevoked = false,
  String? attestor,
}) async {
  final session =
      (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: '_insertDevice',
  );
  try {
    return await AccountDevice.db.insertRow(
      session,
      AccountDevice(
        anonAccountId: accountId,
        deviceSigningPublicKeyHex: _uniqueHex(),
        deviceEncryptionPublicKeyHex: _uniqueHex(),
        encryptedDataKey: 'wrapped',
        label: 'test-device',
        addedByAttestorPublicKeyHex: attestor ?? _uniqueHex(),
        addedByAttestation: 'attestation',
        lastActive: DateTime.now(),
        isRevoked: isRevoked,
      ),
    );
  } finally {
    await session.close();
  }
}

Future<GroupMemberDevice> _insertGrant(
  TestSessionBuilder sessionBuilder, {
  required UuidValue groupMemberId,
  required UuidValue accountDeviceId,
  bool isRevoked = false,
}) async {
  final session =
      (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: '_insertGrant',
  );
  try {
    return await GroupMemberDevice.db.insertRow(
      session,
      GroupMemberDevice(
        groupMemberId: groupMemberId,
        accountDeviceId: accountDeviceId,
        encryptedDataKey: 'wrapped',
        addedByAttestorPublicKeyHex: _uniqueHex(),
        addedByAttestation: 'attestation',
        isRevoked: isRevoked,
      ),
    );
  } finally {
    await session.close();
  }
}

Future<void> _revokeGrant(TestSessionBuilder sessionBuilder, UuidValue id) async {
  final session =
      (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: '_revokeGrant',
  );
  try {
    final row = (await GroupMemberDevice.db.findById(session, id))!;
    await GroupMemberDevice.db.updateRow(
      session,
      row.copyWith(isRevoked: true, revokedAt: DateTime.now()),
    );
  } finally {
    await session.close();
  }
}

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('Schema behaviour', (sessionBuilder, endpoints) {
    test(
      'an account can rejoin a group after its membership was revoked',
      () async {
        // The whole point of making group_member_unique_idx partial. Before
        // this batch the second insert violated the unique constraint.
        final account = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: _uniqueHex(),
        );
        final group = await _seedGroup(sessionBuilder);

        final first = await _insertMember(
          sessionBuilder,
          shareGroupId: group.id!,
          accountId: account.id!,
        );
        await _revokeMember(sessionBuilder, first.id!);
        final second = await _insertMember(
          sessionBuilder,
          shareGroupId: group.id!,
          accountId: account.id!,
        );
        expect(second.id, isNot(first.id));
      },
    );

    test('two ACTIVE memberships for the same pair are still rejected',
        () async {
      // The guarantee that survives. Partial must not mean absent.
      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: _uniqueHex(),
      );
      final group = await _seedGroup(sessionBuilder);

      await _insertMember(
        sessionBuilder,
        shareGroupId: group.id!,
        accountId: account.id!,
      );
      await expectLater(
        _insertMember(
          sessionBuilder,
          shareGroupId: group.id!,
          accountId: account.id!,
        ),
        throwsA(anything),
      );
    });

    test('the same holds for group_owner', () async {
      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: _uniqueHex(),
      );
      final group = await _seedGroup(sessionBuilder);

      final first = await _insertOwner(
        sessionBuilder,
        shareGroupId: group.id!,
        accountId: account.id!,
      );
      await _revokeOwner(sessionBuilder, first.id!);
      final second = await _insertOwner(
        sessionBuilder,
        shareGroupId: group.id!,
        accountId: account.id!,
      );
      expect(second.id, isNot(first.id));

      await expectLater(
        _insertOwner(
          sessionBuilder,
          shareGroupId: group.id!,
          accountId: account.id!,
        ),
        throwsA(anything),
      );
    });

    test('the same holds for group_member_device', () async {
      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: _uniqueHex(),
      );
      final group = await _seedGroup(sessionBuilder);
      final member = await _insertMember(
        sessionBuilder,
        shareGroupId: group.id!,
        accountId: account.id!,
      );
      final device = await _insertDevice(sessionBuilder, accountId: account.id!);

      final first = await _insertGrant(
        sessionBuilder,
        groupMemberId: member.id!,
        accountDeviceId: device.id!,
      );
      await _revokeGrant(sessionBuilder, first.id!);
      final second = await _insertGrant(
        sessionBuilder,
        groupMemberId: member.id!,
        accountDeviceId: device.id!,
      );
      expect(second.id, isNot(first.id));

      await expectLater(
        _insertGrant(
          sessionBuilder,
          groupMemberId: member.id!,
          accountDeviceId: device.id!,
        ),
        throwsA(anything),
      );
    });

    test('keyEpoch defaults to 0 and round-trips', () async {
      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: _uniqueHex(),
      );
      expect(account.keyEpoch, 0);

      final session = sessionBuilder.build();
      try {
        final reread = await AnonAccount.db.findById(session, account.id!);
        expect(reread!.keyEpoch, 0);
      } finally {
        await session.close();
      }
    });

    test('addedByAttestorPublicKeyHex round-trips after the rename',
        () async {
      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: _uniqueHex(),
      );
      final attestor = '04${'a' * 128}';
      final device = await _insertDevice(
        sessionBuilder,
        accountId: account.id!,
        attestor: attestor,
      );

      final session = sessionBuilder.build();
      try {
        final reread = await AccountDevice.db.findById(session, device.id!);
        expect(reread!.addedByAttestorPublicKeyHex, attestor);
      } finally {
        await session.close();
      }
    });

    test('deleting a group cascades to its owner rows', () async {
      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: _uniqueHex(),
      );
      final group = await _seedGroup(sessionBuilder);
      final owner = await _insertOwner(
        sessionBuilder,
        shareGroupId: group.id!,
        accountId: account.id!,
      );

      final session = sessionBuilder.build();
      try {
        await ShareGroup.db.deleteWhere(
          session,
          where: (t) => t.id.equals(group.id!),
        );
        expect(await GroupOwner.db.findById(session, owner.id!), isNull);
      } finally {
        await session.close();
      }
    });

    test('deleting an account cascades to its owner rows', () async {
      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: _uniqueHex(),
      );
      final group = await _seedGroup(sessionBuilder);
      final owner = await _insertOwner(
        sessionBuilder,
        shareGroupId: group.id!,
        accountId: account.id!,
      );

      final session = sessionBuilder.build();
      try {
        await AnonAccount.db.deleteWhere(
          session,
          where: (t) => t.id.equals(account.id!),
        );
        expect(await GroupOwner.db.findById(session, owner.id!), isNull);
      } finally {
        await session.close();
      }
    });
  });
}
