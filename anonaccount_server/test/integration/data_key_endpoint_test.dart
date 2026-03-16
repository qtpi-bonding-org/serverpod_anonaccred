import 'package:anonaccount_server/src/generated/protocol.dart';
import 'package:anonaccount_server/src/pow_methods.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';
import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/pow_test_helper.dart';
import '../test_helpers/signing_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import 'test_tools/serverpod_test_tools.dart';

/// Helper: insert AccountDevice directly (bypasses PoW).
Future<AccountDevice> createTestDevice(
  TestSessionBuilder sessionBuilder, {
  required UuidValue anonAccountId,
  required String deviceSigningPublicKeyHex,
  String encryptedDataKey = 'test-device-encrypted-data-key',
  String label = 'Test Device',
  bool isRevoked = false,
}) async {
  final session =
      (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: 'createTestDevice',
  );
  try {
    final device = AccountDevice(
      anonAccountId: anonAccountId,
      deviceSigningPublicKeyHex: deviceSigningPublicKeyHex,
      encryptedDataKey: encryptedDataKey,
      label: label,
      lastActive: DateTime.now(),
      isRevoked: isRevoked,
    );
    return await AccountDevice.db.insertRow(session, device);
  } finally {
    await session.close();
  }
}

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('DataKeyEndpoint Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    group('retrieveEncryptedDataKey', () {
      test('returns encrypted data key for active device', () async {
        final (ultimatePrivKey, ultimatePubKey) =
            SigningTestHelper.generateKeypair();
        final account = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          ultimatePublicKey: ultimatePubKey,
        );
        final (devicePrivKey, devicePubKey) =
            SigningTestHelper.generateKeypair();
        const expectedKey = 'device-encrypted-key-abc';
        await createTestDevice(
          sessionBuilder,
          anonAccountId: account.id!,
          deviceSigningPublicKeyHex: devicePubKey,
          encryptedDataKey: expectedKey,
        );

        final challenge =
            await endpoints.entrypoint.getChallenge(sessionBuilder);
        final pow = await PowTestHelper.mint(
          challenge.challenge,
          difficulty: challenge.difficulty,
        );
        final payload =
            '${challenge.challenge}:${DataKeyMethods.retrieveEncryptedDataKey}:$devicePubKey';
        final signature = SigningTestHelper.signWith(payload, devicePrivKey);

        final response = await endpoints.dataKey.retrieveEncryptedDataKey(
          sessionBuilder,
          challenge: challenge.challenge,
          proofOfWork: pow,
          signature: signature,
          deviceSigningPublicKeyHex: devicePubKey,
        );

        expect(response.encryptedDataKey, equals(expectedKey));
      });

      test('throws for revoked device', () async {
        final (_, ultimatePubKey) =
            SigningTestHelper.generateKeypair();
        final account = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: ultimatePubKey,
          ultimatePublicKey: ultimatePubKey,
        );
        final (devicePrivKey, devicePubKey) =
            SigningTestHelper.generateKeypair();
        await createTestDevice(
          sessionBuilder,
          anonAccountId: account.id!,
          deviceSigningPublicKeyHex: devicePubKey,
          isRevoked: true,
        );

        final challenge =
            await endpoints.entrypoint.getChallenge(sessionBuilder);
        final pow = await PowTestHelper.mint(
          challenge.challenge,
          difficulty: challenge.difficulty,
        );
        final payload =
            '${challenge.challenge}:${DataKeyMethods.retrieveEncryptedDataKey}:$devicePubKey';
        final signature = SigningTestHelper.signWith(payload, devicePrivKey);

        await expectLater(
          () => endpoints.dataKey.retrieveEncryptedDataKey(
            sessionBuilder,
            challenge: challenge.challenge,
            proofOfWork: pow,
            signature: signature,
            deviceSigningPublicKeyHex: devicePubKey,
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('throws for unknown device', () async {
        final (devicePrivKey, devicePubKey) =
            SigningTestHelper.generateKeypair();

        final challenge =
            await endpoints.entrypoint.getChallenge(sessionBuilder);
        final pow = await PowTestHelper.mint(
          challenge.challenge,
          difficulty: challenge.difficulty,
        );
        final payload =
            '${challenge.challenge}:${DataKeyMethods.retrieveEncryptedDataKey}:$devicePubKey';
        final signature = SigningTestHelper.signWith(payload, devicePrivKey);

        await expectLater(
          () => endpoints.dataKey.retrieveEncryptedDataKey(
            sessionBuilder,
            challenge: challenge.challenge,
            proofOfWork: pow,
            signature: signature,
            deviceSigningPublicKeyHex: devicePubKey,
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      group('recoverEncryptedDataKey', () {
        test('returns account encrypted data key for ultimate key holder',
            () async {
          final (ultimatePrivKey, ultimatePubKey) =
              SigningTestHelper.generateKeypair();
          const expectedKey = 'account-encrypted-key-xyz';
          await createTestAccount(
            sessionBuilder,
            ultimateSigningPublicKeyHex: ultimatePubKey,
            ultimatePublicKey: ultimatePubKey,
            encryptedDataKey: expectedKey,
          );

          final challenge =
              await endpoints.entrypoint.getChallenge(sessionBuilder);
          final pow = await PowTestHelper.mint(
            challenge.challenge,
            difficulty: challenge.difficulty,
          );
          final payload =
              '${challenge.challenge}:${DataKeyMethods.recoverEncryptedDataKey}:$ultimatePubKey';
          final signature =
              SigningTestHelper.signWith(payload, ultimatePrivKey);

          final response = await endpoints.dataKey.recoverEncryptedDataKey(
            sessionBuilder,
            challenge: challenge.challenge,
            proofOfWork: pow,
            signature: signature,
            ultimateSigningPublicKeyHex: ultimatePubKey,
          );

          expect(response.encryptedDataKey, equals(expectedKey));
        });

        test('throws for unknown ultimate key', () async {
          final (ultimatePrivKey, ultimatePubKey) =
              SigningTestHelper.generateKeypair();

          final challenge =
              await endpoints.entrypoint.getChallenge(sessionBuilder);
          final pow = await PowTestHelper.mint(
            challenge.challenge,
            difficulty: challenge.difficulty,
          );
          final payload =
              '${challenge.challenge}:${DataKeyMethods.recoverEncryptedDataKey}:$ultimatePubKey';
          final signature =
              SigningTestHelper.signWith(payload, ultimatePrivKey);

          await expectLater(
            () => endpoints.dataKey.recoverEncryptedDataKey(
              sessionBuilder,
              challenge: challenge.challenge,
              proofOfWork: pow,
              signature: signature,
              ultimateSigningPublicKeyHex: ultimatePubKey,
            ),
            throwsA(isA<AuthenticationException>()),
          );
        });
      });
    });
  });
}
