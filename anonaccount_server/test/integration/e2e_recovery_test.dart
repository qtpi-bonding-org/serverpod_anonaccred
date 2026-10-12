import 'package:anonaccount_sdk/anonaccount_sdk.dart';
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

    test('an invited member recovers its member key from the app-written backup',
        () async {
      final owner = SimulatedUser(sessionBuilder, endpoints, label: 'owner');
      await owner.onboard();
      final invitee = SimulatedUser(sessionBuilder, endpoints, label: 'invitee');
      await invitee.onboard();
      final groupId = await owner.createGroup('G');
      await owner.inviteAndJoin(invitee,
          groupId: groupId, role: GroupMemberRole.member);

      final recovering =
          SimulatedUser(sessionBuilder, endpoints, label: 'invitee-recovered');
      recovering.ultimateBackupJwk = invitee.ultimateBackupJwk;
      final recovered = await recovering.recoverAccount(deviceLabel: 'new-phone');

      final row = recovered.singleWhere((r) => r.groupId == groupId);
      expect(row.recovered, isTrue);
      expect(row.ownerKeyRecovered, isNull);
    });
  });
}
