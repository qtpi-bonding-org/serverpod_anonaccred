import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('AccountEndpoint Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    test('getChallenge returns valid challenge response', () async {
      final challenge = await endpoints.account.getChallenge(sessionBuilder);

      expect(challenge.challenge, hasLength(32));
      expect(challenge.difficulty, equals(20));
      expect(challenge.expiresAt, greaterThan(0));
    });

    test('createAccount with valid PoW succeeds', () async {
      // Use unique keypair to avoid rate limit collisions across tests
      final (privKey, pubKey) = SigningTestHelper.generateKeypair();

      final challengeResponse =
          await endpoints.account.getChallenge(sessionBuilder);

      final proofOfWork = await PowTestHelper.mint(
        challengeResponse.challenge,
        difficulty: challengeResponse.difficulty,
      );

      final payload =
          '${challengeResponse.challenge}:createAccount:$pubKey';
      final signature = SigningTestHelper.signWith(payload, privKey);

      const ultimatePublicKey =
          'b123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
          'b123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

      final account = await endpoints.account.createAccount(
        sessionBuilder,
        challenge: challengeResponse.challenge,
        proofOfWork: proofOfWork,
        signature: signature,
        publicKeyHex: pubKey,
        ultimateSigningPublicKeyHex: pubKey,
        encryptedDataKey: 'test-encrypted-data-key',
        ultimatePublicKey: ultimatePublicKey,
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
        ultimatePublicKey:
            'c123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
            'c123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      );

      // Try to create second account with same signing key via PoW
      final challengeResponse =
          await endpoints.account.getChallenge(sessionBuilder);
      final proofOfWork = await PowTestHelper.mint(
        challengeResponse.challenge,
        difficulty: challengeResponse.difficulty,
      );
      final payload =
          '${challengeResponse.challenge}:createAccount:$pubKey';
      final signature = SigningTestHelper.signWith(payload, privKey);

      expect(
        () => endpoints.account.createAccount(
          sessionBuilder,
          challenge: challengeResponse.challenge,
          proofOfWork: proofOfWork,
          signature: signature,
          publicKeyHex: pubKey,
          ultimateSigningPublicKeyHex: pubKey,
          encryptedDataKey: 'test-encrypted-data-key-2',
          ultimatePublicKey:
              'd123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
              'd123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('getAccountForRecovery with valid PoW succeeds', () async {
      // Create an account to recover — use a generated keypair for the
      // ultimate key so we can sign the recovery payload with its private key
      final (signingPrivKey, signingPubKey) = SigningTestHelper.generateKeypair();
      final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

      await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: signingPubKey,
        ultimatePublicKey: ultimatePubKey,
      );

      // Recover via PoW — signature verified against ultimatePublicKey
      final challengeResponse =
          await endpoints.account.getChallenge(sessionBuilder);
      final proofOfWork = await PowTestHelper.mint(
        challengeResponse.challenge,
        difficulty: challengeResponse.difficulty,
      );
      final payload =
          '${challengeResponse.challenge}:getAccountForRecovery:$ultimatePubKey';
      final signature = SigningTestHelper.signWith(payload, ultimatePrivKey);

      final recovered = await endpoints.account.getAccountForRecovery(
        sessionBuilder,
        challenge: challengeResponse.challenge,
        proofOfWork: proofOfWork,
        ultimatePublicKey: ultimatePubKey,
        signature: signature,
      );

      expect(recovered, isNotNull);
      expect(
        recovered!.ultimateSigningPublicKeyHex,
        equals(signingPubKey),
      );
    });

    test('getAccountForRecovery returns null for non-existent account',
        () async {
      // Generate a keypair to use as the ultimate key — must sign with
      // matching private key since signature is verified against ultimatePublicKey
      final (ultimatePrivKey, ultimatePubKey) = SigningTestHelper.generateKeypair();

      final challengeResponse =
          await endpoints.account.getChallenge(sessionBuilder);
      final proofOfWork = await PowTestHelper.mint(
        challengeResponse.challenge,
        difficulty: challengeResponse.difficulty,
      );
      final payload =
          '${challengeResponse.challenge}:getAccountForRecovery:$ultimatePubKey';
      final signature = SigningTestHelper.signWith(payload, ultimatePrivKey);

      final recovered = await endpoints.account.getAccountForRecovery(
        sessionBuilder,
        challenge: challengeResponse.challenge,
        proofOfWork: proofOfWork,
        ultimatePublicKey: ultimatePubKey,
        signature: signature,
      );

      expect(recovered, isNull);
    });

    test('AccountQueryService.getAccountByPublicKey lookups work', () async {
      const validPublicKey =
          '1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
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
          '7123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
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
