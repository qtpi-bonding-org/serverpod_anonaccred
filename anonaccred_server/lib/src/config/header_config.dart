/// Configuration for AnonAccred header names
/// Allows customization of header names used for authentication and payments
class AnonAccredHeaderConfig {
  /// Default header prefix (can be overridden via environment variable)
  static const String _defaultPrefix = 'QUANITYA';
  
  /// Environment variable name for header prefix
  static const String _prefixEnvVar = 'ANONACCRED_HEADER_PREFIX';
  
  /// Get the configured header prefix
  static String get headerPrefix {
    const envPrefix = String.fromEnvironment(_prefixEnvVar);
    return envPrefix.isNotEmpty ? envPrefix : _defaultPrefix;
  }
  
  /// Get the device public key header name
  /// Format: X-{PREFIX}-DEVICE-PUBKEY
  static String get devicePubKeyHeader => 'X-$headerPrefix-DEVICE-PUBKEY';
  
  /// Get the device public key header name in lowercase
  static String get devicePubKeyHeaderLower => devicePubKeyHeader.toLowerCase();
  
  /// Get all possible variations of the device public key header
  /// Includes different case variations for compatibility
  static List<String> get devicePubKeyHeaderVariations => [
    devicePubKeyHeader,
    devicePubKeyHeaderLower,
    'x-$headerPrefix-device-pubkey',
    'X-${headerPrefix.toLowerCase()}-DEVICE-PUBKEY',
    'x-${headerPrefix.toLowerCase()}-device-pubkey',
  ];
  
  /// Get all possible variations of the Authorization header
  /// For Bearer token format: Authorization: Bearer `device_public_key`
  static List<String> get authorizationHeaderVariations => [
    'Authorization',
    'authorization',
  ];
  
  /// Get the payment header name (X402 standard)
  static String get paymentHeader => 'X-PAYMENT';
  
  /// Get all possible variations of the payment header
  static List<String> get paymentHeaderVariations => [
    'X-PAYMENT',
    'x-payment',
    'X-Payment',
  ];
  
  /// Validate configuration at startup
  static void validateConfiguration() {
    final prefix = headerPrefix;
    
    if (prefix.isEmpty) {
      throw ArgumentError('Header prefix cannot be empty');
    }
    
    if (prefix.contains(' ') || prefix.contains('-')) {
      throw ArgumentError('Header prefix cannot contain spaces or hyphens: $prefix');
    }
    
    // Configuration is valid - header names will be logged during server startup
  }
  
  /// Get header value from HTTP headers with case-insensitive matching
  static String? getHeaderValue(Map<String, List<String>> headers, List<String> headerVariations) {
    for (final variation in headerVariations) {
      final values = headers[variation];
      if (values != null && values.isNotEmpty) {
        return values.first;
      }
    }
    return null;
  }
  
  /// Check if any of the header variations exist
  static bool hasHeader(Map<String, List<String>> headers, List<String> headerVariations) =>
      headerVariations.any((variation) => headers.containsKey(variation));
}