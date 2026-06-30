import 'package:anonaccount_client/anonaccount_client.dart' as wire;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// DevicePairingEvent is not exported by the SDK barrel — import directly.
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/device_pairing_event.dart'
    show DevicePairingEvent;

class _FakeCaller extends Mock implements wire.Caller {}
class _FakeEntrypoint extends Mock implements wire.EndpointEntrypoint {}
class _FakeDevice extends Mock implements wire.EndpointDevice {}

void main() {
  late _FakeCaller caller;
  late _FakeEntrypoint entrypoint;
  late _FakeDevice device;

  setUp(() {
    caller = _FakeCaller();
    entrypoint = _FakeEntrypoint();
    device = _FakeDevice();
    when(() => caller.entrypoint).thenReturn(entrypoint);
    when(() => caller.device).thenReturn(device);
    when(() => entrypoint.getChallenge()).thenAnswer(
      (_) async => wire.PublicChallengeResponse(
        challenge: 'CHAL-MON',
        difficulty: 4,
        expiresAt: 9999999999,
      ),
    );
  });

  DevicePairingEvent makeEvent(String blob) => DevicePairingEvent(
        encryptedDataKey: blob,
        signingKeyHex: 'h' * 128,
      );

  test('monitorRegistration yields wire encryptedDataKey events as strings', () async {
    when(() => device.monitorRegistration(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          signingKeyHex: any(named: 'signingKeyHex'),
        )).thenAnswer((_) => Stream.fromIterable([makeEvent('BLOB-A'), makeEvent('BLOB-B')]));

    final store = InMemoryAccountKeyStore();
    await store.generateAndStoreDeviceKey();
    final hex = (await store.getDeviceSigningPublicKeyHex())!;
    final pairing = AnonaccountPairing(caller, store, difficulty: 4);
    final values = await pairing.monitorRegistration(hex).toList();
    expect(values, ['BLOB-A', 'BLOB-B']);
  });

  test('yields a single emission when the server fires once', () async {
    when(() => device.monitorRegistration(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          signingKeyHex: any(named: 'signingKeyHex'),
        )).thenAnswer((_) => Stream.fromIterable([makeEvent('ONLY')]));

    final store = InMemoryAccountKeyStore();
    await store.generateAndStoreDeviceKey();
    final hex = (await store.getDeviceSigningPublicKeyHex())!;
    final pairing = AnonaccountPairing(caller, store, difficulty: 4);
    final v = await pairing.monitorRegistration(hex).first;
    expect(v, 'ONLY');
  });
}
