import 'package:serverpod/serverpod.dart';
import '../exception_factory.dart';

/// Abstract base class for JWT-protected endpoints.
///
/// Serverpod validates the JWT before the method runs.
/// Subclasses get:
/// - `requireLogin => true` (Serverpod enforces JWT validation)
/// - `getDevicePublicKey()` to extract the device's public key from JWT scopes
/// - `getAccountId()` to extract the account ID from JWT claims
///
/// Usage:
/// ```dart
/// class MyProtectedEndpoint extends JwtEndpoint {
///   Future<MyData> getData(Session session) async {
///     final accountId = getAccountId(session);
///     // ... business logic using authenticated identity
///   }
/// }
/// ```
abstract class JwtEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Extract the authenticated device's ECDSA P-256 public key from JWT scopes.
  ///
  /// Looks for a scope named `device:<publicKeyHex>` in the authenticated session.
  /// Throws [AuthenticationException] if no device key scope is found.
  @doNotGenerate
  String getDevicePublicKey(Session session) {
    if (session.authenticated?.scopes != null) {
      for (final scope in session.authenticated!.scopes) {
        final scopeName = scope.name;
        if (scopeName != null && scopeName.startsWith('device:')) {
          return scopeName.substring(7);
        }
      }
    }
    throw AnonAccountExceptionFactory.createAuthenticationException(
      code: AnonAccountErrorCodes.authMissingKey,
      message: 'No device public key in JWT session',
      operation: 'getDevicePublicKey',
    );
  }

  /// Extract the authenticated account's ID from JWT claims.
  ///
  /// Returns the integer account ID from the JWT's `authUserId`.
  /// Throws [AuthenticationException] if parsing fails.
  @doNotGenerate
  int getAccountId(Session session) {
    final idStr = session.authenticated?.userIdentifier;
    if (idStr == null) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authMissingKey,
        message: 'No account ID in JWT session',
        operation: 'getAccountId',
      );
    }
    return int.parse(idStr);
  }
}
