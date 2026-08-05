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

  withServerpod('e2e grantMemberDevice', (sessionBuilder, endpoints) {
    test('grants a newly paired device access to an existing group', () async {
      final alice = SimulatedUser(sessionBuilder, endpoints, label: 'alice');
      await alice.onboard();
      final groupId = await alice.createGroup('Grant');
      final membership = (await alice.listMyGroups()).singleWhere(
        (m) => m.groupId == groupId,
      );
      await alice.addDeviceViaPairing(label: 'tablet');
      final result = await alice.grantAllDevicesToSelf(
        groupId,
        membership.memberId,
        await alice.groupDataKeyFor(groupId),
      );
      expect(result.granted.length, greaterThanOrEqualTo(1));
    });
  });
}
