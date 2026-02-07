/// Helper for testing authentication scenarios
/// Since Serverpod test framework doesn't easily support mocking authentication,
/// we test authentication by verifying the expected behavior when endpoints
/// are called without proper authentication setup.
class AuthTestHelper {
  /// Generates a valid ECDSA P-256 public key for testing
  /// Uses the correct format: exactly 128 hex characters
  static String generateValidDeviceKey() =>
      'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456'
      'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';
  
  /// Generates a valid ECDSA P-256 signature for testing
  /// Uses exactly 128 hex characters as required by ECDSA P-256
  static String generateValidSignature() =>
      'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456'
      'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';
}