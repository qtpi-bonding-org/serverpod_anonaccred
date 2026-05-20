import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/public_challenge_service.dart';

/// Base endpoint with light hashcash protection.
///
/// Provides:
/// - `getChallenge()` to issue PoW puzzles
/// - `verifyHashcash()` to verify a solved puzzle (no signature, no rate limit)
/// - Configurable difficulty via [hashcashDifficulty]
///
/// Use for entrypoint endpoints that need spam prevention but don't
/// require identity verification (e.g., challenge issuance).
abstract class PowEndpoint extends Endpoint {
  @override
  bool get requireLogin => false;

  /// Hashcash difficulty for this endpoint.
  ///
  /// Override in subclasses to adjust difficulty.
  /// Defaults to the global difficulty from [PublicChallengeService].
  int get hashcashDifficulty => PublicChallengeService.hashcashDifficulty;

  /// Get challenge for proof-of-work.
  ///
  /// Returns a challenge string, difficulty, and expiration timestamp.
  /// Clients must solve the hashcash puzzle before calling protected methods.
  Future<PublicChallengeResponse> getChallenge(Session session) async {
    return await PublicChallengeService.generateChallenge(session);
  }

  /// Verify hashcash proof-of-work only (no signature, no rate limit).
  ///
  /// Checks stamp format, challenge existence, and hash quality.
  /// Consumes the challenge (one-time use).
  Future<void> verifyHashcash(
    Session session,
    String challenge,
    String proofOfWork,
  ) async {
    await PublicChallengeService.verifyProofOfWork(
      session,
      challenge,
      proofOfWork,
    );
  }
}
