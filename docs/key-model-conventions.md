# Key model and auth conventions

**What this is:** a description of the pattern this codebase is currently trying
to follow, written down because it was only ever implicit — which is how the two
halves of the system drifted apart.

**What this is not:** rules handed down from on high. Most of these were inferred
from the code rather than decided up front, and the code disagrees with them in
several places (see [Known deviations](#known-deviations)). If a change has a good
reason to break one of these, that's fine — say why in the commit or spec. What's
not fine is breaking one silently, because the last few rounds of that are what
produced the bugs listed at the bottom.

---

## The structure

There are two parallel key hierarchies with the same shape. The group world has
one extra tier **at the top** — a group has an owner above its members, whereas
nothing sits above an account.

| Tier | Account world | Group world |
|---|---|---|
| **owner** | *(no analogue)* | `ShareGroup` — group ultimate KeyDuo |
| **identity root** | `AnonAccount` — ultimate KeyDuo | `GroupMember` — **member KeyDuo** |
| **data key** | account data key | group data key |
| **device leaf** | `AccountDevice` — device KeyDuo | that account's devices |

In each world a root attests leaves, and each leaf holds its own wrapped copy of
one symmetric data key.

**The member key is an identity root, not a leaf.** It occupies the same position
the account's ultimate key does: it is the account's identity *within one group*,
it attests devices into that membership, and after bootstrap it goes quiet. It
looked like a device-tier key only because the group world originally stopped at
two levels and had no device fan-out of its own.

Getting this backwards has consequences. Anything true of the ultimate key should
be checked against the member key: it needs a backup path, it grants rather than
operates, and peer attestation beneath it needs the standing checks in rule 9.

**A `GroupMember` is an account**, so the two hierarchies compose rather than run
in parallel:

```
ShareGroup → GroupMember → (that account's AccountDevices)
```

That composition is the whole of the multi-device problem. Treating the two worlds
as unrelated is what produced the bug.

### Two roots, and only one of them is anchored

The member key and the account ultimate key sit at the same tier, but they are not
equally well-founded, and the difference explains most of the group world's gaps.

| | account ultimate key | member key |
|---|---|---|
| generated | at signup | per group, at join |
| backed up | yes — user writes it down (`getUltimateKeyJwkOnce`) | **yes**, since the member-key-backup work — `GroupMember.encryptedMemberKey` |
| recoverable after total device loss | yes | **yes** — `recoverAccount` decrypts it and writes it to the caller's `MemberKeyStore` |
| anchored to a parent | n/a — it is the top | **yes, cryptographically** — wrapped to the account ultimate *encryption* key, not just a server-side FK |

The member key **is** anchored to the account now: its private half is wrapped to
the account's ultimate encryption public key and stored on the row
(`GroupMember.encryptedMemberKey`), signed by the member key itself so a relaying
admin (`addGroupMember`'s invitee path) can neither substitute the ciphertext nor
redirect it to another group or account. Losing the joining device no longer loses
the membership: the same backup phrase that recovers the account now recovers
every membership.

This was implementable because `AccountKeyStore.getUltimateEncryptionPublicKeyHex()`
now retains the ultimate key's *public* half past `getUltimateKeyJwkOnce()`'s wipe —
public halves are not secret, so keeping it costs nothing and gives every later
`createGroup` / `addGroupMember` call a wrap target without a server round trip.
Newly paired devices receive the same two ultimate public keys over the pairing
channel that already carries the account data key (`DevicePairingEvent`).

The account is now the ultimate root by construction, not merely by convention.

**Reason:** one mechanism, learned once — and the group world's more complete
implementation acts as a reference for the account world, in both directions.

---

## Rules

### 1. A principal stores both public halves

Every principal is a **KeyDuo**: a P-256 ECDSA signing pair *and* a P-256 ECDH
encryption pair. The server stores both public halves.

**Reason:** the signing key is how a principal *acts*; the encryption key is how a
principal is *given things*. A principal missing its encryption pubkey is
unaddressable — nothing can ever be wrapped to it — which quietly rules out whole
categories of fix later.

### 2. Data keys are symmetric; distribution is asymmetric

Content is encrypted with a symmetric AES-256-GCM data key. That key is never
stored in the clear. It's stored once per principal, wrapped to that principal's
ECDH public key.

**Reason:** symmetric is right for bulk content; asymmetric is right for handing a
secret to someone whose secrets you don't hold.

### 3. Asymmetric across a trust boundary, symmetric within one

Wrap asymmetrically when the sender doesn't (and shouldn't) hold the recipient's
secret — pairing device to new device, admin to invitee. Encrypt symmetrically
only when both parties already share a secret.

**Reason:** asymmetric wrapping between parties who already share a key is
ceremony; symmetric encryption between parties who don't is impossible. Naming
the rule makes the exceptional case obvious when it appears.

### 4. Private keys stay on the device that generated them

No private key is serialized, transmitted, or stored — not even encrypted, not
even on an out-of-band channel.

**Reason:** it's the invariant that makes the rest of the model easy to reason
about. Once one private key is transportable, "who can reach this key" stops
being answerable by looking at the schema. Designs that need to break this should
expect scrutiny proportional to that.

**The one exception, and it is now live: break-glass copies wrapped to a
user-held backup key.** An identity root needs a recovery path, or losing every
device loses the identity permanently. The account's ultimate key already had one —
the user writes it down (`getUltimateKeyJwkOnce`) — and the member key now has one
too: `GroupMember.encryptedMemberKey` wraps it to the account's ultimate encryption
public key, so `recoverAccount` can decrypt it with the same backup phrase that
recovers the account itself. A root private key may therefore be wrapped to a key
that exists *only* in a user-held backup, never to a key resident on a device.

The distinction is the whole point, so state which side any proposal is on:

| Wrapped to | Openable by | Verdict |
|---|---|---|
| account **data** key | every device, and anyone with a device compromise | **no** — makes the data key a super-key over everything |
| account **ultimate** encryption key | only the written-down backup | **yes in principle** — the server, a device, and the data key all get nothing |

Distributing a root key *to devices* in any form is the rejected case, whatever
it is wrapped to. Backing one up so its owner can recover it is not.

**Nothing exercises this exception yet.** The one design that tried — escrowing the
member key for recovery — was cut because no device can obtain the wrap target
after `getUltimateKeyJwkOnce()` wipes the ultimate key. The exception is written
down because the *principle* is what separates it from the rejected escrow, not
because any code takes it.

### 5. Two signatures, two jobs: outer proves liveness, inner proves authority

Every call carries an **outer envelope** — hashcash PoW plus an ECDSA signature
over `'$challenge:$methodName:$publicKeyHex'`, signed by whichever key needs to
prove it's live (usually the device key; the ultimate key for
`recoverEncryptedDataKey` and `revokeDevice`).

Operations that change authority additionally carry an **inner signature** over a
challenge-free payload, signed by the key that holds the relevant authority.

**Reason:** they're different questions. The outer envelope answers "is this
request live and rate-limited"; the inner answers "was this actually authorized."
Conflating them is how you end up with authority proofs that expire.

### 6. Inner payloads are challenge-free and domain-separated

Inner payloads contain no challenge and are prefixed with the operation name —
`'addGroupMember:$groupId:…'`, not a bare value.

**Reason:** challenge-free means the persisted signature stays verifiable from row
state alone, forever, by anyone. The prefix stops a signature made for one purpose
from validating in another context.

### 7. Attestations are persisted with their signer

When an inner signature authorizes a durable change, store both the signature and
the signing public key on the row (`addedBySignerPublicKeyHex` /
`addedByAttestation`, and the `revokedBy*` pair).

**Reason:** it turns the table into an independently verifiable chain rather than
a set of assertions you have to take the server's word for. An attestation that's
verified and then discarded proves nothing after the request ends.

### 8. Attestation comes in two tiers: root-attested and peer-attested

A root key can attest a leaf directly. A leaf can also attest another leaf, if it
holds the right standing — an admin adds a member; a paired device pairs another.

**Reason:** roots aren't always available. The group ultimate key and the account
ultimate key are both backup-only, so requiring root attestation for routine
operations would mean re-entering a recovery phrase constantly.

**Consequence to accept deliberately:** provenance chains through peers, so
revoking a peer doesn't retroactively invalidate what it attested. If that's not
acceptable for some operation, that operation needs root attestation.

### 9. Peer attestation requires standing, and standing is checked

The group world checks three things before accepting a peer attestation: the
attestor has an active row in *this* group, its role is `admin`, and its key is
bound to the account resolved from the device envelope.

**Reason:** a peer-attested grant is only as good as the peer's standing at the
time. Skipping the check means persisting a signed record of an authorization the
system should have refused — worse than not recording it, because it looks
authoritative.

### 10. Authority is possession of a key, not a row in a table

There is no `owner` role. Whoever holds the group's ultimate private key is the
owner, demonstrated by signing. Roles in the DB (`admin`/`member`) describe
delegated authority beneath that.

**Reason:** possession is checkable by anyone; a DB flag is only as trustworthy as
the server.

**`GroupOwner` (added in the P0 schema batch, 2026-08-02) does not change this.**
It is a table of *who has a recoverable copy of the group's ultimate key* —
`encryptedUltimateKey`, the ultimate KeyDuo JWK wrapped to that account's own
ultimate encryption key — not a role or a source of authority. Authority is still
demonstrated by signing with the ultimate private key, exactly as above. The
table exists because ownership can now be transferred and co-held: adding an
owner is a row (a new wrapped copy), not a re-key, which `createGroup`
discarding the ultimate private key after generation (see Known Deviations)
made otherwise unrecoverable. Schema only, landed P0 — no endpoints read or
write this table yet. `GroupOwner`'s own unique index on
`(shareGroupId, anonAccountId)` is partial for the same reason
`group_member_unique_idx` is: an account id can't be regenerated, so an
unconditional index would make a revoked owner-grant permanent.

### 11. One encoding for public keys; purpose lives in the name and the type

Every public key — signing or encryption, either hierarchy — is SEC1 uncompressed
`04||x||y`, 130 hex. Field names state purpose and format
(`...SigningPublicKeyHex`, `...EncryptionPublicKeyHex`).

Three shapes, and which one you want follows from what you are doing:

| Doing | Shape | Why |
|---|---|---|
| **registering a principal** | `PublicKeyDuo` | both halves arrive together and cannot be transposed |
| **identifying a principal** | bare signing hex | one key, and it is the identity |
| **wrapping a secret to someone** | bare encryption hex | one recipient; there is no second half to pair |

Every principal registration in the system takes a duo — `createAccount`
(`ultimateKeys`, `deviceKeys`), `registerDevice`, `registerDeviceForAccount`,
`createGroup` (`groupUltimateKeys`, `creatorMemberKeys`) and `addGroupMember`.
Every caller-identifying parameter is a bare hex
(`callerDeviceSigningPublicKeyHex`). A wrap target is a single encryption key —
using a duo there would be ceremony, not safety.

**Reason:** an ECDSA and an ECDH P-256 public key are the same mathematical
object — no validator can tell them apart, so encoding can't carry the
distinction and names and types have to. One encoding also removes prefix surgery
at every library boundary, and makes key comparison plain string equality.

**Corollary:** a `PublicKeyDuo`'s two members must never be equal. That single
check catches the realistic failure — the same key pasted into both slots.

**Lowercase, always.** Hex is case-insensitive; Postgres `=` and btree indexes are
not. Normalise on decode and store only the normalised form, or mixed case
silently defeats distinctness checks, unique indexes, and key lookups alike.

**The server does not validate that a key is on the curve.** It checks format only
and treats keys as opaque identifiers — parsing them into points would mean
handling key objects server-side, which is what this rule exists to prevent.
On-curve validation happens client-side, where keys are actually used:
`webcrypto`/BoringSSL rejects off-curve points on import. The tradeoff: a malformed
key is stored and fails later, away from its cause.

**Where this lives:** `PublicKeyDuo` and the signed-payload builders
(`AccountInnerPayloads`, `GroupInnerPayloads`, and the `*Methods` name
constants) are defined once, in the `anonaccount_protocol` shared package,
registered via Serverpod's `shared_packages` mechanism and imported by both
`anonaccount_server` and `anonaccount_client` (and, through the client,
`anonaccount_sdk`). Before this package existed there were two hand-maintained
copies of the payload builders (server, client) plus a third copy inlined as
raw string literals in the SDK — three places that had to agree on exactly
what gets signed, with nothing enforcing that they did. These builders emit
signed bytes: a second copy isn't a convenience tradeoff, it's a class of bug
(a silent signature mismatch at runtime, with no compile error). Don't
reintroduce a second copy for convenience at a call site — import the shared
package instead.

### 12. Key objects stay client-side; everything crossing the wire is a string

The servers do their crypto with `pointycastle` over raw bytes. Key-object
libraries (`dart_jwk_duo`, `webcrypto`) are runtime dependencies of the SDK only —
in `anonaccount_server` and `anonaccred_server`, `webcrypto` is a **dev**
dependency, used for test fixtures. Wire values are hex, base64, or JSON strings.

**Reason:** it keeps the server's dependency surface small in the component that's
network-exposed, and it means a breaking change in a key library can't reach the
server at all. `anonaccred_server` has no dependency on `dart_jwk_duo`, directly or
transitively — worth keeping that way.

**Where this erodes:** any server-side need to *parse* a key (on-curve validation,
point comparison) creates the temptation to add `webcrypto` for its import
validation. Use `pointycastle` instead — it's already a runtime dep and already
does the curve arithmetic.

The SDK's public API does expose `KeyDuo` and `webcrypto` types, via narrow `show`
lists and via `AccountKeyStore`. That's accepted: a key-custody interface has to
name key types, and wrapping them would relocate the coupling rather than remove
it.

### 13. Revocation is a flag, not key destruction

`isRevoked` marks a principal inactive; the row stays for audit.

**Reason:** history matters for attestation chains. But note the cost: this makes
revocation a *policy* control, not a cryptographic one — a revoked principal keeps
every key it already held. Anything relying on revocation for confidentiality
needs key rotation, which this system does not currently do.

**Interaction with unique indexes, and the distinction that matters.** Because
revoked rows persist, an unconditional unique index means the indexed value can
never be re-registered. Whether that is fine or fatal depends on whether the value
is *disposable*:

- **Unique on a signing key is fine everywhere.** `device_signing_key_idx`,
  `group_member_signing_key_idx`, `ultimate_signing_key_idx` and
  `share_group_ultimate_signing_key_idx` all index a key that is regenerated when
  its principal is re-created. A revoked device that re-pairs makes a fresh
  keypair; a re-added member makes a fresh member key.
- **Unique on an *identity pair* is a bug.** `group_member_unique_idx` on
  `(shareGroupId, anonAccountId)` indexes an account id, which is fixed for life.
  A revoked row therefore locks that account out of that group permanently, so
  leaving a group cannot be undone. It needs `WHERE isRevoked = false`, which the
  model DSL cannot express — it takes a hand-patched raw index.

The test is not "which hierarchy is this" but "can the indexed value be
regenerated." Check that before copying an index shape from one table to another.

---

## Known deviations

These are places the code doesn't follow the above. Listed so nobody mistakes
them for intentional patterns worth copying.

Verified against `main` at `da80c7b` (account/device parity round 1, merged).

**Revocation is barely enforced** — the largest cluster, and the prerequisite for
widening group authorization:

| Deviation | Where | Status |
|---|---|---|
| `resolveAccountUuid` doesn't check `isRevoked`, so most endpoints accept calls from revoked devices (rule 9) | `helpers.dart:15-34` | Open |
| No last-device guard: `revokeDevice` can strip an account to zero devices, unlocked and untransactional, where the group world has a row-locked last-admin guard | `device_management_endpoint.dart:20-88` | Open |
| Revoked principals keep every key they held; nothing rotates a data key on revocation (rule 13) | design-level | Open — inherent to flag-based revocation |
| `anonaccred`'s JWT is issued per **account**, so any device of a member account can spend group entitlements regardless of per-device grants | `group_commerce_endpoint.dart:109-132` | Open |

**Roots that can't be exercised or recovered** — was three instances of one pattern, now two:

| Deviation | Where | Status |
|---|---|---|
| `createGroup` generates the group ultimate KeyDuo and discards it, so owner authority is unrecoverable on every group ever created — no admin can ever be granted or removed | `anonaccount_sdk/lib/src/auth/groups.dart`, `created_group.dart` | Open — the same construction that now backs up the member key (wrap to the account ultimate encryption key, store on the row) would fix this one too. P0's `GroupOwner` table is the schema half of an answer; the write path is still missing |
| There is no way to change a `GroupMember.role`. `GroupMember.db.updateRow` appears twice, both setting `isRevoked` — yet two error messages advise "promote another member to admin first" | `group_endpoint.dart:592`, `:946` | Open — the advised operation does not exist |

**Group-world gaps the account world doesn't have:**

| Deviation | Where | Status |
|---|---|---|
| `group_member_unique_idx` on `(shareGroupId, anonAccountId)` is unconditional, so leaving a group is permanent — an account id is not regenerable (rule 13) | `migrations/…/definition.sql:92` | Open |
| No `requireActiveMember`: group endpoints inline an `isRevoked` filter, so "membership revoked" and "never a member" return the same error code, where the account side distinguishes them | `group_endpoint.dart` | Open |
| `anonaccred`'s group endpoints authorize on the membership row alone, no inner signature (rule 5), while `GroupEndpoint` demands a member-key signature — two authorization models in one system | `group_commerce_endpoint.dart:109-132` | Open — decide which wins |
| `monitorGroupMembership` has no authorization past the outer envelope; the channel name is a caller-supplied member key, and member keys are public | `group_endpoint.dart:642-667` | Open |
| The group data key reaches only the member key, not the account's devices (rule 2's fan-out) | design-level | Being fixed — group parity unit A |

**Inert or cosmetic:**

| Deviation | Where | Status |
|---|---|---|
| `keyEpoch` exists on `AccountDevice` and `ShareGroup` — leaf on one side, root on the other — and is never read or written | both models | Open — inert |
| `webcrypto` dev-dependency versions differ between the two server packages (`^0.6.0` vs `^0.5.3`) | both `pubspec.yaml` | Open — harmless, separately resolved |

**Fixed by round 1** — listed only so nobody re-adds them from an old draft:
`AccountDevice` now has `deviceEncryptionPublicKeyHex`, persisted
`addedBySignerPublicKeyHex`/`addedByAttestation`, `createdAt`, `revokedAt` and a
unique `device_signing_key_idx`; `registerDeviceForAccount` checks the caller with
`requireActiveDevice`; device attestation payloads are domain-separated and cover
both key halves; every public key is SEC1 130-hex with purpose in the field name;
unique indexes sit on the signing key of all four principals; `createAccount` is
transactional; `dart_jwk_duo` 2.0.0 gives both key-pair types the same hex surface.

If you fix one, delete its row. If you add one, add a row and say why.
