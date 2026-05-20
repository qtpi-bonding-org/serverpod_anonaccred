import 'dart:convert';
import 'package:anonaccount_sdk/src/crypto/hashcash.dart';
import 'package:crypto/crypto.dart';
import 'package:test/test.dart';

void main() {
  test('mint produces a stamp matching "1:difficulty:challenge:nonce"', () async {
    const challenge = 'abc-123';
    final stamp = await Hashcash.mint(challenge, difficulty: 8);
    final parts = stamp.split(':');
    expect(parts, hasLength(4));
    expect(parts[0], '1');
    expect(parts[1], '8');
    expect(parts[2], challenge);
    expect(int.tryParse(parts[3]), isNotNull);
  });

  test('mint stamp\'s SHA-1 has at least `difficulty` leading zero bits', () async {
    const challenge = 'zero-bits-check';
    const difficulty = 12;
    final stamp = await Hashcash.mint(challenge, difficulty: difficulty);
    final bytes = sha1.convert(utf8.encode(stamp)).bytes;
    // Count leading zero bits.
    var zeros = 0;
    for (final b in bytes) {
      if (b == 0) {
        zeros += 8;
        continue;
      }
      for (var mask = 0x80; mask > 0; mask >>= 1) {
        if ((b & mask) == 0) { zeros++; } else { mask = 0; break; }
      }
      break;
    }
    expect(zeros, greaterThanOrEqualTo(difficulty));
  });
}
