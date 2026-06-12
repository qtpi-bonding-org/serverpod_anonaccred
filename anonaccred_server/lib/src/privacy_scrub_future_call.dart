import 'package:serverpod/serverpod.dart';
import 'generated/protocol.dart';
import 'privacy_scrub_config.dart';

/// Recurring FutureCall that deletes expired ephemeral accreditation bridges.
///
/// Implements the 7-day TTL from the iap_privacy_hardening spec:
/// EphemeralAccreditation and EphemeralAccreditationGroup rows older than
/// [retentionDays] are deleted, making the account↔purchase-timestamp linkage
/// truly ephemeral rather than permanently accumulated.
///
/// ## Bootstrapping
///
/// Call once from your server's run.dart after [Serverpod.start]:
/// ```dart
/// await PrivacyScrubFutureCall.schedule(pod, const PrivacyScrubConfig());
/// ```
///
/// The job self-schedules on a 24-hour interval. On restart, [schedule]
/// cancels any pending invocation and re-queues it, so startup is idempotent.
/// Pass [PrivacyScrubConfig.disabled] (or omit the call entirely) to skip it.
///
/// ## Module path (after serverpod generate)
///
/// The consuming server's generated API exposes this as:
/// ```
/// pod.endpoints.futureCalls.callWithDelay(d).anonaccred.privacyScrub.scrub(n)
/// ```
class PrivacyScrubFutureCall extends FutureCall {
  /// Deletes expired bridge rows and re-schedules itself for 24 hours later.
  ///
  /// [retentionDays] rows older than this many days are deleted.
  /// Pass 0 to run without rescheduling (one-shot cleanup).
  Future<void> scrub(Session session, int retentionDays) async {
    // Re-schedule before doing work so the next run is queued even if this
    // one throws. Uses dynamic dispatch to avoid a circular import on the
    // generated future_calls.dart — the .anonaccred.privacyScrub path
    // matches the module nickname in config/generator.yaml.
    if (retentionDays > 0) {
      final futureCalls = session.serverpod.endpoints.futureCalls;
      if (futureCalls != null) {
        await (futureCalls.callWithDelay(
          const Duration(hours: 24),
          identifier: 'anonaccred-privacy-scrub',
        ) as dynamic)
            .anonaccred
            .privacyScrub
            .scrub(retentionDays);
      }
    }

    final cutoff =
        DateTime.now().toUtc().subtract(Duration(days: retentionDays));

    final deleted = await EphemeralAccreditation.db.deleteWhere(
      session,
      where: (t) => t.transactionTimestamp < cutoff,
    );
    final groupDeleted = await EphemeralAccreditationGroup.db.deleteWhere(
      session,
      where: (t) => t.transactionTimestamp < cutoff,
    );

    session.log(
      'PrivacyScrub: deleted ${deleted.length} account bridges, '
      '${groupDeleted.length} group bridges (cutoff: $cutoff)',
      level: LogLevel.info,
    );
  }

  /// Bootstraps the recurring scrub from the consuming server's run.dart.
  ///
  /// Cancels any existing scrub and re-queues it (idempotent on restart).
  /// No-op if [config.enabled] is false.
  ///
  /// ```dart
  /// await pod.start();
  /// await PrivacyScrubFutureCall.schedule(pod, const PrivacyScrubConfig());
  /// ```
  static Future<void> schedule(
    Serverpod pod,
    PrivacyScrubConfig config,
  ) async {
    final futureCalls = pod.endpoints.futureCalls;
    if (futureCalls == null) return;

    // Cancel any pending scrub so we don't double-schedule on restart.
    await futureCalls.cancel('anonaccred-privacy-scrub');

    if (!config.enabled) return;

    await (futureCalls.callWithDelay(
      Duration.zero,
      identifier: 'anonaccred-privacy-scrub',
    ) as dynamic)
        .anonaccred
        .privacyScrub
        .scrub(config.retentionDays);
  }
}
