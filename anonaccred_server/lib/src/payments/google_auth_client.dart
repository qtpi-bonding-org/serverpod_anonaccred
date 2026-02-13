import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';

import '../exception_factory.dart';

/// OAuth 2.0 service account authentication client for Google Play Developer API
///
/// Handles loading service account credentials from environment variables or files,
/// creating JWT tokens, and managing access token caching with expiration checking.
///
/// Requirements 1.1, 1.2, 1.3, 1.4, 1.5: OAuth 2.0 service account authentication
class GoogleAuthClient {
  final ServiceAccountCredentials credentials;
  AccessToken? _cachedToken;

  GoogleAuthClient({required this.credentials});

  /// Load credentials from environment variables or service account file
  ///
  /// Supports two configuration methods:
  /// 1. GOOGLE_SERVICE_ACCOUNT_JSON: Full service account JSON as environment variable
  /// 2. GOOGLE_SERVICE_ACCOUNT_PATH: Path to service account JSON file
  ///
  /// Throws AnonAccredException with configurationMissing code if neither is configured.
  ///
  /// Requirements 1.1: Load credentials from environment or file
  static Future<GoogleAuthClient> fromEnvironment() async {
    final jsonString = Platform.environment['GOOGLE_SERVICE_ACCOUNT_JSON'];
    final filePath = Platform.environment['GOOGLE_SERVICE_ACCOUNT_PATH'];

    String? credentialsJson;

    if (jsonString != null && jsonString.isNotEmpty) {
      credentialsJson = jsonString;
    } else if (filePath != null && filePath.isNotEmpty) {
      try {
        final file = File(filePath);
        credentialsJson = await file.readAsString();
      } catch (e) {
        throw AnonAccredExceptionFactory.createException(
          code: AnonAccredErrorCodes.configurationMissing,
          message: 'Failed to read Google service account file: $filePath',
          details: {
            'filePath': filePath,
            'error': e.toString(),
          },
        );
      }
    }

    if (credentialsJson == null || credentialsJson.isEmpty) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.configurationMissing,
        message: 'Google service account credentials not configured',
        details: {
          'requiredConfig':
              'GOOGLE_SERVICE_ACCOUNT_JSON or GOOGLE_SERVICE_ACCOUNT_PATH',
          'hint':
              'Set GOOGLE_SERVICE_ACCOUNT_JSON to the full JSON string or GOOGLE_SERVICE_ACCOUNT_PATH to the file path',
        },
      );
    }

    try {
      final credentialsMap = jsonDecode(credentialsJson) as Map<String, dynamic>;
      final credentials = ServiceAccountCredentials.fromJson(credentialsMap);
      return GoogleAuthClient(credentials: credentials);
    } catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.configurationMissing,
        message: 'Invalid Google service account credentials format',
        details: {
          'error': e.toString(),
          'hint':
              'Ensure credentials are valid JSON with required fields: type, project_id, private_key_id, private_key, client_email, client_id, auth_uri, token_uri, auth_provider_x509_cert_url, client_x509_cert_url',
        },
      );
    }
  }

  /// Get valid access token with in-memory caching and expiration checking
  ///
  /// Returns a cached token if it exists and hasn't expired. Otherwise,
  /// refreshes the token using the JWT flow and caches the new token.
  ///
  /// Requirements 1.4: Cache tokens and check expiration
  Future<String> getAccessToken() async {
    if (_cachedToken != null && !_isExpired(_cachedToken!)) {
      return _cachedToken!.data;
    }
    return await _refreshToken();
  }

  /// Refresh access token using JWT flow with googleapis_auth
  ///
  /// Creates a JWT signed with the service account private key and exchanges it
  /// for an access token using the Google OAuth 2.0 token endpoint.
  /// Caches the token for future use.
  ///
  /// Requirements 1.2: Create JWT with required claims
  /// Requirements 1.3: Exchange JWT for access token
  /// Requirements 1.5: Handle token refresh errors
  Future<String> _refreshToken() async {
    try {
      // Use clientViaServiceAccount to obtain an authenticated HTTP client
      // This handles JWT creation, signing, and token exchange internally
      final authClient = await clientViaServiceAccount(
        credentials,
        ['https://www.googleapis.com/auth/androidpublisher'],
      );

      // Extract the access token from the authenticated client
      final accessToken = authClient.credentials.accessToken;
      _cachedToken = accessToken;

      // Close the client to clean up resources
      authClient.close();

      return accessToken.data;
    } catch (e) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.configurationMissing,
        message: 'Failed to refresh Google access token: ${e.toString()}',
        details: {
          'error': e.toString(),
          'hint': 'Verify service account credentials are valid and have access to Google Play Developer API',
        },
      );
    }
  }

  /// Check if access token has expired
  ///
  /// Tokens are considered expired if their expiry time is within 60 seconds
  /// of the current time to provide a safety margin for token usage.
  bool _isExpired(AccessToken token) {
    final expiryTime = token.expiry;

    // Consider expired if within 60 seconds of expiry
    final safetyMargin = const Duration(seconds: 60);
    return DateTime.now().add(safetyMargin).isAfter(expiryTime);
  }
}
