import 'package:anonaccred_server/src/payments/redemption_target.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:test/test.dart';

void main() {
  group('RedemptionTarget', () {
    test('AccountTarget carries the account UUID', () {
      final uuid = UuidValue.fromString('00000000-0000-4000-8000-000000000001');
      final t = AccountTarget(uuid);
      expect(t.accountUuid, uuid);
      expect(t, isA<RedemptionTarget>());
    });

    test('GroupTarget carries shareGroupUuid + buyerAccountUuid', () {
      final groupUuid =
          UuidValue.fromString('00000000-0000-4000-8000-000000000002');
      final buyerUuid =
          UuidValue.fromString('00000000-0000-4000-8000-000000000003');
      final t = GroupTarget(
        shareGroupUuid: groupUuid,
        buyerAccountUuid: buyerUuid,
      );
      expect(t.shareGroupUuid, groupUuid);
      expect(t.buyerAccountUuid, buyerUuid);
      expect(t, isA<RedemptionTarget>());
    });

    test('switch on sealed type is exhaustive', () {
      final t = AccountTarget(
        UuidValue.fromString('00000000-0000-4000-8000-000000000004'),
      );
      // If RedemptionTarget gains a new variant, this switch will fail
      // to compile — that's the safety property the sealed class buys us.
      final scope = switch (t as RedemptionTarget) {
        AccountTarget() => 'account',
        GroupTarget() => 'group',
      };
      expect(scope, 'account');
    });

    test('pattern destructuring extracts the UUIDs', () {
      final groupUuid =
          UuidValue.fromString('00000000-0000-4000-8000-000000000005');
      final buyerUuid =
          UuidValue.fromString('00000000-0000-4000-8000-000000000006');
      final RedemptionTarget t = GroupTarget(
        shareGroupUuid: groupUuid,
        buyerAccountUuid: buyerUuid,
      );

      switch (t) {
        case AccountTarget():
          fail('Expected GroupTarget');
        case GroupTarget(:final shareGroupUuid, :final buyerAccountUuid):
          expect(shareGroupUuid, groupUuid);
          expect(buyerAccountUuid, buyerUuid);
      }
    });
  });
}
