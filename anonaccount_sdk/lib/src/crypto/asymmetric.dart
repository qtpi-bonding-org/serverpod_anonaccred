import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_jwk_duo/dart_jwk_duo.dart'
    show CryptoService, EncryptionKeyPair, EncryptionPublicKeyHex, KeyDuo;

import '../auth/exceptions.dart';
import 'wrap_context.dart';

/// HPKE wrap of a plaintext payload (typically a JWK) to one recipient.
///
/// The blob is whatever `CryptoService.encrypt` produces, base64 encoded.
/// Callers round-trip through this class and do not parse the bytes.
class AsymmetricCrypto {
  const AsymmetricCrypto._();

  /// Encrypts [plaintext] to [recipientEncryptionPublicKeyHex] under
  /// [context]. Returns padded standard base64.
  static Future<String> wrapForRecipient(
    String plaintext,
    String recipientEncryptionPublicKeyHex,
    WrapContext context,
  ) async {
    EncryptionKeyPair? recipient;
    try {
      recipient = await EncryptionKeyPair.importPublicKeySec1Hex(
        EncryptionPublicKeyHex(recipientEncryptionPublicKeyHex),
      );
      final ct = await CryptoService.encrypt(
        Uint8List.fromList(utf8.encode(plaintext)),
        recipient,
        info: context.info,
        aad: context.aad,
      );
      return base64.encode(ct);
    } catch (e) {
      throw CryptoOperationException(
        'AsymmetricCrypto.wrapForRecipient failed: $e',
      );
    } finally {
      // grantAllDevices wraps in a loop; release each imported handle.
      recipient?.dispose();
    }
  }

  /// Opens a blob from [wrapForRecipient] with [recipient]'s encryption half.
  ///
  /// Takes the whole duo because 3.0 has no way to build a key pair from a
  /// lone private key, and every caller already holds the duo.
  static Future<String> unwrap(
    String wrappedBlob,
    KeyDuo recipient,
    WrapContext context,
  ) async {
    try {
      final pt = await CryptoService.decrypt(
        base64.decode(wrappedBlob),
        recipient.encryptionKeyPair,
        info: context.info,
        aad: context.aad,
      );
      return utf8.decode(pt);
    } catch (e) {
      throw CryptoOperationException('AsymmetricCrypto.unwrap failed: $e');
    }
  }
}
