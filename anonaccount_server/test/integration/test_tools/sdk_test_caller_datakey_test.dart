import 'package:test/test.dart';

import '../../test_helpers/auth_services_test_helper.dart';
import 'serverpod_test_tools.dart';
import 'simulated_user.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('SdkTestCaller data key', (sessionBuilder, endpoints) {
    test('the SDK can recover the account data key', () async {
      final user = SimulatedUser(sessionBuilder, endpoints, label: 'alice');
      await user.onboard();
      final recovered = SimulatedUser(
        sessionBuilder,
        endpoints,
        label: 'recovered',
      );
      recovered.ultimateBackupJwk = user.ultimateBackupJwk;
      expect(
        await recovered.recoverAccount(deviceLabel: 'new-device'),
        isEmpty,
      );
    });
  });
}
