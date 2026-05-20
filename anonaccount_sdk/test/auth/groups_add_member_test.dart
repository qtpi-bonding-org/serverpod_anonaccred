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
      memberSigningPublicKeyHex: 'd' * 128,
      memberPublicKey: '{"kty":"EC"}',
      encryptedDataKey: 'WRAPPED_KEY',
      joinedAt: DateTime.utc(2026, 5, 20),
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
          memberSigningPublicKeyHex: any(named: 'memberSigningPublicKeyHex'),
          memberPublicKey: any(named: 'memberPublicKey'),
          encryptedDataKey: any(named: 'encryptedDataKey'),
          callerMemberSigningPublicKeyHex:
              any(named: 'callerMemberSigningPublicKeyHex'),
          memberAuthSignature: any(named: 'memberAuthSignature'),
          groupUltimateSignature: any(named: 'groupUltimateSignature'),
        )).thenAnswer((_) async => stubMember);

    final callerMemberKey = await KeyGen.generateDeviceKey();
    final callerDeviceKey = await KeyGen.generateDeviceKey();
    final groups = AnonaccountGroups(caller, difficulty: 4);

    final result = await groups.addGroupMember(
      groupId: groupId,
      newMemberAccountId: newMemberAccountId,
      role: wire.GroupMemberRole.member,
      newMemberSigningPubkeyHex: 'd' * 128,
      newMemberPublicKeyJwk: '{"kty":"EC"}',
      newMemberEncryptedDataKey: 'WRAPPED_KEY',
      callerMemberKey: callerMemberKey,
      callerDeviceKey: callerDeviceKey,
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
        memberSigningPublicKeyHex: any(named: 'memberSigningPublicKeyHex'),
        memberPublicKey: any(named: 'memberPublicKey'),
        encryptedDataKey: any(named: 'encryptedDataKey'),
        callerMemberSigningPublicKeyHex:
            captureAny(named: 'callerMemberSigningPublicKeyHex'),
        memberAuthSignature: captureAny(named: 'memberAuthSignature'),
        groupUltimateSignature: captureAny(named: 'groupUltimateSignature'),
      ),
    ).captured;

    // challenge at index 0, callerMemberSigningPublicKeyHex at 1, memberAuthSignature at 2, groupUltimateSignature at 3
    expect(captured[0], 'CHAL-ADD');
    expect(captured[1], isNotNull); // callerMemberSigningPublicKeyHex
    expect(captured[2], isNotNull); // memberAuthSignature — must be non-null
    expect(captured[3], isNull); // groupUltimateSignature — null for admin branch
  });
}
