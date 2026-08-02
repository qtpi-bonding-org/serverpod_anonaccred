import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('AccountEndpoint Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    test('getChallenge returns valid challenge response', () async {
      final challenge = await endpoints.entrypoint.getChallenge(sessionBuilder);

      expect(challenge.challenge, hasLength(32));
      expect(challenge.difficulty, equals(20));
      expect(challenge.expiresAt, greaterThan(0));
    });

    test('createAccount with valid PoW succeeds', () async {
      // Use unique keypair to avoid rate limit collisions across tests
      final (privKey, pubKey) = SigningTestHelper.generateKeypair();

      final challengeResponse =
          await endpoints.entrypoint.getChallenge(sessionBuilder);

      final proofOfWork = await PowTestHelper.mint(
        challengeResponse.challenge,
        difficulty: challengeResponse.difficulty,
      );

      final payload =
          '${challengeResponse.challenge}:${AccountMethods.createAccount}:$pubKey';
      final signature = SigningTestHelper.signWith(payload, privKey);

      const ultimateEncryptionPublicKeyHex =
          '04b123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
          'b123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

      // Generate device keypair and attestation. Task 6 widens the wire
      // shape to a PublicKeyDuo with two distinct halves.
      final (devicePrivKey, devicePubKey) = SigningTestHelper.generateKeypair();
      final (_, deviceEncPubKey) = SigningTestHelper.generateKeypair();
      final deviceAttestation = SigningTestHelper.signWith(devicePubKey, privKey);

      final account = await endpoints.account.createAccount(
        sessionBuilder,
        challenge: challengeResponse.challenge,
        proofOfWork: proofOfWork,
        signature: signature,
        publicKeyHex: pubKey,
        ultimateKeys: PublicKeyDuo(
          signingPublicKeyHex: pubKey,
          encryptionPublicKeyHex: ultimateEncryptionPublicKeyHex,
        ),
        encryptedDataKey: 'test-encrypted-data-key',
        deviceKeys: PublicKeyDuo(
          signingPublicKeyHex: devicePubKey,
          encryptionPublicKeyHex: deviceEncPubKey,
        ),
        deviceKeyAttestation: deviceAttestation,
        deviceEncryptedDataKey: 'test-device-data-key',
        deviceLabel: 'test-device',
      );

      expect(
        account.ultimateSigningPublicKeyHex,
        equals(pubKey),
      );
      expect(account.encryptedDataKey, equals('test-encrypted-data-key'));
      expect(account.createdAt, isNotNull);
    });

    test('createAccount fails with duplicate signing key', () async {
      // Use unique keypair to avoid rate limit collisions
      final (privKey, pubKey) = SigningTestHelper.generateKeypair();

      // Create first account via direct DB insert
      await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: pubKey,
        ultimateEncryptionPublicKeyHex:
            '04c123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
            'c123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      );

      // Try to create second account with same signing key via PoW
      final challengeResponse =
          await endpoints.entrypoint.getChallenge(sessionBuilder);
      final proofOfWork = await PowTestHelper.mint(
        challengeResponse.challenge,
        difficulty: challengeResponse.difficulty,
      );
      final payload =
          '${challengeResponse.challenge}:${AccountMethods.createAccount}:$pubKey';
      final signature = SigningTestHelper.signWith(payload, privKey);

      final (devicePrivKey2, devicePubKey2) = SigningTestHelper.generateKeypair();
      final (_, deviceEncPubKey2) = SigningTestHelper.generateKeypair();
      final deviceAttestation2 = SigningTestHelper.signWith(devicePubKey2, privKey);

      expect(
        () => endpoints.account.createAccount(
          sessionBuilder,
          challenge: challengeResponse.challenge,
          proofOfWork: proofOfWork,
          signature: signature,
          publicKeyHex: pubKey,
          ultimateKeys: PublicKeyDuo(
            signingPublicKeyHex: pubKey,
            encryptionPublicKeyHex:
                '04d123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
                'd123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
          ),
          encryptedDataKey: 'test-encrypted-data-key-2',
          deviceKeys: PublicKeyDuo(
            signingPublicKeyHex: devicePubKey2,
            encryptionPublicKeyHex: deviceEncPubKey2,
          ),
          deviceKeyAttestation: deviceAttestation2,
          deviceEncryptedDataKey: 'test-device-data-key-2',
          deviceLabel: 'test-device-2',
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('AccountQueryService.getAccountByPublicKey lookups work', () async {
      const validPublicKey =
          '041123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
          '1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

      final created = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: validPublicKey,
      );

      final session =
          (sessionBuilder as InternalTestSessionBuilder).internalBuild(
        endpoint: 'test',
        method: 'getAccountByPublicKey',
      );
      try {
        final found = await AccountQueryService.getAccountByPublicKey(
          session,
          validPublicKey,
        );
        expect(found, isNotNull);
        expect(
          found!.ultimateSigningPublicKeyHex,
          equals(created.ultimateSigningPublicKeyHex),
        );
      } finally {
        await session.close();
      }
    });

    test('encrypted data preservation - data stored without decryption',
        () async {
      const validPublicKey =
          '047123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
          '7123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
      const originalEncryptedData =
          r'complex_encrypted_data_with_special_chars_!@#$%^&*()';

      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: validPublicKey,
        encryptedDataKey: originalEncryptedData,
      );

      expect(account.encryptedDataKey, equals(originalEncryptedData));
    });
  });
}
