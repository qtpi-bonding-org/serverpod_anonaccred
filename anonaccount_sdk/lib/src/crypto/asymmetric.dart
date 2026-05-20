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
      final keyDuo = await _publicOnlyKeyDuo(recipient);
      final ct = await CryptoService.encrypt(
        Uint8List.fromList(utf8.encode(plaintext)),
        keyDuo,
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
      final keyDuo = await _privateOnlyKeyDuo(ourPrivkey);
      final pt = await CryptoService.decrypt(
        base64.decode(wrappedBlob),
        keyDuo,
      );
      return utf8.decode(pt);
    } catch (e) {
      throw CryptoOperationException(
        'AsymmetricCrypto.unwrap failed: $e',
      );
    }
  }

  // `CryptoService.encrypt`/`.decrypt` require a full [KeyDuo]. For
  // one-sided operations we synthesize a throwaway ECDSA signing pair
  // — never used, just to satisfy the API. The encryption side is the
  // only one that matters.

  static Future<KeyDuo> _publicOnlyKeyDuo(EcdhPublicKey recipient) async {
    final dummy = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
    return KeyDuo(
      signing: SigningKeyPair(
        privateKey: dummy.privateKey,
        publicKey: dummy.publicKey,
      ),
      encryption: EncryptionKeyPair.publicOnly(publicKey: recipient),
    );
  }

  static Future<KeyDuo> _privateOnlyKeyDuo(EcdhPrivateKey ourPrivkey) async {
    final dummySign = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
    // CryptoService.decrypt needs a paired pubkey; generate one and
    // hand both halves over. The pubkey is irrelevant for decrypt.
    final dummyEnc = await EcdhPrivateKey.generateKey(EllipticCurve.p256);
    return KeyDuo(
      signing: SigningKeyPair(
        privateKey: dummySign.privateKey,
        publicKey: dummySign.publicKey,
      ),
      encryption: EncryptionKeyPair(
        privateKey: ourPrivkey,
        publicKey: dummyEnc.publicKey,
      ),
    );
  }
}
