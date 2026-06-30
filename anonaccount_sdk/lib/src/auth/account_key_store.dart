import 'dart:typed_data' show Uint8List;
import 'package:dart_jwk_duo/dart_jwk_duo.dart' show KeyDuo;
import 'package:webcrypto/webcrypto.dart' show AesGcmSecretKey, EcdhPublicKey;

/// Key-custody surface the SDK needs to run the account + pairing protocol.
/// Reverse-faceted from the apps' existing ICryptoKeyRepository: an app
/// satisfies it by adding `implements AccountKeyStore` — no new methods.
///
/// Lifecycle contract (already honored by the reference impls):
/// - Device + symmetric keys are persisted by the implementation.
/// - The ultimate key is held in memory only, signed via [signWithUltimateKey]
///   (its KeyDuo is NOT returned during create/register), and wiped by
///   [getUltimateKeyJwkOnce]. It is returned to the SDK only by
///   [importUltimateKeyJwk] (recover/revoke).
abstract interface class AccountKeyStore {
  Future<void> generateAccountKeys();
  Future<void> generateAndStoreDeviceKey();
  Future<String> generateSymmetricKeyJwk();

  Future<KeyDuo?> getDeviceKey();
  Future<EcdhPublicKey?> getDevicePublicKey();
  Future<String?> getDeviceSigningPublicKeyHex();

  Future<AesGcmSecretKey?> getSymmetricDataKey();
  Future<String?> getSymmetricDataKeyJwk();
  Future<void> storeSymmetricDataKeyJwk(String jwk);

  Future<Uint8List?> signWithUltimateKey(Uint8List data);
  Future<EcdhPublicKey?> getUltimatePublicKey();
  Future<String?> getUltimatePublicKeyJwk();
  Future<String?> getUltimateSigningPublicKeyHex();
  Future<String?> getUltimateKeyJwkOnce();
  Future<KeyDuo> importUltimateKeyJwk(String jwk);
}
