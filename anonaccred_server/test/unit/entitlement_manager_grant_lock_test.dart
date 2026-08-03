import 'dart:async';
import 'dart:math';

import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

/// `withServerpod`'s default `RollbackDatabase.afterEach` wraps a whole test
/// in one savepoint-backed transaction — nested `session.db.transaction()`
/// calls share that same underlying transaction, so a transaction can never
/// block on its own lock. Proving `LockMode.forUpdate` actually closes a
/// lost-update race needs genuinely separate, concurrent database
/// transactions, which requires disabling that wrapping here. Since rollback
/// is disabled, every row this test inserts is deleted in `tearDown`.
void main() {
  withServerpod(
    'EntitlementManager.grantEntitlementById locking',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      late UuidValue accountUuid;
      late int entitlementId;
      const tag = 'grant_lock_test';

      tearDown(() async {
        final session = sessionBuilder.build();
        await AccountEntitlement.db.deleteWhere(
          session,
          where: (t) => t.accountUuid.equals(accountUuid),
        );
        await AnonAccount.db.deleteWhere(
          session,
          where: (t) => t.id.equals(accountUuid),
        );
        await Entitlement.db.deleteWhere(
          session,
          where: (t) => t.id.equals(entitlementId),
        );
      });

      test(
        'two concurrent grants to the same balance row do not lose an '
        'update — the balance reflects both grants, not just one',
        () async {
          final session = sessionBuilder.build();
          final account = await AnonAccount.db.insertRow(
            session,
            AnonAccount(
              id: UuidValue.fromString(const Uuid().v4()),
              ultimateSigningPublicKeyHex: _randomHex(),
              encryptedDataKey: 'data',
              ultimateEncryptionPublicKeyHex: _randomHex(),
            ),
          );
          accountUuid = account.id!;
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
          // Seed an existing balance so both concurrent calls hit the update
          // branch (findFirstRow -> updateRow), not the insert branch — the
          // insert branch is already race-safe via the
          // account_entitlement_idx unique index.
          await AccountEntitlement.db.insertRow(
            session,
            AccountEntitlement(
              accountUuid: accountUuid,
              entitlementId: entitlementId,
              balance: 0.0,
            ),
          );

          final holdOpen = Completer<void>();
          final firstGrantApplied = Completer<void>();

          // Deliberately hold the first transaction open (uncommitted) past
          // its own grant so the second transaction's read+write is forced
          // to overlap with it — without that overlap this wouldn't be a
          // reliable test of a timing-dependent race.
          final first = session.db.transaction((tx) async {
            await EntitlementManager.grantEntitlementById(
              session,
              accountUuid: accountUuid,
              entitlementId: entitlementId,
              quantity: 10.0,
              transaction: tx,
            );
            firstGrantApplied.complete();
            await holdOpen.future;
          });

          await firstGrantApplied.future;

          final second = session.db.transaction((tx) async {
            await EntitlementManager.grantEntitlementById(
              session,
              accountUuid: accountUuid,
              entitlementId: entitlementId,
              quantity: 5.0,
              transaction: tx,
            );
          });

          // Give the second transaction time to start (and, without the
          // fix, to read the pre-first-commit balance) before releasing
          // the first.
          await Future<void>.delayed(const Duration(milliseconds: 200));
          holdOpen.complete();
          await Future.wait([first, second]);

          final balance = await EntitlementManager.getEntitlementBalance(
            session,
            accountUuid: accountUuid,
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
