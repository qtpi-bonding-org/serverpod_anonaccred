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
      deviceSigningPublicKeyHex: 'h' * 128,
      encryptedDataKey: 'wrapped',
      label: 'iPhone',
      isRevoked: false,
      lastActive: DateTime.utc(2026, 5, 20),
    );
    when(() => dm.registerDeviceForAccount(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          publicKeyHex: any(named: 'publicKeyHex'),
          signature: any(named: 'signature'),
          newDeviceSigningPublicKeyHex: any(named: 'newDeviceSigningPublicKeyHex'),
          newDeviceEncryptedDataKey: any(named: 'newDeviceEncryptedDataKey'),
          label: any(named: 'label'),
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

    verify(() => dm.registerDeviceForAccount(
        challenge: 'CHAL-PAIR',
        proofOfWork: any(named: 'proofOfWork'),
        publicKeyHex: ourDeviceHex,
        signature: any(named: 'signature'),
        newDeviceSigningPublicKeyHex: theirHex,
        newDeviceEncryptedDataKey: any(named: 'newDeviceEncryptedDataKey'),
        label: 'iPhone')).called(1);
  });
}
