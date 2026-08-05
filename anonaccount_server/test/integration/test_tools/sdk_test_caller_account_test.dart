import 'package:anonaccount_sdk/anonaccount_sdk.dart' as sdk;
import 'package:test/test.dart';

import '../../test_helpers/auth_services_test_helper.dart';
import 'serverpod_test_tools.dart';
import 'sdk_test_caller.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('SdkTestCaller account', (sessionBuilder, endpoints) {
    test('entrypoint and account calls reach the real test server', () async {
      final caller = SdkTestCaller(sessionBuilder, endpoints);
      final challenge = await caller.entrypoint.getChallenge();
      expect(challenge.challenge, isNotEmpty);
      final store = sdk.InMemoryAccountKeyStore();
      final auth = sdk.AnonaccountAuth(
        caller,
        store,
        sdk.InMemoryMemberKeyStore(),
        sdk.InMemoryGroupOwnerKeyStore(),
      );
      final result = await auth.createAccount(
        deviceLabel: 'primary',
        createdAt: DateTime.utc(2026, 8, 3),
      );
      await auth.registerAccount(result.payload, deviceLabel: 'primary');
      expect(await store.getDeviceSigningPublicKeyHex(), isNotNull);
    });
  });
}
