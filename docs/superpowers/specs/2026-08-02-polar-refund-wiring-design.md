# Wire Polar refunds to RefundManager

**Date:** 2026-08-02
**Scope:** `anonaccred_server` — `payments/rails/polar_rail.dart`, `payments/polar_client.dart`, `endpoints/polar_endpoint.dart`
**Conventions:** `docs/superpowers/DECISIONS.md` — D17 (no attestation on this side of the boundary, do not add any), D1 (no compat shims)
**Depends on:** nothing. Independent of the B4/B5 refund-idempotency-locking work — this spec fixes correctness of the Polar refund *path*; B4/B5 fixes concurrency of the shared `RefundManager`/`CommerceManager` idempotency checks. Land this first; B4/B5 can follow without touching this file.
**Tracked as:** A2 (`docs/superpowers/TODO-2026-08-02.md`), CRITICAL #1 (`docs/superpowers/anonaccred-issues-2026-08-02.md`)

---

## The problem is not just "wire it up"

`PolarRail.processCallback` (`polar_rail.dart:261-269`) acknowledges every Polar webhook delivery and does nothing else:

```dart
Future<PaymentResult> processCallback(Map<String, dynamic> callbackData) async {
  // TODO(polar-webhook-refund-resolution): wire Polar order_id →
  // license_key_id via `client.getOrder(orderId)`, then forward the
  // resulting RefundEvent to RefundManager.processRefund. For now we
  // acknowledge deliveries without action so Polar stops retrying.
  return PaymentResult(success: true);
}
```

The pieces this needs already exist and are unreachable from this path: `PolarSignatureValidator` (`payments/polar_signature_validator.dart`) is fully implemented and referenced exactly once outside its own file — an `export` in the barrel (`anonaccred_server.dart:80`). Nothing constructs it; there is not even an env var wired up for the webhook secret yet. `PolarRail.extractRefundEvent` (`polar_rail.dart:271-297`), immediately below the stub, is also fully implemented and equally unreachable.

Wiring these three together is not just plumbing, though, because **`extractRefundEvent` currently produces a `RefundEvent` that can never match its own purchase.** This is not a hypothetical — it's a live bug in code that's about to go live for the first time, and if it ships as-is, wiring `processCallback` up correctly will still silently fail every refund. That bug has to be fixed in the same change, not filed separately, because there is no way to "wire up refund resolution" without touching the exact lines the bug is in.

## Bug 1: the refund event can never match its own purchase

`RefundEvent.receiptHash` and `.paymentRef` are documented (`refund_event.dart:17-23`) to match `ReceiptHash.hash` and `TransactionPayment.paymentRef` respectively — `RefundManager._resolveContext` (`refund_manager.dart:94-113`) does two independent lookups, one by each field, not a join through one:

```dart
// refund_manager.dart:94-113
final hashRecord = await ReceiptHash.db.findFirstRow(
  session, where: (t) => t.hash.equals(event.receiptHash));
...
final payment = await TransactionPayment.db.findFirstRow(
  session, where: (t) => t.paymentRef.equals(event.paymentRef));
```

At delivery time (`validateLicenseKey`, `polar_rail.dart:92-249`), both of those are written from **`validation.id`** — Polar's license-key UUID:

- `polar_rail.dart:95`: `licenseHash = CryptoUtils.sha256Hash(validation.id)` → stored as `ReceiptHash.hash`
- `polar_rail.dart:214`: `paymentRef: validation.id, // license_key_id` → stored as `TransactionPayment.paymentRef`

But `extractRefundEvent` (`polar_rail.dart:271-297`) builds both fields from the webhook's **`order_id`** instead:

```dart
// polar_rail.dart:286-293
return RefundEvent(
  rail: PaymentRail.polar,
  receiptHash: CryptoUtils.sha256Hash(orderId),
  paymentRef: orderId,
  ...
);
```

`license_key_id` and `order_id` are different Polar identifiers. `sha256(order_id)` will never equal the `ReceiptHash.hash` row written at delivery, and `order_id` will never equal the `TransactionPayment.paymentRef` written at delivery. Every refund resolves to `bridgeExpired: true` — the exact case that logs and no-ops rather than revoking anything. Wiring `processCallback` up without fixing this ships a refund path that *looks* live (200 OK to Polar, log line saying "processed") and revokes nothing, which is strictly worse than the current honest no-op stub, because it appears to work.

**Fix:** `extractRefundEvent` needs the license-key UUID, not the order UUID. Polar's webhook payload for `refund.created`/`refund.updated` only carries `order_id` (`polar_rail.dart:279`) — the translation the existing `TODO` already names is not optional plumbing, it is the fix for this bug. See "Wiring order" below for where the `client.getOrder` call has to happen relative to signature validation.

## Bug 2: null entitlement silently changes which target gets credited

Adjacent to the above, in the same method (`validateLicenseKey`, `polar_rail.dart:144-151`):

```dart
final firstGrantEntitlement = await Entitlement.db.findById(
  session, grantList.first.entitlementId);
final productIsGroup = firstGrantEntitlement?.tag.startsWith('group_') ?? false;
```

If `grantList.first.entitlementId` doesn't resolve to a row — a `RailProductGrant` pointing at a deleted or never-created `Entitlement`, a configuration mistake made once and never caught — this doesn't throw. It silently treats the product as account-scoped. If the product was actually meant to be group-scoped, and the caller passed a `GroupTarget`, the scope-mismatch check three lines below (`polar_rail.dart:152-166`) *would* have caught the misconfiguration and thrown `polarScopeMismatch` — but the null fallback routes around that check by asserting a scope that doesn't reflect the actual (broken) configuration state.

Not a webhook/refund bug specifically, but it's in `validateLicenseKey`, the same method this spec is already touching for the hash fix, and it's a data-integrity issue in the same family (silently-wrong instead of loudly-wrong). Fix it in the same pass: fail loud when the entitlement lookup misses.

```dart
final firstGrantEntitlement = await Entitlement.db.findById(
  session, grantList.first.entitlementId);
if (firstGrantEntitlement == null) {
  throw AnonAccredExceptionFactory.createPaymentException(
    code: AnonAccredErrorCodes.polarBenefitUnmapped,
    message: 'RailProductGrant ${grantList.first.id} references missing '
        'Entitlement ${grantList.first.entitlementId}',
    paymentRail: PaymentRail.polar.name,
  );
}
final productIsGroup = firstGrantEntitlement.tag.startsWith('group_');
```

## Wiring order

Compare against Apple's `processCallback` (`apple_iap_rail.dart:92-170`), the reference shape both Google and this fix should mirror: validate the outer envelope before decoding anything, decode before routing, route before touching `RefundManager`. Polar's callback data (from `polar_webhook_route.dart:67-71`) is `{'session': ..., 'request_body': ..., 'headers': {...}}` — the header map is already lower-cased there (`polar_webhook_route.dart:64`).

1. **Validate the Standard Webhooks signature first**, before parsing the body as JSON. `PolarSignatureValidator.verify` needs `id`/`timestamp`/`signatureHeader` from `headers['webhook-id']` / `headers['webhook-timestamp']` / `headers['webhook-signature']`, plus the raw `request_body` string — not the decoded map, per `polar_signature_validator.dart:16` ("signed payload is `${id}.${timestamp}.${rawBody}`"). This has no network dependency and should reject bad deliveries before any DB or Polar-API call.

   **Open question, not this spec's to answer:** where does the webhook secret come from? No env var exists yet (`PolarRail.fromEnvironment` only reads `POLAR_ACCESS_TOKEN`/`POLAR_ORGANIZATION_ID`/`POLAR_ENVIRONMENT`). Needs a `POLAR_WEBHOOK_SECRET` (or similar) added to that factory, and `PolarSignatureValidator` constructed once at rail-init time, not per-callback — check whether `PolarRail` should own a `PolarSignatureValidator?` field the way it owns `PolarClient`.

2. **Parse the body JSON only after signature validation passes.** Route on `type` — `extractRefundEvent` already gates on `'refund.created'`/`'refund.updated'` internally (`polar_rail.dart:275`), so `processCallback` can call it unconditionally and treat a `null` return as "not a refund notification, acknowledge and stop" (mirrors Apple's `if (event != null)` at `apple_iap_rail.dart:144`).

3. **Resolve `order_id` → `license_key_id`** via `client.getOrder(orderId)` (`polar_client.dart:163-166`) before constructing the `RefundEvent` — this has to happen inside `extractRefundEvent` (or a helper it calls), since that's where `receiptHash`/`paymentRef` get built, and both need the resolved ID. `extractRefundEvent` is currently synchronous; this fix makes it `async` and gives it a network dependency it didn't have before. Its signature (`RefundEvent? extractRefundEvent(Map<String, dynamic> notificationData)`) is declared on `PaymentRailInterface` — check whether that's shared with Apple/Google (both currently synchronous, parsing pure JSON) before changing it; if the interface method must stay sync, do the `getOrder` resolution in `processCallback` before calling a lower-level sync extractor, not inside `extractRefundEvent` itself.

   **Open question, not this spec's to answer:** which field on the `getOrder` response body is the license-key UUID. `getOrder`'s own doc comment (`polar_client.dart:158-161`) says this is exactly what it's for but doesn't name the field — confirm against Polar's order-object API docs before implementing, don't guess a JSON path.

4. **Forward to `RefundManager.processRefund(session, event)`** once the event carries the corrected `receiptHash`/`paymentRef`. This part needs no changes — `RefundManager` is rail-agnostic and already used correctly by Apple and Google.

5. **Return `PaymentResult(success: true)`** regardless of whether a matching purchase was found — Apple's shape acknowledges the webhook either way (`apple_iap_rail.dart:147-150`) and lets `RefundContext.bridgeExpired` carry the "couldn't resolve" signal into logs, not into the HTTP response. Polar should not retry-storm on a refund for a purchase this system never saw.

## Also in scope: `redeemLicenseKey` has zero test coverage

`PolarEndpoint.redeemLicenseKey` (`endpoints/polar_endpoint.dart:27-102`) — same rail, no test file exists (`test/unit/polar_*_test.dart` covers the client/signature-validator/rail layers but there is no `polar_endpoint_test.dart`). Bundling this into A2 rather than filing separately because implementing this spec is the natural point to add coverage for the method that calls into the code being changed — write it against the corrected `validateLicenseKey` (Bug 2 fix included), not the current behavior.

## Non-goals

- **No attestation.** Per D17, Polar redemption authorizes on JWT + `GroupMember` row, same as every other entitlement/commerce endpoint. Do not add signature verification on the redemption call itself — only on the *webhook delivery*, which is a different trust boundary (Polar's server, not the end user).
- **Not fixing B4/B5 here.** `RefundManager._resolveContext`'s unlocked idempotency check and `TransactionPayment.paymentRef`'s missing uniqueness constraint are real and adjacent, but they're rail-agnostic — Apple and Google hit the same code path today. Fixing them here would couple an isolated, low-risk correctness fix to a schema change that (per D3) needs to be announced and batched separately. Land this spec first.
- **Not deduping the three rails' shared transaction pattern.** That work explicitly waits until Polar has test coverage comparable to Apple/Google (see the parent issues doc's "Duplication" section) — this spec is what gets Polar to that baseline, not what does the dedupe.
- **Not redesigning the webhook secret storage mechanism.** Wherever `POLAR_WEBHOOK_SECRET` ends up living, follow whatever pattern the other rails' env-var secrets already use — this is a wiring gap, not a secrets-architecture decision.

## Where this was found

`anonaccred_server/lib/src/payments/rails/polar_rail.dart` (lines 92-297), `anonaccred_server/lib/src/payments/polar_signature_validator.dart`, `anonaccred_server/lib/src/payments/polar_client.dart` (lines 100-168), `anonaccred_server/lib/src/endpoints/polar_endpoint.dart`, `anonaccred_server/lib/src/refund_manager.dart` (lines 76-113), `anonaccred_server/lib/src/refund_event.dart`, and the Apple reference shape in `anonaccred_server/lib/src/payments/rails/apple_iap_rail.dart` (lines 92-170) — all against pinned ref `5542026d8b9afdfbf488b2c1b23a43ca2ae42e54`. Bug 1 independently verified by reading `validateLicenseKey`'s write path against `extractRefundEvent`'s read path side by side; not present in the original audit note that flagged the stub, found during the mechanical-fixes pass that preceded this spec.
