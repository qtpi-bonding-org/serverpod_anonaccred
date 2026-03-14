import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/public_challenge_service.dart';

/// Abstract base class for unauthenticated endpoints protected by
/// hashcash proof-of-work + ECDSA signature + rate limiting.
///
/// Subclasses get:
/// - `getChallenge()` endpoint method (auto-registered by Serverpod)
/// - `verifyPow()` helper to call at the top of each endpoint method
/// - Configurable rate limiting via `endpointType` and `rateLimitPerHour`
///
/// Usage in consuming projects:
/// ```dart
/// class MyPublicEndpoint extends PowProtectedEndpoint {
///   @override
///   String get endpointType => 'my_endpoint';
///
///   @override
///   int get rateLimitPerHour => 20;
///
///   Future<MyResponse> submitThing(
///     Session session, {
///     required String challenge,
///     required String proofOfWork,
///     required String signature,
///     required String publicKeyHex,
///     required String data,
///   }) async {
///     await verifyPow(session, challenge, proofOfWork, publicKeyHex,
///         signature, '$challenge:submitThing:$publicKeyHex');
///     // ... business logic
///   }
/// }
/// ```
abstract class PowProtectedEndpoint extends Endpoint {
  @override
  bool get requireLogin => false;

  /// Endpoint type for rate limiting bucketing (e.g., 'error_report', 'feedback').
  ///
  /// Override in subclasses to separate rate limit counters per endpoint.
  /// Defaults to `'default'`.
  String get endpointType => 'default';

  /// Maximum requests allowed per hour per public key.
  ///
  /// Override in subclasses to set custom rate limits.
  /// Defaults to 10.
  int get rateLimitPerHour => 10;

  /// Get challenge for proof-of-work.
  ///
  /// Returns a challenge string, difficulty, and expiration timestamp.
  /// Clients must solve the hashcash puzzle before calling PoW-protected methods.
  Future<PublicChallengeResponse> getChallenge(Session session) async {
    return await PublicChallengeService.generateChallenge(session);
  }

  /// Verify proof-of-work, ECDSA signature, and apply rate limiting.
  ///
  /// Call this at the top of each PoW-protected endpoint method.
  ///
  /// - [session] Serverpod session
  /// - [challenge] The challenge string from [getChallenge]
  /// - [proofOfWork] The hashcash stamp mined by the client
  /// - [publicKeyHex] The ECDSA P-256 public key (128 hex chars)
  /// - [signature] ECDSA signature over [payload]
  /// - [payload] The signed payload (typically `'$challenge:methodName:$publicKeyHex'`)
  Future<void> verifyPow(
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
