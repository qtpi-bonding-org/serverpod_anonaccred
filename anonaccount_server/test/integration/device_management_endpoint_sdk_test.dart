import 'package:anonaccount_protocol/anonaccount_protocol.dart'
    show AccountInnerPayloads, PublicKeyDuo;
import 'package:anonaccount_server/anonaccount_server.dart'
    show AccountDevice;
import 'package:anonaccount_server/src/generated/authentication_exception.dart';
import 'package:anonaccount_sdk/anonaccount_sdk.dart' hide AccountDevice;
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import 'test_tools/sdk_test_caller.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/simulated_user.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('DeviceManagementEndpoint Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    Future<KeyDuo> ultimateKeyOf(SimulatedUser user) =>
        InMemoryAccountKeyStore().importUltimateKeyJwk(user.ultimateBackupJwk!);

    test('revokeDevice stamps revokedAt', () async {
      final alice = SimulatedUser(sessionBuilder, endpoints, label: 'alice');
      await alice.onboard();
      await alice.addDeviceViaPairing(label: 'secondary');
      final deviceId = await alice.primaryDeviceId();

      final ok = await alice.revokeDevice(deviceId);
      expect(ok, isTrue);

      final session = (sessionBuilder as InternalTestSessionBuilder)
          .internalBuild(endpoint: 'test', method: 'checkRevoked');
      try {
        final row = await AccountDevice.db.findById(session, deviceId);
        expect(row!.isRevoked, isTrue);
        expect(row.revokedAt, isNotNull);
      } finally {
        await session.close();
      }
    });

    test(
      'revokeDevice refuses to revoke the account\'s last active device',
      () async {
        final alice = SimulatedUser(sessionBuilder, endpoints, label: 'alice');
        await alice.onboard();
        final deviceId = await alice.primaryDeviceId();

        await expectLater(
          alice.revokeDevice(deviceId),
          throwsA(isA<AuthenticationException>()),
        );

        final row = (await AccountDevice.db.findById(
          sessionBuilder.build(),
          deviceId,
        ))!;
        expect(row.isRevoked, isFalse);
      },
    );

    test('a revoked device cannot pair a new device', () async {
      final alice = SimulatedUser(sessionBuilder, endpoints, label: 'alice');
      await alice.onboard();
      await alice.addDeviceViaPairing(label: 'secondary');
      final deviceId = await alice.primaryDeviceId();
      final deviceKey = await alice.deviceKey;
      final deviceHex = await alice.deviceKeyHex();
      await alice.revokeDevice(deviceId);

      final newDevice = await KeyGen.generateDeviceKey();
      final newDeviceDuo = await newDevice.exportPublicKeyDuo();
      final newDeviceKeys = PublicKeyDuo(
        signingPublicKeyHex: newDeviceDuo.signing.value,
        encryptionPublicKeyHex: newDeviceDuo.encryption.value,
      );
      final pairingAttestation = await SigningCrypto.signChallenge(
        AccountInnerPayloads.pairDevice(newDeviceKeys),
        deviceKey,
      );
      final envelope = await alice.caller.buildEnvelope(
        methodName: 'registerDeviceForAccount',
        signingKey: deviceKey,
        publicKeyHex: deviceHex,
      );

      await expectLater(
        alice.caller.deviceManagement.registerDeviceForAccount(
          challenge: envelope.challenge,
          proofOfWork: envelope.proofOfWork,
          publicKeyHex: deviceHex,
          signature: envelope.signature,
          newDeviceKeys: newDeviceKeys,
          pairingAttestation: pairingAttestation,
          newDeviceEncryptedDataKey: 'paired-device-data-key',
          label: 'paired-device',
          ultimateEncryptionPublicKeyHex: 'ultimate-enc-pub',
          ultimateSigningPublicKeyHex: 'ultimate-sig-pub',
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('rejects a pairing attestation signed by a non-caller key', () async {
      final alice = SimulatedUser(sessionBuilder, endpoints, label: 'alice');
      await alice.onboard();
      final deviceKey = await alice.deviceKey;
      final deviceHex = await alice.deviceKeyHex();

      final newDevice = await KeyGen.generateDeviceKey();
      final newDeviceDuo = await newDevice.exportPublicKeyDuo();
      final newDeviceKeys = PublicKeyDuo(
        signingPublicKeyHex: newDeviceDuo.signing.value,
        encryptionPublicKeyHex: newDeviceDuo.encryption.value,
      );

      // Attestation signed by an UNRELATED key, not the caller device.
      final foreign = await KeyGen.generateDeviceKey();
      final pairingAttestation = await SigningCrypto.signChallenge(
        AccountInnerPayloads.pairDevice(newDeviceKeys),
        foreign,
      );
      final envelope = await alice.caller.buildEnvelope(
        methodName: 'registerDeviceForAccount',
        signingKey: deviceKey,
        publicKeyHex: deviceHex,
      );

      await expectLater(
        alice.caller.deviceManagement.registerDeviceForAccount(
          challenge: envelope.challenge,
          proofOfWork: envelope.proofOfWork,
          publicKeyHex: deviceHex,
          signature: envelope.signature,
          newDeviceKeys: newDeviceKeys,
          pairingAttestation: pairingAttestation,
          newDeviceEncryptedDataKey: 'paired-device-data-key',
          label: 'paired-device',
          ultimateEncryptionPublicKeyHex: 'ultimate-enc-pub',
          ultimateSigningPublicKeyHex: 'ultimate-sig-pub',
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('persists the pairing attestation and its signer', () async {
      final alice = SimulatedUser(sessionBuilder, endpoints, label: 'alice');
      await alice.onboard();
      final deviceKey = await alice.deviceKey;
      final deviceHex = await alice.deviceKeyHex();
      final primaryId = await alice.primaryDeviceId();

      final newDevice = await KeyGen.generateDeviceKey();
      final newDeviceDuo = await newDevice.exportPublicKeyDuo();
      final newDeviceKeys = PublicKeyDuo(
        signingPublicKeyHex: newDeviceDuo.signing.value,
        encryptionPublicKeyHex: newDeviceDuo.encryption.value,
      );
      final pairingAttestation = await SigningCrypto.signChallenge(
        AccountInnerPayloads.pairDevice(newDeviceKeys),
        deviceKey,
      );
      final envelope = await alice.caller.buildEnvelope(
        methodName: 'registerDeviceForAccount',
        signingKey: deviceKey,
        publicKeyHex: deviceHex,
      );

      final device = await alice.caller.deviceManagement
          .registerDeviceForAccount(
            challenge: envelope.challenge,
            proofOfWork: envelope.proofOfWork,
            publicKeyHex: deviceHex,
            signature: envelope.signature,
            newDeviceKeys: newDeviceKeys,
            pairingAttestation: pairingAttestation,
            newDeviceEncryptedDataKey: 'paired-device-data-key',
            label: 'paired-device',
            ultimateEncryptionPublicKeyHex: 'ultimate-enc-pub',
            ultimateSigningPublicKeyHex: 'ultimate-sig-pub',
          );

      final primaryRow = (await AccountDevice.db.findById(
        sessionBuilder.build(),
        primaryId,
      ))!;
      expect(device.addedByAttestorPublicKeyHex, deviceHex);
      expect(device.addedByAttestation, pairingAttestation);
      expect(device.anonAccountId, primaryRow.anonAccountId);
    });

    test('listDevices rejects a revoked device key', () async {
      final alice = SimulatedUser(sessionBuilder, endpoints, label: 'alice');
      await alice.onboard();
      await alice.addDeviceViaPairing(label: 'secondary');
      final deviceHex = await alice.deviceKeyHex();
      final deviceKey = await alice.deviceKey;
      await alice.revokeDevice(await alice.primaryDeviceId());

      final envelope = await alice.caller.buildEnvelope(
        methodName: 'listDevices',
        signingKey: deviceKey,
        publicKeyHex: deviceHex,
      );

      await expectLater(
        alice.caller.deviceManagement.listDevices(
          challenge: envelope.challenge,
          proofOfWork: envelope.proofOfWork,
          publicKeyHex: deviceHex,
          signature: envelope.signature,
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('listDevices keeps the ultimate-key fallback', () async {
      final alice = SimulatedUser(sessionBuilder, endpoints, label: 'alice');
      await alice.onboard();
      final ultimate = await ultimateKeyOf(alice);
      final ultimateHex = (await ultimate.exportPublicKeyDuo()).signing.value;

      final envelope = await alice.caller.buildEnvelope(
        methodName: 'listDevices',
        signingKey: ultimate,
        publicKeyHex: ultimateHex,
      );
      final result = await alice.caller.deviceManagement.listDevices(
        challenge: envelope.challenge,
        proofOfWork: envelope.proofOfWork,
        publicKeyHex: ultimateHex,
        signature: envelope.signature,
      );

      expect(result, hasLength(1));
    });
  });
}
