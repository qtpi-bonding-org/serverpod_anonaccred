/// Configuration for the ephemeral-bridge privacy scrub job.
///
/// Pass to [PrivacyScrubFutureCall.schedule] after [Serverpod.start]:
/// ```dart
/// await PrivacyScrubFutureCall.schedule(pod, const PrivacyScrubConfig());
/// ```
///
/// Set [enabled] to false if your deployment has different privacy requirements
/// or manages the scrub job externally. Setting [enabled] to false also cancels
/// any existing scheduled scrub (safe to call on restart).
class PrivacyScrubConfig {
  const PrivacyScrubConfig({
    this.enabled = true,
    this.retentionDays = 7,
  });

  /// Whether the scrub job should run. Default: true.
  final bool enabled;

  /// How many days to retain ephemeral accreditation bridge rows.
  /// Rows older than this are deleted on each scrub pass. Default: 7.
  final int retentionDays;

  /// Convenience constant: disable the scrub entirely.
  static const disabled = PrivacyScrubConfig(enabled: false);
}
