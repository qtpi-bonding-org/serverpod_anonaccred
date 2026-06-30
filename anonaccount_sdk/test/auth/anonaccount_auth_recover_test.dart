import 'package:anonaccount_client/anonaccount_client.dart' as wire;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
// ignore: implementation_imports
import 'package:anonaccount_sdk/src/crypto/signing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeCaller extends Mock implements wire.Caller {}

void main() {
  test('recoverAccount produces fresh device key but reuses ultimate key',
      () async {
    final caller = _FakeCaller();

    // Generate a seed account and extract its ultimate key
    final seedStore = InMemoryAccountKeyStore();
    await seedStore.generateAccountKeys();
    final seedUltimateJwk = (await seedStore.getUltimateKeyJwkOnce())!;

    // Create auth with a fresh store and recover using the seed's ultimate key
    final recoveryStore = InMemoryAccountKeyStore();
    final auth = AnonaccountAuth(caller, recoveryStore);
    final createdAt = DateTime.utc(2026, 1, 1);
    final recovered = await auth.recoverAccount(
      ultimateKeyJwk: seedUltimateJwk,
      deviceLabel: 'd',
      createdAt: createdAt,
    );

    final p = recovered.payload;

    // structure
    expect(p.devicePublicKeyHex, hasLength(128));
    expect(p.ultimatePublicKeyHex, hasLength(128));
    expect(p.createdAt, createdAt);

    // signature verifies over the canonical signableData with the ultimate key
    final signable =
        '${p.devicePublicKeyHex}:${p.ultimatePublicKeyHex}:${p.recoveryBlob}:'
        '${p.deviceBlob}:${createdAt.toIso8601String()}';

    // Re-import the seed's ultimate key to verify signatures
    final verifyStore = InMemoryAccountKeyStore();
    final ultimate = await verifyStore.importUltimateKeyJwk(seedUltimateJwk);

    expect(await SigningCrypto.verifyChallenge(signable, p.signature, ultimate),
        isTrue);
    expect(
        await SigningCrypto.verifyChallenge(
            p.devicePublicKeyHex, p.deviceKeyAttestation, ultimate),
        isTrue);
  });

  test('recoverAccount throws InvalidUltimateKeyException on bad JWK', () async {
    final caller = _FakeCaller();
    final store = InMemoryAccountKeyStore();
    final auth = AnonaccountAuth(caller, store);
    await expectLater(
      auth.recoverAccount(
        ultimateKeyJwk: 'not-json',
        deviceLabel: 'x',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
      throwsA(isA<InvalidUltimateKeyException>()),
    );
  });
}
