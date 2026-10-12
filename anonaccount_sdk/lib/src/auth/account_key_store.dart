import 'dart:typed_data' show Uint8List;
import 'package:dart_jwk_duo/dart_jwk_duo.dart' show KeyDuo;

/// Key-custody surface the SDK needs to run the account + pairing protocol.
/// Reverse-faceted from the apps' existing ICryptoKeyRepository: an app
/// satisfies it by adding `implements AccountKeyStore`.
///
/// Lifecycle contract (honored by the reference impls):
/// - Device + symmetric keys are persisted by the implementation.
/// - The ultimate key is held in memory only, signed via [signWithUltimateKey]
///   (its KeyDuo is NOT returned during create/register), and wiped by
///   [getUltimateKeyJwkOnce]. It is returned to the SDK only by
///   [importUltimateKeyJwk] (recover/revoke).
///
/// Ownership: the store owns every key object it holds. A [KeyDuo] returned
/// by [getDeviceKey] or [importUltimateKeyJwk] is the store's own object,
/// usable until the store next replaces or wipes that slot, at which point
/// the store disposes it. Keys are native handles, so this is what releases
/// their memory; a caller that needs a key across a replacement fetches it
/// again.
abstract interface class AccountKeyStore {
  Future<void> generateAccountKeys();
  Future<void> generateAndStoreDeviceKey();
  Future<String> generateSymmetricKeyJwk();

  Future<KeyDuo?> getDeviceKey();
  Future<String?> getDeviceSigningPublicKeyHex();

  /// The device key's encryption half, SEC1 uncompressed hex: the target
  /// other devices wrap the account data key to.
  Future<String?> getDeviceEncryptionPublicKeyHex();

  Future<String?> getSymmetricDataKeyJwk();
  Future<void> storeSymmetricDataKeyJwk(String jwk);

  Future<Uint8List?> signWithUltimateKey(Uint8List data);
  Future<String?> getUltimateSigningPublicKeyHex();

  /// The account's ultimate encryption public key, SEC1 uncompressed hex.
  ///
  /// Survives [getUltimateKeyJwkOnce]: that wipes the private halves, and a
  /// public key is not secret. Needed to encrypt group member keys long
  /// after the ultimate key itself has left the device.
  Future<String?> getUltimateEncryptionPublicKeyHex();

  Future<String?> getUltimateKeyJwkOnce();
  Future<KeyDuo> importUltimateKeyJwk(String jwk);
}
