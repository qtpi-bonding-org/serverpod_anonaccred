/// Shared `tenantType` values for `ShardRouting`.
///
/// Not DB-enforced — `ShardRouting.tenantType` is a plain String so future
/// consumers can define their own tenant units without an anonaccred change.
/// These constants exist purely so quanitya and episutra reference the same
/// values instead of hand-typing strings (typo protection via IDE
/// autocomplete, not schema constraint).
abstract final class ShardTenantType {
  static const account = 'account';
  static const group = 'group';
}
