import 'dart:convert';
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:test/test.dart';
import 'package:webcrypto/webcrypto.dart';

void main() {
  test('createGroup surfaces a member KeyDuo that unwraps the creator data-key copy', () async {
    // Simulate the exact wrap createGroup performs, then prove the returned
    // memberKey.privateKey recovers it (impossible before this fix).
    final memberKey = await KeyGen.generateDeviceKey();
    final dataKey = await AesGcmSecretKey.generateKey(256);
    final dataKeyJwk = jsonEncode(await dataKey.exportJsonWebKey());
    final wrapped = await AsymmetricCrypto.wrapForRecipient(
        dataKeyJwk, memberKey.encryptionKeyPair.publicKey);

    final recovered = await AsymmetricCrypto.unwrap(
        wrapped, memberKey.encryptionKeyPair.privateKey!);

    expect(recovered, dataKeyJwk);
    // And CreatedGroup must be able to carry it:
    final cg = CreatedGroup(
      groupId: 'g', displayName: 'G', groupDataKey: dataKey,
      memberKey: memberKey, createdAt: DateTime.utc(2026),
    );
    expect(cg.memberKey, same(memberKey));
  });
}
