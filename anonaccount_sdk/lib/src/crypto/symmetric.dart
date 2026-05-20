import 'dart:typed_data';
import 'package:webcrypto/webcrypto.dart';

import '../auth/exceptions.dart';

/// AES-256-GCM encrypt/decrypt with a 12-byte random IV prepended to
/// the ciphertext. Format: `IV(12) || ciphertext`.
class SymmetricCrypto {
  const SymmetricCrypto._();

  /// Encrypts [plaintext] under [key]. Returns `IV || ciphertext`.
  ///
  /// Throws [CryptoOperationException] on any underlying failure.
  static Future<Uint8List> encrypt(
    Uint8List plaintext,
    AesGcmSecretKey key,
  ) async {
    try {
      final iv = Uint8List(12);
      fillRandomBytes(iv);
      final ct = await key.encryptBytes(plaintext, iv);
      final out = Uint8List(iv.length + ct.length)
        ..setRange(0, iv.length, iv)
        ..setRange(iv.length, iv.length + ct.length, ct);
      return out;
    } catch (e) {
      throw CryptoOperationException('SymmetricCrypto.encrypt failed: $e');
    }
  }

  /// Decrypts `IV || ciphertext` from [ivAndCiphertext] under [key].
  ///
  /// Throws [CryptoOperationException] if the blob is too short or
  /// authentication fails.
  static Future<Uint8List> decrypt(
    Uint8List ivAndCiphertext,
    AesGcmSecretKey key,
  ) async {
    if (ivAndCiphertext.length < 12) {
      throw const CryptoOperationException(
        'SymmetricCrypto.decrypt: blob shorter than 12-byte IV',
      );
    }
    try {
      final iv = ivAndCiphertext.sublist(0, 12);
      final ct = ivAndCiphertext.sublist(12);
      return await key.decryptBytes(ct, iv);
    } catch (e) {
      throw CryptoOperationException('SymmetricCrypto.decrypt failed: $e');
    }
  }
}
