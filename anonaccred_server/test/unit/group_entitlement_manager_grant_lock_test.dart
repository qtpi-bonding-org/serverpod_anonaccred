import 'dart:async';
import 'dart:math';

import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

/// See `entitlement_manager_grant_lock_test.dart` for why this test disables
/// `withServerpod`'s default transaction-per-test rollback: proving a
/// `FOR UPDATE` lock closes a lost-update race needs genuinely separate,
/// concurrent database transactions, which its savepoint-sharing wrapping
/// doesn't allow. Since rollback is disabled, every row this test inserts is
/// deleted in `tearDown`.
void main() {
  withServerpod(
    'GroupEntitlementManager.grantGroupEntitlementById locking',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      late UuidValue shareGroupUuid;
      late int entitlementId;
      const tag = 'group_grant_lock_test';

      tearDown(() async {
        final session = sessionBuilder.build();
        await GroupEntitlement.db.deleteWhere(
          session,
          where: (t) => t.shareGroupUuid.equals(shareGroupUuid),
        );
        await ShareGroup.db.deleteWhere(
          session,
          where: (t) => t.id.equals(shareGroupUuid),
        );
        await Entitlement.db.deleteWhere(
          session,
          where: (t) => t.id.equals(entitlementId),
        );
      });

      test(
        'two concurrent group grants to the same balance row do not lose '
        'an update — the balance reflects both grants, not just one',
        () async {
          final session = sessionBuilder.build();
          final group = await ShareGroup.db.insertRow(
            session,
            ShareGroup(
              ultimateSigningPublicKeyHex: _randomHex(),
              ultimateEncryptionPublicKeyHex: _randomHex(),
              encryptedDataKey: 'group_data',
            ),
          );
          shareGroupUuid = group.id!;
          final entitlement = await Entitlement.db.insertRow(
            session,
            Entitlement(
              tag: tag,
              name: tag,
              type: EntitlementType.consumable,
              serverValidated: true,
            ),
          );
          entitlementId = entitlement.id!;
          await GroupEntitlement.db.insertRow(
            session,
            GroupEntitlement(
              shareGroupUuid: shareGroupUuid,
              entitlementId: entitlementId,
              balance: 0.0,
            ),
          );

          final holdOpen = Completer<void>();
          final firstGrantApplied = Completer<void>();

          final first = session.db.transaction((tx) async {
            await GroupEntitlementManager.grantGroupEntitlementById(
              session,
              shareGroupUuid: shareGroupUuid,
              entitlementId: entitlementId,
              quantity: 10.0,
              transaction: tx,
            );
            firstGrantApplied.complete();
            await holdOpen.future;
          });

          await firstGrantApplied.future;

          final second = session.db.transaction((tx) async {
            await GroupEntitlementManager.grantGroupEntitlementById(
              session,
              shareGroupUuid: shareGroupUuid,
              entitlementId: entitlementId,
              quantity: 5.0,
              transaction: tx,
            );
          });

          await Future<void>.delayed(const Duration(milliseconds: 200));
          holdOpen.complete();
          await Future.wait([first, second]);

          final balance = await GroupEntitlementManager.getGroupEntitlementBalance(
            session,
            shareGroupUuid: shareGroupUuid,
            tag: tag,
          );
          expect(
            balance,
            15.0,
            reason:
                'both grants should be reflected — without the FOR UPDATE '
                'lock, the second transaction reads the balance before the '
                'first commits and overwrites it, losing the first grant '
                '(balance would be 5.0)',
          );
        },
      );
    },
  );
}

String _randomHex() {
  final random = Random();
  final buffer = StringBuffer();
  for (var i = 0; i < 128; i++) {
    buffer.write(random.nextInt(16).toRadixString(16));
  }
  return buffer.toString();
}
