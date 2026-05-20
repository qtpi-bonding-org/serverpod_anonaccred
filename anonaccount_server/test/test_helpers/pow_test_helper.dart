import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Hashcash proof-of-work helper for tests.
///
/// Generates valid PoW stamps matching the server's verification:
/// - Format: "1:difficulty:challenge:nonce"
/// - SHA-1 hash must have [difficulty] leading zero bits
/// - Default difficulty: 20 (~1M hashes, ~1-2 sec)
class PowTestHelper {
  /// Mine a valid hashcash stamp for the given challenge.
  ///
  /// This is the same algorithm used by the Flutter client's Hashcash.mint().
  static Future<String> mint(
    String challenge, {
    int difficulty = 20,
  }) async {
    final random = Random.secure();
    int nonce = random.nextInt(1 << 30);

    while (true) {
      final stamp = '1:$difficulty:$challenge:$nonce';
      final hash = sha1.convert(utf8.encode(stamp));

      if (_hasLeadingZeroBits(hash.bytes, difficulty)) {
        return stamp;
      }

      nonce++;

      // Yield to event loop every 1000 iterations
      if (nonce % 1000 == 0) {
        await Future.delayed(Duration.zero);
      }
    }
  }

  static bool _hasLeadingZeroBits(List<int> hashBytes, int requiredBits) {
    int zeroBits = 0;

    for (final byte in hashBytes) {
      if (byte == 0) {
        zeroBits += 8;
      } else {
        zeroBits += _countLeadingZeros(byte);
        break;
      }

      if (zeroBits >= requiredBits) {
        return true;
      }
    }

    return zeroBits >= requiredBits;
  }

  static int _countLeadingZeros(int byte) {
    if (byte == 0) return 8;

    int count = 0;
    int mask = 0x80;

    while ((byte & mask) == 0) {
      count++;
      mask >>= 1;
    }

    return count;
  }
}
