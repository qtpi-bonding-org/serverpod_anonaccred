import 'dart:convert';

// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/account_device.dart'
    show AccountDevice;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/client.dart' show Caller;
import 'package:anonaccount_protocol/anonaccount_protocol.dart'
    show AccountInnerPayloads, DeviceMethods, PublicKeyDuo;
import 'package:dart_jwk_duo/dart_jwk_duo.dart' show SymmetricKey;

import '../crypto/asymmetric.dart';
import '../crypto/wrap_context.dart';
import '../models/generated_pairing_qr.dart';
import '../models/pairing_delivery.dart';
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
    final encryptionPubkeyHex =
        (await _store.getDeviceEncryptionPublicKeyHex())!;
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
  /// Persists the unwrapped key's JWK into the store and returns a live
  /// [SymmetricKey], which the caller owns and disposes.
  Future<SymmetricKey> completePairing({required String wrappedKey}) async {
    final deviceKey = (await _store.getDeviceKey())!;
    if (!deviceKey.encryptionKeyPair.hasPrivateKey) {
      throw ArgumentError('completePairing: device key missing private half');
    }
    final deviceSigningHex = (await _store.getDeviceSigningPublicKeyHex())!;
    final jwkString = await AsymmetricCrypto.unwrap(
      wrappedKey,
      deviceKey,
      WrapContext.accountDataKeyForDevice(deviceSigningHex: deviceSigningHex),
    );
    await _store.storeSymmetricDataKeyJwk(jwkString);
    return SymmetricKey.fromJwk(jwkString);
  }

  /// Side B (the joiner): opens a server-sent stream that fires once for
  /// each pairing event the server emits for this signing public key.
  ///
  /// The consumer passes [PairingDelivery.encryptedDataKey] to
  /// [completePairing] to unwrap the symmetric key. The ultimate public
  /// keys ride along on the same channel because it already is this
  /// device's trust basis — no additional round trip or signature.
  Stream<PairingDelivery> monitorRegistration(String mySigningPubkeyHex) async* {
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
        .map((e) => PairingDelivery(
              encryptedDataKey: e.encryptedDataKey,
              ultimateEncryptionPublicKeyHex: e.ultimateEncryptionPublicKeyHex,
              ultimateSigningPublicKeyHex: e.ultimateSigningPublicKeyHex,
            ));
  }

  /// Side A (the approver, an existing paired device): wraps our account
  /// symmetric key to the new device's encryption pubkey and registers
  /// the new device with the server.
  Future<AccountDevice> registerPairedDevice({
    required ScannedPairingQr scanned,
    required String label,
  }) async {
    final ourDeviceKey = (await _store.getDeviceKey())!;
    final ultimateEncryptionPublicKeyHex =
        await _store.getUltimateEncryptionPublicKeyHex();
    final ultimateSigningPublicKeyHex =
        await _store.getUltimateSigningPublicKeyHex();
    if (ultimateEncryptionPublicKeyHex == null ||
        ultimateSigningPublicKeyHex == null) {
      throw StateError(
        'registerPairedDevice: this device\'s store has no ultimate public '
        'keys. Side A itself never learned them, so pairing would silently '
        'produce a device that can never write a group member-key backup.',
      );
    }
    final symJwk = (await _store.getSymmetricDataKeyJwk())!;
    final wrappedSymKey = await AsymmetricCrypto.wrapForRecipient(
      symJwk,
      scanned.theirEncryptionPubkeyHex,
      WrapContext.accountDataKeyForDevice(
        deviceSigningHex: scanned.theirSigningPubkeyHex,
      ),
    );
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
      ultimateEncryptionPublicKeyHex: ultimateEncryptionPublicKeyHex,
      ultimateSigningPublicKeyHex: ultimateSigningPublicKeyHex,
    );
  }
}
