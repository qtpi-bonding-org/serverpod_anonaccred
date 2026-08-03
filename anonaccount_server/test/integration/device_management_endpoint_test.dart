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
  })
>
_bootstrapAccountWithDevice(
  TestSessionBuilder sessionBuilder,
  TestEndpoints endpoints, {
  bool withSecondDevice = false,
}) async {
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

  if (withSecondDevice) {
    final (_, secondDevicePub) = SigningTestHelper.generateKeypair();
    final (_, secondDeviceEncPub) = SigningTestHelper.generateKeypair();
    final pairChallenge = await endpoints.entrypoint.getChallenge(
      sessionBuilder,
    );
    final pairPow = await PowTestHelper.mint(
      pairChallenge.challenge,
      difficulty: pairChallenge.difficulty,
    );
    final pairPayload =
        '${pairChallenge.challenge}:registerDeviceForAccount:$devicePub';
    final pairSignature = SigningTestHelper.signWith(pairPayload, devicePriv);
    final pairingAttestation = SigningTestHelper.signWith(
      AccountInnerPayloads.pairDevice(
        PublicKeyDuo(
          signingPublicKeyHex: secondDevicePub,
          encryptionPublicKeyHex: secondDeviceEncPub,
        ),
      ),
      devicePriv,
    );
    await endpoints.deviceManagement.registerDeviceForAccount(
      sessionBuilder,
      challenge: pairChallenge.challenge,
      proofOfWork: pairPow,
      signature: pairSignature,
      publicKeyHex: devicePub,
      newDeviceKeys: PublicKeyDuo(
        signingPublicKeyHex: secondDevicePub,
        encryptionPublicKeyHex: secondDeviceEncPub,
      ),
      pairingAttestation: pairingAttestation,
      newDeviceEncryptedDataKey: 'bootstrap-second-device-data-key',
      label: 'bootstrap-second-device',
      ultimateEncryptionPublicKeyHex: ultimatePub,
      ultimateSigningPublicKeyHex: ultimatePub,
    );
  }

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
      final s = await _bootstrapAccountWithDevice(
        sessionBuilder,
        endpoints,
        withSecondDevice: true,
      );

      final revChallenge = await endpoints.entrypoint.getChallenge(
        sessionBuilder,
      );
      final revPow = await PowTestHelper.mint(
        revChallenge.challenge,
        difficulty: revChallenge.difficulty,
      );
      final revPayload =
          '${revChallenge.challenge}:revokeDevice:${s.ultimatePub}';
      final revSignature = SigningTestHelper.signWith(
        revPayload,
        s.ultimatePriv,
      );

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

    test(
      'revokeDevice refuses to revoke the account\'s last active device',
      () async {
        final s = await _bootstrapAccountWithDevice(sessionBuilder, endpoints);

        final revChallenge = await endpoints.entrypoint.getChallenge(
          sessionBuilder,
        );
        final revPow = await PowTestHelper.mint(
          revChallenge.challenge,
          difficulty: revChallenge.difficulty,
        );
        final revPayload =
            '${revChallenge.challenge}:revokeDevice:${s.ultimatePub}';
        final revSignature = SigningTestHelper.signWith(
          revPayload,
          s.ultimatePriv,
        );

        await expectLater(
          endpoints.deviceManagement.revokeDevice(
            sessionBuilder,
            challenge: revChallenge.challenge,
            proofOfWork: revPow,
            publicKeyHex: s.ultimatePub,
            signature: revSignature,
            deviceId: s.device.id!,
          ),
          throwsA(isA<AuthenticationException>()),
        );

        final row = (await AccountDevice.db.findById(
          sessionBuilder.build(),
          s.device.id!,
        ))!;
        expect(row.isRevoked, isFalse);
      },
    );

    test('a revoked device cannot pair a new device', () async {
      final s = await _bootstrapAccountWithDevice(
        sessionBuilder,
        endpoints,
        withSecondDevice: true,
      );

      final revChallenge = await endpoints.entrypoint.getChallenge(
        sessionBuilder,
      );
      final revPow = await PowTestHelper.mint(
        revChallenge.challenge,
        difficulty: revChallenge.difficulty,
      );
      final revPayload =
          '${revChallenge.challenge}:revokeDevice:${s.ultimatePub}';
      final revSignature = SigningTestHelper.signWith(
        revPayload,
        s.ultimatePriv,
      );
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

      final pairChallenge = await endpoints.entrypoint.getChallenge(
        sessionBuilder,
      );
      final pairPow = await PowTestHelper.mint(
        pairChallenge.challenge,
        difficulty: pairChallenge.difficulty,
      );
      final pairPayload =
          '${pairChallenge.challenge}:registerDeviceForAccount:${s.devicePub}';
      final pairSignature = SigningTestHelper.signWith(
        pairPayload,
        s.devicePriv,
      );
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
          ultimateEncryptionPublicKeyHex: 'ultimate-enc-pub',
          ultimateSigningPublicKeyHex: 'ultimate-sig-pub',
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('rejects a pairing attestation signed by a non-caller key', () async {
      final s = await _bootstrapAccountWithDevice(sessionBuilder, endpoints);

      final (_, newDevicePub) = SigningTestHelper.generateKeypair();
      final (_, newDeviceEncPub) = SigningTestHelper.generateKeypair();
      final newDeviceKeys = PublicKeyDuo(
        signingPublicKeyHex: newDevicePub,
        encryptionPublicKeyHex: newDeviceEncPub,
      );

      final pairChallenge = await endpoints.entrypoint.getChallenge(
        sessionBuilder,
      );
      final pairPow = await PowTestHelper.mint(
        pairChallenge.challenge,
        difficulty: pairChallenge.difficulty,
      );
      final pairPayload =
          '${pairChallenge.challenge}:registerDeviceForAccount:${s.devicePub}';
      final pairSignature = SigningTestHelper.signWith(
        pairPayload,
        s.devicePriv,
      );

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
          ultimateEncryptionPublicKeyHex: 'ultimate-enc-pub',
          ultimateSigningPublicKeyHex: 'ultimate-sig-pub',
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

      final pairChallenge = await endpoints.entrypoint.getChallenge(
        sessionBuilder,
      );
      final pairPow = await PowTestHelper.mint(
        pairChallenge.challenge,
        difficulty: pairChallenge.difficulty,
      );
      final pairPayload =
          '${pairChallenge.challenge}:registerDeviceForAccount:${s.devicePub}';
      final pairSignature = SigningTestHelper.signWith(
        pairPayload,
        s.devicePriv,
      );
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
        ultimateEncryptionPublicKeyHex: 'ultimate-enc-pub',
        ultimateSigningPublicKeyHex: 'ultimate-sig-pub',
      );

      expect(device.addedByAttestorPublicKeyHex, s.devicePub);
      expect(device.addedByAttestation, pairingAttestation);
      expect(device.anonAccountId, s.device.anonAccountId);
    });
    test('listDevices rejects a revoked device key', () async {
      final s = await _bootstrapAccountWithDevice(
        sessionBuilder,
        endpoints,
        withSecondDevice: true,
      );

      final revokeChallenge = await endpoints.entrypoint.getChallenge(
        sessionBuilder,
      );
      final revokePow = await PowTestHelper.mint(
        revokeChallenge.challenge,
        difficulty: revokeChallenge.difficulty,
      );
      await endpoints.deviceManagement.revokeDevice(
        sessionBuilder,
        challenge: revokeChallenge.challenge,
        proofOfWork: revokePow,
        publicKeyHex: s.ultimatePub,
        signature: SigningTestHelper.signWith(
          '${revokeChallenge.challenge}:revokeDevice:${s.ultimatePub}',
          s.ultimatePriv,
        ),
        deviceId: s.device.id!,
      );

      final challenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
      final pow = await PowTestHelper.mint(
        challenge.challenge,
        difficulty: challenge.difficulty,
      );
      await expectLater(
        endpoints.deviceManagement.listDevices(
          sessionBuilder,
          challenge: challenge.challenge,
          proofOfWork: pow,
          publicKeyHex: s.devicePub,
          signature: SigningTestHelper.signWith(
            '${challenge.challenge}:listDevices:${s.devicePub}',
            s.devicePriv,
          ),
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('listDevices keeps the ultimate-key fallback', () async {
      final s = await _bootstrapAccountWithDevice(sessionBuilder, endpoints);

      final challenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
      final pow = await PowTestHelper.mint(
        challenge.challenge,
        difficulty: challenge.difficulty,
      );
      final result = await endpoints.deviceManagement.listDevices(
        sessionBuilder,
        challenge: challenge.challenge,
        proofOfWork: pow,
        publicKeyHex: s.ultimatePub,
        signature: SigningTestHelper.signWith(
          '${challenge.challenge}:listDevices:${s.ultimatePub}',
          s.ultimatePriv,
        ),
      );

      expect(result, hasLength(1));
    });
  });
}
