import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto_keys/crypto_keys.dart';

/// Test-only RS256 keypair + minimal in-memory JWKS server used to fake
/// Google's Pub/Sub push OIDC tokens without depending on Google's real
/// signing keys. Start once per test file via [certsUri]; it serves the
/// public key set GooglePubSubVerifier.certsUriOverride is pointed at.
class GoogleTestOidc {
  static final KeyPair _keyPair = KeyPair.generateRsa();

  /// Starting an HttpServer is inherently async, so unlike the plan
  /// sketch's synchronous getter, this is a cached Future — `await` it
  /// (repeated awaits after the first resolve immediately, and every
  /// caller gets the same loopback server instance).
  static Future<Uri>? _serverUriFuture;

  static Future<Uri> get certsUri => _serverUriFuture ??= _start();

  static Future<Uri> _start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final body = utf8.encode(jsonEncode({
      'keys': [_publicJwk()],
    }));
    server.listen((request) {
      request.response
        ..headers.contentType = ContentType.json
        ..add(body)
        ..close();
    });

    return Uri.parse('http://${server.address.host}:${server.port}/');
  }

  static Map<String, dynamic> _publicJwk() {
    final publicKey = _keyPair.publicKey! as RsaPublicKey;
    return {
      'kty': 'RSA',
      'use': 'sig',
      'alg': 'RS256',
      'kid': 'test-key-1',
      'n': _base64UrlEncodeBigInt(publicKey.modulus),
      'e': _base64UrlEncodeBigInt(publicKey.exponent),
    };
  }

  /// Signs a token whose `iat`/`exp` are relative to the real wall clock
  /// (`GooglePubSubVerifier` rejects tokens whose `exp` has passed, so a
  /// fixed historical timestamp would make every token here permanently
  /// expired). Pass [expiresIn] negative to mint an already-expired token
  /// for testing that rejection path.
  static String signToken({
    required String audience,
    Duration expiresIn = const Duration(hours: 1),
  }) {
    final header = {'alg': 'RS256', 'typ': 'JWT', 'kid': 'test-key-1'};
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expSeconds = nowSeconds + expiresIn.inSeconds;
    final payload = {
      'iss': 'https://accounts.google.com',
      'aud': audience,
      'email': 'test-pubsub@test.iam.gserviceaccount.com',
      'email_verified': true,
      'iat': nowSeconds,
      'exp': expSeconds,
    };
    final headerB64 = base64Url
        .encode(utf8.encode(jsonEncode(header)))
        .replaceAll('=', '');
    final payloadB64 = base64Url
        .encode(utf8.encode(jsonEncode(payload)))
        .replaceAll('=', '');
    final signingInput = '$headerB64.$payloadB64';
    final signer = _keyPair.privateKey!.createSigner(
      algorithms.signing.rsa.sha256,
    );
    final signature = signer.sign(utf8.encode(signingInput));
    final sigB64 = base64Url.encode(signature.data).replaceAll('=', '');
    return '$signingInput.$sigB64';
  }

  static String _base64UrlEncodeBigInt(BigInt value) =>
      base64Url.encode(_bigIntToBytes(value)).replaceAll('=', '');

  /// Minimal-length big-endian byte encoding — JWK's `n`/`e` fields must not
  /// carry a DER-style leading zero pad byte.
  static Uint8List _bigIntToBytes(BigInt value) {
    var hex = value.toRadixString(16);
    if (hex.length % 2 != 0) hex = '0$hex';
    final bytes = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return bytes;
  }
}
