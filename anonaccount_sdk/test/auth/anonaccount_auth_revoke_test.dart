// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/client.dart'
    show Caller, EndpointEntrypoint, EndpointDeviceManagement;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/public_challenge_response.dart'
    show PublicChallengeResponse;
import 'package:anonaccount_client/anonaccount_client.dart' show UuidValue;
import 'package:anonaccount_sdk/anonaccount_sdk.dart' show AnonaccountAuth, InMemoryAccountKeyStore;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeCaller extends Mock implements Caller {}

class _FakeEntrypoint extends Mock implements EndpointEntrypoint {}

class _FakeDeviceManagement extends Mock implements EndpointDeviceManagement {}

class _FakeUuid extends Fake implements UuidValue {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeUuid());
  });

  test('revokeDevice signs outer PoW with ultimate key and calls deviceManagement',
      () async {
    final caller = _FakeCaller();
    final entrypoint = _FakeEntrypoint();
    final deviceManagement = _FakeDeviceManagement();
    when(() => caller.entrypoint).thenReturn(entrypoint);
    when(() => caller.deviceManagement).thenReturn(deviceManagement);
    when(() => entrypoint.getChallenge()).thenAnswer(
      (_) async => PublicChallengeResponse(
        challenge: 'CHAL-REV',
        difficulty: 4,
        expiresAt: 9999999999,
      ),
    );
    when(() => deviceManagement.revokeDevice(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          publicKeyHex: any(named: 'publicKeyHex'),
          signature: any(named: 'signature'),
          deviceId: any(named: 'deviceId'),
        )).thenAnswer((_) async => true);

    // Generate a seed account and extract its ultimate key
    final seedStore = InMemoryAccountKeyStore();
    await seedStore.generateAccountKeys();
    final seedUltimateJwk = (await seedStore.getUltimateKeyJwkOnce())!;

    // Create auth with a fresh store
    final authStore = InMemoryAccountKeyStore();
    final auth = AnonaccountAuth(caller, authStore);
    final targetId =
        UuidValue.fromString('11111111-1111-4111-8111-111111111111');

    // Compute expected ultimateHex by importing into throwaway store
    final verifyStore = InMemoryAccountKeyStore();
    final ultimate = await verifyStore.importUltimateKeyJwk(seedUltimateJwk);
    final ultimateHex = await ultimate.signingKeyPair.exportPublicKeyHex();

    final ok = await auth.revokeDevice(
      deviceId: targetId,
      ultimateBackupJwk: seedUltimateJwk,
    );
    expect(ok, isTrue);

    verify(() => deviceManagement.revokeDevice(
          challenge: 'CHAL-REV',
          proofOfWork: any(named: 'proofOfWork'),
          publicKeyHex: ultimateHex,
          signature: any(named: 'signature'),
          deviceId: targetId,
        )).called(1);
  });
}
