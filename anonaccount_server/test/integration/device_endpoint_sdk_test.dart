import 'package:anonaccount_protocol/anonaccount_protocol.dart'
    show AccountInnerPayloads, PublicKeyDuo;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:anonaccount_server/src/generated/authentication_exception.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'test_tools/sdk_test_caller.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('DeviceEndpoint Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    Future<AccountDevice> registerRealDevice(
      SdkTestCaller caller, {
      required KeyDuo ultimate,
      required String ultimateHex,
      required KeyDuo device,
      required String encryptedDataKey,
      required String label,
    }) async {
      final deviceDuo = await device.exportPublicKeyDuo();
      final deviceKeys = PublicKeyDuo(
        signingPublicKeyHex: deviceDuo.signing.value,
        encryptionPublicKeyHex: deviceDuo.encryption.value,
      );
      final attestation = await SigningCrypto.signChallenge(
        AccountInnerPayloads.registerDevice(deviceKeys),
        ultimate,
      );
      final envelope = await caller.buildEnvelope(
        methodName: 'registerDevice',
        signingKey: device,
        publicKeyHex: deviceDuo.signing.value,
      );
      return caller.device.registerDevice(
        challenge: envelope.challenge,
        proofOfWork: envelope.proofOfWork,
        signature: envelope.signature,
        deviceKeyAttestation: attestation,
        ultimateSigningPublicKeyHex: ultimateHex,
        deviceKeys: deviceKeys,
        encryptedDataKey: encryptedDataKey,
        label: label,
      );
    }

    test(
      'registerDevice - should register device successfully with valid data',
      () async {
        final caller = SdkTestCaller(sessionBuilder, endpoints);
        final ultimate = await KeyGen.generateUltimateKey();
        final ultimateHex = (await ultimate.exportPublicKeyDuo()).signing.value;
        final testAccount = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimateHex,
          encryptedDataKey: 'encrypted_test_data_key',
          ultimateEncryptionPublicKeyHex: ultimateHex,
        );
        final device = await KeyGen.generateDeviceKey();
        final deviceHex = (await device.exportPublicKeyDuo()).signing.value;

        final result = await registerRealDevice(
          caller,
          ultimate: ultimate,
          ultimateHex: ultimateHex,
          device: device,
          encryptedDataKey: 'device_encrypted_data_key',
          label: 'Test Device',
        );

        expect(result.id, isNotNull);
        expect(result.anonAccountId, equals(testAccount.id));
        expect(result.deviceSigningPublicKeyHex, equals(deviceHex));
        expect(result.label, equals('Test Device'));
        expect(result.isRevoked, isFalse);
        expect(result.lastActive, isNotNull);
      },
    );

    test(
      'registerDevice persists the encryption key and its attestation',
      () async {
        final caller = SdkTestCaller(sessionBuilder, endpoints);
        final ultimate = await KeyGen.generateUltimateKey();
        final ultimateHex = (await ultimate.exportPublicKeyDuo()).signing.value;
        await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimateHex,
          encryptedDataKey: 'encrypted_test_data_key_roundtrip',
          ultimateEncryptionPublicKeyHex: ultimateHex,
        );
        final device = await KeyGen.generateDeviceKey();

        final result = await registerRealDevice(
          caller,
          ultimate: ultimate,
          ultimateHex: ultimateHex,
          device: device,
          encryptedDataKey: 'device_encrypted_data_key_roundtrip',
          label: 'Roundtrip Test Device',
        );

        expect(result.deviceEncryptionPublicKeyHex, hasLength(130));
        expect(result.addedByAttestation, isNotEmpty);
        expect(result.addedByAttestorPublicKeyHex, ultimateHex);
        expect(result.createdAt, isNotNull);
        expect(result.revokedAt, isNull);
      },
    );

    test(
      'rejects an attestation that covers a different encryption key',
      () async {
        final caller = SdkTestCaller(sessionBuilder, endpoints);
        final ultimate = await KeyGen.generateUltimateKey();
        final ultimateHex = (await ultimate.exportPublicKeyDuo()).signing.value;
        await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimateHex,
          encryptedDataKey: 'encrypted_test_data_key_mismatch',
          ultimateEncryptionPublicKeyHex: ultimateHex,
        );

        final device = await KeyGen.generateDeviceKey();
        final deviceDuo = await device.exportPublicKeyDuo();
        final realDeviceKeys = PublicKeyDuo(
          signingPublicKeyHex: deviceDuo.signing.value,
          encryptionPublicKeyHex: deviceDuo.encryption.value,
        );
        final attestation = await SigningCrypto.signChallenge(
          AccountInnerPayloads.registerDevice(realDeviceKeys),
          ultimate,
        );
        final substituted = await KeyGen.generateDeviceKey();
        final substitutedEncHex =
            (await substituted.exportPublicKeyDuo()).encryption.value;

        final envelope = await caller.buildEnvelope(
          methodName: 'registerDevice',
          signingKey: device,
          publicKeyHex: deviceDuo.signing.value,
        );

        await expectLater(
          caller.device.registerDevice(
            challenge: envelope.challenge,
            proofOfWork: envelope.proofOfWork,
            signature: envelope.signature,
            deviceKeyAttestation: attestation,
            ultimateSigningPublicKeyHex: ultimateHex,
            deviceKeys: PublicKeyDuo(
              signingPublicKeyHex: deviceDuo.signing.value,
              encryptionPublicKeyHex: substitutedEncHex,
            ),
            encryptedDataKey: 'device_encrypted_data_key_mismatch',
            label: 'Mismatch Test Device',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      },
    );

    test(
      'registerDevice - should reject duplicate public subkey registration',
      () async {
        final caller = SdkTestCaller(sessionBuilder, endpoints);
        final ultimate = await KeyGen.generateUltimateKey();
        final ultimateHex = (await ultimate.exportPublicKeyDuo()).signing.value;
        await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimateHex,
          encryptedDataKey: 'encrypted_test_data_key_2',
          ultimateEncryptionPublicKeyHex: ultimateHex,
        );
        final device = await KeyGen.generateDeviceKey();

        await registerRealDevice(
          caller,
          ultimate: ultimate,
          ultimateHex: ultimateHex,
          device: device,
          encryptedDataKey: 'device_encrypted_data_key',
          label: 'Test Device',
        );

        await expectLater(
          registerRealDevice(
            caller,
            ultimate: ultimate,
            ultimateHex: ultimateHex,
            device: device,
            encryptedDataKey: 'different_encrypted_data_key',
            label: 'Different Device',
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('registerDevice - should reject invalid public subkey format', () async {
      final caller = SdkTestCaller(sessionBuilder, endpoints);
      final ultimate = await KeyGen.generateUltimateKey();
      final ultimateHex = (await ultimate.exportPublicKeyDuo()).signing.value;
      await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: ultimateHex,
        encryptedDataKey: 'encrypted_test_data_key_3',
        ultimateEncryptionPublicKeyHex: ultimateHex,
      );

      const invalidKeyHex = 'invalid_key_format';
      // Attestation over an invalid key format — fails at attestation
      // verification since invalidKeyHex is not a valid public key.
      final attestation = await SigningCrypto.signChallenge(
        invalidKeyHex,
        ultimate,
      );
      final envelope = await caller.buildEnvelope(
        methodName: 'registerDevice',
        signingKey: ultimate,
        publicKeyHex: invalidKeyHex,
      );

      await expectLater(
        caller.device.registerDevice(
          challenge: envelope.challenge,
          proofOfWork: envelope.proofOfWork,
          signature: envelope.signature,
          deviceKeyAttestation: attestation,
          ultimateSigningPublicKeyHex: ultimateHex,
          deviceKeys: PublicKeyDuo(
            signingPublicKeyHex: invalidKeyHex,
            encryptionPublicKeyHex: invalidKeyHex,
          ),
          encryptedDataKey: 'device_encrypted_data_key',
          label: 'Test Device',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'registerDevice - should reject registration for non-existent account',
      () async {
        final caller = SdkTestCaller(sessionBuilder, endpoints);
        final device = await KeyGen.generateDeviceKey();
        final deviceDuo = await device.exportPublicKeyDuo();
        final nonExistent = await KeyGen.generateUltimateKey();
        final nonExistentHex =
            (await nonExistent.exportPublicKeyDuo()).signing.value;

        final attestation = await SigningCrypto.signChallenge(
          AccountInnerPayloads.registerDevice(
            PublicKeyDuo(
              signingPublicKeyHex: deviceDuo.signing.value,
              encryptionPublicKeyHex: deviceDuo.encryption.value,
            ),
          ),
          nonExistent,
        );
        final envelope = await caller.buildEnvelope(
          methodName: 'registerDevice',
          signingKey: device,
          publicKeyHex: deviceDuo.signing.value,
        );

        await expectLater(
          caller.device.registerDevice(
            challenge: envelope.challenge,
            proofOfWork: envelope.proofOfWork,
            signature: envelope.signature,
            deviceKeyAttestation: attestation,
            ultimateSigningPublicKeyHex: nonExistentHex,
            deviceKeys: PublicKeyDuo(
              signingPublicKeyHex: deviceDuo.signing.value,
              encryptionPublicKeyHex: deviceDuo.encryption.value,
            ),
            encryptedDataKey: 'device_encrypted_data_key',
            label: 'Test Device',
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('registerDevice - should reject invalid attestation', () async {
      final caller = SdkTestCaller(sessionBuilder, endpoints);
      final ultimate = await KeyGen.generateUltimateKey();
      final ultimateHex = (await ultimate.exportPublicKeyDuo()).signing.value;
      await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: ultimateHex,
        encryptedDataKey: 'encrypted_test_data_key_attest',
        ultimateEncryptionPublicKeyHex: ultimateHex,
      );
      final device = await KeyGen.generateDeviceKey();
      final deviceDuo = await device.exportPublicKeyDuo();

      // Signed with the WRONG key (device key instead of ultimate).
      final badAttestation = await SigningCrypto.signChallenge(
        deviceDuo.signing.value,
        device,
      );
      final envelope = await caller.buildEnvelope(
        methodName: 'registerDevice',
        signingKey: device,
        publicKeyHex: deviceDuo.signing.value,
      );

      await expectLater(
        caller.device.registerDevice(
          challenge: envelope.challenge,
          proofOfWork: envelope.proofOfWork,
          signature: envelope.signature,
          deviceKeyAttestation: badAttestation,
          ultimateSigningPublicKeyHex: ultimateHex,
          deviceKeys: PublicKeyDuo(
            signingPublicKeyHex: deviceDuo.signing.value,
            encryptionPublicKeyHex: deviceDuo.encryption.value,
          ),
          encryptedDataKey: 'device_encrypted_data_key',
          label: 'Test Device',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('signIn - should produce unique auth results per call', () async {
      final caller = SdkTestCaller(sessionBuilder, endpoints);
      final ultimate = await KeyGen.generateUltimateKey();
      final ultimateHex = (await ultimate.exportPublicKeyDuo()).signing.value;
      await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: ultimateHex,
        encryptedDataKey: 'encrypted_test_data_key_challenge',
        ultimateEncryptionPublicKeyHex: ultimateHex,
      );
      final device = await KeyGen.generateDeviceKey();
      final deviceHex = (await device.exportPublicKeyDuo()).signing.value;

      await registerRealDevice(
        caller,
        ultimate: ultimate,
        ultimateHex: ultimateHex,
        device: device,
        encryptedDataKey: 'device_encrypted_data_key_challenge',
        label: 'Challenge Test Device',
      );

      Future<AuthenticationResult> signIn() async {
        final envelope = await caller.buildEnvelope(
          methodName: 'signIn',
          signingKey: device,
          publicKeyHex: deviceHex,
        );
        return caller.device.signIn(
          challenge: envelope.challenge,
          proofOfWork: envelope.proofOfWork,
          signature: envelope.signature,
          devicePublicKeyHex: deviceHex,
        );
      }

      final result1 = await signIn();
      final result2 = await signIn();

      expect(result1, isNotNull);
      expect(result2, isNotNull);
    });
  });
}
