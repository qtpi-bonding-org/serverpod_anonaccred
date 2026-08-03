import 'dart:convert';

import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:anonaccred_server/src/payments/polar_client.dart';
import 'package:anonaccred_server/src/payments/polar_http_client.dart';
import 'package:anonaccred_server/src/payments/rails/polar_rail.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('PolarEndpoint.redeemLicenseKey', (sessionBuilder, endpoints) {
    late AnonAccount account;
    late TestSessionBuilder authenticated;

    setUp(() async {
      PaymentManager.clearRails();
      final session = sessionBuilder.build();
      account = await AnonAccount.db.insertRow(
        session,
        AnonAccount(
          id: UuidValue.fromString(const Uuid().v4()),
          ultimateSigningPublicKeyHex: 'a' * 128,
          encryptedDataKey: 'data',
          ultimateEncryptionPublicKeyHex: 'b' * 128,
        ),
      );
      final device = await AccountDevice.db.insertRow(
        session,
        AccountDevice(
          anonAccountId: account.id!,
          deviceSigningPublicKeyHex: 'c' * 128,
          deviceEncryptionPublicKeyHex: 'd' * 128,
          addedByAttestorPublicKeyHex: 'a' * 128,
          addedByAttestation: 'test-attestation',
          encryptedDataKey: 'device_data',
          label: 'Test Device',
        ),
      );
      authenticated = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          account.id.toString(),
          {Scope('device:${device.deviceSigningPublicKeyHex}')},
          authId: device.deviceSigningPublicKeyHex,
        ),
      );
    });

    tearDown(PaymentManager.clearRails);

    test('redeemLicenseKey rejects a revoked device', () async {
      final session = sessionBuilder.build();
      final device = (await AccountDevice.db.findFirstRow(
        session,
        where: (t) => t.deviceSigningPublicKeyHex.equals('c' * 128),
      ))!;
      await AccountDevice.db.updateRow(
        session,
        device.copyWith(isRevoked: true),
      );

      await expectLater(
        endpoints.polar.redeemLicenseKey(authenticated, 'some-license-key'),
        throwsA(isA<AuthenticationException>()),
      );

      await AccountDevice.db.updateRow(
        session,
        device.copyWith(isRevoked: false),
      );
    });

    void registerRail() {
      PaymentManager.registerRail(
        PolarRail(
          client: PolarClient(
            organizationId: 'org',
            http: PolarHttpClient(
              baseUrl: 'https://api.polar.sh',
              bearerToken: 'token',
              httpClient: MockClient(
                (request) async => http.Response(
                  jsonEncode({
                    'id': 'license-1',
                    'key': 'LICENSE-1',
                    'status': 'granted',
                    'organization_id': 'org',
                    'benefit_id': 'benefit-1',
                    'customer_id': 'customer-1',
                    'expires_at': null,
                  }),
                  200,
                ),
              ),
            ),
          ),
        ),
      );
    }

    test('rejects unauthenticated callers', () async {
      registerRail();
      expect(
        endpoints.polar.redeemLicenseKey(sessionBuilder, 'LICENSE-1'),
        throwsA(isA<Exception>()),
      );
    });

    test('credits an account-scoped entitlement', () async {
      registerRail();
      final session = sessionBuilder.build();
      final entitlement = await Entitlement.db.insertRow(
        session,
        Entitlement(
          tag: 'coins',
          name: 'coins',
          type: EntitlementType.consumable,
          serverValidated: true,
        ),
      );
      final product = await RailProduct.db.insertRow(
        session,
        RailProduct(
          rail: PaymentRail.polar,
          storeProductId: 'benefit-1',
          isActive: true,
        ),
      );
      await RailProductGrant.db.insertRow(
        session,
        RailProductGrant(
          railProductId: product.id!,
          entitlementId: entitlement.id!,
          quantity: 5,
        ),
      );

      final result = await endpoints.polar.redeemLicenseKey(
        authenticated,
        'LICENSE-1',
      );

      expect(result.success, isTrue);
      expect(result.productId, 'benefit-1');
      expect(result.tag, 'coins');
      expect(result.amount, 5);
      expect(result.fromCache, isFalse);
    });

    test('rejects an empty license key', () async {
      registerRail();
      expect(
        endpoints.polar.redeemLicenseKey(authenticated, ''),
        throwsA(isA<Exception>()),
      );
    });
  });
}
