import 'dart:convert';
import 'package:anonaccount_client/anonaccount_client.dart' as wire;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
// ignore: implementation_imports
import 'package:anonaccount_sdk/src/crypto/asymmetric.dart';
// ignore: implementation_imports
import 'package:anonaccount_sdk/src/crypto/signing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeCaller extends Mock implements wire.Caller {}

void main() {
  test('createAccount builds a verifiable, structurally-correct payload', () async {
    final store = InMemoryAccountKeyStore();
    final auth = AnonaccountAuth(_FakeCaller(), store);
    final createdAt = DateTime.utc(2026, 1, 1, 12);

    final result = await auth.createAccount(
        deviceLabel: 'macbook', createdAt: createdAt);
    final p = result.payload;

    // structure
    expect(p.devicePublicKeyHex, hasLength(128));
    expect(p.ultimatePublicKeyHex, hasLength(128));
    expect(p.createdAt, createdAt);

    // signature verifies over the canonical signableData with the ultimate key
    final signable =
        '${p.devicePublicKeyHex}:${p.ultimatePublicKeyHex}:${p.recoveryBlob}:'
        '${p.deviceBlob}:${createdAt.toIso8601String()}';
    final ultimateJwk = (await store.getUltimateKeyJwkOnce())!;
    // re-import to verify (note: getUltimateKeyJwkOnce wiped the store copy)
    final verifyStore = InMemoryAccountKeyStore();
    final ultimate = await verifyStore.importUltimateKeyJwk(ultimateJwk);
    expect(await SigningCrypto.verifyChallenge(signable, p.signature, ultimate),
        isTrue);
    expect(
        await SigningCrypto.verifyChallenge(
            p.devicePublicKeyHex, p.deviceKeyAttestation, ultimate),
        isTrue);

    // deviceBlob unwraps to the symmetric key with the device private key
    final device = (await store.getDeviceKey())!;
    final unwrapped = await AsymmetricCrypto.unwrap(
        p.deviceBlob, device.encryptionKeyPair.privateKey!);
    expect(jsonDecode(unwrapped)['kty'], 'oct');
  });
}
