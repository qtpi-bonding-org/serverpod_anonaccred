import 'package:anonaccount_protocol/anonaccount_protocol.dart'
    show PublicKeyDuo;
import 'package:anonaccount_client/anonaccount_client.dart' as wire;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeCaller extends Mock implements wire.Caller {}
class _FakeEntrypoint extends Mock implements wire.EndpointEntrypoint {}
class _FakeDeviceManagement extends Mock implements wire.EndpointDeviceManagement {}

class _FakeUuid extends Fake implements wire.UuidValue {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeUuid());
    registerFallbackValue(
      PublicKeyDuo(
        signingPublicKeyHex: '04${'0' * 128}',
        encryptionPublicKeyHex: '04${'1' * 128}',
      ),
    );
  });

  late _FakeCaller caller;
  late _FakeEntrypoint entrypoint;
  late _FakeDeviceManagement dm;

  setUp(() {
    caller = _FakeCaller();
    entrypoint = _FakeEntrypoint();
    dm = _FakeDeviceManagement();
    when(() => caller.entrypoint).thenReturn(entrypoint);
    when(() => caller.deviceManagement).thenReturn(dm);
    when(() => entrypoint.getChallenge()).thenAnswer(
      (_) async => wire.PublicChallengeResponse(
        challenge: 'CHAL-PAIR',
        difficulty: 4,
        expiresAt: 9999999999,
      ),
    );
  });

  test('registerPairedDevice wraps our symmetric key + calls deviceManagement', () async {
    final stubResponse = AccountDevice(
      anonAccountId: wire.UuidValue.fromString('11111111-1111-4111-8111-111111111111'),
      deviceSigningPublicKeyHex: '04${'h' * 128}',
      deviceEncryptionPublicKeyHex: '04${'i' * 128}',
      encryptedDataKey: 'wrapped',
      label: 'iPhone',
      addedByAttestorPublicKeyHex: '04${'j' * 128}',
      addedByAttestation: 'test-attestation',
      isRevoked: false,
      lastActive: DateTime.utc(2026, 5, 20),
    );
    when(() => dm.registerDeviceForAccount(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          publicKeyHex: any(named: 'publicKeyHex'),
          signature: any(named: 'signature'),
          newDeviceKeys: any(named: 'newDeviceKeys'),
          pairingAttestation: any(named: 'pairingAttestation'),
          newDeviceEncryptedDataKey: any(named: 'newDeviceEncryptedDataKey'),
          label: any(named: 'label'),
          ultimateEncryptionPublicKeyHex:
              any(named: 'ultimateEncryptionPublicKeyHex'),
          ultimateSigningPublicKeyHex:
              any(named: 'ultimateSigningPublicKeyHex'),
        )).thenAnswer((_) async => stubResponse);

    final ourStore = InMemoryAccountKeyStore();
    await ourStore.generateAccountKeys();
    final ourDeviceHex = (await ourStore.getDeviceSigningPublicKeyHex())!;

    final theirStore = InMemoryAccountKeyStore();
    final theirPairing = AnonaccountPairing(_FakeCaller(), theirStore);
    final theirQr = await theirPairing.beginPairing(deviceLabel: 'their-device');
    final theirHex = theirQr.signingPubkeyHex;

    final pairing = AnonaccountPairing(caller, ourStore, difficulty: 4);
    final scanned = pairing.parseQr(theirQr.qrPayloadJson);
    final result = await pairing.registerPairedDevice(
      scanned: scanned,
      label: 'iPhone',
    );
    expect(result, stubResponse);

    final captured = verify(() => dm.registerDeviceForAccount(
        challenge: 'CHAL-PAIR',
        proofOfWork: any(named: 'proofOfWork'),
        publicKeyHex: ourDeviceHex,
        signature: any(named: 'signature'),
        newDeviceKeys: captureAny(named: 'newDeviceKeys'),
        pairingAttestation: any(named: 'pairingAttestation'),
        newDeviceEncryptedDataKey: any(named: 'newDeviceEncryptedDataKey'),
        label: 'iPhone',
        ultimateEncryptionPublicKeyHex:
            any(named: 'ultimateEncryptionPublicKeyHex'),
        ultimateSigningPublicKeyHex:
            any(named: 'ultimateSigningPublicKeyHex'))).captured;
    final capturedKeys = captured.single as PublicKeyDuo;
    expect(capturedKeys.signingPublicKeyHex, theirHex);
    expect(
      capturedKeys.signingPublicKeyHex,
      isNot(capturedKeys.encryptionPublicKeyHex),
    );
  });

  test('registerPairedDevice throws StateError when our store has no ultimate keys',
      () async {
    when(() => dm.registerDeviceForAccount(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          publicKeyHex: any(named: 'publicKeyHex'),
          signature: any(named: 'signature'),
          newDeviceKeys: any(named: 'newDeviceKeys'),
          pairingAttestation: any(named: 'pairingAttestation'),
          newDeviceEncryptedDataKey: any(named: 'newDeviceEncryptedDataKey'),
          label: any(named: 'label'),
          ultimateEncryptionPublicKeyHex:
              any(named: 'ultimateEncryptionPublicKeyHex'),
          ultimateSigningPublicKeyHex:
              any(named: 'ultimateSigningPublicKeyHex'),
        )).thenAnswer((_) async => throw StateError('should not be reached'));

    // A device that only paired, never generated or imported an ultimate
    // key — the shape Side A takes when it is itself a paired-in device
    // whose own pairing predates this feature.
    final ourStore = InMemoryAccountKeyStore();
    await ourStore.generateAndStoreDeviceKey();
    await ourStore.storeSymmetricDataKeyJwk(await KeyGen.generateSymmetricKeyJwk());

    final theirStore = InMemoryAccountKeyStore();
    final theirPairing = AnonaccountPairing(_FakeCaller(), theirStore);
    final theirQr = await theirPairing.beginPairing(deviceLabel: 'their-device');

    final pairing = AnonaccountPairing(caller, ourStore, difficulty: 4);
    final scanned = pairing.parseQr(theirQr.qrPayloadJson);

    await expectLater(
      pairing.registerPairedDevice(scanned: scanned, label: 'iPhone'),
      throwsA(isA<StateError>()),
    );
  });
}
