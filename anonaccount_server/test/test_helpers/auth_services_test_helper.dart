import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

/// Initializes AuthServices with test HMAC keys for integration tests.
///
/// Call this in a `setUpAll` before tests that call endpoints which
/// use `AuthServices.instance` (createAccount, signIn, revokeDevice).
void initializeTestAuthServices() {
  AuthServices.set(
    tokenManagerBuilders: [
      JwtConfig(
        algorithm: JwtAlgorithm.hmacSha512(
          SecretKey('test-hmac-key-for-integration-tests-must-be-long-enough'),
        ),
        refreshTokenHashPepper: 'test-pepper-for-integration-tests',
      ),
    ],
  );
}
