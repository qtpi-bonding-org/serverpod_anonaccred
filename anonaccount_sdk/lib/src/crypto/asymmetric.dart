import 'dart:convert';
import 'dart:typed_data';
import 'package:dart_jwk_duo/dart_jwk_duo.dart';
import 'package:webcrypto/webcrypto.dart';

import '../auth/exceptions.dart';

/// Hybrid ECDH+AES wrap. Wraps a plaintext payload (typically a JWK
/// representing a symmetric data key) so that only the holder of the
/// matching ECDH private key can recover it.
///
/// Wire format is whatever `CryptoService.encrypt` produces. Callers
/// must round-trip via this class — do not parse the bytes.
class AsymmetricCrypto {
  const AsymmetricCrypto._();

  /// Encrypts [plaintext] to [recipient]. Returns base64-encoded blob.
  static Future<String> wrapForRecipient(
    String plaintext,
    EcdhPublicKey recipient,
  ) async {
    try {
      final encryptionKeyPair = EncryptionKeyPair.publicOnly(
        publicKey: recipient,
      );
      final ct = await CryptoService.encrypt(
        Uint8List.fromList(utf8.encode(plaintext)),
        encryptionKeyPair,
      );
      return base64.encode(ct);
    } catch (e) {
      throw CryptoOperationException(
        'AsymmetricCrypto.wrapForRecipient failed: $e',
      );
    }
  }

  /// Decrypts a [wrappedBlob] produced by [wrapForRecipient] using
  /// our [ourPrivkey]. Returns the original plaintext string.
  static Future<String> unwrap(
    String wrappedBlob,
    EcdhPrivateKey ourPrivkey,
  ) async {
    try {
      // CryptoService.decrypt needs a paired pubkey; generate a throwaway
      // one — it's irrelevant for decrypt, only the private key matters.
      final dummyEnc = await EcdhPrivateKey.generateKey(EllipticCurve.p256);
      final encryptionKeyPair = EncryptionKeyPair(
        privateKey: ourPrivkey,
        publicKey: dummyEnc.publicKey,
      );
      final pt = await CryptoService.decrypt(
        base64.decode(wrappedBlob),
        encryptionKeyPair,
      );
      return utf8.decode(pt);
    } catch (e) {
      throw CryptoOperationException(
        'AsymmetricCrypto.unwrap failed: $e',
      );
    }
  }
}
