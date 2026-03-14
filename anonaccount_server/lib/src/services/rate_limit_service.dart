import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Redis-based rate limiting service for public endpoints.
///
/// Features:
/// - Serverpod cache (Redis-backed) counter storage with TTL auto-cleanup
/// - Stores public key directly (no hashing - not PII)
/// - Fail-open on cache errors (allows request if cache down)
class RateLimitService {
  /// Check and increment rate limit counter.
  ///
  /// Returns true if within limit, false if exceeded.
  /// On Redis errors, returns true (fail-open) to avoid breaking the API.
  static Future<bool> checkAndIncrement(
    Session session,
    String endpointType,
    String publicKeyHex,
    int limitPerHour,
  ) async {
    try {
      final cacheKey = 'ratelimit:$endpointType:$publicKeyHex';
      final cache = session.caches.global;
      final counterData = await cache.get<RateLimitCounter>(cacheKey);
      final current = counterData?.count ?? 0;
      final newCount = current + 1;

      await cache.put(
        cacheKey,
        RateLimitCounter(count: newCount),
        lifetime: const Duration(hours: 1),
      );

      if (newCount > limitPerHour) {
        session.log(
          'Rate limit exceeded for $endpointType: $newCount/$limitPerHour (key: ${publicKeyHex.substring(0, 8)}...)',
          level: LogLevel.warning,
        );
        return false;
      }

      return true;
    } catch (e) {
      session.log(
        'Rate limit check failed (allowing request): $e',
        level: LogLevel.error,
      );
      return true;
    }
  }

  /// Get current rate limit status for a public key.
  static Future<RateLimitStatus> getStatus(
    Session session,
    String endpointType,
    String publicKeyHex,
    int limitPerHour,
  ) async {
    try {
      final cacheKey = 'ratelimit:$endpointType:$publicKeyHex';
      final cache = session.caches.global;
      final counterData = await cache.get<RateLimitCounter>(cacheKey);
      final current = counterData?.count ?? 0;

      return RateLimitStatus(
        current: current,
        limit: limitPerHour,
        remaining: limitPerHour - current,
      );
    } catch (e) {
      session.log(
        'Failed to get rate limit status: $e',
        level: LogLevel.error,
      );
      return RateLimitStatus(
        current: 0,
        limit: limitPerHour,
        remaining: limitPerHour,
      );
    }
  }
}

/// Typed rate limit status (internal use only).
class RateLimitStatus {
  final int current;
  final int limit;
  final int remaining;

  RateLimitStatus({
    required this.current,
    required this.limit,
    required this.remaining,
  });
}
