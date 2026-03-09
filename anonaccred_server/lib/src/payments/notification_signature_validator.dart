import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';
import 'package:serverpod/serverpod.dart';

import 'package:anonaccount_server/anonaccount_server.dart';

import '../exception_factory.dart';

const String _appleJwksUrl = 'https://api.appstoreconnect.apple.com/v1/certs';
const Duration _jwksCacheExpiry = Duration(hours: 24);

class _ApplePublicKey {

  _ApplePublicKey({
    required this.kid,
    required this.kty,
    required this.use,
    required this.alg,
    required this.x,
    required this.y,
    required this.crv,
  });

  factory _ApplePublicKey.fromJson(Map<String, dynamic> json) => _ApplePublicKey(
      kid: json['kid'] as String,
      kty: json['kty'] as String,
      use: json['use'] as String,
      alg: json['alg'] as String,
      x: json['x'] as String,
      y: json['y'] as String,
      crv: json['crv'] as String? ?? 'P-256',
    );
  final String kid;
  final String kty;
  final String use;
  final String alg;
  final String x;
  final String y;
  final String crv;
}

class _JWKSCache {
  static List<_ApplePublicKey>? _keys;
  static DateTime? _lastFetched;

  static bool get isExpired {
    if (_keys == null || _lastFetched == null) return true;
    return DateTime.now().isAfter(_lastFetched!.add(_jwksCacheExpiry));
  }

  static void set(List<_ApplePublicKey> keys) {
    _keys = keys;
    _lastFetched = DateTime.now();
  }

  static List<_ApplePublicKey>? get() => _keys;
}

class NotificationSignatureValidator {
  static String? extractSignedPayload(String requestBody) {
    try {
      final decoded = jsonDecode(requestBody) as Map<String, dynamic>;
      return decoded['signedPayload'] as String?;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> validateSignature({required String signedPayload}) async {
    try {
      final parts = signedPayload.split('.');
      if (parts.length != 3) {
        return false;
      }

      final header = _decodeJWTHeader(parts[0]);
      if (header == null) {
        return false;
      }

      if (header['alg'] != 'ES256') {
        return false;
      }

      final keyId = header['kid'] as String?;
      if (keyId == null) {
        return false;
      }

      var keys = await _fetchJWKS();
      if (keys == null || keys.isEmpty) {
        return false;
      }

      var key = _findKeyById(keys, keyId);
      if (key == null) {
        // Key rotation: refresh JWKS once and retry
        refreshJWKS();
        keys = await _fetchJWKS();
        if (keys == null || keys.isEmpty) {
          return false;
        }
        key = _findKeyById(keys, keyId);
        if (key == null) {
          return false;
        }
      }

      return _verifyES256Signature(
        signedPayload: signedPayload,
        publicKey: key,
      );
    } catch (e) {
      return false;
    }
  }

  static _ApplePublicKey? _findKeyById(
    List<_ApplePublicKey> keys,
    String keyId,
  ) {
    for (final key in keys) {
      if (key.kid == keyId) {
        return key;
      }
    }
    return null;
  }

  static Future<List<_ApplePublicKey>?> _fetchJWKS() async {
    if (!_JWKSCache.isExpired) {
      return _JWKSCache.get();
    }

    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(_appleJwksUrl));
      request.headers.set('Accept', 'application/json');
      final response = await request.close();

      if (response.statusCode != 200) {
        return null;
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
      final keysList = decoded['keys'] as List<dynamic>;
      final keys = keysList
          .map((k) => _ApplePublicKey.fromJson(k as Map<String, dynamic>))
          .toList();

      _JWKSCache.set(keys);
      return keys;
    } catch (e) {
      return null;
    }
  }

  static bool _verifyES256Signature({
    required String signedPayload,
    required _ApplePublicKey publicKey,
  }) {
    try {
      final parts = signedPayload.split('.');
      final signingInput = '${parts[0]}.${parts[1]}';
      final signatureBytes = _base64UrlDecode(parts[2]);

      final publicKeyParams = _createPublicKey(publicKey);

      final signer = ECDSASigner(SHA256Digest())
        ..init(false, PublicKeyParameter<ECPublicKey>(publicKeyParams));

      final messageBytes = Uint8List.fromList(utf8.encode(signingInput));

      final r = BigInt.parse(
        _bytesToHex(signatureBytes.sublist(0, signatureBytes.length ~/ 2)),
        radix: 16,
      );
      final s = BigInt.parse(
        _bytesToHex(signatureBytes.sublist(signatureBytes.length ~/ 2)),
        radix: 16,
      );

      return signer.verifySignature(messageBytes, ECSignature(r, s));
    } catch (e) {
      return false;
    }
  }

  static ECPublicKey _createPublicKey(_ApplePublicKey key) {
    final x = _base64UrlDecodeBigInt(key.x);
    final y = _base64UrlDecodeBigInt(key.y);

    final curveName = key.crv == 'P-256' ? 'secp256r1' : key.crv;
    final curve = ECDomainParameters(curveName);
    final point = curve.curve.createPoint(x, y);

    return ECPublicKey(point, curve);
  }

  static BigInt _base64UrlDecodeBigInt(String input) {
    final normalized = input.replaceAll('-', '+').replaceAll('_', '/');
    final padded = normalized.padRight(
      normalized.length + (4 - normalized.length % 4) % 4,
      '=',
    );
    final bytes = base64Decode(padded);
    return BigInt.parse(_bytesToHex(bytes), radix: 16);
  }

  static String _bytesToHex(List<int> bytes) => bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  static List<int> _base64UrlDecode(String input) {
    final normalized = input.replaceAll('-', '+').replaceAll('_', '/');
    final padded = normalized.padRight(
      normalized.length + (4 - normalized.length % 4) % 4,
      '=',
    );
    return base64Decode(padded);
  }

  static Map<String, dynamic>? _decodeJWTHeader(String headerPart) {
    try {
      final normalized = base64Url.normalize(headerPart);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static void refreshJWKS() {
    _JWKSCache._keys = null;
    _JWKSCache._lastFetched = null;
  }

  static Future<void> validateSignatureOrThrow({
    required Session session,
    required String signedPayload,
  }) async {
    final isValid = await validateSignature(signedPayload: signedPayload);
    if (!isValid) {
      final payloadHash = sha256.convert(utf8.encode(signedPayload)).toString();
      final parts = signedPayload.split('.');
      final signature = parts.length == 3 ? parts[2] : 'invalid';

      session.log(
        'Apple notification signature validation failed - '
        'Timestamp: ${DateTime.now().toIso8601String()}, '
        'Signature: ${signature.substring(0, signature.length < 20 ? signature.length : 20)}..., '
        'PayloadHash: $payloadHash',
        level: LogLevel.warning,
      );

      throw AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.authInvalidSignature,
        message: 'Invalid Apple notification signature',
        details: {
          'error': 'Apple notification signature validation failed',
          'timestamp': DateTime.now().toIso8601String(),
          'payload_hash': payloadHash,
        },
      );
    }
  }
}
