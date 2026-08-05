import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import 'test_tools/sdk_test_caller.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/simulated_user.dart';

void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('DataKeyEndpoint Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    group('retrieveEncryptedDataKey', () {
      test('returns encrypted data key for active device', () async {
        final alice = SimulatedUser(sessionBuilder, endpoints, label: 'alice');
        await alice.onboard();
        final expectedKey = (await alice.listDevices()).single.encryptedDataKey;

        final deviceHex = await alice.deviceKeyHex();
        final envelope = await alice.caller.buildEnvelope(
          methodName: 'retrieveEncryptedDataKey',
          signingKey: await alice.deviceKey,
          publicKeyHex: deviceHex,
        );
        final response = await alice.caller.dataKey.retrieveEncryptedDataKey(
          challenge: envelope.challenge,
          proofOfWork: envelope.proofOfWork,
          signature: envelope.signature,
          deviceSigningPublicKeyHex: deviceHex,
        );

        expect(response.encryptedDataKey, equals(expectedKey));
      });

      test('throws for revoked device', () async {
        final alice = SimulatedUser(sessionBuilder, endpoints, label: 'alice');
        await alice.onboard();
        await alice.addDeviceViaPairing(label: 'secondary');
        final deviceHex = await alice.deviceKeyHex();
        final deviceKey = await alice.deviceKey;
        await alice.revokeDevice(await alice.primaryDeviceId());

        final envelope = await alice.caller.buildEnvelope(
          methodName: 'retrieveEncryptedDataKey',
          signingKey: deviceKey,
          publicKeyHex: deviceHex,
        );

        await expectLater(
          () => alice.caller.dataKey.retrieveEncryptedDataKey(
            challenge: envelope.challenge,
            proofOfWork: envelope.proofOfWork,
            signature: envelope.signature,
            deviceSigningPublicKeyHex: deviceHex,
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('throws for unknown device', () async {
        final alice = SimulatedUser(sessionBuilder, endpoints, label: 'alice');
        final unknown = await KeyGen.generateDeviceKey();
        final unknownHex = (await unknown.exportPublicKeyDuo()).signing.value;

        final envelope = await alice.caller.buildEnvelope(
          methodName: 'retrieveEncryptedDataKey',
          signingKey: unknown,
          publicKeyHex: unknownHex,
        );

        await expectLater(
          () => alice.caller.dataKey.retrieveEncryptedDataKey(
            challenge: envelope.challenge,
            proofOfWork: envelope.proofOfWork,
            signature: envelope.signature,
            deviceSigningPublicKeyHex: unknownHex,
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      group('recoverEncryptedDataKey', () {
        test(
          'returns account encrypted data key for ultimate key holder',
          () async {
            final alice = SimulatedUser(
              sessionBuilder,
              endpoints,
              label: 'alice',
            );
            await alice.onboard();

            // No SDK-exposed accessor for the account's raw encryptedDataKey
            // (only the SDK's already-decrypted recoverAccount() flow), so
            // this checks the endpoint deterministically returns the same
            // ciphertext across two independent calls for the same key
            // holder, rather than asserting on an internal representation.
            final ultimateKey = await InMemoryAccountKeyStore()
                .importUltimateKeyJwk(alice.ultimateBackupJwk!);
            final ultimateHex =
                (await ultimateKey.exportPublicKeyDuo()).signing.value;

            Future<String> fetchOnce() async {
              final envelope = await alice.caller.buildEnvelope(
                methodName: 'recoverEncryptedDataKey',
                signingKey: ultimateKey,
                publicKeyHex: ultimateHex,
              );
              final response = await alice.caller.dataKey
                  .recoverEncryptedDataKey(
                    challenge: envelope.challenge,
                    proofOfWork: envelope.proofOfWork,
                    signature: envelope.signature,
                    ultimateSigningPublicKeyHex: ultimateHex,
                  );
              return response.encryptedDataKey;
            }

            final first = await fetchOnce();
            final second = await fetchOnce();
            expect(first, isNotEmpty);
            expect(first, equals(second));
          },
        );

        test('throws for unknown ultimate key', () async {
          final alice = SimulatedUser(sessionBuilder, endpoints, label: 'alice');
          final unknown = await KeyGen.generateDeviceKey();
          final unknownHex = (await unknown.exportPublicKeyDuo()).signing.value;

          final envelope = await alice.caller.buildEnvelope(
            methodName: 'recoverEncryptedDataKey',
            signingKey: unknown,
            publicKeyHex: unknownHex,
          );

          await expectLater(
            () => alice.caller.dataKey.recoverEncryptedDataKey(
              challenge: envelope.challenge,
              proofOfWork: envelope.proofOfWork,
              signature: envelope.signature,
              ultimateSigningPublicKeyHex: unknownHex,
            ),
            throwsA(isA<AuthenticationException>()),
          );
        });
      });
    });
  });
}
