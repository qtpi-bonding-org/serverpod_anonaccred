# A2: Wire Polar Refunds to RefundManager — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `PolarRail.processCallback` actually validate, resolve, and forward refund webhooks to `RefundManager` — today it acknowledges every delivery and does nothing. Fix the two bugs discovered while investigating (`extractRefundEvent`'s hash mismatch, `validateLicenseKey`'s null-entitlement fallback), and close `redeemLicenseKey`'s test-coverage gap.

**Architecture:** No new files except one test file and (conditionally) a private helper on `PolarClient`. All changes land in the existing `PolarRail`/`PolarClient`/`PolarEndpoint` trio plus their test files. `RefundManager` itself is untouched — it's already rail-agnostic and correctly used by Apple/Google.

**Tech Stack:** Dart, Serverpod ORM, `package:test`, `package:http/testing.dart` (`MockClient`) for HTTP-layer fakes — same tooling every existing Polar test file already uses.

## Global Constraints

- D17: no attestation on this boundary — do not add signature checks to `redeemLicenseKey` itself, only to the webhook delivery.
- D1: no backwards-compat shims, no feature flags.
- TDD Iron Law: no production code without a failing test first, for every task below.
- `PaymentRailInterface.extractRefundEvent` is **synchronous** and shared with Apple/Google — do not change its signature. Any network call needed to resolve a refund must happen in `processCallback`, not inside `extractRefundEvent`.
- Per this repo's root CLAUDE.md: don't add defensive handling for states the schema already makes impossible (see Task 2 — this changes what the original spec proposed).

---

## Correction to the A2 spec, found while grounding this plan

The spec (`docs/superpowers/specs/2026-08-02-polar-refund-wiring-design.md`, "Bug 2") proposed throwing when `Entitlement.db.findById(grantList.first.entitlementId)` returns null, instead of silently defaulting `productIsGroup` to `false`.

Checked `rail_product_grant.spy.yaml` and the pinned migration's `definition.sql`: `RailProductGrant.entitlementId` has a real FK to `entitlement.id` with `ON DELETE NO ACTION`. Postgres enforces that FK on both insert (can't create a grant pointing at a nonexistent entitlement) and delete (can't delete an entitlement a grant still references). **The null case the spec worried about cannot occur while this constraint stands** — it's not a live bug, it's defensive code guarding an already-impossible state, same shape as the `accreditTransaction` dead code found and deleted earlier in this session.

Task 2 below fixes it as a one-line simplification (`!` instead of `?? false`), not a new throw path, and does **not** get a new test — writing a test for an FK-guaranteed-unreachable branch would mean bypassing the constraint to fabricate the scenario, which tests nothing real. If this FK is ever relaxed, this line becomes wrong again — worth a comment, not a test.

---

## Correction to the A2 spec, `processCallback`/`redeemLicenseKey` rail construction

Both `PolarEndpoint.redeemLicenseKey` (`polar_endpoint.dart:76`) and `PolarWebhookRoute` construct their rail differently. The webhook route already does the right thing:

```dart
// polar_webhook_route.dart:35-38
final rail = PaymentManager.getRail(PaymentRail.polar);
if (rail == null) {
  PaymentManager.initializePolarRail(session);
  ...
}
```

`redeemLicenseKey` instead calls `PolarRail.fromEnvironment()` directly every time, which makes it un-mockable — there's no way for a test to inject a fake `PolarClient`. That's *why* `redeemLicenseKey` has zero tests today, and it's why Apple/Google's own endpoint tests (`iap_endpoint_integration_test.dart`) only assert "some exception happens when unconfigured," never a real happy path. Task 5 fixes this by making `redeemLicenseKey` resolve its rail the same way the webhook route already does — this is copying an existing, working pattern in this codebase, not inventing a new one.

---

### Task 1: `PolarSignatureValidator` wiring on `PolarRail`

**Files:**
- Modify: `anonaccred_server/lib/src/payments/rails/polar_rail.dart`
- Test: `anonaccred_server/test/unit/polar_rail_test.dart`

**Interfaces:**
- Produces: `PolarRail.signatureValidator` (`PolarSignatureValidator?`, nullable — null means "webhook secret not configured, reject all webhook deliveries").
- Produces: `PolarRail(client: ..., signatureValidator: ...)` constructor now takes an optional second named param.

- [ ] **Step 1: Write the failing test**

Add to `test/unit/polar_rail_test.dart`, inside a new group after `PolarRail interface conformance`:

```dart
group('PolarRail.signatureValidator', () {
  test('defaults to null when not provided', () {
    final mock = MockClient((req) async => http.Response('{}', 200));
    expect(_rail(mock).signatureValidator, isNull);
  });

  test('can be constructed with a configured validator', () {
    final mock = MockClient((req) async => http.Response('{}', 200));
    final validator = PolarSignatureValidator(secret: 'whsec_dGVzdA==');
    final rail = PolarRail(
      client: PolarClient(
        organizationId: 'org',
        http: PolarHttpClient(
          baseUrl: 'https://api.polar.sh',
          bearerToken: 't',
          httpClient: mock,
        ),
      ),
      signatureValidator: validator,
    );
    expect(rail.signatureValidator, same(validator));
  });
});
```

Add the import: `import 'package:anonaccred_server/src/payments/polar_signature_validator.dart';`

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test test/unit/polar_rail_test.dart`
Expected: compile error — `signatureValidator` named parameter doesn't exist on `PolarRail`.

- [ ] **Step 3: Write minimal implementation**

In `polar_rail.dart`, add the import and field/constructor:

```dart
import '../polar_signature_validator.dart';
```

```dart
class PolarRail implements PaymentRailInterface {
  PolarRail({required this.client, this.signatureValidator});

  /// Build from env vars: `POLAR_ACCESS_TOKEN`, `POLAR_ORGANIZATION_ID`,
  /// `POLAR_ENVIRONMENT`, `POLAR_WEBHOOK_SECRET`.
  factory PolarRail.fromEnvironment() {
    final secret = Platform.environment['POLAR_WEBHOOK_SECRET'];
    return PolarRail(
      client: PolarClient.fromEnvironment(),
      signatureValidator: (secret == null || secret.isEmpty)
          ? null
          : PolarSignatureValidator(secret: secret),
    );
  }

  final PolarClient client;

  /// Validates Standard Webhooks signatures on incoming deliveries. Null
  /// when `POLAR_WEBHOOK_SECRET` isn't configured — [processCallback]
  /// must reject all webhook deliveries in that case rather than skip
  /// verification.
  final PolarSignatureValidator? signatureValidator;
```

Also add `import 'dart:io';` to `polar_rail.dart` (needed for `Platform.environment`) — check it isn't already imported before adding.

- [ ] **Step 4: Run test to verify it passes**

Run: `dart test test/unit/polar_rail_test.dart`
Expected: PASS, all prior tests in the file still pass.

- [ ] **Step 5: Commit**

```bash
git add anonaccred_server/lib/src/payments/rails/polar_rail.dart anonaccred_server/test/unit/polar_rail_test.dart
git commit -m "feat(polar): wire PolarSignatureValidator into PolarRail"
```

---

### Task 2: Simplify the unreachable null-entitlement fallback in `validateLicenseKey`

**Files:**
- Modify: `anonaccred_server/lib/src/payments/rails/polar_rail.dart`

**Interfaces:**
- No interface change — `validateLicenseKey`'s signature and behavior are identical for every reachable input. This is a refactor, not a behavior change.

- [ ] **Step 1: No new test.** See "Correction to the A2 spec" above — the FK on `rail_product_grant.entitlementId` makes the null case unreachable. Existing tests already cover the reachable path (grant → real entitlement) implicitly via `refund_manager_test.dart`'s `_seedBridgeChain` pattern and will catch any regression.

- [ ] **Step 2: Make the change**

In `polar_rail.dart`, replace:

```dart
final firstGrantEntitlement = await Entitlement.db.findById(
  session,
  grantList.first.entitlementId,
);
final productIsGroup =
    firstGrantEntitlement?.tag.startsWith('group_') ?? false;
```

with:

```dart
// grantList.first.entitlementId is FK-constrained (ON DELETE NO ACTION)
// to a real entitlement.id — this lookup cannot return null while that
// constraint holds.
final firstGrantEntitlement = await Entitlement.db.findById(
  session,
  grantList.first.entitlementId,
);
final productIsGroup = firstGrantEntitlement!.tag.startsWith('group_');
```

- [ ] **Step 3: Run the full Polar test suite to confirm no regression**

Run: `dart test test/unit/polar_rail_test.dart test/unit/polar_client_test.dart test/unit/polar_signature_validator_test.dart test/unit/polar_http_client_test.dart`
Expected: all PASS, same count as before this task.

- [ ] **Step 4: Commit**

```bash
git add anonaccred_server/lib/src/payments/rails/polar_rail.dart
git commit -m "refactor(polar): drop unreachable null-entitlement fallback"
```

---

### Task 3: Spike — confirm where the license-key UUID lives in `PolarClient.getOrder`'s response

**This task is a hard gate for Task 4.** Do not write Task 4's code from a guess — the previous spec explicitly flagged this as unconfirmed, and web research done while writing this plan confirmed Polar's public docs don't spell out the Order↔LicenseKey link in the pages that were reachable (`docs.polar.sh` redirects to a JS-rendered app that returns 404 to a plain fetch; the OpenAPI spec at `api.polar.sh/openapi.json` is too large to pull in one shot). `polar_client.dart:158-166`'s existing doc comment on `getOrder` — written before this plan, by whoever built the client — already asserts this is what the method is *for*, which is the reason to trust the JSON body carries it somewhere, just not which key.

**Files:** none yet — this task produces a decision, recorded in Task 4's actual field name, not a file change.

- [ ] **Step 1:** If `POLAR_ACCESS_TOKEN` / `POLAR_ORGANIZATION_ID` are available for a Polar **sandbox** org in this environment, create a test license-key-benefit product, complete a checkout for it, then call:
  ```bash
  curl -s -H "Authorization: Bearer $POLAR_ACCESS_TOKEN" \
    "https://sandbox-api.polar.sh/v1/orders/<the-order-id>" | python3 -m json.tool
  ```
  Inspect the output for any key containing `license` (e.g. `license_key_id`, or a nested `items[].benefits[].id` pointing at a license-key benefit).

- [ ] **Step 2:** If sandbox credentials aren't available, fetch Polar's OpenAPI spec in slices instead of all at once (it's too large for one `WebFetch` call) — request the `Order` schema specifically:
  ```
  WebFetch: https://api.polar.sh/openapi.json
  prompt: "Return only the full JSON schema definition under components.schemas.Order, verbatim, nothing else."
  ```
  Repeat for `components.schemas.LicenseKey` if the field isn't on `Order` directly, looking for a reverse reference (e.g. `LicenseKey.order_id`) that would mean the resolution has to go through `GET /v1/license-keys/?...` filters instead of `getOrder` at all.

- [ ] **Step 3:** Record the finding as a one-line update to this plan's Task 4 (replace the placeholder field-access line with the confirmed one) before starting Task 4's TDD cycle. If the answer turns out to be "no direct field, must go through a different endpoint," rewrite Task 4's steps around that endpoint instead — don't force the `getOrder`-only shape if it's wrong.

- [ ] **Step 4: Commit** — none (research-only task, nothing to commit). If Step 3 changes this plan file, that edit can ride along with Task 4's commit.

---

### Task 4: Resolve `order_id` → license-key UUID and fix the hash mismatch (Bug 1)

**Files:**
- Modify: `anonaccred_server/lib/src/payments/rails/polar_rail.dart`
- Test: `anonaccred_server/test/unit/polar_rail_test.dart`

**Interfaces:**
- Consumes: `PolarClient.getOrder(String orderId) → Future<Map<String, dynamic>>` (already exists, `polar_client.dart:163-166`).
- Produces: `PolarRail.resolveRefundEvent(String orderId, RefundEvent preliminary) → Future<RefundEvent?>` — takes the sync, order-id-keyed event `extractRefundEvent` already builds and returns a corrected, license-key-keyed one (or null if the order can't be resolved — e.g. deleted/expired order, network failure). Task 6 calls this from `processCallback`.

This task's code below uses `orderJson['license_key_id']` as the field name — **replace this with whatever Task 3 confirmed** before implementing. The test is written against that same assumed field name so RED/GREEN both track the real contract once Task 3 lands.

- [ ] **Step 1: Write the failing test**

Add to `test/unit/polar_rail_test.dart`, new group after `PolarRail.extractRefundEvent`:

```dart
group('PolarRail.resolveRefundEvent (order → license-key resolution)', () {
  test('rebuilds receiptHash/paymentRef from the resolved license-key id',
      () async {
    final mock = MockClient((req) async {
      expect(req.url.path, '/v1/orders/ord-42');
      return http.Response(
        jsonEncode({
          'id': 'ord-42',
          'license_key_id': 'lk-resolved-uuid',
        }),
        200,
      );
    });
    final rail = _rail(mock);
    final preliminary = rail.extractRefundEvent({
      'type': 'refund.created',
      'data': {'order_id': 'ord-42', 'product_id': 'prod-x'},
    })!;

    final resolved = await rail.resolveRefundEvent(
      'ord-42',
      preliminary,
    );

    expect(resolved, isNotNull);
    expect(resolved!.paymentRef, 'lk-resolved-uuid');
    expect(resolved.receiptHash, CryptoUtils.sha256Hash('lk-resolved-uuid'));
    // Fields not affected by the resolution carry over unchanged.
    expect(resolved.productId, 'prod-x');
    expect(resolved.rail, PaymentRail.polar);
  });

  test('returns null when the order has no license_key_id (e.g. non-license order)',
      () async {
    final mock = MockClient((req) async => http.Response(
          jsonEncode({'id': 'ord-99'}),
          200,
        ));
    final rail = _rail(mock);
    final preliminary = rail.extractRefundEvent({
      'type': 'refund.created',
      'data': {'order_id': 'ord-99'},
    })!;

    final resolved = await rail.resolveRefundEvent(
      'ord-99',
      preliminary,
    );

    expect(resolved, isNull);
  });

  test('returns null when getOrder fails (order not found / network error)',
      () async {
    final mock = MockClient((req) async => http.Response('not found', 404));
    final rail = _rail(mock);
    final preliminary = rail.extractRefundEvent({
      'type': 'refund.created',
      'data': {'order_id': 'ord-missing'},
    })!;

    final resolved = await rail.resolveRefundEvent(
      'ord-missing',
      preliminary,
    );

    expect(resolved, isNull);
  });
});
```

Add the import: `import 'package:anonaccount_server/src/crypto_utils.dart';` (matches the import path already used in `apple_iap_rail_test.dart`/`google_iap_rail_test.dart`) and `import 'dart:convert';` is already present in the file.

`resolveRefundEvent` is public, not a test-only shim — Dart has no `private-but-visible-to-test-in-same-package` modifier for instance methods the way it does for top-level members in the same library file (see this repo's `notification_signature_validator.dart` static-field seam for the same problem solved differently for statics). Since `polar_rail_test.dart` is a *different file* from `polar_rail.dart`, the resolution method has to be public to be callable from the test at all — and `processCallback` in Task 6 calls this exact same method, so making it public isn't test-only scaffolding, it's the real method both places need.

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test test/unit/polar_rail_test.dart`
Expected: compile error — no method `resolveRefundEvent` on `PolarRail`.

- [ ] **Step 3: Write minimal implementation**

In `polar_rail.dart`, add after `extractRefundEvent`:

```dart
/// Resolve a preliminary [RefundEvent] (built by [extractRefundEvent] from
/// the webhook's `order_id`) into the corrected event keyed on the
/// license-key UUID — the same identifier [validateLicenseKey] wrote
/// [ReceiptHash]/[TransactionPayment] with at delivery time.
///
/// Returns null if the order can't be resolved (not found, network
/// failure) or doesn't carry a license-key id (not a license-key order).
/// [processCallback] treats a null return as "acknowledge and stop."
Future<RefundEvent?> resolveRefundEvent(
  String orderId,
  RefundEvent preliminary,
) async {
  final Map<String, dynamic> orderJson;
  try {
    orderJson = await client.getOrder(orderId);
  } catch (_) {
    return null;
  }

  final licenseKeyId = orderJson['license_key_id'] as String?;
  if (licenseKeyId == null) return null;

  return RefundEvent(
    rail: preliminary.rail,
    receiptHash: CryptoUtils.sha256Hash(licenseKeyId),
    paymentRef: licenseKeyId,
    productId: preliminary.productId,
    purchaseTimestamp: preliminary.purchaseTimestamp,
    rawData: preliminary.rawData,
  );
}
```

Add `import 'package:anonaccount_server/src/crypto_utils.dart';` if `CryptoUtils` isn't already resolvable — check first: `polar_rail.dart` line 95 already calls `CryptoUtils.sha256Hash` unqualified via the `package:anonaccount_server/anonaccount_server.dart` barrel import at line 3, so no new import is needed here.

- [ ] **Step 4: Run test to verify it passes**

Run: `dart test test/unit/polar_rail_test.dart`
Expected: PASS, all prior tests in the file still pass.

- [ ] **Step 5: Commit**

```bash
git add anonaccred_server/lib/src/payments/rails/polar_rail.dart anonaccred_server/test/unit/polar_rail_test.dart
git commit -m "fix(polar): resolve refund events to the license-key id, not order id"
```

---

### Task 5: Make `PolarEndpoint.redeemLicenseKey` use `PaymentManager.getRail` (mechanical, unblocks Task 6)

**Files:**
- Modify: `anonaccred_server/lib/src/endpoints/polar_endpoint.dart`

**Interfaces:**
- No new interface — `redeemLicenseKey`'s signature and success-path behavior are unchanged when `PaymentManager` has no rail registered (same fallback to `PolarRail.fromEnvironment()` the webhook route already uses).

- [ ] **Step 1: No new test for this file alone** — Task 6 is the test that exercises this change; writing a standalone test here would just re-test `PaymentManager.getRail`, which already has its own tests elsewhere in this package. Task 6's RED phase will fail for the right reason (rail not mockable) before this task lands, which is the actual proof this change is needed — see Task 6 Step 1/2.

- [ ] **Step 2: Make the change**

In `polar_endpoint.dart`, add the import:

```dart
import '../payments/payment_manager.dart';
```

Replace:

```dart
final rail = PolarRail.fromEnvironment();
```

with:

```dart
final rail = PaymentManager.getRail(PaymentRail.polar) as PolarRail? ??
    PolarRail.fromEnvironment();
```

- [ ] **Step 3: Run the full existing Polar + endpoint suite to confirm no regression**

Run: `dart test test/unit/polar_rail_test.dart test/integration/iap_endpoint_integration_test.dart`
Expected: all PASS (no Polar endpoint tests exist yet to break — this just confirms compilation and unrelated suites are untouched).

- [ ] **Step 4: Commit**

```bash
git add anonaccred_server/lib/src/endpoints/polar_endpoint.dart
git commit -m "refactor(polar): resolve redeemLicenseKey's rail via PaymentManager"
```

(This is intentionally its own commit, separate from Task 6's tests, so the mechanical DI change is reviewable independent of the coverage it unlocks.)

---

### Task 6: Rewire `processCallback` — signature validation → parse → route → resolve → forward

**Files:**
- Modify: `anonaccred_server/lib/src/payments/rails/polar_rail.dart`
- Test: `anonaccred_server/test/unit/polar_rail_test.dart`

**Interfaces:**
- Consumes: `PolarRail.signatureValidator` (Task 1), `PolarRail.resolveRefundEvent` (Task 4), `RefundManager.processRefund(Session, RefundEvent)` (existing, unchanged).
- Produces: `PolarRail.processCallback` now does real work instead of always returning `PaymentResult(success: true)`.

This is the task that actually fixes CRITICAL #1 — everything before it was groundwork.

- [ ] **Step 1: Write the failing tests**

Replace the existing stub test in `test/unit/polar_rail_test.dart`:

```dart
test('processCallback returns success acknowledgement (stub today)',
    () async {
  ...
});
```

with a new `withServerpod` group (this needs a real `Session` for `RefundManager.processRefund` and DB fixtures — mirrors `apple_iap_rail_test.dart`'s `'Apple IAP Rail - processCallback refund flow'` group). Add near the bottom of the file, replacing the deleted stub test:

```dart
withServerpod('PolarRail.processCallback', (sessionBuilder, endpoints) {
  setUp(() => RefundManager.resetHandler());
  tearDown(() => RefundManager.resetHandler());

  PolarRail railWithSecret(Future<http.Response> Function(http.Request) handler) {
    return PolarRail(
      client: PolarClient(
        organizationId: 'org',
        http: PolarHttpClient(
          baseUrl: 'https://api.polar.sh',
          bearerToken: 't',
          httpClient: MockClient(handler),
        ),
      ),
      signatureValidator: PolarSignatureValidator(secret: 'whsec_dGVzdA=='),
    );
  }

  Map<String, String> validHeaders(String id, String timestamp, String body) {
    // Build a real signature the same way PolarSignatureValidator.verify
    // checks it (secret 'whsec_dGVzdA==' → key bytes are base64-decoded
    // 'dGVzdA=='), so these tests exercise the actual HMAC path, not a stub.
    final key = base64.decode('dGVzdA==');
    final sig = base64.encode(
      Hmac(sha256, key).convert(utf8.encode('$id.$timestamp.$body')).bytes,
    );
    return {
      'webhook-id': id,
      'webhook-timestamp': timestamp,
      'webhook-signature': 'v1,$sig',
    };
  }

  test('rejects delivery when no signature validator is configured',
      () async {
    final rail = PolarRail(
      client: PolarClient(
        organizationId: 'org',
        http: PolarHttpClient(
          baseUrl: 'https://api.polar.sh',
          bearerToken: 't',
          httpClient: MockClient((req) async => http.Response('{}', 200)),
        ),
      ),
      // no signatureValidator
    );
    final session = sessionBuilder.build();
    final result = await rail.processCallback({
      'session': session,
      'request_body': '{"type":"refund.created"}',
      'headers': <String, String>{},
    });
    expect(result.success, isFalse);
  });

  test('rejects delivery with a bad signature', () async {
    final rail = railWithSecret((req) async => http.Response('{}', 200));
    final session = sessionBuilder.build();
    const body = '{"type":"refund.created"}';
    final result = await rail.processCallback({
      'session': session,
      'request_body': body,
      'headers': {
        'webhook-id': 'evt-1',
        'webhook-timestamp':
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        'webhook-signature': 'v1,not-the-real-signature',
      },
    });
    expect(result.success, isFalse);
  });

  test('acknowledges and does nothing for a non-refund event type',
      () async {
    final rail = railWithSecret((req) async => http.Response('{}', 200));
    final session = sessionBuilder.build();
    const body = '{"type":"order.created","data":{}}';
    final ts = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final result = await rail.processCallback({
      'session': session,
      'request_body': body,
      'headers': validHeaders('evt-2', ts, body),
    });
    expect(result.success, isTrue);
  });

  test('forwards a resolved refund to RefundManager with the license-key id',
      () async {
    var getOrderCalled = false;
    final rail = railWithSecret((req) async {
      if (req.url.path.contains('/orders/')) {
        getOrderCalled = true;
        return http.Response(
          jsonEncode({'id': 'ord-live', 'license_key_id': 'lk-live'}),
          200,
        );
      }
      return http.Response('{}', 200);
    });
    final session = sessionBuilder.build();

    String? forwardedPaymentRef;
    RefundManager.onRefund((s, event, context) async {
      forwardedPaymentRef = event.paymentRef;
      return RefundAction.ignore;
    });

    final body = jsonEncode({
      'type': 'refund.created',
      'data': {'order_id': 'ord-live', 'product_id': 'prod-x'},
    });
    final ts = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    final result = await rail.processCallback({
      'session': session,
      'request_body': body,
      'headers': validHeaders('evt-3', ts, body),
    });

    expect(result.success, isTrue);
    expect(getOrderCalled, isTrue);
    expect(forwardedPaymentRef, 'lk-live');
  });

  test('acknowledges (does not error) when order resolution fails',
      () async {
    final rail = railWithSecret((req) async => http.Response('not found', 404));
    final session = sessionBuilder.build();

    var hookCalled = false;
    RefundManager.onRefund((s, event, context) async {
      hookCalled = true;
      return RefundAction.ignore;
    });

    final body = jsonEncode({
      'type': 'refund.created',
      'data': {'order_id': 'ord-gone'},
    });
    final ts = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    final result = await rail.processCallback({
      'session': session,
      'request_body': body,
      'headers': validHeaders('evt-4', ts, body),
    });

    expect(result.success, isTrue);
    expect(hookCalled, isFalse);
  });
});
```

Add imports to the test file: `import 'package:crypto/crypto.dart';`, `import 'package:anonaccred_server/src/payments/polar_signature_validator.dart';`, `import 'package:anonaccred_server/src/refund_manager.dart';`, `import '../integration/test_tools/serverpod_test_tools.dart';`.

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test test/unit/polar_rail_test.dart`
Expected: FAIL — every new test observes `result.success == true` with no signature check and no `getOrder` call, because `processCallback` is still the stub. The "bad signature" and "no validator" tests fail because nothing rejects them; the "forwards refund" test fails because `getOrderCalled` stays false and `forwardedPaymentRef` stays null.

- [ ] **Step 3: Write minimal implementation**

Add the import (not already present in this file — `polar_rail.dart` currently imports `refund_event.dart` but not `refund_manager.dart`):

```dart
import '../../refund_manager.dart';
```

Replace `processCallback` in `polar_rail.dart`:

```dart
@override
Future<PaymentResult> processCallback(
    Map<String, dynamic> callbackData) async {
  final session = callbackData['session'] as Session?;
  final requestBody = callbackData['request_body'] as String?;
  final headers =
      (callbackData['headers'] as Map<String, dynamic>?) ?? const {};

  if (session == null || requestBody == null) {
    return PaymentResult(
      success: false,
      errorMessage: 'Malformed payload: missing session or request_body',
    );
  }

  final validator = signatureValidator;
  if (validator == null) {
    session.log(
      'Polar webhook rejected: POLAR_WEBHOOK_SECRET not configured',
      level: LogLevel.error,
    );
    return PaymentResult(
      success: false,
      errorMessage: 'Webhook signature validation not configured',
    );
  }

  final valid = validator.verify(
    id: headers['webhook-id'] as String? ?? '',
    timestamp: headers['webhook-timestamp'] as String? ?? '',
    signatureHeader: headers['webhook-signature'] as String? ?? '',
    rawBody: requestBody,
  );
  if (!valid) {
    session.log('Polar webhook signature invalid', level: LogLevel.warning);
    return PaymentResult(
      success: false,
      errorMessage: 'Invalid webhook signature',
    );
  }

  final Map<String, dynamic> notificationData;
  try {
    notificationData = jsonDecode(requestBody) as Map<String, dynamic>;
  } on FormatException {
    return PaymentResult(
      success: false,
      errorMessage: 'Malformed payload: invalid JSON',
    );
  }

  final preliminary = extractRefundEvent(notificationData);
  if (preliminary != null) {
    final orderId = (notificationData['data']
        as Map<String, dynamic>?)?['order_id'] as String?;
    final resolved = orderId == null
        ? null
        : await resolveRefundEvent(orderId, preliminary);
    if (resolved != null) {
      await RefundManager.processRefund(session, resolved);
    } else {
      session.log(
        'Polar refund could not be resolved to a license key for '
        'order_id=$orderId; acknowledging without action',
        level: LogLevel.warning,
      );
    }
  }

  return PaymentResult(success: true);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `dart test test/unit/polar_rail_test.dart`
Expected: PASS, all tests in the file (old and new) pass.

- [ ] **Step 5: Run the full anonaccred_server suite**

Run: `dart test`
Expected: PASS. Two known pre-existing failures may appear — the macOS `webcrypto`/BoringSSL issue documented in this project's own memory — unrelated to this change; no other failures.

- [ ] **Step 6: `dart analyze` check**

Run: `dart analyze`
Expected: 0 errors, 0 warnings (info-level lints acceptable, matching this package's existing baseline).

- [ ] **Step 7: Commit**

```bash
git add anonaccred_server/lib/src/payments/rails/polar_rail.dart anonaccred_server/test/unit/polar_rail_test.dart
git commit -m "feat(polar): wire processCallback to validate, resolve, and forward refunds"
```

---

### Task 7: `redeemLicenseKey` test coverage

**Files:**
- Create: `anonaccred_server/test/unit/polar_endpoint_test.dart`

**Interfaces:**
- Consumes: `endpoints.polar.redeemLicenseKey(sessionBuilder, licenseKey, {shareGroupUuid, internalTransactionId})` (generated test facade, mirrors `endpoints.iAP.validateAppleTransaction` usage in `iap_endpoint_integration_test.dart`), `PaymentManager.registerRail`/`clearRails`, `PolarRail`/`PolarClient`/`PolarHttpClient` (Task 5 makes this rail injectable).

This is "Also in scope" from the A2 spec — same rail, same change window, closes the file that doesn't exist today (`test/unit/polar_*_test.dart` covers client/signature-validator/rail, never the endpoint).

- [ ] **Step 1: Write the failing tests**

Create `test/unit/polar_endpoint_test.dart`:

```dart
import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:anonaccred_server/src/payments/polar_client.dart';
import 'package:anonaccred_server/src/payments/polar_http_client.dart';
import 'package:anonaccred_server/src/payments/rails/polar_rail.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

/// Standard "granted" license-key validation response body.
Map<String, dynamic> _grantedResponse({
  String id = 'lk-1',
  String benefitId = 'benefit-1',
}) => {
  'id': id,
  'key': 'KEY-XXXX',
  'status': 'granted',
  'organization_id': 'org',
  'benefit_id': benefitId,
  'customer_id': 'cust-1',
  'expires_at': null,
};

void main() {
  withServerpod('PolarEndpoint.redeemLicenseKey', (sessionBuilder, endpoints) {
    late AnonAccount testAccount;
    late TestSessionBuilder authenticatedSessionBuilder;

    setUp(() async {
      PaymentManager.clearRails();
      final session = sessionBuilder.build();
      testAccount = await AnonAccount.db.insertRow(
        session,
        AnonAccount(
          id: UuidValue.fromString(const Uuid().v4()),
          ultimateSigningPublicKeyHex: 'a' * 128,
          encryptedDataKey: 'data',
          ultimateEncryptionPublicKeyHex: 'b' * 128,
        ),
      );
      final device = await AccountDevice.db.insertRow(
        session,
        AccountDevice(
          anonAccountId: testAccount.id!,
          deviceSigningPublicKeyHex: 'c' * 128,
          deviceEncryptionPublicKeyHex: 'd' * 128,
          addedByAttestorPublicKeyHex: 'a' * 128,
          addedByAttestation: 'test-attestation',
          encryptedDataKey: 'device_data',
          label: 'Test Device',
        ),
      );
      authenticatedSessionBuilder = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          testAccount.id.toString(),
          {Scope('device:${device.deviceSigningPublicKeyHex}')},
          authId: device.deviceSigningPublicKeyHex,
        ),
      );
    });

    tearDown(PaymentManager.clearRails);

    void registerPolarRail(Future<http.Response> Function(http.Request) handler) {
      PaymentManager.registerRail(PolarRail(
        client: PolarClient(
          organizationId: 'org',
          http: PolarHttpClient(
            baseUrl: 'https://api.polar.sh',
            bearerToken: 't',
            httpClient: MockClient(handler),
          ),
        ),
      ));
    }

    test('fails without authentication', () async {
      registerPolarRail((req) async => http.Response('{}', 200));
      await expectLater(
        endpoints.polar.redeemLicenseKey(sessionBuilder, 'KEY-XXXX'),
        throwsA(isA<Exception>()),
      );
    });

    test('throws for an empty license key', () async {
      registerPolarRail((req) async => http.Response('{}', 200));
      await expectLater(
        endpoints.polar.redeemLicenseKey(authenticatedSessionBuilder, ''),
        throwsA(isA<PaymentException>()),
      );
    });

    test('happy path: account target, credits the account entitlement',
        () async {
      registerPolarRail(
        (req) async => http.Response(jsonEncode(_grantedResponse()), 200),
      );
      final session = sessionBuilder.build();
      final entitlement = await Entitlement.db.insertRow(
        session,
        Entitlement(
          tag: 'coins',
          name: 'coins',
          type: EntitlementType.consumable,
          serverValidated: true,
        ),
      );
      final railProduct = await RailProduct.db.insertRow(
        session,
        RailProduct(
          rail: PaymentRail.polar,
          storeProductId: 'benefit-1',
          isActive: true,
        ),
      );
      await RailProductGrant.db.insertRow(
        session,
        RailProductGrant(
          railProductId: railProduct.id!,
          entitlementId: entitlement.id!,
          quantity: 50.0,
        ),
      );

      final result = await endpoints.polar.redeemLicenseKey(
        authenticatedSessionBuilder,
        'KEY-XXXX',
      );

      expect(result.success, isTrue);
      expect(result.productId, 'benefit-1');
      expect(result.tag, 'coins');
      expect(result.amount, 50.0);
      expect(result.fromCache, isFalse);
    });

    test('group target: throws AUTH_ACCOUNT_NOT_FOUND when caller is not a member',
        () async {
      registerPolarRail(
        (req) async => http.Response(jsonEncode(_grantedResponse()), 200),
      );
      await expectLater(
        endpoints.polar.redeemLicenseKey(
          authenticatedSessionBuilder,
          'KEY-XXXX',
          shareGroupUuid: UuidValue.fromString(const Uuid().v4()),
        ),
        throwsA(isA<AnonAccountException>()),
      );
    });

    test('throws POLAR_BENEFIT_UNMAPPED when no RailProduct exists for the benefit',
        () async {
      registerPolarRail(
        (req) async => http.Response(jsonEncode(_grantedResponse()), 200),
      );
      await expectLater(
        endpoints.polar.redeemLicenseKey(authenticatedSessionBuilder, 'KEY-XXXX'),
        throwsA(isA<PaymentException>()),
      );
    });

    test('throws POLAR_SCOPE_MISMATCH when an account-scoped benefit targets a group',
        () async {
      registerPolarRail(
        (req) async => http.Response(jsonEncode(_grantedResponse()), 200),
      );
      final session = sessionBuilder.build();
      final entitlement = await Entitlement.db.insertRow(
        session,
        Entitlement(
          tag: 'coins', // no group_ prefix → account-scoped
          name: 'coins',
          type: EntitlementType.consumable,
          serverValidated: true,
        ),
      );
      final railProduct = await RailProduct.db.insertRow(
        session,
        RailProduct(
          rail: PaymentRail.polar,
          storeProductId: 'benefit-1',
          isActive: true,
        ),
      );
      await RailProductGrant.db.insertRow(
        session,
        RailProductGrant(
          railProductId: railProduct.id!,
          entitlementId: entitlement.id!,
          quantity: 1.0,
        ),
      );
      final group = await ShareGroup.db.insertRow(
        session,
        ShareGroup(
          ultimateSigningPublicKeyHex: 'e' * 128,
          ultimateEncryptionPublicKeyHex: 'f' * 128,
          encryptedDataKey: 'group_data',
        ),
      );
      await GroupMember.db.insertRow(
        session,
        GroupMember(
          shareGroupId: group.id!,
          anonAccountId: testAccount.id!,
          role: GroupMemberRole.admin,
          memberSigningPublicKeyHex: testAccount.ultimateSigningPublicKeyHex,
          memberEncryptionPublicKeyHex: testAccount.ultimateEncryptionPublicKeyHex,
          encryptedDataKey: 'wrapped',
          encryptedMemberKey: 'wrapped',
          addedByAttestorPublicKeyHex: testAccount.ultimateSigningPublicKeyHex,
          addedByAttestation: 'test-attestation',
        ),
      );

      await expectLater(
        endpoints.polar.redeemLicenseKey(
          authenticatedSessionBuilder,
          'KEY-XXXX',
          shareGroupUuid: group.id,
        ),
        throwsA(isA<PaymentException>()),
      );
    });
  });
}
```

Check field names on `ShareGroup`/`GroupMember` against `group_commerce_endpoint_test.dart` before running — this test mirrors that file's fixture shape but trims unused fields; if `ShareGroup`/`GroupMember` require additional non-nullable fields not listed here, add them to match the model, not by guessing — read `lib/src/models/share_group.spy.yaml` and `lib/src/models/group_member.spy.yaml` directly if the compiler flags missing required params.

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test test/unit/polar_endpoint_test.dart`
Expected: FAIL on the "fails without authentication" and "happy path" tests specifically because `redeemLicenseKey` calls `PolarRail.fromEnvironment()` (ignores the registered mock rail) — before Task 5 lands, the happy-path test either throws a `configurationMissing` `PaymentException` (no real `POLAR_ACCESS_TOKEN` in the test environment) or hits the real network, not the `MockClient`. This is the concrete proof Task 5 is needed, not just a nice-to-have.

If Task 5 already landed (recommended order — do Task 5 before writing this test file, so this step's failure is purely "endpoint file doesn't exist yet" / "PolarEndpoint doesn't credit the right entitlement" rather than a rail-wiring failure), expect the more normal RED: compile succeeds, `happy path` test fails because DB rows don't exist / mock isn't wired — confirm by running and reading the actual failure message, don't assume.

- [ ] **Step 3: Fix whatever the RED output says needs fixing**

If Task 5 already landed correctly, no production code changes should be needed here — this task is pure test-writing against already-correct behavior (Bug 2's fix from Task 2, `redeemLicenseKey`'s existing logic). If a test fails for a reason that isn't "test setup is wrong," stop and treat it as a real bug found by this coverage — fix it with its own RED→GREEN cycle before continuing.

- [ ] **Step 4: Run test to verify it passes**

Run: `dart test test/unit/polar_endpoint_test.dart`
Expected: PASS, all 6 tests.

- [ ] **Step 5: Run the full suite + analyze**

Run: `dart test && dart analyze`
Expected: PASS / 0 errors, 0 warnings.

- [ ] **Step 6: Commit**

```bash
git add anonaccred_server/test/unit/polar_endpoint_test.dart
git commit -m "test(polar): add redeemLicenseKey coverage"
```

---

## Non-goals (unchanged from the spec)

- No attestation added to `redeemLicenseKey` (D17).
- B4/B5 refund-idempotency-locking work — separate spec/plan, land independently.
- No rails-dedupe work.
- No redesign of where `POLAR_WEBHOOK_SECRET` lives beyond "read it the same way the other three Polar env vars are already read" (Task 1).

## Where this was found

Same grounding as the spec (`docs/superpowers/specs/2026-08-02-polar-refund-wiring-design.md`), plus, while writing this plan: `anonaccred_server/lib/src/models/rail_product_grant.spy.yaml` and `anonaccred_server/migrations/20260802130701358/definition.sql` (lines ~872-877, the `rail_product_grant_fk_1` FK) for the Task 2 correction; `anonaccred_server/lib/src/webhooks/polar_webhook_route.dart` (lines 35-38) and `anonaccred_server/lib/src/endpoints/polar_endpoint.dart:76` for the Task 5 correction; `anonaccred_server/test/unit/polar_rail_test.dart`, `anonaccred_server/test/unit/apple_iap_rail_test.dart`, `anonaccred_server/test/unit/refund_manager_test.dart`, `anonaccred_server/test/integration/iap_endpoint_integration_test.dart`, and `anonaccred_server/test/integration/group_commerce_endpoint_test.dart` for existing test conventions this plan's new tests mirror. All against pinned ref `5542026d8b9afdfbf488b2c1b23a43ca2ae42e54` unless noted.
