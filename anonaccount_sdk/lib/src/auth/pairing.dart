import 'dart:convert';

// ignore: implementation_imports
import 'package:anonaccount_client/src/pow_methods.dart'
    show AccountInnerPayloads, DeviceMethods;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/account_device.dart'
    show AccountDevice;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/client.dart' show Caller;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/public_key_duo.dart'
    show PublicKeyDuo;
import 'package:dart_jwk_duo/dart_jwk_duo.dart'
    show EncryptionKeyPair, EncryptionPublicKeyHex;
import 'package:webcrypto/webcrypto.dart';

import '../crypto/asymmetric.dart';
import '../models/generated_pairing_qr.dart';
import '../models/scanned_pairing_qr.dart';
import 'account_key_store.dart';
import 'pow_signer.dart';

/// Device-pairing and group-handoff key exchange, backed by an
/// [AccountKeyStore] for key custody.
class AnonaccountPairing {
  AnonaccountPairing(
    this._caller,
    this._store, {
    this.difficulty = PowSigner.defaultDifficulty,
  });

  final Caller _caller;
  final AccountKeyStore _store;
  final int difficulty;

  /// Side B (the joiner): generates a fresh device key (persisted via the
  /// store) and packages its public halves into a QR/link payload for
  /// side A to scan.
  Future<GeneratedPairingQr> beginPairing({required String deviceLabel}) async {
    await _store.generateAndStoreDeviceKey();
    final signingPubkeyHex = (await _store.getDeviceSigningPublicKeyHex())!;
    final devicePublicKey = (await _store.getDevicePublicKey())!;
    final encryptionPubkeyHex =
        (await EncryptionKeyPair.publicOnly(publicKey: devicePublicKey)
                .exportPublicKeySec1Hex())
            .value;
    return GeneratedPairingQr(
      qrPayloadJson: jsonEncode({
        'action': 'pair',
        'theirSigningPubkeyHex': signingPubkeyHex,
        'theirEncryptionPubkeyHex': encryptionPubkeyHex,
        'label': deviceLabel,
      }),
      signingPubkeyHex: signingPubkeyHex,
    );
  }

  /// Side A (the approver): decodes a QR/link payload from side B.
  ScannedPairingQr parseQr(String qrJson) =>
      ScannedPairingQr.fromQrJson(qrJson);

  /// Side B (the joiner): unwrap a wrapped symmetric key blob delivered
  /// by side A via [monitorRegistration]. Persists the unwrapped key
  /// into the store and returns a live AES-GCM key ready for
  /// encrypt/decrypt.
  Future<AesGcmSecretKey> completePairing({required String wrappedKey}) async {
    final deviceKey = (await _store.getDeviceKey())!;
    final privateKey = deviceKey.encryptionKeyPair.privateKey;
    if (privateKey == null) {
      throw ArgumentError('completePairing: device key missing private half');
    }
    final jwkString = await AsymmetricCrypto.unwrap(wrappedKey, privateKey);
    await _store.storeSymmetricDataKeyJwk(jwkString);
    final jwk = jsonDecode(jwkString) as Map<String, dynamic>;
    return AesGcmSecretKey.importJsonWebKey(jwk);
  }

  /// Side B (the joiner): opens a server-sent stream that fires once for
  /// each wrapped-key event the server emits for this signing public key.
  ///
  /// Yields the `encryptedDataKey` blob from each event; the consumer
  /// passes that blob to [completePairing] to unwrap the symmetric key.
  Stream<String> monitorRegistration(String mySigningPubkeyHex) async* {
    final deviceKey = (await _store.getDeviceKey())!;
    final challengeResp = await _caller.entrypoint.getChallenge();
    final envelope = await PowSigner.build(
      challenge: challengeResp.challenge,
      methodName: DeviceMethods.monitorRegistration,
      signingKey: deviceKey,
      publicKeyHex: mySigningPubkeyHex,
      difficulty: challengeResp.difficulty,
    );
    yield* _caller.device
        .monitorRegistration(
          challenge: envelope.challenge,
          proofOfWork: envelope.proofOfWork,
          signature: envelope.signature,
          signingKeyHex: envelope.publicKeyHex,
        )
        .map((e) => e.encryptedDataKey);
  }

  /// Side A (the approver, an existing paired device): wraps our account
  /// symmetric key to the new device's encryption pubkey and registers
  /// the new device with the server.
  Future<AccountDevice> registerPairedDevice({
    required ScannedPairingQr scanned,
    required String label,
  }) async {
    final ourDeviceKey = (await _store.getDeviceKey())!;
    final ourSymmetricKey = (await _store.getSymmetricDataKey())!;
    final theirEncryptionKeyPair = await EncryptionKeyPair.importPublicKeySec1Hex(
      EncryptionPublicKeyHex(scanned.theirEncryptionPubkeyHex),
    );
    final theirEncryptionPubkey = theirEncryptionKeyPair.publicKey;
    final symJwk = jsonEncode(await ourSymmetricKey.exportJsonWebKey());
    final wrappedSymKey = await AsymmetricCrypto.wrapForRecipient(
        symJwk, theirEncryptionPubkey);
    final ourDeviceHex =
        (await ourDeviceKey.signingKeyPair.exportPublicKeySec1Hex()).value;
    final newDeviceKeys = PublicKeyDuo(
      signingPublicKeyHex: scanned.theirSigningPubkeyHex,
      encryptionPublicKeyHex: scanned.theirEncryptionPubkeyHex,
    );
    // An existing paired device attests to the newly paired device's key
    // pair — the server verifies this against our device signing key.
    final pairingAttestation = await ourDeviceKey.signingKeyPair.signBytes(
      utf8.encode(AccountInnerPayloads.pairDevice(newDeviceKeys)),
    );
    final challengeResp = await _caller.entrypoint.getChallenge();
    final envelope = await PowSigner.build(
      challenge: challengeResp.challenge,
      methodName: 'registerDeviceForAccount',
      signingKey: ourDeviceKey,
      publicKeyHex: ourDeviceHex,
      difficulty: challengeResp.difficulty,
    );
    return _caller.deviceManagement.registerDeviceForAccount(
      challenge: envelope.challenge,
      proofOfWork: envelope.proofOfWork,
      publicKeyHex: envelope.publicKeyHex,
      signature: envelope.signature,
      newDeviceKeys: newDeviceKeys,
      pairingAttestation: pairingAttestation
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(),
      newDeviceEncryptedDataKey: wrappedSymKey,
      label: label,
    );
  }
}
