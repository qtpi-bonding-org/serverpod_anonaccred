import 'package:anonaccount_client/anonaccount_client.dart' as wire;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeCaller extends Mock implements wire.Caller {}

class _FakeEntrypoint extends Mock implements wire.EndpointEntrypoint {}

class _FakeGroup extends Mock implements wire.EndpointGroup {}

// The wire now returns `GroupMembershipView` rows (not `GroupMember`).
// We need to use the new view's fields when mocking.
void main() {
  test('listMyGroups surfaces the member row id as memberId', () async {
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

    final memberRowId = wire.UuidValue.fromString(
      '11111111-1111-1111-1111-111111111111',
    );
    final row = wire.GroupMembershipView(
      memberId: memberRowId,
      shareGroupId: wire.UuidValue.fromString(
        '22222222-2222-4222-8222-222222222222',
      ),
      role: wire.GroupMemberRole.member,
      memberSigningPublicKeyHex: '04${'a' * 128}',
      memberEncryptedDataKey: 'BLOB1',
      deviceEncryptedDataKey: 'device-blob',
      joinedAt: DateTime.utc(2026, 5, 20),
      encryptedMemberKey: 'MEMBER-KEY-BLOB1',
      encryptedUltimateKey: null,
    );
    when(
      () => group.listMyGroups(
        challenge: any(named: 'challenge'),
        proofOfWork: any(named: 'proofOfWork'),
        signature: any(named: 'signature'),
        callerDeviceSigningPublicKeyHex: any(
          named: 'callerDeviceSigningPublicKeyHex',
        ),
      ),
    ).thenAnswer((_) async => [row]);

    final callerDeviceKey = await KeyGen.generateDeviceKey();
    final store = InMemoryMemberKeyStore();
    final groups = AnonaccountGroups(
      caller,
      store,
      InMemoryGroupOwnerKeyStore(),
      difficulty: 4,
    );
    final memberships = await groups.listMyGroups(
      callerDeviceKey: callerDeviceKey,
    );

    expect(memberships.single.memberId, memberRowId);
  });
}
