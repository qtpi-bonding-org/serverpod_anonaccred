import 'package:anonaccount_client/anonaccount_client.dart' as wire;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:dart_jwk_duo/dart_jwk_duo.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeCaller extends Mock implements wire.Caller {}

class _FakeEntrypoint extends Mock implements wire.EndpointEntrypoint {}

void main() {
  test('recoverAccount produces fresh device key but reuses ultimate key',
      () async {
    final caller = _FakeCaller();
    when(() => caller.entrypoint).thenReturn(_FakeEntrypoint());

    final source = await KeyGen.generateAccountKeys();
    final ultimateJwkSet =
        await const KeyDuoSerializer().exportKeyDuo(source.ultimateKey);

    final auth = AnonaccountAuth(caller);
    final recovered = await auth.recoverAccount(
      ultimateKeyJwk: ultimateJwkSet,
      deviceLabel: 'NewMacBook',
    );

    final originalUltimateHex =
        await source.ultimateKey.signingKeyPair.exportPublicKeyHex();
    final recoveredUltimateHex =
        await recovered.keys.ultimateKey.signingKeyPair.exportPublicKeyHex();
    final originalDeviceHex =
        await source.deviceKey.signingKeyPair.exportPublicKeyHex();
    final recoveredDeviceHex =
        await recovered.keys.deviceKey.signingKeyPair.exportPublicKeyHex();

    expect(recoveredUltimateHex, originalUltimateHex);
    expect(recoveredDeviceHex, isNot(originalDeviceHex));
    expect(recovered.payload.devicePublicKeyHex, recoveredDeviceHex);
    expect(recovered.payload.ultimatePublicKeyHex, originalUltimateHex);
    expect(recovered.payload.recoveryBlob, isNotEmpty);
    expect(recovered.payload.deviceBlob, isNotEmpty);
    expect(recovered.payload.signature, isNotEmpty);
    expect(recovered.payload.deviceKeyAttestation, isNotEmpty);
  });

  test('recoverAccount throws InvalidUltimateKeyException on bad JWK', () async {
    final caller = _FakeCaller();
    when(() => caller.entrypoint).thenReturn(_FakeEntrypoint());
    final auth = AnonaccountAuth(caller);
    await expectLater(
      auth.recoverAccount(ultimateKeyJwk: 'not-json', deviceLabel: 'x'),
      throwsA(isA<InvalidUltimateKeyException>()),
    );
  });
}
