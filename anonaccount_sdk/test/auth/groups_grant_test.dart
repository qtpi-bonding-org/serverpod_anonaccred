import 'package:anonaccount_client/anonaccount_client.dart' as wire;
import 'package:anonaccount_client/src/pow_methods.dart' show GroupInnerPayloads;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeCaller extends Mock implements wire.Caller {}

class _FakeEntrypoint extends Mock implements wire.EndpointEntrypoint {}

class _FakeGroup extends Mock implements wire.EndpointGroup {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      wire.UuidValue.fromString('00000000-0000-4000-8000-000000000000'),
    );
    registerFallbackValue(wire.GrantTier.root);
    registerFallbackValue(
      wire.PublicKeyDuo(
        signingPublicKeyHex: '04${'0' * 128}',
        encryptionPublicKeyHex: '04${'1' * 128}',
      ),
    );
  });

  test(
    'grantMemberDevice forwards grants and signs the inner payload '
    'over (memberId, device duo, encryptedDataKey) with the member key',
    () async {
      final caller = _FakeCaller();
      final entrypoint = _FakeEntrypoint();
      final group = _FakeGroup();
      when(() => caller.entrypoint).thenReturn(entrypoint);
      when(() => caller.group).thenReturn(group);
      when(() => entrypoint.getChallenge()).thenAnswer(
        (_) async => wire.PublicChallengeResponse(
          challenge: 'CHAL-GRANT',
          difficulty: 4,
          expiresAt: 9999999999,
        ),
      );

      final memberId = wire.UuidValue.fromString(
        '22222222-2222-4222-8222-222222222222',
      );
      final granteeDeviceId = wire.UuidValue.fromString(
        '33333333-3333-4333-8333-333333333333',
      );
      final granteeDuo = wire.PublicKeyDuo(
        signingPublicKeyHex: '04${'a' * 128}',
        encryptionPublicKeyHex: '04${'b' * 128}',
      );
      const wrappedBlob = 'WRAPPED-BLOB-FOR-SIBLING';

      final stubResult = wire.GrantMemberDeviceResult(
        granted: [
          wire.MemberDeviceGrantOutcome(
            groupMemberId: memberId,
            accountDeviceId: granteeDeviceId,
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

      final memberKey = await KeyGen.generateDeviceKey();
      final callerDeviceKey = await KeyGen.generateDeviceKey();
      final memberSigningPublicKeyHex =
          (await memberKey.signingKeyPair.exportPublicKeySec1Hex()).value;

      final groups = AnonaccountGroups(caller, difficulty: 4);

      // grantMemberDevice is a low-level forwarder — Task 7's
      // grantAllDevices/grantNewDevice do the per-item signing (they hold
      // the member key). Here we build the real attestation ourselves,
      // exactly as those callers would, and confirm the SDK forwards it
      // unmodified.
      final realAttestation = await SigningCrypto.signChallenge(
        GroupInnerPayloads.grantMemberDevice(
          memberId,
          granteeDuo,
          wrappedBlob,
        ),
        memberKey,
      );

      final result = await groups.grantMemberDevice(
        grants: [
          wire.MemberDeviceGrant(
            groupMemberId: memberId,
            accountDeviceId: granteeDeviceId,
            encryptedDataKey: wrappedBlob,
            attestorSigningPublicKeyHex: memberSigningPublicKeyHex,
            tier: wire.GrantTier.root,
            attestation: realAttestation,
          ),
        ],
        callerDeviceKey: callerDeviceKey,
      );

      // Returned result is forwarded.
      expect(result.granted, hasLength(1));
      expect(result.granted.first.groupMemberId, memberId);
      expect(result.granted.first.accountDeviceId, granteeDeviceId);
      expect(result.alreadyGranted, isEmpty);

      // Capture the single MemberDeviceGrant the SDK actually sent.
      final captured = verify(
        () => group.grantMemberDevice(
          challenge: captureAny(named: 'challenge'),
          proofOfWork: captureAny(named: 'proofOfWork'),
          signature: captureAny(named: 'signature'),
          callerDeviceSigningPublicKeyHex:
              captureAny(named: 'callerDeviceSigningPublicKeyHex'),
          grants: captureAny(named: 'grants'),
        ),
      ).captured;

      // captured[0] = challenge, [1] = proofOfWork, [2] = signature,
      // [3] = callerDeviceSigningPublicKeyHex, [4] = List<MemberDeviceGrant>
      expect(captured[0], 'CHAL-GRANT');
      expect(captured[3], isNotNull);

      final sentGrants = captured[4] as List<wire.MemberDeviceGrant>;
      expect(sentGrants, hasLength(1));
      final sent = sentGrants.single;

      // grantMemberDevice forwards the caller-supplied grant unmodified —
      // it does not (and cannot; it never receives the member key) alter
      // the attestation.
      expect(sent.attestation, equals(realAttestation));
      expect(sent.encryptedDataKey, equals(wrappedBlob));
      expect(sent.groupMemberId, equals(memberId));
      expect(sent.accountDeviceId, equals(granteeDeviceId));

      // The inner attestation verifies under the member signing key,
      // over the canonical payload covering (memberId, device duo, blob).
      final ok = await SigningCrypto.verifyChallenge(
        GroupInnerPayloads.grantMemberDevice(
          sent.groupMemberId,
          granteeDuo,
          sent.encryptedDataKey,
        ),
        sent.attestation,
        memberKey,
      );
      expect(ok, isTrue,
          reason: 'inner attestation must verify under the member signing '
              'key over GroupInnerPayloads.grantMemberDevice');

      // The attestation must NOT verify a different wrapped-key value —
      // confirms the payload the caller signed binds the ciphertext.
      final tamperedOk = await SigningCrypto.verifyChallenge(
        GroupInnerPayloads.grantMemberDevice(
          memberId,
          granteeDuo,
          'TAMPERED-BLOB',
        ),
        sent.attestation,
        memberKey,
      );
      expect(tamperedOk, isFalse,
          reason: 'an attestation must bind the wrapped-key value, '
              'so swapping the blob must invalidate it');
    },
  );
}
