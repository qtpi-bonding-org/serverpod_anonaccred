import 'dart:async';

import '../auth/exceptions.dart';
import 'crypto_logger.dart';

/// Error recovery strategies for crypto operations
/// Provides retry logic and fallback mechanisms for common failure scenarios
class CryptoErrorRecovery {
  /// Maximum number of retry attempts for transient failures
  static const int maxRetries = 3;

  /// Base delay between retry attempts (exponential backoff)
  static const Duration baseRetryDelay = Duration(milliseconds: 500);

  /// Execute an operation with retry logic for transient failures
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    String? operationName,
    int maxAttempts = maxRetries,
    Duration baseDelay = baseRetryDelay,
    bool Function(Object error)? shouldRetry,
  }) async {
    final opName = operationName ?? 'crypto operation';
    Object? lastError;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        CryptoLogger.logOperationStart(
          '$opName (attempt $attempt/$maxAttempts)',
        );
        final result = await operation();

        if (attempt > 1) {
          CryptoLogger.logSuccess('$opName succeeded after $attempt attempts');
        }

        return result;
      } catch (error, stackTrace) {
        lastError = error;

        // Check if we should retry this error
        final canRetry =
            shouldRetry?.call(error) ?? _defaultShouldRetry(error);

        if (attempt < maxAttempts && canRetry) {
          final delay = Duration(
            milliseconds: (baseDelay.inMilliseconds * (1 << (attempt - 1)))
                .round(),
          );

          CryptoLogger.logError(
            '$opName failed (attempt $attempt/$maxAttempts), retrying in ${delay.inMilliseconds}ms',
            error,
            stackTrace: stackTrace,
            metadata: {'attempt': attempt, 'maxAttempts': maxAttempts},
          );

          await Future<void>.delayed(delay);
        } else {
          CryptoLogger.logError(
            '$opName failed permanently after $attempt attempts',
            error,
            stackTrace: stackTrace,
            metadata: {'finalAttempt': attempt, 'maxAttempts': maxAttempts},
          );
          break;
        }
      }
    }

    // All retries exhausted, throw the last error
    throw lastError ??
        Exception('Operation failed after $maxAttempts attempts');
  }

  /// Execute an operation with timeout and retry logic
  static Future<T> withTimeoutAndRetry<T>(
    Future<T> Function() operation, {
    Duration timeout = const Duration(seconds: 30),
    String? operationName,
    int maxAttempts = maxRetries,
  }) async {
    return withRetry(
      () => operation().timeout(timeout),
      operationName: operationName,
      maxAttempts: maxAttempts,
      shouldRetry: (error) =>
          _defaultShouldRetry(error) || error is TimeoutException,
    );
  }

  /// Execute an operation with circuit breaker pattern
  static Future<T> withCircuitBreaker<T>(
    Future<T> Function() operation, {
    String? operationName,
    Duration circuitBreakerTimeout = const Duration(minutes: 5),
  }) async {
    // Simple circuit breaker implementation
    // In a production app, you'd want a more sophisticated implementation

    try {
      return await operation().timeout(circuitBreakerTimeout);
    } catch (error) {
      if (error is TimeoutException) {
        CryptoLogger.logError(
          'Circuit breaker opened for ${operationName ?? 'operation'}',
          error,
          metadata: {'timeout': circuitBreakerTimeout.inMilliseconds},
        );
        throw NetworkException(
          'Operation timed out after ${circuitBreakerTimeout.inSeconds} seconds',
        );
      }
      rethrow;
    }
  }

  /// Default retry predicate.
  ///
  /// [NetworkException] and unknown/raw [Exception]s are treated as transient
  /// (retryable). All other [AnonaccountException] subclasses are non-retryable.
  static bool _defaultShouldRetry(Object error) {
    if (error is NetworkException) return true;
    if (error is AnonaccountException) return false;
    return true; // unknown/transient — retry
  }

  /// Graceful degradation for non-critical operations
  static Future<T?> withGracefulDegradation<T>(
    Future<T> Function() operation, {
    String? operationName,
    T? fallbackValue,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      CryptoLogger.logError(
        'Graceful degradation for ${operationName ?? 'operation'}',
        error,
        stackTrace: stackTrace,
        metadata: {'fallbackUsed': fallbackValue != null},
      );

      return fallbackValue;
    }
  }
}
