import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'test_tools/serverpod_test_tools.dart';

/// Bootstraps an account with one active, real device (via the actual
/// registerDevice endpoint, not a direct DB insert) so callerDevice.
/// deviceSigningPublicKeyHex round-trips exactly as production traffic
/// would produce it.
Future<
    ({
      String ultimatePriv,
      String ultimatePub,
      String devicePriv,
      String devicePub,
      AccountDevice device,
    })> _bootstrapAccountWithDevice(
  TestSessionBuilder sessionBuilder,
  TestEndpoints endpoints,
) async {
  final (ultimatePriv, ultimatePub) = SigningTestHelper.generateKeypair();
  await createTestAccount(
    sessionBuilder,
    ultimateSigningPublicKeyHex: ultimatePub,
    ultimateEncryptionPublicKeyHex: ultimatePub,
  );

  final (devicePriv, devicePub) = SigningTestHelper.generateKeypair();
  final (_, deviceEncPub) = SigningTestHelper.generateKeypair();

  final regChallenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
  final regPow = await PowTestHelper.mint(
    regChallenge.challenge,
    difficulty: regChallenge.difficulty,
  );
  final regPayload =
      '${regChallenge.challenge}:${DeviceMethods.registerDevice}:$devicePub';
  final regSignature = SigningTestHelper.signWith(regPayload, devicePriv);
  final deviceKeyAttestation = SigningTestHelper.signWith(
    AccountInnerPayloads.registerDevice(
      PublicKeyDuo(
        signingPublicKeyHex: devicePub,
        encryptionPublicKeyHex: deviceEncPub,
      ),
    ),
    ultimatePriv,
  );

  final device = await endpoints.device.registerDevice(
    sessionBuilder,
    challenge: regChallenge.challenge,
    proofOfWork: regPow,
    signature: regSignature,
    deviceKeyAttestation: deviceKeyAttestation,
    ultimateSigningPublicKeyHex: ultimatePub,
    deviceKeys: PublicKeyDuo(
      signingPublicKeyHex: devicePub,
      encryptionPublicKeyHex: deviceEncPub,
    ),
    encryptedDataKey: 'bootstrap-device-data-key',
    label: 'bootstrap-device',
  );

  return (
    ultimatePriv: ultimatePriv,
    ultimatePub: ultimatePub,
    devicePriv: devicePriv,
    devicePub: devicePub,
    device: device,
  );
}

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('DeviceManagementEndpoint Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    test('revokeDevice stamps revokedAt', () async {
      final s = await _bootstrapAccountWithDevice(sessionBuilder, endpoints);

      final revChallenge =
          await endpoints.entrypoint.getChallenge(sessionBuilder);
      final revPow = await PowTestHelper.mint(
        revChallenge.challenge,
        difficulty: revChallenge.difficulty,
      );
      final revPayload =
          '${revChallenge.challenge}:revokeDevice:${s.ultimatePub}';
      final revSignature =
          SigningTestHelper.signWith(revPayload, s.ultimatePriv);

      final ok = await endpoints.deviceManagement.revokeDevice(
        sessionBuilder,
        challenge: revChallenge.challenge,
        proofOfWork: revPow,
        publicKeyHex: s.ultimatePub,
        signature: revSignature,
        deviceId: s.device.id!,
      );
      expect(ok, isTrue);

      final session = (sessionBuilder as InternalTestSessionBuilder)
          .internalBuild(endpoint: 'test', method: 'checkRevoked');
      try {
        final row = await AccountDevice.db.findById(session, s.device.id!);
        expect(row!.isRevoked, isTrue);
        expect(row.revokedAt, isNotNull);
      } finally {
        await session.close();
      }
    });

    test('a revoked device cannot pair a new device', () async {
      final s = await _bootstrapAccountWithDevice(sessionBuilder, endpoints);

      final revChallenge =
          await endpoints.entrypoint.getChallenge(sessionBuilder);
      final revPow = await PowTestHelper.mint(
        revChallenge.challenge,
        difficulty: revChallenge.difficulty,
      );
      final revPayload =
          '${revChallenge.challenge}:revokeDevice:${s.ultimatePub}';
      final revSignature =
          SigningTestHelper.signWith(revPayload, s.ultimatePriv);
      await endpoints.deviceManagement.revokeDevice(
        sessionBuilder,
        challenge: revChallenge.challenge,
        proofOfWork: revPow,
        publicKeyHex: s.ultimatePub,
        signature: revSignature,
        deviceId: s.device.id!,
      );

      final (_, newDevicePub) = SigningTestHelper.generateKeypair();
      final (_, newDeviceEncPub) = SigningTestHelper.generateKeypair();
      final newDeviceKeys = PublicKeyDuo(
        signingPublicKeyHex: newDevicePub,
        encryptionPublicKeyHex: newDeviceEncPub,
      );

      final pairChallenge =
          await endpoints.entrypoint.getChallenge(sessionBuilder);
      final pairPow = await PowTestHelper.mint(
        pairChallenge.challenge,
        difficulty: pairChallenge.difficulty,
      );
      final pairPayload =
          '${pairChallenge.challenge}:registerDeviceForAccount:${s.devicePub}';
      final pairSignature =
          SigningTestHelper.signWith(pairPayload, s.devicePriv);
      final pairingAttestation = SigningTestHelper.signWith(
        AccountInnerPayloads.pairDevice(newDeviceKeys),
        s.devicePriv,
      );

      await expectLater(
        endpoints.deviceManagement.registerDeviceForAccount(
          sessionBuilder,
          challenge: pairChallenge.challenge,
          proofOfWork: pairPow,
          publicKeyHex: s.devicePub,
          signature: pairSignature,
          newDeviceKeys: newDeviceKeys,
          pairingAttestation: pairingAttestation,
          newDeviceEncryptedDataKey: 'paired-device-data-key',
          label: 'paired-device',
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('rejects a pairing attestation signed by a non-caller key',
        () async {
      final s = await _bootstrapAccountWithDevice(sessionBuilder, endpoints);

      final (_, newDevicePub) = SigningTestHelper.generateKeypair();
      final (_, newDeviceEncPub) = SigningTestHelper.generateKeypair();
      final newDeviceKeys = PublicKeyDuo(
        signingPublicKeyHex: newDevicePub,
        encryptionPublicKeyHex: newDeviceEncPub,
      );

      final pairChallenge =
          await endpoints.entrypoint.getChallenge(sessionBuilder);
      final pairPow = await PowTestHelper.mint(
        pairChallenge.challenge,
        difficulty: pairChallenge.difficulty,
      );
      final pairPayload =
          '${pairChallenge.challenge}:registerDeviceForAccount:${s.devicePub}';
      final pairSignature =
          SigningTestHelper.signWith(pairPayload, s.devicePriv);

      // Attestation signed by an UNRELATED key, not the caller device.
      final (foreignPriv, _) = SigningTestHelper.generateKeypair();
      final pairingAttestation = SigningTestHelper.signWith(
        AccountInnerPayloads.pairDevice(newDeviceKeys),
        foreignPriv,
      );

      await expectLater(
        endpoints.deviceManagement.registerDeviceForAccount(
          sessionBuilder,
          challenge: pairChallenge.challenge,
          proofOfWork: pairPow,
          publicKeyHex: s.devicePub,
          signature: pairSignature,
          newDeviceKeys: newDeviceKeys,
          pairingAttestation: pairingAttestation,
          newDeviceEncryptedDataKey: 'paired-device-data-key',
          label: 'paired-device',
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('persists the pairing attestation and its signer', () async {
      final s = await _bootstrapAccountWithDevice(sessionBuilder, endpoints);

      final (_, newDevicePub) = SigningTestHelper.generateKeypair();
      final (_, newDeviceEncPub) = SigningTestHelper.generateKeypair();
      final newDeviceKeys = PublicKeyDuo(
        signingPublicKeyHex: newDevicePub,
        encryptionPublicKeyHex: newDeviceEncPub,
      );

      final pairChallenge =
          await endpoints.entrypoint.getChallenge(sessionBuilder);
      final pairPow = await PowTestHelper.mint(
        pairChallenge.challenge,
        difficulty: pairChallenge.difficulty,
      );
      final pairPayload =
          '${pairChallenge.challenge}:registerDeviceForAccount:${s.devicePub}';
      final pairSignature =
          SigningTestHelper.signWith(pairPayload, s.devicePriv);
      final pairingAttestation = SigningTestHelper.signWith(
        AccountInnerPayloads.pairDevice(newDeviceKeys),
        s.devicePriv,
      );

      final device = await endpoints.deviceManagement.registerDeviceForAccount(
        sessionBuilder,
        challenge: pairChallenge.challenge,
        proofOfWork: pairPow,
        publicKeyHex: s.devicePub,
        signature: pairSignature,
        newDeviceKeys: newDeviceKeys,
        pairingAttestation: pairingAttestation,
        newDeviceEncryptedDataKey: 'paired-device-data-key',
        label: 'paired-device',
      );

      expect(device.addedBySignerPublicKeyHex, s.devicePub);
      expect(device.addedByAttestation, pairingAttestation);
      expect(device.anonAccountId, s.device.anonAccountId);
    });
  });
}
