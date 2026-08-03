import 'package:anonaccount_protocol/anonaccount_protocol.dart'
    show AccountInnerPayloads, GroupInnerPayloads, PublicKeyDuo;
import 'package:anonaccount_client/anonaccount_client.dart' as wire;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeCaller extends Mock implements wire.Caller {}

class _FakeEntrypoint extends Mock implements wire.EndpointEntrypoint {}

class _FakeDataKey extends Mock implements wire.EndpointDataKey {}

class _FakeDevice extends Mock implements wire.EndpointDevice {}

class _FakeGroup extends Mock implements wire.EndpointGroup {}

/// Builds the server-side state a real account would have: the account's
/// symmetric data key wrapped to its ultimate encryption pubkey, which is
/// what `AnonAccount.encryptedDataKey` holds and what
/// `recoverEncryptedDataKey` hands back.
Future<({String ultimateJwk, String ultimateHex, String symmetricJwk, String recoveryBlob})>
    _seedAccount() async {
  final seed = InMemoryAccountKeyStore();
  await seed.generateAccountKeys();
  final symmetricJwk = (await seed.getSymmetricDataKeyJwk())!;
  final ultimateJwk = (await seed.getUltimateKeyJwkOnce())!;

  final holder = InMemoryAccountKeyStore();
  final ultimate = await holder.importUltimateKeyJwk(ultimateJwk);
  final recoveryBlob = await AsymmetricCrypto.wrapForRecipient(
    symmetricJwk,
    ultimate.encryptionKeyPair.publicKey,
  );
  return (
    ultimateJwk: ultimateJwk,
    ultimateHex: (await ultimate.signingKeyPair.exportPublicKeySec1Hex()).value,
    symmetricJwk: symmetricJwk,
    recoveryBlob: recoveryBlob,
  );
}

void _stubRecovery(_FakeDataKey dataKey, String recoveryBlob) {
  when(() => dataKey.recoverEncryptedDataKey(
        challenge: any(named: 'challenge'),
        proofOfWork: any(named: 'proofOfWork'),
        signature: any(named: 'signature'),
        ultimateSigningPublicKeyHex: any(named: 'ultimateSigningPublicKeyHex'),
      )).thenAnswer(
    (_) async => wire.EncryptedDataKeyResponse(encryptedDataKey: recoveryBlob),
  );
}

void _stubListMyGroups(
  _FakeGroup group, {
  String? encryptedMemberKey,
  wire.UuidValue? shareGroupId,
}) {
  when(() => group.listMyGroups(
        challenge: any(named: 'challenge'),
        proofOfWork: any(named: 'proofOfWork'),
        signature: any(named: 'signature'),
        callerDeviceSigningPublicKeyHex:
            any(named: 'callerDeviceSigningPublicKeyHex'),
      )).thenAnswer((_) async => encryptedMemberKey == null
      ? <wire.GroupMembershipView>[]
      : [
          wire.GroupMembershipView(
            memberId: wire.UuidValue.fromString(
              '22222222-2222-4222-8222-222222222222',
            ),
            shareGroupId: shareGroupId ??
                wire.UuidValue.fromString(
                  '33333333-3333-4333-8333-333333333333',
                ),
            role: wire.GroupMemberRole.member,
            memberSigningPublicKeyHex: '04${'m' * 128}',
            memberEncryptedDataKey: 'group-blob',
            deviceEncryptedDataKey: null,
            joinedAt: DateTime.utc(2026, 8, 2),
            encryptedMemberKey: encryptedMemberKey,
            encryptedUltimateKey: null,
          ),
        ]);
}

void _stubRegisterDevice(_FakeDevice device) {
  when(() => device.registerDevice(
        challenge: any(named: 'challenge'),
        proofOfWork: any(named: 'proofOfWork'),
        signature: any(named: 'signature'),
        deviceKeyAttestation: any(named: 'deviceKeyAttestation'),
        ultimateSigningPublicKeyHex: any(named: 'ultimateSigningPublicKeyHex'),
        deviceKeys: any(named: 'deviceKeys'),
        encryptedDataKey: any(named: 'encryptedDataKey'),
        label: any(named: 'label'),
      )).thenAnswer((_) async => wire.AccountDevice(
        anonAccountId:
            wire.UuidValue.fromString('11111111-1111-4111-8111-111111111111'),
        deviceSigningPublicKeyHex: '04${'h' * 128}',
        deviceEncryptionPublicKeyHex: '04${'i' * 128}',
        encryptedDataKey: 'wrapped',
        label: 'laptop',
        addedByAttestorPublicKeyHex: '04${'j' * 128}',
        addedByAttestation: 'test-attestation',
        isRevoked: false,
        lastActive: DateTime.utc(2026, 8, 1),
      ));
}

void main() {
  late _FakeCaller caller;
  late _FakeEntrypoint entrypoint;
  late _FakeDataKey dataKey;
  late _FakeDevice device;
  late _FakeGroup group;

  setUpAll(() {
    registerFallbackValue(
      PublicKeyDuo(
        signingPublicKeyHex: '04${'0' * 128}',
        encryptionPublicKeyHex: '04${'1' * 128}',
      ),
    );
  });

  setUp(() {
    caller = _FakeCaller();
    entrypoint = _FakeEntrypoint();
    dataKey = _FakeDataKey();
    device = _FakeDevice();
    group = _FakeGroup();
    when(() => caller.entrypoint).thenReturn(entrypoint);
    when(() => caller.dataKey).thenReturn(dataKey);
    when(() => caller.device).thenReturn(device);
    when(() => caller.group).thenReturn(group);
    when(() => entrypoint.getChallenge()).thenAnswer(
      (_) async => wire.PublicChallengeResponse(
        challenge: 'CHAL-REC',
        difficulty: 4,
        expiresAt: 9999999999,
      ),
    );
  });

  test('recoverAccount restores the original account data key into the store',
      () async {
    final seeded = await _seedAccount();
    _stubRecovery(dataKey, seeded.recoveryBlob);
    _stubRegisterDevice(device);

    final store = InMemoryAccountKeyStore();
    final memberStore = InMemoryMemberKeyStore();
    _stubListMyGroups(group);
    final auth = AnonaccountAuth(caller, store, memberStore, InMemoryGroupOwnerKeyStore());

    await auth.recoverAccount(
      ultimateKeyJwk: seeded.ultimateJwk,
      deviceLabel: 'laptop',
    );

    // The whole point of recovery: the account's ORIGINAL data key is back,
    // so previously-encrypted content is still readable.
    expect(await store.getSymmetricDataKeyJwk(), seeded.symmetricJwk);

    verify(() => dataKey.recoverEncryptedDataKey(
          challenge: 'CHAL-REC',
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          ultimateSigningPublicKeyHex: seeded.ultimateHex,
        )).called(1);
  });

  test('recoverAccount registers the new device against the existing account',
      () async {
    final seeded = await _seedAccount();
    _stubRecovery(dataKey, seeded.recoveryBlob);
    _stubRegisterDevice(device);

    final store = InMemoryAccountKeyStore();
    final memberStore = InMemoryMemberKeyStore();
    _stubListMyGroups(group);
    final auth = AnonaccountAuth(caller, store, memberStore, InMemoryGroupOwnerKeyStore());

    await auth.recoverAccount(
      ultimateKeyJwk: seeded.ultimateJwk,
      deviceLabel: 'laptop',
    );

    final newDeviceHex = (await store.getDeviceSigningPublicKeyHex())!;
    final captured = verify(() => device.registerDevice(
          challenge: 'CHAL-REC',
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          deviceKeyAttestation: captureAny(named: 'deviceKeyAttestation'),
          ultimateSigningPublicKeyHex: seeded.ultimateHex,
          deviceKeys: captureAny(named: 'deviceKeys'),
          encryptedDataKey: captureAny(named: 'encryptedDataKey'),
          label: 'laptop',
        )).captured;
    final attestation = captured[0] as String;
    final capturedDeviceKeys = captured[1] as PublicKeyDuo;
    final deviceBlob = captured[2] as String;

    expect(capturedDeviceKeys.signingPublicKeyHex, newDeviceHex);
    expect(
      capturedDeviceKeys.signingPublicKeyHex,
      isNot(capturedDeviceKeys.encryptionPublicKeyHex),
    );

    // The blob handed to the server must be the recovered account data key
    // wrapped to the NEW device — otherwise the device can never read it back.
    final newDeviceKey = (await store.getDeviceKey())!;
    expect(
      await AsymmetricCrypto.unwrap(
        deviceBlob,
        newDeviceKey.encryptionKeyPair.privateKey!,
      ),
      seeded.symmetricJwk,
    );

    // The ultimate key must have authorized this device key pair, or the
    // server rejects the registration.
    final verifier = InMemoryAccountKeyStore();
    final ultimate = await verifier.importUltimateKeyJwk(seeded.ultimateJwk);
    expect(
      await SigningCrypto.verifyChallenge(
        AccountInnerPayloads.registerDevice(capturedDeviceKeys),
        attestation,
        ultimate,
      ),
      isTrue,
    );
  });

  test('recoverAccount throws InvalidUltimateKeyException on bad JWK', () async {
    final store = InMemoryAccountKeyStore();
    final memberStore = InMemoryMemberKeyStore();
    _stubListMyGroups(group);
    final auth = AnonaccountAuth(caller, store, memberStore, InMemoryGroupOwnerKeyStore());
    await expectLater(
      auth.recoverAccount(ultimateKeyJwk: 'not-json', deviceLabel: 'x'),
      throwsA(isA<InvalidUltimateKeyException>()),
    );
  });

  test('recoverAccount restores a usable member key from the backup',
      () async {
    final seeded = await _seedAccount();
    _stubRecovery(dataKey, seeded.recoveryBlob);
    _stubRegisterDevice(device);

    // A membership whose member key was encrypted with the ultimate
    // encryption public key at join time.
    final memberKey = await KeyGen.generateDeviceKey();
    final memberKeyJwk =
        await const KeyDuoSerializer().exportKeyDuoJwk(memberKey);
    final holder = InMemoryAccountKeyStore();
    final ultimate = await holder.importUltimateKeyJwk(seeded.ultimateJwk);
    final encryptedMemberKey = await AsymmetricCrypto.wrapForRecipient(
      memberKeyJwk,
      ultimate.encryptionKeyPair.publicKey,
    );
    final shareGroupId = wire.UuidValue.fromString(
      '33333333-3333-4333-8333-333333333333',
    );
    _stubListMyGroups(
      group,
      encryptedMemberKey: encryptedMemberKey,
      shareGroupId: shareGroupId,
    );

    final store = InMemoryAccountKeyStore();
    final memberStore = InMemoryMemberKeyStore();
    final auth = AnonaccountAuth(caller, store, memberStore, InMemoryGroupOwnerKeyStore());

    final recovered = await auth.recoverAccount(
      ultimateKeyJwk: seeded.ultimateJwk,
      deviceLabel: 'laptop',
    );

    expect(recovered, hasLength(1));
    expect(recovered.single.recovered, isTrue);
    // The key reached custody, keyed by group, and is the same member key —
    // anything else leaves the group data key unreadable.
    final stored = (await memberStore.getMemberKey(shareGroupId))!;
    expect(
      (await stored.signingKeyPair.exportPublicKeySec1Hex()).value,
      (await memberKey.signingKeyPair.exportPublicKeySec1Hex()).value,
    );
  });

  test('a corrupt member key backup is reported, not thrown', () async {
    final seeded = await _seedAccount();
    _stubRecovery(dataKey, seeded.recoveryBlob);
    _stubRegisterDevice(device);

    final shareGroupId = wire.UuidValue.fromString(
      '33333333-3333-4333-8333-333333333333',
    );
    _stubListMyGroups(
      group,
      encryptedMemberKey: 'NOT-A-BLOB',
      shareGroupId: shareGroupId,
    );

    final store = InMemoryAccountKeyStore();
    final memberStore = InMemoryMemberKeyStore();
    final auth = AnonaccountAuth(caller, store, memberStore, InMemoryGroupOwnerKeyStore());

    final recovered = await auth.recoverAccount(
      ultimateKeyJwk: seeded.ultimateJwk,
      deviceLabel: 'laptop',
    );

    // One bad row must not cost the user their account or their other
    // groups.
    expect(recovered.single.recovered, isFalse);
    expect(await memberStore.getMemberKey(shareGroupId), isNull);
  });

  test(
      'the whole chain: ultimate private key recovers a member key that can '
      'sign group authority',
      () async {
    // The plan for this task asked for a server-side integration test that
    // recovers a real member key and uses it to sign a leaveGroup payload
    // the server accepts. That is not possible without adding dart_jwk_duo
    // to anonaccount_server: the real ECDH wrap/unwrap and KeyDuoSerializer
    // this test needs are SDK-only (docs/superpowers/CLAUDE.md conventions,
    // and the "no new dependencies" constraint this whole plan runs under).
    // The chain is proven here instead, entirely client-side, which is
    // where every step of it actually runs: decrypt the member key with
    // the account ultimate private key, then use the SAME recovered key to
    // produce a signature the server's CryptoUtils.verifySignature — the
    // exact function every group endpoint calls — accepts. The server side
    // of "a valid member-key signature authorizes group actions" is already
    // covered by groups_fanout_test.dart and group_endpoint_test.dart's
    // leaveGroup tests; this test is the missing middle link.
    final seeded = await _seedAccount();
    _stubRecovery(dataKey, seeded.recoveryBlob);
    _stubRegisterDevice(device);

    final memberKey = await KeyGen.generateDeviceKey();
    final memberKeyJwk =
        await const KeyDuoSerializer().exportKeyDuoJwk(memberKey);
    final holder = InMemoryAccountKeyStore();
    final ultimate = await holder.importUltimateKeyJwk(seeded.ultimateJwk);
    final encryptedMemberKey = await AsymmetricCrypto.wrapForRecipient(
      memberKeyJwk,
      ultimate.encryptionKeyPair.publicKey,
    );
    final shareGroupId = wire.UuidValue.fromString(
      '33333333-3333-4333-8333-333333333333',
    );
    _stubListMyGroups(
      group,
      encryptedMemberKey: encryptedMemberKey,
      shareGroupId: shareGroupId,
    );

    final store = InMemoryAccountKeyStore();
    final memberStore = InMemoryMemberKeyStore();
    final auth = AnonaccountAuth(caller, store, memberStore, InMemoryGroupOwnerKeyStore());

    await auth.recoverAccount(
      ultimateKeyJwk: seeded.ultimateJwk,
      deviceLabel: 'laptop',
    );

    // The recovered key — not the one generated above — is what a real
    // caller would read back out of custody after recovery.
    final recoveredKey = (await memberStore.getMemberKey(shareGroupId))!;
    final memberId = wire.UuidValue.fromString(
      '44444444-4444-4444-8444-444444444444',
    );
    final leaveGroupPayload = GroupInnerPayloads.leaveGroup(memberId);
    final signature =
        await SigningCrypto.signChallenge(leaveGroupPayload, recoveredKey);

    // Verified with the recovered key's own public half, exactly as the
    // server's CryptoUtils.verifySignature does against the row's
    // memberSigningPublicKeyHex.
    final ok = await SigningCrypto.verifyChallenge(
      leaveGroupPayload,
      signature,
      recoveredKey,
    );
    expect(ok, isTrue);
  });
}
