import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/simulated_user.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('e2e recovery', (sessionBuilder, endpoints) {
    test('recovers a lost account and its owner membership', () async {
      final alice = SimulatedUser(sessionBuilder, endpoints, label: 'alice');
      await alice.onboard();
      final groupId = await alice.createGroup('Recovery');
      final recovering = SimulatedUser(
        sessionBuilder,
        endpoints,
        label: 'recovered',
      );
      recovering.ultimateBackupJwk = alice.ultimateBackupJwk;
      final recovered = await recovering.recoverAccount(
        deviceLabel: 'new-phone',
      );
      expect(recovered.single.groupId, groupId);
      expect(recovered.single.recovered, isTrue);
      expect(recovered.single.ownerKeyRecovered, isTrue);
    });
  });
}
