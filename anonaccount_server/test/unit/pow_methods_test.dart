// Tests for AccountInnerPayloads builders. These mirror the wire strings
// signed by account/device endpoints and the client SDK, so any drift
// between server and client surfaces here as a string mismatch.
import 'package:anonaccount_protocol/anonaccount_protocol.dart' hide Protocol;
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:test/test.dart';

void main() {
  final duo = PublicKeyDuo(
    signingPublicKeyHex: '04${'a' * 128}',
    encryptionPublicKeyHex: '04${'b' * 128}',
  );

  test('registerDevice payload is domain-separated and covers both halves', () {
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

  test('grantMemberDevice payload covers the wrapped key', () {
    final memberId = UuidValue.fromString(
      '22222222-2222-4222-8222-222222222222',
    );
    final duo = PublicKeyDuo(
      signingPublicKeyHex: '04${'a' * 128}',
      encryptionPublicKeyHex: '04${'b' * 128}',
    );

    expect(
      GroupInnerPayloads.grantMemberDevice(memberId, duo, 'CIPHERTEXT'),
      'grantMemberDevice:$memberId:04${'a' * 128}:04${'b' * 128}:CIPHERTEXT',
    );
  });

  final acct = UuidValue.fromString('11111111-1111-4111-8111-111111111111');
  final other = UuidValue.fromString('22222222-2222-4222-8222-222222222222');

  test('setEncryptedMemberKey emits all four bound values', () {
    expect(
      GroupInnerPayloads.setEncryptedMemberKey('04gg', acct, '04aa', 'CT'),
      'setEncryptedMemberKey:04gg:$acct:04aa:CT',
    );
  });

  test('monitorGroupMembership formats the domain-separated payload', () {
    final payload = GroupInnerPayloads.monitorGroupMembership(acct);
    expect(
      payload,
      'monitorGroupMembership:11111111-1111-4111-8111-111111111111',
    );
  });

  test('setEncryptedUltimateKey emits the domain-separated payload', () {
    final account = UuidValue.fromString(
      '11111111-1111-4111-8111-111111111111',
    );
    expect(
      GroupInnerPayloads.setEncryptedUltimateKey('GROUP-ULT', account, 'BLOB'),
      'setEncryptedUltimateKey:GROUP-ULT:$account:BLOB',
    );
  });

  test('each bound field changes the signed message', () {
    final base = GroupInnerPayloads.setEncryptedMemberKey(
      '04gg',
      acct,
      '04aa',
      'CT',
    );
    // Group: stops an admin of two groups redirecting the invitee's tuple.
    expect(
      GroupInnerPayloads.setEncryptedMemberKey('04hh', acct, '04aa', 'CT'),
      isNot(base),
    );
    // Account: stops the blob being bound to someone else's membership.
    expect(
      GroupInnerPayloads.setEncryptedMemberKey('04gg', other, '04aa', 'CT'),
      isNot(base),
    );
    // Member key.
    expect(
      GroupInnerPayloads.setEncryptedMemberKey('04gg', acct, '04bb', 'CT'),
      isNot(base),
    );
    // Ciphertext: stops a relaying admin swapping the blob.
    expect(
      GroupInnerPayloads.setEncryptedMemberKey('04gg', acct, '04aa', 'XX'),
      isNot(base),
    );
  });
}
