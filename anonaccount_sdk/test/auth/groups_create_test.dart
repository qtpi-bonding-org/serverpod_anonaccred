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
      wire.PublicKeyDuo(
        signingPublicKeyHex: '04${'0' * 128}',
        encryptionPublicKeyHex: '04${'1' * 128}',
      ),
    );
  });

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
      ultimateSigningPublicKeyHex: '04${'u' * 128}',
      ultimateEncryptionPublicKeyHex: '04${'v' * 128}',
      encryptedDataKey: 'WRAPPED',
      createdAt: DateTime.utc(2026, 5, 20),
    );
    when(() => group.createGroup(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          callerDeviceSigningPublicKeyHex: any(named: 'callerDeviceSigningPublicKeyHex'),
          groupUltimateKeys: any(named: 'groupUltimateKeys'),
          groupEncryptedDataKey: any(named: 'groupEncryptedDataKey'),
          creatorMemberKeys: any(named: 'creatorMemberKeys'),
          creatorMemberEncryptedDataKey: any(named: 'creatorMemberEncryptedDataKey'),
          groupUltimateAttestation: any(named: 'groupUltimateAttestation'),
        )).thenAnswer((_) async => stubReturn);

    final callerDeviceKey = await KeyGen.generateDeviceKey();
    final callerDeviceHex = await callerDeviceKey.signingKeyPair.exportPublicKeySec1Hex();
    final store = InMemoryMemberKeyStore();
    final groups = AnonaccountGroups(caller, store, difficulty: 4);
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
          callerDeviceSigningPublicKeyHex: callerDeviceHex.value,
          groupUltimateKeys: any(named: 'groupUltimateKeys'),
          groupEncryptedDataKey: any(named: 'groupEncryptedDataKey'),
          creatorMemberKeys: any(named: 'creatorMemberKeys'),
          creatorMemberEncryptedDataKey: any(named: 'creatorMemberEncryptedDataKey'),
          groupUltimateAttestation: any(named: 'groupUltimateAttestation'),
        )).called(1);
  });

  test('AnonaccountGroups takes a MemberKeyStore', () {
    // Pins the constructor arity so a later refactor cannot quietly drop
    // custody back out of the class.
    final groups = AnonaccountGroups(
      _FakeCaller(),
      InMemoryMemberKeyStore(),
      difficulty: 4,
    );
    expect(groups, isA<AnonaccountGroups>());
  });
}
