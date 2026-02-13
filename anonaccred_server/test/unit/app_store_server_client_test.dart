import 'package:test/test.dart';
import 'package:anonaccred_server/src/payments/app_store_server_client.dart';
import 'package:anonaccred_server/src/payments/apple_jwt_auth_client.dart';

void main() {
  group('AppStoreServerClient', () {
    group('class structure', () {
      test('can be instantiated with AppleJWTAuthClient', () {
        final authClient = AppleJWTAuthClient(
          privateKey: 'test_key',
          keyId: 'test_key_id',
          issuerId: 'test_issuer_id',
          bundleId: 'test_bundle_id',
        );
        expect(
          () => AppStoreServerClient(authClient),
          returnsNormally,
        );
      });

      test('can be instantiated with sandbox environment', () {
        final authClient = AppleJWTAuthClient(
          privateKey: 'test_key',
          keyId: 'test_key_id',
          issuerId: 'test_issuer_id',
          bundleId: 'test_bundle_id',
        );
        expect(
          () => AppStoreServerClient(
            authClient,
            environment: AppStoreClientEnvironment.sandbox,
          ),
          returnsNormally,
        );
      });
    });

    group('AppStoreClientEnvironment enum', () {
      test('has production and sandbox values', () {
        expect(AppStoreClientEnvironment.production, isNotNull);
        expect(AppStoreClientEnvironment.sandbox, isNotNull);
      });
    });

    group('interface compliance', () {
      test('getTransactionInfo method exists', () {
        final authClient = AppleJWTAuthClient(
          privateKey: 'test_key',
          keyId: 'test_key_id',
          issuerId: 'test_issuer_id',
          bundleId: 'test_bundle_id',
        );
        final client = AppStoreServerClient(authClient);
        expect(client.getTransactionInfo, isA<Function>());
      });

      test('getTransactionHistory method exists', () {
        final authClient = AppleJWTAuthClient(
          privateKey: 'test_key',
          keyId: 'test_key_id',
          issuerId: 'test_issuer_id',
          bundleId: 'test_bundle_id',
        );
        final client = AppStoreServerClient(authClient);
        expect(client.getTransactionHistory, isA<Function>());
      });

      test('lookUpOrderId method exists', () {
        final authClient = AppleJWTAuthClient(
          privateKey: 'test_key',
          keyId: 'test_key_id',
          issuerId: 'test_issuer_id',
          bundleId: 'test_bundle_id',
        );
        final client = AppStoreServerClient(authClient);
        expect(client.lookUpOrderId, isA<Function>());
      });
    });
  });
}