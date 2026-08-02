import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'test_tools/serverpod_test_tools.dart';

/// Local fixture helper — `createTestDevice` is a file-private function in
/// `group_endpoint_test.dart`, so we replicate its pattern here.
Future<AccountDevice> createTestDevice(
  TestSessionBuilder sessionBuilder, {
  required UuidValue anonAccountId,
  required String deviceSigningPublicKeyHex,
  required String deviceEncryptionPublicKeyHex,
  bool isRevoked = false,
}) async {
  final session = (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: 'createTestDevice',
  );
  try {
    final device = AccountDevice(
      anonAccountId: anonAccountId,
      deviceSigningPublicKeyHex: deviceSigningPublicKeyHex,
      deviceEncryptionPublicKeyHex: deviceEncryptionPublicKeyHex,
      encryptedDataKey: 'test-device-encrypted-data-key',
      label: 'test-device',
      addedBySignerPublicKeyHex: deviceSigningPublicKeyHex,
      addedByAttestation: 'test-attestation',
      lastActive: DateTime.now(),
      isRevoked: isRevoked,
    );
    return await AccountDevice.db.insertRow(session, device);
  } finally {
    await session.close();
  }
}

/// Build a ShareGroup + GroupMember for an account, both inserted directly
/// via DB so the test has the membership row's id and memberSigningPublicKeyHex
/// without driving the full createGroup / addGroupMember PoW chain.
Future<({GroupMember member, AccountDevice ownerDevice, String groupUltSigPub, String creatorMemberSigPub, String creatorMemberSigPriv, String ownerDevicePriv, String ownerDevicePub})>
    bootstrapCallerWithMembership(
  TestSessionBuilder sessionBuilder, {
  String role = 'admin',
}) async {
  final (ownerDevicePriv, ownerDevicePub) = SigningTestHelper.generateKeypair();
  final (_, ownerDeviceEnc) = SigningTestHelper.generateKeypair();
  final (accUltSigPriv, accUltPub) = SigningTestHelper.generateKeypair();
  final (_, accUltEnc) = SigningTestHelper.generateKeypair();
  final (groupUltSigPriv, groupUltSigPub) = SigningTestHelper.generateKeypair();
  final (_, groupUltEnc) = SigningTestHelper.generateKeypair();
  final (creatorMemberSigPriv, creatorMemberSigPub) =
      SigningTestHelper.generateKeypair();
  final (_, creatorMemberEnc) = SigningTestHelper.generateKeypair();

  final account = await createTestAccount(
    sessionBuilder,
    ultimateSigningPublicKeyHex: accUltPub,
    ultimateEncryptionPublicKeyHex: accUltEnc,
  );
  final ownerDevice = await createTestDevice(
    sessionBuilder,
    anonAccountId: account.id!,
    deviceSigningPublicKeyHex: ownerDevicePub,
    deviceEncryptionPublicKeyHex: ownerDeviceEnc,
  );

  final setupSession =
      (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: 'bootstrapSetup',
  );
  try {
    final group = await ShareGroup.db.insertRow(
      setupSession,
      ShareGroup(
        ultimateSigningPublicKeyHex: groupUltSigPub,
        ultimateEncryptionPublicKeyHex: groupUltEnc,
        encryptedDataKey: 'wrapped',
      ),
    );
    final member = await GroupMember.db.insertRow(
      setupSession,
      GroupMember(
        shareGroupId: group.id!,
        anonAccountId: account.id!,
        role: GroupMemberRole.values.byName(role),
        memberSigningPublicKeyHex: creatorMemberSigPub,
        memberEncryptionPublicKeyHex: creatorMemberEnc,
        encryptedDataKey: 'wrapped',
        addedBySignerPublicKeyHex: groupUltSigPub,
        addedByAttestation: 'sig',
      ),
    );
    return (
      member: member,
      ownerDevice: ownerDevice,
      groupUltSigPub: groupUltSigPub,
      creatorMemberSigPub: creatorMemberSigPub,
      creatorMemberSigPriv: creatorMemberSigPriv,
      ownerDevicePriv: ownerDevicePriv,
      ownerDevicePub: ownerDevicePub,
    );
  } finally {
    await setupSession.close();
  }
}

/// Build a second device (or pair) for the same account; returns the new
/// device plus its private key (for signing), and the encryption public key
/// hex (for the grantee half of the payload).
Future<({AccountDevice device, String priv, String pub, String encPub})>
    createSiblingDevice(
  TestSessionBuilder sessionBuilder, {
  required UuidValue anonAccountId,
  bool isRevoked = false,
}) async {
  final (priv, pub) = SigningTestHelper.generateKeypair();
  final (_, enc) = SigningTestHelper.generateKeypair();
  final device = await createTestDevice(
    sessionBuilder,
    anonAccountId: anonAccountId,
    deviceSigningPublicKeyHex: pub,
    deviceEncryptionPublicKeyHex: enc,
    isRevoked: isRevoked,
  );
  return (device: device, priv: priv, pub: pub, encPub: enc);
}

/// Build the outer PoW envelope for a group endpoint call.
Future<({String challenge, String pow, String signature})> outerEnvelope(
  TestSessionBuilder sessionBuilder,
  TestEndpoints endpoints,
  String methodName,
  String pubKey,
  String privKey,
) async {
  final c = await endpoints.entrypoint.getChallenge(sessionBuilder);
  final pow = await PowTestHelper.mint(c.challenge, difficulty: c.difficulty);
  final payload = '${c.challenge}:$methodName:$pubKey';
  final sig = SigningTestHelper.signWith(payload, privKey);
  return (challenge: c.challenge, pow: pow, signature: sig);
}

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('GroupMemberDevice schema', (sessionBuilder, endpoints) {
    test('a grant row round-trips and defaults to not revoked', () async {
      final session = sessionBuilder.build();

      // Bootstrap a membership row directly via DB so we have its id and
      // memberSigningPublicKeyHex available without going through the full
      // PoW-signed endpoint chain — the schema invariant under test is the
      // row itself, not the createGroup flow.
      final lookupSession =
          (sessionBuilder as InternalTestSessionBuilder).internalBuild(
        endpoint: 'test',
        method: 'lookupCreator',
      );
      late final GroupMember member;
      late final AccountDevice device;
      try {
        final (_, accUltPub) = SigningTestHelper.generateKeypair();
        final account = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: accUltPub,
          ultimateEncryptionPublicKeyHex: accUltPub,
        );
        final (_, devicePub) = SigningTestHelper.generateKeypair();
        final (_, deviceEnc) = SigningTestHelper.generateKeypair();
        device = await createTestDevice(
          sessionBuilder,
          anonAccountId: account.id!,
          deviceSigningPublicKeyHex: devicePub,
          deviceEncryptionPublicKeyHex: deviceEnc,
        );
        final (_, groupUltSigPub) = SigningTestHelper.generateKeypair();
        final (_, groupUltEnc) = SigningTestHelper.generateKeypair();
        final (_, creatorMemberSigPub) = SigningTestHelper.generateKeypair();
        final (_, creatorMemberEnc) = SigningTestHelper.generateKeypair();

        final group = await ShareGroup.db.insertRow(
          lookupSession,
          ShareGroup(
            ultimateSigningPublicKeyHex: groupUltSigPub,
            ultimateEncryptionPublicKeyHex: groupUltEnc,
            encryptedDataKey: 'wrapped',
          ),
        );
        member = await GroupMember.db.insertRow(
          lookupSession,
          GroupMember(
            shareGroupId: group.id!,
            anonAccountId: account.id!,
            role: GroupMemberRole.admin,
            memberSigningPublicKeyHex: creatorMemberSigPub,
            memberEncryptionPublicKeyHex: creatorMemberEnc,
            encryptedDataKey: 'wrapped',
            addedBySignerPublicKeyHex: groupUltSigPub,
            addedByAttestation: 'sig',
          ),
        );
      } finally {
        await lookupSession.close();
      }

      final row = await GroupMemberDevice.db.insertRow(
        session,
        GroupMemberDevice(
          groupMemberId: member.id!,
          accountDeviceId: device.id!,
          encryptedDataKey: 'wrapped-to-device',
          addedBySignerPublicKeyHex: member.memberSigningPublicKeyHex,
          addedByAttestation: 'sig',
        ),
      );

      expect(row.isRevoked, isFalse);
      expect(row.revokedAt, isNull);
      expect(row.createdAt, isNotNull);
      expect(row.encryptedDataKey, equals('wrapped-to-device'));
      expect(
        row.addedBySignerPublicKeyHex,
        equals(member.memberSigningPublicKeyHex),
      );
    });

    test('the unique index is partial: a revoked pair can be re-granted',
        () async {
      final session = sessionBuilder.build();

      final lookupSession =
          (sessionBuilder as InternalTestSessionBuilder).internalBuild(
        endpoint: 'test',
        method: 'lookupCreator',
      );
      late final GroupMember member;
      late final AccountDevice device;
      try {
        final (_, accUltPub) = SigningTestHelper.generateKeypair();
        final account = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: accUltPub,
          ultimateEncryptionPublicKeyHex: accUltPub,
        );
        final (_, devicePub) = SigningTestHelper.generateKeypair();
        final (_, deviceEnc) = SigningTestHelper.generateKeypair();
        device = await createTestDevice(
          sessionBuilder,
          anonAccountId: account.id!,
          deviceSigningPublicKeyHex: devicePub,
          deviceEncryptionPublicKeyHex: deviceEnc,
        );
        final (_, groupUltSigPub) = SigningTestHelper.generateKeypair();
        final (_, groupUltEnc) = SigningTestHelper.generateKeypair();
        final (_, creatorMemberSigPub) = SigningTestHelper.generateKeypair();
        final (_, creatorMemberEnc) = SigningTestHelper.generateKeypair();

        final group = await ShareGroup.db.insertRow(
          lookupSession,
          ShareGroup(
            ultimateSigningPublicKeyHex: groupUltSigPub,
            ultimateEncryptionPublicKeyHex: groupUltEnc,
            encryptedDataKey: 'wrapped',
          ),
        );
        member = await GroupMember.db.insertRow(
          lookupSession,
          GroupMember(
            shareGroupId: group.id!,
            anonAccountId: account.id!,
            role: GroupMemberRole.admin,
            memberSigningPublicKeyHex: creatorMemberSigPub,
            memberEncryptionPublicKeyHex: creatorMemberEnc,
            encryptedDataKey: 'wrapped',
            addedBySignerPublicKeyHex: groupUltSigPub,
            addedByAttestation: 'sig',
          ),
        );
      } finally {
        await lookupSession.close();
      }

      // First grant.
      final first = await GroupMemberDevice.db.insertRow(
        session,
        GroupMemberDevice(
          groupMemberId: member.id!,
          accountDeviceId: device.id!,
          encryptedDataKey: 'blob-v1',
          addedBySignerPublicKeyHex: member.memberSigningPublicKeyHex,
          addedByAttestation: 'sig-1',
        ),
      );

      // Revoke the first grant — without the partial index the second
      // insert would hit the unconditional unique constraint.
      await GroupMemberDevice.db.updateRow(
        session,
        first.copyWith(isRevoked: true, revokedAt: DateTime.now()),
      );

      // Same (groupMemberId, accountDeviceId) pair — must succeed because
      // the unique index is partial on isRevoked = false.
      final second = await GroupMemberDevice.db.insertRow(
        session,
        GroupMemberDevice(
          groupMemberId: member.id!,
          accountDeviceId: device.id!,
          encryptedDataKey: 'blob-v2',
          addedBySignerPublicKeyHex: member.memberSigningPublicKeyHex,
          addedByAttestation: 'sig-2',
        ),
      );

      expect(second.id, isNot(equals(first.id)));
      expect(second.encryptedDataKey, equals('blob-v2'));
      expect(second.isRevoked, isFalse);
    });
  });

  withServerpod('GroupEndpoint.grantMemberDevice', (
    sessionBuilder,
    endpoints,
  ) {
    test('persists a grant with attestation and signer when attested by the member key', () async {
      final s = await bootstrapCallerWithMembership(sessionBuilder);
      final sibling = await createSiblingDevice(
        sessionBuilder,
        anonAccountId: s.ownerDevice.anonAccountId,
      );

      final outer = await outerEnvelope(
        sessionBuilder,
        endpoints,
        GroupMethods.grantMemberDevice,
        s.ownerDevicePub,
        s.ownerDevicePriv,
      );

      final grantee = PublicKeyDuo(
        signingPublicKeyHex: sibling.device.deviceSigningPublicKeyHex,
        encryptionPublicKeyHex: sibling.device.deviceEncryptionPublicKeyHex,
      );
      final innerPayload = GroupInnerPayloads.grantMemberDevice(
        s.member.id!,
        grantee,
        'blob-for-sibling',
      );
      final attestation =
          SigningTestHelper.signWith(innerPayload, s.creatorMemberSigPriv);

      final result = await endpoints.group.grantMemberDevice(
        sessionBuilder,
        challenge: outer.challenge,
        proofOfWork: outer.pow,
        signature: outer.signature,
        callerDeviceSigningPublicKeyHex: s.ownerDevicePub,
        grants: [
          MemberDeviceGrant(
            groupMemberId: s.member.id!,
            accountDeviceId: sibling.device.id!,
            encryptedDataKey: 'blob-for-sibling',
            attestorSigningPublicKeyHex: s.creatorMemberSigPub,
            tier: GrantTier.root,
            attestation: attestation,
          ),
        ],
      );

      expect(result.granted, hasLength(1));
      expect(result.alreadyGranted, isEmpty);
      expect(result.granted.single.groupMemberId, equals(s.member.id!));
      expect(result.granted.single.accountDeviceId, equals(sibling.device.id!));

      final verifySession =
          (sessionBuilder as InternalTestSessionBuilder).internalBuild(
        endpoint: 'test',
        method: 'verify',
      );
      try {
        final row = await GroupMemberDevice.db.findFirstRow(
          verifySession,
          where: (t) =>
              t.groupMemberId.equals(s.member.id!) &
              t.accountDeviceId.equals(sibling.device.id!) &
              t.isRevoked.equals(false),
        );
        expect(row, isNotNull);
        expect(row!.encryptedDataKey, equals('blob-for-sibling'));
        expect(
          row.addedBySignerPublicKeyHex,
          equals(s.creatorMemberSigPub),
        );
        expect(row.addedByAttestation, equals(attestation));
      } finally {
        await verifySession.close();
      }
    });

    test('rejects a grantee AccountDevice belonging to a different account',
        () async {
      final s = await bootstrapCallerWithMembership(sessionBuilder);

      // The grantee device belongs to a different account entirely.
      final (_, otherAccUltPub) = SigningTestHelper.generateKeypair();
      final otherAccount = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: otherAccUltPub,
        ultimateEncryptionPublicKeyHex: otherAccUltPub,
      );
      final otherDevice = await createSiblingDevice(
        sessionBuilder,
        anonAccountId: otherAccount.id!,
      );

      final outer = await outerEnvelope(
        sessionBuilder,
        endpoints,
        GroupMethods.grantMemberDevice,
        s.ownerDevicePub,
        s.ownerDevicePriv,
      );

      final grantee = PublicKeyDuo(
        signingPublicKeyHex: otherDevice.device.deviceSigningPublicKeyHex,
        encryptionPublicKeyHex:
            otherDevice.device.deviceEncryptionPublicKeyHex,
      );
      final innerPayload = GroupInnerPayloads.grantMemberDevice(
        s.member.id!,
        grantee,
        'leaked-blob',
      );
      final attestation =
          SigningTestHelper.signWith(innerPayload, s.creatorMemberSigPriv);

      await expectLater(
        endpoints.group.grantMemberDevice(
          sessionBuilder,
          challenge: outer.challenge,
          proofOfWork: outer.pow,
          signature: outer.signature,
          callerDeviceSigningPublicKeyHex: s.ownerDevicePub,
          grants: [
            MemberDeviceGrant(
              groupMemberId: s.member.id!,
              accountDeviceId: otherDevice.device.id!,
              encryptedDataKey: 'leaked-blob',
              attestorSigningPublicKeyHex: s.creatorMemberSigPub,
              tier: GrantTier.root,
              attestation: attestation,
            ),
          ],
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('root tier rejects an attestor that is not the membership member key',
        () async {
      final s = await bootstrapCallerWithMembership(sessionBuilder);
      final sibling = await createSiblingDevice(
        sessionBuilder,
        anonAccountId: s.ownerDevice.anonAccountId,
      );

      final outer = await outerEnvelope(
        sessionBuilder,
        endpoints,
        GroupMethods.grantMemberDevice,
        s.ownerDevicePub,
        s.ownerDevicePriv,
      );

      // Attestor is a fresh, unrelated key — sign the inner payload with it.
      final (foreignPriv, foreignPub) = SigningTestHelper.generateKeypair();
      final grantee = PublicKeyDuo(
        signingPublicKeyHex: sibling.device.deviceSigningPublicKeyHex,
        encryptionPublicKeyHex: sibling.device.deviceEncryptionPublicKeyHex,
      );
      final innerPayload = GroupInnerPayloads.grantMemberDevice(
        s.member.id!,
        grantee,
        'blob',
      );
      final attestation = SigningTestHelper.signWith(innerPayload, foreignPriv);

      await expectLater(
        endpoints.group.grantMemberDevice(
          sessionBuilder,
          challenge: outer.challenge,
          proofOfWork: outer.pow,
          signature: outer.signature,
          callerDeviceSigningPublicKeyHex: s.ownerDevicePub,
          grants: [
            MemberDeviceGrant(
              groupMemberId: s.member.id!,
              accountDeviceId: sibling.device.id!,
              encryptedDataKey: 'blob',
              attestorSigningPublicKeyHex: foreignPub,
              tier: GrantTier.root,
              attestation: attestation,
            ),
          ],
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('peer tier rejects an attestor with no active grant', () async {
      final s = await bootstrapCallerWithMembership(sessionBuilder);
      final sibling = await createSiblingDevice(
        sessionBuilder,
        anonAccountId: s.ownerDevice.anonAccountId,
      );

      // The attestor is a sibling device of the same account, but it has NO
      // active GroupMemberDevice grant for this membership. Peer tier must
      // reject.
      final outer = await outerEnvelope(
        sessionBuilder,
        endpoints,
        GroupMethods.grantMemberDevice,
        s.ownerDevicePub,
        s.ownerDevicePriv,
      );

      final grantee = PublicKeyDuo(
        signingPublicKeyHex: sibling.device.deviceSigningPublicKeyHex,
        encryptionPublicKeyHex: sibling.device.deviceEncryptionPublicKeyHex,
      );
      final innerPayload = GroupInnerPayloads.grantMemberDevice(
        s.member.id!,
        grantee,
        'blob',
      );
      final attestation =
          SigningTestHelper.signWith(innerPayload, sibling.priv);

      await expectLater(
        endpoints.group.grantMemberDevice(
          sessionBuilder,
          challenge: outer.challenge,
          proofOfWork: outer.pow,
          signature: outer.signature,
          callerDeviceSigningPublicKeyHex: s.ownerDevicePub,
          grants: [
            MemberDeviceGrant(
              groupMemberId: s.member.id!,
              accountDeviceId: sibling.device.id!,
              encryptedDataKey: 'blob',
              attestorSigningPublicKeyHex: sibling.device.deviceSigningPublicKeyHex,
              tier: GrantTier.peer,
              attestation: attestation,
            ),
          ],
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('an attestation over a different encryptedDataKey is rejected',
        () async {
      final s = await bootstrapCallerWithMembership(sessionBuilder);
      final sibling = await createSiblingDevice(
        sessionBuilder,
        anonAccountId: s.ownerDevice.anonAccountId,
      );

      final outer = await outerEnvelope(
        sessionBuilder,
        endpoints,
        GroupMethods.grantMemberDevice,
        s.ownerDevicePub,
        s.ownerDevicePriv,
      );

      final grantee = PublicKeyDuo(
        signingPublicKeyHex: sibling.device.deviceSigningPublicKeyHex,
        encryptionPublicKeyHex: sibling.device.deviceEncryptionPublicKeyHex,
      );
      // Sign over a DIFFERENT ciphertext than the one we send.
      final innerPayload = GroupInnerPayloads.grantMemberDevice(
        s.member.id!,
        grantee,
        'TAMPERED-CIPHERTEXT',
      );
      final attestation =
          SigningTestHelper.signWith(innerPayload, s.creatorMemberSigPriv);

      await expectLater(
        endpoints.group.grantMemberDevice(
          sessionBuilder,
          challenge: outer.challenge,
          proofOfWork: outer.pow,
          signature: outer.signature,
          callerDeviceSigningPublicKeyHex: s.ownerDevicePub,
          grants: [
            MemberDeviceGrant(
              groupMemberId: s.member.id!,
              accountDeviceId: sibling.device.id!,
              encryptedDataKey: 'real-blob',
              attestorSigningPublicKeyHex: s.creatorMemberSigPub,
              tier: GrantTier.root,
              attestation: attestation,
            ),
          ],
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('two items naming the same (member, device) pair are rejected',
        () async {
      final s = await bootstrapCallerWithMembership(sessionBuilder);
      final sibling = await createSiblingDevice(
        sessionBuilder,
        anonAccountId: s.ownerDevice.anonAccountId,
      );

      final outer = await outerEnvelope(
        sessionBuilder,
        endpoints,
        GroupMethods.grantMemberDevice,
        s.ownerDevicePub,
        s.ownerDevicePriv,
      );

      final grantee = PublicKeyDuo(
        signingPublicKeyHex: sibling.device.deviceSigningPublicKeyHex,
        encryptionPublicKeyHex: sibling.device.deviceEncryptionPublicKeyHex,
      );
      final innerPayload = GroupInnerPayloads.grantMemberDevice(
        s.member.id!,
        grantee,
        'blob',
      );
      final attestation =
          SigningTestHelper.signWith(innerPayload, s.creatorMemberSigPriv);

      await expectLater(
        endpoints.group.grantMemberDevice(
          sessionBuilder,
          challenge: outer.challenge,
          proofOfWork: outer.pow,
          signature: outer.signature,
          callerDeviceSigningPublicKeyHex: s.ownerDevicePub,
          grants: [
            MemberDeviceGrant(
              groupMemberId: s.member.id!,
              accountDeviceId: sibling.device.id!,
              encryptedDataKey: 'blob1',
              attestorSigningPublicKeyHex: s.creatorMemberSigPub,
              tier: GrantTier.root,
              attestation: attestation,
            ),
            MemberDeviceGrant(
              groupMemberId: s.member.id!,
              accountDeviceId: sibling.device.id!,
              encryptedDataKey: 'blob2',
              attestorSigningPublicKeyHex: s.creatorMemberSigPub,
              tier: GrantTier.root,
              attestation: attestation,
            ),
          ],
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('an already-granted item returns in alreadyGranted, others still land',
        () async {
      final s = await bootstrapCallerWithMembership(sessionBuilder);
      final siblingA = await createSiblingDevice(
        sessionBuilder,
        anonAccountId: s.ownerDevice.anonAccountId,
      );
      final siblingB = await createSiblingDevice(
        sessionBuilder,
        anonAccountId: s.ownerDevice.anonAccountId,
      );

      // First call: grant siblingA. Fresh outer envelope required because
      // challenges are single-use.
      {
        final outer = await outerEnvelope(
          sessionBuilder,
          endpoints,
          GroupMethods.grantMemberDevice,
          s.ownerDevicePub,
          s.ownerDevicePriv,
        );
        final grantee = PublicKeyDuo(
          signingPublicKeyHex: siblingA.device.deviceSigningPublicKeyHex,
          encryptionPublicKeyHex:
              siblingA.device.deviceEncryptionPublicKeyHex,
        );
        final innerPayload = GroupInnerPayloads.grantMemberDevice(
          s.member.id!,
          grantee,
          'blob-a',
        );
        final attestation =
            SigningTestHelper.signWith(innerPayload, s.creatorMemberSigPriv);

        await endpoints.group.grantMemberDevice(
          sessionBuilder,
          challenge: outer.challenge,
          proofOfWork: outer.pow,
          signature: outer.signature,
          callerDeviceSigningPublicKeyHex: s.ownerDevicePub,
          grants: [
            MemberDeviceGrant(
              groupMemberId: s.member.id!,
              accountDeviceId: siblingA.device.id!,
              encryptedDataKey: 'blob-a',
              attestorSigningPublicKeyHex: s.creatorMemberSigPub,
              tier: GrantTier.root,
              attestation: attestation,
            ),
          ],
        );
      }

      // Second call: re-request siblingA + siblingB. siblingA must land in
      // alreadyGranted, siblingB must land in granted.
      final outer2 = await outerEnvelope(
        sessionBuilder,
        endpoints,
        GroupMethods.grantMemberDevice,
        s.ownerDevicePub,
        s.ownerDevicePriv,
      );

      final granteeA = PublicKeyDuo(
        signingPublicKeyHex: siblingA.device.deviceSigningPublicKeyHex,
        encryptionPublicKeyHex: siblingA.device.deviceEncryptionPublicKeyHex,
      );
      final innerA = GroupInnerPayloads.grantMemberDevice(
        s.member.id!,
        granteeA,
        'blob-a-again',
      );
      final attestationA =
          SigningTestHelper.signWith(innerA, s.creatorMemberSigPriv);

      final granteeB = PublicKeyDuo(
        signingPublicKeyHex: siblingB.device.deviceSigningPublicKeyHex,
        encryptionPublicKeyHex: siblingB.device.deviceEncryptionPublicKeyHex,
      );
      final innerB = GroupInnerPayloads.grantMemberDevice(
        s.member.id!,
        granteeB,
        'blob-b',
      );
      final attestationB =
          SigningTestHelper.signWith(innerB, s.creatorMemberSigPriv);

      final result = await endpoints.group.grantMemberDevice(
        sessionBuilder,
        challenge: outer2.challenge,
        proofOfWork: outer2.pow,
        signature: outer2.signature,
        callerDeviceSigningPublicKeyHex: s.ownerDevicePub,
        grants: [
          MemberDeviceGrant(
            groupMemberId: s.member.id!,
            accountDeviceId: siblingA.device.id!,
            encryptedDataKey: 'blob-a-again',
            attestorSigningPublicKeyHex: s.creatorMemberSigPub,
            tier: GrantTier.root,
            attestation: attestationA,
          ),
          MemberDeviceGrant(
            groupMemberId: s.member.id!,
            accountDeviceId: siblingB.device.id!,
            encryptedDataKey: 'blob-b',
            attestorSigningPublicKeyHex: s.creatorMemberSigPub,
            tier: GrantTier.root,
            attestation: attestationB,
          ),
        ],
      );

      expect(result.granted, hasLength(1));
      expect(result.granted.single.accountDeviceId, equals(siblingB.device.id!));
      expect(result.alreadyGranted, hasLength(1));
      expect(
        result.alreadyGranted.single.accountDeviceId,
        equals(siblingA.device.id!),
      );

      // Confirm siblingB's row actually landed in the DB.
      final verifySession =
          (sessionBuilder as InternalTestSessionBuilder).internalBuild(
        endpoint: 'test',
        method: 'verify',
      );
      try {
        final row = await GroupMemberDevice.db.findFirstRow(
          verifySession,
          where: (t) =>
              t.groupMemberId.equals(s.member.id!) &
              t.accountDeviceId.equals(siblingB.device.id!) &
              t.isRevoked.equals(false),
        );
        expect(row, isNotNull);
        expect(row!.encryptedDataKey, equals('blob-b'));
      } finally {
        await verifySession.close();
      }
    });

    test('outcomes disambiguate on the pair: same device, two memberships',
        () async {
      // The same account has memberships in two different groups. We need
      // the same sibling device to be granted on both. The pair keying
      // (groupMemberId, accountDeviceId) means both can be granted and
      // both should land in `granted` without confusion.
      final s1 = await bootstrapCallerWithMembership(sessionBuilder);
      final sibling = await createSiblingDevice(
        sessionBuilder,
        anonAccountId: s1.ownerDevice.anonAccountId,
      );

      // Build a second membership for the same account, in a different group.
      final group2 = await ShareGroup.db.insertRow(
        (sessionBuilder as InternalTestSessionBuilder).internalBuild(
          endpoint: 'test',
          method: 'group2',
        ),
        ShareGroup(
          ultimateSigningPublicKeyHex: '04${'b' * 128}',
          ultimateEncryptionPublicKeyHex: '04${'c' * 128}',
          encryptedDataKey: 'wrapped2',
        ),
      );
      final lookupSession =
          (sessionBuilder as InternalTestSessionBuilder).internalBuild(
        endpoint: 'test',
        method: 'lookupGroup2',
      );
      late final GroupMember member2;
      try {
        member2 = await GroupMember.db.insertRow(
          lookupSession,
          GroupMember(
            shareGroupId: group2.id!,
            anonAccountId: s1.ownerDevice.anonAccountId,
            role: GroupMemberRole.admin,
            memberSigningPublicKeyHex: '04${'d' * 128}',
            memberEncryptionPublicKeyHex: '04${'e' * 128}',
            encryptedDataKey: 'wrapped2',
            addedBySignerPublicKeyHex: '04${'b' * 128}',
            addedByAttestation: 'sig-b',
          ),
        );
      } finally {
        await lookupSession.close();
      }

      // For the second membership we need a member signing key we actually
      // hold. Recreate the second membership with a fresh keypair.
      final (member2Priv, member2Pub) = SigningTestHelper.generateKeypair();
      final (_, member2Enc) = SigningTestHelper.generateKeypair();
      // Drive the insert through a fresh session so we get a real id.
      final lookupSession2 =
          (sessionBuilder as InternalTestSessionBuilder).internalBuild(
        endpoint: 'test',
        method: 'lookupGroup2-v2',
      );
      late final GroupMember member2WithKey;
      try {
        // Remove the placeholder we just inserted (no signed key).
        await GroupMember.db.deleteRow(lookupSession2, member2);
        member2WithKey = await GroupMember.db.insertRow(
          lookupSession2,
          GroupMember(
            shareGroupId: group2.id!,
            anonAccountId: s1.ownerDevice.anonAccountId,
            role: GroupMemberRole.admin,
            memberSigningPublicKeyHex: member2Pub,
            memberEncryptionPublicKeyHex: member2Enc,
            encryptedDataKey: 'wrapped2',
            addedBySignerPublicKeyHex: '04${'b' * 128}',
            addedByAttestation: 'sig-b',
          ),
        );
      } finally {
        await lookupSession2.close();
      }

      final outer = await outerEnvelope(
        sessionBuilder,
        endpoints,
        GroupMethods.grantMemberDevice,
        s1.ownerDevicePub,
        s1.ownerDevicePriv,
      );

      final grantee = PublicKeyDuo(
        signingPublicKeyHex: sibling.device.deviceSigningPublicKeyHex,
        encryptionPublicKeyHex: sibling.device.deviceEncryptionPublicKeyHex,
      );

      // Build attestations against the member key for each membership.
      final innerA = GroupInnerPayloads.grantMemberDevice(
        s1.member.id!,
        grantee,
        'blob-for-group-1',
      );
      final attestationA =
          SigningTestHelper.signWith(innerA, s1.creatorMemberSigPriv);

      final innerB = GroupInnerPayloads.grantMemberDevice(
        member2WithKey.id!,
        grantee,
        'blob-for-group-2',
      );
      final attestationB =
          SigningTestHelper.signWith(innerB, member2Priv);

      final result = await endpoints.group.grantMemberDevice(
        sessionBuilder,
        challenge: outer.challenge,
        proofOfWork: outer.pow,
        signature: outer.signature,
        callerDeviceSigningPublicKeyHex: s1.ownerDevicePub,
        grants: [
          MemberDeviceGrant(
            groupMemberId: s1.member.id!,
            accountDeviceId: sibling.device.id!,
            encryptedDataKey: 'blob-for-group-1',
            attestorSigningPublicKeyHex: s1.creatorMemberSigPub,
            tier: GrantTier.root,
            attestation: attestationA,
          ),
          MemberDeviceGrant(
            groupMemberId: member2WithKey.id!,
            accountDeviceId: sibling.device.id!,
            encryptedDataKey: 'blob-for-group-2',
            attestorSigningPublicKeyHex: member2Pub,
            tier: GrantTier.root,
            attestation: attestationB,
          ),
        ],
      );

      expect(result.granted, hasLength(2));
      expect(result.alreadyGranted, isEmpty);
      // Both outcomes present, keyed by their (groupMemberId, accountDeviceId).
      final pairs = result.granted
          .map((o) => '${o.groupMemberId}:${o.accountDeviceId}')
          .toSet();
      expect(pairs, contains('${s1.member.id!}:${sibling.device.id!}'));
      expect(
        pairs,
        contains('${member2WithKey.id!}:${sibling.device.id!}'),
      );
    });
  });
}
