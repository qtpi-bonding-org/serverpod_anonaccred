import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Simple Hashcash proof-of-work implementation
/// 
/// Implements interactive Hashcash protocol to prevent spam
/// without requiring authentication or rate limiting.
/// 
/// Format: "1:difficulty:challenge:nonce"
/// Example: "1:20:a8f3-92xb-11k4:1234567890"
class Hashcash {
  /// Mine a Hashcash stamp for the given challenge
  /// 
  /// Finds a nonce such that SHA-1(stamp) has [difficulty] leading zero bits.
  /// 
  /// Parameters:
  /// - [challenge]: Unique challenge string from server
  /// - [difficulty]: Number of leading zero bits required (default: 20)
  /// 
  /// Returns: Complete stamp string "1:difficulty:challenge:nonce"
  /// 
  /// Difficulty guide:
  /// - 16 bits: ~65k hashes (~instant)
  /// - 20 bits: ~1M hashes (~1-2 seconds on mobile)
  /// - 24 bits: ~16M hashes (~15-30 seconds on mobile)
  static Future<String> mint(
    String challenge, {
    int difficulty = 20,
  }) async {
    final random = Random.secure();
    int nonce = random.nextInt(1 << 30); // Start from random position
    
    while (true) {
      final stamp = '1:$difficulty:$challenge:$nonce';
      final hash = sha1.convert(utf8.encode(stamp));
      
      if (_hasLeadingZeroBits(hash.bytes, difficulty)) {
        return stamp;
      }
      
      nonce++;
      
      // Yield to event loop every 1000 iterations
      if (nonce % 1000 == 0) {
        await Future<void>.delayed(Duration.zero);
      }
    }
  }
  
  /// Check if hash has required number of leading zero bits
  static bool _hasLeadingZeroBits(List<int> hashBytes, int requiredBits) {
    int zeroBits = 0;
    
    for (final byte in hashBytes) {
      if (byte == 0) {
        zeroBits += 8;
      } else {
        // Count leading zeros in this byte
        zeroBits += _countLeadingZeros(byte);
        break;
      }
      
      if (zeroBits >= requiredBits) {
        return true;
      }
    }
    
    return zeroBits >= requiredBits;
  }
  
  /// Count leading zero bits in a byte
  static int _countLeadingZeros(int byte) {
    if (byte == 0) return 8;
    
    int count = 0;
    int mask = 0x80; // 10000000
    
    while ((byte & mask) == 0) {
      count++;
      mask >>= 1;
    }
    
    return count;
  }
}
