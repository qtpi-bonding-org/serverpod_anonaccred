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
  /// Stores the challenge in Redis with TTL-based auto-expiry.
  static Future<PublicChallengeResponse> generateChallenge(
    Session session,
  ) async {
    try {
      // Generate random challenge (128-bit = 32 hex chars)
      final random = Random.secure();
      final bytes = List<int>.generate(16, (_) => random.nextInt(256));
      final challenge = bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();

      final expiresAt = DateTime.now().add(challengeTTL);

      // Store in Redis with TTL — auto-expires, no manual cleanup needed
      await session.caches.global.put(
        'pow_challenge:$challenge',
        ChallengeExists(exists: true),
        lifetime: challengeTTL,
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
    String payload, {
    String endpointType = 'account',
    int? rateLimitPerHour,
  }) async {
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
    await verifyProofOfWork(session, challenge, proofOfWork);

    // 2. Verify ECDSA signature
    await _verifySignature(publicKeyHex, signature, payload);

    // 3. Apply rate limiting
    await _applyRateLimit(
      session,
      publicKeyHex,
      endpointType: endpointType,
      limit: rateLimitPerHour ?? defaultRateLimit,
    );
  }

  /// Verify proof-of-work solution (hashcash only, no signature).
  ///
  /// Checks stamp format, challenge existence in Redis, hash quality,
  /// and removes challenge after use (one-time).
  ///
  /// Used directly by [PowEndpoint] for light hashcash protection.
  /// Used internally by [verifyAndRateLimit] for full PoW + signature.
  static Future<void> verifyProofOfWork(
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

      // Check if challenge exists in Redis (TTL handles expiry)
      final cacheKey = 'pow_challenge:$challenge';
      final challengeRecord =
          await session.caches.global.get<ChallengeExists>(cacheKey);

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

      // Remove challenge (one-time use)
      await session.caches.global.invalidateKey('pow_challenge:$challenge');
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
    String publicKeyHex, {
    String endpointType = 'account',
    int? limit,
  }) async {
    final effectiveLimit = limit ?? defaultRateLimit;
    final allowed = await RateLimitService.checkAndIncrement(
      session,
      endpointType,
      publicKeyHex,
      effectiveLimit,
    );

    if (!allowed) {
      final status = await RateLimitService.getStatus(
        session,
        endpointType,
        publicKeyHex,
        effectiveLimit,
      );

      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.rateLimitExceeded,
        message: 'Rate limit: ${status.current}/${status.limit}',
        operation: 'applyRateLimit',
      );
    }
  }
}
