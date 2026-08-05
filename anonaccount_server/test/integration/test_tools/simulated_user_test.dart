import 'package:test/test.dart';

import '../../test_helpers/auth_services_test_helper.dart';
import 'serverpod_test_tools.dart';
import 'simulated_user.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('SimulatedUser', (sessionBuilder, endpoints) {
    test('onboard creates an account with one active device', () async {
      final alice = SimulatedUser(sessionBuilder, endpoints, label: 'alice');
      await alice.onboard();
      expect(alice.accountId, isNotNull);
      final devices = await alice.listDevices();
      expect(devices, hasLength(1));
      expect(devices.single.isRevoked, isFalse);
    });
  });
}
