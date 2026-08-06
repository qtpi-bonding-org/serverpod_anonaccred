# Anonaccred Commerce Flow Test Harness — Design

## Goal

Give `anonaccred_server` (entitlements/commerce/IAP) the same flow-level test
coverage anonaccount_server already has (see
`2026-08-03-sdk-e2e-workflow-harness-design.md`'s `e2e_*.dart` tests): full
multi-step user flows through real endpoints against a real Postgres-backed
test server, not one-off calls per endpoint. Close two concrete gaps found
while mapping the surface — Polar has no mock client (Apple and Google do),
and the webhook ingestion path (`apple_webhook_route.dart`,
`google_webhook_route.dart`, `polar_webhook_route.dart`) has zero test
coverage today. And fix two provider-verification bugs discovered while
researching what "faking a valid webhook" actually requires, so the new
webhook tests validate real behavior instead of a fictional one.

## Why not the SDK-driven pattern anonaccount used

anonaccount's harness drives real PoW-protected, signature-envelope
endpoints via a hand-written client (`anonaccount_sdk`) using real key
material. anonaccred's endpoints (`IAPEndpoint`, `CommerceEndpoint`,
`PolarEndpoint`, `GroupCommerceEndpoint`) are all `JwtEndpoint`s — they take
no challenge/PoW/signature parameters at all. Identity comes entirely from
`session.authenticated` (a JWT's claims), which is populated in production
by `DeviceEndpoint.signIn` (in `anonaccount_server`) after real PoW+ECDSA
verification, then handed to Serverpod's real token manager
(`AuthServices.instance.tokenManager.issueToken`, configured via
`JwtConfigFromPasswords()` in `quanitya_cloud_server/lib/server.dart`).

That JWT-minting flow is real and crypto-gated, but it lives in a different
Serverpod module (`anonaccount_server`) with its own generated
`TestEndpoints`, which anonaccred_server's own generated test harness does
not include. There is no single `withServerpod` call that can drive both
modules' endpoints together — they are deliberately kept as separate
Serverpod services. Re-running `signIn`'s PoW/crypto path from inside
anonaccred_server's test suite is therefore not possible, and not useful:
that path is already covered by anonaccount_server's own tests.

Consequently, anonaccred's tests build identity the way they already do —
a real `AnonAccount` + `AccountDevice` row plus `AuthenticationOverride`
reproducing the JWT's shape (`userIdentifier` = account UUID,
`device:<pubkey>` scope) — and focus flow coverage on what's actually
anonaccred's own responsibility: entitlement/commerce logic, rail
fulfillment, refunds, and webhook ingestion.

## Confirmed bugs found during research (fixed as part of this plan)

### Apple: wrong verification model

`notification_signature_validator.dart` fetches a JWKS from
`https://api.appstoreconnect.apple.com/v1/certs` and looks up the signing
key by `kid`. Real Apple App Store Server Notifications embed the signing
certificate chain directly in each JWS's `x5c` header; verification means
validating that chain against Apple's fixed Root CA G3 certificate, not
fetching a runtime JWKS. Two concrete symptoms:

- Sandbox notifications have no `kid` field at all — current code's
  `if (keyId == null) return false;` rejects every sandbox notification.
- `https://api.appstoreconnect.apple.com/v1/certs` is not a documented
  Apple endpoint for this purpose (may be confused with Sign in with
  Apple's unrelated JWKS at `appleid.apple.com/auth/keys`).

**Fix:** replace JWKS+kid lookup with x5c chain-of-trust verification:
parse the JWS header's certificate chain (`package:x509`), verify leaf →
intermediate → a bundled Apple Root CA G3 certificate (a fixed constant,
not fetched), then verify the ES256 signature with the leaf certificate's
public key. Must also succeed for sandbox notifications (no `kid`).

`x509` and `asn1lib` currently resolve only as *transitive* dependencies
(pulled in by something else, likely `googleapis_auth` or
`app_store_server_sdk`) — not declared in `pubspec.yaml`. This plan adds
both as explicit direct dependencies rather than relying on transitive
resolution, which could silently break if the package that currently pulls
them in changes its own dependencies.

### Google: wrong envelope, wrong fields, wrong auth model

Real Google Play Real-time Developer Notifications deliver a Pub/Sub push
HTTP POST shaped as
`{"message": {"data": "<base64 DeveloperNotification JSON>", "messageId": "...", ...}, "subscription": "..."}`,
with camelCase fields (`packageName`, `subscriptionNotification`, etc.),
authenticated via a Pub/Sub-issued OIDC bearer token verified against
Google's real public-certs endpoint. `google_webhook_route.dart` instead
expects a flat, snake_case JSON body (`package_name`, `product_id`,
`notification_type`, ...) directly at the top level, "verified" by
`webhook_signature_validator.dart`'s custom HMAC scheme keyed off
`GOOGLE_WEBHOOK_SIGNING_KEY` — a scheme with no counterpart in Google's
actual product. A real RTDN delivery would not parse today.

**Fix:** parse the real Pub/Sub envelope (base64-decode `message.data` to
the camelCase `DeveloperNotification` JSON), verify the request's
`Authorization: Bearer <token>` against Google's real public-certs JWKS
endpoint, and check `iss`/`aud`/service-account `email` claims. This
reuses the fetch-and-cache JWKS pattern currently (mis)implemented for
Apple — Google is where that model actually belongs.

### Polar: correct, no change

`polar_signature_validator.dart` / `polar_rail.dart`'s `processCallback`
match the real Standard Webhooks spec exactly: `webhook-id` /
`webhook-timestamp` / `webhook-signature` headers, signed content
`${id}.${timestamp}.${rawBody}`, HMAC-SHA256, `v1,<base64>` format,
`whsec_`-prefixed secret. No fix needed; used as the reference shape for
the other two.

## Out of scope

`quanitya_cloud_server/lib/server.dart` registers `AppleWebhookRoute` and
`GoogleWebhookRoute` but never registers `PolarWebhookRoute` — Polar
refunds/cancellations currently have no path into `RefundManager` in
production. This is a real finding but lives in a different repo
(`quanitya_cloud_server`, the consuming app) that this plan does not touch.
Flagged for a separate one-line fix there:
`pod.webServer.addRoute(PolarWebhookRoute(), '/hooks/polar');`

## Architecture

### `MockPolarClient`

Same shape as the existing `MockAppStoreServerClient` /
`MockAndroidPublisherClient`: a call-log (`List<ApiCall>`) plus
programmable responses keyed by license key / order id, implementing
whatever interface `PolarClient` exposes to `PolarRail`. Gives Polar the
same mockability the other two rails already have, for both endpoint-level
and flow-level tests.

### `CommerceTestHarness` (test_tools)

A helper living in `anonaccred_server/test/integration/test_tools/`,
analogous in purpose (not mechanism — see above) to anonaccount's
`SimulatedUser`:

- Creates a real `AnonAccount` + `AccountDevice` via direct DB insert
  (matching the existing pattern in `iap_endpoint_integration_test.dart`
  etc.), builds the corresponding `AuthenticationOverride` session.
- Registers all three mock rails (`MockAppStoreServerClient`,
  `MockAndroidPublisherClient`, `MockPolarClient`) via
  `PaymentManager.registerRail`.
- Exposes flow-level actions instead of raw endpoint calls: `buyApple(...)`,
  `buyGoogle(...)`, `redeemPolar(...)`, `consumeEntitlement(...)`,
  `getBalance(...)`, group variants (`redeemPolarForGroup(...)`,
  `consumeGroupEntitlement(...)`), and a way to construct a second
  `CommerceTestHarness` sharing the same group for multi-member scenarios.

### `WebhookSigner` (test_tools)

Produces validly-signed payloads for all three providers, reusing and
extending existing unit-test signing helpers rather than duplicating them:

- **Apple**: builds a real x5c-chain-signed JWS. Needs a matching
  test-only certificate chain (self-signed leaf/intermediate/root generated
  once, with the validator's "Apple Root CA G3" constant swapped for a
  test root via a test-only override hook — mirroring the existing
  `NotificationSignatureValidator.jwksUri` test-override pattern) so tests
  don't depend on real Apple certificates.
- **Google**: builds a real Pub/Sub push envelope (`message.data` base64 of
  a camelCase `DeveloperNotification`) plus a signed OIDC-shaped bearer
  token, with the verifier's public-certs endpoint pointed at a test
  double the same way Apple's `jwksUri` already supports.
- **Polar**: lifts the existing `_sign()` helper from
  `polar_signature_validator_test.dart` verbatim — already correct.

Each provider's route is driven directly — `route.handleCall(session, request)`
— using a `relic_core` `Request` built via
`RequestInternal.create(...)` (`package:relic_core/src/context/request.dart`).
`Request`'s only public constructor path is `Request._`, reachable in
production solely through a real IO adapter
(`relic_io/lib/src/adapter/io_adapter.dart`); `RequestInternal` is an
extension exposing that private constructor, deliberately excluded from
the public `relic`/`relic_core` barrel exports ("hidden in barrel file"
per its own doc comment) but still reachable via a deep `src/` import —
confirmed by `relic_core`'s own test suite using exactly this to construct
requests without a server. This is a deliberate, documented use of an
internal-but-reachable extension, not a stable public API contract: a
future `relic_core` version could remove or relocate it without a
deprecation cycle, and the plan should say so at the import site. No live
HTTP server is needed either way.

### Test-only verification override hooks

Both rewritten validators need a way for tests to substitute their own
trusted root (Apple) or certs endpoint (Google) instead of Apple's/Google's
real ones, matching the existing pattern:
`NotificationSignatureValidator.jwksUri` is already a test-only static
override; the plan extends this idea to the new Apple root-cert constant
and the new Google certs-endpoint URL. Explicitly not a runtime
configuration knob — a static field documented as test-only, same as
today's `jwksUri`.

## Flow-level integration tests

Five categories, covering all three rails where applicable, happy path
plus one adversarial variant each:

1. **Purchase → consume lifecycle** (per rail): buy → `getEntitlements` →
   `getEntitlementBalance` → `consumeEntitlement` → balance drops → replay
   the same transaction (idempotent, no double-credit) → over-consume
   (insufficient balance returns a failed `ConsumeResult`, not an
   exception).
2. **Group commerce lifecycle**: buy into a group target (Polar's
   `shareGroupUuid` path) → member consumes → member's group membership is
   revoked mid-flow → their next `consumeGroupEntitlement` call is
   rejected → group balance is unaffected by the member's revocation → a
   different active member can still consume.
3. **Cross-module auth chaining**: device revocation is a direct
   `AccountDevice.isRevoked` DB update (the only mechanism available given
   this harness can't drive anonaccount's real `signIn`/revocation
   endpoints — see "Why not the SDK-driven pattern" above). This is a
   faithful test of production behavior, not a shortcut: every anonaccred
   `JwtEndpoint` calls `AnonAccountHelpers.requireCaller`, which does a
   live DB lookup by device signing key on every call
   (`anonaccount_server/lib/src/helpers.dart:323-337`) rather than trusting
   the JWT's claims — so revoking the row and re-calling each
   commerce/IAP/group-commerce/Polar entrypoint genuinely exercises the
   real re-check, not a mocked one. Separately: membership revoked
   concurrently with `consumeGroupEntitlement` — verify
   `_requireGroupMember`'s check-then-act actually closes the window it
   appears to (per this repo's documented history of comments overclaiming
   atomicity that wasn't there).
4. **Webhook-driven fulfillment**: valid signed notification →
   `AppleWebhookRoute` / `GoogleWebhookRoute` / `PolarWebhookRoute`
   `.handleCall()` → transaction status updates / entitlement granted;
   bad signature / replayed signature → rejected. Written against the
   corrected Apple/Google validators, so these tests exercise real
   verification behavior.
5. **Refund lifecycle**: purchase → webhook-delivered refund event →
   `RefundManager.processRefund` → entitlement revoked → account can't
   consume anymore → duplicate refund event is idempotent (no
   double-revoke).

## Testing

All new tests are `anonaccred_server` integration tests under
`test/integration/`, run via `dart test` (pure-Dart server package, not
Flutter). `MockPolarClient` and `WebhookSigner` get their own focused unit
tests before being used in flow tests. The rewritten Apple/Google
validators get dedicated unit tests for the specific real-shape cases that
motivated the rewrite (sandbox notification with no `kid`, cert chain that
doesn't chain to the trusted root, Pub/Sub envelope with a tampered `aud`
claim) in addition to the flow-level webhook tests.

## Known deviations (carried forward, not fixed by this plan)

- `PolarWebhookRoute` is never registered in
  `quanitya_cloud_server/lib/server.dart` — see "Out of scope" above.
