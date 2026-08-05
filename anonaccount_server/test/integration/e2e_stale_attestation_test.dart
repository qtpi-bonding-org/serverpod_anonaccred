@Tags(['two_actor'])
library;

import 'package:test/test.dart';
import 'package:serverpod_test/serverpod_test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/sdk_test_caller.dart';
import 'test_tools/simulated_user.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('e2e stale attestation', (sessionBuilder, endpoints) {
    test('a device envelope built before revocation is rejected', () async {
      final alice = SimulatedUser(sessionBuilder, endpoints, label: 'alice');
      await alice.onboard();
      await alice.addDeviceViaPairing(label: 'secondary');
      final deviceHex = await alice.deviceKeyHex();
      final envelope = await alice.caller.buildEnvelope(
        methodName: 'listDevices',
        signingKey: await alice.deviceKey,
        publicKeyHex: deviceHex,
      );
      await alice.revokeDevice(await alice.primaryDeviceId());
      await expectLater(
        alice.caller.deviceManagement.listDevices(
          challenge: envelope.challenge,
          proofOfWork: envelope.proofOfWork,
          publicKeyHex: deviceHex,
          signature: envelope.signature,
        ),
        throwsA(anything),
      );
    });
  });
}
