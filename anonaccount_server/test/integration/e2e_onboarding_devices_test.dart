@Tags(['two_actor'])
library;

import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/simulated_user.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('e2e onboarding and device lifecycle', (
    sessionBuilder,
    endpoints,
  ) {
    test('pairs, revokes, and protects the last device', () async {
      final alice = SimulatedUser(sessionBuilder, endpoints, label: 'alice');
      await alice.onboard();
      final second = await alice.addDeviceViaPairing(label: 'alice-laptop');
      expect(await alice.listDevices(), hasLength(2));
      expect(await alice.revokeDevice(second), isTrue);
      expect(
        (await alice.listDevices()).where((d) => !d.isRevoked),
        hasLength(1),
      );
      await expectLater(
        alice.revokeDevice(await alice.primaryDeviceId()),
        throwsA(anything),
      );
    });
  });
}
