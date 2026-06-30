import 'dart:convert';
import 'dart:typed_data';
import 'package:dart_jwk_duo/dart_jwk_duo.dart';
import 'package:webcrypto/webcrypto.dart';
import '../crypto/key_gen.dart';
import 'account_key_store.dart';

/// Non-persistent reference store used by SDK tests and trivial consumers.
/// Real apps implement [AccountKeyStore] over secure storage instead.
class InMemoryAccountKeyStore implements AccountKeyStore {
  KeyDuo? _device;
  KeyDuo? _ultimate;
  String? _symmetricJwk;
  String? _deviceHex;
  String? _ultimateHex;

  @override
  Future<void> generateAccountKeys() async {
    _ultimate = await KeyGen.generateUltimateKey();
    _device = await KeyGen.generateDeviceKey();
    _symmetricJwk = await KeyGen.generateSymmetricKeyJwk();
    _ultimateHex = await _ultimate!.signingKeyPair.exportPublicKeyHex();
    _deviceHex = await _device!.signingKeyPair.exportPublicKeyHex();
  }

  @override
  Future<void> generateAndStoreDeviceKey() async {
    _device = await KeyGen.generateDeviceKey();
    _deviceHex = await _device!.signingKeyPair.exportPublicKeyHex();
  }

  @override
  Future<String> generateSymmetricKeyJwk() => KeyGen.generateSymmetricKeyJwk();

  @override
  Future<KeyDuo?> getDeviceKey() async => _device;

  @override
  Future<EcdhPublicKey?> getDevicePublicKey() async =>
      _device?.encryptionKeyPair.publicKey;

  @override
  Future<String?> getDeviceSigningPublicKeyHex() async => _deviceHex;

  @override
  Future<AesGcmSecretKey?> getSymmetricDataKey() async {
    final jwk = _symmetricJwk;
    if (jwk == null) return null;
    final k = (jsonDecode(jwk) as Map<String, dynamic>)['k'] as String;
    return AesGcmSecretKey.importRawKey(base64Url.decode(base64Url.normalize(k)));
  }

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
  Future<EcdhPublicKey?> getUltimatePublicKey() async =>
      _ultimate?.encryptionKeyPair.publicKey;

  @override
  Future<String?> getUltimatePublicKeyJwk() async {
    final u = _ultimate;
    if (u == null) return null;
    return jsonEncode(await u.encryptionKeyPair.publicKey.exportJsonWebKey());
  }

  @override
  Future<String?> getUltimateSigningPublicKeyHex() async => _ultimateHex;

  @override
  Future<String?> getUltimateKeyJwkOnce() async {
    final u = _ultimate;
    if (u == null) return null;
    final jwk = await const KeyDuoSerializer().exportKeyDuo(u);
    _ultimate = null; // one-time retrieval — wipe
    return jwk;
  }

  @override
  Future<KeyDuo> importUltimateKeyJwk(String jwk) async {
    final u = await const KeyDuoSerializer().importKeyDuo(jwk);
    _ultimate = u;
    _ultimateHex = await u.signingKeyPair.exportPublicKeyHex();
    return u;
  }
}
