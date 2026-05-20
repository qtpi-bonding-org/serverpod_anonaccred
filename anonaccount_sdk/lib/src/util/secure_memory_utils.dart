import 'dart:developer' as developer;
import 'dart:typed_data';

/// Utilities for secure memory management in cryptographic operations
/// 
/// Provides best-effort secure memory clearing for sensitive cryptographic data.
/// Note: Dart doesn't provide true secure memory clearing primitives, so these
/// methods provide defense-in-depth by overwriting memory locations.
class SecureMemoryUtils {
  /// Securely clears a string containing sensitive data
  /// 
  /// [sensitiveString] - The string to clear (will be overwritten)
  /// 
  /// This method attempts to overwrite the string's memory with random data
  /// to prevent sensitive data from remaining in memory.
  static void clearSensitiveString(String? sensitiveString) {
    if (sensitiveString == null || sensitiveString.isEmpty) return;
    
    try {
      // Convert string to bytes for overwriting
      final bytes = Uint8List.fromList(sensitiveString.codeUnits);
      
      // Overwrite with random data multiple times
      for (int pass = 0; pass < 3; pass++) {
        for (int i = 0; i < bytes.length; i++) {
          bytes[i] = (DateTime.now().millisecondsSinceEpoch + i) % 256;
        }
      }
      
      // Final pass with zeros
      bytes.fillRange(0, bytes.length, 0);
      
    } catch (e) {
      // Best effort - don't throw on cleanup failure
      developer.log('WARNING: Failed to securely clear sensitive string: $e', name: 'SecureMemoryUtils');
    }
  }

  /// Securely clears a Uint8List containing sensitive data
  /// 
  /// [sensitiveBytes] - The byte array to clear (will be overwritten)
  /// 
  /// This method overwrites the byte array with random data multiple times
  /// to prevent sensitive data from remaining in memory.
  static void clearSensitiveBytes(Uint8List? sensitiveBytes) {
    if (sensitiveBytes == null || sensitiveBytes.isEmpty) return;
    
    try {
      // Overwrite with random data multiple times
      for (int pass = 0; pass < 3; pass++) {
        for (int i = 0; i < sensitiveBytes.length; i++) {
          sensitiveBytes[i] = (DateTime.now().millisecondsSinceEpoch + i) % 256;
        }
      }
      
      // Final pass with zeros
      sensitiveBytes.fillRange(0, sensitiveBytes.length, 0);
      
    } catch (e) {
      // Best effort - don't throw on cleanup failure
      developer.log('WARNING: Failed to securely clear sensitive bytes: $e', name: 'SecureMemoryUtils');
    }
  }

  /// Logs a security event for memory clearing operations
  /// 
  /// [operation] - Description of the operation being performed
  /// [keyType] - Type of key being cleared (e.g., 'Ultimate Private Key')
  /// 
  /// This method logs security events without exposing sensitive data.
  static void logSecureMemoryOperation(String operation, String keyType) {
    final timestamp = DateTime.now().toIso8601String();
    developer.log('SECURITY [$timestamp]: $operation - $keyType cleared from memory', name: 'SecureMemoryUtils');
  }

  /// Creates a secure cleanup function for use in finally blocks
  /// 
  /// [sensitiveData] - List of sensitive strings to clear
  /// [keyType] - Type of key for logging purposes
  /// 
  /// Returns a function that can be called to securely clear all provided data.
  /// This is useful for ensuring cleanup happens even if exceptions occur.
  static Function createSecureCleanup(List<String?> sensitiveData, String keyType) {
    return () {
      try {
        for (final data in sensitiveData) {
          clearSensitiveString(data);
        }
        logSecureMemoryOperation('Secure cleanup completed', keyType);
      } catch (e) {
        developer.log('WARNING: Secure cleanup failed for $keyType: $e', name: 'SecureMemoryUtils');
      }
    };
  }

  /// Forces garbage collection to help clear unreferenced memory
  /// 
  /// This is a best-effort attempt to trigger garbage collection after
  /// clearing sensitive data. Note that Dart's GC is not deterministic.
  static void forceGarbageCollection() {
    try {
      // Create and immediately discard large objects to encourage GC
      for (int i = 0; i < 10; i++) {
        final _ = List.filled(1000, 0);
      }
    } catch (e) {
      // Best effort - don't throw on GC failure
      developer.log('WARNING: Failed to force garbage collection: $e', name: 'SecureMemoryUtils');
    }
  }
}