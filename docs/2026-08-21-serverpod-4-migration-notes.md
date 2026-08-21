# Serverpod 3.4.1 → 4.0: what to look at when we migrate

**Status as of 2026-08-21:** staying on `serverpod: 3.4.1`. Serverpod 4 is still
beta (tech preview June 2026, public beta July 2026, no GA date announced), and
we're too close to a September-ish launch to absorb a moving target on the
endpoints that gate real money. Revisit after launch, or when 4.0 hits GA —
whichever comes first.

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
  tokens — open upstream bug, [serverpod/serverpod#5113](https://github.com/serverpod/serverpod/issues/5113).
  We mint a `device:<pubkey>` scope per token; confirm this doesn't interact
  badly with revocation (a revoked device's outstanding refresh token should
  not silently keep working).
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
