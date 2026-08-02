import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:anonaccount_server/src/queries/active_rows.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'test_tools/serverpod_test_tools.dart';

// Re-use the helpers declared in grant_member_device_test.dart /
// group_endpoint_test.dart where they are already private to those files.
// To keep this test file self-contained we redeclare the minimum helpers we
// need: createTestAccount (exported from test_account_helper), plus local
// seeders that mirror what group_endpoint_test.dart's helpers do.

Future<AccountDevice> _seedDevice(
  TestSessionBuilder sessionBuilder, {
  required UuidValue accountId,
  String? deviceSigningPublicKeyHex,
  String? deviceEncryptionPublicKeyHex,
  bool isRevoked = false,
}) async {
  final session =
      (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: '_seedDevice',
  );
  try {
    final sig = deviceSigningPublicKeyHex ??
        'aa${List.filled(63, 'a').join()}'
            'aa${List.filled(63, 'a').join()}';
    final enc = deviceEncryptionPublicKeyHex ??
        'bb${List.filled(63, 'b').join()}'
            'bb${List.filled(63, 'b').join()}';
    final device = AccountDevice(
      anonAccountId: accountId,
      deviceSigningPublicKeyHex: sig,
      deviceEncryptionPublicKeyHex: enc,
      encryptedDataKey: 'wrapped',
      label: 'test-device',
      addedBySignerPublicKeyHex: sig,
      addedByAttestation: 'attestation',
      lastActive: DateTime.now(),
      isRevoked: isRevoked,
    );
    return await AccountDevice.db.insertRow(session, device);
  } finally {
    await session.close();
  }
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
        ultimateSigningPublicKeyHex: 'cc${List.filled(63, 'c').join()}'
            'cc${List.filled(63, 'c').join()}',
        ultimateEncryptionPublicKeyHex: 'dd${List.filled(63, 'd').join()}'
            'dd${List.filled(63, 'd').join()}',
        encryptedDataKey: 'wrapped',
      ),
    );
  } finally {
    await session.close();
  }
}

Future<GroupMember> _seedMember(
  TestSessionBuilder sessionBuilder, {
  required UuidValue shareGroupId,
  required UuidValue accountId,
  bool isRevoked = false,
  String? memberSigningPublicKeyHex,
}) async {
  final session =
      (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: '_seedMember',
  );
  try {
    final hex = memberSigningPublicKeyHex ?? _uniqueHex();
    final member = GroupMember(
      shareGroupId: shareGroupId,
      anonAccountId: accountId,
      role: GroupMemberRole.member,
      memberSigningPublicKeyHex: hex,
      memberEncryptionPublicKeyHex: hex,
      encryptedDataKey: 'wrapped',
      addedBySignerPublicKeyHex: hex,
      addedByAttestation: 'attestation',
      isRevoked: isRevoked,
    );
    return await GroupMember.db.insertRow(session, member);
  } finally {
    await session.close();
  }
}

String _uniqueHex() {
  // 128 hex chars: prefix a tag so distinct calls produce distinct rows
  final tag = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
  return tag.padRight(128, '0').substring(0, 128);
}

Future<GroupMemberDevice> _seedGrant(
  TestSessionBuilder sessionBuilder, {
  required UuidValue groupMemberId,
  required UuidValue accountDeviceId,
  bool isRevoked = false,
}) async {
  final session =
      (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: '_seedGrant',
  );
  try {
    final grant = GroupMemberDevice(
      groupMemberId: groupMemberId,
      accountDeviceId: accountDeviceId,
      encryptedDataKey: 'wrapped',
      addedBySignerPublicKeyHex: _uniqueHex(),
      addedByAttestation: 'attestation',
      isRevoked: isRevoked,
    );
    return await GroupMemberDevice.db.insertRow(session, grant);
  } finally {
    await session.close();
  }
}

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('ActiveRows.finders', (sessionBuilder, endpoints) {
    test(
      'memberInGroup returns the active membership, not the revoked one',
      () async {
        // Same (group, account): one revoked, one active. Only legal once
        // the unique index is partial, which is why this test exists.
        final account = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: _uniqueHex(),
        );
        final group = await _seedGroup(sessionBuilder);

        await _seedMember(
          sessionBuilder,
          shareGroupId: group.id!,
          accountId: account.id!,
          isRevoked: true,
        );
        final active = await _seedMember(
          sessionBuilder,
          shareGroupId: group.id!,
          accountId: account.id!,
          isRevoked: false,
        );

        final session = sessionBuilder.build();
        try {
          final found =
              await ActiveRows.memberInGroup(session, group.id!, account.id!);
          expect(found, isNotNull);
          expect(found!.id, active.id);
        } finally {
          await session.close();
        }
      },
    );

    test(
      'memberInGroup returns null when every membership is revoked',
      () async {
        final account = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: _uniqueHex(),
        );
        final group = await _seedGroup(sessionBuilder);

        await _seedMember(
          sessionBuilder,
          shareGroupId: group.id!,
          accountId: account.id!,
          isRevoked: true,
        );

        final session = sessionBuilder.build();
        try {
          final found =
              await ActiveRows.memberInGroup(session, group.id!, account.id!);
          expect(found, isNull);
        } finally {
          await session.close();
        }
      },
    );

    test('membersOfGroup omits revoked members', () async {
      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: _uniqueHex(),
      );
      final group = await _seedGroup(sessionBuilder);

      final active = await _seedMember(
        sessionBuilder,
        shareGroupId: group.id!,
        accountId: account.id!,
        isRevoked: false,
      );
      await _seedMember(
        sessionBuilder,
        shareGroupId: group.id!,
        accountId: account.id!,
        isRevoked: true,
        memberSigningPublicKeyHex: _uniqueHex(),
      );

      final session = sessionBuilder.build();
      try {
        final found = await ActiveRows.membersOfGroup(session, group.id!);
        expect(found.map((m) => m.id), [active.id]);
      } finally {
        await session.close();
      }
    });

    test('deviceBySigningKey omits a revoked device', () async {
      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: _uniqueHex(),
      );

      final active = await _seedDevice(
        sessionBuilder,
        accountId: account.id!,
        isRevoked: false,
        deviceSigningPublicKeyHex: _uniqueHex(),
      );
      final revokedSigningKey = _uniqueHex();
      await _seedDevice(
        sessionBuilder,
        accountId: account.id!,
        isRevoked: true,
        deviceSigningPublicKeyHex: revokedSigningKey,
      );

      final session = sessionBuilder.build();
      try {
        // Active device: found.
        final activeFound = await ActiveRows.deviceBySigningKey(
          session,
          active.deviceSigningPublicKeyHex,
        );
        expect(activeFound, isNotNull);
        expect(activeFound!.id, active.id);

        // Revoked device: not found.
        final revokedFound = await ActiveRows.deviceBySigningKey(
          session,
          revokedSigningKey,
        );
        expect(revokedFound, isNull);
      } finally {
        await session.close();
      }
    });

    test('devicesForAccount omits revoked devices', () async {
      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: _uniqueHex(),
      );

      final active = await _seedDevice(
        sessionBuilder,
        accountId: account.id!,
        isRevoked: false,
        deviceSigningPublicKeyHex: _uniqueHex(),
      );
      await _seedDevice(
        sessionBuilder,
        accountId: account.id!,
        isRevoked: true,
        deviceSigningPublicKeyHex: _uniqueHex(),
      );

      final session = sessionBuilder.build();
      try {
        final found = await ActiveRows.devicesForAccount(session, account.id!);
        expect(found.map((d) => d.id), [active.id]);
      } finally {
        await session.close();
      }
    });

    test('grant omits a revoked grant', () async {
      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: _uniqueHex(),
      );
      final group = await _seedGroup(sessionBuilder);
      final member = await _seedMember(
        sessionBuilder,
        shareGroupId: group.id!,
        accountId: account.id!,
      );

      final device = await _seedDevice(
        sessionBuilder,
        accountId: account.id!,
        deviceSigningPublicKeyHex: _uniqueHex(),
      );

      final activeGrant = await _seedGrant(
        sessionBuilder,
        groupMemberId: member.id!,
        accountDeviceId: device.id!,
        isRevoked: false,
      );

      // Create a second device with its own grant, then revoke that grant,
      // to prove the active filter at the (member, device) level.
      final device2 = await _seedDevice(
        sessionBuilder,
        accountId: account.id!,
        deviceSigningPublicKeyHex: _uniqueHex(),
      );
      await _seedGrant(
        sessionBuilder,
        groupMemberId: member.id!,
        accountDeviceId: device2.id!,
        isRevoked: true,
      );

      final session = sessionBuilder.build();
      try {
        final found = await ActiveRows.grant(
          session,
          member.id!,
          device.id!,
        );
        expect(found, isNotNull);
        expect(found!.id, activeGrant.id);

        final revokedFound = await ActiveRows.grant(
          session,
          member.id!,
          device2.id!,
        );
        expect(revokedFound, isNull);
      } finally {
        await session.close();
      }
    });

    test('grantsForMember omits revoked grants', () async {
      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: _uniqueHex(),
      );
      final group = await _seedGroup(sessionBuilder);
      final member = await _seedMember(
        sessionBuilder,
        shareGroupId: group.id!,
        accountId: account.id!,
      );

      final deviceA = await _seedDevice(
        sessionBuilder,
        accountId: account.id!,
        deviceSigningPublicKeyHex: _uniqueHex(),
      );
      final deviceB = await _seedDevice(
        sessionBuilder,
        accountId: account.id!,
        deviceSigningPublicKeyHex: _uniqueHex(),
      );

      final activeGrant = await _seedGrant(
        sessionBuilder,
        groupMemberId: member.id!,
        accountDeviceId: deviceA.id!,
        isRevoked: false,
      );
      await _seedGrant(
        sessionBuilder,
        groupMemberId: member.id!,
        accountDeviceId: deviceB.id!,
        isRevoked: true,
      );

      final session = sessionBuilder.build();
      try {
        final found =
            await ActiveRows.grantsForMember(session, member.id!);
        expect(found.map((g) => g.id), [activeGrant.id]);
      } finally {
        await session.close();
      }
    });

    test(
      'AllRows.deviceBySigningKeyIncludingRevoked DOES return a revoked device',
      () async {
        // The escape hatch has to actually work, or callers will bypass the file.
        final account = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: _uniqueHex(),
        );
        final revoked = await _seedDevice(
          sessionBuilder,
          accountId: account.id!,
          isRevoked: true,
          deviceSigningPublicKeyHex: _uniqueHex(),
        );

        final session = sessionBuilder.build();
        try {
          final found = await AllRows.deviceBySigningKeyIncludingRevoked(
            session,
            revoked.deviceSigningPublicKeyHex,
          );
          expect(found, isNotNull);
          expect(found!.id, revoked.id);
        } finally {
          await session.close();
        }
      },
    );
  });
}
