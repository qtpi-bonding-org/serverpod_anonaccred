import 'package:anonaccount_client/anonaccount_client.dart' as wire;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeCaller extends Mock implements wire.Caller {}
class _FakeEntrypoint extends Mock implements wire.EndpointEntrypoint {}
class _FakeGroup extends Mock implements wire.EndpointGroup {}

void main() {
  test('listMyGroups maps wire rows to GroupMembership', () async {
    final caller = _FakeCaller();
    final entrypoint = _FakeEntrypoint();
    final group = _FakeGroup();
    when(() => caller.entrypoint).thenReturn(entrypoint);
    when(() => caller.group).thenReturn(group);
    when(() => entrypoint.getChallenge()).thenAnswer(
      (_) async => wire.PublicChallengeResponse(
        challenge: 'C',
        difficulty: 4,
        expiresAt: 9999999999,
      ),
    );

    final row1 = wire.GroupMember(
      id: wire.UuidValue.fromString('44444444-4444-4444-8444-444444444444'),
      shareGroupId: wire.UuidValue.fromString('11111111-1111-4111-8111-111111111111'),
      anonAccountId: wire.UuidValue.fromString('22222222-2222-4222-8222-222222222222'),
      role: wire.GroupMemberRole.admin,
      memberSigningPublicKeyHex: '04${'a' * 128}',
      memberEncryptionPublicKeyHex: '04${'e' * 128}',
      encryptedDataKey: 'BLOB1',
      joinedAt: DateTime.utc(2026, 5, 20),
      addedBySignerPublicKeyHex: '04${'f' * 128}',
      addedByAttestation: 'test-attestation',
    );
    final row2 = wire.GroupMember(
      id: wire.UuidValue.fromString('55555555-5555-4555-8555-555555555555'),
      shareGroupId: wire.UuidValue.fromString('33333333-3333-4333-8333-333333333333'),
      anonAccountId: wire.UuidValue.fromString('22222222-2222-4222-8222-222222222222'),
      role: wire.GroupMemberRole.member,
      memberSigningPublicKeyHex: '04${'b' * 128}',
      memberEncryptionPublicKeyHex: '04${'d' * 128}',
      encryptedDataKey: 'BLOB2',
      joinedAt: DateTime.utc(2026, 5, 21),
      isRevoked: false,
      addedBySignerPublicKeyHex: '04${'f' * 128}',
      addedByAttestation: 'test-attestation',
    );
    when(() => group.listMyGroups(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          callerDeviceSigningPublicKeyHex:
              any(named: 'callerDeviceSigningPublicKeyHex'),
        )).thenAnswer((_) async => [row1, row2]);

    final callerDeviceKey = await KeyGen.generateDeviceKey();
    final groups = AnonaccountGroups(caller, difficulty: 4);
    final memberships =
        await groups.listMyGroups(callerDeviceKey: callerDeviceKey);

    expect(memberships, hasLength(2));
    expect(memberships[0].groupId, '11111111-1111-4111-8111-111111111111');
    expect(memberships[0].memberId, row1.id);
    expect(memberships[0].role, wire.GroupMemberRole.admin);
    expect(memberships[0].encryptedDataKey, 'BLOB1');
    expect(memberships[1].groupId, '33333333-3333-4333-8333-333333333333');
    expect(memberships[1].memberId, row2.id);
    expect(memberships[1].isRevoked, isFalse);
  });
}
