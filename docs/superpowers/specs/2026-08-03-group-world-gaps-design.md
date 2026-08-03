# Group world gaps

**Date:** 2026-08-03
**Scope:** `anonaccount_server` only.
**Conventions:** `docs/key-model-conventions.md` — rules 5, 6, 7, 9 (attestation model, standing checks).
**Depends on:** the endpoint-auth-interface work (`AnonAccountHelpers.requireCaller`, `requireAttestation`, `requireMemberStanding`) — both phases already merged.

## Source

`docs/key-model-conventions.md`'s "Group-world gaps the account world doesn't have"
cluster. Four items were originally grouped there; this spec covers three of them —
the fourth (`anonaccred`'s group endpoints authorizing on the membership row alone vs.
`GroupEndpoint`'s member-key signature) turned out to be **intentional, not a gap**:
hashcash PoW is too slow for commerce/IAP flows, so `anonaccred` uses a JWT there
instead. That's now written down as boundary B1 in
`docs/superpowers/patterns/2026-08-02/RULES-CANDIDATES.md` and the corresponding
deviation row in `key-model-conventions.md` is updated to say so — no further work
needed on it.

The three real items:

1. `group_member_unique_idx` on `(shareGroupId, anonAccountId)` was documented as
   unconditional, making leaving a group permanent.
2. No `requireActiveMember` — group endpoints collapse "revoked" and "never a member"
   into the same error, where the account side (`requireDevice` vs.
   `requireActiveDevice`) distinguishes them.
3. `monitorGroupMembership` has no authorization past the outer envelope — anyone who
   has observed a member key (they're public) can watch that group's membership
   events.

## What changed under this spec before it was written

Checked against current `main` before designing anything: **item 1 already appears
fixed at the schema and query level**, and the deviation row describing it is stale.

`migrations/20260802130448042/definition.sql:94-98` already drops and recreates
`group_member_unique_idx` as a **partial** index (`WHERE "isRevoked" = false`) — the
same hand-patch pattern `GroupOwner`/`GroupMemberDevice`'s active-row indexes already
use, with a comment crediting "P0's Task 4." `ActiveRows.memberInGroup` (the
duplicate-membership check `addGroupMember` uses) already filters `isRevoked = false`
too, matching the partial index's semantics.

## Landed (2026-08-03)

`docs/superpowers/plans/2026-08-03-group-world-gaps.md` implemented all three
sections. Item 1 needed no code change, only the test and doc correction Task 1
describes. Items 2 and 3 are both live: `requireActiveMember` (new),
`AllRows.memberBySigningKeyIncludingRevoked` (new), `AnonAccountErrorCodes.authAccountRevoked`
(new), `requireMemberStanding` refactored to use them, and `monitorGroupMembership`
now requires `groupId` + `memberAuthSignature` and calls the same
`requireCaller`/`requireAttestation`/`requireMemberStanding` sequence `getGroup`
already used.

So a rejoin after leaving should already work end-to-end. Nothing currently tests it,
and the deviation row was never corrected after the schema work landed — this spec's
Task 1 is verification and documentation, not a fix, unless the new test finds
something the schema-level read missed.

## Design

### 1. Rejoin after leaving a group — verify, test, correct the doc

No code change expected. Add an integration test: bootstrap a group with two admins
(so the last-admin guard doesn't block the leave), have the second admin leave, then
have the same account rejoin via `addGroupMember` with a fresh member key, and assert
success. If this reveals a real gap despite the schema being ready, fix that specific
gap — don't redesign the index or the query, since both already match the intended
shape.

Once the test passes, delete the stale deviation row from `key-model-conventions.md`
and add a one-line "fixed by round 1" style note pointing at the schema work that
already did it, so nobody re-flags this from an old draft.

### 2. `requireActiveMember` — distinguish "revoked" from "never a member"

The account side already has this split: `AnonAccountHelpers.requireDevice` throws
`authDeviceNotFound` when no row exists; `requireActiveDevice` (which calls
`requireDevice` first) throws `authDeviceRevoked` when the row exists but is revoked.
The group side has no equivalent — `ActiveRows.callerMembershipByMemberKey` filters
`isRevoked = false` in its `WHERE` clause, so a revoked member and a stranger who was
never a member both produce "no row found," and every call site (including
`AnonAccountHelpers.requireMemberStanding`, from the endpoint-auth-interface work)
throws the same generic `authAccountNotFound` either way.

New query, `AllRows.memberBySigningKeyIncludingRevoked(Session, UuidValue groupId,
String memberSigningPublicKeyHex)` — mirrors `AllRows.deviceBySigningKeyIncludingRevoked`,
finds the row without filtering on `isRevoked`.

New helper, `AnonAccountHelpers.requireActiveMember(GroupMember? member, String
memberSigningPublicKeyHex, String operation)` — mirrors `requireActiveDevice`
structurally: not-found throws the existing `authAccountNotFound` (nothing currently
depends on a *new* not-found code, so this one is reused rather than added); revoked
throws a **new** code, `authAccountRevoked`, mirroring `authDeviceRevoked`.

`requireMemberStanding` is refactored to use the new two-step lookup
(`memberBySigningKeyIncludingRevoked` then `requireActiveMember`) in place of its
current single filtered query, for the *first* of its two checks (does this member key
have an active membership at all). Its second check (does that membership belong to
the caller's account) is unchanged — that's a binding mismatch, not a revocation
question, and stays `authInvalidSignature`.

This changes the error `requireMemberStanding` throws for an existing-but-revoked
membership, at every site it's already wired into: `getGroup`, `listGroupMembers`,
`addGroupMember` (member branch), `removeGroupMember` (member branch).
(`leaveGroup` is not in this list — per the endpoint-auth-interface phase 2 plan, it
only calls `requireCaller` plus a direct comparison against the target row, not
`requireMemberStanding`, so it's unaffected by this section.) Every one of the four
affected sites already has tests asserting `isA<AuthenticationException>()`
generically for their "caller not a member" cases — those keep passing. Any test
asserting the *specific* old code for a revoked-member case (none currently do, based
on the endpoint-auth-interface work's own test additions, but this is worth confirming
against `main` at implementation time, not assumed here) would need updating to expect
`authAccountRevoked` instead.

### 3. `monitorGroupMembership` — require proof of membership before opening the stream

Two new required params, and one new shared payload builder:

```dart
static String monitorGroupMembership(UuidValue groupId) =>
    'monitorGroupMembership:$groupId';
```

(challenge-free, domain-separated, same pattern as every other `GroupInnerPayloads`
builder.)

`GroupEndpoint.monitorGroupMembership` gains `required UuidValue groupId` and
`required String memberAuthSignature`, and — after the existing, unchanged
`verifySignedPow` call — adds:

```dart
final activeCaller = await AnonAccountHelpers.requireCaller(
  session, callerDeviceSigningPublicKeyHex, 'monitorGroupMembership',
);
await AnonAccountHelpers.requireAttestation(
  message: GroupInnerPayloads.monitorGroupMembership(groupId),
  signature: memberAuthSignature,
  publicKey: memberSigningKeyHex,
  operation: 'monitorGroupMembership',
  failureMessage: 'Invalid member attestation for monitorGroupMembership',
);
await AnonAccountHelpers.requireMemberStanding(
  session, activeCaller, memberSigningKeyHex, groupId, 'monitorGroupMembership',
);
```

before the existing `session.messages.createStream(...)` call, unchanged below that
point.

No SDK change: nothing in `anonaccount_sdk` calls `monitorGroupMembership` today (it's
server-only, unreachable from the SDK — the same situation the group-owner-key-backup
work found for the owner-tier auth branch before that spec). The existing tests for
this endpoint already call `endpoints.group.monitorGroupMembership(...)` directly at
the wire level, so this fix is testable without adding an SDK consumer, matching the
current scope of the endpoint itself.

## Testing

- **Section 1:** one new integration test — leave, then rejoin with the same account,
  assert success. If it passes on the first run, that confirms the schema-level fix
  already works; the test still earns its place as the regression guard nothing else
  currently provides.
- **Section 2:** `requireActiveMember` unit tests (not-found vs. revoked → distinct
  codes), one integration test that a revoked member gets `authAccountRevoked` at a
  representative call site (`getGroup`), and a full-suite run to catch any other test
  that depended on the old collapsed error.
- **Section 3:** flip `monitorGroupMembership`'s existing `'opens without throwing for
  valid device'` test to also supply a valid `groupId`/`memberAuthSignature`; add a
  test that a member key with no standing in the given group is rejected before the
  stream opens; keep the existing `'rejected for invalid device key'` test (outer
  envelope failure, unaffected by this change) as-is.

## What this deliberately does not do

- **Item 4 (two authorization models)** is out of scope — confirmed intentional, see
  "Source" above. Its own spec is not needed; the fix here was documentation only,
  already applied.
- **No SDK wrapper for `monitorGroupMembership`** — see Design section 3.
- **No change to `leaveGroup`'s auth path** — it doesn't use `requireMemberStanding` and
  isn't affected by section 2's refactor.
