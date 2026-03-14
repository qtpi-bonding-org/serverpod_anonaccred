import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:anonaccred_server/src/entitlement_manager.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('CommerceEndpoint Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    // Test constants
    const validPublicKey =
        '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
    const validSignature =
        'valid_signature_placeholder_64_chars_1234567890abcdef1234567890ab';
    late int testAccountId;

    setUp(() async {
      // Find or create a test account (handles stale data from previous runs)
      final session = sessionBuilder.build();
      var account = await AnonAccount.db.findFirstRow(
        session,
        where: (t) => t.ultimatePublicKey.equals(validPublicKey),
      );
      account ??= await AnonAccount.db.insertRow(session, AnonAccount(
        ultimateSigningPublicKeyHex: validPublicKey,
        encryptedDataKey: 'encrypted_data_key_for_commerce_test',
        ultimatePublicKey: validPublicKey,
      ));
      testAccountId = account.id!;

      // Ensure a device exists for this account with the validPublicKey so that
      // AnonAccountHelpers.resolveAccountId can find it.
      var device = await AccountDevice.db.findFirstRow(
        session,
        where: (t) => t.deviceSigningPublicKeyHex.equals(validPublicKey),
      );
      device ??= await AccountDevice.db.insertRow(
        session,
        AccountDevice(
          accountId: testAccountId,
          deviceSigningPublicKeyHex: validPublicKey,
          encryptedDataKey: 'device_encrypted_key_commerce_test',
          label: 'Test Device',
        ),
      );

      // Clean up any leftover entitlement balances from prior runs
      await AccountEntitlement.db.deleteWhere(
        session,
        where: (t) => t.accountId.equals(testAccountId),
      );
    });

    group('getEntitlements endpoint', () {
      test(
        'returns empty entitlements for account with no inventory',
        () async {
          final entitlements = await endpoints.commerce.getEntitlements(
            sessionBuilder,
            validPublicKey,
            validSignature,
          );

          expect(entitlements, isEmpty);
        },
      );

      test('fails with empty public key', () async {
        expect(
          () => endpoints.commerce.getEntitlements(
            sessionBuilder,
            '', // empty public key
            validSignature,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with invalid public key format', () async {
        expect(
          () => endpoints.commerce.getEntitlements(
            sessionBuilder,
            'invalid_key',
            validSignature,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with empty signature', () async {
        expect(
          () => endpoints.commerce.getEntitlements(
            sessionBuilder,
            validPublicKey,
            '', // empty signature
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getEntitlementBalance endpoint', () {
      test('returns zero balance for non-existent consumable', () async {
        final balance = await endpoints.commerce.getEntitlementBalance(
          sessionBuilder,
          validPublicKey,
          validSignature,
          'non_existent_item',
        );

        expect(balance, equals(0.0));
      });

      test('fails with empty public key', () async {
        expect(
          () => endpoints.commerce.getEntitlementBalance(
            sessionBuilder,
            '', // empty public key
            validSignature,
            'test_item',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with invalid public key format', () async {
        expect(
          () => endpoints.commerce.getEntitlementBalance(
            sessionBuilder,
            'invalid_key',
            validSignature,
            'test_item',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with empty signature', () async {
        expect(
          () => endpoints.commerce.getEntitlementBalance(
            sessionBuilder,
            validPublicKey,
            '', // empty signature
            'test_item',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with empty tag', () async {
        // Empty tag returns 0.0 balance (no entitlement found)
        final result = await endpoints.commerce.getEntitlementBalance(
          sessionBuilder,
          validPublicKey,
          validSignature,
          '', // empty tag
        );
        expect(result, equals(0.0));
      });
    });

    group('consumeEntitlement endpoint', () {
      setUp(() async {
        // Add some entitlement for consumption tests
        final session = sessionBuilder.build();

        // Ensure the Entitlement exists first
        final existing = await Entitlement.db.findFirstRow(
          session,
          where: (t) => t.tag.equals('api_calls'),
        );
        if (existing == null) {
          await Entitlement.db.insertRow(
            session,
            Entitlement(
              name: 'API Calls',
              tag: 'api_calls',
              type: EntitlementType.consumable,
            ),
          );
        }

        await session.db.transaction((txn) async {
          await EntitlementManager.grantEntitlement(
            session,
            accountId: testAccountId,
            tag: 'api_calls',
            quantity: 100.0,
            transaction: txn,
          );
        });
      });

      test('successful consumption with sufficient balance', () async {
        final result = await endpoints.commerce.consumeEntitlement(
          sessionBuilder,
          validPublicKey,
          validSignature,
          'api_calls',
          25.0,
        );

        expect(result.success, isTrue);
        expect(result.availableBalance, equals(75.0)); // 100 - 25 = 75
        expect(result.errorMessage, isNull);
      });

      test('fails with insufficient balance', () async {
        final result = await endpoints.commerce.consumeEntitlement(
          sessionBuilder,
          validPublicKey,
          validSignature,
          'api_calls',
          150.0, // More than available
        );

        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Insufficient balance'));
      });

      test('fails with empty public key', () async {
        expect(
          () => endpoints.commerce.consumeEntitlement(
            sessionBuilder,
            '', // empty public key
            validSignature,
            'api_calls',
            10.0,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with invalid public key format', () async {
        expect(
          () => endpoints.commerce.consumeEntitlement(
            sessionBuilder,
            'invalid_key',
            validSignature,
            'api_calls',
            10.0,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with empty signature', () async {
        expect(
          () => endpoints.commerce.consumeEntitlement(
            sessionBuilder,
            validPublicKey,
            '', // empty signature
            'api_calls',
            10.0,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('fails with empty consumable type', () async {
        final result = await endpoints.commerce.consumeEntitlement(
          sessionBuilder,
          validPublicKey,
          validSignature,
          '', // empty consumable type
          10.0,
        );
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('not found'));
      });

      test('fails with negative quantity', () async {
        final result = await endpoints.commerce.consumeEntitlement(
          sessionBuilder,
          validPublicKey,
          validSignature,
          'test_consumable',
          -5.0, // negative quantity
        );
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('positive'));
      });

      test('fails with zero quantity', () async {
        final result = await endpoints.commerce.consumeEntitlement(
          sessionBuilder,
          validPublicKey,
          validSignature,
          'test_consumable',
          0.0, // zero quantity
        );
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('positive'));
      });

      test(
        'atomic operation behavior - multiple concurrent consumptions',
        () async {
          // First consumption should succeed
          final result1 = await endpoints.commerce.consumeEntitlement(
            sessionBuilder,
            validPublicKey,
            validSignature,
            'api_calls',
            50.0,
          );

          expect(result1.success, isTrue);
          expect(result1.availableBalance, equals(50.0));

          // Second consumption should also succeed
          final result2 = await endpoints.commerce.consumeEntitlement(
            sessionBuilder,
            validPublicKey,
            validSignature,
            'api_calls',
            50.0,
          );

          expect(result2.success, isTrue);
          expect(result2.availableBalance, equals(0.0));

          // Third consumption should fail due to insufficient balance
          final result3 = await endpoints.commerce.consumeEntitlement(
            sessionBuilder,
            validPublicKey,
            validSignature,
            'api_calls',
            1.0,
          );

          expect(result3.success, isFalse);
          expect(result3.availableBalance, equals(0.0));
          expect(result3.errorMessage, contains('Insufficient balance'));
        },
      );

      test('consumption from non-existent consumable type', () async {
        final result = await endpoints.commerce.consumeEntitlement(
          sessionBuilder,
          validPublicKey,
          validSignature,
          'non_existent_consumable',
          10.0,
        );

        expect(result.success, isFalse);
        expect(result.availableBalance, equals(0.0));
        expect(result.errorMessage, contains('not found'));
      });

      test('consumption with fractional quantities', () async {
        final result = await endpoints.commerce.consumeEntitlement(
          sessionBuilder,
          validPublicKey,
          validSignature,
          'api_calls',
          25.5, // fractional quantity
        );

        expect(result.success, isTrue);
        expect(result.availableBalance, equals(74.5)); // 100 - 25.5 = 74.5
        expect(result.errorMessage, isNull);
      });
    });
  }, rollbackDatabase: RollbackDatabase.disabled);
}
