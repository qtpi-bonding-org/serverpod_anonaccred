@Tags(['two_actor'])
library;

import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/simulated_user.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('Group endpoint SDK integration', (sessionBuilder, endpoints) {
    test('createGroup makes the creator an admin', () async {
      final owner = SimulatedUser(sessionBuilder, endpoints, label: 'owner');
      await owner.onboard();
      final groupId = await owner.createGroup('CRUD');
      final members = await owner.listGroupMembers(groupId);
      expect(members.single.role, GroupMemberRole.admin);
    });

    test('member add and list expose only public member data', () async {
      final owner = SimulatedUser(sessionBuilder, endpoints, label: 'owner');
      final member = SimulatedUser(sessionBuilder, endpoints, label: 'member');
      await owner.onboard();
      await member.onboard();
      final groupId = await owner.createGroup('Members');
      await owner.inviteAndJoin(
        member,
        groupId: groupId,
        role: GroupMemberRole.member,
      );
      expect(await owner.listGroupMembers(groupId), hasLength(2));
      expect((await member.listMyGroups()).single.role, GroupMemberRole.member);
    });

    test('owner can promote and remove a member', () async {
      final owner = SimulatedUser(sessionBuilder, endpoints, label: 'owner');
      final member = SimulatedUser(sessionBuilder, endpoints, label: 'member');
      await owner.onboard();
      await member.onboard();
      final groupId = await owner.createGroup('Roles');
      await owner.inviteAndJoin(
        member,
        groupId: groupId,
        role: GroupMemberRole.member,
      );
      final memberId = (await member.listMyGroups()).single.memberId;
      await owner.changeRole(groupId, memberId, GroupMemberRole.admin);
      expect(
        (await owner.listGroupMembers(
          groupId,
        )).singleWhere((m) => m.memberId == memberId).role,
        GroupMemberRole.admin,
      );
      await owner.removeMember(groupId, memberId);
      expect(await owner.listGroupMembers(groupId), hasLength(1));
    });

    test('a member can leave and the group remains usable', () async {
      final owner = SimulatedUser(sessionBuilder, endpoints, label: 'owner');
      final member = SimulatedUser(sessionBuilder, endpoints, label: 'member');
      await owner.onboard();
      await member.onboard();
      final groupId = await owner.createGroup('Leave');
      await owner.inviteAndJoin(
        member,
        groupId: groupId,
        role: GroupMemberRole.member,
      );
      await member.leaveGroupMembership(
        groupId,
        (await member.listMyGroups()).single.memberId,
      );
      expect(await owner.listGroupMembers(groupId), hasLength(1));
    });

    test('getGroup returns the group created through the SDK', () async {
      final owner = SimulatedUser(sessionBuilder, endpoints, label: 'owner');
      await owner.onboard();
      final groupId = await owner.createGroup('Get');
      expect((await owner.getGroup(groupId)).id.toString(), groupId);
    });
  });
}
