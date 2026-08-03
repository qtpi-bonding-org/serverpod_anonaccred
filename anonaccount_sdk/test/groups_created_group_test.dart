import 'dart:convert';
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:test/test.dart';
import 'package:webcrypto/webcrypto.dart';

void main() {
  test('the creator data-key copy unwraps with the creator member key', () async {
    // Simulates the exact wrap createGroup performs against the key it now
    // files in the MemberKeyStore.
    final memberKey = await KeyGen.generateDeviceKey();
    final dataKey = await AesGcmSecretKey.generateKey(256);
    final dataKeyJwk = jsonEncode(await dataKey.exportJsonWebKey());
    final wrapped = await AsymmetricCrypto.wrapForRecipient(
        dataKeyJwk, memberKey.encryptionKeyPair.publicKey);

    final recovered = await AsymmetricCrypto.unwrap(
        wrapped, memberKey.encryptionKeyPair.privateKey!);

    expect(recovered, dataKeyJwk);
  });
}
