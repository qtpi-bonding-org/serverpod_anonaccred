import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/revocation_test_helper.dart';
import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('AnonAccountHelpers.requireCaller', (
    sessionBuilder,
    endpoints,
  ) {
    Future<({UuidValue accountId, String devicePub})> seedDevice() async {
      final (_, ultimatePub) = SigningTestHelper.generateKeypair();
      final account = await createTestAccount(
        sessionBuilder,
        ultimateSigningPublicKeyHex: ultimatePub,
        ultimateEncryptionPublicKeyHex: ultimatePub,
      );
      final (_, devicePub) = SigningTestHelper.generateKeypair();
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
      return (accountId: account.id!, devicePub: devicePub);
    }

    test('returns an AuthenticatedCaller for an active device', () async {
      final seeded = await seedDevice();
      final caller = await AnonAccountHelpers.requireCaller(
        (sessionBuilder as InternalTestSessionBuilder).internalBuild(
          endpoint: 'test',
          method: 'call',
        ),
        seeded.devicePub,
        'testOp',
      );

      expect(caller.accountId, seeded.accountId);
      expect(caller.signingPublicKeyHex, seeded.devicePub);
    });

    test('throws AuthenticationException for a revoked device', () async {
      final seeded = await seedDevice();
      await RevocationTestHelper.revokeDevice(sessionBuilder, seeded.devicePub);

      await expectLater(
        AnonAccountHelpers.requireCaller(
          (sessionBuilder as InternalTestSessionBuilder).internalBuild(
            endpoint: 'test',
            method: 'call',
          ),
          seeded.devicePub,
          'testOp',
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('throws AuthenticationException for an unknown key', () async {
      await expectLater(
        AnonAccountHelpers.requireCaller(
          (sessionBuilder as InternalTestSessionBuilder).internalBuild(
            endpoint: 'test',
            method: 'call',
          ),
          'a' * 128,
          'testOp',
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('AuthenticatedCaller itself rejects a revoked device', () {
      final revokedDevice = AccountDevice(
        anonAccountId: UuidValue.fromString(
          '00000000-0000-0000-0000-000000000003',
        ),
        deviceSigningPublicKeyHex: 'a' * 128,
        deviceEncryptionPublicKeyHex: 'a' * 128,
        encryptedDataKey: 'x',
        label: 'x',
        addedByAttestorPublicKeyHex: 'a' * 128,
        addedByAttestation: 'x',
        lastActive: DateTime.now(),
        isRevoked: true,
      );

      expect(() => AuthenticatedCaller(revokedDevice), throwsStateError);
    });
  });
}
