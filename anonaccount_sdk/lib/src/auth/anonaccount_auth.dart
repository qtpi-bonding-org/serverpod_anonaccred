import 'dart:convert';

// ignore: implementation_imports
import 'package:anonaccount_client/src/pow_methods.dart' show AccountMethods;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/account_creation_response.dart'
    show AccountCreationResponse;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/client.dart' show Caller;
import 'package:dart_jwk_duo/dart_jwk_duo.dart' show KeyDuo, KeyDuoSerializer;

import '../crypto/asymmetric.dart';
import '../crypto/key_gen.dart';
import '../crypto/signing.dart';
import '../models/account_creation_result.dart';
import '../models/account_keys.dart';
import '../models/registration_payload.dart';
import 'exceptions.dart';
import 'pow_signer.dart';

/// High-level account lifecycle wrapper. Stateless — every call takes
/// the inputs it needs explicitly.
class AnonaccountAuth {
  AnonaccountAuth(this._caller);

  final Caller _caller;

  /// Local-only: generates a fresh ultimate + device + symmetric key triple
  /// and builds a signed [RegistrationPayload]. Does NOT contact the server.
  ///
  /// Call [registerAccount] afterwards to submit. This split lets consumers
  /// show the ultimate key to the user for backup before committing.
  Future<AccountCreationResult> createAccount({
    required String deviceLabel,
  }) async {
    final keys = await KeyGen.generateAccountKeys();

    final devicePublicKeyHex =
        await keys.deviceKey.signingKeyPair.exportPublicKeyHex();
    final ultimatePublicKeyHex =
        await keys.ultimateKey.signingKeyPair.exportPublicKeyHex();

    final recoveryBlob = await AsymmetricCrypto.wrapForRecipient(
      keys.symmetricKeyJwk,
      keys.ultimateKey.encryptionKeyPair.publicKey,
    );
    final deviceBlob = await AsymmetricCrypto.wrapForRecipient(
      keys.symmetricKeyJwk,
      keys.deviceKey.encryptionKeyPair.publicKey,
    );

    final createdAt = DateTime.now().toUtc();
    final signableData =
        '$devicePublicKeyHex:$ultimatePublicKeyHex:$recoveryBlob:$deviceBlob:'
        '${createdAt.toIso8601String()}';

    final signature = await SigningCrypto.signChallenge(
      signableData,
      keys.ultimateKey,
    );

    // Device-key attestation: ultimate key signs the device's pubkey hex.
    final deviceKeyAttestation = await SigningCrypto.signChallenge(
      devicePublicKeyHex,
      keys.ultimateKey,
    );

    final payload = RegistrationPayload(
      devicePublicKeyHex: devicePublicKeyHex,
      ultimatePublicKeyHex: ultimatePublicKeyHex,
      recoveryBlob: recoveryBlob,
      deviceBlob: deviceBlob,
      signature: signature,
      deviceKeyAttestation: deviceKeyAttestation,
      createdAt: createdAt,
    );

    return AccountCreationResult(keys: keys, payload: payload);
  }

  /// Submits a previously-built [payload] to the server. Difficulty is
  /// pulled from the server's challenge response.
  Future<AccountCreationResponse> registerAccount(
    RegistrationPayload payload, {
    required AccountKeys keys,
    required String deviceLabel,
  }) async {
    final ultimatePublicKeyJwk = jsonEncode(
      await keys.ultimateKey.encryptionKeyPair.publicKey.exportJsonWebKey(),
    );

    final challengeResponse = await _caller.entrypoint.getChallenge();
    final envelope = await PowSigner.build(
      challenge: challengeResponse.challenge,
      methodName: AccountMethods.createAccount,
      signingKey: keys.deviceKey,
      publicKeyHex: payload.devicePublicKeyHex,
      difficulty: challengeResponse.difficulty,
    );

    return _caller.account.createAccount(
      challenge: envelope.challenge,
      proofOfWork: envelope.proofOfWork,
      signature: envelope.signature,
      publicKeyHex: envelope.publicKeyHex,
      ultimateSigningPublicKeyHex: payload.ultimatePublicKeyHex,
      encryptedDataKey: payload.recoveryBlob,
      ultimatePublicKey: ultimatePublicKeyJwk,
      deviceKeyAttestation: payload.deviceKeyAttestation,
      deviceSigningPublicKeyHex: payload.devicePublicKeyHex,
      deviceEncryptedDataKey: payload.deviceBlob,
      deviceLabel: deviceLabel,
    );
  }

  /// Re-derives a fresh device key for an existing account using a
  /// previously-backed-up ultimate key JWK Set. Returns the new local
  /// material; submit via [registerAccount].
  ///
  /// Throws [InvalidUltimateKeyException] if [ultimateKeyJwk] cannot be parsed.
  Future<AccountCreationResult> recoverAccount({
    required String ultimateKeyJwk,
    required String deviceLabel,
  }) async {
    final KeyDuo ultimate;
    try {
      ultimate = await const KeyDuoSerializer().importKeyDuo(ultimateKeyJwk);
    } catch (e) {
      throw InvalidUltimateKeyException(
        'recoverAccount: could not parse ultimate key JWK: $e',
      );
    }

    final device = await KeyGen.generateDeviceKey();
    final symmetricKeyJwk = await KeyGen.generateSymmetricKeyJwk();

    final devicePublicKeyHex =
        await device.signingKeyPair.exportPublicKeyHex();
    final ultimatePublicKeyHex =
        await ultimate.signingKeyPair.exportPublicKeyHex();

    final recoveryBlob = await AsymmetricCrypto.wrapForRecipient(
      symmetricKeyJwk,
      ultimate.encryptionKeyPair.publicKey,
    );
    final deviceBlob = await AsymmetricCrypto.wrapForRecipient(
      symmetricKeyJwk,
      device.encryptionKeyPair.publicKey,
    );

    final createdAt = DateTime.now().toUtc();
    final signableData =
        '$devicePublicKeyHex:$ultimatePublicKeyHex:$recoveryBlob:$deviceBlob:'
        '${createdAt.toIso8601String()}';
    final signature =
        await SigningCrypto.signChallenge(signableData, ultimate);
    final deviceKeyAttestation =
        await SigningCrypto.signChallenge(devicePublicKeyHex, ultimate);

    return AccountCreationResult(
      keys: AccountKeys(
        ultimateKey: ultimate,
        deviceKey: device,
        symmetricKeyJwk: symmetricKeyJwk,
      ),
      payload: RegistrationPayload(
        devicePublicKeyHex: devicePublicKeyHex,
        ultimatePublicKeyHex: ultimatePublicKeyHex,
        recoveryBlob: recoveryBlob,
        deviceBlob: deviceBlob,
        signature: signature,
        deviceKeyAttestation: deviceKeyAttestation,
        createdAt: createdAt,
      ),
    );
  }
}
