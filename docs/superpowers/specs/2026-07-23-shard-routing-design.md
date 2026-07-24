# Shard Routing Design

**Date:** 2026-07-23
**Scope:** `anonaccount_server`, `anonaccount_client`
**Consumers:** `quanitya_cloud_server`, `episutra_cloud_server` (both depend directly
on `anonaccount_server`)

---

## Context

Both quanitya and episutra run PowerSync + Serverpod + Postgres E2EE sync stacks,
each modeled on the same scaling notes (single replication container is the
hard ceiling; horizontal scaling means adding whole PowerSync *instances*, each
with its own logical replication slot against one Postgres). Neither app needs
to shard today — both run a single shard — but the notes call out a routing
table as "cheap now, painful to retrofit": add the lookup table and default
everything to one shard now, so scaling out later is a config change instead
of a data migration.

Both apps already depend on `anonaccount_server` directly and both build their
group/vault feature on its `ShareGroup`/`GroupMember` models. Rather than each
app hand-rolling an identical three-column lookup table, this spec adds a
shared `ShardRouting` model to `anonaccount_server`.

**Why this lives in anonaccred and not each parent app:** the schema itself
(tenant → shard name) is identical for both consumers and would otherwise be
copy-pasted. Putting it here means one migration, one model, no drift between
the two copies.

**Why it doesn't couple to `ShareGroup`/`AnonAccount`:** anonaccred is a
reusable, parent-agnostic module (see README's Interface Boundary section). If
`ShardRouting` held a `relation()` to `ShareGroup` or `AnonAccount`, it would
hardcode the assumption that "account" and "group" are the only sharding units
any consumer will ever need, and it would tie a generic identity/payment
module to PowerSync-specific vocabulary. Instead `ShardRouting` stores an
opaque `tenantId` + free-text `tenantType`, so it works for whatever unit a
given consumer shards by — including both `account` and `group` at once, which
is what quanitya and episutra both need (personal data shards by account,
vault data shards by group).

---

## What AnonAccred provides — and what it deliberately does not

Same boundary as the rest of the module (README: *"Generate JWTs for
services... Make business logic decisions"* are parent-project
responsibility). Applied here:

**Provides:**
- The `ShardRouting` schema + migration.
- The `ShardTenantType` constants (`account`, `group`) as a shared, typo-safe
  convention — not DB-enforced, just exported so both consumers reference the
  same Dart constant instead of hand-typing strings.

**Does not provide:**
- No endpoint. No lookup RPC, no write RPC. Both parent servers already run
  migrations from this module into their own Postgres, so they query the
  generated `ShardRouting` DAO directly from their own endpoint/JWT-minting
  code, same as any other table in their own database.
- No auto-population. AnonAccred's own `ShareGroup`/`AnonAccount` creation
  code does **not** insert `ShardRouting` rows. Doing so would assume every
  consumer treats groups/accounts as sharding units, which is exactly the
  coupling this design avoids. Each parent app's own account/group creation
  flow decides if and when to insert a row (defaulting to `shard_01`).
- No shard-name → connection-string resolution. That mapping is
  environment/deployment config, and lives in each parent app.

This mirrors the existing "What AnonAccred Does NOT Do" list in the README —
add a line there (see Changes below) rather than inventing a new boundary
concept.

---

## Model

New file: `anonaccount_server/lib/src/models/shard_routing.spy.yaml`

```yaml
# ShardRouting: opaque tenant -> shard lookup for horizontally-scaled
# PowerSync/Postgres deployments. AnonAccred does not read or write this
# table itself — see docs/superpowers/specs/2026-07-23-shard-routing-design.md
class: ShardRouting
table: shard_routing
indexes:
  shard_routing_unique_idx:
    fields: tenantId, tenantType
    unique: true
fields:
  id: UuidValue?, defaultPersist=random

  # Opaque — no relation() to AnonAccount or ShareGroup. The tenant unit is
  # entirely consumer-defined; anonaccred does not assume what this ID refers to.
  tenantId: UuidValue

  # Free-text, consumer-defined label (e.g. "account", "group"). Not an enum —
  # a fixed enum here would hardcode which sharding units are legal, which is
  # exactly what this table exists to avoid. See ShardTenantType for the
  # shared convention quanitya/episutra both use today.
  tenantType: String

  shardName: String, default='shard_01'
  updatedAt: DateTime, default=now
```

No relation fields, so no cross-module UUID FK migration issue (the known
`serverpod create-migration` bug only affects cross-module `relation()`
fields — this model has none).

---

## Dart constants

New file: `anonaccount_client/lib/src/shard_tenant_type.dart`

```dart
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
```

Export from `anonaccount_client/lib/anonaccount_client.dart` alongside the
existing `pow_methods.dart` export.

---

## README changes

Add one line to the existing "What AnonAccred Does NOT Do" list:

```markdown
- Decide shard/routing topology or perform shard lookups (provides only the
  `ShardRouting` schema; parent project owns population, reads, and
  shard-name → endpoint resolution)
```

---

## Migration

Flat migration convention (per project convention — delete existing,
regenerate from scratch):

```bash
cd anonaccount_server
serverpod create-migration --force
dart analyze
```

Verify `definition.sql` creates `shard_routing` with a plain `uuid` column
for `tenant_id` (not `bigint`) — this model has no cross-module relation, so
the known UUID-FK generation bug should not apply, but confirm anyway since
`create-migration` output isn't otherwise reviewed line-by-line.

---

## Consumer usage (non-normative — for context only, not part of this change)

Illustrative only; quanitya/episutra each own their actual implementation.

```dart
// In quanitya_cloud_server / episutra_cloud_server, e.g. when minting a JWT:
final accountShard = await ShardRouting.db.findFirstRow(
  session,
  where: (t) => t.tenantId.equals(accountId) & t.tenantType.equals(ShardTenantType.account),
);
final groupShard = await ShardRouting.db.findFirstRow(
  session,
  where: (t) => t.tenantId.equals(groupId) & t.tenantType.equals(ShardTenantType.group),
);
// shardName defaults to 'shard_01' if no row exists yet — parent app decides
// whether "no row" means "default shard" or "not yet provisioned."
```

---

## Summary table

| Item | Change |
|---|---|
| `anonaccount_server/lib/src/models/shard_routing.spy.yaml` | New model: `ShardRouting` |
| `anonaccount_client/lib/src/shard_tenant_type.dart` | New: `ShardTenantType` constants |
| `anonaccount_client/lib/anonaccount_client.dart` | Export new constants file |
| `README.md` | Add one bullet to "What AnonAccred Does NOT Do" |
| Migration | New flat migration via `serverpod create-migration --force` |
| Endpoints | None added |
| Auto-population | None — parent apps own row creation |
