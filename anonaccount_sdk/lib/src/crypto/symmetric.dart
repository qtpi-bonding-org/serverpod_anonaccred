import 'dart:typed_data';

import 'package:dart_jwk_duo/dart_jwk_duo.dart' show CryptoService, SymmetricKey;

import '../auth/exceptions.dart';

/// AES-256-GCM through dart_jwk_duo. The blob layout (IV, ciphertext, tag)
/// is the library's; callers round-trip through this class and do not parse
/// the bytes.
class SymmetricCrypto {
  const SymmetricCrypto._();

  /// Encrypts [plaintext] under [key], binding [aad] when given.
  static Future<Uint8List> encrypt(
    Uint8List plaintext,
    SymmetricKey key, {
    Uint8List? aad,
  }) async {
    try {
      return await CryptoService.encryptSymmetric(plaintext, key, aad: aad);
    } catch (e) {
      throw CryptoOperationException('SymmetricCrypto.encrypt failed: $e');
    }
  }

  /// Decrypts a blob from [encrypt] under [key] and the same [aad].
  static Future<Uint8List> decrypt(
    Uint8List blob,
    SymmetricKey key, {
    Uint8List? aad,
  }) async {
    try {
      return await CryptoService.decryptSymmetric(blob, key, aad: aad);
    } catch (e) {
      throw CryptoOperationException('SymmetricCrypto.decrypt failed: $e');
    }
  }
}
