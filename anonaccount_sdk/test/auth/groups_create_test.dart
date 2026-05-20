import 'package:anonaccount_client/anonaccount_client.dart' as wire;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeCaller extends Mock implements wire.Caller {}
class _FakeEntrypoint extends Mock implements wire.EndpointEntrypoint {}
class _FakeGroup extends Mock implements wire.EndpointGroup {}

void main() {
  test('createGroup generates fresh group keys, wraps to self, returns CreatedGroup', () async {
    final caller = _FakeCaller();
    final entrypoint = _FakeEntrypoint();
    final group = _FakeGroup();
    when(() => caller.entrypoint).thenReturn(entrypoint);
    when(() => caller.group).thenReturn(group);
    when(() => entrypoint.getChallenge()).thenAnswer(
      (_) async => wire.PublicChallengeResponse(
        challenge: 'CHAL-G',
        difficulty: 4,
        expiresAt: 9999999999,
      ),
    );

    final stubReturn = wire.ShareGroup(
      id: wire.UuidValue.fromString('11111111-1111-4111-8111-111111111111'),
      ultimateSigningPublicKeyHex: 'u' * 128,
      ultimatePublicKey: '{"kty":"EC"}',
      encryptedDataKey: 'WRAPPED',
      createdAt: DateTime.utc(2026, 5, 20),
    );
    when(() => group.createGroup(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          callerDeviceSigningPublicKeyHex: any(named: 'callerDeviceSigningPublicKeyHex'),
          groupUltimateSigningPublicKeyHex: any(named: 'groupUltimateSigningPublicKeyHex'),
          groupUltimatePublicKey: any(named: 'groupUltimatePublicKey'),
          groupEncryptedDataKey: any(named: 'groupEncryptedDataKey'),
          creatorMemberSigningPublicKeyHex: any(named: 'creatorMemberSigningPublicKeyHex'),
          creatorMemberPublicKey: any(named: 'creatorMemberPublicKey'),
          creatorMemberEncryptedDataKey: any(named: 'creatorMemberEncryptedDataKey'),
          groupUltimateAttestation: any(named: 'groupUltimateAttestation'),
        )).thenAnswer((_) async => stubReturn);

    final callerDeviceKey = await KeyGen.generateDeviceKey();
    final callerDeviceHex = await callerDeviceKey.signingKeyPair.exportPublicKeyHex();
    final groups = AnonaccountGroups(caller, difficulty: 4);
    final created = await groups.createGroup(
      displayName: 'Family',
      callerDeviceKey: callerDeviceKey,
    );

    expect(created.displayName, 'Family');
    expect(created.groupId, '11111111-1111-4111-8111-111111111111');
    expect(created.groupDataKey, isA<AesGcmSecretKey>());

    verify(() => group.createGroup(
          challenge: 'CHAL-G',
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          callerDeviceSigningPublicKeyHex: callerDeviceHex,
          groupUltimateSigningPublicKeyHex: any(named: 'groupUltimateSigningPublicKeyHex'),
          groupUltimatePublicKey: any(named: 'groupUltimatePublicKey'),
          groupEncryptedDataKey: any(named: 'groupEncryptedDataKey'),
          creatorMemberSigningPublicKeyHex: any(named: 'creatorMemberSigningPublicKeyHex'),
          creatorMemberPublicKey: any(named: 'creatorMemberPublicKey'),
          creatorMemberEncryptedDataKey: any(named: 'creatorMemberEncryptedDataKey'),
          groupUltimateAttestation: any(named: 'groupUltimateAttestation'),
        )).called(1);
  });
}
