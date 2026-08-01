import 'dart:convert';
import 'dart:typed_data';

// ignore: implementation_imports
import 'package:anonaccount_client/src/pow_methods.dart'
    show AccountMethods, DataKeyMethods, DeviceMethods;
// ignore: implementation_imports
import 'package:dart_jwk_duo/dart_jwk_duo.dart' show KeyDuo;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/account_creation_response.dart'
    show AccountCreationResponse;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/client.dart' show Caller;
// UuidValue comes from serverpod_client, re-exported by anonaccount_client.
import 'package:anonaccount_client/anonaccount_client.dart' show UuidValue;

import '../crypto/asymmetric.dart';
import '../models/account_creation_result.dart';
import '../models/registration_payload.dart';
import 'account_key_store.dart';
import 'exceptions.dart';
import 'pow_signer.dart';

/// High-level account lifecycle wrapper. Key custody lives in the
/// app-supplied [AccountKeyStore]; this class only drives the protocol.
class AnonaccountAuth {
  AnonaccountAuth(this._caller, this._store);

  final Caller _caller;
  final AccountKeyStore _store;

  static String _hex(Uint8List b) =>
      b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

  /// Hex-encoded ultimate-key signature over [message]. Used for the
  /// registration payload signature and for device-key attestations on both
  /// the create-account and recover-account paths.
  Future<String> _signWithUltimate(String message) async => _hex(
        (await _store
            .signWithUltimateKey(Uint8List.fromList(utf8.encode(message))))!,
      );

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
    final signature = await _signWithUltimate(signableData);
    final deviceKeyAttestation = await _signWithUltimate(devicePublicKeyHex);
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

  /// Recovers access to an EXISTING account from its ultimate key backup,
  /// after all paired devices are lost.
  ///
  /// [ultimateKeyJwk] is the exported JWK of the account's ultimate key. It is
  /// used locally only — never sent to the server.
  ///
  /// Unlike [createAccount], this contacts the server (twice) and mints no new
  /// account data key. It:
  /// 1. fetches `AnonAccount.encryptedDataKey` via `recoverEncryptedDataKey`,
  /// 2. unwraps it with the ultimate encryption private key, recovering the
  ///    account's **original** symmetric data key,
  /// 3. generates a fresh device key and stores the recovered data key,
  /// 4. registers that device against the existing account via
  ///    `registerDevice`, attested by the ultimate key.
  ///
  /// Recovering the original data key (rather than generating a new one) is
  /// what keeps previously-encrypted content readable, and is relied upon by
  /// anything that wraps secrets under the account data key.
  ///
  /// Do NOT call [registerAccount] afterwards — that submits `createAccount`,
  /// which rejects an ultimate key that already has an account.
  Future<void> recoverAccount({
    required String ultimateKeyJwk,
    required String deviceLabel,
  }) async {
    final KeyDuo ultimate;
    try {
      ultimate = await _store.importUltimateKeyJwk(ultimateKeyJwk);
    } catch (e) {
      throw InvalidUltimateKeyException(
        'recoverAccount: could not parse ultimate key JWK: $e',
      );
    }
    final ultimateHex = await ultimate.signingKeyPair.exportPublicKeyHex();

    // Fetch the account data key wrapped to the ultimate encryption pubkey
    // (written as `recoveryBlob` at account creation) and unwrap it locally.
    // The ultimate private key never leaves this device.
    final challenge = await _caller.entrypoint.getChallenge();
    final envelope = await PowSigner.build(
      challenge: challenge.challenge,
      methodName: DataKeyMethods.recoverEncryptedDataKey,
      signingKey: ultimate,
      publicKeyHex: ultimateHex,
      difficulty: challenge.difficulty,
    );
    final response = await _caller.dataKey.recoverEncryptedDataKey(
      challenge: envelope.challenge,
      proofOfWork: envelope.proofOfWork,
      signature: envelope.signature,
      ultimateSigningPublicKeyHex: envelope.publicKeyHex,
    );

    final ultimatePrivateKey = ultimate.encryptionKeyPair.privateKey;
    if (ultimatePrivateKey == null) {
      throw const InvalidUltimateKeyException(
        'recoverAccount: ultimate key has no private encryption half',
      );
    }
    final symmetricJwk = await AsymmetricCrypto.unwrap(
      response.encryptedDataKey,
      ultimatePrivateKey,
    );

    await _store.generateAndStoreDeviceKey();
    final deviceKey = (await _store.getDeviceKey())!;
    final deviceHex = (await _store.getDeviceSigningPublicKeyHex())!;

    // Persist the key BEFORE registering. A crash after registration but
    // before this write would leave a device registered server-side with no
    // local key — unrecoverable without re-entering the recovery phrase.
    // This ordering fails the other way instead: a key with no registration,
    // which a later retry fixes.
    await _store.storeSymmetricDataKeyJwk(symmetricJwk);

    final deviceBlob = await AsymmetricCrypto.wrapForRecipient(
      symmetricJwk,
      deviceKey.encryptionKeyPair.publicKey,
    );
    final attestation = await _signWithUltimate(deviceHex);

    final regChallenge = await _caller.entrypoint.getChallenge();
    final regEnvelope = await PowSigner.build(
      challenge: regChallenge.challenge,
      methodName: DeviceMethods.registerDevice,
      signingKey: deviceKey,
      publicKeyHex: deviceHex,
      difficulty: regChallenge.difficulty,
    );
    await _caller.device.registerDevice(
      challenge: regEnvelope.challenge,
      proofOfWork: regEnvelope.proofOfWork,
      signature: regEnvelope.signature,
      deviceKeyAttestation: attestation,
      ultimateSigningPublicKeyHex: ultimateHex,
      deviceSigningPublicKeyHex: deviceHex,
      encryptedDataKey: deviceBlob,
      label: deviceLabel,
    );
  }

  /// Revokes a device from the caller's account.
  ///
  /// Authenticates with the ultimate key — the server verifies the PoW was
  /// signed by the ultimate key and resolves the account from it.
  ///
  /// [deviceId] is the UUID of the device row to revoke (not a pubkey hex).
  /// [ultimateBackupJwk] is the exported JWK of the account's ultimate key.
  ///
  /// Returns `true` if the device was successfully revoked.
  Future<bool> revokeDevice({
    required UuidValue deviceId,
    required String ultimateBackupJwk,
  }) async {
    final ultimate = await _store.importUltimateKeyJwk(ultimateBackupJwk);
    final ultimateHex = await ultimate.signingKeyPair.exportPublicKeyHex();
    final challengeResp = await _caller.entrypoint.getChallenge();
    final envelope = await PowSigner.build(
      challenge: challengeResp.challenge,
      methodName: 'revokeDevice',
      signingKey: ultimate,
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
  Future<void> deleteAccount({required String ultimateBackupJwk}) async {
    throw UnimplementedError(
      'deleteAccount: server-side endpoint not yet available.',
    );
  }
}
