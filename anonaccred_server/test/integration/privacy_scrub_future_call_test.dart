import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/privacy_scrub_future_call.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Regression coverage for PrivacyScrubFutureCall.scrub() under serverpod
/// 4.0.0's "future calls run at least once" execution guarantee (a crash
/// mid-call now triggers a re-run, per the 4.0 upgrade guide).
///
/// Uses retentionDays: 0 — scrub()'s documented one-shot mode that skips its
/// self-reschedule call — because that reschedule goes through
/// `session.serverpod.endpoints.futureCalls` typed as `.anonaccred
/// .privacyScrub.scrub(...)` via dynamic dispatch, and serverpod_test's
/// TestServerpod session exposes a `_FutureCallRef` that doesn't implement
/// that module-chained accessor (confirmed: calling scrub() with
/// retentionDays > 0 in this harness throws NoSuchMethodError on
/// `.anonaccred`, not a delete-logic failure). The delete-where idempotency
/// claim under test here — the actual behavior change from 4.0's "at least
/// once" guarantee — is independent of the reschedule call, so testing it
/// via the one-shot path still exercises the real code path a retried
/// production call would hit.
void main() {
  withServerpod('PrivacyScrubFutureCall.scrub()', (sessionBuilder, _) {
    test(
      'a second scrub() call deletes nothing further after the first call '
      'already cleared expired rows, and leaves a not-yet-expired row alone',
      () async {
        final session = sessionBuilder.build();
        final expiredTimestamp = DateTime.now().toUtc().subtract(
          const Duration(hours: 1),
        );
        final notYetExpiredTimestamp = DateTime.now().toUtc().add(
          const Duration(days: 1),
        );
        final accountId = UuidValue.fromString(
          'a0000000-0000-4000-8000-000000000201',
        );

        final expiredRow = await EphemeralAccreditation.db.insertRow(
          session,
          EphemeralAccreditation(
            accountUuid: accountId,
            transactionTimestamp: expiredTimestamp,
          ),
        );
        final notYetExpiredRow = await EphemeralAccreditation.db.insertRow(
          session,
          EphemeralAccreditation(
            accountUuid: accountId,
            transactionTimestamp: notYetExpiredTimestamp,
          ),
        );

        final scrubCall = PrivacyScrubFutureCall();

        // First call: the normal run.
        await scrubCall.scrub(session, 0);

        expect(
          await EphemeralAccreditation.db.findById(session, expiredRow.id!),
          isNull,
        );
        expect(
          await EphemeralAccreditation.db.findById(
            session,
            notYetExpiredRow.id!,
          ),
          isNotNull,
        );

        // Second call: simulates the "at least once" retry Serverpod's
        // future-call runner performs after a crash mid-call. The expired
        // row is already gone, so this must not throw and must not touch
        // the not-yet-expired row.
        await expectLater(scrubCall.scrub(session, 0), completes);

        expect(
          await EphemeralAccreditation.db.findById(
            session,
            notYetExpiredRow.id!,
          ),
          isNotNull,
        );
      },
    );
  });
}
