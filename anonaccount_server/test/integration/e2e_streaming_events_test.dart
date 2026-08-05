import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import 'test_tools/sdk_test_caller.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/simulated_user.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('e2e: streaming endpoints', (sessionBuilder, endpoints) {
    test(
      'monitorGroupMembership replays the caller\'s own membership event',
      () async {
        final alice = SimulatedUser(sessionBuilder, endpoints, label: 'alice5');
        await alice.onboard();
        final groupId = await alice.createGroup('Streaming Group');
        final membership = (await alice.listMyGroups()).singleWhere(
          (m) => m.groupId == groupId,
        );

        final deviceHex = await alice.deviceKeyHex();
        final memberHex = await alice.memberSigningKeyHex(groupId);
        final envelope = await alice.caller.buildEnvelope(
          methodName: 'monitorGroupMembership',
          signingKey: await alice.deviceKey,
          publicKeyHex: deviceHex,
        );
        final event = await alice.caller.group
            .monitorGroupMembership(
              challenge: envelope.challenge,
              proofOfWork: envelope.proofOfWork,
              signature: envelope.signature,
              callerDeviceSigningPublicKeyHex: deviceHex,
              groupId: UuidValue.fromString(groupId),
              memberSigningKeyHex: memberHex,
              memberAuthSignature: await alice.signGroupInnerPayload(groupId),
            )
            .first;

        expect(event.memberId, membership.memberId);
        expect(event.memberSigningPublicKeyHex, memberHex);
      },
    );
  });
}
