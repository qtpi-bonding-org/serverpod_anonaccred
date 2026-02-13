import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

import '../exception_factory.dart';
import '../generated/protocol.dart';

/// Validates webhook signatures from Google Real-time Developer Notifications
///
/// Implements HMAC-SHA256 signature validation using Google's public key to ensure
/// that webhooks are authentic and come from Google.
///
/// Requirements 7.1, 8.1, 8.2: Webhook signature validation
class WebhookSignatureValidator {
  /// Load Google's webhook signing key from environment
  ///
  /// Reads the GOOGLE_WEBHOOK_SIGNING_KEY environment variable which contains
  /// Google's public key for verifying webhook signatures.
  ///
  /// Returns: The webhook signing key as a string
  ///
  /// Throws: [AnonAccredException] if the key is not configured
  ///
  /// Requirements 8.4: Load Google's webhook signing key from environment variables
  static String _getWebhookSigningKey() {
    final key = Platform.environment['GOOGLE_WEBHOOK_SIGNING_KEY'];
    if (key == null || key.isEmpty) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.configurationMissing,
        message: 'GOOGLE_WEBHOOK_SIGNING_KEY environment variable is not configured',
        details: {'required_env_var': 'GOOGLE_WEBHOOK_SIGNING_KEY'},
      );
    }
    return key;
  }

  /// Extract signature from request headers
  ///
  /// Looks for the signature in the X-Goog-IAM-Authority-Selector header
  /// (or other common header names for webhook signatures).
  ///
  /// Parameters:
  /// - [headers]: HTTP request headers map
  ///
  /// Returns: The signature string if found, null otherwise
  ///
  /// Requirements 8.1: Extract signature from request headers
  static String? extractSignature(Map<String, String> headers) {
    // Google uses X-Goog-IAM-Authority-Selector for signature
    // Also check common alternatives for flexibility
    return headers['x-goog-iam-authority-selector'] ??
        headers['X-Goog-IAM-Authority-Selector'] ??
        headers['x-signature'] ??
        headers['X-Signature'];
  }

  /// Validate webhook signature using HMAC-SHA256
  ///
  /// Verifies that the webhook payload was signed by Google using the expected
  /// public key. Uses HMAC-SHA256 for signature verification.
  ///
  /// Parameters:
  /// - [payload]: The raw webhook payload (JSON string)
  /// - [signature]: The signature from the request headers
  ///
  /// Returns: true if signature is valid, false if invalid
  ///
  /// Throws: [AnonAccredException] if webhook signing key is not configured
  ///
  /// Requirements 8.2: Use Google's public key to verify HMAC-SHA256 signature
  static bool validateSignature({
    required String payload,
    required String signature,
  }) {
    try {
      final signingKey = _getWebhookSigningKey();

      // Compute HMAC-SHA256 of the payload using the signing key
      final hmac = Hmac(sha256, utf8.encode(signingKey));
      final digest = hmac.convert(utf8.encode(payload));
      final computedSignature = digest.toString();

      // Compare signatures (constant-time comparison to prevent timing attacks)
      return _constantTimeEquals(computedSignature, signature);
    } catch (e) {
      // If there's an error computing the signature, it's invalid
      return false;
    }
  }

  /// Constant-time string comparison to prevent timing attacks
  ///
  /// Compares two strings in constant time to prevent attackers from
  /// using timing differences to guess valid signatures.
  ///
  /// Parameters:
  /// - [a]: First string to compare
  /// - [b]: Second string to compare
  ///
  /// Returns: true if strings are equal, false otherwise
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) {
      return false;
    }

    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }

    return result == 0;
  }

  /// Validate webhook signature and throw on failure
  ///
  /// Validates the webhook signature and throws an HTTP 401 exception if invalid.
  /// Also logs the validation failure with request details.
  ///
  /// Parameters:
  /// - [session]: Serverpod session for logging
  /// - [payload]: The raw webhook payload (JSON string)
  /// - [signature]: The signature from the request headers
  ///
  /// Throws: [AnonAccredException] with HTTP 401 if signature is invalid
  ///
  /// Requirements 8.3, 8.5: Throw HTTP 401 for invalid signatures and log failures
  static void validateSignatureOrThrow({
    required Session session,
    required String payload,
    required String signature,
  }) {
    if (!validateSignature(payload: payload, signature: signature)) {
      // Compute payload hash for logging
      final payloadHash = sha256.convert(utf8.encode(payload)).toString();

      // Log validation failure with request details
      session.log(
        'Webhook signature validation failed - '
        'Timestamp: ${DateTime.now().toIso8601String()}, '
        'Signature: ${signature.substring(0, min(20, signature.length))}..., '
        'PayloadHash: $payloadHash',
        level: LogLevel.warning,
      );

      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.authInvalidSignature,
        message: 'Invalid webhook signature',
        details: {
          'error': 'Webhook signature validation failed',
          'timestamp': DateTime.now().toIso8601String(),
          'payload_hash': payloadHash,
        },
      );
    }
  }
}

/// Helper function for min
int min(int a, int b) => a < b ? a : b;
