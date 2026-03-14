import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import '../crypto_utils.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import 'rate_limit_service.dart';

/// Service for managing public endpoint challenges, proof-of-work, and rate limiting.
///
/// Provides hashcash PoW spam prevention for account creation and recovery:
/// 1. Hashcash proof-of-work for spam prevention
/// 2. ECDSA P-256 signature verification
/// 3. Redis-based rate limiting by public key (no IP tracking)
class PublicChallengeService {
  /// Challenge TTL (5 minutes)
  static const Duration challengeTTL = Duration(minutes: 5);

  /// Hashcash difficulty (20 leading zero bits)
  static const int hashcashDifficulty = 20;

  /// Default rate limit for account operations (requests per hour)
  static const int defaultRateLimit = 10;

  /// Generate a challenge for proof-of-work.
  ///
  /// Stores the challenge in the database with a 5-minute TTL.
  static Future<PublicChallengeResponse> generateChallenge(
    Session session,
  ) async {
    try {
      await _cleanupExpiredChallenges(session);

      // Generate random challenge (128-bit = 32 hex chars)
      final random = Random.secure();
      final bytes = List<int>.generate(16, (_) => random.nextInt(256));
      final challenge = bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();

      final expiresAt = DateTime.now().add(challengeTTL);

      await PublicChallenge.db.insertRow(
        session,
        PublicChallenge(
          challenge: challenge,
          expiresAt: expiresAt,
        ),
      );

      return PublicChallengeResponse(
        challenge: challenge,
        difficulty: hashcashDifficulty,
        expiresAt: expiresAt.millisecondsSinceEpoch ~/ 1000,
      );
    } catch (e) {
      if (e is AnonAccountException) rethrow;
      session.log(
        'Failed to generate challenge: $e',
        level: LogLevel.error,
      );
      throw AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.internalError,
        message: 'Challenge generation failed',
      );
    }
  }

  /// Verify proof-of-work, signature, and apply rate limiting.
  ///
  /// Performs all verification steps:
  /// 1. Validates public key format
  /// 2. Verifies proof-of-work solution
  /// 3. Verifies ECDSA signature
  /// 4. Checks and enforces rate limits
  static Future<void> verifyAndRateLimit(
    Session session,
    String challenge,
    String proofOfWork,
    String publicKeyHex,
    String signature,
    String payload,
  ) async {
    // 0. Validate public key format
    if (publicKeyHex.length != 128 ||
        !RegExp(r'^[0-9a-fA-F]+$').hasMatch(publicKeyHex)) {
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.cryptoInvalidPublicKey,
        message: 'Invalid public key format',
        operation: 'verifyAndRateLimit',
      );
    }

    // 1. Verify proof-of-work
    await _verifyProofOfWork(session, challenge, proofOfWork);

    // 2. Verify ECDSA signature
    await _verifySignature(publicKeyHex, signature, payload);

    // 3. Apply rate limiting
    await _applyRateLimit(session, publicKeyHex);
  }

  /// Clean up expired challenges from database.
  static Future<void> _cleanupExpiredChallenges(Session session) async {
    try {
      final now = DateTime.now();
      await PublicChallenge.db.deleteWhere(
        session,
        where: (t) => t.expiresAt < now,
      );
    } catch (e) {
      session.log(
        'Failed to cleanup expired challenges: $e',
        level: LogLevel.warning,
      );
    }
  }

  /// Verify proof-of-work solution.
  ///
  /// Checks stamp format, challenge existence, hash quality,
  /// and deletes challenge after use (one-time).
  static Future<void> _verifyProofOfWork(
    Session session,
    String challenge,
    String proofOfWork,
  ) async {
    try {
      final parts = proofOfWork.split(':');
      if (parts.length != 4) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.powInvalidStamp,
          message: 'Invalid stamp format',
          operation: 'verifyProofOfWork',
        );
      }

      final version = parts[0];
      final difficulty = int.tryParse(parts[1]);
      final stampChallenge = parts[2];

      if (version != '1') {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.powInvalidStamp,
          message: 'Unsupported Hashcash version',
          operation: 'verifyProofOfWork',
        );
      }

      if (difficulty == null || difficulty != hashcashDifficulty) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.powInvalidStamp,
          message: 'Difficulty must be $hashcashDifficulty',
          operation: 'verifyProofOfWork',
        );
      }

      if (stampChallenge != challenge) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.powInvalidStamp,
          message: 'Challenge mismatch',
          operation: 'verifyProofOfWork',
        );
      }

      // Check if challenge exists in database (not expired/used)
      final challengeRecord = await PublicChallenge.db.findFirstRow(
        session,
        where: (t) =>
            t.challenge.equals(challenge) & (t.expiresAt > DateTime.now()),
      );

      if (challengeRecord == null) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.powChallengeExpired,
          message: 'Challenge not found or expired',
          operation: 'verifyProofOfWork',
        );
      }

      // Verify hash has required leading zero bits
      final hash = sha1.convert(utf8.encode(proofOfWork));
      final hashHex = hash.toString();

      int zeroBits = 0;
      for (int i = 0; i < hashHex.length; i++) {
        final hexDigit = int.parse(hashHex[i], radix: 16);
        if (hexDigit == 0) {
          zeroBits += 4;
        } else {
          zeroBits += (4 - hexDigit.bitLength);
          break;
        }
      }

      if (zeroBits < hashcashDifficulty) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.powInsufficientWork,
          message: 'Insufficient PoW: $zeroBits < $hashcashDifficulty bits',
          operation: 'verifyProofOfWork',
        );
      }

      // Delete challenge (one-time use)
      await PublicChallenge.db.deleteWhere(
        session,
        where: (t) => t.challenge.equals(challenge),
      );
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.powVerificationFailed,
        message: 'PoW verification failed',
        operation: 'verifyProofOfWork',
      );
    }
  }

  /// Verify ECDSA P-256 signature.
  static Future<void> _verifySignature(
    String publicKeyHex,
    String signature,
    String payload,
  ) async {
    try {
      final isValid = await CryptoUtils.verifySignature(
        message: payload,
        signature: signature,
        publicKey: publicKeyHex,
      );

      if (!isValid) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.cryptoInvalidSignature,
          message: 'Invalid ECDSA signature',
          operation: 'verifySignature',
        );
      }
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.cryptoVerificationFailed,
        message: 'Signature verification failed',
        operation: 'verifySignature',
      );
    }
  }

  /// Apply rate limiting by public key.
  static Future<void> _applyRateLimit(
    Session session,
    String publicKeyHex,
  ) async {
    final allowed = await RateLimitService.checkAndIncrement(
      session,
      'account',
      publicKeyHex,
      defaultRateLimit,
    );

    if (!allowed) {
      final status = await RateLimitService.getStatus(
        session,
        'account',
        publicKeyHex,
        defaultRateLimit,
      );

      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.rateLimitExceeded,
        message: 'Rate limit: ${status.current}/${status.limit}',
        operation: 'applyRateLimit',
      );
    }
  }
}
