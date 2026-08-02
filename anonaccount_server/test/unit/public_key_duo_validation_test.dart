// anonaccount_server/test/unit/public_key_duo_validation_test.dart
import 'package:anonaccount_protocol/anonaccount_protocol.dart' hide Protocol;
import 'package:anonaccount_server/src/generated/authentication_exception.dart';
import 'package:anonaccount_server/src/helpers.dart';
import 'package:test/test.dart';
import '../test_helpers/signing_test_helper.dart';

void main() {
  late String keyA;
  late String keyB;

  setUp(() {
    // Positional record — see the note in Task 2.
    final (_, a) = SigningTestHelper.generateKeypair();
    final (_, b) = SigningTestHelper.generateKeypair();
    keyA = a;
    keyB = b;
  });

  test('accepts two distinct well-formed keys and returns them normalised',
      () {
    final duo = AnonAccountHelpers.validateKeyDuo(
      PublicKeyDuo(
        signingPublicKeyHex: keyA.toUpperCase(),
        encryptionPublicKeyHex: keyB,
      ),
      'test',
    );
    expect(duo.signingPublicKeyHex, keyA);
    expect(duo.encryptionPublicKeyHex, keyB);
  });

  test('rejects a duo whose two members are the same key', () {
    expect(
      () => AnonAccountHelpers.validateKeyDuo(
        PublicKeyDuo(
            signingPublicKeyHex: keyA, encryptionPublicKeyHex: keyA),
        'test',
      ),
      throwsA(isA<AuthenticationException>()),
    );
  });

  test('rejects members that are the same key differently cased', () {
    expect(
      () => AnonAccountHelpers.validateKeyDuo(
        PublicKeyDuo(
          signingPublicKeyHex: keyA,
          encryptionPublicKeyHex: keyA.toUpperCase(),
        ),
        'test',
      ),
      throwsA(isA<AuthenticationException>()),
    );
  });

  test('rejects a malformed member', () {
    expect(
      () => AnonAccountHelpers.validateKeyDuo(
        PublicKeyDuo(
            signingPublicKeyHex: 'nope', encryptionPublicKeyHex: keyB),
        'test',
      ),
      throwsA(isA<AuthenticationException>()),
    );
  });
}
