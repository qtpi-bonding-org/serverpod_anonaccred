import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:dart_jwk_duo/dart_jwk_duo.dart' show GenerationService;
import 'package:test/test.dart';

void main() {
  test('the creator data-key copy unwraps with the creator member key', () async {
    // Simulates the exact wrap createGroup performs against the key it now
    // files in the MemberKeyStore.
    final memberKey = await KeyGen.generateDeviceKey();
    final dataKey = await GenerationService.generateSymmetricKey();
    final dataKeyJwk = await dataKey.toJwk();
    final groupKey = await KeyGen.generateUltimateKey();
    final groupSigningHex =
        (await groupKey.signingKeyPair.exportPublicKeySec1Hex()).value;
    final memberSigningHex =
        (await memberKey.signingKeyPair.exportPublicKeySec1Hex()).value;
    final wrapped = await AsymmetricCrypto.wrapForRecipient(
      dataKeyJwk,
      (await memberKey.encryptionKeyPair.exportPublicKeySec1Hex()).value,
      WrapContext.groupDataKeyForMember(
        groupSigningHex: groupSigningHex,
        memberSigningHex: memberSigningHex,
      ),
    );

    final recovered = await AsymmetricCrypto.unwrap(
      wrapped,
      memberKey,
      WrapContext.groupDataKeyForMember(
        groupSigningHex: groupSigningHex,
        memberSigningHex: memberSigningHex,
      ),
    );

    expect(recovered, dataKeyJwk);
  });
}
