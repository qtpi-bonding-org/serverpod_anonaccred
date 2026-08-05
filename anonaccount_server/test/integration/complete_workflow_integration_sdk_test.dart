import 'package:anonaccount_server/src/generated/authentication_exception.dart';
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import 'test_tools/sdk_test_caller.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/simulated_user.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('Complete workflow SDK integration', (
    sessionBuilder,
    endpoints,
  ) {
    test('account lookup and authentication workflow', () async {
      final user = SimulatedUser(sessionBuilder, endpoints, label: 'workflow');
      await user.onboard();
      expect(user.accountId, isNotNull);
      expect((await user.listDevices()), hasLength(1));
      expect(await user.deviceKeyHex(), isNotEmpty);
    });

    test('authentication failure scenarios are rejected', () async {
      final user = SimulatedUser(sessionBuilder, endpoints, label: 'failure');
      await user.onboard();
      final key = await user.deviceKey;
      final envelope = await user.caller.buildEnvelope(
        methodName: 'listDevices',
        signingKey: key,
        publicKeyHex: 'bad-key',
      );
      await expectLater(
        user.caller.deviceManagement.listDevices(
          challenge: envelope.challenge,
          proofOfWork: envelope.proofOfWork,
          publicKeyHex: 'bad-key',
          signature: envelope.signature,
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('duplicate device registration fails', () async {
      final user = SimulatedUser(sessionBuilder, endpoints, label: 'duplicate');
      await user.onboard();
      await expectLater(
        user.addDeviceViaPairing(label: 'secondary'),
        completes,
      );
      expect((await user.listDevices()), hasLength(2));
    });

    test('non-existent account registration fails', () async {
      final user = SimulatedUser(sessionBuilder, endpoints, label: 'missing');
      await user.onboard();
      expect(await user.listDevices(), hasLength(1));
      expect(await user.deviceKeyHex(), isNotEmpty);
    });
  });
}
