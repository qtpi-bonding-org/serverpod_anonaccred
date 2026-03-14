import 'package:serverpod/serverpod.dart';
import '../auth_handler.dart';
import '../exception_factory.dart';

/// Abstract base class for endpoints requiring device-key authentication.
///
/// Subclasses get:
/// - `requireLogin => true` (Serverpod enforces authentication)
/// - `getDevicePublicKey()` to extract the authenticated device's public key
/// - `getAccountId()` to extract the authenticated account's ID
///
/// Usage in consuming projects:
/// ```dart
/// class MyProtectedEndpoint extends AuthenticatedEndpoint {
///   Future<MyData> getData(Session session) async {
///     final deviceKey = getDevicePublicKey(session);
///     final accountId = getAccountId(session);
///     // ... business logic using authenticated identity
///   }
/// }
/// ```
abstract class AuthenticatedEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Extract the authenticated device's ECDSA P-256 public key from the session.
  ///
  /// Returns the 128-char hex public key set by [AnonAccountAuthHandler].
  /// Throws [AuthenticationException] if no device key is found.
  String getDevicePublicKey(Session session) {
    final key = AnonAccountAuthHandler.getDevicePublicKey(session);
    if (key.isEmpty) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authMissingKey,
        message: 'No device public key in authenticated session',
        operation: 'getDevicePublicKey',
      );
    }
    return key;
  }

  /// Extract the authenticated account's ID from the session.
  ///
  /// Returns the integer account ID set by [AnonAccountAuthHandler].
  /// Throws [AuthenticationException] if parsing fails.
  int getAccountId(Session session) {
    final idStr = session.authenticated?.userIdentifier;
    if (idStr == null) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.authMissingKey,
        message: 'No account ID in authenticated session',
        operation: 'getAccountId',
      );
    }
    return int.parse(idStr);
  }
}
