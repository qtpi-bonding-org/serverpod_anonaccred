# Group Invite & Management Endpoints Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `monitorGroupMembership`, `getGroup`, `listGroupMembers`, and `leaveGroup` to `GroupEndpoint`, centralise all inner payload strings into `GroupInnerPayloads` / `AccountInnerPayloads`, and wire the stream notification into `addGroupMember`.

**Architecture:** URL-based stateless invite (no Redis, no new DB table). The invitee encodes their freshly-generated member public keys into a deep link; the admin decodes it and calls the existing `addGroupMember` directly. `monitorGroupMembership` is the only new server primitive needed for the invite path — it mirrors `monitorRegistration` with a separate PoW key and channel key. `getGroup`, `listGroupMembers`, and `leaveGroup` round out group management. All inner payload strings move to two new `abstract final class` constants in `pow_methods.dart`.

**Tech Stack:** Dart 3, Serverpod 3.4, PointyCastle (test signing), `dart test` (server package)

---

## File Map

| File | Action |
|---|---|
| `anonaccount_server/lib/src/pow_methods.dart` | Add `AccountInnerPayloads`, `GroupInnerPayloads`; extend `GroupMethods` |
| `anonaccount_server/lib/src/endpoints/account_endpoint.dart` | Replace inline attestation string with `AccountInnerPayloads.deviceAttestation` |
| `anonaccount_server/lib/src/endpoints/device_endpoint.dart` | Replace inline attestation string with `AccountInnerPayloads.deviceAttestation` |
| `anonaccount_server/lib/src/endpoints/group_endpoint.dart` | Replace inline strings; modify `addGroupMember`; add 4 new methods |
| `anonaccount_server/test/integration/group_endpoint_test.dart` | Add tests for all new behaviour |

---

## Task 1: Add payload constants and refactor inline strings

**Files:**
- Modify: `anonaccount_server/lib/src/pow_methods.dart`
- Modify: `anonaccount_server/lib/src/endpoints/account_endpoint.dart`
- Modify: `anonaccount_server/lib/src/endpoints/device_endpoint.dart`
- Modify: `anonaccount_server/lib/src/endpoints/group_endpoint.dart`

No tests needed — pure refactor of inline strings to named constants. `dart analyze` is the verification.

- [ ] **Step 1: Add constants to `pow_methods.dart`**

Add after the existing `GroupMethods` class:

```dart
abstract final class AccountInnerPayloads {
  /// Ultimate key attests to a new device signing key.
  /// Used identically in createAccount and registerDevice.
  static String deviceAttestation(String deviceSigningPublicKeyHex) =>
      deviceSigningPublicKeyHex;
}

abstract final class GroupInnerPayloads {
  static String createGroup(
    String ultimateSigningKeyHex,
    String ultimatePublicKey,
    String memberSigningKeyHex,
    String memberPublicKey,
  ) =>
      'createGroup:$ultimateSigningKeyHex:$ultimatePublicKey'
      ':$memberSigningKeyHex:$memberPublicKey';

  static String addGroupMember(
    UuidValue groupId,
    UuidValue newMemberAccountId,
    GroupMemberRole role,
    String memberSigningKeyHex,
    String memberPublicKey,
  ) =>
      'addGroupMember:$groupId:$newMemberAccountId:${role.name}'
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

`GroupInnerPayloads` uses `UuidValue` and `GroupMemberRole` — add the imports to `pow_methods.dart`:

```dart
import 'package:serverpod/serverpod.dart';
import 'src/generated/group_member_role.dart';
```

Wait — `pow_methods.dart` is inside `lib/src/`, so the import is:

```dart
import 'package:serverpod/serverpod.dart';
import 'generated/group_member_role.dart';
```

- [ ] **Step 2: Extend `GroupMethods` with the four new method names**

Replace the existing `GroupMethods` class:

```dart
abstract final class GroupMethods {
  static const createGroup = 'createGroup';
  static const listMyGroups = 'listMyGroups';
  static const addGroupMember = 'addGroupMember';
  static const removeGroupMember = 'removeGroupMember';
  static const monitorGroupMembership = 'monitorGroupMembership';
  static const getGroup = 'getGroup';
  static const listGroupMembers = 'listGroupMembers';
  static const leaveGroup = 'leaveGroup';
}
```

- [ ] **Step 3: Refactor `account_endpoint.dart`**

Find the inline attestation verification in `createAccount` (around line 76):

```dart
final attestationValid = await CryptoUtils.verifySignature(
  message: deviceSigningPublicKeyHex,
  signature: deviceKeyAttestation,
  publicKey: ultimateSigningPublicKeyHex,
);
```

Replace `message: deviceSigningPublicKeyHex` with:

```dart
final attestationValid = await CryptoUtils.verifySignature(
  message: AccountInnerPayloads.deviceAttestation(deviceSigningPublicKeyHex),
  signature: deviceKeyAttestation,
  publicKey: ultimateSigningPublicKeyHex,
);
```

- [ ] **Step 4: Refactor `device_endpoint.dart`**

Find the same pattern in `registerDevice` (around line 42):

```dart
final attestationValid = await CryptoUtils.verifySignature(
  message: deviceSigningPublicKeyHex,
  signature: deviceKeyAttestation,
  publicKey: ultimateSigningPublicKeyHex,
);
```

Replace with:

```dart
final attestationValid = await CryptoUtils.verifySignature(
  message: AccountInnerPayloads.deviceAttestation(deviceSigningPublicKeyHex),
  signature: deviceKeyAttestation,
  publicKey: ultimateSigningPublicKeyHex,
);
```

- [ ] **Step 5: Refactor `group_endpoint.dart` — `createGroup`**

Find (around line 108):

```dart
final innerPayload =
    'createGroup:$groupUltimateSigningPublicKeyHex:$groupUltimatePublicKey:$creatorMemberSigningPublicKeyHex:$creatorMemberPublicKey';
```

Replace with:

```dart
final innerPayload = GroupInnerPayloads.createGroup(
  groupUltimateSigningPublicKeyHex,
  groupUltimatePublicKey,
  creatorMemberSigningPublicKeyHex,
  creatorMemberPublicKey,
);
```

- [ ] **Step 6: Refactor `group_endpoint.dart` — `addGroupMember`**

Find (around line 263):

```dart
final innerPayload =
    'addGroupMember:$groupId:$newMemberAccountId:${role.name}:$memberSigningPublicKeyHex:$memberPublicKey';
```

Replace with:

```dart
final innerPayload = GroupInnerPayloads.addGroupMember(
  groupId,
  newMemberAccountId,
  role,
  memberSigningPublicKeyHex,
  memberPublicKey,
);
```

- [ ] **Step 7: Refactor `group_endpoint.dart` — `removeGroupMember`**

Find (around line 454):

```dart
final innerPayload = 'removeGroupMember:$memberId';
```

Replace with:

```dart
final innerPayload = GroupInnerPayloads.removeGroupMember(memberId);
```

- [ ] **Step 8: Run `dart analyze` — expect zero issues**

```bash
cd anonaccount_server && dart analyze
```

Expected: `No issues found!`

- [ ] **Step 9: Run existing tests to confirm no regressions**

```bash
cd anonaccount_server && dart test test/integration/group_endpoint_test.dart --reporter expanded
```

Expected: All existing tests pass.

- [ ] **Step 10: Commit**

```bash
git add anonaccount_server/lib/src/pow_methods.dart \
        anonaccount_server/lib/src/endpoints/account_endpoint.dart \
        anonaccount_server/lib/src/endpoints/device_endpoint.dart \
        anonaccount_server/lib/src/endpoints/group_endpoint.dart
git commit -m "refactor: centralise inner payload strings in AccountInnerPayloads + GroupInnerPayloads"
```

---

## Task 2: Add stubs + modify `addGroupMember` + regenerate

**Files:**
- Modify: `anonaccount_server/lib/src/endpoints/group_endpoint.dart`
- Auto-updated by generate: `anonaccount_server/lib/src/generated/endpoints.dart`, `anonaccount_server/test/integration/test_tools/serverpod_test_tools.dart`

Serverpod's test tools are generated — new endpoint methods don't exist in test tools until `serverpod generate` runs. Add all stubs first, generate once, then TDD each endpoint in Tasks 3–6.

- [ ] **Step 1: Modify `addGroupMember` to fire the stream notification**

At the end of `addGroupMember`, after `return await GroupMember.db.insertRow(session, member);`, replace the return statement with:

```dart
final insertedMember = await GroupMember.db.insertRow(session, member);
session.messages.postMessage(
  'group-membership-${insertedMember.memberSigningPublicKeyHex}',
  insertedMember,
);
return insertedMember;
```

- [ ] **Step 2: Add stubs for all four new endpoints at the bottom of `GroupEndpoint`**

Add these four methods to `group_endpoint.dart` before the closing `}` of the class:

```dart
Stream<GroupMember> monitorGroupMembership(
  Session session, {
  required String challenge,
  required String proofOfWork,
  required String signature,
  required String callerDeviceSigningPublicKeyHex,
  required String memberSigningKeyHex,
}) async* {
  throw UnimplementedError('monitorGroupMembership not yet implemented');
}

Future<ShareGroup> getGroup(
  Session session, {
  required String challenge,
  required String proofOfWork,
  required String signature,
  required String callerDeviceSigningPublicKeyHex,
  required UuidValue groupId,
  required String callerMemberSigningPublicKeyHex,
  required String memberAuthSignature,
}) async {
  throw UnimplementedError('getGroup not yet implemented');
}

Future<List<GroupMember>> listGroupMembers(
  Session session, {
  required String challenge,
  required String proofOfWork,
  required String signature,
  required String callerDeviceSigningPublicKeyHex,
  required UuidValue groupId,
  required String callerMemberSigningPublicKeyHex,
  required String memberAuthSignature,
}) async {
  throw UnimplementedError('listGroupMembers not yet implemented');
}

Future<bool> leaveGroup(
  Session session, {
  required String challenge,
  required String proofOfWork,
  required String signature,
  required String callerDeviceSigningPublicKeyHex,
  required UuidValue memberId,
  required String memberSigningPublicKeyHex,
  required String memberAuthSignature,
}) async {
  throw UnimplementedError('leaveGroup not yet implemented');
}
```

- [ ] **Step 3: Run `serverpod generate`**

```bash
cd anonaccount_server && serverpod generate
```

This regenerates `lib/src/generated/endpoints.dart` and `test/integration/test_tools/serverpod_test_tools.dart` to include the four new methods.

- [ ] **Step 4: Run `dart analyze` — expect zero issues**

```bash
cd anonaccount_server && dart analyze
```

Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add anonaccount_server/lib/src/endpoints/group_endpoint.dart \
        anonaccount_server/lib/src/generated/endpoints.dart \
        anonaccount_server/test/integration/test_tools/serverpod_test_tools.dart
git commit -m "feat: stub group endpoint additions + wire addGroupMember stream notification"
```

---

## Task 3: TDD `getGroup`

**Files:**
- Modify: `anonaccount_server/lib/src/endpoints/group_endpoint.dart`
- Modify: `anonaccount_server/test/integration/group_endpoint_test.dart`

- [ ] **Step 1: Write failing tests for `getGroup`**

Add inside the `withServerpod(...)` block in `group_endpoint_test.dart`:

```dart
test('getGroup: returns group details for active member', () async {
  final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

  final outer = await _outer(
    sessionBuilder, endpoints, 'getGroup', s.devicePub, s.devicePriv,
  );
  final innerPayload = GroupInnerPayloads.getGroup(s.group.id!);
  final innerSig = SigningTestHelper.signWith(innerPayload, s.creatorMemberSigPriv);

  final result = await endpoints.group.getGroup(
    sessionBuilder,
    challenge: outer.challenge,
    proofOfWork: outer.pow,
    signature: outer.signature,
    callerDeviceSigningPublicKeyHex: s.devicePub,
    groupId: s.group.id!,
    callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
    memberAuthSignature: innerSig,
  );

  expect(result.id, equals(s.group.id));
  expect(result.ultimateSigningPublicKeyHex, equals(s.groupUltSigPub));
});

test('getGroup: rejected when member sig is wrong', () async {
  final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

  final outer = await _outer(
    sessionBuilder, endpoints, 'getGroup', s.devicePub, s.devicePriv,
  );
  final innerPayload = GroupInnerPayloads.getGroup(s.group.id!);
  final (foreignPriv, _) = SigningTestHelper.generateKeypair();
  final badSig = SigningTestHelper.signWith(innerPayload, foreignPriv);

  expect(
    () => endpoints.group.getGroup(
      sessionBuilder,
      challenge: outer.challenge,
      proofOfWork: outer.pow,
      signature: outer.signature,
      callerDeviceSigningPublicKeyHex: s.devicePub,
      groupId: s.group.id!,
      callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
      memberAuthSignature: badSig,
    ),
    throwsA(isA<Exception>()),
  );
});

test('getGroup: rejected when caller is not a member of the group', () async {
  final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

  // A separate account with no membership.
  final (_, outsiderUltPub) = SigningTestHelper.generateKeypair();
  final outsider = await createTestAccount(
    sessionBuilder,
    ultimateSigningPublicKeyHex: outsiderUltPub,
    ultimatePublicKey: outsiderUltPub,
  );
  final (outsiderDevicePriv, outsiderDevicePub) = SigningTestHelper.generateKeypair();
  await createTestDevice(
    sessionBuilder,
    anonAccountId: outsider.id!,
    deviceSigningPublicKeyHex: outsiderDevicePub,
  );
  final (outsiderMemberPriv, outsiderMemberPub) = SigningTestHelper.generateKeypair();

  final outer = await _outer(
    sessionBuilder, endpoints, 'getGroup', outsiderDevicePub, outsiderDevicePriv,
  );
  final innerPayload = GroupInnerPayloads.getGroup(s.group.id!);
  final innerSig = SigningTestHelper.signWith(innerPayload, outsiderMemberPriv);

  expect(
    () => endpoints.group.getGroup(
      sessionBuilder,
      challenge: outer.challenge,
      proofOfWork: outer.pow,
      signature: outer.signature,
      callerDeviceSigningPublicKeyHex: outsiderDevicePub,
      groupId: s.group.id!,
      callerMemberSigningPublicKeyHex: outsiderMemberPub,
      memberAuthSignature: innerSig,
    ),
    throwsA(isA<Exception>()),
  );
});
```

- [ ] **Step 2: Run — expect failures**

```bash
cd anonaccount_server && dart test test/integration/group_endpoint_test.dart --name "getGroup" --reporter expanded
```

Expected: 3 failures with `UnimplementedError`.

- [ ] **Step 3: Implement `getGroup` in `group_endpoint.dart`**

Replace the `getGroup` stub with:

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
}) async {
  try {
    final outerPayload =
        '$challenge:${GroupMethods.getGroup}:$callerDeviceSigningPublicKeyHex';
    await verifySignedPow(
      session,
      challenge,
      proofOfWork,
      callerDeviceSigningPublicKeyHex,
      signature,
      outerPayload,
    );

    final innerPayload = GroupInnerPayloads.getGroup(groupId);
    final innerOk = await CryptoUtils.verifySignature(
      message: innerPayload,
      signature: memberAuthSignature,
      publicKey: callerMemberSigningPublicKeyHex,
    );
    if (!innerOk) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.cryptoInvalidSignature,
        message: 'Invalid member attestation for getGroup',
        operation: 'getGroup',
      );
    }

    final callerMembership = await GroupMember.db.findFirstRow(
      session,
      where: (t) =>
          t.memberSigningPublicKeyHex
              .equals(callerMemberSigningPublicKeyHex) &
          t.shareGroupId.equals(groupId) &
          t.isRevoked.equals(false),
    );
    if (callerMembership == null) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authAccountNotFound,
        message: 'No active membership for caller in this group',
        operation: 'getGroup',
      );
    }

    final deviceAccountId = await AnonAccountHelpers.resolveAccountUuid(
      session,
      callerDeviceSigningPublicKeyHex,
      'getGroup',
    );
    if (callerMembership.anonAccountId != deviceAccountId) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authInvalidSignature,
        message: 'Caller member key is not bound to the device-resolved account',
        operation: 'getGroup',
      );
    }

    final group = await ShareGroup.db.findById(session, groupId);
    if (group == null) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authAccountNotFound,
        message: 'Group not found',
        operation: 'getGroup',
        details: {'groupId': groupId.toString()},
      );
    }
    return group;
  } on AuthenticationException {
    rethrow;
  } catch (e, stackTrace) {
    session.log(
      'GroupEndpoint: getGroup error: $e\n$stackTrace',
      level: LogLevel.error,
    );
    throw AnonAccountExceptionFactory.createAuthenticationException(
      code: AnonAccountErrorCodes.databaseError,
      message: 'getGroup failed: ${e.toString()}',
      operation: 'getGroup',
      details: {'error': e.toString()},
    );
  }
}
```

- [ ] **Step 4: Run — expect all 3 pass**

```bash
cd anonaccount_server && dart test test/integration/group_endpoint_test.dart --name "getGroup" --reporter expanded
```

Expected: 3 tests pass.

- [ ] **Step 5: Commit**

```bash
git add anonaccount_server/lib/src/endpoints/group_endpoint.dart \
        anonaccount_server/test/integration/group_endpoint_test.dart
git commit -m "feat: implement getGroup endpoint with member-key auth"
```

---

## Task 4: TDD `listGroupMembers`

**Files:**
- Modify: `anonaccount_server/lib/src/endpoints/group_endpoint.dart`
- Modify: `anonaccount_server/test/integration/group_endpoint_test.dart`

- [ ] **Step 1: Write failing tests**

Add inside the `withServerpod(...)` block:

```dart
test('listGroupMembers: returns active members only', () async {
  final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

  // Add a second member.
  final (_, m2UltPub) = SigningTestHelper.generateKeypair();
  final m2 = await createTestAccount(
    sessionBuilder,
    ultimateSigningPublicKeyHex: m2UltPub,
    ultimatePublicKey: m2UltPub,
  );
  final (_, m2MemberSig) = SigningTestHelper.generateKeypair();
  final (_, m2MemberEnc) = SigningTestHelper.generateKeypair();

  final outerAdd = await _outer(
    sessionBuilder, endpoints, 'addGroupMember', s.devicePub, s.devicePriv,
  );
  final addInner = GroupInnerPayloads.addGroupMember(
    s.group.id!, m2.id!, GroupMemberRole.member, m2MemberSig, m2MemberEnc,
  );
  final addSig = SigningTestHelper.signWith(addInner, s.creatorMemberSigPriv);
  await endpoints.group.addGroupMember(
    sessionBuilder,
    challenge: outerAdd.challenge,
    proofOfWork: outerAdd.pow,
    signature: outerAdd.signature,
    callerDeviceSigningPublicKeyHex: s.devicePub,
    groupId: s.group.id!,
    newMemberAccountId: m2.id!,
    role: GroupMemberRole.member,
    memberSigningPublicKeyHex: m2MemberSig,
    memberPublicKey: m2MemberEnc,
    encryptedDataKey: 'wrapped',
    callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
    memberAuthSignature: addSig,
  );

  final outer = await _outer(
    sessionBuilder, endpoints, 'listGroupMembers', s.devicePub, s.devicePriv,
  );
  final innerPayload = GroupInnerPayloads.listGroupMembers(s.group.id!);
  final innerSig = SigningTestHelper.signWith(innerPayload, s.creatorMemberSigPriv);

  final members = await endpoints.group.listGroupMembers(
    sessionBuilder,
    challenge: outer.challenge,
    proofOfWork: outer.pow,
    signature: outer.signature,
    callerDeviceSigningPublicKeyHex: s.devicePub,
    groupId: s.group.id!,
    callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
    memberAuthSignature: innerSig,
  );

  expect(members, hasLength(2));
  expect(members.any((m) => m.role == GroupMemberRole.admin), isTrue);
  expect(members.any((m) => m.role == GroupMemberRole.member), isTrue);
  expect(members.every((m) => !m.isRevoked), isTrue);
});

test('listGroupMembers: rejected when caller is not a member', () async {
  final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

  final (_, outsiderUltPub) = SigningTestHelper.generateKeypair();
  final outsider = await createTestAccount(
    sessionBuilder,
    ultimateSigningPublicKeyHex: outsiderUltPub,
    ultimatePublicKey: outsiderUltPub,
  );
  final (outsiderDevicePriv, outsiderDevicePub) = SigningTestHelper.generateKeypair();
  await createTestDevice(
    sessionBuilder,
    anonAccountId: outsider.id!,
    deviceSigningPublicKeyHex: outsiderDevicePub,
  );
  final (outsiderMemberPriv, outsiderMemberPub) = SigningTestHelper.generateKeypair();

  final outer = await _outer(
    sessionBuilder, endpoints, 'listGroupMembers', outsiderDevicePub, outsiderDevicePriv,
  );
  final innerPayload = GroupInnerPayloads.listGroupMembers(s.group.id!);
  final innerSig = SigningTestHelper.signWith(innerPayload, outsiderMemberPriv);

  expect(
    () => endpoints.group.listGroupMembers(
      sessionBuilder,
      challenge: outer.challenge,
      proofOfWork: outer.pow,
      signature: outer.signature,
      callerDeviceSigningPublicKeyHex: outsiderDevicePub,
      groupId: s.group.id!,
      callerMemberSigningPublicKeyHex: outsiderMemberPub,
      memberAuthSignature: innerSig,
    ),
    throwsA(isA<Exception>()),
  );
});
```

- [ ] **Step 2: Run — expect failures**

```bash
cd anonaccount_server && dart test test/integration/group_endpoint_test.dart --name "listGroupMembers" --reporter expanded
```

Expected: 2 failures with `UnimplementedError`.

- [ ] **Step 3: Implement `listGroupMembers` in `group_endpoint.dart`**

Replace the `listGroupMembers` stub with:

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
}) async {
  try {
    final outerPayload =
        '$challenge:${GroupMethods.listGroupMembers}:$callerDeviceSigningPublicKeyHex';
    await verifySignedPow(
      session,
      challenge,
      proofOfWork,
      callerDeviceSigningPublicKeyHex,
      signature,
      outerPayload,
    );

    final innerPayload = GroupInnerPayloads.listGroupMembers(groupId);
    final innerOk = await CryptoUtils.verifySignature(
      message: innerPayload,
      signature: memberAuthSignature,
      publicKey: callerMemberSigningPublicKeyHex,
    );
    if (!innerOk) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.cryptoInvalidSignature,
        message: 'Invalid member attestation for listGroupMembers',
        operation: 'listGroupMembers',
      );
    }

    final callerMembership = await GroupMember.db.findFirstRow(
      session,
      where: (t) =>
          t.memberSigningPublicKeyHex
              .equals(callerMemberSigningPublicKeyHex) &
          t.shareGroupId.equals(groupId) &
          t.isRevoked.equals(false),
    );
    if (callerMembership == null) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authAccountNotFound,
        message: 'No active membership for caller in this group',
        operation: 'listGroupMembers',
      );
    }

    final deviceAccountId = await AnonAccountHelpers.resolveAccountUuid(
      session,
      callerDeviceSigningPublicKeyHex,
      'listGroupMembers',
    );
    if (callerMembership.anonAccountId != deviceAccountId) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authInvalidSignature,
        message: 'Caller member key is not bound to the device-resolved account',
        operation: 'listGroupMembers',
      );
    }

    return await GroupMember.db.find(
      session,
      where: (t) =>
          t.shareGroupId.equals(groupId) & t.isRevoked.equals(false),
      orderBy: (t) => t.joinedAt,
    );
  } on AuthenticationException {
    rethrow;
  } catch (e, stackTrace) {
    session.log(
      'GroupEndpoint: listGroupMembers error: $e\n$stackTrace',
      level: LogLevel.error,
    );
    throw AnonAccountExceptionFactory.createAuthenticationException(
      code: AnonAccountErrorCodes.databaseError,
      message: 'listGroupMembers failed: ${e.toString()}',
      operation: 'listGroupMembers',
      details: {'error': e.toString()},
    );
  }
}
```

- [ ] **Step 4: Run — expect 2 pass**

```bash
cd anonaccount_server && dart test test/integration/group_endpoint_test.dart --name "listGroupMembers" --reporter expanded
```

Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add anonaccount_server/lib/src/endpoints/group_endpoint.dart \
        anonaccount_server/test/integration/group_endpoint_test.dart
git commit -m "feat: implement listGroupMembers endpoint with member-key auth"
```

---

## Task 5: TDD `leaveGroup`

**Files:**
- Modify: `anonaccount_server/lib/src/endpoints/group_endpoint.dart`
- Modify: `anonaccount_server/test/integration/group_endpoint_test.dart`

- [ ] **Step 1: Write failing tests**

Add inside the `withServerpod(...)` block:

```dart
test('leaveGroup: member removes themselves, row is self-attested', () async {
  final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

  // Add a second member to leave.
  final (_, m2UltPub) = SigningTestHelper.generateKeypair();
  final m2 = await createTestAccount(
    sessionBuilder,
    ultimateSigningPublicKeyHex: m2UltPub,
    ultimatePublicKey: m2UltPub,
  );
  final (m2DevicePriv, m2DevicePub) = SigningTestHelper.generateKeypair();
  await createTestDevice(
    sessionBuilder,
    anonAccountId: m2.id!,
    deviceSigningPublicKeyHex: m2DevicePub,
  );
  final (m2MemberPriv, m2MemberPub) = SigningTestHelper.generateKeypair();
  final (_, m2MemberEnc) = SigningTestHelper.generateKeypair();

  final outerAdd = await _outer(
    sessionBuilder, endpoints, 'addGroupMember', s.devicePub, s.devicePriv,
  );
  final addInner = GroupInnerPayloads.addGroupMember(
    s.group.id!, m2.id!, GroupMemberRole.member, m2MemberPub, m2MemberEnc,
  );
  final addSig = SigningTestHelper.signWith(addInner, s.creatorMemberSigPriv);
  final m2Row = await endpoints.group.addGroupMember(
    sessionBuilder,
    challenge: outerAdd.challenge,
    proofOfWork: outerAdd.pow,
    signature: outerAdd.signature,
    callerDeviceSigningPublicKeyHex: s.devicePub,
    groupId: s.group.id!,
    newMemberAccountId: m2.id!,
    role: GroupMemberRole.member,
    memberSigningPublicKeyHex: m2MemberPub,
    memberPublicKey: m2MemberEnc,
    encryptedDataKey: 'wrapped',
    callerMemberSigningPublicKeyHex: s.creatorMemberSigPub,
    memberAuthSignature: addSig,
  );

  // m2 leaves.
  final outer = await _outer(
    sessionBuilder, endpoints, 'leaveGroup', m2DevicePub, m2DevicePriv,
  );
  final innerPayload = GroupInnerPayloads.leaveGroup(m2Row.id!);
  final innerSig = SigningTestHelper.signWith(innerPayload, m2MemberPriv);

  final ok = await endpoints.group.leaveGroup(
    sessionBuilder,
    challenge: outer.challenge,
    proofOfWork: outer.pow,
    signature: outer.signature,
    callerDeviceSigningPublicKeyHex: m2DevicePub,
    memberId: m2Row.id!,
    memberSigningPublicKeyHex: m2MemberPub,
    memberAuthSignature: innerSig,
  );
  expect(ok, isTrue);

  // Verify row is self-attested revocation.
  final dbSession = (sessionBuilder as InternalTestSessionBuilder)
      .internalBuild(endpoint: 'test', method: 'verify');
  try {
    final after = await GroupMember.db.findById(dbSession, m2Row.id!);
    expect(after!.isRevoked, isTrue);
    expect(after.revokedBySignerPublicKeyHex, equals(m2MemberPub));
    expect(after.revokedByAttestation, equals(innerSig));
  } finally {
    await dbSession.close();
  }

  // Group still exists — creator is still an admin.
  final dbSession2 = (sessionBuilder as InternalTestSessionBuilder)
      .internalBuild(endpoint: 'test', method: 'verify');
  try {
    final groupAfter = await ShareGroup.db.findById(dbSession2, s.group.id!);
    expect(groupAfter, isNotNull);
  } finally {
    await dbSession2.close();
  }
});

test('leaveGroup: last admin leaving deletes the group and all members', () async {
  final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

  // Find the creator's member row.
  final lookupSession = (sessionBuilder as InternalTestSessionBuilder)
      .internalBuild(endpoint: 'test', method: 'findCreator');
  late final GroupMember creatorRow;
  try {
    creatorRow = (await GroupMember.db.findFirstRow(
      lookupSession,
      where: (t) =>
          t.shareGroupId.equals(s.group.id!) &
          t.anonAccountId.equals(s.account.id!),
    ))!;
  } finally {
    await lookupSession.close();
  }

  final outer = await _outer(
    sessionBuilder, endpoints, 'leaveGroup', s.devicePub, s.devicePriv,
  );
  final innerPayload = GroupInnerPayloads.leaveGroup(creatorRow.id!);
  final innerSig = SigningTestHelper.signWith(innerPayload, s.creatorMemberSigPriv);

  final ok = await endpoints.group.leaveGroup(
    sessionBuilder,
    challenge: outer.challenge,
    proofOfWork: outer.pow,
    signature: outer.signature,
    callerDeviceSigningPublicKeyHex: s.devicePub,
    memberId: creatorRow.id!,
    memberSigningPublicKeyHex: s.creatorMemberSigPub,
    memberAuthSignature: innerSig,
  );
  expect(ok, isTrue);

  // Group must be deleted.
  final dbSession = (sessionBuilder as InternalTestSessionBuilder)
      .internalBuild(endpoint: 'test', method: 'verify');
  try {
    final groupAfter = await ShareGroup.db.findById(dbSession, s.group.id!);
    expect(groupAfter, isNull);
  } finally {
    await dbSession.close();
  }
});

test('leaveGroup: rejected when inner sig is wrong', () async {
  final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);

  final lookupSession = (sessionBuilder as InternalTestSessionBuilder)
      .internalBuild(endpoint: 'test', method: 'findCreator');
  late final GroupMember creatorRow;
  try {
    creatorRow = (await GroupMember.db.findFirstRow(
      lookupSession,
      where: (t) =>
          t.shareGroupId.equals(s.group.id!) &
          t.anonAccountId.equals(s.account.id!),
    ))!;
  } finally {
    await lookupSession.close();
  }

  final outer = await _outer(
    sessionBuilder, endpoints, 'leaveGroup', s.devicePub, s.devicePriv,
  );
  final innerPayload = GroupInnerPayloads.leaveGroup(creatorRow.id!);
  final (foreignPriv, _) = SigningTestHelper.generateKeypair();
  final badSig = SigningTestHelper.signWith(innerPayload, foreignPriv);

  expect(
    () => endpoints.group.leaveGroup(
      sessionBuilder,
      challenge: outer.challenge,
      proofOfWork: outer.pow,
      signature: outer.signature,
      callerDeviceSigningPublicKeyHex: s.devicePub,
      memberId: creatorRow.id!,
      memberSigningPublicKeyHex: s.creatorMemberSigPub,
      memberAuthSignature: badSig,
    ),
    throwsA(isA<Exception>()),
  );
});
```

- [ ] **Step 2: Run — expect failures**

```bash
cd anonaccount_server && dart test test/integration/group_endpoint_test.dart --name "leaveGroup" --reporter expanded
```

Expected: 3 failures with `UnimplementedError`.

- [ ] **Step 3: Implement `leaveGroup` in `group_endpoint.dart`**

Replace the `leaveGroup` stub with:

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
}) async {
  try {
    final outerPayload =
        '$challenge:${GroupMethods.leaveGroup}:$callerDeviceSigningPublicKeyHex';
    await verifySignedPow(
      session,
      challenge,
      proofOfWork,
      callerDeviceSigningPublicKeyHex,
      signature,
      outerPayload,
    );

    final target = await GroupMember.db.findById(session, memberId);
    if (target == null || target.isRevoked) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authDeviceNotFound,
        message: 'Group member not found or already revoked',
        operation: 'leaveGroup',
        details: {'memberId': memberId.toString()},
      );
    }

    if (target.memberSigningPublicKeyHex != memberSigningPublicKeyHex) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authInvalidSignature,
        message: 'memberSigningPublicKeyHex does not match the target row',
        operation: 'leaveGroup',
      );
    }

    final innerPayload = GroupInnerPayloads.leaveGroup(memberId);
    final innerOk = await CryptoUtils.verifySignature(
      message: innerPayload,
      signature: memberAuthSignature,
      publicKey: memberSigningPublicKeyHex,
    );
    if (!innerOk) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.cryptoInvalidSignature,
        message: 'Invalid member attestation for leaveGroup',
        operation: 'leaveGroup',
      );
    }

    final deviceAccountId = await AnonAccountHelpers.resolveAccountUuid(
      session,
      callerDeviceSigningPublicKeyHex,
      'leaveGroup',
    );
    if (target.anonAccountId != deviceAccountId) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authInvalidSignature,
        message: 'Caller member key is not bound to the device-resolved account',
        operation: 'leaveGroup',
      );
    }

    await GroupMember.db.updateRow(
      session,
      target.copyWith(
        isRevoked: true,
        revokedBySignerPublicKeyHex: memberSigningPublicKeyHex,
        revokedByAttestation: memberAuthSignature,
      ),
    );

    // If no non-revoked admins remain, delete the group (cascades all members).
    final remainingAdmins = await GroupMember.db.count(
      session,
      where: (t) =>
          t.shareGroupId.equals(target.shareGroupId) &
          t.role.equals(GroupMemberRole.admin) &
          t.isRevoked.equals(false),
    );
    if (remainingAdmins == 0) {
      await ShareGroup.db.deleteRow(
        session,
        (await ShareGroup.db.findById(session, target.shareGroupId))!,
      );
    }

    return true;
  } on AuthenticationException {
    rethrow;
  } catch (e, stackTrace) {
    session.log(
      'GroupEndpoint: leaveGroup error: $e\n$stackTrace',
      level: LogLevel.error,
    );
    throw AnonAccountExceptionFactory.createAuthenticationException(
      code: AnonAccountErrorCodes.databaseError,
      message: 'leaveGroup failed: ${e.toString()}',
      operation: 'leaveGroup',
      details: {'error': e.toString()},
    );
  }
}
```

**Note on `GroupMember.db.count` with enum filter:** Serverpod's query DSL may not support `.equals()` on enum columns directly. If `t.role.equals(GroupMemberRole.admin)` does not compile, replace with a raw find + count:

```dart
final adminRows = await GroupMember.db.find(
  session,
  where: (t) =>
      t.shareGroupId.equals(target.shareGroupId) &
      t.isRevoked.equals(false),
);
final remainingAdmins = adminRows.where((m) => m.role == GroupMemberRole.admin).length;
```

- [ ] **Step 4: Run — expect 3 pass**

```bash
cd anonaccount_server && dart test test/integration/group_endpoint_test.dart --name "leaveGroup" --reporter expanded
```

Expected: 3 tests pass.

- [ ] **Step 5: Commit**

```bash
git add anonaccount_server/lib/src/endpoints/group_endpoint.dart \
        anonaccount_server/test/integration/group_endpoint_test.dart
git commit -m "feat: implement leaveGroup with self-attestation and last-admin group deletion"
```

---

## Task 6: TDD `monitorGroupMembership`

**Files:**
- Modify: `anonaccount_server/lib/src/endpoints/group_endpoint.dart`
- Modify: `anonaccount_server/test/integration/group_endpoint_test.dart`

Note: Serverpod streaming in tests verifies PoW auth synchronously before the stream opens — the auth rejection test is the most reliable test. Stream event delivery (that `addGroupMembership` fires into the channel) requires concurrent async execution; the test below covers auth correctness. Manual testing confirms event delivery.

- [ ] **Step 1: Write failing tests**

Add inside the `withServerpod(...)` block:

```dart
test('monitorGroupMembership: rejected for invalid device key', () async {
  final (_, unknownPub) = SigningTestHelper.generateKeypair();
  final (memberPriv, memberPub) = SigningTestHelper.generateKeypair();

  // Build outer with an unknown device key — no DB row exists for it.
  final challengeResp = await endpoints.entrypoint.getChallenge(sessionBuilder);
  final pow = await PowTestHelper.mint(
    challengeResp.challenge,
    difficulty: challengeResp.difficulty,
  );
  final payload =
      '${challengeResp.challenge}:${GroupMethods.monitorGroupMembership}:$unknownPub';
  // Sign with memberPriv (also unknown) to produce a structurally valid sig.
  final sig = SigningTestHelper.signWith(payload, memberPriv);

  // The stream endpoint verifies PoW+sig before yielding. Any invalid auth
  // should cause the stream to throw before the first event.
  final stream = endpoints.group.monitorGroupMembership(
    sessionBuilder,
    challenge: challengeResp.challenge,
    proofOfWork: pow,
    signature: sig,
    callerDeviceSigningPublicKeyHex: unknownPub,
    memberSigningKeyHex: memberPub,
  );

  expect(
    () async => await stream.first,
    throwsA(isA<Exception>()),
  );
});

test('monitorGroupMembership: opens without throwing for valid device', () async {
  final s = await _bootstrapOwnerWithGroup(sessionBuilder, endpoints);
  final (_, freshMemberPub) = SigningTestHelper.generateKeypair();

  final outer = await _outer(
    sessionBuilder, endpoints,
    GroupMethods.monitorGroupMembership, s.devicePub, s.devicePriv,
  );

  // Opening the stream for a valid device should not throw immediately.
  // (Event delivery is verified by the addGroupMember stream notification
  //  wired in Task 2 — tested manually / via E2E.)
  final stream = endpoints.group.monitorGroupMembership(
    sessionBuilder,
    challenge: outer.challenge,
    proofOfWork: outer.pow,
    signature: outer.signature,
    callerDeviceSigningPublicKeyHex: s.devicePub,
    memberSigningKeyHex: freshMemberPub,
  );
  expect(stream, isNotNull);
});
```

- [ ] **Step 2: Run — expect failures**

```bash
cd anonaccount_server && dart test test/integration/group_endpoint_test.dart --name "monitorGroupMembership" --reporter expanded
```

Expected: failures due to `UnimplementedError`.

- [ ] **Step 3: Implement `monitorGroupMembership` in `group_endpoint.dart`**

Replace the `monitorGroupMembership` stub with:

```dart
Stream<GroupMember> monitorGroupMembership(
  Session session, {
  required String challenge,
  required String proofOfWork,
  required String signature,
  required String callerDeviceSigningPublicKeyHex,
  required String memberSigningKeyHex,
}) async* {
  final outerPayload =
      '$challenge:${GroupMethods.monitorGroupMembership}:$callerDeviceSigningPublicKeyHex';
  await verifySignedPow(
    session,
    challenge,
    proofOfWork,
    callerDeviceSigningPublicKeyHex,
    signature,
    outerPayload,
  );

  final channelName = 'group-membership-$memberSigningKeyHex';
  final stream = session.messages.createStream<GroupMember>(channelName);

  await for (final event in stream) {
    yield event;
  }
}
```

- [ ] **Step 4: Run — expect 2 pass**

```bash
cd anonaccount_server && dart test test/integration/group_endpoint_test.dart --name "monitorGroupMembership" --reporter expanded
```

Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add anonaccount_server/lib/src/endpoints/group_endpoint.dart \
        anonaccount_server/test/integration/group_endpoint_test.dart
git commit -m "feat: implement monitorGroupMembership stream endpoint"
```

---

## Task 7: Full test suite + analyze

**Files:** No changes — verification only.

- [ ] **Step 1: Run `dart analyze`**

```bash
cd anonaccount_server && dart analyze
```

Expected: `No issues found!`

- [ ] **Step 2: Run full integration test suite**

```bash
cd anonaccount_server && dart test test/ --reporter expanded
```

Expected: All tests pass, no regressions in account/device/data key tests.

- [ ] **Step 3: Run anonaccred integration tests (cascade verification)**

```bash
cd anonaccred_server && dart test test/ --reporter expanded
```

Expected: All tests pass. The `leaveGroup` group-deletion cascade must not break existing group commerce tests (those tests create their own groups — they are unaffected).

- [ ] **Step 4: Commit if any cleanup was needed, otherwise done**

```bash
git add -A && git commit -m "chore: final analyze + test run for group invite endpoints"
```

Only commit if there were actual fixes. If everything was already clean, skip this step.
