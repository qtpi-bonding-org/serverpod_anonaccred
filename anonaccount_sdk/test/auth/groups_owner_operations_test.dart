import 'package:anonaccount_client/anonaccount_client.dart' as wire;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _Caller extends Mock implements wire.Caller {}

class _Entrypoint extends Mock implements wire.EndpointEntrypoint {}

class _Group extends Mock implements wire.EndpointGroup {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      wire.UuidValue.fromString('00000000-0000-4000-8000-000000000000'),
    );
    registerFallbackValue(wire.GroupMemberRole.member);
    registerFallbackValue(
      wire.PublicKeyDuo(
        signingPublicKeyHex: '04${'0' * 128}',
        encryptionPublicKeyHex: '04${'1' * 128}',
      ),
    );
  });

  test(
    'owner methods send owner signatures without member signatures',
    () async {
      final caller = _Caller();
      final entrypoint = _Entrypoint();
      final group = _Group();
      when(() => caller.entrypoint).thenReturn(entrypoint);
      when(() => caller.group).thenReturn(group);
      when(() => entrypoint.getChallenge()).thenAnswer(
        (_) async => wire.PublicChallengeResponse(
          challenge: 'OWNER-CHALLENGE',
          difficulty: 4,
          expiresAt: 9999999999,
        ),
      );
      final groupId = wire.UuidValue.fromString(
        'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      );
      final memberId = wire.UuidValue.fromString(
        'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
      );
      final ownerStore = InMemoryGroupOwnerKeyStore();
      await ownerStore.storeOwnerKey(
        groupId,
        await KeyGen.generateUltimateKey(),
      );
      when(
        () => group.addGroupMember(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          callerDeviceSigningPublicKeyHex: any(
            named: 'callerDeviceSigningPublicKeyHex',
          ),
          groupId: any(named: 'groupId'),
          newMemberAccountId: any(named: 'newMemberAccountId'),
          role: any(named: 'role'),
          memberKeys: any(named: 'memberKeys'),
          encryptedDataKey: any(named: 'encryptedDataKey'),
          encryptedMemberKey: any(named: 'encryptedMemberKey'),
          encryptedMemberKeyAttestation: any(
            named: 'encryptedMemberKeyAttestation',
          ),
          callerMemberSigningPublicKeyHex: any(
            named: 'callerMemberSigningPublicKeyHex',
          ),
          memberAuthSignature: any(named: 'memberAuthSignature'),
          groupUltimateSignature: any(named: 'groupUltimateSignature'),
        ),
      ).thenAnswer(
        (_) async => wire.GroupMember(
          id: memberId,
          shareGroupId: groupId,
          anonAccountId: memberId,
          role: wire.GroupMemberRole.admin,
          memberSigningPublicKeyHex: '04${'a' * 128}',
          memberEncryptionPublicKeyHex: '04${'b' * 128}',
          encryptedDataKey: 'data',
          encryptedMemberKey: 'member',
          joinedAt: DateTime.utc(2026, 8, 3),
          addedByAttestorPublicKeyHex: '04${'c' * 128}',
          addedByAttestation: 'sig',
        ),
      );
      when(
        () => group.removeGroupMember(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          callerDeviceSigningPublicKeyHex: any(
            named: 'callerDeviceSigningPublicKeyHex',
          ),
          memberId: any(named: 'memberId'),
          callerMemberSigningPublicKeyHex: any(
            named: 'callerMemberSigningPublicKeyHex',
          ),
          memberAuthSignature: any(named: 'memberAuthSignature'),
          groupUltimateSignature: any(named: 'groupUltimateSignature'),
        ),
      ).thenAnswer((_) async => true);
      final groups = AnonaccountGroups(
        caller,
        InMemoryMemberKeyStore(),
        ownerStore,
      );
      final device = await KeyGen.generateDeviceKey();
      await groups.addGroupMemberAsOwner(
        groupId: groupId,
        newMemberAccountId: memberId,
        newMemberSigningPubkeyHex: '04${'a' * 128}',
        newMemberEncryptionPublicKeyHex: '04${'b' * 128}',
        newMemberEncryptedDataKey: 'data',
        callerDeviceKey: device,
        encryptedMemberKey: 'member',
        encryptedMemberKeyAttestation: 'sig',
      );
      await groups.removeGroupMemberAsOwner(
        groupId: groupId,
        memberId: memberId,
        callerDeviceKey: device,
      );
      final add = verify(
        () => group.addGroupMember(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          callerDeviceSigningPublicKeyHex: any(
            named: 'callerDeviceSigningPublicKeyHex',
          ),
          groupId: groupId,
          newMemberAccountId: memberId,
          role: wire.GroupMemberRole.admin,
          memberKeys: any(named: 'memberKeys'),
          encryptedDataKey: 'data',
          encryptedMemberKey: 'member',
          encryptedMemberKeyAttestation: 'sig',
          callerMemberSigningPublicKeyHex: captureAny(
            named: 'callerMemberSigningPublicKeyHex',
          ),
          memberAuthSignature: captureAny(named: 'memberAuthSignature'),
          groupUltimateSignature: captureAny(named: 'groupUltimateSignature'),
        ),
      ).captured;
      expect(add[0], isNull);
      expect(add[1], isNull);
      expect(add[2], isNotNull);
      final remove = verify(
        () => group.removeGroupMember(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          callerDeviceSigningPublicKeyHex: any(
            named: 'callerDeviceSigningPublicKeyHex',
          ),
          memberId: memberId,
          callerMemberSigningPublicKeyHex: captureAny(
            named: 'callerMemberSigningPublicKeyHex',
          ),
          memberAuthSignature: captureAny(named: 'memberAuthSignature'),
          groupUltimateSignature: captureAny(named: 'groupUltimateSignature'),
        ),
      ).captured;
      expect(remove[0], isNull);
      expect(remove[1], isNull);
      expect(remove[2], isNotNull);
    },
  );

  test('owner methods require a recovered owner key', () async {
    final groups = AnonaccountGroups(
      _Caller(),
      InMemoryMemberKeyStore(),
      InMemoryGroupOwnerKeyStore(),
    );
    final id = wire.UuidValue.fromString(
      'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    );
    await expectLater(
      groups.removeGroupMemberAsOwner(
        groupId: id,
        memberId: id,
        callerDeviceKey: await KeyGen.generateDeviceKey(),
      ),
      throwsA(isA<StateError>()),
    );
  });
}
