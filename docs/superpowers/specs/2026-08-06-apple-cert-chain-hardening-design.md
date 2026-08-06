# Apple x5c certificate-chain hardening

**Date:** 2026-08-06
**Scope:** `anonaccred_server` — `lib/src/payments/notification_signature_validator.dart`, `test/test_helpers/apple_test_certificates.dart`, `test/unit/notification_signature_validator_test.dart`
**Conventions:** THE COMMENT RULE (repo root `CLAUDE.md`) — no falsifiable claims in comments, only WHY
**Depends on:** nothing outstanding; follows directly from the anonaccred commerce flow harness branch merged 2026-08-02 (commit `8eb1224`)
**Tracked as:** closes one row of the "Commerce webhook verification gaps" table in `docs/key-model-conventions.md` (Known deviations, line ~369)

---

## Background

`NotificationSignatureValidator.validateSignature` verifies Apple App Store
Server Notifications: each notification is a JWS whose header carries an
`x5c` certificate chain (leaf → intermediate, terminating at — or signed
by — Apple's Root CA G3). The validator currently checks two things:

1. Each cert in the chain was signed by the next cert up (`_isSignedBy`).
2. The terminal cert is, or was signed by, the pinned trusted root
   (`_chainsToTrustedRoot`).

This proves the chain is cryptographically rooted in Apple's real CA. It
does **not** prove the chain is a *valid, currently-usable* certificate
chain for this purpose. Two gaps follow from that, both documented in
`docs/key-model-conventions.md`'s Known Deviations table and both closed
by this spec:

- **No `basicConstraints CA:TRUE` check on intermediates.** A cert that
  isn't authorized to act as a CA could still sign a "leaf" and pass
  today's chain check, since nothing currently confirms the signer was
  *permitted* to sign other certificates.
- **No validity-period check.** An expired (or not-yet-valid) certificate
  passes today's checks forever — there's no way for a leaked or
  compromised old cert to stop working.

A third gap — checking Apple's leaf-certificate OID
(`1.2.840.113635.100.6.11.1`) to confirm the leaf is specifically an App
Store Server Notification signing cert — is **explicitly out of scope**
for this spec. Its exact meaning could not be confirmed against Apple's
documentation or a real sample cert; hardcoding an unverified OID and
hard-failing on it risks rejecting genuine Apple notifications in
production, which is worse than today's gap. It stays in the Known
Deviations table, to be closed later once a real Apple `x5c` chain can be
inspected to confirm the true OID value.

## What changes

Both new checks are added inside the existing chain walk in
`_chainsToTrustedRoot`, so the chain is parsed exactly once — no second
pass over the certs.

### 1. `basicConstraints CA:TRUE` on non-leaf certs

Every cert in the chain except the leaf (index 0) must carry a
`BasicConstraintsExtension` with `isCA == true`. `package:x509`'s
`X509Certificate.tbsCertificate.extensions` exposes parsed extensions;
the implementer confirms the exact extension-lookup API against the
installed package source (same approach Task 3 used for TBS-byte
handling) before writing the check, since `package:x509`'s extension
accessors aren't guaranteed stable across the plan-writing and
implementation steps.

Reject the chain (return `false`) if any non-leaf cert lacks the
extension or has `isCA != true`.

### 2. Certificate validity period on every cert

Every cert in the chain (leaf included) must have `notBefore <= now <=
notAfter`, read from `certificate.tbsCertificate.validity`. `now` is
`DateTime.now()` at verification time — no clock injection is added,
since nothing in this codebase already provides one and adding one here
would be scope creep beyond what this spec needs.

Reject the chain if any cert is outside its validity window.

### Where the checks live

Both checks run inside the same loop `_chainsToTrustedRoot` already has,
immediately after chain positions are known (leaf = index 0, everything
else = non-leaf) and before/alongside the existing `_isSignedBy` calls.
A cert failing either new check short-circuits to `false` exactly like a
failed signature link does today — no new error/exception path, matching
the function's existing all-or-nothing boolean contract.

## Test fixtures

`AppleTestCertificates` gains two additional throwaway certs, generated
the same way as the existing chain (openssl, P-256, hardcoded DER
base64 — see the file's existing comments for the exact commands):

- **`expiredLeafDerBase64`** — a leaf cert signed correctly by the
  existing test intermediate, but with a validity window entirely in the
  past (e.g. `notBefore`/`notAfter` both in 2020). Proves the validity
  check rejects it — nothing else about this cert is wrong, so a test
  passing here can't be explained by a different, unrelated failure.
- **`nonCaIntermediateDerBase64`** — an intermediate cert signed
  correctly by the existing test root, valid today, but generated
  *without* `basicConstraints CA:TRUE` (openssl's default when the `CA:
  TRUE` extension isn't explicitly requested). A leaf signed by this
  intermediate proves the `basicConstraints` check rejects it.

Both need paired private-key DER constants (`...PrivateKeyDerBase64`)
the same way `unrelatedPrivateKeyDerBase64` already does, since a leaf
must be signed by the fixture's own key to produce a chain that fails
*only* on the new check, not on signature verification too.

`test/unit/notification_signature_validator_test.dart` gains two new
tests:

- A JWS whose leaf chains through `nonCaIntermediateDerBase64` is
  rejected.
- A JWS signed with `expiredLeafDerBase64` (correctly, by its own valid
  key) is rejected.

Both tests build their JWS via the existing test-fixture pattern in that
file (or via `WebhookSigner`, whichever the implementer finds already
wired for constructing a JWS from an arbitrary chain — the plan step
will point at the exact one).

## Out of scope

- The leaf-certificate OID check (deferred, see Background).
- Any change to Google's or Polar's webhook verification — both already
  match their providers' documented models and have no equivalent gap.
- A generic/reusable "certificate chain verifier" abstraction. Checked
  during design: Apple is the only provider in this codebase using
  X.509 chain-of-trust verification. Google uses OIDC JWT verification
  against a JWKS (no certificate chain); Polar uses HMAC-SHA256 webhook
  signatures (no PKI at all). Three distinct verification models with
  one real implementation each — building a shared interface now would
  be an abstraction for a population of one.
- Updating the Known Deviations table row's wording happens as part of
  implementation (split into two rows — one `Fixed`, one still `Not
  fixed here` for the deferred OID check), not as a separate task.

## Testing

Existing tests in `notification_signature_validator_test.dart` must keep
passing unchanged — the two new checks must not reject the existing
valid-chain-and-signature happy path or the existing
untrusted-chain-rejection test. Run via `dart test
test/unit/notification_signature_validator_test.dart` (pure-Dart package
— not `flutter test`, per this repo's Serverpod Rules).
