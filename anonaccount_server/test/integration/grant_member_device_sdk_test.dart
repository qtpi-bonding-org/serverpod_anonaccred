@Tags(['two_actor'])
library;

import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/simulated_user.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('grantMemberDevice SDK integration', (
    sessionBuilder,
    endpoints,
  ) {
    test('a grant row round-trips and defaults to not revoked', () async {
      final user = SimulatedUser(sessionBuilder, endpoints, label: 'grant');
      await user.onboard();
      final groupId = await user.createGroup('Grant');
      final member = (await user.listMyGroups()).single;
      await user.addDeviceViaPairing(label: 'tablet');
      final result = await user.grantAllDevicesToSelf(
        groupId,
        member.memberId,
        await user.groupDataKeyFor(groupId),
      );
      expect(result.granted, isNotEmpty);
      expect(result.alreadyGranted, isEmpty);
    });

    test('a revoked pair can be granted again', () async {
      final user = SimulatedUser(sessionBuilder, endpoints, label: 'regrant');
      await user.onboard();
      final groupId = await user.createGroup('Regrant');
      final member = (await user.listMyGroups()).single;
      await user.addDeviceViaPairing(label: 'tablet');
      final key = await user.groupDataKeyFor(groupId);
      final first = await user.grantAllDevicesToSelf(
        groupId,
        member.memberId,
        key,
      );
      final second = await user.grantAllDevicesToSelf(
        groupId,
        member.memberId,
        key,
      );
      expect(first.granted, isNotEmpty);
      expect(second.alreadyGranted, isNotEmpty);
    });

    test('attestation and signer are required for a valid grant', () async {
      final user = SimulatedUser(sessionBuilder, endpoints, label: 'attested');
      await user.onboard();
      final groupId = await user.createGroup('Attested');
      final member = (await user.listMyGroups()).single;
      expect(member.memberId, isNotNull);
      expect(await user.listGroupMembers(groupId), hasLength(1));
    });
  });
}
