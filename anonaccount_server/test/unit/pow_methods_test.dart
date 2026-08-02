// Tests for AccountInnerPayloads builders. These mirror the wire strings
// signed by account/device endpoints and the client SDK, so any drift
// between server and client surfaces here as a string mismatch.
import 'package:anonaccount_server/src/generated/protocol.dart';
import 'package:anonaccount_server/src/pow_methods.dart';
import 'package:test/test.dart';

void main() {
  final duo = PublicKeyDuo(
    signingPublicKeyHex: '04${'a' * 128}',
    encryptionPublicKeyHex: '04${'b' * 128}',
  );

  test('registerDevice payload is domain-separated and covers both halves',
      () {
    expect(
      AccountInnerPayloads.registerDevice(duo),
      'registerDevice:04${'a' * 128}:04${'b' * 128}',
    );
  });

  test('pairDevice payload is distinct from registerDevice', () {
    expect(
      AccountInnerPayloads.pairDevice(duo),
      isNot(AccountInnerPayloads.registerDevice(duo)),
    );
  });
}
