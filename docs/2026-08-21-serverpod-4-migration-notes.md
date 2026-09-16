# Serverpod 3.4.1 → 4.0: what to look at when we migrate

**Status as of 2026-08-21:** staying on `serverpod: 3.4.1`. Serverpod 4 is still
beta (tech preview June 2026, public beta July 2026, no GA date announced), and
we're too close to a September-ish launch to absorb a moving target on the
endpoints that gate real money. Revisit after launch, or when 4.0 hits GA —
whichever comes first.

**Update 2026-09-15: 4.0.0 hit stable/GA on pub.dev** (published ~30 hours
before this note). The "revisit" trigger below has fired. Execution plan:
`docs/superpowers/plans/2026-09-15-serverpod-4-migration.md`. Everything below
this line is the original 2026-08-21 research; treat the sections on beta
churn as historical — GA superseded the "wait for churn to settle" concern,
but the two-auth-surface risk split it identified still holds and is the spine
of the plan.

**Two changes found in the actual 4.0.0 GA changelog/upgrade guide that this
2026-08-21 note didn't anticipate, because they weren't in the beta.2
changelog it was written against:**

- **Model file extension.** 4.0 requires `.spy.yaml` for model files;
  plain `.yaml`/`.yml` in model directories is now ignored. Checked
  2026-09-15: every model file in this repo already uses `.spy.yaml`
  (`find . -name '*.spy.yaml' -path '*models*'` matches all of them, no
  bare `.yaml` stragglers). Not a migration task — just confirming.
- **Token manager API split.** The upgrade guide describes `issueToken` as
  now non-virtual, applying sign-in policies (e.g. rejecting sign-in on top
  of another account, via a new `SignInWhileAuthenticatedException`)
  automatically, with custom token managers expected to implement
  `createToken` only. Our `device_endpoint.dart:169` calls
  `AuthServices.instance.tokenManager.issueToken(...)` directly against the
  default token manager (no subclass), after our own PoW+ECDSA envelope
  passes. This needs to be checked against the actual installed package
  source at migration time, not against secondhand summaries of the guide —
  see the plan's verification task.

**Update 2026-09-15, second pass — grepped this repo directly against every
enumerated 4.0 breaking-change API** (not just the beta.2-era list, the GA
guide's full removed-API list) instead of trusting the earlier "verified,
not assumed" section, which predates GA and never checked these specific
symbols:

- **`orderDescending` — hits, and it's a real one-line fix.**
  `anonaccount_server/lib/src/queries/active_rows.dart:251`,
  `devicesForAccountIncludingRevoked`, passes `orderDescending: true`
  alongside `orderBy: (t) => t.lastActive`. 4.0 removes this parameter; the
  replacement is `orderBy: (t) => t.lastActive.desc()`. See plan Task 3.
- **`CloudStorage`/`storeFile`/`retrieveFile`/`getPublicUrl`/
  `createDirectFileUploadDescription`, `ServerpodClientException` subclass
  matching, `ignoreEndpoint`, legacy `StreamingEndpoint`/`StreamingSession`
  — no hits.** Grepped directly across `anonaccount_server/lib`,
  `anonaccred_server/lib`, `anonaccount_sdk/lib`. None of these APIs appear
  anywhere in this repo.
- **Future calls: already on the modern class-based API, not the removed
  string-based one.** `anonaccred_server/lib/src/privacy_scrub_future_call.dart`
  defines `PrivacyScrubFutureCall extends FutureCall` and calls
  `pod.endpoints.futureCalls.callWithDelay(...)`, the typed generated-API
  form — not `registerFutureCall`/`futureCallWithDelay(String name, ...)`.
  Not a compile-time break. But 4.0 changes the *execution guarantee* to
  "at least once" (a crash mid-call triggers a re-run), which is a behavior
  question: `scrub()` re-schedules itself via `callWithDelay(identifier:
  'anonaccred-privacy-scrub')` *before* doing the delete-where work, so the
  next run stays queued even if this one throws. Whether a retried `scrub()`
  double-schedules under that fixed identifier, and whether re-running the
  delete-where on retry is a no-op — it should be, deleting rows that are
  already gone or past the cutoff is naturally idempotent — belongs in a
  test, not a claim here. See plan Task 5's addendum.
- **Message Central default-scope change: doesn't change our behavior
  today, but worth knowing about.** `session.messages.postMessage` backs our
  own custom pub/sub streaming — `device_endpoint.dart` (device pairing) and
  `group_endpoint.dart` (`monitorGroupMembership`) — paired with
  `session.messages.createStream<T>(channelName)`. Neither call site passes
  `global: true` (which 4.0 removes anyway), so nothing to fix to compile.
  4.0 changes the *default* delivery scope from local-only to
  `MessageScope.auto` (cluster-wide via Redis, local fallback if no Redis is
  configured). Checked: neither `anonaccount_server/config/production.yaml`
  nor `anonaccred_server/config/production.yaml` has a `redis:` section —
  only `test.yaml` does, for `serverpod_test`'s harness. So `auto` falls
  back to local in production today, identical to current 3.4.1 behavior —
  not a regression. It's a latent capability worth remembering if this ever
  runs multiple server instances: today, a `monitorGroupMembership` stream
  connected to instance B would never see a `postMessage` fired by a request
  handled on instance A (no cross-instance delivery; single-instance
  deployment currently masks this). 4.0 + Redis would fix that for free —
  not this migration's problem to solve, flagging it so it isn't rediscovered
  as a mystery bug the day this scales past one instance.

### Update 2026-09-15 — Task 1 token-manager source check

The first attempt (run inside a Gait-dispatched sandboxed session) couldn't
reach `pub.dev` — sandbox network restriction, not a Serverpod issue. Redone
directly (no sandbox) by fetching `serverpod_auth_core_server: 4.0.0` into a
disposable `/tmp` package (this is the package that actually defines
`TokenManager`/`TokenIssuer` — not `serverpod` itself, which has no
`issueToken` definition anywhere in its own source; the class lives one
layer down, in the auth-core package `anonaccount_server` also imports
transitively through `serverpod_auth_idp_server`). Read directly from
`~/.pub-cache/hosted/pub.dev/serverpod_auth_core_server-4.0.0/lib/src/common/integrations/token_manager.dart`.
All three questions are answered from that source, not from guide prose:

1. **`issueToken` signature: unchanged, compiles as-is.** The real signature
   is `issueToken(Session session, {required UuidValue authUserId, required
   String method, Set<Scope>? scopes, Transaction? transaction})` on
   `abstract class TokenIssuer` (which `TokenManager extends`), and it's
   `@nonVirtual`. `device_endpoint.dart:169`'s call — `issueToken(session,
   authUserId: ..., method: 'anonaccount', scopes: {...})` — matches this
   exactly. No code change needed here.
2. **Sign-in policy: the check is per-`authUserId`, not per-device, and
   doesn't apply to our device flow's normal case.** The actual guarded code:
   `final callerIdentifier = session.authenticated?.userIdentifier; if
   (callerIdentifier != null && callerIdentifier != authUserId.toString())
   { throw SignInWhileAuthenticatedException(); }`. Two things follow: (a)
   if the incoming request carries no prior authentication on the session
   (`session.authenticated == null` — the normal case for our unauthenticated
   `signIn` endpoint), the check is skipped entirely, regardless of which
   device is signing in; (b) even if a request *did* carry an existing valid
   token, the check compares against `authUserId`, which in our model is the
   **account** UUID shared by every device on that account — so a second
   device on the *same* account re-authenticating would still pass
   (`callerIdentifier == authUserId.toString()`); it only throws if a
   request already authenticated as *account A* tries to `issueToken` for
   *account B*. Whether our SDK/client ever attaches a stale Authorization
   header from a different account while calling `signIn` is a client-side
   question this source reading can't answer — worth a regression test
   (Task 5) confirming a plain `signIn` call with no `Authorization` header
   never trips this, since that's the actual request shape in normal use.
3. **`revokeAllTokens`: signature and account-wide revocation scope
   confirmed unchanged.** Real signature: `revokeAllTokens(Session session,
   {required UuidValue? authUserId, Transaction? transaction, String?
   method, String? tokenIssuer})` on `abstract class TokenManager`. Passing
   only `authUserId:` (as `device_management_endpoint.dart`'s `revokeDevice`
   does) revokes every token for that `authUserId` regardless of `method` or
   `tokenIssuer` — i.e. still account-wide, not scoped to one device's
   token, confirming the existing 3.4.1 behavior carries over unchanged.

No `AuthServices.instance.tokenManager.issueToken`/`revokeAllTokens` call
site needs to change for this migration. Plan Task 1/Task 3's conditional
edits to `device_endpoint.dart`/`device_management_endpoint.dart` are now
unconditionally **not needed** — downgrade those from "conditional per
finding" to "no change" in the plan.

## Cross-module foreign keys: not new in 4.0, and we don't use the feature

Checked whether 4.0 added first-class FK support across custom modules
(`anonaccred` referencing `anonaccount`'s tables) — the question that
prompted this second research pass. Findings:

- The `module:<moduleName>:<ClassName>?, relation` syntax (and the
  table-name form, `fooId: int, relation(parent=some_table)`) already
  exists and predates 4.0 — documented at the unversioned/current docs URL,
  with no 4.0 changelog entry introducing or changing it. Serverpod's docs
  demonstrate it via the built-in `auth` module (`module:auth:UserInfo`),
  but the syntax is generic by module name, not auth-specific.
- **We don't use it for anonaccred → anonaccount.** Every anonaccred model
  that references an account (`account_entitlement.spy.yaml`,
  `consumption_log.spy.yaml`, `ephemeral_accreditation.spy.yaml`,
  `ephemeral_accreditation_group.spy.yaml`) declares a plain
  `accountUuid: UuidValue` field — no `relation` keyword, no FK constraint.
  That's UUID matching by convention, not a database-enforced FK. Whether
  that's a deliberate choice (avoiding a hard dependency shape between the
  modules) or just never revisited isn't answerable from the code alone —
  worth an explicit decision if it matters, but it's unrelated to this
  migration: 4.0 doesn't change what's possible here either way.
- The one real cross-module FK that *does* exist in this repo —
  `account_device.anonAccountId → anon_account.id`, declared in
  `anonaccount_server/lib/src/models/account_device.spy.yaml` via
  `anonAccount: AnonAccount?, relation(onDelete=Cascade)` — is intra-module
  (both tables belong to `anonaccount`). The March 2026 hand-patch
  (`6a5779d`) wasn't about adding a cross-module FK; it fixed a generator
  bug where regenerating `anonaccred_server`'s own bundled migration
  snapshot (which embeds every dependency module's schema, including
  anonaccount's) re-derived that already-declared FK's column type as
  `int`/`bigint` instead of `uuid`. No evidence either way on whether 4.0
  fixed that specific generator bug — re-test it during migration (Task 4's
  shared-packages diff step is where it would resurface).

## Other 4.0 features, evaluated and set aside (not part of this migration)

- **Embedded Postgres (`dataPath` in `development.yaml`/`test.yaml`) and the
  unified `serverpod start` dev command** — optional local-dev workflow
  changes, no effect on production behavior. Could simplify local dev later;
  not this migration's job.
- **Social sign-in expansion, account merging, OAuth2 PKCE for web** — all
  `serverpod_auth_idp` sign-in-flow features. We don't use
  `serverpod_auth_idp`'s actual sign-in flows — our dependency on it exists
  only for `AuthServices`/`AuthenticationInfo`/token-management plumbing
  (see the original note above). Not applicable.
- **Geography types, client-side SQLite (`database` keyword), dynamic model
  types** — no current use case in this repo (no client-side offline data
  model, no geo data). Not applicable now; worth remembering for future
  features, not for this migration.
- **AI agent skills / MCP server scaffolding on `serverpod create`** — a
  new-project bootstrap feature; doesn't apply to existing packages.

This doc is the checklist for when that happens. It's a map of *where this
codebase's own conventions and auth split make the generic upgrade guide
insufficient by itself* — not a restatement of the guide.

Official guide: https://docs.serverpod.dev/next/upgrading/upgrade-to-four

## Two auth surfaces, two different risk levels

This repo has two unrelated auth mechanisms, and the 4.0 changes land
unevenly across them. See `docs/key-model-conventions.md` for the full model.

### `anonaccount` (device/group world) — low risk, mostly untouched

Device and group operations are authorized by a hand-rolled hashcash-PoW +
ECDSA envelope, verified with `pointycastle` against public keys the server
never signs with. Serverpod's own auth module touches this world in exactly
one call: `AuthServices.instance.authUsers.create(session)` in
`anonaccount_server/lib/src/endpoints/account_endpoint.dart:145`, used only to
mint a UUID for the `AnonAccount` row id. None of 4.0's auth changes (social
sign-in, account merging, refresh-token rotation, session-key salting) reach
this path. Low-risk, low-effort to verify.

### `anonaccred` (commerce/IAP/Polar) — real risk, needs actual regression testing

This is the surface that matters. `anonaccred`'s commerce endpoints run on
Serverpod's *actual* built-in session/JWT auth, not our own crypto:

- `anonaccount_server/lib/src/endpoints/device_endpoint.dart:169` issues the
  token: `AuthServices.instance.tokenManager.issueToken(session,
  authUserId: ..., scopes: {Scope('device:$devicePublicKeyHex')})`, after our
  PoW+ECDSA envelope passes. Refresh tokens come from the same call.
- `anonaccount_server/lib/src/endpoints/jwt_endpoint.dart` — `JwtEndpoint`
  sets `requireLogin => true` and reads identity via `session.authenticated`
  (Serverpod's own session object), not our own verification code.
- `CommerceEndpoint`, `IAPEndpoint`, `GroupCommerceEndpoint`, `PolarEndpoint`
  in `anonaccred_server/lib/src/endpoints/` all extend `JwtEndpoint` — every
  purchase/entitlement call is gated by Serverpod's auth machinery.

4.0 beta changes that land directly on this path:

- Refresh-token rotation is blocked for blocked auth users (beta.2) — verify
  our revoked-device handling still composes correctly with this.
- Session-key hash now includes a salt (beta.2) — check nothing of ours
  persists or compares a raw session key.
- Scope updates on an `authUser` don't propagate to already-issued refresh
  tokens — [serverpod/serverpod#5113](https://github.com/serverpod/serverpod/issues/5113),
  open when this note was written on 2026-08-21. **Closed as of 2026-09-15**
  (status "Done" on the GitHub issue, no fix-version confirmed from the issue
  page alone). We mint a `device:<pubkey>` scope per token; confirm at
  migration time which 4.0.0 behavior we actually got — the fix changes the
  answer to "does a revoked device's outstanding refresh token stop working
  promptly," which is worth a regression test either way. Separately, note
  that `device_management_endpoint.dart`'s `revokeDevice` already calls
  `revokeAllTokens(authUserId: ...)` — account-wide, not per-device — so
  today one revoked device already invalidates every other device's tokens
  too. That's existing 3.4.1 behavior, not a 4.0 change; don't conflate the
  two when writing the regression test.
- Account-merging mechanics (beta.2) — we don't use this feature, but confirm
  it doesn't change `authUsers.create` semantics in a way that affects our
  `AnonAccount.id = authUser.id` assumption.

**When we migrate: this is the part that needs a real regression pass against
live Apple/Google/Polar sandbox flows, not just `dart test` passing.** The
`anonaccount` side needs far less scrutiny.

## Breaking changes that don't apply to us (verified, not assumed)

Checked by grep across the whole repo — none of these hit:

- `authenticationKeyManager` client param removal — we never use it.
- Legacy streaming session API removal — no `Stream<...>`/`monitorGroupMembership`-adjacent
  code touches Serverpod's own streaming auth, only our own custom streams.
- Message Central delivery-strategy change — no `MessageCentral` usage.
- Dockerfile rework — we don't have one.
- Root `pub` workspace changes — no root `pubspec.yaml`; each package
  upgrades independently, which is already how we work.

## Repo-specific migration mechanics

- **Flat migrations meet the guide's "layer a migration on top" advice.**
  CLAUDE.md convention here is delete-and-regenerate with
  `serverpod create-migration --force`, no backwards compatibility; the
  official 4.0 guide instead says to run
  `serverpod create-migration --tag "upgrade-4.0"` to capture just the new
  internal Serverpod tables/index changes. Pick one and be deliberate: either
  layer the 4.0 migration per the guide, or fold it into the next flat
  regenerate. Either way, budget for the **cross-module UUID hand-patch**
  step our migrations always need after regeneration — that's our existing
  tax, not something new from 4.0.
- **`shared_packages` (`anonaccount_protocol`) needs a real diff check.**
  4.0-beta.2's changelog notes "forwards shared package models through
  owning module's server/client packages" — behavior in exactly the
  mechanism `anonaccount_server/config/generator.yaml`'s `shared_packages:`
  entry relies on. Run `serverpod generate` and diff the output for
  `anonaccount_protocol`-sourced types before assuming nothing moved.
- **`serverpod_test`** — 63 files depend on it across `anonaccount_server`/
  `anonaccred_server`. The guide's only test-harness note
  (`--concurrency=1` requirement) only applies if we adopt the new embedded
  Postgres dev mode, which is optional.

## Non-goals this migration does not solve

- **Multi-database support.** Confirmed via Serverpod docs/GitHub as of
  2026-08-21: still single DB connection through the ORM, in 4.0 betas too.
  Modules share one database via table-name prefixing. If we ever want
  `anonaccount` and `anonaccred` on physically separate databases, that's a
  standalone project (bypassing the ORM for one side), independent of which
  Serverpod version we're on — don't bundle it with this upgrade.

## Suggested trigger to revisit

- Serverpod 4.0 reaches GA (or at minimum RC, with beta churn visibly
  settled — check the changelog for consecutive betas with no auth/session
  breaking changes), **or**
- We're past the September launch and have a quiet window to eat migration
  risk deliberately rather than under deadline pressure.

When we do start: begin with the `anonaccred` JWT path regression tests
before touching anything else — everything else in this doc is comparatively
low-stakes.
