# Group Invite & Management Endpoints Design

**Date:** 2026-05-20
**Branch:** remove-int-id
**Scope:** `anonaccount_server` (GroupEndpoint + pow_methods.dart)

---

## Context

The groups feature (commit `cc5216b`) added `createGroup`, `listMyGroups`,
`addGroupMember`, and `removeGroupMember`. These cover the mechanics of group
membership but leave gaps:

- No way to invite someone asynchronously (addGroupMember requires all of the
  invitee's keys upfront — keys the admin cannot have until the invitee
  generates and shares them).
- No way to read a single group's details.
- No way to list the members of a group.
- No self-removal (leaveGroup) — removeGroupMember's auth requires an admin or
  ultimate key, so a member cannot remove themselves.
- Inner payload strings are hardcoded inline in group_endpoint.dart and
  account_endpoint.dart/device_endpoint.dart, with no shared source of truth.

---

## Invite Flow Design

### Why URL, not Redis

The invite problem is a key-exchange problem: the admin needs the invitee's
group-specific member public keys before they can encrypt the group master key
for them. A server-side staging table (Redis or DB) was considered but
rejected in favour of a stateless URL approach.

**Reasoning:** The device pairing flow (Device B shows QR → Device A scans →
calls registerDeviceForAccount) needs zero server staging because the QR is
the transport layer for the key exchange. The group invite flow can use the
same pattern with a deep-link URL as the carrier instead of a QR code.

**Invite URL shape (client-side, no server endpoint):**

```
app://group-invite?
  groupId=<uuid>
  &accountId=<invitee-anon-account-uuid>
  &memberSigningKey=<128-hex>
  &memberPublicKey=<128-hex>
```

The invitee generates a fresh member keypair, encodes their public keys +
accountId + groupId into this URL, and shares it (text, copy-paste, etc.).

The admin opens the URL. The app decodes it, has every parameter needed to
call the existing `addGroupMember` endpoint directly. No new server endpoint
for invite creation or acceptance.

The only new server piece is a stream so the invitee knows when the admin has
acted: `monitorGroupMembership`.

**Trade-off:** If the admin never opens the URL, the invite simply never
happens — no cleanup needed. The URL is ephemeral by nature.

---

## Changes

### 1. New constants in `pow_methods.dart`

#### `AccountInnerPayloads`

Centralises the device key attestation payload used in both `createAccount`
and `registerDevice` (currently a bare inline string in both endpoints).

```dart
abstract final class AccountInnerPayloads {
  /// Ultimate key attests to a new device signing key.
  /// Used in createAccount and registerDevice.
  static String deviceAttestation(String deviceSigningPublicKeyHex) =>
      deviceSigningPublicKeyHex;
}
```

#### `GroupInnerPayloads`

Centralises every inner (non-PoW) payload string used or to be used in
`GroupEndpoint`. Replaces inline string construction in the endpoint.

```dart
abstract final class GroupInnerPayloads {
  static String createGroup(
    String ultimateSigningKeyHex,
    String ultimatePublicKey,
    String memberSigningKeyHex,
    String memberPublicKey,
  ) => 'createGroup:$ultimateSigningKeyHex:$ultimatePublicKey'
       ':$memberSigningKeyHex:$memberPublicKey';

  static String addGroupMember(
    UuidValue groupId,
    UuidValue newMemberAccountId,
    GroupMemberRole role,
    String memberSigningKeyHex,
    String memberPublicKey,
  ) => 'addGroupMember:$groupId:$newMemberAccountId:${role.name}'
       ':$memberSigningKeyHex:$memberPublicKey';

  static String removeGroupMember(UuidValue memberId) =>
      'removeGroupMember:$memberId';

  static String leaveGroup(UuidValue memberId) =>
      'leaveGroup:$memberId';

  static String getGroup(UuidValue groupId) =>
      'getGroup:$groupId';

  static String listGroupMembers(UuidValue groupId) =>
      'listGroupMembers:$groupId';
}
```

Also add to `GroupMethods`:

```dart
abstract final class GroupMethods {
  static const createGroup = 'createGroup';
  static const listMyGroups = 'listMyGroups';
  static const addGroupMember = 'addGroupMember';
  static const removeGroupMember = 'removeGroupMember';
  // new:
  static const monitorGroupMembership = 'monitorGroupMembership';
  static const getGroup = 'getGroup';
  static const listGroupMembers = 'listGroupMembers';
  static const leaveGroup = 'leaveGroup';
}
```

---

### 2. Modify `addGroupMember` (existing endpoint)

After successfully inserting the `GroupMember` row, post a Serverpod message
to notify the invitee's stream:

```dart
session.messages.postMessage(
  'group-membership-${member.memberSigningPublicKeyHex}',
  insertedMember,
);
```

No signature change. This is the only change to an existing endpoint.

---

### 3. New endpoints in `GroupEndpoint`

All new endpoints live in the same `GroupEndpoint` class and extend the same
`SignedPowEndpoint` base (same `endpointType = 'group'`,
`rateLimitPerHour = 30`).

---

#### `monitorGroupMembership` — stream

Mirrors `DeviceEndpoint.monitorRegistration` exactly, with one difference:
the monitored key (`memberSigningKeyHex`) is separate from the PoW key
(`callerDeviceSigningPublicKeyHex`) because they are different key types.

**Auth:** Device-tier PoW.

```dart
Stream<GroupMember> monitorGroupMembership(
  Session session, {
  required String challenge,
  required String proofOfWork,
  required String signature,
  required String callerDeviceSigningPublicKeyHex,
  required String memberSigningKeyHex,
})
```

- Outer payload: `'$challenge:${GroupMethods.monitorGroupMembership}:$callerDeviceSigningPublicKeyHex'`
- Opens channel: `'group-membership-$memberSigningKeyHex'`
- Yields `GroupMember` events from the channel.
- No membership check — the invitee is not yet a member when they open this
  stream. The channel name is derived from the key they just generated, which
  only they know.

---

#### `getGroup` — returns `ShareGroup`

**Auth:** Device-tier PoW (outer) + member key signature (inner).

Caller proves both device liveness and possession of an active member key for
the requested group.

```dart
Future<ShareGroup> getGroup(
  Session session, {
  required String challenge,
  required String proofOfWork,
  required String signature,
  required String callerDeviceSigningPublicKeyHex,
  required UuidValue groupId,
  required String callerMemberSigningPublicKeyHex,
  required String memberAuthSignature,
})
```

- Outer payload: `'$challenge:${GroupMethods.getGroup}:$callerDeviceSigningPublicKeyHex'`
- Inner payload: `GroupInnerPayloads.getGroup(groupId)`
- Server verifies:
  1. Outer PoW + device sig.
  2. Inner sig valid: `memberAuthSignature` over inner payload using `callerMemberSigningPublicKeyHex`.
  3. Active membership: `GroupMember` row exists where `shareGroupId = groupId`,
     `memberSigningPublicKeyHex = callerMemberSigningPublicKeyHex`,
     `isRevoked = false`.
  4. Account binding: `GroupMember.anonAccountId` matches the account resolved
     from the device key (same check as `addGroupMember` member-tier path).
- Returns the `ShareGroup` row.

---

#### `listGroupMembers` — returns `List<GroupMember>`

Same auth shape as `getGroup`.

```dart
Future<List<GroupMember>> listGroupMembers(
  Session session, {
  required String challenge,
  required String proofOfWork,
  required String signature,
  required String callerDeviceSigningPublicKeyHex,
  required UuidValue groupId,
  required String callerMemberSigningPublicKeyHex,
  required String memberAuthSignature,
})
```

- Outer payload: `'$challenge:${GroupMethods.listGroupMembers}:$callerDeviceSigningPublicKeyHex'`
- Inner payload: `GroupInnerPayloads.listGroupMembers(groupId)`
- Same four verification steps as `getGroup`.
- Returns all `GroupMember` rows where `shareGroupId = groupId` and
  `isRevoked = false`, ordered by `joinedAt` ascending.

---

#### `leaveGroup` — returns `bool`

Self-removal. Member signs their own departure. No ultimate key needed
regardless of role — this is intentionally lighter than `removeGroupMember`
for the self-removal case.

**Auth:** Device-tier PoW (outer) + member key signature (inner).

```dart
Future<bool> leaveGroup(
  Session session, {
  required String challenge,
  required String proofOfWork,
  required String signature,
  required String callerDeviceSigningPublicKeyHex,
  required UuidValue memberId,
  required String memberSigningPublicKeyHex,
  required String memberAuthSignature,
})
```

- Outer payload: `'$challenge:${GroupMethods.leaveGroup}:$callerDeviceSigningPublicKeyHex'`
- Inner payload: `GroupInnerPayloads.leaveGroup(memberId)`
- Server verifies:
  1. Outer PoW + device sig.
  2. Inner sig valid: `memberAuthSignature` over inner payload using
     `memberSigningPublicKeyHex`.
  3. Target row: `GroupMember.findById(memberId)` — must exist and not be
     revoked.
  4. Key match: `target.memberSigningPublicKeyHex == memberSigningPublicKeyHex`.
  5. Account binding: `target.anonAccountId` matches device-resolved account.
- Marks target as revoked: `isRevoked = true`,
  `revokedBySignerPublicKeyHex = memberSigningPublicKeyHex`,
  `revokedByAttestation = memberAuthSignature` (self-attested).
- **Last-admin rule:** after revoking, query for any remaining non-revoked
  `GroupMember` row in the same group where `role = admin`. If none exist,
  delete the `ShareGroup` row. The `onDelete=Cascade` relation on
  `GroupMember → ShareGroup` cleans up all member rows. The anonaccred module's
  `GroupEntitlement`, `GroupConsumptionLog`, and `EphemeralAccreditationGroup`
  rows must also cascade — verify FK constraints cover this before
  implementation.
- Returns `true`.

---

## No new DB models or migrations

All new endpoints read/write to existing `share_group` and `group_member`
tables. No new models, no migration needed.

---

## Summary table

| Endpoint | Auth | Notes |
|---|---|---|
| `monitorGroupMembership` | Device PoW | Stream; channel keyed on `memberSigningKeyHex` |
| `getGroup` | Device PoW + member sig | Returns `ShareGroup`; membership verified |
| `listGroupMembers` | Device PoW + member sig | Returns active members; membership verified |
| `leaveGroup` | Device PoW + member sig | Self-attested revocation; deletes group if last admin |
| `addGroupMember` (modified) | Unchanged | Posts to `group-membership-{key}` channel after insert |
| `AccountInnerPayloads` | — | New constants class in `pow_methods.dart` |
| `GroupInnerPayloads` | — | New constants class in `pow_methods.dart`; replaces inline strings |
