@Tags(['two_actor'])
library;

import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/simulated_user.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('group owner backup SDK integration', (
    sessionBuilder,
    endpoints,
  ) {
    test('createGroup persists the creator owner backup', () async {
      final owner = SimulatedUser(sessionBuilder, endpoints, label: 'owner');
      await owner.onboard();
      final groupId = await owner.createGroup('Owner backup');
      final row = (await owner.listMyGroups()).single;
      expect(row.groupId, groupId);
      expect(row.encryptedUltimateKey, isNotNull);
    });

    test('owner backup is not exposed to a non-owner', () async {
      final owner = SimulatedUser(sessionBuilder, endpoints, label: 'owner');
      final member = SimulatedUser(sessionBuilder, endpoints, label: 'member');
      await owner.onboard();
      await member.onboard();
      final groupId = await owner.createGroup('Private backup');
      await owner.inviteAndJoin(
        member,
        groupId: groupId,
        role: GroupMemberRole.member,
      );
      final row = (await member.listMyGroups()).single;
      expect(row.encryptedUltimateKey, isNull);
    });
  });
}
