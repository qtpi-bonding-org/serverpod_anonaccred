import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/public_challenge_service.dart';
import 'pow_endpoint.dart';

/// Endpoint with full PoW + ECDSA signature verification + rate limiting.
///
/// Extends [PowEndpoint] to add:
/// - ECDSA P-256 signature verification (proves private key ownership)
/// - Per-public-key rate limiting (no IP tracking)
///
/// Subclasses call [verifySignedPow] at the top of each endpoint method.
///
/// Note: [getChallenge] throws — clients use [EntrypointEndpoint.getChallenge]
/// instead of per-endpoint challenges.
abstract class SignedPowEndpoint extends PowEndpoint {
  /// Throws — use [EntrypointEndpoint.getChallenge] instead.
  ///
  /// Overridden without `@doNotGenerate` so the generated client class gets a
  /// concrete implementation, satisfying the abstract [EndpointPow.getChallenge].
  @override
  Future<PublicChallengeResponse> getChallenge(Session session) async {
    throw UnsupportedError('Use EntrypointEndpoint.getChallenge() instead');
  }
  /// Endpoint type for rate limiting bucketing.
  ///
  /// Override in subclasses to separate rate limit counters per endpoint.
  /// Defaults to `'default'`.
  String get endpointType => 'default';

  /// Maximum requests allowed per hour per public key.
  ///
  /// Override in subclasses to set custom rate limits.
  /// Defaults to 10.
  int get rateLimitPerHour => 30;

  /// Verify PoW + ECDSA signature + rate limit.
  ///
  /// Call this at the top of each protected endpoint method.
  ///
  /// - [session] Serverpod session
  /// - [challenge] The challenge string from [getChallenge]
  /// - [proofOfWork] The hashcash stamp mined by the client
  /// - [publicKeyHex] The ECDSA P-256 public key (128 hex chars)
  /// - [signature] ECDSA signature over [payload]
  /// - [payload] The signed payload (typically `'$challenge:methodName:$publicKeyHex'`)
  Future<void> verifySignedPow(
    Session session,
    String challenge,
    String proofOfWork,
    String publicKeyHex,
    String signature,
    String payload,
  ) async {
    await PublicChallengeService.verifyAndRateLimit(
      session,
      challenge,
      proofOfWork,
      publicKeyHex,
      signature,
      payload,
      endpointType: endpointType,
      rateLimitPerHour: rateLimitPerHour,
    );
  }
}
