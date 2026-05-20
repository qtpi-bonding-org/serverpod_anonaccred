import 'dart:convert';

// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/client.dart' show Caller;
import 'package:dart_jwk_duo/dart_jwk_duo.dart' show KeyDuo;
import 'package:webcrypto/webcrypto.dart';

import '../crypto/asymmetric.dart';
import '../crypto/key_gen.dart';
import '../crypto/signing.dart';
import '../models/created_group.dart';
import 'pow_signer.dart';

/// High-level group lifecycle wrapper. Stateless. Each method takes the
/// keys it needs explicitly — the SDK does not retain state between calls.
class AnonaccountGroups {
  AnonaccountGroups(this._caller, {this.difficulty = PowSigner.defaultDifficulty});

  final Caller _caller;
  // ignore: unused_field
  final int difficulty;

  /// Creates a new group. Generates a fresh group ultimate KeyDuo, a
  /// fresh creator-member KeyDuo, and a fresh AES-GCM data key locally.
  /// Wraps the data key to both keypairs and posts to the server.
  Future<CreatedGroup> createGroup({
    required String displayName,
    required KeyDuo callerDeviceKey,
  }) async {
    // Group-scoped key material.
    final groupUltimate = await KeyGen.generateUltimateKey();
    final creatorMember = await KeyGen.generateDeviceKey();
    final dataKey = await AesGcmSecretKey.generateKey(256);

    final dataKeyJwk = jsonEncode(await dataKey.exportJsonWebKey());

    final groupUltimateSigningPublicKeyHex =
        await groupUltimate.signingKeyPair.exportPublicKeyHex();
    final groupUltimatePublicKey = jsonEncode(
      await groupUltimate.encryptionKeyPair.publicKey.exportJsonWebKey(),
    );
    final creatorMemberSigningPublicKeyHex =
        await creatorMember.signingKeyPair.exportPublicKeyHex();
    final creatorMemberPublicKey = jsonEncode(
      await creatorMember.encryptionKeyPair.publicKey.exportJsonWebKey(),
    );

    final groupEncryptedDataKey = await AsymmetricCrypto.wrapForRecipient(
      dataKeyJwk,
      groupUltimate.encryptionKeyPair.publicKey,
    );
    final creatorMemberEncryptedDataKey =
        await AsymmetricCrypto.wrapForRecipient(
      dataKeyJwk,
      creatorMember.encryptionKeyPair.publicKey,
    );

    // Inner attestation: group's ultimate key signs the inner payload.
    final innerPayload =
        'createGroup:$groupUltimateSigningPublicKeyHex:$groupUltimatePublicKey'
        ':$creatorMemberSigningPublicKeyHex:$creatorMemberPublicKey';
    final groupUltimateAttestation =
        await SigningCrypto.signChallenge(innerPayload, groupUltimate);

    // Outer envelope signed by the user's device key.
    final callerDeviceSigningPublicKeyHex =
        await callerDeviceKey.signingKeyPair.exportPublicKeyHex();
    final challengeResp = await _caller.entrypoint.getChallenge();
    final envelope = await PowSigner.build(
      challenge: challengeResp.challenge,
      methodName: 'createGroup',
      signingKey: callerDeviceKey,
      publicKeyHex: callerDeviceSigningPublicKeyHex,
      difficulty: challengeResp.difficulty,
    );

    final share = await _caller.group.createGroup(
      challenge: envelope.challenge,
      proofOfWork: envelope.proofOfWork,
      signature: envelope.signature,
      callerDeviceSigningPublicKeyHex: envelope.publicKeyHex,
      groupUltimateSigningPublicKeyHex: groupUltimateSigningPublicKeyHex,
      groupUltimatePublicKey: groupUltimatePublicKey,
      groupEncryptedDataKey: groupEncryptedDataKey,
      creatorMemberSigningPublicKeyHex: creatorMemberSigningPublicKeyHex,
      creatorMemberPublicKey: creatorMemberPublicKey,
      creatorMemberEncryptedDataKey: creatorMemberEncryptedDataKey,
      groupUltimateAttestation: groupUltimateAttestation,
    );

    return CreatedGroup(
      groupId: share.id!.toString(),
      displayName: displayName,
      groupDataKey: dataKey,
      createdAt: share.createdAt,
    );
  }
}
