import 'dart:developer' as developer;

/// Crypto-specific logger for security events and operations
/// Provides structured logging for crypto operations while avoiding sensitive data
class CryptoLogger {
  static const String _tag = 'CRYPTO';
  
  /// Log successful crypto operations
  static void logSuccess(String operation, {Map<String, dynamic>? metadata}) {
    final message = 'SUCCESS: $operation';
    developer.log(
      message,
      name: _tag,
      level: 800, // INFO level
      time: DateTime.now(),
    );
    
    if (metadata != null) {
      developer.log(
        'Metadata: ${_sanitizeMetadata(metadata)}',
        name: _tag,
        level: 800,
        time: DateTime.now(),
      );
    }
  }
  
  /// Log crypto operation failures
  static void logError(String operation, Object error, {StackTrace? stackTrace, Map<String, dynamic>? metadata}) {
    final message = 'ERROR: $operation - ${error.toString()}';
    developer.log(
      message,
      name: _tag,
      level: 1000, // SEVERE level
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );
    
    if (metadata != null) {
      developer.log(
        'Error metadata: ${_sanitizeMetadata(metadata)}',
        name: _tag,
        level: 1000,
        time: DateTime.now(),
      );
    }
  }
  
  /// Log security-related events
  static void logSecurityEvent(String event, {Map<String, dynamic>? metadata}) {
    final message = 'SECURITY: $event';
    developer.log(
      message,
      name: _tag,
      level: 900, // WARNING level
      time: DateTime.now(),
    );
    
    if (metadata != null) {
      developer.log(
        'Security metadata: ${_sanitizeMetadata(metadata)}',
        name: _tag,
        level: 900,
        time: DateTime.now(),
      );
    }
  }
  
  /// Log crypto operation start
  static void logOperationStart(String operation, {Map<String, dynamic>? metadata}) {
    final message = 'START: $operation';
    developer.log(
      message,
      name: _tag,
      level: 700, // CONFIG level
      time: DateTime.now(),
    );
    
    if (metadata != null) {
      developer.log(
        'Start metadata: ${_sanitizeMetadata(metadata)}',
        name: _tag,
        level: 700,
        time: DateTime.now(),
      );
    }
  }
  
  /// Sanitize metadata to remove sensitive information
  static Map<String, dynamic> _sanitizeMetadata(Map<String, dynamic> metadata) {
    final sanitized = <String, dynamic>{};
    
    for (final entry in metadata.entries) {
      final key = entry.key.toLowerCase();
      final value = entry.value;
      
      // Remove sensitive data
      if (_isSensitiveKey(key)) {
        sanitized[entry.key] = '[REDACTED]';
      } else if (value is String && value.length > 100) {
        // Truncate long strings that might contain sensitive data
        sanitized[entry.key] = '${value.substring(0, 50)}...[TRUNCATED]';
      } else {
        sanitized[entry.key] = value;
      }
    }
    
    return sanitized;
  }
  
  /// Check if a key contains sensitive information
  static bool _isSensitiveKey(String key) {
    const sensitiveKeys = [
      'key', 'private', 'secret', 'password', 'token', 'signature',
      'blob', 'encrypted', 'jwk', 'symmetric', 'ultimate', 'device'
    ];
    
    return sensitiveKeys.any((sensitive) => key.contains(sensitive));
  }
}