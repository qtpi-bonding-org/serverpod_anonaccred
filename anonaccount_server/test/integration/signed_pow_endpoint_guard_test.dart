import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/revocation_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'test_tools/serverpod_test_tools.dart';

class _TestGuardEndpoint extends SignedPowEndpoint {
  @override
  String get endpointType => 'testGuard';
}

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('SignedPowEndpoint.guard', (sessionBuilder, endpoints) {
    Future<({String devicePriv, String devicePub})> seedDevice() async {
      final (_, ultimatePub) = SigningTestHelper.generateKeypair();
      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: ultimatePub,
        ultimateEncryptionPublicKeyHex: ultimatePub,
      );
      final (devicePriv, devicePub) = SigningTestHelper.generateKeypair();
      final session = (sessionBuilder as InternalTestSessionBuilder)
          .internalBuild(endpoint: 'test', method: 'setup');
      try {
        await AccountDevice.db.insertRow(
          session,
          AccountDevice(
            anonAccountId: account.id!,
            deviceSigningPublicKeyHex: devicePub,
            deviceEncryptionPublicKeyHex: devicePub,
            encryptedDataKey: 'x',
            label: 'x',
            addedByAttestorPublicKeyHex: devicePub,
            addedByAttestation: 'x',
            lastActive: DateTime.now(),
            isRevoked: false,
          ),
        );
      } finally {
        await session.close();
      }
      return (devicePriv: devicePriv, devicePub: devicePub);
    }

    test('returns an AuthenticatedCaller for a valid active caller', () async {
      final seeded = await seedDevice();
      final challenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
      final pow = await PowTestHelper.mint(
        challenge.challenge,
        difficulty: challenge.difficulty,
      );
      final endpoint = _TestGuardEndpoint();
      final caller = await endpoint.guard(
        (sessionBuilder as InternalTestSessionBuilder).internalBuild(
          endpoint: 'testGuard',
          method: 'testMethod',
        ),
        challenge: challenge.challenge,
        proofOfWork: pow,
        signature: SigningTestHelper.signWith(
          '${challenge.challenge}:testMethod:${seeded.devicePub}',
          seeded.devicePriv,
        ),
        callerDeviceSigningPublicKeyHex: seeded.devicePub,
        methodName: 'testMethod',
      );

      expect(caller.signingPublicKeyHex, seeded.devicePub);
    });

    test('rejects a revoked caller device', () async {
      final seeded = await seedDevice();
      await RevocationTestHelper.revokeDevice(sessionBuilder, seeded.devicePub);
      final challenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
      final pow = await PowTestHelper.mint(
        challenge.challenge,
        difficulty: challenge.difficulty,
      );
      final endpoint = _TestGuardEndpoint();

      await expectLater(
        endpoint.guard(
          (sessionBuilder as InternalTestSessionBuilder).internalBuild(
            endpoint: 'testGuard',
            method: 'testMethod',
          ),
          challenge: challenge.challenge,
          proofOfWork: pow,
          signature: SigningTestHelper.signWith(
            '${challenge.challenge}:testMethod:${seeded.devicePub}',
            seeded.devicePriv,
          ),
          callerDeviceSigningPublicKeyHex: seeded.devicePub,
          methodName: 'testMethod',
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('rejects a bad outer signature', () async {
      final challenge = await endpoints.entrypoint.getChallenge(sessionBuilder);
      final pow = await PowTestHelper.mint(
        challenge.challenge,
        difficulty: challenge.difficulty,
      );
      final endpoint = _TestGuardEndpoint();

      await expectLater(
        endpoint.guard(
          (sessionBuilder as InternalTestSessionBuilder).internalBuild(
            endpoint: 'testGuard',
            method: 'testMethod',
          ),
          challenge: challenge.challenge,
          proofOfWork: pow,
          signature: 'a' * 128,
          callerDeviceSigningPublicKeyHex: 'b' * 128,
          methodName: 'testMethod',
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });
  });
}
