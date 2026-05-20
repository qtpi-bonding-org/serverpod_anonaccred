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
      shareGroupId: wire.UuidValue.fromString('11111111-1111-4111-8111-111111111111'),
      anonAccountId: wire.UuidValue.fromString('22222222-2222-4222-8222-222222222222'),
      role: wire.GroupMemberRole.admin,
      memberSigningPublicKeyHex: 'a' * 128,
      memberPublicKey: '{"kty":"EC"}',
      encryptedDataKey: 'BLOB1',
      joinedAt: DateTime.utc(2026, 5, 20),
    );
    final row2 = wire.GroupMember(
      shareGroupId: wire.UuidValue.fromString('33333333-3333-4333-8333-333333333333'),
      anonAccountId: wire.UuidValue.fromString('22222222-2222-4222-8222-222222222222'),
      role: wire.GroupMemberRole.member,
      memberSigningPublicKeyHex: 'b' * 128,
      memberPublicKey: '{"kty":"EC"}',
      encryptedDataKey: 'BLOB2',
      joinedAt: DateTime.utc(2026, 5, 21),
      isRevoked: false,
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
    expect(memberships[0].role, wire.GroupMemberRole.admin);
    expect(memberships[0].encryptedDataKey, 'BLOB1');
    expect(memberships[1].groupId, '33333333-3333-4333-8333-333333333333');
    expect(memberships[1].isRevoked, isFalse);
  });
}
