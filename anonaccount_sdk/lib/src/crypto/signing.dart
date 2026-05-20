import 'dart:convert';
import 'dart:typed_data';
import 'package:dart_jwk_duo/dart_jwk_duo.dart';

import '../auth/exceptions.dart';

/// ECDSA P-256 sign/verify against [KeyDuo.signingKeyPair]. Signatures
/// are returned as lowercase hex strings.
class SigningCrypto {
  const SigningCrypto._();

  static Future<String> signChallenge(String challenge, KeyDuo keyDuo) =>
      _signBytes(Uint8List.fromList(utf8.encode(challenge)), keyDuo);

  static Future<bool> verifyChallenge(
    String challenge,
    String sigHex,
    KeyDuo keyDuo,
  ) =>
      _verifyBytes(
        Uint8List.fromList(utf8.encode(challenge)),
        sigHex,
        keyDuo,
      );

  static Future<String> signBytes(Uint8List data, KeyDuo keyDuo) =>
      _signBytes(data, keyDuo);

  static Future<bool> verifyBytes(
    Uint8List data,
    String sigHex,
    KeyDuo keyDuo,
  ) =>
      _verifyBytes(data, sigHex, keyDuo);

  static Future<String> _signBytes(Uint8List data, KeyDuo keyDuo) async {
    try {
      final bytes = await keyDuo.signingKeyPair.signBytes(data);
      return bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
    } catch (e) {
      throw CryptoOperationException('SigningCrypto.sign failed: $e');
    }
  }

  static Future<bool> _verifyBytes(
    Uint8List data,
    String sigHex,
    KeyDuo keyDuo,
  ) async {
    try {
      final sig = Uint8List(sigHex.length ~/ 2);
      for (var i = 0; i < sig.length; i++) {
        sig[i] = int.parse(sigHex.substring(i * 2, i * 2 + 2), radix: 16);
      }
      // SigningKeyPair.verifyBytes(signature, data) — signature is first arg.
      return await keyDuo.signingKeyPair.verifyBytes(sig, data);
    } catch (e) {
      throw CryptoOperationException('SigningCrypto.verify failed: $e');
    }
  }
}
