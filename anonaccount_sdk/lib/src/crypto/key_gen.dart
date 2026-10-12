import 'package:dart_jwk_duo/dart_jwk_duo.dart';

import '../auth/exceptions.dart';
import '../models/account_keys.dart';

/// Static, stateless key generation. The SDK never persists what it
/// produces — callers receive [KeyDuo] / JWK strings and own storage.
class KeyGen {
  const KeyGen._();

  /// Generates the long-term recovery key (a fresh ECDSA + ECDH P-256
  /// KeyDuo). The user must back this up.
  static Future<KeyDuo> generateUltimateKey() => _generateP256KeyDuo();

  /// Generates a per-device key — short-lived, scoped to one install.
  static Future<KeyDuo> generateDeviceKey() => _generateP256KeyDuo();

  /// Generates a key intended to be stored in cross-device sync
  /// (iCloud Keychain / BlockStore). Same shape as the device key —
  /// the lifecycle differs, not the cryptography.
  static Future<KeyDuo> generateCrossDeviceKey() => _generateP256KeyDuo();

  /// Generates an AES-256-GCM data key and returns its JWK
  /// (`{"kty":"oct","k":"<base64url>","alg":"A256GCM","use":"enc"}`).
  static Future<String> generateSymmetricKeyJwk() async {
    SymmetricKey? key;
    try {
      key = await GenerationService.generateSymmetricKey();
      return await key.toJwk();
    } catch (e) {
      throw CryptoOperationException(
        'KeyGen.generateSymmetricKeyJwk failed: $e',
      );
    } finally {
      key?.dispose();
    }
  }

  /// Convenience: generates all three keys in parallel and bundles them.
  static Future<AccountKeys> generateAccountKeys() async {
    final results = await Future.wait([
      generateUltimateKey(),
      generateDeviceKey(),
      generateSymmetricKeyJwk(),
    ]);
    return AccountKeys(
      ultimateKey: results[0] as KeyDuo,
      deviceKey: results[1] as KeyDuo,
      symmetricKeyJwk: results[2] as String,
    );
  }

  static Future<KeyDuo> _generateP256KeyDuo() async {
    try {
      return await GenerationService.generateKeyDuo();
    } catch (e) {
      throw CryptoOperationException('KeyGen P-256 generation failed: $e');
    }
  }
}
