import 'package:anonaccount_client/anonaccount_client.dart' as wire;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeCaller extends Mock implements wire.Caller {}

class _FakeEntrypoint extends Mock implements wire.EndpointEntrypoint {}

class _FakeGroup extends Mock implements wire.EndpointGroup {}

void main() {
  setUpAll(() {
    // Register fallback values for UuidValue (used in named matchers).
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

  test('addGroupMember calls wire with inner member-key attestation', () async {
    final caller = _FakeCaller();
    final entrypoint = _FakeEntrypoint();
    final group = _FakeGroup();
    when(() => caller.entrypoint).thenReturn(entrypoint);
    when(() => caller.group).thenReturn(group);
    when(() => entrypoint.getChallenge()).thenAnswer(
      (_) async => wire.PublicChallengeResponse(
        challenge: 'CHAL-ADD',
        difficulty: 4,
        expiresAt: 9999999999,
      ),
    );

    final groupId = wire.UuidValue.fromString(
      'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    );
    final newMemberAccountId = wire.UuidValue.fromString(
      'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    );

    final stubMember = wire.GroupMember(
      id: wire.UuidValue.fromString('cccccccc-cccc-4ccc-8ccc-cccccccccccc'),
      shareGroupId: groupId,
      anonAccountId: newMemberAccountId,
      role: wire.GroupMemberRole.member,
      memberSigningPublicKeyHex: '04${'d' * 128}',
      memberEncryptionPublicKeyHex: '04${'e' * 128}',
      encryptedDataKey: 'WRAPPED_KEY',
      encryptedMemberKey: 'WRAPPED_KEY',
      joinedAt: DateTime.utc(2026, 5, 20),
      addedByAttestorPublicKeyHex: '04${'f' * 128}',
      addedByAttestation: 'test-attestation',
    );

    when(() => group.addGroupMember(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          callerDeviceSigningPublicKeyHex:
              any(named: 'callerDeviceSigningPublicKeyHex'),
          groupId: any(named: 'groupId'),
          newMemberAccountId: any(named: 'newMemberAccountId'),
          role: any(named: 'role'),
          memberKeys: any(named: 'memberKeys'),
          encryptedDataKey: any(named: 'encryptedDataKey'),
          callerMemberSigningPublicKeyHex:
              any(named: 'callerMemberSigningPublicKeyHex'),
          memberAuthSignature: any(named: 'memberAuthSignature'),
          groupUltimateSignature: any(named: 'groupUltimateSignature'),
          encryptedMemberKey: any(named: 'encryptedMemberKey'),
          encryptedMemberKeyAttestation:
              any(named: 'encryptedMemberKeyAttestation'),
        )).thenAnswer((_) async => stubMember);

    final callerMemberKey = await KeyGen.generateDeviceKey();
    final callerDeviceKey = await KeyGen.generateDeviceKey();
    final store = InMemoryMemberKeyStore();
    await store.storeMemberKey(groupId, callerMemberKey);
    final groups = AnonaccountGroups(caller, store, difficulty: 4);

    final result = await groups.addGroupMember(
      groupId: groupId,
      newMemberAccountId: newMemberAccountId,
      role: wire.GroupMemberRole.member,
      newMemberSigningPubkeyHex: '04${'d' * 128}',
      newMemberEncryptionPublicKeyHex: '04${'e' * 128}',
      newMemberEncryptedDataKey: 'WRAPPED_KEY',
      callerDeviceKey: callerDeviceKey,
      encryptedMemberKey: 'INVITEE-BLOB',
      encryptedMemberKeyAttestation: 'INVITEE-SIG',
    );

    expect(result.id.toString(), 'cccccccc-cccc-4ccc-8ccc-cccccccccccc');
    expect(result.encryptedDataKey, 'WRAPPED_KEY');
    expect(result.role, wire.GroupMemberRole.member);

    // Verify wire was called with groupUltimateSignature: null (admin branch).
    final captured = verify(
      () => group.addGroupMember(
        challenge: captureAny(named: 'challenge'),
        proofOfWork: any(named: 'proofOfWork'),
        signature: any(named: 'signature'),
        callerDeviceSigningPublicKeyHex:
            any(named: 'callerDeviceSigningPublicKeyHex'),
        groupId: any(named: 'groupId'),
        newMemberAccountId: any(named: 'newMemberAccountId'),
        role: any(named: 'role'),
        memberKeys: any(named: 'memberKeys'),
        encryptedDataKey: any(named: 'encryptedDataKey'),
        callerMemberSigningPublicKeyHex:
            captureAny(named: 'callerMemberSigningPublicKeyHex'),
        memberAuthSignature: captureAny(named: 'memberAuthSignature'),
        groupUltimateSignature: captureAny(named: 'groupUltimateSignature'),
        encryptedMemberKey: captureAny(named: 'encryptedMemberKey'),
        encryptedMemberKeyAttestation:
            captureAny(named: 'encryptedMemberKeyAttestation'),
      ),
    ).captured;

    // mocktail's `captured` order follows the mocked method's declared
    // parameter order (see client.dart's addGroupMember), not the order
    // captureAny() appears in this verify() call: challenge(0),
    // encryptedMemberKey(1), encryptedMemberKeyAttestation(2),
    // callerMemberSigningPublicKeyHex(3), memberAuthSignature(4),
    // groupUltimateSignature(5).
    expect(captured[0], 'CHAL-ADD');
    // The invitee's backup is relayed untouched: the admin's SDK cannot
    // construct these — it has neither the invitee's member private key nor
    // their ultimate public key — so both must pass through byte-for-byte.
    expect(captured[1], 'INVITEE-BLOB');
    expect(captured[2], 'INVITEE-SIG');
    // The signing key came from the store — nothing else supplies it now.
    expect(
      captured[3],
      (await callerMemberKey.signingKeyPair.exportPublicKeySec1Hex()).value,
    );
    expect(captured[4], isNotNull); // memberAuthSignature — must be non-null
    expect(captured[5], isNull); // groupUltimateSignature — null for admin branch
  });

  test('addGroupMember throws StateError when no member key is stored for the group',
      () async {
    final caller = _FakeCaller();
    final groupId = wire.UuidValue.fromString(
      'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    );
    final groups =
        AnonaccountGroups(caller, InMemoryMemberKeyStore(), difficulty: 4);

    await expectLater(
      groups.addGroupMember(
        groupId: groupId,
        newMemberAccountId: wire.UuidValue.fromString(
          'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
        ),
        role: wire.GroupMemberRole.member,
        newMemberSigningPubkeyHex: '04${'d' * 128}',
        newMemberEncryptionPublicKeyHex: '04${'e' * 128}',
        newMemberEncryptedDataKey: 'WRAPPED_KEY',
        callerDeviceKey: await KeyGen.generateDeviceKey(),
        encryptedMemberKey: 'INVITEE-BLOB',
        encryptedMemberKeyAttestation: 'INVITEE-SIG',
      ),
      throwsA(isA<StateError>().having(
        (e) => e.message,
        'message',
        allOf(contains('addGroupMember'), contains(groupId.toString())),
      )),
    );
    // No stub on caller.entrypoint: reaching the wire would throw a mocktail
    // error instead of the StateError, so this also pins that the throw lands
    // before any proof-of-work.
  });
}
