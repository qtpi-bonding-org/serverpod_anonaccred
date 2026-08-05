import 'package:test/test.dart';

import '../../test_helpers/auth_services_test_helper.dart';
import 'serverpod_test_tools.dart';
import 'simulated_user.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('SdkTestCaller device', (sessionBuilder, endpoints) {
    test('device management lists an SDK-created device', () async {
      final user = SimulatedUser(sessionBuilder, endpoints, label: 'alice');
      await user.onboard();
      expect(await user.listDevices(), hasLength(1));
    });
  });
}
