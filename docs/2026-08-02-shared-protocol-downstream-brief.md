# Downstream brief: anonaccount_protocol shared package

**For:** whoever next touches `quanitya`'s `anonaccount_server`/`anonaccred_server`
dependency pins. This repo (`serverpod_anonaccred`) is consumed by `quanitya` over
git, per `quanitya/CLAUDE.md`'s dependency update chain. This brief is the
"what changed and what you need to do" note for that chain, produced by
`docs/superpowers/plans/2026-08-02-shared-protocol-package.md`.

## What moved

`PublicKeyDuo` (the wire model) and the signed-payload builders
(`AccountInnerPayloads`, `GroupInnerPayloads`, `AccountMethods`, `DeviceMethods`,
`DataKeyMethods`, `GroupMethods`) used to exist as three separate copies:

- Generated into `anonaccount_server`'s protocol (for `PublicKeyDuo`) plus a
  hand-written `anonaccount_server/lib/src/pow_methods.dart`.
- Generated into `anonaccount_client`'s protocol plus a hand-written,
  byte-identical copy at `anonaccount_client/lib/src/pow_methods.dart`.
- Four payloads (`createGroup`, `addGroupMember`, `removeGroupMember`,
  `leaveGroup`) inlined as raw string literals in
  `anonaccount_sdk/lib/src/auth/groups.dart`, not even going through the
  client's copy of the builders.

All three collapsed into one: a new package, `anonaccount_protocol`, registered
via Serverpod's `shared_packages` mechanism in `anonaccount_server/config/generator.yaml`.
Both `anonaccount_server` and `anonaccount_client` depend on it by path; the SDK
depends on it directly too (previously reached `PublicKeyDuo` only through
`anonaccount_client`, with `// ignore: implementation_imports` comments — those
comments are gone now that the type lives in its own package).

## No data, signature, or persisted value is affected

This is a pure code-organization move. Every emitted payload string is
byte-identical before and after — verified with a golden test
(`anonaccount_server/test/unit/payload_golden_test.dart`) that pins the exact
output of every builder against hardcoded expectations, written *before* any
code moved and never edited to accommodate the refactor. It still passes.
`GroupMemberRole` (a DB-backed enum, `group_member.role` column type) did
**not** move — it stays in `anonaccount_server`; the one builder that used it
(`GroupInnerPayloads.addGroupMember`) now takes `String roleName` instead, and
callers pass `role.name`, which is exactly what the payload always emitted.

Neither `anonaccount_server/migrations/` nor `anonaccred_server/migrations/`
changed — `PublicKeyDuo` has no `table:` key, so no schema depends on it, and
`anonaccred_server`/`anonaccred_client` reference neither `PublicKeyDuo` nor
`GroupMemberRole` anywhere (verified by grep, both hand-written and generated
code) — this refactor does not touch anonaccred at all.

## What quanitya needs to change

Two files, both under `public/quanitya_flutter/`:

- `lib/features/device_pairing/services/pairing_service.dart`
- `lib/infrastructure/crypto/crypto_key_repository.dart`

Both currently import `PublicKeyDuo` from the client's generated protocol path
(something like `package:anonaccount_client/src/protocol/public_key_duo.dart`
or via the `anonaccount_client` barrel). That generated file no longer exists —
`PublicKeyDuo` now generates into `anonaccount_protocol`'s own
`lib/src/generated/public_key_duo.dart`. Change both imports to:

```dart
import 'package:anonaccount_protocol/anonaccount_protocol.dart';
```

(`anonaccount_client`'s own barrel, `anonaccount_client/anonaccount_client.dart`,
also still re-exports `PublicKeyDuo` — with `Protocol` hidden to avoid a name
collision with the client's own generated `Protocol` class — so if either file
imports the client's top-level barrel rather than the specific generated file,
no change may be needed there. Check which import form is actually in use.)

## No new git pin needed for the package itself

`anonaccount_protocol` is a `path: ../anonaccount_protocol` dependency inside
this repo, resolved relative to `anonaccount_server`/`anonaccount_client` —
the same mechanism `anonaccred_server` already relies on for its
`path: ../anonaccount_server` dependency, which quanitya already consumes over
git without issue. Updating quanitya's `ref:` for `anonaccount_server_client`
and `anonaccred_server_client` (per the normal dependency-update chain in
`quanitya/CLAUDE.md`) is sufficient to pull in `anonaccount_protocol`
transitively; there is no separate `anonaccount_protocol` git remote to add.

## Commit hash to pin

**This work is on an unmerged branch, not yet pushed to origin.** As of
writing, the branch is `shared-protocol-package`, tip:

```
27896f2a38d9fcbe4a787ab07f2ddaa69e25f88b
```

Do not pin quanitya to this hash directly — it is a local worktree commit and
is not guaranteed to be reachable from `origin` yet, let alone stable (may be
rebased before merge, per this repo's normal review flow). Once this branch is
merged to `main` and pushed, get the **merge commit's full 40-character hash**
(`git log --oneline -1` on `main` after the merge) and use that — never a short
ref, per `quanitya/CLAUDE.md`'s dependency-update-chain rule.

## If `dart pub get` misbehaves

Nothing about this change should require `--offline` to be cleared or any
non-standard pub flags — the new dependency is a same-repo relative path, same
mechanism already in use for `anonaccred_server` → `anonaccount_server`. If the
implementer hits anything unexpected running `dart pub get` in
`quanitya_cloud_server` after bumping the refs, it's worth checking first
whether it's specific to this change or a pre-existing environment issue
(e.g. this repo's own dev sandbox has no network access for git-dependency
fetches — see the `gait-agent` skill's notes on `dart_jwk_duo` — that's a
sandbox property, not something introduced by this refactor).
