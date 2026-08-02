// anonaccount_server/test/unit/key_format_test.dart
import 'package:anonaccount_server/src/key_format.dart';
import '../test_helpers/signing_test_helper.dart';
import 'package:test/test.dart';

// A real P-256 point, SEC1 uncompressed, 130 hex.
const _validKey =
    '04'
    'b1f3a4c9e2d80f6a5b4c3d2e1f00998877665544332211aabbccddeeff001122'
    '3344556677889900aabbccddeeff112233445566778899aabbccddeeff001122';

void main() {
  group('PublicKeyFormat.normalize', () {
    test('accepts a 130-char lowercase SEC1 key unchanged', () {
      expect(PublicKeyFormat.normalize(_validKey), _validKey);
    });

    test('lowercases uppercase input so equal keys compare equal', () {
      expect(PublicKeyFormat.normalize(_validKey.toUpperCase()), _validKey);
    });

    test('rejects the legacy bare 128-hex form', () {
      expect(() => PublicKeyFormat.normalize(_validKey.substring(2)),
          throwsA(isA<FormatException>()));
    });

    test('rejects a 130-char string with a non-04 tag', () {
      expect(() => PublicKeyFormat.normalize('02${_validKey.substring(2)}'),
          throwsA(isA<FormatException>()));
    });

    test('rejects non-hex characters', () {
      expect(() => PublicKeyFormat.normalize('zz${_validKey.substring(2)}'),
          throwsA(isA<FormatException>()));
    });

    test('rejects the empty string', () {
      expect(() => PublicKeyFormat.normalize(''),
          throwsA(isA<FormatException>()));
    });
  });

  group('test fixtures', () {
    test('generateKeypair emits SEC1 130-hex accepted by the codec', () {
      final (_, publicKeyHex) = SigningTestHelper.generateKeypair();
      expect(publicKeyHex, hasLength(130));
      expect(PublicKeyFormat.isValid(publicKeyHex), isTrue);
    });

    test('testPublicKeyHex is a valid SEC1 key', () {
      expect(PublicKeyFormat.isValid(SigningTestHelper.testPublicKeyHex),
          isTrue);
    });
  });
}
