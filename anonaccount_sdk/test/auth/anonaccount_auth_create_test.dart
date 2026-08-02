import 'dart:convert';
// ignore: implementation_imports
import 'package:anonaccount_client/src/pow_methods.dart'
    show AccountInnerPayloads;
import 'package:anonaccount_protocol/anonaccount_protocol.dart'
    show PublicKeyDuo;
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

    // structure — SEC1 uncompressed, 130 hex, signing and encryption
    // halves of a duo are always distinct.
    expect(p.devicePublicKeyHex, hasLength(130));
    expect(p.deviceEncryptionPublicKeyHex, hasLength(130));
    expect(p.devicePublicKeyHex, isNot(p.deviceEncryptionPublicKeyHex));
    expect(p.ultimatePublicKeyHex, hasLength(130));
    expect(p.ultimateEncryptionPublicKeyHex, hasLength(130));
    expect(p.ultimatePublicKeyHex, isNot(p.ultimateEncryptionPublicKeyHex));
    expect(p.createdAt, createdAt);

    // deviceKeyAttestation verifies over the duo-covering payload with the
    // ultimate key — matches the server's
    // AccountInnerPayloads.registerDevice(deviceKeys) verification.
    final ultimateJwk = (await store.getUltimateKeyJwkOnce())!;
    // re-import to verify (note: getUltimateKeyJwkOnce wiped the store copy)
    final verifyStore = InMemoryAccountKeyStore();
    final ultimate = await verifyStore.importUltimateKeyJwk(ultimateJwk);
    final devicePayload = AccountInnerPayloads.registerDevice(
      PublicKeyDuo(
        signingPublicKeyHex: p.devicePublicKeyHex,
        encryptionPublicKeyHex: p.deviceEncryptionPublicKeyHex,
      ),
    );
    expect(
      await SigningCrypto.verifyChallenge(
          devicePayload, p.deviceKeyAttestation, ultimate),
      isTrue,
    );

    // deviceBlob unwraps to the symmetric key with the device private key
    final device = (await store.getDeviceKey())!;
    final unwrapped = await AsymmetricCrypto.unwrap(
        p.deviceBlob, device.encryptionKeyPair.privateKey!);
    expect(jsonDecode(unwrapped)['kty'], 'oct');
  });
}
