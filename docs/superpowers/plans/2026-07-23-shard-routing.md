# Shard Routing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a tenant-agnostic `ShardRouting` lookup table to `anonaccount_server` so quanitya and episutra can later shard their PowerSync/Postgres deployments by adding rows instead of running a data migration.

**Architecture:** One new Serverpod model (`ShardRouting`, no relations, opaque `tenantId`/`tenantType`), one small Dart constants file (`ShardTenantType`), a flat migration regenerate, and one README boundary bullet. No endpoints, no auto-population — this repo ships schema only; quanitya/episutra own reading and writing rows.

**Tech Stack:** Dart, Serverpod 3.4.1 ORM/codegen, `serverpod_test` (`withServerpod` harness), Postgres.

## Global Constraints

- Model lives in `anonaccount_server` (not `anonaccred_server`) — both consumers already depend on it directly. See spec §"Why `anonaccount_server` specifically."
- `ShardRouting.tenantId` is a plain `UuidValue` with **no** `relation()` to `AnonAccount`/`ShareGroup`. `tenantType` is a plain `String`, not an enum. This is the entire point of the design — do not "improve" it into a typed relation.
- `ShardTenantType` constants live in `anonaccount_server` (server-only), not `anonaccount_client` — there is no client-side consumer.
- Follow this repo's flat-migration convention: exactly one migration directory should exist under `anonaccount_server/migrations/` at all times. `serverpod create-migration --force` only skips confirmation prompts — it does **not** delete prior migration directories, so the existing one must be removed manually first (see Task 1 Step 3).
- Full spec: `docs/superpowers/specs/2026-07-23-shard-routing-design.md` — read it before starting if anything below is ambiguous.
- If `dart test` fails with a native-asset/build error unrelated to `ShardRouting`/`ShardTenantType`, this is likely the known local webcrypto/BoringSSL P-256 build issue (unrelated to this plan — neither task touches P-256 crypto paths). Don't treat it as a regression introduced by this work.

---

### Task 1: `ShardRouting` model, codegen, and migration

**Files:**
- Create: `anonaccount_server/lib/src/models/shard_routing.spy.yaml`
- Generated (do not hand-edit): `anonaccount_server/lib/src/generated/shard_routing.dart` and related generated files, plus a new migration directory under `anonaccount_server/migrations/`

**Interfaces:**
- Produces: `ShardRouting` class with fields `id: UuidValue?`, `tenantId: UuidValue`, `tenantType: String`, `shardName: String`, `updatedAt: DateTime`, and static accessor `ShardRouting.db` (Serverpod-generated ORM) supporting `insertRow`, `findFirstRow`, `findRows` — used by Task 3.

- [ ] **Step 1: Write the model YAML**

Create `anonaccount_server/lib/src/models/shard_routing.spy.yaml`:

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
  # exactly what this table exists to avoid. See ShardTenantType (Task 2) for
  # the shared convention quanitya/episutra both use today.
  tenantType: String

  shardName: String, default='shard_01'

  # NOT auto-updated on write — Serverpod's `default=now` only fires on
  # insert. Callers that change shardName on an existing row must set this
  # field explicitly; there is no ORM hook to bump it for you.
  updatedAt: DateTime, default=now
```

- [ ] **Step 2: Generate Dart classes**

Run from the repo root:

```bash
cd anonaccount_server && serverpod generate
```

Expected: command exits 0, and `anonaccount_server/lib/src/generated/shard_routing.dart` now exists.

- [ ] **Step 3: Regenerate the flat migration**

This repo keeps exactly one migration directory (flat migrations — no
incremental history). `serverpod create-migration --force` only suppresses
confirmation prompts; it does **not** delete the existing migration
directory. Remove it first, or `create-migration` will add a second,
incremental migration alongside it instead of regenerating a single flat one:

```bash
rm -rf anonaccount_server/migrations/20260612014040715
cd anonaccount_server && serverpod create-migration --force
```

Expected: exactly one new timestamp-named directory appears under
`anonaccount_server/migrations/`, containing `definition.sql`,
`migration.sql`, `definition.json`, `definition_project.json`,
`migration.json`.

```bash
ls anonaccount_server/migrations | wc -l
```

Expected: `1` — confirms the old directory was actually removed and this
didn't turn into a second, incremental migration.

- [ ] **Step 4: Verify the generated SQL uses `uuid`, not `bigint`/`bigserial`**

```bash
grep -A3 'CREATE TABLE "shard_routing"' anonaccount_server/migrations/*/definition.sql
```

Expected: `"id" uuid` and `"tenant_id" uuid` (not `bigserial`/`bigint`). `ShardRouting` is defined directly in this module (not consumed cross-module here), so the known cross-module UUID-FK bug should not apply — this step confirms that rather than assuming it.

If this shows `bigint`/`bigserial` instead, stop and treat it as a bug in this task, not something to patch around — that would mean the assumption in the spec ("this repo's own migration is safe") was wrong and needs re-diagnosis before continuing.

- [ ] **Step 5: `dart analyze`**

```bash
cd anonaccount_server && dart analyze
```

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add anonaccount_server/lib/src/models/shard_routing.spy.yaml \
        anonaccount_server/lib/src/generated \
        anonaccount_server/migrations
git commit -m "feat(anonaccount): add ShardRouting model and migration"
```

---

### Task 2: `ShardTenantType` constants

**Files:**
- Create: `anonaccount_server/lib/src/shard_tenant_type.dart`
- Modify: `anonaccount_server/lib/anonaccount_server.dart` (add export)
- Test: `anonaccount_server/test/unit/shard_tenant_type_test.dart`

**Interfaces:**
- Consumes: nothing (pure constants, no dependency on Task 1)
- Produces: `ShardTenantType.account` (`'account'`), `ShardTenantType.group` (`'group'`) — used by Task 3's test and, later, by quanitya/episutra.

- [ ] **Step 1: Write the failing test**

Create `anonaccount_server/test/unit/shard_tenant_type_test.dart`:

```dart
import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:test/test.dart';

void main() {
  test('ShardTenantType exposes the shared account/group convention', () {
    expect(ShardTenantType.account, 'account');
    expect(ShardTenantType.group, 'group');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd anonaccount_server && dart test test/unit/shard_tenant_type_test.dart
```

Expected: FAIL — `ShardTenantType` isn't defined (compile error / `Undefined name 'ShardTenantType'`).

- [ ] **Step 3: Write the implementation**

Create `anonaccount_server/lib/src/shard_tenant_type.dart`:

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

Then add the export. Open `anonaccount_server/lib/anonaccount_server.dart` and add this line alongside the existing `export` statements (match the existing alphabetical/grouping style already in that file):

```dart
export 'src/shard_tenant_type.dart';
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd anonaccount_server && dart test test/unit/shard_tenant_type_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add anonaccount_server/lib/src/shard_tenant_type.dart \
        anonaccount_server/lib/anonaccount_server.dart \
        anonaccount_server/test/unit/shard_tenant_type_test.dart
git commit -m "feat(anonaccount): add ShardTenantType constants"
```

---

### Task 3: `ShardRouting` model behavior test

**Files:**
- Create: `anonaccount_server/test/unit/shard_routing_model_test.dart`

**Interfaces:**
- Consumes: `ShardRouting` (Task 1: fields `id`, `tenantId`, `tenantType`, `shardName`, `updatedAt`; `ShardRouting.db.insertRow`, `.findFirstRow`), `ShardTenantType.account`/`.group` (Task 2)

This task has no separate "implementation step" — Tasks 1 and 2 already produced everything under test. This test exists to pin the model's actual runtime behavior (insert, lookup, unique-index enforcement) the way the rest of this repo's models are tested, using the `withServerpod` harness plus a raw `Session` for direct DB row inserts (same pattern as `createTestDevice` in `anonaccount_server/test/integration/group_endpoint_test.dart:12-34`).

- [ ] **Step 1: Write the test**

Create `anonaccount_server/test/unit/shard_routing_model_test.dart`:

```dart
import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

Future<ShardRouting> _insertRouting(
  TestSessionBuilder sessionBuilder,
  ShardRouting row,
) async {
  final session = (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: '_insertRouting',
  );
  try {
    return await ShardRouting.db.insertRow(session, row);
  } finally {
    await session.close();
  }
}

Future<ShardRouting?> _findRouting(
  TestSessionBuilder sessionBuilder, {
  required UuidValue tenantId,
  required String tenantType,
}) async {
  final session = (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: '_findRouting',
  );
  try {
    return await ShardRouting.db.findFirstRow(
      session,
      where: (t) => t.tenantId.equals(tenantId) & t.tenantType.equals(tenantType),
    );
  } finally {
    await session.close();
  }
}

void main() {
  withServerpod('Given ShardRouting model', (sessionBuilder, endpoints) {
    test('inserts and looks up a row by tenantId + tenantType', () async {
      final tenantId =
          UuidValue.fromString('10000000-0000-4000-8000-000000000001');
      final inserted = await _insertRouting(
        sessionBuilder,
        ShardRouting(
          tenantId: tenantId,
          tenantType: ShardTenantType.account,
          shardName: 'shard_01',
          updatedAt: DateTime.now(),
        ),
      );
      expect(inserted.id, isNotNull);

      final found = await _findRouting(
        sessionBuilder,
        tenantId: tenantId,
        tenantType: ShardTenantType.account,
      );
      expect(found, isNotNull);
      expect(found!.shardName, 'shard_01');
    });

    test('the same tenantId can hold separate account and group rows', () async {
      final tenantId =
          UuidValue.fromString('20000000-0000-4000-8000-000000000002');
      await _insertRouting(
        sessionBuilder,
        ShardRouting(
          tenantId: tenantId,
          tenantType: ShardTenantType.account,
          shardName: 'shard_01',
          updatedAt: DateTime.now(),
        ),
      );
      await _insertRouting(
        sessionBuilder,
        ShardRouting(
          tenantId: tenantId,
          tenantType: ShardTenantType.group,
          shardName: 'shard_02',
          updatedAt: DateTime.now(),
        ),
      );

      final accountRow = await _findRouting(
        sessionBuilder,
        tenantId: tenantId,
        tenantType: ShardTenantType.account,
      );
      final groupRow = await _findRouting(
        sessionBuilder,
        tenantId: tenantId,
        tenantType: ShardTenantType.group,
      );
      expect(accountRow!.shardName, 'shard_01');
      expect(groupRow!.shardName, 'shard_02');
    });

    test('duplicate (tenantId, tenantType) violates the unique index', () async {
      final tenantId =
          UuidValue.fromString('30000000-0000-4000-8000-000000000003');
      await _insertRouting(
        sessionBuilder,
        ShardRouting(
          tenantId: tenantId,
          tenantType: ShardTenantType.account,
          shardName: 'shard_01',
          updatedAt: DateTime.now(),
        ),
      );

      expect(
        () => _insertRouting(
          sessionBuilder,
          ShardRouting(
            tenantId: tenantId,
            tenantType: ShardTenantType.account,
            shardName: 'shard_02',
            updatedAt: DateTime.now(),
          ),
        ),
        throwsA(anything),
      );
    });

    test('lookup for a tenant with no row returns null', () async {
      final found = await _findRouting(
        sessionBuilder,
        tenantId:
            UuidValue.fromString('40000000-0000-4000-8000-000000000004'),
        tenantType: ShardTenantType.account,
      );
      expect(found, isNull);
    });
  });
}
```

Note: `withServerpod` wraps each `test()` in a transaction that rolls back afterward (`RollbackDatabase` default), so these tests don't need manual cleanup. Each test uses its own literal UUID (matching this repo's existing convention — see `anonaccred_server/test/unit/redemption_target_test.dart`) purely so each test's intent is self-evident, not because collision is actually possible across the per-test rollback boundary.

- [ ] **Step 2: Run tests to verify they fail for the right reason if anything's wrong**

```bash
cd anonaccount_server && dart test test/unit/shard_routing_model_test.dart
```

Expected: `All tests passed!` — Tasks 1 and 2 already implemented everything this test exercises, so there's no red phase here. If any test fails, treat it as a real bug in Task 1/2's implementation (e.g. the unique index wasn't created, or `tenantType` matching is case-sensitive in a way that breaks the second test) and fix the model/migration, not this test.

- [ ] **Step 3: Commit**

```bash
git add anonaccount_server/test/unit/shard_routing_model_test.dart
git commit -m "test(anonaccount): pin ShardRouting insert/lookup/unique-index behavior"
```

---

### Task 4: README boundary documentation

**Files:**
- Modify: `README.md` (repo root)

**Interfaces:** none — documentation only.

- [ ] **Step 1: Add the boundary bullet**

Open `README.md` and find the `### What AnonAccred Does NOT Do` section (currently a bulleted list ending with `- Make business logic decisions about access control`). Add one new bullet at the end of that list:

```markdown
- Decide shard/routing topology or perform shard lookups (provides only the
  `ShardRouting` schema; parent project owns population, reads, and
  shard-name → endpoint resolution)
```

- [ ] **Step 2: Verify the bullet landed in the right section**

```bash
grep -A1 'Decide shard/routing topology' README.md
```

Expected: the grep matches and shows the two-line bullet.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: document ShardRouting boundary in README"
```

---

## Post-plan note (not a task)

Whoever wires `ShardRouting` into `quanitya_cloud_server` or `episutra_cloud_server` will need to run `serverpod create-migration --force` in that repo and manually patch the resulting migration for `shard_routing.id`/`shard_routing.tenant_id` (uuid, not bigint) — same workaround already required for `anon_account`/`account_device`, per quanitya's CLAUDE.md "Cross-module UUID primary keys are broken in migration generation." This plan does not touch either consumer repo.
