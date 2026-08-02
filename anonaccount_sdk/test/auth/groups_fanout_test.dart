import 'dart:convert';
import 'dart:typed_data';

import 'package:anonaccount_client/anonaccount_client.dart' as wire;
import 'package:anonaccount_protocol/anonaccount_protocol.dart'
    show GroupInnerPayloads;
// EncryptionPublicKeyHex is part of dart_jwk_duo's public surface, used here
// to import the sibling device's encryption pubkey so we can wrap to it.
// ignore: implementation_imports
import 'package:dart_jwk_duo/dart_jwk_duo.dart' show EncryptionPublicKeyHex;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeCaller extends Mock implements wire.Caller {}

class _FakeEntrypoint extends Mock implements wire.EndpointEntrypoint {}

class _FakeGroup extends Mock implements wire.EndpointGroup {}

class _FakeDeviceManagement extends Mock
    implements wire.EndpointDeviceManagement {}

class _FakeUuid extends Fake implements wire.UuidValue {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeUuid());
    registerFallbackValue(wire.GrantAttestor.memberKey);
    registerFallbackValue(
      wire.PublicKeyDuo(
        signingPublicKeyHex: '04${'0' * 128}',
        encryptionPublicKeyHex: '04${'1' * 128}',
      ),
    );
  });

  // The "join fan-out" tests need a fully generated set of sibling KeyDuos.
  // We use Sec1 hex strings as identifiers (matches every other public key in
  // the system) and real ECDH keys for the cryptographic round-trip — the
  // server stores identity from SEC1 hex only, but the SDK must be able to
  // actually wrap/unwrap using the local key objects.
  Future<wire.AccountDevice> _makeDevice({
    required String id,
    required String signingHex,
    required String encryptionHex,
    required AesGcmSecretKey dataKey,
    bool isRevoked = false,
    wire.UuidValue? anonAccountId,
  }) async {
    final pub = await EncryptionKeyPair.importPublicKeySec1Hex(
      EncryptionPublicKeyHex(encryptionHex),
    );
    final blob = await AsymmetricCrypto.wrapForRecipient(
      jsonEncode(await dataKey.exportJsonWebKey()),
      pub.publicKey,
    );
    return wire.AccountDevice(
      id: wire.UuidValue.fromString(id),
      anonAccountId: anonAccountId ??
          wire.UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
      deviceSigningPublicKeyHex: signingHex,
      deviceEncryptionPublicKeyHex: encryptionHex,
      encryptedDataKey: blob,
      label: 'device-$id',
      addedByAttestorPublicKeyHex: '04${'0' * 128}',
      addedByAttestation: 'test-attestation',
      isRevoked: isRevoked,
    );
  }

  test(
    'grantAllDevices grants every non-revoked sibling device AND the caller '
    'itself, with scalar FKs and a real attestation',
    () async {
      final caller = _FakeCaller();
      final entrypoint = _FakeEntrypoint();
      final group = _FakeGroup();
      final dm = _FakeDeviceManagement();
      when(() => caller.entrypoint).thenReturn(entrypoint);
      when(() => caller.group).thenReturn(group);
      when(() => caller.deviceManagement).thenReturn(dm);
      when(() => entrypoint.getChallenge()).thenAnswer(
        (_) async => wire.PublicChallengeResponse(
          challenge: 'CHAL-FANOUT',
          difficulty: 4,
          expiresAt: 9999999999,
        ),
      );

      // Three devices on the account: the caller (self), a non-revoked
      // sibling, and a revoked sibling. listDevices does NOT filter revoked
      // (device_management_endpoint.dart:114-119), so the SDK must.
      final callerKey = await KeyGen.generateDeviceKey();
      final siblingKey = await KeyGen.generateDeviceKey();
      final revokedKey = await KeyGen.generateDeviceKey();

      final callerHex =
          (await callerKey.signingKeyPair.exportPublicKeySec1Hex()).value;
      final siblingHex =
          (await siblingKey.signingKeyPair.exportPublicKeySec1Hex()).value;
      final revokedHex =
          (await revokedKey.signingKeyPair.exportPublicKeySec1Hex()).value;
      final callerEnc =
          (await EncryptionKeyPair.publicOnly(
                  publicKey: callerKey.encryptionKeyPair.publicKey)
              .exportPublicKeySec1Hex()).value;
      final siblingEnc =
          (await EncryptionKeyPair.publicOnly(
                  publicKey: siblingKey.encryptionKeyPair.publicKey)
              .exportPublicKeySec1Hex()).value;
      final revokedEnc =
          (await EncryptionKeyPair.publicOnly(
                  publicKey: revokedKey.encryptionKeyPair.publicKey)
              .exportPublicKeySec1Hex()).value;

      final callerId = wire.UuidValue.fromString('11111111-1111-4111-8111-111111111111');
      final siblingId = wire.UuidValue.fromString('22222222-2222-4222-8222-222222222222');
      final revokedId = wire.UuidValue.fromString('33333333-3333-4333-8333-333333333333');

      final dataKey = await AesGcmSecretKey.generateKey(256);
      final callerDevice = await _makeDevice(
        id: '11111111-1111-4111-8111-111111111111',
        signingHex: callerHex,
        encryptionHex: callerEnc,
        dataKey: dataKey,
      );
      final siblingDevice = await _makeDevice(
        id: '22222222-2222-4222-8222-222222222222',
        signingHex: siblingHex,
        encryptionHex: siblingEnc,
        dataKey: dataKey,
      );
      final revokedDevice = await _makeDevice(
        id: '33333333-3333-4333-8333-333333333333',
        signingHex: revokedHex,
        encryptionHex: revokedEnc,
        dataKey: dataKey,
        isRevoked: true,
      );

      when(() => dm.listDevices(
            challenge: any(named: 'challenge'),
            proofOfWork: any(named: 'proofOfWork'),
            publicKeyHex: any(named: 'publicKeyHex'),
            signature: any(named: 'signature'),
          )).thenAnswer((_) async => [callerDevice, siblingDevice, revokedDevice]);

      final memberId = wire.UuidValue.fromString('99999999-9999-4999-8999-999999999999');
      final memberKey = await KeyGen.generateDeviceKey();
      final memberSigningPublicKeyHex =
          (await memberKey.signingKeyPair.exportPublicKeySec1Hex()).value;

      final stubResult = wire.GrantMemberDeviceResult(
        granted: [
          wire.MemberDeviceGrantOutcome(
            groupMemberId: memberId,
            accountDeviceId: callerId,
          ),
          wire.MemberDeviceGrantOutcome(
            groupMemberId: memberId,
            accountDeviceId: siblingId,
          ),
        ],
        alreadyGranted: const [],
      );
      when(() => group.grantMemberDevice(
            challenge: any(named: 'challenge'),
            proofOfWork: any(named: 'proofOfWork'),
            signature: any(named: 'signature'),
            callerDeviceSigningPublicKeyHex:
                any(named: 'callerDeviceSigningPublicKeyHex'),
            grants: any(named: 'grants'),
          )).thenAnswer((_) async => stubResult);

      final groups = AnonaccountGroups(caller, difficulty: 4);
      final result = await groups.grantAllDevices(
        memberId: memberId,
        groupDataKey: dataKey,
        memberKey: memberKey,
        callerDeviceKey: callerKey,
      );

      // Server result is forwarded.
      expect(result.granted, hasLength(2));
      expect(result.granted.map((o) => o.accountDeviceId),
          containsAll([callerId, siblingId]));
      expect(result.alreadyGranted, isEmpty);

      // Capture the grants the SDK actually sent.
      final captured = verify(() => group.grantMemberDevice(
            challenge: captureAny(named: 'challenge'),
            proofOfWork: captureAny(named: 'proofOfWork'),
            signature: captureAny(named: 'signature'),
            callerDeviceSigningPublicKeyHex:
                captureAny(named: 'callerDeviceSigningPublicKeyHex'),
            grants: captureAny(named: 'grants'),
          )).captured;

      final sentGrants = captured.last as List<wire.MemberDeviceGrant>;
      final sentIds = sentGrants.map((g) => g.accountDeviceId).toList();

      // Both self and the non-revoked sibling are sent; the revoked one is
      // filtered out.
      expect(sentIds, contains(callerId));
      expect(sentIds, contains(siblingId));
      expect(sentIds, isNot(contains(revokedId)));
      expect(sentGrants, hasLength(2));

      // Shape: every MemberDeviceGrant carries scalar FKs only. The class
      // itself has only scalar UuidValue fields (no relation objects), so
      // this is a compile-time property — the test makes it explicit:
      for (final g in sentGrants) {
        expect(g.groupMemberId, memberId);
        expect(g.accountDeviceId, isA<wire.UuidValue>());
        expect(g.encryptedDataKey, isNotEmpty);
        expect(g.attestorSigningPublicKeyHex, memberSigningPublicKeyHex);
        expect(g.attestor, wire.GrantAttestor.memberKey);
        expect(g.attestation, isNotEmpty);
      }

      // The attestation is real — verifies under the member signing key
      // over the canonical payload covering (memberId, device duo, blob).
      for (final g in sentGrants) {
        final isCallerGrant = g.accountDeviceId == callerId;
        final device = isCallerGrant ? callerDevice : siblingDevice;
        final deviceDuo = wire.PublicKeyDuo(
          signingPublicKeyHex: device.deviceSigningPublicKeyHex,
          encryptionPublicKeyHex: device.deviceEncryptionPublicKeyHex,
        );
        final ok = await SigningCrypto.verifyChallenge(
          GroupInnerPayloads.grantMemberDevice(
            g.groupMemberId,
            deviceDuo,
            g.encryptedDataKey,
          ),
          g.attestation,
          memberKey,
        );
        expect(ok, isTrue,
            reason: 'attestation must verify under the member signing key '
                'over GroupInnerPayloads.grantMemberDevice');
      }
    },
  );

  test(
    'a granted sibling really can read the group: wraps to sibling encryption '
    'key, call sends it, sibling private key unwraps it back to the original '
    'data key JWK',
    () async {
      final caller = _FakeCaller();
      final entrypoint = _FakeEntrypoint();
      final group = _FakeGroup();
      final dm = _FakeDeviceManagement();
      when(() => caller.entrypoint).thenReturn(entrypoint);
      when(() => caller.group).thenReturn(group);
      when(() => caller.deviceManagement).thenReturn(dm);
      when(() => entrypoint.getChallenge()).thenAnswer(
        (_) async => wire.PublicChallengeResponse(
          challenge: 'CHAL-ROUND',
          difficulty: 4,
          expiresAt: 9999999999,
        ),
      );

      // D2 is the sibling, in this test. The member key holder grants D2
      // access to the group data key.
      final d2Key = await KeyGen.generateDeviceKey();
      final d2Hex = (await d2Key.signingKeyPair.exportPublicKeySec1Hex()).value;
      final d2Enc =
          (await EncryptionKeyPair.publicOnly(
                  publicKey: d2Key.encryptionKeyPair.publicKey)
              .exportPublicKeySec1Hex()).value;

      final d2Id = wire.UuidValue.fromString('22222222-2222-4222-8222-222222222222');

      // The SDK treats the caller as itself, so include a self device that
      // matches the caller's signing hex.
      final callerKey = await KeyGen.generateDeviceKey();
      final callerHex =
          (await callerKey.signingKeyPair.exportPublicKeySec1Hex()).value;
      final callerEnc =
          (await EncryptionKeyPair.publicOnly(
                  publicKey: callerKey.encryptionKeyPair.publicKey)
              .exportPublicKeySec1Hex()).value;
      final callerId = wire.UuidValue.fromString('11111111-1111-4111-8111-111111111111');

      final dataKey = await AesGcmSecretKey.generateKey(256);
      final dataKeyJwk = jsonEncode(await dataKey.exportJsonWebKey());

      final callerDevice = await _makeDevice(
        id: '11111111-1111-4111-8111-111111111111',
        signingHex: callerHex,
        encryptionHex: callerEnc,
        dataKey: dataKey,
      );
      final d2Device = await _makeDevice(
        id: '22222222-2222-4222-8222-222222222222',
        signingHex: d2Hex,
        encryptionHex: d2Enc,
        dataKey: dataKey,
      );

      when(() => dm.listDevices(
            challenge: any(named: 'challenge'),
            proofOfWork: any(named: 'proofOfWork'),
            publicKeyHex: any(named: 'publicKeyHex'),
            signature: any(named: 'signature'),
          )).thenAnswer((_) async => [callerDevice, d2Device]);

      final memberId = wire.UuidValue.fromString('77777777-7777-4777-8777-777777777777');
      final memberKey = await KeyGen.generateDeviceKey();
      final memberSigningPublicKeyHex =
          (await memberKey.signingKeyPair.exportPublicKeySec1Hex()).value;

      final stubResult = wire.GrantMemberDeviceResult(
        granted: [
          wire.MemberDeviceGrantOutcome(
            groupMemberId: memberId,
            accountDeviceId: callerId,
          ),
          wire.MemberDeviceGrantOutcome(
            groupMemberId: memberId,
            accountDeviceId: d2Id,
          ),
        ],
        alreadyGranted: const [],
      );
      when(() => group.grantMemberDevice(
            challenge: any(named: 'challenge'),
            proofOfWork: any(named: 'proofOfWork'),
            signature: any(named: 'signature'),
            callerDeviceSigningPublicKeyHex:
                any(named: 'callerDeviceSigningPublicKeyHex'),
            grants: any(named: 'grants'),
          )).thenAnswer((_) async => stubResult);

      final groups = AnonaccountGroups(caller, difficulty: 4);
      await groups.grantAllDevices(
        memberId: memberId,
        groupDataKey: dataKey,
        memberKey: memberKey,
        callerDeviceKey: callerKey,
      );

      final captured = verify(() => group.grantMemberDevice(
            challenge: captureAny(named: 'challenge'),
            proofOfWork: captureAny(named: 'proofOfWork'),
            signature: captureAny(named: 'signature'),
            callerDeviceSigningPublicKeyHex:
                captureAny(named: 'callerDeviceSigningPublicKeyHex'),
            grants: captureAny(named: 'grants'),
          )).captured;
      final sentGrants = captured.last as List<wire.MemberDeviceGrant>;
      final d2Grant = sentGrants.firstWhere(
        (g) => g.accountDeviceId == d2Id,
        orElse: () =>
            throw StateError('no grant for sibling D2 was sent to the server'),
      );

      // The blob sent for D2 must unwrap with D2's private key back to the
      // original data key JWK. This is the property that turns a fresh
      // sibling into a group reader.
      final privateKey = d2Key.encryptionKeyPair.privateKey;
      if (privateKey == null) {
        fail('sibling D2 key has no private encryption half');
      }
      final unwrapped = await AsymmetricCrypto.unwrap(
        d2Grant.encryptedDataKey,
        privateKey,
      );
      expect(unwrapped, dataKeyJwk);

      // And the attestation on that grant is real:
      final ok = await SigningCrypto.verifyChallenge(
        GroupInnerPayloads.grantMemberDevice(
          memberId,
          wire.PublicKeyDuo(
            signingPublicKeyHex: d2Device.deviceSigningPublicKeyHex,
            encryptionPublicKeyHex: d2Device.deviceEncryptionPublicKeyHex,
          ),
          d2Grant.encryptedDataKey,
        ),
        d2Grant.attestation,
        memberKey,
      );
      expect(ok, isTrue);
      expect(d2Grant.attestorSigningPublicKeyHex, memberSigningPublicKeyHex);
      expect(d2Grant.attestor, wire.GrantAttestor.memberKey);
    },
  );

  test(
    'grantNewDevice issues one batched grant per membership, attested by the '
    'member key where the caller holds it and by a granted device where it '
    'grant',
    () async {
      final caller = _FakeCaller();
      final entrypoint = _FakeEntrypoint();
      final group = _FakeGroup();
      when(() => caller.entrypoint).thenReturn(entrypoint);
      when(() => caller.group).thenReturn(group);
      when(() => entrypoint.getChallenge()).thenAnswer(
        (_) async => wire.PublicChallengeResponse(
          challenge: 'CHAL-NEW',
          difficulty: 4,
          expiresAt: 9999999999,
        ),
      );

      // The new device is paired into the account. The caller has two
      // memberships to grant it: one where the caller holds the member key
      // (member key) and one where the caller holds only a grant.
      final callerKey = await KeyGen.generateDeviceKey();
      final callerHex =
          (await callerKey.signingKeyPair.exportPublicKeySec1Hex()).value;
      final callerEnc =
          (await EncryptionKeyPair.publicOnly(
                  publicKey: callerKey.encryptionKeyPair.publicKey)
              .exportPublicKeySec1Hex()).value;

      // The new device — generate and read its two public halves back out
      // as SEC1 hex, since the wire type is the hex and a fresh KeyDuo is
      // its source.
      final newDeviceKeyDuo = await KeyGen.generateDeviceKey();
      final newDeviceSigningHex =
          (await newDeviceKeyDuo.signingKeyPair.exportPublicKeySec1Hex()).value;
      final newDeviceEncHex =
          (await EncryptionKeyPair.publicOnly(
                  publicKey: newDeviceKeyDuo.encryptionKeyPair.publicKey)
              .exportPublicKeySec1Hex()).value;

      // The new device needs an id; AccountDevice on the wire carries one.
      // We construct a minimal row that lists `id` so the SDK can reference it.
      final newDevice = wire.AccountDevice(
        id: wire.UuidValue.fromString('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'),
        anonAccountId:
            wire.UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
        deviceSigningPublicKeyHex: newDeviceSigningHex,
        deviceEncryptionPublicKeyHex: newDeviceEncHex,
        encryptedDataKey: 'wrapped-by-approver',
        label: 'new-device',
        addedByAttestorPublicKeyHex: callerHex,
        addedByAttestation: 'att',
        isRevoked: false,
      );

      // Root membership — caller holds the member key.
      final rootMemberId =
          wire.UuidValue.fromString('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb');
      final rootMemberKey = await KeyGen.generateDeviceKey();
      final rootMemberSigningPublicKeyHex =
          (await rootMemberKey.signingKeyPair.exportPublicKeySec1Hex()).value;
      final rootDataKey = await AesGcmSecretKey.generateKey(256);
      final rootDataKeyJwk = jsonEncode(await rootDataKey.exportJsonWebKey());

      // Peer membership — caller holds only a grant, not the member key.
      final peerMemberId =
          wire.UuidValue.fromString('cccccccc-cccc-4ccc-8ccc-cccccccccccc');
      final peerMemberKey = await KeyGen.generateDeviceKey();
      final peerMemberSigningPublicKeyHex =
          (await peerMemberKey.signingKeyPair.exportPublicKeySec1Hex()).value;
      final peerDataKey = await AesGcmSecretKey.generateKey(256);
      final peerDataKeyJwk = jsonEncode(await peerDataKey.exportJsonWebKey());

      // grantNewDevice re-wraps the caller's own per-device grant blob to
      // the new device — these must be REAL wrapped blobs (to the
      // caller's own encryption key), not placeholder strings, since the
      // implementation actually unwraps them.
      final rootDeviceBlobForCaller = await AsymmetricCrypto.wrapForRecipient(
        rootDataKeyJwk,
        callerKey.encryptionKeyPair.publicKey,
      );
      final peerDeviceBlobForCaller = await AsymmetricCrypto.wrapForRecipient(
        peerDataKeyJwk,
        callerKey.encryptionKeyPair.publicKey,
      );

      final memberships = [
        wire.GroupMembershipView(
          memberId: rootMemberId,
          shareGroupId:
              wire.UuidValue.fromString('11111111-1111-4111-8111-111111111111'),
          role: wire.GroupMemberRole.admin,
          memberSigningPublicKeyHex: rootMemberSigningPublicKeyHex,
          memberEncryptedDataKey: 'root-member-blob',
          deviceEncryptedDataKey: rootDeviceBlobForCaller,
          joinedAt: DateTime.utc(2026, 5, 20),
        ),
        wire.GroupMembershipView(
          memberId: peerMemberId,
          shareGroupId:
              wire.UuidValue.fromString('22222222-2222-4222-8222-222222222222'),
          role: wire.GroupMemberRole.member,
          memberSigningPublicKeyHex: peerMemberSigningPublicKeyHex,
          memberEncryptedDataKey: 'peer-member-blob',
          deviceEncryptedDataKey: peerDeviceBlobForCaller,
          joinedAt: DateTime.utc(2026, 5, 21),
        ),
      ];

      final stubResult = wire.GrantMemberDeviceResult(
        granted: [
          wire.MemberDeviceGrantOutcome(
            groupMemberId: rootMemberId,
            accountDeviceId: newDevice.id!,
          ),
          wire.MemberDeviceGrantOutcome(
            groupMemberId: peerMemberId,
            accountDeviceId: newDevice.id!,
          ),
        ],
        alreadyGranted: const [],
      );
      when(() => group.grantMemberDevice(
            challenge: any(named: 'challenge'),
            proofOfWork: any(named: 'proofOfWork'),
            signature: any(named: 'signature'),
            callerDeviceSigningPublicKeyHex:
                any(named: 'callerDeviceSigningPublicKeyHex'),
            grants: any(named: 'grants'),
          )).thenAnswer((_) async => stubResult);

      final groups = AnonaccountGroups(caller, difficulty: 4);
      final result = await groups.grantNewDevice(
        newDevice: newDevice,
        memberships: memberships,
        memberKeys: {
          rootMemberId: rootMemberKey,
        },
        callerDeviceKey: callerKey,
      );

      expect(result.granted, hasLength(2));

      final captured = verify(() => group.grantMemberDevice(
            challenge: captureAny(named: 'challenge'),
            proofOfWork: captureAny(named: 'proofOfWork'),
            signature: captureAny(named: 'signature'),
            callerDeviceSigningPublicKeyHex:
                captureAny(named: 'callerDeviceSigningPublicKeyHex'),
            grants: captureAny(named: 'grants'),
          )).captured;
      final sentGrants = captured.last as List<wire.MemberDeviceGrant>;
      expect(sentGrants, hasLength(2));

      final rootGrant = sentGrants.firstWhere(
        (g) => g.groupMemberId == rootMemberId,
      );
      final peerGrant = sentGrants.firstWhere(
        (g) => g.groupMemberId == peerMemberId,
      );

      // Attested by the corresponding member key.
      expect(rootGrant.attestor, wire.GrantAttestor.memberKey);
      expect(
        rootGrant.attestorSigningPublicKeyHex,
        rootMemberSigningPublicKeyHex,
      );
      final rootOk = await SigningCrypto.verifyChallenge(
        GroupInnerPayloads.grantMemberDevice(
          rootMemberId,
          wire.PublicKeyDuo(
            signingPublicKeyHex: newDeviceSigningHex,
            encryptionPublicKeyHex: newDeviceEncHex,
          ),
          rootGrant.encryptedDataKey,
        ),
        rootGrant.attestation,
        rootMemberKey,
      );
      expect(rootOk, isTrue);
      // The root grant's blob unwraps to the root group's data key.
      final newDevicePriv = newDeviceKeyDuo.encryptionKeyPair.privateKey;
      if (newDevicePriv == null) {
        fail('new device key has no private encryption half');
      }
      final rootUnwrapped = await AsymmetricCrypto.unwrap(
        rootGrant.encryptedDataKey,
        newDevicePriv,
      );
      expect(rootUnwrapped, rootDataKeyJwk);

      // Attested by the caller's device key — the only key the
      // caller holds for that membership.
      expect(peerGrant.attestor, wire.GrantAttestor.grantedDevice);
      expect(peerGrant.attestorSigningPublicKeyHex, callerHex);
      final peerOk = await SigningCrypto.verifyChallenge(
        GroupInnerPayloads.grantMemberDevice(
          peerMemberId,
          wire.PublicKeyDuo(
            signingPublicKeyHex: newDeviceSigningHex,
            encryptionPublicKeyHex: newDeviceEncHex,
          ),
          peerGrant.encryptedDataKey,
        ),
        peerGrant.attestation,
        callerKey,
      );
      expect(peerOk, isTrue);
      final peerUnwrapped = await AsymmetricCrypto.unwrap(
        peerGrant.encryptedDataKey,
        newDevicePriv,
      );
      expect(peerUnwrapped, peerDataKeyJwk);
    },
  );
}
