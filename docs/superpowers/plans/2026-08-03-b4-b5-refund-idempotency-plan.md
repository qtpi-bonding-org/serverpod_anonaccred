# B4 + B5: Refund Idempotency and `paymentRef` Uniqueness — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `TransactionPayment.paymentRef` lookups reliably name one row (B5), and make `RefundManager.processRefund` safe against the same refund event being processed twice — sequential retries or genuine concurrent deliveries (B4).

**Architecture:** One schema batch (D3 — land both model changes in a single migration, not two): a compound unique index on `TransactionPayment(paymentRail, paymentRef)`, and a new `RefundClaim` table that `processRefund` claims atomically before doing anything else. The claim table decouples "has this refund been seen" (must be atomic, must happen first) from "what should happen" (hook-driven, unchanged) — see the spec (`docs/superpowers/specs/2026-08-03-refund-idempotency-design.md`) for why a single `FOR UPDATE` transaction spanning the hook doesn't work here.

**Tech Stack:** Dart, Serverpod ORM, Postgres unique constraints, `package:test`. No new external dependencies.

## Global Constraints

- D1: no backwards-compat shims.
- D3: batch schema changes — one `serverpod create-migration --force` for both model changes, not two.
- D21: schema changes need repo-owner sign-off — already given (`(paymentRail, paymentRef)`, confirmed in conversation, recorded in the spec's header).
- TDD Iron Law: no production code without a failing test first.
- This is a **flat migration** repo (per the parent quanitya CLAUDE.md's "Flat migrations" section): delete the existing single migration directory and regenerate from scratch with `serverpod create-migration --force`. `definition.sql` and `migration.sql` end up identical.
- **Known regen bug**: `serverpod create-migration` doesn't propagate `id: UuidValue?` from module dependencies. After regenerating, check `definition.sql` for `anon_account.id` and `account_device.anonAccountId` — if either comes back as `bigserial`/`bigint` instead of `uuid`, manually patch `definition.sql`, `migration.sql`, and `definition.json` per the documented workaround. This plan's own schema changes don't touch those tables, but a full flat regen re-touches the whole schema, so the check is still required.

## Confirmed while grounding this plan: the exception type the spec flagged as unconfirmed

The spec (`docs/superpowers/specs/2026-08-03-refund-idempotency-design.md`, "B4") explicitly flagged `on DatabaseException` as "this spec's best guess... not a confirmed type." Checked the installed `serverpod-3.4.1` package source directly (`~/.pub-cache/hosted/pub.dev/serverpod-3.4.1/lib/src/database/adapters/postgres/`):

- `TableRow.db.insertRow` only throws `DatabaseInsertRowException` when Postgres returns a row count other than 1 (`database_connection.dart:207-223`) — **not** on a constraint violation.
- A Postgres constraint violation is a `pg.ServerException` raised during the underlying query, which the adapter catches and wraps as `_PgDatabaseQueryException` — a `DatabaseQueryException` (`database_connection.dart:578-588`), **not** `DatabaseInsertRowException`.
- `DatabaseQueryException` carries `code` (the raw Postgres SQLSTATE, e.g. `'23505'` for `unique_violation`) and `constraintName`. `PgErrorCode.uniqueViolation` (`postgres_error_codes.dart:141`) is the named constant for `'23505'`.
- Both `DatabaseQueryException` and `PgErrorCode` are exported from `package:serverpod/database.dart`, which `package:serverpod/serverpod.dart` re-exports (`serverpod.dart:21`) — already imported in `refund_manager.dart:1`, so **no new import is needed**.

So the real catch clause is `on DatabaseQueryException catch (e)`, checking `e.code == PgErrorCode.uniqueViolation` — not `on DatabaseException`. This is used in Task 3 below.

---

### Task 1: Schema batch — `TransactionPayment` unique index + new `RefundClaim` table

**Files:**
- Modify: `anonaccred_server/lib/src/models/transaction_payment.spy.yaml`
- Create: `anonaccred_server/lib/src/models/refund_claim.spy.yaml`
- Regenerate: `anonaccred_server/lib/src/generated/**` (via `serverpod generate`)
- Regenerate: `anonaccred_server/migrations/**` (via `serverpod create-migration --force`)
- Test: `anonaccred_server/test/integration/transaction_payment_database_test.dart`

**Interfaces:**
- Produces: `RefundClaim` model (`paymentRail: PaymentRail`, `paymentRef: String`, `claimedAt: DateTime`), unique on `(paymentRail, paymentRef)`. Task 3 consumes `RefundClaim.db.insertRow`.
- Produces: `TransactionPayment(paymentRail, paymentRef)` now unique at the DB level — no Dart-level interface change, `TransactionPayment`'s fields are unchanged.

- [ ] **Step 1: Write the failing test**

Add to `test/integration/transaction_payment_database_test.dart`, new test in the existing `withServerpod` group (reuses the file's existing `setUp`, which creates `testRailProduct`):

```dart
test(
  'inserting a second TransactionPayment with the same (paymentRail, paymentRef) throws a unique-constraint violation',
  () async {
    final session = sessionBuilder.build();
    final shared = TransactionPayment(
      railProductId: testRailProduct.id!,
      internalTransactionId:
          'first_${DateTime.now().millisecondsSinceEpoch}',
      priceCurrency: Currency.USD,
      price: 9.99,
      paymentRail: PaymentRail.monero,
      paymentCurrency: Currency.XMR,
      paymentAmount: 0.05,
      paymentRef: 'dup_ref_test',
      transactionTimestamp: DateTime.now(),
      status: OrderStatus.paid,
    );
    await TransactionPayment.db.insertRow(session, shared);

    final duplicate = TransactionPayment(
      railProductId: testRailProduct.id!,
      internalTransactionId:
          'second_${DateTime.now().millisecondsSinceEpoch}',
      priceCurrency: Currency.USD,
      price: 9.99,
      paymentRail: PaymentRail.monero, // same rail
      paymentCurrency: Currency.XMR,
      paymentAmount: 0.05,
      paymentRef: 'dup_ref_test', // same ref
      transactionTimestamp: DateTime.now(),
      status: OrderStatus.paid,
    );

    await expectLater(
      TransactionPayment.db.insertRow(session, duplicate),
      throwsA(
        isA<DatabaseQueryException>().having(
          (e) => e.code,
          'code',
          PgErrorCode.uniqueViolation,
        ),
      ),
    );
  },
);
```

Add the import (if not already present via the protocol barrel): `import 'package:serverpod/serverpod.dart';` — check first, `DatabaseQueryException`/`PgErrorCode` may already be reachable through an existing import in this file; add explicitly only if `dart analyze` flags them as undefined.

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test test/integration/transaction_payment_database_test.dart`
Expected: FAIL — the second `insertRow` succeeds today (no constraint exists yet), so `expectLater`'s `throwsA` assertion fails with "expected: throws / actual: <TransactionPayment instance>".

- [ ] **Step 3: Make the schema change**

In `transaction_payment.spy.yaml`, add the new index (keep `internal_tx_id_idx` and `timestamp_idx` as-is):

```yaml
indexes:
  internal_tx_id_idx:
    fields: internalTransactionId
    unique: true
  timestamp_idx:
    fields: transactionTimestamp
    unique: false
  payment_ref_idx:
    fields: paymentRail, paymentRef
    unique: true
```

Create `anonaccred_server/lib/src/models/refund_claim.spy.yaml`:

```yaml
class: RefundClaim
table: refund_claim
fields:
  paymentRail: PaymentRail
  paymentRef: String
  claimedAt: DateTime, default=now
indexes:
  refund_claim_idx:
    fields: paymentRail, paymentRef
    unique: true
```

- [ ] **Step 4: Regenerate**

Run, from `anonaccred_server/`:
```bash
serverpod generate
```

Then regenerate the flat migration:
```bash
serverpod create-migration --force
```

- [ ] **Step 5: Check for the known cross-module UUID regen bug**

Open the newly regenerated `anonaccred_server/migrations/<new-timestamp>/definition.sql`. Search for `anon_account` and `account_device`. Confirm `anon_account."id"` is `uuid`, not `bigserial`, and `account_device."anonAccountId"` is `uuid`, not `bigint`. If either regressed to the integer type, manually patch `definition.sql`, `migration.sql`, and `definition.json` in the new migration directory to restore `uuid`/`UuidValue?`, per the documented workaround (this has recurred before on this exact pair of tables).

Also confirm the new migration's `definition.sql` contains:
- A unique index on `transaction_payment("paymentRail", "paymentRef")`.
- A new `refund_claim` table with a unique index on `("paymentRail", "paymentRef")`.

- [ ] **Step 6: Run test to verify it passes**

Run: `dart test test/integration/transaction_payment_database_test.dart`
Expected: PASS, all tests in the file including the new one.

- [ ] **Step 7: `dart analyze`**

Run: `dart analyze`
Expected: 0 errors, 0 warnings (the new `RefundClaim` generated class must compile cleanly).

- [ ] **Step 8: Commit**

```bash
git add anonaccred_server/lib/src/models/transaction_payment.spy.yaml \
        anonaccred_server/lib/src/models/refund_claim.spy.yaml \
        anonaccred_server/lib/src/generated \
        anonaccred_server/migrations \
        anonaccred_server/test/integration/transaction_payment_database_test.dart
git commit -m "schema: unique (paymentRail, paymentRef) on TransactionPayment + RefundClaim table"
```

---

### Task 2: `RefundManager.processRefund` claims before resolving

**Files:**
- Modify: `anonaccred_server/lib/src/refund_manager.dart`
- Test: `anonaccred_server/test/unit/refund_manager_test.dart`

**Interfaces:**
- Consumes: `RefundClaim` (Task 1), `DatabaseQueryException`/`PgErrorCode.uniqueViolation` (already reachable via the existing `package:serverpod/serverpod.dart` import).
- No change to `RefundManager.processRefund`'s public signature — same `Future<void> processRefund(Session session, RefundEvent event)`.

- [ ] **Step 1: Write the failing tests**

Add to `test/unit/refund_manager_test.dart`, inside the existing `withServerpod('RefundManager', ...)` group (reuses the file's `_seedBridgeChain` helper):

```dart
group('idempotency claim', () {
  test('processing the same event twice only revokes once', () async {
    final session = sessionBuilder.build();
    final seed = await _seedBridgeChain(
      session,
      paymentRef: 'claim_test_1',
      storeProductId: 'sku_claim_1',
      grantQuantity: 50.0,
    );

    await RefundManager.processRefund(session, seed.event);
    await RefundManager.processRefund(session, seed.event);

    final balance = await AccountEntitlement.db.findFirstRow(
      session,
      where: (t) =>
          t.accountUuid.equals(seed.accountUuid) &
          t.entitlementId.equals(seed.entitlementId),
    );
    // Revoked once: 50.0 granted, one revocation clamps to 0, a second
    // no-op revocation would still leave it at 0 either way — the real
    // proof is the hook-call count below, not the balance.
    expect(balance?.balance, 0.0);
  });

  test('the developer hook only runs once for a duplicate event', () async {
    final session = sessionBuilder.build();
    final seed = await _seedBridgeChain(
      session,
      paymentRef: 'claim_test_2',
      storeProductId: 'sku_claim_2',
    );

    var hookCallCount = 0;
    RefundManager.onRefund((s, event, context) async {
      hookCallCount++;
      return RefundAction.ignore;
    });

    await RefundManager.processRefund(session, seed.event);
    await RefundManager.processRefund(session, seed.event);

    expect(hookCallCount, 1);
  });

  test('concurrent processRefund calls for the same event only revoke once',
      () async {
    final session = sessionBuilder.build();
    final seed = await _seedBridgeChain(
      session,
      paymentRef: 'claim_test_3',
      storeProductId: 'sku_claim_3',
      grantQuantity: 50.0,
    );

    var hookCallCount = 0;
    RefundManager.onRefund((s, event, context) async {
      hookCallCount++;
      return RefundAction.ignore;
    });

    await Future.wait([
      RefundManager.processRefund(session, seed.event),
      RefundManager.processRefund(session, seed.event),
    ]);

    expect(hookCallCount, 1);
  });

  test('a genuinely new event is not blocked by an unrelated claim',
      () async {
    final session = sessionBuilder.build();
    final seedA = await _seedBridgeChain(
      session,
      paymentRef: 'claim_test_unrelated_a',
      storeProductId: 'sku_claim_unrelated_a',
    );
    final seedB = await _seedBridgeChain(
      session,
      paymentRef: 'claim_test_unrelated_b',
      storeProductId: 'sku_claim_unrelated_b',
    );

    var hookCallCount = 0;
    RefundManager.onRefund((s, event, context) async {
      hookCallCount++;
      return RefundAction.ignore;
    });

    await RefundManager.processRefund(session, seedA.event);
    await RefundManager.processRefund(session, seedB.event);

    expect(hookCallCount, 2);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test test/unit/refund_manager_test.dart`
Expected: FAIL on the three duplicate-event tests — `hookCallCount` is `2`, not `1`, because nothing claims the event yet; today's `processRefund` has no memory of having seen a `paymentRef` before (that's exactly B4). The fourth test ("unrelated") should already pass — it's there to prove Task 2's fix doesn't over-block, run it now to confirm it passes for the *current* reason (no claim mechanism exists yet) so its later pass is meaningful, not accidental.

- [ ] **Step 3: Write minimal implementation**

In `refund_manager.dart`, replace `processRefund`:

```dart
/// Main entry point: process a refund event.
static Future<void> processRefund(Session session, RefundEvent event) async {
  // 0. Atomically claim this refund before doing anything else. A
  // unique-constraint violation means another delivery of the same
  // refund already claimed it — whatever that delivery decided has
  // already happened or is happening; this call is a no-op.
  try {
    await RefundClaim.db.insertRow(
      session,
      RefundClaim(paymentRail: event.rail, paymentRef: event.paymentRef),
    );
  } on DatabaseQueryException catch (e) {
    if (e.code != PgErrorCode.uniqueViolation) rethrow;
    session.log(
      'Refund already claimed: ${event.rail.name}:${event.paymentRef}',
      level: LogLevel.info,
    );
    return;
  }

  // 1. Resolve context via bridge chain
  final context = await _resolveContext(session, event);

  // 2. Determine action
  RefundAction action;
  if (_handler != null) {
    action = await _handler!(session, event, context);
  } else {
    action = RefundAction.revokeAll;
  }

  // 3. Execute action
  await _executeAction(session, event, context, action);
}
```

No new imports needed — `DatabaseQueryException`, `PgErrorCode`, and `RefundClaim` are all reachable via the file's existing `package:serverpod/serverpod.dart` and `generated/protocol.dart` imports.

- [ ] **Step 4: Run test to verify it passes**

Run: `dart test test/unit/refund_manager_test.dart`
Expected: PASS, all tests in the file (old and new).

- [ ] **Step 5: Commit**

```bash
git add anonaccred_server/lib/src/refund_manager.dart anonaccred_server/test/unit/refund_manager_test.dart
git commit -m "feat(refund): claim refund events atomically before processing"
```

---

### Task 3: Full suite + analyze

**Files:** none — verification only.

- [ ] **Step 1:** Run `dart test` from `anonaccred_server/`.
Expected: PASS. Two known pre-existing failures may appear — the macOS `webcrypto`/BoringSSL issue documented in this project's own memory — unrelated to this change; no other failures.

- [ ] **Step 2:** Run `dart analyze` from `anonaccred_server/`.
Expected: 0 errors, 0 warnings.

- [ ] **Step 3:** If either check surfaces a regression outside the files this plan touches, stop and investigate before continuing — do not silently patch around it as part of this plan's scope.

---

## Non-goals (unchanged from the spec)

- **Not fixing `CommerceManager.fulfillTransactionPayment`'s idempotency gap** — different call site, different (simpler) root cause: it already wraps everything in one `session.db.transaction`, just missing `lockMode: LockMode.forUpdate` on its `findFirstRow` (confirmed still true — `commerce_manager.dart`, `fulfillTransactionPayment`, the `TransactionPayment.db.findFirstRow` call has no `lockMode`).
- **Not touching `EntitlementManager`/`GroupEntitlementManager`** — their existing per-row `FOR UPDATE` locks (confirmed still present: `entitlement_manager.dart` and `group_entitlement_manager.dart`, both `consumeEntitlement`/`revokeEntitlement` and their group equivalents) are correct and sufficient for what they do.
- **Not deduping.**
- **Not tightening `TransactionPayment.paymentRef` to non-nullable** — separate, smaller decision; Postgres unique indexes already treat `NULL` as distinct from every other `NULL`, so the nullable column doesn't weaken the new constraint.
- **Not touching `ReceiptHash.hash`'s global (not per-rail) uniqueness** — flagged for consistency in the spec, not actioned; different risk profile (opaque digest vs. vendor ID string).

## Where this was found

`anonaccred_server/lib/src/refund_manager.dart` (full file), `anonaccred_server/lib/src/models/transaction_payment.spy.yaml`, `anonaccred_server/lib/src/models/receipt_hash.spy.yaml`, `anonaccred_server/lib/src/models/order_status.spy.yaml`, `anonaccred_server/lib/src/entitlement_manager.dart`, `anonaccred_server/lib/src/group_entitlement_manager.dart`, `anonaccred_server/lib/src/commerce_manager.dart` (`fulfillTransactionPayment`), `anonaccred_server/test/unit/refund_manager_test.dart` (`_seedBridgeChain` helper and existing test group), `anonaccred_server/test/integration/transaction_payment_database_test.dart`, `anonaccred_server/migrations/20260802130701358/definition.sql`, and — for the exception-type confirmation — the installed `serverpod-3.4.1` package source at `~/.pub-cache/hosted/pub.dev/serverpod-3.4.1/lib/src/database/adapters/postgres/{database_connection.dart,postgres_exceptions.dart,postgres_error_codes.dart}` and `~/.pub-cache/hosted/pub.dev/serverpod-3.4.1/lib/src/database/concepts/exceptions.dart`. All against pinned ref `5542026d8b9afdfbf488b2c1b23a43ca2ae42e54` unless noted.
