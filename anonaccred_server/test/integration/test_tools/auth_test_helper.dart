/// Helper for testing authentication scenarios
/// Since Serverpod test framework doesn't easily support mocking authentication,
/// we test authentication by verifying the expected behavior when endpoints
/// are called without proper authentication setup.
class AuthTestHelper {
  /// Generates a valid Ed25519 public key for testing
  /// Uses the same format as the working tests: exactly 64 hex characters
  static String generateValidDeviceKey() {
    return 'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';
  }
  
  /// Generates a valid Ed25519 signature for testing
  /// Uses exactly 128 hex characters as required by Ed25519
  static String generateValidSignature() {
    return 'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';
  }
}