import 'package:anonaccount_client/anonaccount_client.dart' as wire;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeCaller extends Mock implements wire.Caller {}

class _FakeEntrypoint extends Mock implements wire.EndpointEntrypoint {}

class _FakeDataKey extends Mock implements wire.EndpointDataKey {}

class _FakeDevice extends Mock implements wire.EndpointDevice {}

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
    ultimateHex: await ultimate.signingKeyPair.exportPublicKeyHex(),
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

void _stubRegisterDevice(_FakeDevice device) {
  when(() => device.registerDevice(
        challenge: any(named: 'challenge'),
        proofOfWork: any(named: 'proofOfWork'),
        signature: any(named: 'signature'),
        deviceKeyAttestation: any(named: 'deviceKeyAttestation'),
        ultimateSigningPublicKeyHex: any(named: 'ultimateSigningPublicKeyHex'),
        deviceSigningPublicKeyHex: any(named: 'deviceSigningPublicKeyHex'),
        encryptedDataKey: any(named: 'encryptedDataKey'),
        label: any(named: 'label'),
      )).thenAnswer((_) async => wire.AccountDevice(
        anonAccountId:
            wire.UuidValue.fromString('11111111-1111-4111-8111-111111111111'),
        deviceSigningPublicKeyHex: 'h' * 128,
        encryptedDataKey: 'wrapped',
        label: 'laptop',
        isRevoked: false,
        lastActive: DateTime.utc(2026, 8, 1),
      ));
}

void main() {
  late _FakeCaller caller;
  late _FakeEntrypoint entrypoint;
  late _FakeDataKey dataKey;
  late _FakeDevice device;

  setUp(() {
    caller = _FakeCaller();
    entrypoint = _FakeEntrypoint();
    dataKey = _FakeDataKey();
    device = _FakeDevice();
    when(() => caller.entrypoint).thenReturn(entrypoint);
    when(() => caller.dataKey).thenReturn(dataKey);
    when(() => caller.device).thenReturn(device);
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
    final auth = AnonaccountAuth(caller, store);

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
    final auth = AnonaccountAuth(caller, store);

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
          deviceSigningPublicKeyHex: newDeviceHex,
          encryptedDataKey: captureAny(named: 'encryptedDataKey'),
          label: 'laptop',
        )).captured;
    final attestation = captured[0] as String;
    final deviceBlob = captured[1] as String;

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

    // The ultimate key must have authorized this device key, or the server
    // rejects the registration.
    final verifier = InMemoryAccountKeyStore();
    final ultimate = await verifier.importUltimateKeyJwk(seeded.ultimateJwk);
    expect(
      await SigningCrypto.verifyChallenge(newDeviceHex, attestation, ultimate),
      isTrue,
    );
  });

  test('recoverAccount throws InvalidUltimateKeyException on bad JWK', () async {
    final store = InMemoryAccountKeyStore();
    final auth = AnonaccountAuth(caller, store);
    await expectLater(
      auth.recoverAccount(ultimateKeyJwk: 'not-json', deviceLabel: 'x'),
      throwsA(isA<InvalidUltimateKeyException>()),
    );
  });
}
