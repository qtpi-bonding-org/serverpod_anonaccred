import 'dart:typed_data';
import 'package:dart_jwk_duo/dart_jwk_duo.dart';
import '../crypto/key_gen.dart';
import 'account_key_store.dart';

/// Non-persistent reference store used by SDK tests and trivial consumers.
/// Real apps implement [AccountKeyStore] over secure storage instead.
class InMemoryAccountKeyStore implements AccountKeyStore {
  KeyDuo? _device;
  KeyDuo? _ultimate;
  String? _symmetricJwk;
  String? _deviceHex;
  String? _deviceEncryptionHex;
  String? _ultimateHex;
  String? _ultimateEncryptionHex;

  // The store owns what it holds (see AccountKeyStore), so a dropped key is
  // disposed here; re-storing the same object must not free the live one.
  static void _drop(KeyDuo? old, KeyDuo? next) {
    if (old != null && !identical(old, next)) old.dispose();
  }

  @override
  Future<void> generateAccountKeys() async {
    final ultimate = await KeyGen.generateUltimateKey();
    final device = await KeyGen.generateDeviceKey();
    _drop(_ultimate, ultimate);
    _drop(_device, device);
    _ultimate = ultimate;
    _device = device;
    _symmetricJwk = await KeyGen.generateSymmetricKeyJwk();
    _ultimateHex = await ultimate.signingKeyPair.exportPublicKeySec1Hex();
    _ultimateEncryptionHex =
        await ultimate.encryptionKeyPair.exportPublicKeySec1Hex();
    _deviceHex = await device.signingKeyPair.exportPublicKeySec1Hex();
    _deviceEncryptionHex =
        await device.encryptionKeyPair.exportPublicKeySec1Hex();
  }

  @override
  Future<void> generateAndStoreDeviceKey() async {
    final device = await KeyGen.generateDeviceKey();
    _drop(_device, device);
    _device = device;
    _deviceHex = await device.signingKeyPair.exportPublicKeySec1Hex();
    _deviceEncryptionHex =
        await device.encryptionKeyPair.exportPublicKeySec1Hex();
  }

  @override
  Future<String> generateSymmetricKeyJwk() => KeyGen.generateSymmetricKeyJwk();

  @override
  Future<KeyDuo?> getDeviceKey() async => _device;

  @override
  Future<String?> getDeviceSigningPublicKeyHex() async => _deviceHex;

  @override
  Future<String?> getDeviceEncryptionPublicKeyHex() async => _deviceEncryptionHex;

  @override
  Future<String?> getSymmetricDataKeyJwk() async => _symmetricJwk;

  @override
  Future<void> storeSymmetricDataKeyJwk(String jwk) async => _symmetricJwk = jwk;

  @override
  Future<Uint8List?> signWithUltimateKey(Uint8List data) async {
    final u = _ultimate;
    if (u == null) return null;
    return Uint8List.fromList(await u.signingKeyPair.signBytes(data));
  }

  @override
  Future<String?> getUltimateSigningPublicKeyHex() async => _ultimateHex;

  @override
  Future<String?> getUltimateEncryptionPublicKeyHex() async =>
      _ultimateEncryptionHex;

  @override
  Future<String?> getUltimateKeyJwkOnce() async {
    final u = _ultimate;
    if (u == null) return null;
    final jwk = await const KeyDuoSerializer().exportKeyDuoJwk(u);
    _ultimate = null; // one-time retrieval — wipe
    u.dispose();
    return jwk;
  }

  @override
  Future<KeyDuo> importUltimateKeyJwk(String jwk) async {
    final u = await const KeyDuoSerializer().importKeyDuoJwk(jwk);
    _drop(_ultimate, u);
    _ultimate = u;
    _ultimateHex = await u.signingKeyPair.exportPublicKeySec1Hex();
    _ultimateEncryptionHex = await u.encryptionKeyPair.exportPublicKeySec1Hex();
    return u;
  }
}
