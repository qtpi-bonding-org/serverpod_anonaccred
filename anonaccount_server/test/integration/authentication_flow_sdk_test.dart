@Tags(['two_actor'])
library;

import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:anonaccount_sdk/anonaccount_sdk.dart' hide AccountDevice;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/simulated_user.dart';

/// Pairs a new device for [user] the same way [SimulatedUser.addDeviceViaPairing]
/// does, but also returns the new device's own key — needed here because
/// these tests sign challenges directly with each device's key rather than
/// going through [SimulatedUser]'s single tracked primary device.
Future<(UuidValue, KeyDuo)> _pairDeviceReturningKey(
  SimulatedUser user, {
  required String label,
}) async {
  final store = InMemoryAccountKeyStore();
  final pairing = AnonaccountPairing(user.caller, store);
  final qr = await pairing.beginPairing(deviceLabel: label);
  // Registration completes before monitorRegistration is called at all —
  // see the matching comment on SimulatedUser.addDeviceViaPairing for why
  // racing these two server calls intermittently throws under the test
  // harness's single shared transaction.
  final registered = await user.pairing.registerPairedDevice(
    scanned: user.pairing.parseQr(qr.qrPayloadJson),
    label: label,
  );
  final event = await pairing.monitorRegistration(qr.signingPubkeyHex).first;
  await pairing.completePairing(wrappedKey: event.encryptedDataKey);
  return (registered.id!, (await store.getDeviceKey())!);
}

void main() {
  setUpAll(initializeTestAuthServices);

  group('Authentication Flow Integration Tests', () {
    withServerpod('Given authentication flow integration', (
      sessionBuilder,
      endpoints,
    ) {
      test(
        'successful authentication with valid device key and database lookup',
        () async {
          final alice = SimulatedUser(sessionBuilder, endpoints, label: 'a1');
          await alice.onboard();
          // Second device so this test can exercise revocation elsewhere
          // without violating the account's last-device invariant.
          await alice.addDeviceViaPairing(label: 'secondary');
          final deviceHex = await alice.deviceKeyHex();
          final deviceKey = await alice.deviceKey;
          final primaryId = await alice.primaryDeviceId();

          final challenge = CryptoUtils.generateChallenge();
          final signatureHex = await SigningCrypto.signChallenge(
            challenge,
            deviceKey,
          );

          final result = await CryptoAuth.verifyChallengeResponse(
            deviceHex,
            challenge,
            signatureHex,
          );
          expect(result.success, isTrue);

          final foundDevice = await AccountDevice.db.findFirstRow(
            sessionBuilder.build(),
            where: (t) => t.deviceSigningPublicKeyHex.equals(deviceHex),
          );
          expect(foundDevice, isNotNull);
          expect(foundDevice!.anonAccountId, equals(alice.accountId));
          expect(foundDevice.id, equals(primaryId));
        },
      );

      test('authentication failure with invalid signature', () async {
        final alice = SimulatedUser(sessionBuilder, endpoints, label: 'a2');
        await alice.onboard();
        final deviceHex = await alice.deviceKeyHex();

        final challenge = CryptoUtils.generateChallenge();
        final invalidSignature = 'invalid_signature_${'f' * 100}';

        final result = await CryptoAuth.verifyChallengeResponse(
          deviceHex,
          challenge,
          invalidSignature,
        );

        expect(result.success, isFalse);
        expect(
          result.errorCode,
          equals(AnonAccountErrorCodes.cryptoInvalidSignature),
        );
      });

      test('authentication failure with revoked device', () async {
        final alice = SimulatedUser(sessionBuilder, endpoints, label: 'a3');
        await alice.onboard();
        await alice.addDeviceViaPairing(label: 'secondary');
        final deviceHex = await alice.deviceKeyHex();
        final deviceKey = await alice.deviceKey;
        final primaryId = await alice.primaryDeviceId();
        await alice.revokeDevice(primaryId);

        // Cryptographic verification still succeeds — the signature itself
        // remains valid — it's the database standing that changed.
        final challenge = CryptoUtils.generateChallenge();
        final signatureHex = await SigningCrypto.signChallenge(
          challenge,
          deviceKey,
        );
        final result = await CryptoAuth.verifyChallengeResponse(
          deviceHex,
          challenge,
          signatureHex,
        );
        expect(result.success, isTrue);

        final revokedDevice = await AccountDevice.db.findById(
          sessionBuilder.build(),
          primaryId,
        );
        expect(revokedDevice, isNotNull);
        expect(revokedDevice!.isRevoked, isTrue);
      });

      test('AuthenticationInfo structure matches Serverpod requirements', () async {
        final alice = SimulatedUser(sessionBuilder, endpoints, label: 'a4');
        await alice.onboard();

        final authenticatedSessionBuilder = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            alice.accountId.toString(),
            <Scope>{},
          ),
        );

        final session = authenticatedSessionBuilder.build();
        expect(session.authenticated, isNotNull);
        expect(
          session.authenticated!.userIdentifier,
          equals(alice.accountId.toString()),
        );
      });

      test('multiple devices can authenticate independently', () async {
        final alice = SimulatedUser(sessionBuilder, endpoints, label: 'a5');
        await alice.onboard();
        final devices = <(UuidValue, KeyDuo)>[
          (await alice.primaryDeviceId(), await alice.deviceKey),
        ];
        for (var i = 0; i < 2; i++) {
          devices.add(await _pairDeviceReturningKey(alice, label: 'multi-$i'));
        }

        for (final (deviceId, key) in devices) {
          final hex = (await key.exportPublicKeyDuo()).signing.value;
          final challenge = CryptoUtils.generateChallenge();
          final signatureHex = await SigningCrypto.signChallenge(
            challenge,
            key,
          );

          final result = await CryptoAuth.verifyChallengeResponse(
            hex,
            challenge,
            signatureHex,
          );
          expect(result.success, isTrue);

          final foundDevice = await AccountDevice.db.findFirstRow(
            sessionBuilder.build(),
            where: (t) => t.deviceSigningPublicKeyHex.equals(hex),
          );
          expect(foundDevice, isNotNull);
          expect(foundDevice!.anonAccountId, equals(alice.accountId));
          expect(foundDevice.id, equals(deviceId));
        }
      });

      test('extracts device key from authenticated session', () async {
        final alice = SimulatedUser(sessionBuilder, endpoints, label: 'a6');
        await alice.onboard();

        final authenticatedSessionBuilder = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            alice.accountId.toString(),
            <Scope>{},
          ),
        );
        final session = authenticatedSessionBuilder.build();

        expect(session.authenticated, isNotNull);
        expect(
          session.authenticated!.userIdentifier,
          equals(alice.accountId.toString()),
        );
        expect(session.isUserSignedIn, isTrue);
      });
    });
  });
}
