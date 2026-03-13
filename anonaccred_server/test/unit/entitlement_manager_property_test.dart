import 'dart:math';

import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

/// **Feature: anonaccred-phase3, Property 4: Entitlement Addition Consistency**
/// **Validates: Requirements 3.1, 3.4**

void main() {
  withServerpod(
    'Entitlement Manager Property Tests',
    (sessionBuilder, endpoints) {
    final random = Random();

    test(
      'Property 4: Entitlement Addition Consistency - For any entitlement addition operation, the system should correctly increment balances or create new records while updating timestamps',
      () async {
        // Run 5 iterations during development (can be increased to 100+ for production)
        for (var i = 0; i < 5; i++) {
          // Generate random test data
          final tag = _generateRandomTag();
          final quantity = _generateRandomQuantity();

          // Create a real account for this test
          final publicKey = _generateRandomPublicKey();
          final encryptedDataKey = 'test_encrypted_data_key_$i';

          final session = sessionBuilder.build();
          final account = await AnonAccount.db.insertRow(session, AnonAccount(
            ultimateSigningPublicKeyHex: publicKey,
            encryptedDataKey: encryptedDataKey,
            ultimatePublicKey: publicKey, // ultimatePublicKey - using same key for testing
          ));
          final accountId = account.id!;

          // REQUIREMENT: Must create the Entitlement record first for EntitlementManager to work
          final createdEntitlement = await Entitlement.db.insertRow(
            session,
            Entitlement(
              tag: tag,
              name: 'Test $tag',
              type: EntitlementType.consumable,
            ),
          );
          final entitlementId = createdEntitlement.id!;

          // Test initial state - should have zero balance
          final initialBalance = await EntitlementManager.getEntitlementBalance(
            session,
            accountId: accountId,
            tag: tag,
          );
          expect(initialBalance, equals(0.0));

          // Test initial entitlements - should be empty/null for this tag
          final initialEntitlements =
              await EntitlementManager.getAccountEntitlements(
                session,
                accountId: accountId,
              );
          final initialRecord = initialEntitlements
              .where((e) => e.entitlementId == entitlementId)
              .firstOrNull;
          expect(initialRecord, isNull);

          // Add entitlement (Requirement 3.1)
          await session.db.transaction((txn) async {
            await EntitlementManager.grantEntitlement(
              session,
              accountId: accountId,
              tag: tag,
              quantity: quantity,
              transaction: txn,
            );
          });

          // Verify balance was incremented correctly
          final newBalance = await EntitlementManager.getEntitlementBalance(
            session,
            accountId: accountId,
            tag: tag,
          );
          expect(newBalance, equals(quantity));

          // Verify entitlement record was created
          final newEntitlements =
              await EntitlementManager.getAccountEntitlements(
                session,
                accountId: accountId,
              );
          final newRecord = newEntitlements
              .where((e) => e.entitlementId == entitlementId)
              .first;

          expect(newRecord.accountId, equals(accountId));
          expect(newRecord.entitlementId, equals(entitlementId));
          expect(newRecord.balance, equals(quantity));

          // Test adding more to existing entitlement
          final additionalQuantity = _generateRandomQuantity();

          await session.db.transaction((txn) async {
            await EntitlementManager.grantEntitlement(
              session,
              accountId: accountId,
              tag: tag,
              quantity: additionalQuantity,
              transaction: txn,
            );
          });

          // Verify balance was incremented correctly
          final finalBalance = await EntitlementManager.getEntitlementBalance(
            session,
            accountId: accountId,
            tag: tag,
          );
          expect(finalBalance, equals(quantity + additionalQuantity));

          // Verify consistency
          final finalEntitlements =
              await EntitlementManager.getAccountEntitlements(
                session,
                accountId: accountId,
              );
          final finalRecord = finalEntitlements
              .where((e) => e.entitlementId == entitlementId)
              .first;
          expect(finalRecord.balance, equals(quantity + additionalQuantity));

          // Test multiple entitlement types for same account
          final secondTag = _generateRandomTag();
          final secondQuantity = _generateRandomQuantity();

          final secondEnt = await Entitlement.db.insertRow(
            session,
            Entitlement(
              tag: secondTag,
              name: 'Test $secondTag',
              type: EntitlementType.subscription,
            ),
          );
          final secondEntId = secondEnt.id!;

          await session.db.transaction((txn) async {
            await EntitlementManager.grantEntitlement(
              session,
              accountId: accountId,
              tag: secondTag,
              quantity: secondQuantity,
              transaction: txn,
            );
          });

          // Verify both entitlements exist independently
          final b1 = await EntitlementManager.getEntitlementBalance(
            session,
            accountId: accountId,
            tag: tag,
          );
          final b2 = await EntitlementManager.getEntitlementBalance(
            session,
            accountId: accountId,
            tag: secondTag,
          );

          expect(b1, equals(quantity + additionalQuantity));
          expect(b2, equals(secondQuantity));

          // Verify account entitlements contains both records
          final multiEnt = await EntitlementManager.getAccountEntitlements(
            session,
            accountId: accountId,
          );
          expect(multiEnt.length, greaterThanOrEqualTo(2));

          final rec1 = multiEnt
              .where((e) => e.entitlementId == entitlementId)
              .first;
          final rec2 = multiEnt
              .where((e) => e.entitlementId == secondEntId)
              .first;

          expect(rec1.balance, equals(quantity + additionalQuantity));
          expect(rec2.balance, equals(secondQuantity));

          // Clean up for next iteration
          await _cleanupTestData(session, accountId);
        }
      },
    );

    test('Property 4 Extension: Invalid quantity rejection', () async {
      final tag = _generateRandomTag();
      final publicKey = _generateRandomPublicKey();
      const encryptedDataKey = 'test_encrypted_data_key_invalid';

      final session = sessionBuilder.build();
      final account = await AnonAccount.db.insertRow(session, AnonAccount(
        ultimateSigningPublicKeyHex: publicKey,
        encryptedDataKey: encryptedDataKey,
        ultimatePublicKey: publicKey,
      ));
      final accountId = account.id!;

      await Entitlement.db.insertRow(
        session,
        Entitlement(
          tag: tag,
          name: 'Test $tag',
          type: EntitlementType.consumable,
        ),
      );

      // Test zero quantity
      await expectLater(
        session.db.transaction((txn) async {
          await EntitlementManager.grantEntitlement(
            session,
            accountId: accountId,
            tag: tag,
            quantity: 0.0,
            transaction: txn,
          );
        }),
        throwsA(isA<InventoryException>()),
      );

      // Test negative quantity
      await expectLater(
        session.db.transaction((txn) async {
          await EntitlementManager.grantEntitlement(
            session,
            accountId: accountId,
            tag: tag,
            quantity: -1.0,
            transaction: txn,
          );
        }),
        throwsA(isA<InventoryException>()),
      );

      // Verify no entitlement balance created
      final balance = await EntitlementManager.getEntitlementBalance(
        session,
        accountId: accountId,
        tag: tag,
      );
      expect(balance, equals(0.0));
    });

    test(
      'Property 5: Entitlement Query Accuracy - For any entitlement query operation, the system should return accurate balance information without modifying existing data',
      () async {
        for (var i = 0; i < 5; i++) {
          final publicKey = _generateRandomPublicKey();
          final encryptedDataKey = 'test_encrypted_data_key_query_$i';

          final session = sessionBuilder.build();
          final account = await AnonAccount.db.insertRow(session, AnonAccount(
            ultimateSigningPublicKeyHex: publicKey,
            encryptedDataKey: encryptedDataKey,
            ultimatePublicKey: publicKey,
          ));
          final accountId = account.id!;

          // Empty state
          final empty = await EntitlementManager.getAccountEntitlements(
            session,
            accountId: accountId,
          );
          expect(empty, isEmpty);

          final nonTag = _generateRandomTag();
          final zero = await EntitlementManager.getEntitlementBalance(
            session,
            accountId: accountId,
            tag: nonTag,
          );
          expect(zero, equals(0.0));

          // Add some items
          final tags = <String>[];
          final quantities = <double>[];
          final ids = <int>[];
          final numItems = random.nextInt(5) + 1;

          for (var j = 0; j < numItems; j++) {
            final tag = _generateRandomTag();
            final quantity = _generateRandomQuantity();

            tags.add(tag);
            quantities.add(quantity);

            final createdEnt = await Entitlement.db.insertRow(
              session,
              Entitlement(
                tag: tag,
                name: 'Test $tag',
                type: EntitlementType.consumable,
              ),
            );
            ids.add(createdEnt.id!);

            await session.db.transaction((txn) async {
              await EntitlementManager.grantEntitlement(
                session,
                accountId: accountId,
                tag: tag,
                quantity: quantity,
                transaction: txn,
              );
            });
          }

          final full = await EntitlementManager.getAccountEntitlements(
            session,
            accountId: accountId,
          );
          expect(full.length, equals(numItems));

          for (var j = 0; j < numItems; j++) {
            final expectedTag = tags[j];
            final expectedQuantity = quantities[j];
            final expectedId = ids[j];

            final rec = full.where((e) => e.entitlementId == expectedId).first;
            expect(rec.balance, equals(expectedQuantity));

            final b = await EntitlementManager.getEntitlementBalance(
              session,
              accountId: accountId,
              tag: expectedTag,
            );
            expect(b, equals(expectedQuantity));
          }

          // Queries don't change state
          final before = await EntitlementManager.getAccountEntitlements(
            session,
            accountId: accountId,
          );
          for (var j = 0; j < 3; j++) {
            await EntitlementManager.getAccountEntitlements(
              session,
              accountId: accountId,
            );
            for (final tag in tags) {
              await EntitlementManager.getEntitlementBalance(
                session,
                accountId: accountId,
                tag: tag,
              );
            }
          }
          final after = await EntitlementManager.getAccountEntitlements(
            session,
            accountId: accountId,
          );
          expect(after.length, equals(before.length));

          for (var j = 0; j < before.length; j++) {
            expect(after[j].balance, equals(before[j].balance));
          }

          await _cleanupTestData(session, accountId);
        }
      },
    );

    test(
      'Property 6: Empty Account Handling - Queries on non-existent accounts should return empty/zero',
      () async {
        for (var i = 0; i < 5; i++) {
          final publicKey = _generateRandomPublicKey();
          final session = sessionBuilder.build();
          final account = await AnonAccount.db.insertRow(session, AnonAccount(
            ultimateSigningPublicKeyHex: publicKey,
            encryptedDataKey: 'test_empty_$i',
            ultimatePublicKey: publicKey,
          ));
          final accountId = account.id!;

          final ents = await EntitlementManager.getAccountEntitlements(
            session,
            accountId: accountId,
          );
          expect(ents, isEmpty);

          final tag = _generateRandomTag();
          final b = await EntitlementManager.getEntitlementBalance(
            session,
            accountId: accountId,
            tag: tag,
          );
          expect(b, equals(0.0));
        }
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);
}

String _generateRandomPublicKey() {
  final random = Random();
  final buffer = StringBuffer();
  for (var i = 0; i < 128; i++) {
    buffer.write(random.nextInt(16).toRadixString(16));
  }
  return buffer.toString();
}

String _generateRandomTag() {
  final random = Random();
  const prefixes = ['storage', 'api', 'compute', 'bandwidth', 'credits'];
  final prefix = prefixes[random.nextInt(prefixes.length)];
  final number = random.nextInt(1000000);
  return '${prefix}_$number';
}

double _generateRandomQuantity() {
  final random = Random();
  return (random.nextDouble() * 999.98) + 0.01;
}

Future<void> _cleanupTestData(Session session, int accountId) async {
  try {
    await AccountEntitlement.db.deleteWhere(
      session,
      where: (t) => t.accountId.equals(accountId),
    );
  } catch (e) {
    // Ignore cleanup errors
  }
}
