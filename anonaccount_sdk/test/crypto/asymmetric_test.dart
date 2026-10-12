import 'package:anonaccount_client/anonaccount_client.dart' show UuidValue;
import 'package:anonaccount_sdk/src/auth/exceptions.dart';
import 'package:anonaccount_sdk/src/crypto/asymmetric.dart';
import 'package:anonaccount_sdk/src/crypto/wrap_context.dart';
import 'package:dart_jwk_duo/dart_jwk_duo.dart';
import 'package:test/test.dart';

Future<String> _sigHex(KeyDuo k) async =>
    (await k.signingKeyPair.exportPublicKeySec1Hex()).value;
Future<String> _encHex(KeyDuo k) async =>
    (await k.encryptionKeyPair.exportPublicKeySec1Hex()).value;

void main() {
  late KeyDuo recipient;
  late KeyDuo other;
  late KeyDuo third;
  late String a, b, c;
  final m1 = UuidValue.fromString('11111111-1111-4111-8111-111111111111');
  final m2 = UuidValue.fromString('22222222-2222-4222-8222-222222222222');

  setUpAll(() async {
    recipient = await GenerationService.generateKeyDuo();
    other = await GenerationService.generateKeyDuo();
    third = await GenerationService.generateKeyDuo();
    a = await _sigHex(recipient);
    b = await _sigHex(other);
    c = await _sigHex(third);
  });
  tearDownAll(() {
    recipient.dispose();
    other.dispose();
    third.dispose();
  });

  List<(String, WrapContext)> contexts() => [
        ('accountDataKeyForUltimate',
            WrapContext.accountDataKeyForUltimate(ultimateSigningHex: a)),
        ('accountDataKeyForDevice',
            WrapContext.accountDataKeyForDevice(deviceSigningHex: a)),
        ('groupDataKeyForGroup',
            WrapContext.groupDataKeyForGroup(groupSigningHex: a)),
        ('groupDataKeyForMember',
            WrapContext.groupDataKeyForMember(
                groupSigningHex: a, memberSigningHex: b)),
        ('groupDataKeyForDevice',
            WrapContext.groupDataKeyForDevice(memberId: m1, deviceSigningHex: a)),
        ('memberKeyBackup',
            WrapContext.memberKeyBackup(groupSigningHex: a, memberSigningHex: b)),
        ('groupOwnerKeyBackup',
            WrapContext.groupOwnerKeyBackup(groupSigningHex: a)),
      ];

  test('a blob opens under its own context and under no other', () async {
    final enc = await _encHex(recipient);
    for (final (wName, w) in contexts()) {
      final blob = await AsymmetricCrypto.wrapForRecipient('secret', enc, w);
      for (final (uName, u) in contexts()) {
        if (wName == uName) {
          expect(await AsymmetricCrypto.unwrap(blob, recipient, u), 'secret',
              reason: wName);
        } else {
          await expectLater(
            AsymmetricCrypto.unwrap(blob, recipient, u),
            throwsA(isA<CryptoOperationException>()),
            reason: '$wName opened as $uName',
          );
        }
      }
    }
  });

  test('a member-key backup for group X does not open as group Y', () async {
    final blob = await AsymmetricCrypto.wrapForRecipient(
      'member-jwk',
      await _encHex(recipient),
      WrapContext.memberKeyBackup(groupSigningHex: a, memberSigningHex: c),
    );
    await expectLater(
      AsymmetricCrypto.unwrap(blob, recipient,
          WrapContext.memberKeyBackup(groupSigningHex: b, memberSigningHex: c)),
      throwsA(isA<CryptoOperationException>()),
    );
  });

  test('a device grant for member M1 does not open as member M2', () async {
    final blob = await AsymmetricCrypto.wrapForRecipient(
      'group-jwk',
      await _encHex(recipient),
      WrapContext.groupDataKeyForDevice(memberId: m1, deviceSigningHex: a),
    );
    await expectLater(
      AsymmetricCrypto.unwrap(blob, recipient,
          WrapContext.groupDataKeyForDevice(memberId: m2, deviceSigningHex: a)),
      throwsA(isA<CryptoOperationException>()),
    );
  });

  test('a group data key for member A does not open as member B', () async {
    final blob = await AsymmetricCrypto.wrapForRecipient(
      'group-jwk',
      await _encHex(recipient),
      WrapContext.groupDataKeyForMember(
          groupSigningHex: c, memberSigningHex: a),
    );
    await expectLater(
      AsymmetricCrypto.unwrap(blob, recipient,
          WrapContext.groupDataKeyForMember(
              groupSigningHex: c, memberSigningHex: b)),
      throwsA(isA<CryptoOperationException>()),
    );
  });

  test('unwrap with the wrong recipient key fails', () async {
    final ctx = WrapContext.groupOwnerKeyBackup(groupSigningHex: a);
    final blob = await AsymmetricCrypto.wrapForRecipient(
        'secret', await _encHex(recipient), ctx);
    await expectLater(
      AsymmetricCrypto.unwrap(blob, other, ctx),
      throwsA(isA<CryptoOperationException>()),
    );
  });

  test('a recipient hex that is not a P-256 point fails to wrap', () async {
    await expectLater(
      AsymmetricCrypto.wrapForRecipient('secret', '04${'0' * 128}',
          WrapContext.groupOwnerKeyBackup(groupSigningHex: a)),
      throwsA(isA<CryptoOperationException>()),
    );
  });
}
