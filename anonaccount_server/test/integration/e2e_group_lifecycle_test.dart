@Tags(['two_actor'])
library;

import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/simulated_user.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('e2e group lifecycle', (sessionBuilder, endpoints) {
    test('create, join, promote, remove, rejoin, and leave', () async {
      final alice = SimulatedUser(sessionBuilder, endpoints, label: 'alice');
      final bob = SimulatedUser(sessionBuilder, endpoints, label: 'bob');
      await alice.onboard();
      await bob.onboard();
      final groupId = await alice.createGroup('Lifecycle');
      await alice.inviteAndJoin(
        bob,
        groupId: groupId,
        role: GroupMemberRole.member,
      );
      final bobMembership = (await bob.listMyGroups()).singleWhere(
        (m) => m.groupId == groupId,
      );
      await alice.changeRole(
        groupId,
        bobMembership.memberId,
        GroupMemberRole.admin,
      );
      expect(
        (await alice.listGroupMembers(
          groupId,
        )).singleWhere((m) => m.memberId == bobMembership.memberId).role,
        GroupMemberRole.admin,
      );
      await alice.removeMember(groupId, bobMembership.memberId);
      expect(await alice.listGroupMembers(groupId), hasLength(1));
      await alice.inviteAndJoin(
        bob,
        groupId: groupId,
        role: GroupMemberRole.member,
      );
      final rejoined = (await bob.listMyGroups()).singleWhere(
        (m) => m.groupId == groupId,
      );
      await bob.leaveGroupMembership(groupId, rejoined.memberId);
      expect(await alice.listGroupMembers(groupId), hasLength(1));
    });
  });
}
