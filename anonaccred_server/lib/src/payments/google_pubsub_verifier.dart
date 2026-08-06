import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto_keys/crypto_keys.dart';

import 'package:anonaccount_server/anonaccount_server.dart';

const String _googleCertsUrl = 'https://www.googleapis.com/oauth2/v3/certs';

/// A single Google Play Real-time Developer Notification, decoded from the
/// base64 `message.data` payload of a Cloud Pub/Sub push envelope.
///
/// [subscriptionNotification], [oneTimeProductNotification], and
/// [voidedPurchaseNotification] are all nullable, rather than a sealed
/// variant type, because that mirrors how Google represents them on the
/// wire: a flat JSON object with one notification-type key per message,
/// not a tagged union. Modeling each as its own nullable field avoids an
/// untyped intermediate JSON decode at every call site.
class GoogleDeveloperNotification {
  GoogleDeveloperNotification({
    required this.packageName,
    required this.eventTimeMillis,
    this.subscriptionNotification,
    this.oneTimeProductNotification,
    this.voidedPurchaseNotification,
  });

  final String packageName;
  final String eventTimeMillis;
  final Map<String, dynamic>? subscriptionNotification;
  final Map<String, dynamic>? oneTimeProductNotification;
  final Map<String, dynamic>? voidedPurchaseNotification;

  factory GoogleDeveloperNotification.fromJson(Map<String, dynamic> json) =>
      GoogleDeveloperNotification(
        packageName: json['packageName'] as String,
        eventTimeMillis: json['eventTimeMillis'] as String,
        subscriptionNotification:
            json['subscriptionNotification'] as Map<String, dynamic>?,
        oneTimeProductNotification:
            json['oneTimeProductNotification'] as Map<String, dynamic>?,
        voidedPurchaseNotification:
            json['voidedPurchaseNotification'] as Map<String, dynamic>?,
      );
}

/// Verifies Google Play Real-time Developer Notifications, delivered as a
/// Cloud Pub/Sub push HTTP request authenticated by an OIDC bearer token
/// (RFC 7519 JWT, RS256) — not a shared-secret HMAC. See
/// `docs/key-model-conventions.md` deviation history for why the prior
/// implementation in this file's place was wrong about the transport.
class GooglePubSubVerifier {
  /// Test-only override for Google's public-certs endpoint.
  static Uri? certsUriOverride;

  static Future<GoogleDeveloperNotification> verifyAndDecode({
    required String authorizationHeader,
    required String requestBody,
    required String expectedAudience,
  }) async {
    final token = _extractBearerToken(authorizationHeader);
    if (token == null) {
      throw _invalid('Missing or malformed Authorization header');
    }
    await _verifyOidcToken(token, expectedAudience: expectedAudience);

    final envelope = jsonDecode(requestBody) as Map<String, dynamic>;
    final message = envelope['message'] as Map<String, dynamic>?;
    final data = message?['data'] as String?;
    if (data == null) {
      throw _invalid('Pub/Sub envelope missing message.data');
    }
    final decoded = utf8.decode(base64.decode(base64.normalize(data)));
    return GoogleDeveloperNotification.fromJson(
      jsonDecode(decoded) as Map<String, dynamic>,
    );
  }

  static String? _extractBearerToken(String header) {
    if (!header.startsWith('Bearer ')) return null;
    return header.substring('Bearer '.length);
  }

  static Future<void> _verifyOidcToken(
    String token, {
    required String expectedAudience,
  }) async {
    final parts = token.split('.');
    if (parts.length != 3) throw _invalid('Malformed OIDC token');

    final header =
        jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[0]))))
            as Map<String, dynamic>;
    final payload =
        jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))))
            as Map<String, dynamic>;

    if (payload['iss'] != 'https://accounts.google.com' &&
        payload['iss'] != 'accounts.google.com') {
      throw _invalid('Unexpected token issuer: ${payload['iss']}');
    }
    if (payload['aud'] != expectedAudience) {
      throw _invalid('Unexpected token audience: ${payload['aud']}');
    }

    final exp = payload['exp'];
    if (exp is! int) {
      throw _invalid('Missing or malformed exp claim');
    }
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (exp < nowSeconds) {
      throw _invalid('OIDC token has expired');
    }

    if (payload['email_verified'] != true) {
      throw _invalid('Token email_verified claim is not true');
    }

    final kid = header['kid'] as String?;
    final keys = await _fetchCerts();
    final key = keys[kid];
    if (key == null) throw _invalid('No matching signing key for kid: $kid');

    final signingInput = '${parts[0]}.${parts[1]}';
    final signatureBytes = base64Url.decode(base64Url.normalize(parts[2]));
    final verifier = key.createVerifier(algorithms.signing.rsa.sha256);
    final ok = verifier.verify(
      Uint8List.fromList(utf8.encode(signingInput)),
      Signature(Uint8List.fromList(signatureBytes)),
    );
    if (!ok) throw _invalid('OIDC token signature verification failed');
  }

  static const Duration _certsFetchTimeout = Duration(seconds: 10);

  static Future<Map<String, RsaPublicKey>> _fetchCerts() async {
    final client = HttpClient();
    try {
      final uri = certsUriOverride ?? Uri.parse(_googleCertsUrl);
      final request = await client.getUrl(uri).timeout(_certsFetchTimeout);
      final response = await request.close().timeout(_certsFetchTimeout);
      if (response.statusCode != 200) {
        throw _invalid(
          'Failed to fetch Google certs: HTTP ${response.statusCode}',
        );
      }
      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(_certsFetchTimeout);
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final keysList = decoded['keys'] as List<dynamic>;
      final result = <String, RsaPublicKey>{};
      for (final k in keysList) {
        final jwk = k as Map<String, dynamic>;
        final kid = jwk['kid'] as String;
        result[kid] = RsaPublicKey(
          modulus: _base64UrlToBigInt(jwk['n'] as String),
          exponent: _base64UrlToBigInt(jwk['e'] as String),
        );
      }
      return result;
    } finally {
      client.close();
    }
  }

  static BigInt _base64UrlToBigInt(String input) {
    final bytes = base64Url.decode(base64Url.normalize(input));
    if (bytes.isEmpty) return BigInt.zero;
    return bytes.fold(
      BigInt.zero,
      (acc, byte) => (acc << 8) | BigInt.from(byte),
    );
  }

  static AnonAccountException _invalid(String message) =>
      AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.authInvalidSignature,
        message: message,
      );
}
