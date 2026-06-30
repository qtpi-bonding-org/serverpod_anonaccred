import 'dart:convert';
import 'dart:typed_data';

// ignore: implementation_imports
import 'package:anonaccount_client/src/pow_methods.dart' show AccountMethods;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/account_creation_response.dart'
    show AccountCreationResponse;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/client.dart' show Caller;
// UuidValue comes from serverpod_client, re-exported by anonaccount_client.
import 'package:anonaccount_client/anonaccount_client.dart' show UuidValue;
import 'package:dart_jwk_duo/dart_jwk_duo.dart' show KeyDuo;

import '../crypto/asymmetric.dart';
import '../models/account_creation_result.dart';
import '../models/registration_payload.dart';
import 'account_key_store.dart';
import 'pow_signer.dart';

/// High-level account lifecycle wrapper. Key custody lives in the
/// app-supplied [AccountKeyStore]; this class only drives the protocol.
class AnonaccountAuth {
  AnonaccountAuth(this._caller, this._store);

  final Caller _caller;
  final AccountKeyStore _store;

  static String _hex(Uint8List b) =>
      b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

  /// Local-only: has the [AccountKeyStore] generate a fresh ultimate +
  /// device + symmetric key triple and builds a signed [RegistrationPayload].
  /// Does NOT contact the server.
  ///
  /// Call [registerAccount] afterwards to submit. Ordering contract: the
  /// consumer MUST call [registerAccount] (which reads
  /// `_store.getUltimatePublicKeyJwk`) **before** calling
  /// `store.getUltimateKeyJwkOnce()` for backup display, since the latter
  /// wipes the store's in-memory ultimate key.
  Future<AccountCreationResult> createAccount({
    required String deviceLabel,
    required DateTime createdAt,
  }) async {
    await _store.generateAccountKeys();
    final payload = await _buildSignedPayload(createdAt: createdAt);
    return AccountCreationResult(payload: payload);
  }

  Future<RegistrationPayload> _buildSignedPayload({
    required DateTime createdAt,
  }) async {
    final devicePublicKeyHex = (await _store.getDeviceSigningPublicKeyHex())!;
    final ultimatePublicKeyHex =
        (await _store.getUltimateSigningPublicKeyHex())!;
    final symmetricJwk = (await _store.getSymmetricDataKeyJwk())!;
    final recoveryBlob = await AsymmetricCrypto.wrapForRecipient(
        symmetricJwk, (await _store.getUltimatePublicKey())!);
    final deviceBlob = await AsymmetricCrypto.wrapForRecipient(
        symmetricJwk, (await _store.getDevicePublicKey())!);
    final signableData =
        '$devicePublicKeyHex:$ultimatePublicKeyHex:$recoveryBlob:$deviceBlob:'
        '${createdAt.toIso8601String()}';
    final signature = _hex((await _store
        .signWithUltimateKey(Uint8List.fromList(utf8.encode(signableData))))!);
    final deviceKeyAttestation = _hex((await _store.signWithUltimateKey(
        Uint8List.fromList(utf8.encode(devicePublicKeyHex))))!);
    return RegistrationPayload(
      devicePublicKeyHex: devicePublicKeyHex,
      ultimatePublicKeyHex: ultimatePublicKeyHex,
      recoveryBlob: recoveryBlob,
      deviceBlob: deviceBlob,
      signature: signature,
      deviceKeyAttestation: deviceKeyAttestation,
      createdAt: createdAt,
    );
  }

  /// Submits a previously-built [payload] to the server. Difficulty is
  /// pulled from the server's challenge response.
  Future<AccountCreationResponse> registerAccount(
    RegistrationPayload payload, {
    required String deviceLabel,
  }) async {
    final deviceKey = (await _store.getDeviceKey())!;
    final ultimatePublicKeyJwk = (await _store.getUltimatePublicKeyJwk())!;
    final challengeResponse = await _caller.entrypoint.getChallenge();
    final envelope = await PowSigner.build(
      challenge: challengeResponse.challenge,
      methodName: AccountMethods.createAccount,
      signingKey: deviceKey,
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

  // TODO(A3): recoverAccount needs to be rewired to use AccountKeyStore
  // (via store.importUltimateKeyJwk / generateAndStoreDeviceKey /
  // generateSymmetricKeyJwk). Commented out for now — it references the
  // removed AccountKeys-based API and AccountCreationResult.keys, which no
  // longer exist after this task. Will be uncommented and rewired in A3.
  //
  // Future<AccountCreationResult> recoverAccount({
  //   required String ultimateKeyJwk,
  //   required String deviceLabel,
  // }) async {
  //   final KeyDuo ultimate;
  //   try {
  //     ultimate = await const KeyDuoSerializer().importKeyDuo(ultimateKeyJwk);
  //   } catch (e) {
  //     throw InvalidUltimateKeyException(
  //       'recoverAccount: could not parse ultimate key JWK: $e',
  //     );
  //   }
  //
  //   final device = await KeyGen.generateDeviceKey();
  //   final symmetricKeyJwk = await KeyGen.generateSymmetricKeyJwk();
  //
  //   final devicePublicKeyHex =
  //       await device.signingKeyPair.exportPublicKeyHex();
  //   final ultimatePublicKeyHex =
  //       await ultimate.signingKeyPair.exportPublicKeyHex();
  //
  //   final recoveryBlob = await AsymmetricCrypto.wrapForRecipient(
  //     symmetricKeyJwk,
  //     ultimate.encryptionKeyPair.publicKey,
  //   );
  //   final deviceBlob = await AsymmetricCrypto.wrapForRecipient(
  //     symmetricKeyJwk,
  //     device.encryptionKeyPair.publicKey,
  //   );
  //
  //   final createdAt = DateTime.now().toUtc();
  //   final signableData =
  //       '$devicePublicKeyHex:$ultimatePublicKeyHex:$recoveryBlob:$deviceBlob:'
  //       '${createdAt.toIso8601String()}';
  //   final signature =
  //       await SigningCrypto.signChallenge(signableData, ultimate);
  //   final deviceKeyAttestation =
  //       await SigningCrypto.signChallenge(devicePublicKeyHex, ultimate);
  //
  //   return AccountCreationResult(
  //     keys: AccountKeys(
  //       ultimateKey: ultimate,
  //       deviceKey: device,
  //       symmetricKeyJwk: symmetricKeyJwk,
  //     ),
  //     payload: RegistrationPayload(
  //       devicePublicKeyHex: devicePublicKeyHex,
  //       ultimatePublicKeyHex: ultimatePublicKeyHex,
  //       recoveryBlob: recoveryBlob,
  //       deviceBlob: deviceBlob,
  //       signature: signature,
  //       deviceKeyAttestation: deviceKeyAttestation,
  //       createdAt: createdAt,
  //     ),
  //   );
  // }

  /// Revokes a device from the caller's account.
  ///
  /// Authenticates with the ultimate key — the server verifies the PoW was
  /// signed by the ultimate key and resolves the account from it.
  ///
  /// [deviceId] is the UUID of the device row to revoke (not a pubkey hex).
  /// [ultimateKey] is the account's ultimate key pair.
  ///
  /// Returns `true` if the device was successfully revoked.
  Future<bool> revokeDevice({
    required UuidValue deviceId,
    required KeyDuo ultimateKey,
  }) async {
    final ultimateHex = await ultimateKey.signingKeyPair.exportPublicKeyHex();
    final challengeResp = await _caller.entrypoint.getChallenge();
    final envelope = await PowSigner.build(
      challenge: challengeResp.challenge,
      methodName: 'revokeDevice',
      signingKey: ultimateKey,
      publicKeyHex: ultimateHex,
      difficulty: challengeResp.difficulty,
    );
    return _caller.deviceManagement.revokeDevice(
      challenge: envelope.challenge,
      proofOfWork: envelope.proofOfWork,
      publicKeyHex: envelope.publicKeyHex,
      signature: envelope.signature,
      deviceId: deviceId,
    );
  }

  /// Server-side deleteAccount is not yet implemented. The SDK exposes this
  /// method so consumer code can wire it up now; the call will throw until
  /// the server endpoint lands. See spec section 6.6.
  Future<void> deleteAccount({
    required KeyDuo ultimateKey,
  }) async {
    throw UnimplementedError(
      'deleteAccount: server-side endpoint not yet available. '
      'Track follow-up in the anonaccount_server spec.',
    );
  }
}
