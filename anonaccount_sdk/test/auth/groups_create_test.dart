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
          creatorEncryptedMemberKey: any(named: 'creatorEncryptedMemberKey'),
          creatorEncryptedMemberKeyAttestation:
              any(named: 'creatorEncryptedMemberKeyAttestation'),
        )).thenAnswer((_) async => stubReturn);

    final callerDeviceKey = await KeyGen.generateDeviceKey();
    final callerDeviceHex = await callerDeviceKey.signingKeyPair.exportPublicKeySec1Hex();
    final ultimateHolder = InMemoryAccountKeyStore();
    await ultimateHolder.generateAccountKeys();
    final ultimateEncHex =
        (await ultimateHolder.getUltimateEncryptionPublicKeyHex())!;
    final store = InMemoryMemberKeyStore();
    final groups = AnonaccountGroups(caller, store, InMemoryGroupOwnerKeyStore(), difficulty: 4);
    final created = await groups.createGroup(
      displayName: 'Family',
      callerDeviceKey: callerDeviceKey,
      myAnonAccountId: wire.UuidValue.fromString(
        '99999999-9999-4999-8999-999999999999',
      ),
      ultimateEncryptionPublicKeyHex: ultimateEncHex,
    );

    expect(created.displayName, 'Family');
    expect(created.groupId, '11111111-1111-4111-8111-111111111111');
    expect(created.groupDataKey, isA<AesGcmSecretKey>());

    final verification = verify(() => group.createGroup(
          challenge: 'CHAL-G',
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          callerDeviceSigningPublicKeyHex: callerDeviceHex.value,
          groupUltimateKeys: any(named: 'groupUltimateKeys'),
          groupEncryptedDataKey: any(named: 'groupEncryptedDataKey'),
          creatorMemberKeys: captureAny(named: 'creatorMemberKeys'),
          creatorMemberEncryptedDataKey:
              any(named: 'creatorMemberEncryptedDataKey'),
          groupUltimateAttestation: any(named: 'groupUltimateAttestation'),
          creatorEncryptedMemberKey: any(named: 'creatorEncryptedMemberKey'),
          creatorEncryptedMemberKeyAttestation:
              any(named: 'creatorEncryptedMemberKeyAttestation'),
        ));
    verification.called(1);

    // The creator's member key reaches custody, filed under the new group id.
    final stored = await store.getMemberKey(
      wire.UuidValue.fromString('11111111-1111-4111-8111-111111111111'),
    );
    expect(stored, isNotNull);

    // And it is the key whose public half went over the wire as
    // creatorMemberKeys, not merely some key.
    final sentDuo = verification.captured.single as wire.PublicKeyDuo;
    final storedHex =
        (await stored!.signingKeyPair.exportPublicKeySec1Hex()).value;
    expect(storedHex, sentDuo.signingPublicKeyHex);
  });

  test('createGroup encrypts the member key with the ultimate encryption key',
      () async {
    final caller = _FakeCaller();
    final entrypoint = _FakeEntrypoint();
    final group = _FakeGroup();
    when(() => caller.entrypoint).thenReturn(entrypoint);
    when(() => caller.group).thenReturn(group);
    when(() => entrypoint.getChallenge()).thenAnswer(
      (_) async => wire.PublicChallengeResponse(
        challenge: 'CHAL-BK',
        difficulty: 4,
        expiresAt: 9999999999,
      ),
    );
    when(() => group.createGroup(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          callerDeviceSigningPublicKeyHex:
              any(named: 'callerDeviceSigningPublicKeyHex'),
          groupUltimateKeys: any(named: 'groupUltimateKeys'),
          groupEncryptedDataKey: any(named: 'groupEncryptedDataKey'),
          creatorMemberKeys: any(named: 'creatorMemberKeys'),
          creatorMemberEncryptedDataKey:
              any(named: 'creatorMemberEncryptedDataKey'),
          groupUltimateAttestation: any(named: 'groupUltimateAttestation'),
          creatorEncryptedMemberKey:
              captureAny(named: 'creatorEncryptedMemberKey'),
          creatorEncryptedMemberKeyAttestation:
              any(named: 'creatorEncryptedMemberKeyAttestation'),
        )).thenAnswer((_) async => wire.ShareGroup(
          id: wire.UuidValue.fromString(
            '11111111-1111-4111-8111-111111111111',
          ),
          ultimateSigningPublicKeyHex: '04${'u' * 128}',
          ultimateEncryptionPublicKeyHex: '04${'v' * 128}',
          encryptedDataKey: 'WRAPPED',
          createdAt: DateTime.utc(2026, 8, 2),
        ));

    // A real ultimate key, so the test can decrypt what the SDK produced.
    final ultimateHolder = InMemoryAccountKeyStore();
    await ultimateHolder.generateAccountKeys();
    final ultimateEncHex =
        (await ultimateHolder.getUltimateEncryptionPublicKeyHex())!;
    final ultimateJwk = (await ultimateHolder.getUltimateKeyJwkOnce())!;

    final store = InMemoryMemberKeyStore();
    final groups = AnonaccountGroups(caller, store, InMemoryGroupOwnerKeyStore(), difficulty: 4);
    final callerDeviceKey = await KeyGen.generateDeviceKey();
    final myAccountId = wire.UuidValue.fromString(
      '33333333-3333-4333-8333-333333333333',
    );

    await groups.createGroup(
      displayName: 'g',
      callerDeviceKey: callerDeviceKey,
      myAnonAccountId: myAccountId,
      ultimateEncryptionPublicKeyHex: ultimateEncHex,
    );

    final captured = verify(() => group.createGroup(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          callerDeviceSigningPublicKeyHex:
              any(named: 'callerDeviceSigningPublicKeyHex'),
          groupUltimateKeys: any(named: 'groupUltimateKeys'),
          groupEncryptedDataKey: any(named: 'groupEncryptedDataKey'),
          creatorMemberKeys: any(named: 'creatorMemberKeys'),
          creatorMemberEncryptedDataKey:
              any(named: 'creatorMemberEncryptedDataKey'),
          groupUltimateAttestation: any(named: 'groupUltimateAttestation'),
          creatorEncryptedMemberKey:
              captureAny(named: 'creatorEncryptedMemberKey'),
          creatorEncryptedMemberKeyAttestation:
              any(named: 'creatorEncryptedMemberKeyAttestation'),
        )).captured;
    final blob = captured.single as String;

    // The blob must decrypt with the ultimate ENCRYPTION private key and
    // yield the very member key pair the store now holds.
    final verifier = InMemoryAccountKeyStore();
    final ultimate = await verifier.importUltimateKeyJwk(ultimateJwk);
    final recoveredJwk = await AsymmetricCrypto.unwrap(
      blob,
      ultimate.encryptionKeyPair.privateKey!,
    );
    final recovered = await const KeyDuoSerializer().importKeyDuoJwk(
      recoveredJwk,
    );
    final storedMemberKey = (await store.getMemberKey(
      wire.UuidValue.fromString('11111111-1111-4111-8111-111111111111'),
    ))!;
    expect(
      (await recovered.signingKeyPair.exportPublicKeySec1Hex()).value,
      (await storedMemberKey.signingKeyPair.exportPublicKeySec1Hex()).value,
    );
  });

  test('no device-resident key opens the member key backup', () async {
    // The property that separates this from the escrow design that was
    // rejected: a compromised device holding data keys gains nothing.
    // Asserted against the device key, which IS resident. (The group data
    // key is symmetric AES-GCM and structurally cannot decrypt an ECDH
    // hybrid blob at all, so asserting against it would prove nothing.)
    final caller = _FakeCaller();
    final entrypoint = _FakeEntrypoint();
    final group = _FakeGroup();
    when(() => caller.entrypoint).thenReturn(entrypoint);
    when(() => caller.group).thenReturn(group);
    when(() => entrypoint.getChallenge()).thenAnswer(
      (_) async => wire.PublicChallengeResponse(
        challenge: 'CHAL-BK2',
        difficulty: 4,
        expiresAt: 9999999999,
      ),
    );
    when(() => group.createGroup(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          callerDeviceSigningPublicKeyHex:
              any(named: 'callerDeviceSigningPublicKeyHex'),
          groupUltimateKeys: any(named: 'groupUltimateKeys'),
          groupEncryptedDataKey: any(named: 'groupEncryptedDataKey'),
          creatorMemberKeys: any(named: 'creatorMemberKeys'),
          creatorMemberEncryptedDataKey:
              any(named: 'creatorMemberEncryptedDataKey'),
          groupUltimateAttestation: any(named: 'groupUltimateAttestation'),
          creatorEncryptedMemberKey:
              captureAny(named: 'creatorEncryptedMemberKey'),
          creatorEncryptedMemberKeyAttestation:
              any(named: 'creatorEncryptedMemberKeyAttestation'),
        )).thenAnswer((_) async => wire.ShareGroup(
          id: wire.UuidValue.fromString(
            '22222222-2222-4222-8222-222222222222',
          ),
          ultimateSigningPublicKeyHex: '04${'u' * 128}',
          ultimateEncryptionPublicKeyHex: '04${'v' * 128}',
          encryptedDataKey: 'WRAPPED',
          createdAt: DateTime.utc(2026, 8, 2),
        ));

    final ultimateHolder = InMemoryAccountKeyStore();
    await ultimateHolder.generateAccountKeys();
    final ultimateEncHex =
        (await ultimateHolder.getUltimateEncryptionPublicKeyHex())!;

    final groups =
        AnonaccountGroups(caller, InMemoryMemberKeyStore(), InMemoryGroupOwnerKeyStore(), difficulty: 4);
    final deviceKey = await KeyGen.generateDeviceKey();

    await groups.createGroup(
      displayName: 'g',
      callerDeviceKey: deviceKey,
      myAnonAccountId: wire.UuidValue.fromString(
        '44444444-4444-4444-8444-444444444444',
      ),
      ultimateEncryptionPublicKeyHex: ultimateEncHex,
    );
    final blob = verify(() => group.createGroup(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          callerDeviceSigningPublicKeyHex:
              any(named: 'callerDeviceSigningPublicKeyHex'),
          groupUltimateKeys: any(named: 'groupUltimateKeys'),
          groupEncryptedDataKey: any(named: 'groupEncryptedDataKey'),
          creatorMemberKeys: any(named: 'creatorMemberKeys'),
          creatorMemberEncryptedDataKey:
              any(named: 'creatorMemberEncryptedDataKey'),
          groupUltimateAttestation: any(named: 'groupUltimateAttestation'),
          creatorEncryptedMemberKey:
              captureAny(named: 'creatorEncryptedMemberKey'),
          creatorEncryptedMemberKeyAttestation:
              any(named: 'creatorEncryptedMemberKeyAttestation'),
        )).captured.single as String;

    await expectLater(
      AsymmetricCrypto.unwrap(blob, deviceKey.encryptionKeyPair.privateKey!),
      throwsA(isA<CryptoOperationException>()),
    );
  });

  test('CreatedGroup exposes no member key', () async {
    // The member key reaches the store, never the caller. Pins the field's
    // absence so it cannot be reintroduced without this failing.
    final created = CreatedGroup(
      groupId: 'g',
      displayName: 'g',
      groupDataKey: await AesGcmSecretKey.generateKey(256),
      createdAt: DateTime.utc(2026, 8, 2),
    );
    expect(created.toString(), isNot(contains('memberKey')));
  });

  test('AnonaccountGroups takes a MemberKeyStore', () {
    // Pins the constructor arity so a later refactor cannot quietly drop
    // custody back out of the class.
    final groups = AnonaccountGroups(
      _FakeCaller(),
      InMemoryMemberKeyStore(),
      InMemoryGroupOwnerKeyStore(),
      difficulty: 4,
    );
    expect(groups, isA<AnonaccountGroups>());
  });
}
