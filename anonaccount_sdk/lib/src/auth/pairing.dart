import 'dart:convert';

// ignore: implementation_imports
import 'package:anonaccount_client/src/pow_methods.dart' show DeviceMethods;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/client.dart' show Caller;
import 'package:dart_jwk_duo/dart_jwk_duo.dart' show KeyDuo;
import 'package:webcrypto/webcrypto.dart';

import '../crypto/asymmetric.dart';
import '../crypto/key_gen.dart';
import '../models/generated_pairing_qr.dart';
import '../models/scanned_pairing_qr.dart';
import 'pow_signer.dart';

/// Device-pairing and group-handoff key exchange. Stateless.
class AnonaccountPairing {
  AnonaccountPairing(
    this._caller, {
    this.difficulty = PowSigner.defaultDifficulty,
  });

  final Caller _caller;
  final int difficulty;

  /// Side B (the joiner): generates a fresh device key and packages its
  /// public halves into a QR/link payload for side A to scan.
  Future<GeneratedPairingQr> generateQr({required String deviceLabel}) async {
    final deviceKey = await KeyGen.generateDeviceKey();
    final signingPubkeyHex =
        await deviceKey.signingKeyPair.exportPublicKeyHex();
    final encryptionPubkeyJwk = jsonEncode(
      await deviceKey.encryptionKeyPair.publicKey.exportJsonWebKey(),
    );

    return GeneratedPairingQr(
      qrPayloadJson: jsonEncode({
        'action': 'pair',
        'theirSigningPubkeyHex': signingPubkeyHex,
        'theirEncryptionPubkeyJwk': encryptionPubkeyJwk,
        'label': deviceLabel,
      }),
      deviceKey: deviceKey,
      signingPubkeyHex: signingPubkeyHex,
    );
  }

  /// Side A (the approver): decodes a QR/link payload from side B.
  ScannedPairingQr parseQr(String qrJson) =>
      ScannedPairingQr.fromQrJson(qrJson);

  /// Side B (the joiner): unwrap a wrapped symmetric key blob delivered
  /// by side A via [monitorRegistration]. Returns a live AES-GCM key
  /// ready for encrypt/decrypt.
  Future<AesGcmSecretKey> completePairing({
    required String wrappedKey,
    required KeyDuo myDeviceKey,
  }) async {
    final privateKey = myDeviceKey.encryptionKeyPair.privateKey;
    if (privateKey == null) {
      throw ArgumentError(
        'completePairing: myDeviceKey must contain a private encryption key',
      );
    }
    final jwkString = await AsymmetricCrypto.unwrap(wrappedKey, privateKey);
    final jwk = jsonDecode(jwkString) as Map<String, dynamic>;
    return AesGcmSecretKey.importJsonWebKey(jwk);
  }

  /// Side B (the joiner): opens a server-sent stream that fires once for
  /// each wrapped-key event the server emits for this signing public key.
  ///
  /// Yields the `encryptedDataKey` blob from each event; the consumer
  /// passes that blob to [completePairing] to unwrap the symmetric key.
  Stream<String> monitorRegistration(
    String mySigningPubkeyHex, {
    required KeyDuo deviceKey,
  }) async* {
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

  /// One-shot convenience — awaits the first wrapped-key event.
  Future<String> awaitFirstRegistration(
    String mySigningPubkeyHex, {
    required KeyDuo deviceKey,
  }) =>
      monitorRegistration(mySigningPubkeyHex, deviceKey: deviceKey).first;
}
