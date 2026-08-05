@Tags(['two_actor'])
library;

import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/simulated_user.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('group member backup SDK integration', (
    sessionBuilder,
    endpoints,
  ) {
    test('createGroup persists the creator member key backup', () async {
      final owner = SimulatedUser(sessionBuilder, endpoints, label: 'owner');
      await owner.onboard();
      final groupId = await owner.createGroup('Member backup');
      final membership = (await owner.listMyGroups()).single;
      expect(membership.encryptedMemberKey, isNotEmpty);
      expect((await owner.listGroupMembers(groupId)), hasLength(1));
    });

    test('a relaying admin cannot expose a different backup', () async {
      final owner = SimulatedUser(sessionBuilder, endpoints, label: 'owner');
      final admin = SimulatedUser(sessionBuilder, endpoints, label: 'admin');
      final member = SimulatedUser(sessionBuilder, endpoints, label: 'member');
      await owner.onboard();
      await admin.onboard();
      await member.onboard();
      final groupId = await owner.createGroup('Relaying');
      await owner.inviteAndJoin(
        admin,
        groupId: groupId,
        role: GroupMemberRole.admin,
      );
      await admin.inviteAndJoin(
        member,
        groupId: groupId,
        role: GroupMemberRole.member,
      );
      expect((await admin.listGroupMembers(groupId)), hasLength(3));
      expect((await member.listGroupMembers(groupId)), hasLength(3));
    });

    test('listGroupMembers never returns another member key backup', () async {
      final owner = SimulatedUser(sessionBuilder, endpoints, label: 'owner');
      final member = SimulatedUser(sessionBuilder, endpoints, label: 'member');
      await owner.onboard();
      await member.onboard();
      final groupId = await owner.createGroup('Visibility');
      await owner.inviteAndJoin(
        member,
        groupId: groupId,
        role: GroupMemberRole.member,
      );
      for (final row in await member.listGroupMembers(groupId)) {
        expect(row.toJson(), isNot(contains('encryptedMemberKey')));
        expect(row.toJson(), isNot(contains('memberEncryptedDataKey')));
      }
    });

    test('listMyGroups returns the caller their own backup', () async {
      final owner = SimulatedUser(sessionBuilder, endpoints, label: 'owner');
      await owner.onboard();
      final groupId = await owner.createGroup('Own backup');
      expect((await owner.listMyGroups()).single.groupId, groupId);
    });
  });
}
