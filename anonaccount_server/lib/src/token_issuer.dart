import 'package:serverpod/serverpod.dart';

/// Result of a successful token issuance.
class TokenResult {
  /// The access token (e.g., JWT) for authenticated requests.
  final String accessToken;

  /// The refresh token for obtaining new access tokens.
  final String? refreshToken;

  const TokenResult({required this.accessToken, this.refreshToken});
}

/// Callback type for issuing authentication tokens.
///
/// The host server provides this callback to decouple the anonaccount module
/// from any specific token implementation (JWT, opaque tokens, etc.).
///
/// Parameters:
/// - [session] The Serverpod session
/// - [accountId] The authenticated account's ID
/// - [devicePublicKeyHex] The device's ECDSA P-256 public key (128 hex chars)
///
/// Returns a [TokenResult] containing access and optional refresh tokens.
typedef TokenIssuer = Future<TokenResult> Function(
  Session session, {
  required int accountId,
  required String devicePublicKeyHex,
});

/// Registry for the token issuer callback.
///
/// The host server must call [AnonAccountTokenIssuer.configure] before
/// any sign-in attempts. Without a configured issuer, sign-in will fail.
class AnonAccountTokenIssuer {
  static TokenIssuer? _issuer;

  /// Configure the token issuer callback.
  ///
  /// Call this during server initialization, before starting the server.
  static void configure(TokenIssuer issuer) {
    _issuer = issuer;
  }

  /// Issue a token using the configured issuer.
  ///
  /// Throws [StateError] if no issuer has been configured.
  static Future<TokenResult> issueToken(
    Session session, {
    required int accountId,
    required String devicePublicKeyHex,
  }) async {
    final issuer = _issuer;
    if (issuer == null) {
      throw StateError(
        'AnonAccountTokenIssuer not configured. '
        'Call AnonAccountTokenIssuer.configure() during server initialization.',
      );
    }
    return await issuer(
      session,
      accountId: accountId,
      devicePublicKeyHex: devicePublicKeyHex,
    );
  }
}
