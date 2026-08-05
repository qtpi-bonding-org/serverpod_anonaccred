import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'test_tools/sdk_test_caller.dart';
import 'test_tools/serverpod_test_tools.dart';

Future<String> _deviceAttestation(
  PublicKeyDuo deviceKeys,
  KeyDuo attestor,
) => SigningCrypto.signChallenge(
  AccountInnerPayloads.registerDevice(deviceKeys),
  attestor,
);

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
      final caller = SdkTestCaller(sessionBuilder, endpoints);
      final ultimate = await KeyGen.generateUltimateKey();
      final ultimateHex = (await ultimate.exportPublicKeyDuo()).signing.value;
      final device = await KeyGen.generateDeviceKey();
      final deviceDuo = await device.exportPublicKeyDuo();
      final deviceKeys = PublicKeyDuo(
        signingPublicKeyHex: deviceDuo.signing.value,
        encryptionPublicKeyHex: deviceDuo.encryption.value,
      );

      final envelope = await caller.buildEnvelope(
        methodName: 'createAccount',
        signingKey: ultimate,
        publicKeyHex: ultimateHex,
      );

      final account = await caller.account.createAccount(
        challenge: envelope.challenge,
        proofOfWork: envelope.proofOfWork,
        signature: envelope.signature,
        publicKeyHex: ultimateHex,
        ultimateKeys: PublicKeyDuo(
          signingPublicKeyHex: ultimateHex,
          encryptionPublicKeyHex:
              (await ultimate.exportPublicKeyDuo()).encryption.value,
        ),
        encryptedDataKey: 'test-encrypted-data-key',
        deviceKeys: deviceKeys,
        deviceKeyAttestation: await _deviceAttestation(deviceKeys, ultimate),
        deviceEncryptedDataKey: 'test-device-data-key',
        deviceLabel: 'test-device',
      );

      expect(account.ultimateSigningPublicKeyHex, equals(ultimateHex));
      expect(account.encryptedDataKey, equals('test-encrypted-data-key'));
      expect(account.createdAt, isNotNull);
    });

    test('createAccount fails with duplicate signing key', () async {
      final caller = SdkTestCaller(sessionBuilder, endpoints);
      final ultimate = await KeyGen.generateUltimateKey();
      final ultimateHex = (await ultimate.exportPublicKeyDuo()).signing.value;

      // Existing account with the same ultimate signing key, via direct
      // DB insert (bypasses PoW — not what's under test here).
      await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: ultimateHex,
      );

      final device = await KeyGen.generateDeviceKey();
      final deviceDuo = await device.exportPublicKeyDuo();
      final deviceKeys = PublicKeyDuo(
        signingPublicKeyHex: deviceDuo.signing.value,
        encryptionPublicKeyHex: deviceDuo.encryption.value,
      );
      final envelope = await caller.buildEnvelope(
        methodName: 'createAccount',
        signingKey: ultimate,
        publicKeyHex: ultimateHex,
      );

      await expectLater(
        () async => caller.account.createAccount(
          challenge: envelope.challenge,
          proofOfWork: envelope.proofOfWork,
          signature: envelope.signature,
          publicKeyHex: ultimateHex,
          ultimateKeys: PublicKeyDuo(
            signingPublicKeyHex: ultimateHex,
            encryptionPublicKeyHex:
                (await ultimate.exportPublicKeyDuo()).encryption.value,
          ),
          encryptedDataKey: 'test-encrypted-data-key-2',
          deviceKeys: deviceKeys,
          deviceKeyAttestation: await _deviceAttestation(deviceKeys, ultimate),
          deviceEncryptedDataKey: 'test-device-data-key-2',
          deviceLabel: 'test-device-2',
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('rejects an attestation over a different encryption key', () async {
      final caller = SdkTestCaller(sessionBuilder, endpoints);
      final ultimate = await KeyGen.generateUltimateKey();
      final ultimateHex = (await ultimate.exportPublicKeyDuo()).signing.value;
      final device = await KeyGen.generateDeviceKey();
      final deviceDuo = await device.exportPublicKeyDuo();
      final realDeviceKeys = PublicKeyDuo(
        signingPublicKeyHex: deviceDuo.signing.value,
        encryptionPublicKeyHex: deviceDuo.encryption.value,
      );
      // Compute the attestation over the real duo, then swap in a THIRD
      // key for the encryption half of the request — the attestation no
      // longer covers what's actually being registered.
      final attestation = await _deviceAttestation(realDeviceKeys, ultimate);
      final substituted = await KeyGen.generateDeviceKey();
      final substitutedEncHex =
          (await substituted.exportPublicKeyDuo()).encryption.value;

      final envelope = await caller.buildEnvelope(
        methodName: 'createAccount',
        signingKey: ultimate,
        publicKeyHex: ultimateHex,
      );

      await expectLater(
        caller.account.createAccount(
          challenge: envelope.challenge,
          proofOfWork: envelope.proofOfWork,
          signature: envelope.signature,
          publicKeyHex: ultimateHex,
          ultimateKeys: PublicKeyDuo(
            signingPublicKeyHex: ultimateHex,
            encryptionPublicKeyHex:
                (await ultimate.exportPublicKeyDuo()).encryption.value,
          ),
          encryptedDataKey: 'test-encrypted-data-key-mismatch',
          deviceKeys: PublicKeyDuo(
            signingPublicKeyHex: deviceDuo.signing.value,
            // Substituted after the attestation was computed.
            encryptionPublicKeyHex: substitutedEncHex,
          ),
          deviceKeyAttestation: attestation,
          deviceEncryptedDataKey: 'test-device-data-key-mismatch',
          deviceLabel: 'test-device-mismatch',
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('a failed device insert leaves no orphan account', () async {
      final caller = SdkTestCaller(sessionBuilder, endpoints);
      final ultimate = await KeyGen.generateUltimateKey();
      final ultimateHex = (await ultimate.exportPublicKeyDuo()).signing.value;
      final device = await KeyGen.generateDeviceKey();
      final deviceDuo = await device.exportPublicKeyDuo();
      final deviceKeys = PublicKeyDuo(
        signingPublicKeyHex: deviceDuo.signing.value,
        encryptionPublicKeyHex: deviceDuo.encryption.value,
      );

      // Register the device key once (as its own account) so the SECOND
      // createAccount below — using a fresh ultimate key but the SAME
      // device key — fails at the device-insert step.
      final firstEnvelope = await caller.buildEnvelope(
        methodName: 'createAccount',
        signingKey: device,
        publicKeyHex: deviceDuo.signing.value,
      );
      await caller.account.createAccount(
        challenge: firstEnvelope.challenge,
        proofOfWork: firstEnvelope.proofOfWork,
        signature: firstEnvelope.signature,
        publicKeyHex: deviceDuo.signing.value,
        ultimateKeys: PublicKeyDuo(
          signingPublicKeyHex: ultimateHex,
          encryptionPublicKeyHex:
              (await ultimate.exportPublicKeyDuo()).encryption.value,
        ),
        encryptedDataKey: 'orphan-guard-first-account',
        deviceKeys: deviceKeys,
        deviceKeyAttestation: await _deviceAttestation(deviceKeys, ultimate),
        deviceEncryptedDataKey: 'orphan-guard-first-device',
        deviceLabel: 'orphan-guard-first-device-label',
      );

      // Second createAccount: fresh ultimate key, SAME device signing key.
      final newUltimate = await KeyGen.generateUltimateKey();
      final newUltimateHex =
          (await newUltimate.exportPublicKeyDuo()).signing.value;
      final secondEnvelope = await caller.buildEnvelope(
        methodName: 'createAccount',
        signingKey: device,
        publicKeyHex: deviceDuo.signing.value,
      );

      await expectLater(
        caller.account.createAccount(
          challenge: secondEnvelope.challenge,
          proofOfWork: secondEnvelope.proofOfWork,
          signature: secondEnvelope.signature,
          publicKeyHex: deviceDuo.signing.value,
          ultimateKeys: PublicKeyDuo(
            signingPublicKeyHex: newUltimateHex,
            encryptionPublicKeyHex:
                (await newUltimate.exportPublicKeyDuo()).encryption.value,
          ),
          encryptedDataKey: 'orphan-guard-second-account',
          deviceKeys: deviceKeys,
          deviceKeyAttestation: await _deviceAttestation(
            deviceKeys,
            newUltimate,
          ),
          deviceEncryptedDataKey: 'orphan-guard-second-device',
          deviceLabel: 'orphan-guard-second-device-label',
        ),
        throwsA(isA<AuthenticationException>()),
      );

      final orphan = await AnonAccount.db.findFirstRow(
        (sessionBuilder as InternalTestSessionBuilder).internalBuild(
          endpoint: 'test',
          method: 'checkOrphan',
        ),
        where: (t) => t.ultimateSigningPublicKeyHex.equals(newUltimateHex),
      );
      expect(orphan, isNull);
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

    test(
      'encrypted data preservation - data stored without decryption',
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
      },
    );
  });
}
