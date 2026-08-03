import 'package:anonaccount_client/anonaccount_client.dart' as wire;
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
  });

  test(
    'leaveGroup calls wire with member key attestation and correct memberSigningPublicKeyHex',
    () async {
      final caller = _FakeCaller();
      final entrypoint = _FakeEntrypoint();
      final group = _FakeGroup();
      when(() => caller.entrypoint).thenReturn(entrypoint);
      when(() => caller.group).thenReturn(group);
      when(() => entrypoint.getChallenge()).thenAnswer(
        (_) async => wire.PublicChallengeResponse(
          challenge: 'CHAL-LV',
          difficulty: 4,
          expiresAt: 9999999999,
        ),
      );

      final memberId = wire.UuidValue.fromString(
        'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
      );

      when(
        () => group.leaveGroup(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          callerDeviceSigningPublicKeyHex: any(
            named: 'callerDeviceSigningPublicKeyHex',
          ),
          memberId: any(named: 'memberId'),
          memberSigningPublicKeyHex: any(named: 'memberSigningPublicKeyHex'),
          memberAuthSignature: any(named: 'memberAuthSignature'),
        ),
      ).thenAnswer((_) async => true);

      final groupId = wire.UuidValue.fromString(
        'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      );
      final callerMemberKey = await KeyGen.generateDeviceKey();
      final callerDeviceKey = await KeyGen.generateDeviceKey();
      final store = InMemoryMemberKeyStore();
      await store.storeMemberKey(groupId, callerMemberKey);
      final groups = AnonaccountGroups(
        caller,
        store,
        InMemoryGroupOwnerKeyStore(),
        difficulty: 4,
      );

      final result = await groups.leaveGroup(
        groupId: groupId,
        memberId: memberId,
        callerDeviceKey: callerDeviceKey,
      );

      expect(result, isTrue);

      // Extract the caller member key's public key hex for verification.
      final expectedMemberPubkeyHex = await callerMemberKey.signingKeyPair
          .exportPublicKeySec1Hex();

      final captured = verify(
        () => group.leaveGroup(
          challenge: captureAny(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          callerDeviceSigningPublicKeyHex: any(
            named: 'callerDeviceSigningPublicKeyHex',
          ),
          memberId: captureAny(named: 'memberId'),
          memberSigningPublicKeyHex: captureAny(
            named: 'memberSigningPublicKeyHex',
          ),
          memberAuthSignature: captureAny(named: 'memberAuthSignature'),
        ),
      ).captured;

      // Indices: challenge(0), memberId(1), memberSigningPublicKeyHex(2), memberAuthSignature(3)
      expect(captured[0], 'CHAL-LV');
      expect(captured[1].toString(), memberId.toString());
      expect(
        captured[2],
        expectedMemberPubkeyHex,
      ); // caller's own member pubkey hex
      expect(captured[3], isNotNull); // memberAuthSignature — must be non-null
    },
  );

  test(
    'leaveGroup removes the member key after the server confirms departure',
    () async {
      final caller = _FakeCaller();
      final entrypoint = _FakeEntrypoint();
      final group = _FakeGroup();
      when(() => caller.entrypoint).thenReturn(entrypoint);
      when(() => caller.group).thenReturn(group);
      when(() => entrypoint.getChallenge()).thenAnswer(
        (_) async => wire.PublicChallengeResponse(
          challenge: 'CHAL-LV2',
          difficulty: 4,
          expiresAt: 9999999999,
        ),
      );
      when(
        () => group.leaveGroup(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          callerDeviceSigningPublicKeyHex: any(
            named: 'callerDeviceSigningPublicKeyHex',
          ),
          memberId: any(named: 'memberId'),
          memberSigningPublicKeyHex: any(named: 'memberSigningPublicKeyHex'),
          memberAuthSignature: any(named: 'memberAuthSignature'),
        ),
      ).thenAnswer((_) async => true);

      final groupId = wire.UuidValue.fromString(
        'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      );
      final store = InMemoryMemberKeyStore();
      await store.storeMemberKey(groupId, await KeyGen.generateDeviceKey());

      await AnonaccountGroups(
        caller,
        store,
        InMemoryGroupOwnerKeyStore(),
        difficulty: 4,
      ).leaveGroup(
        groupId: groupId,
        memberId: wire.UuidValue.fromString(
          'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
        ),
        callerDeviceKey: await KeyGen.generateDeviceKey(),
      );

      expect(await store.getMemberKey(groupId), isNull);
    },
  );

  test(
    'leaveGroup keeps the member key when the server rejects the departure',
    () async {
      // GroupEndpoint.leaveGroup has one `return true` and otherwise throws, so
      // a rejection arrives as an exception, never as `false`. Driving this with
      // a `false` return would pin behaviour the server cannot produce.
      final caller = _FakeCaller();
      final entrypoint = _FakeEntrypoint();
      final group = _FakeGroup();
      when(() => caller.entrypoint).thenReturn(entrypoint);
      when(() => caller.group).thenReturn(group);
      when(() => entrypoint.getChallenge()).thenAnswer(
        (_) async => wire.PublicChallengeResponse(
          challenge: 'CHAL-LV3',
          difficulty: 4,
          expiresAt: 9999999999,
        ),
      );
      when(
        () => group.leaveGroup(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          callerDeviceSigningPublicKeyHex: any(
            named: 'callerDeviceSigningPublicKeyHex',
          ),
          memberId: any(named: 'memberId'),
          memberSigningPublicKeyHex: any(named: 'memberSigningPublicKeyHex'),
          memberAuthSignature: any(named: 'memberAuthSignature'),
        ),
      ).thenThrow(Exception('Cannot leave as the last admin'));

      final groupId = wire.UuidValue.fromString(
        'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      );
      final key = await KeyGen.generateDeviceKey();
      final store = InMemoryMemberKeyStore();
      await store.storeMemberKey(groupId, key);

      await expectLater(
        AnonaccountGroups(
          caller,
          store,
          InMemoryGroupOwnerKeyStore(),
          difficulty: 4,
        ).leaveGroup(
          groupId: groupId,
          memberId: wire.UuidValue.fromString(
            'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
          ),
          callerDeviceKey: await KeyGen.generateDeviceKey(),
        ),
        throwsA(isA<Exception>()),
      );
      expect(await store.getMemberKey(groupId), same(key));
    },
  );

  test(
    'leaveGroup throws StateError when no member key is stored for the group',
    () async {
      final groups = AnonaccountGroups(
        _FakeCaller(),
        InMemoryMemberKeyStore(),
        InMemoryGroupOwnerKeyStore(),
        difficulty: 4,
      );

      await expectLater(
        groups.leaveGroup(
          groupId: wire.UuidValue.fromString(
            'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
          ),
          memberId: wire.UuidValue.fromString(
            'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
          ),
          callerDeviceKey: await KeyGen.generateDeviceKey(),
        ),
        throwsA(isA<StateError>()),
      );
    },
  );
}
