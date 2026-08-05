import 'package:test/test.dart';

import '../../test_helpers/auth_services_test_helper.dart';
import 'serverpod_test_tools.dart';
import 'simulated_user.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('SdkTestCaller group', (sessionBuilder, endpoints) {
    test('group creation and listing use the SDK caller', () async {
      final user = SimulatedUser(sessionBuilder, endpoints, label: 'alice');
      await user.onboard();
      final groupId = await user.createGroup('Test Group');
      expect(
        (await user.listMyGroups()).map((m) => m.groupId),
        contains(groupId),
      );
    });
  });
}
