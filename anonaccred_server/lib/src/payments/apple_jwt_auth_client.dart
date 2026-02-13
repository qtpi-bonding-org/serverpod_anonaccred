import 'dart:io';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../exception_factory.dart';

/// Handles JWT authentication using Apple private keys with ES256 algorithm.
/// Used to authenticate with the App Store Server API.
class AppleJWTAuthClient {
  final String privateKey;
  final String keyId;
  final String issuerId;
  final String bundleId;
  String? _cachedToken;
  DateTime? _tokenExpiry;

  /// Creates a new AppleJWTAuthClient instance.
  ///
  /// [privateKey] - The Apple private key for signing JWT tokens
  /// [keyId] - The key ID for the Apple private key
  /// [issuerId] - The issuer ID for App Store Connect API
  /// [bundleId] - The iOS application bundle identifier
  AppleJWTAuthClient({
    required this.privateKey,
    required this.keyId,
    required this.issuerId,
    required this.bundleId,
  });

  /// Load credentials from environment variables.
  /// Required: APPLE_PRIVATE_KEY, APPLE_KEY_ID, APPLE_ISSUER_ID, APPLE_BUNDLE_ID
  static AppleJWTAuthClient fromEnvironment() {
    final privateKey = Platform.environment['APPLE_PRIVATE_KEY'];
    final keyId = Platform.environment['APPLE_KEY_ID'];
    final issuerId = Platform.environment['APPLE_ISSUER_ID'];
    final bundleId = Platform.environment['APPLE_BUNDLE_ID'];

    if (privateKey == null ||
        privateKey.isEmpty ||
        keyId == null ||
        keyId.isEmpty ||
        issuerId == null ||
        issuerId.isEmpty ||
        bundleId == null ||
        bundleId.isEmpty) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.configurationMissing,
        message:
            'Missing Apple authentication credentials. Required: APPLE_PRIVATE_KEY, APPLE_KEY_ID, APPLE_ISSUER_ID, APPLE_BUNDLE_ID',
        details: {
          'APPLE_PRIVATE_KEY': privateKey == null ? 'missing' : 'set',
          'APPLE_KEY_ID': keyId == null ? 'missing' : 'set',
          'APPLE_ISSUER_ID': issuerId == null ? 'missing' : 'set',
          'APPLE_BUNDLE_ID': bundleId == null ? 'missing' : 'set',
        },
      );
    }

    return AppleJWTAuthClient(
      privateKey: privateKey,
      keyId: keyId,
      issuerId: issuerId,
      bundleId: bundleId,
    );
  }

  /// Get valid JWT token (cached or newly generated).
  /// Tokens are cached for 20 minutes to avoid unnecessary JWT generation.
  String getToken() {
    if (_cachedToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _cachedToken!;
    }
    return _generateToken();
  }

  /// Generate new JWT token with required claims.
  String _generateToken() {
    final now = DateTime.now();
    final expiry = now.add(const Duration(minutes: 20));

    // Create JWT using dart_jsonwebtoken package
    final jwt = JWT(
      {
        'iss': issuerId,
        'iat': now.millisecondsSinceEpoch ~/ 1000,
        'exp': expiry.millisecondsSinceEpoch ~/ 1000,
        'aud': 'appstoreconnect-v1',
        'bid': bundleId,
      },
      header: {
        'alg': 'ES256',
        'kid': keyId,
        'typ': 'JWT',
      },
    );

    // Sign with ES256 algorithm using the private key
    final token = jwt.sign(
      ECPrivateKey(privateKey),
      algorithm: JWTAlgorithm.ES256,
    );

    _cachedToken = token;
    _tokenExpiry = expiry;

    return token;
  }
}