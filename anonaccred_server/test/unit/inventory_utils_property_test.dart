import 'dart:math';
import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart';
import 'package:anonaccred_server/anonaccred_server.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

/// **Feature: anonaccred-phase3, Property 9: Consumption Utility Success**
/// **Validates: Requirements 6.1**

void main() {
  withServerpod('Inventory Utils Property Tests', (sessionBuilder, endpoints) {
    final random = Random();

    test(
      'Property 9: Consumption Utility Success - For any consumption request with sufficient balance, the utility should atomically decrement the balance and return success',
      () async {
        // Run 5 iterations during development (can be increased to 100+ for production)
        for (int i = 0; i < 5; i++) {
          // Generate random test data
          final consumableType = _generateRandomConsumableType();
          final initialQuantity = _generateRandomQuantity();
          final consumeQuantity =
              initialQuantity *
              (0.1 + (random.nextDouble() * 0.8)); // 10-90% of initial

          // Create a real account for this test
          final publicKey = _generateRandomPublicKey();
          final encryptedDataKey = 'test_encrypted_data_key_consume_$i';

          final account = await endpoints.account.createAccount(
            sessionBuilder,
            publicKey,
            encryptedDataKey,
          );
          final accountId = account.id!;

          // Build session for this test iteration
          final session = sessionBuilder.build();

          // Add initial inventory
          await InventoryManager.addToInventory(
            session,
            accountId: accountId,
            consumableType: consumableType,
            quantity: initialQuantity,
          );

          // Verify initial balance
          final initialBalance = await InventoryManager.getBalance(
            session,
            accountId: accountId,
            consumableType: consumableType,
          );
          expect(initialBalance, equals(initialQuantity));

          // Test consumption with sufficient balance (Requirement 6.1)
          final result = await InventoryUtils.tryConsume(
            session,
            accountId: accountId,
            consumableType: consumableType,
            quantity: consumeQuantity,
          );

          // Verify successful consumption
          expect(result.success, isTrue);
          expect(result.errorMessage, isNull);
          expect(
            result.availableBalance,
            closeTo(initialQuantity - consumeQuantity, 0.0001),
          );

          // Verify balance was atomically decremented
          final newBalance = await InventoryManager.getBalance(
            session,
            accountId: accountId,
            consumableType: consumableType,
          );
          expect(
            newBalance,
            closeTo(initialQuantity - consumeQuantity, 0.0001),
          );

          // Test multiple consumptions from same account
          final secondConsumeQuantity =
              newBalance * 0.5; // Consume half of remaining

          final secondResult = await InventoryUtils.tryConsume(
            session,
            accountId: accountId,
            consumableType: consumableType,
            quantity: secondConsumeQuantity,
          );

          expect(secondResult.success, isTrue);
          expect(secondResult.errorMessage, isNull);
          expect(
            secondResult.availableBalance,
            closeTo(newBalance - secondConsumeQuantity, 0.0001),
          );

          // Verify final balance
          final finalBalance = await InventoryManager.getBalance(
            session,
            accountId: accountId,
            consumableType: consumableType,
          );
          expect(
            finalBalance,
            closeTo(newBalance - secondConsumeQuantity, 0.0001),
          );

          // Test exact balance consumption
          final exactResult = await InventoryUtils.tryConsume(
            session,
            accountId: accountId,
            consumableType: consumableType,
            quantity: finalBalance,
          );

          expect(exactResult.success, isTrue);
          expect(exactResult.errorMessage, isNull);
          expect(exactResult.availableBalance, closeTo(0.0, 0.0001));

          // Verify balance is now zero
          final zeroBalance = await InventoryManager.getBalance(
            session,
            accountId: accountId,
            consumableType: consumableType,
          );
          expect(zeroBalance, closeTo(0.0, 0.0001));

          // Clean up for next iteration
          await _cleanupTestData(session, accountId);
        }
      },
    );

    test(
      'Property 9 Extension: Consumption with multiple consumable types',
      () async {
        // Create a real account for this test
        final publicKey = _generateRandomPublicKey();
        const encryptedDataKey = 'test_encrypted_data_key_multi_consume';

        final account = await endpoints.account.createAccount(
          sessionBuilder,
          publicKey,
          encryptedDataKey,
        );
        final accountId = account.id!;
        final session = sessionBuilder.build();

        // Create multiple consumable types with different balances
        final consumableTypes = <String>[];
        final quantities = <double>[];

        for (int i = 0; i < 3; i++) {
          final consumableType = _generateRandomConsumableType();
          final quantity = _generateRandomQuantity();

          consumableTypes.add(consumableType);
          quantities.add(quantity);

          await InventoryManager.addToInventory(
            session,
            accountId: accountId,
            consumableType: consumableType,
            quantity: quantity,
          );
        }

        // Test consumption from each type independently
        final expectedBalances = List<double>.from(quantities);

        for (int i = 0; i < consumableTypes.length; i++) {
          final consumableType = consumableTypes[i];
          final initialQuantity = expectedBalances[i];
          final consumeQuantity = initialQuantity * 0.3; // Consume 30%

          final result = await InventoryUtils.tryConsume(
            session,
            accountId: accountId,
            consumableType: consumableType,
            quantity: consumeQuantity,
          );

          expect(result.success, isTrue);
          expect(result.errorMessage, isNull);
          expect(
            result.availableBalance,
            closeTo(initialQuantity - consumeQuantity, 0.0001),
          );

          // Update expected balance for this type
          expectedBalances[i] = initialQuantity - consumeQuantity;

          // Verify all balances match expected values
          for (int j = 0; j < consumableTypes.length; j++) {
            final actualBalance = await InventoryManager.getBalance(
              session,
              accountId: accountId,
              consumableType: consumableTypes[j],
            );
            expect(actualBalance, closeTo(expectedBalances[j], 0.0001));
          }
        }

        // Clean up
        await _cleanupTestData(session, accountId);
      },
    );

    test('Property 9 Extension: Fractional consumption', () async {
      // Create a real account for this test
      final publicKey = _generateRandomPublicKey();
      const encryptedDataKey = 'test_encrypted_data_key_fractional_consume';

      final account = await endpoints.account.createAccount(
        sessionBuilder,
        publicKey,
        encryptedDataKey,
      );
      final accountId = account.id!;
      final session = sessionBuilder.build();

      final consumableType = _generateRandomConsumableType();
      const initialQuantity = 10.0;

      // Add initial inventory
      await InventoryManager.addToInventory(
        session,
        accountId: accountId,
        consumableType: consumableType,
        quantity: initialQuantity,
      );

      // Test fractional consumption
      const fractionalConsume = 0.25;

      final result = await InventoryUtils.tryConsume(
        session,
        accountId: accountId,
        consumableType: consumableType,
        quantity: fractionalConsume,
      );

      expect(result.success, isTrue);
      expect(result.errorMessage, isNull);
      expect(
        result.availableBalance,
        closeTo(initialQuantity - fractionalConsume, 0.0001),
      );

      // Verify balance
      final newBalance = await InventoryManager.getBalance(
        session,
        accountId: accountId,
        consumableType: consumableType,
      );
      expect(newBalance, closeTo(initialQuantity - fractionalConsume, 0.0001));

      // Clean up
      await _cleanupTestData(session, accountId);
    });

    test(
      'Consumption failure scenarios - insufficient balance and invalid inputs',
      () async {
        // Create a real account for this test
        final publicKey = _generateRandomPublicKey();
        const encryptedDataKey = 'test_encrypted_data_key_failure';

        final account = await endpoints.account.createAccount(
          sessionBuilder,
          publicKey,
          encryptedDataKey,
        );
        final accountId = account.id!;
        final session = sessionBuilder.build();

        final consumableType = _generateRandomConsumableType();
        const initialQuantity = 5.0;

        // Add initial inventory
        await InventoryManager.addToInventory(
          session,
          accountId: accountId,
          consumableType: consumableType,
          quantity: initialQuantity,
        );

        // Test insufficient balance (Requirement 6.2)
        const excessiveQuantity = 10.0;

        final insufficientResult = await InventoryUtils.tryConsume(
          session,
          accountId: accountId,
          consumableType: consumableType,
          quantity: excessiveQuantity,
        );

        expect(insufficientResult.success, isFalse);
        expect(insufficientResult.availableBalance, equals(initialQuantity));
        expect(insufficientResult.errorMessage, isNotNull);
        expect(
          insufficientResult.errorMessage,
          contains('Insufficient balance'),
        );

        // Verify balance unchanged
        final unchangedBalance = await InventoryManager.getBalance(
          session,
          accountId: accountId,
          consumableType: consumableType,
        );
        expect(unchangedBalance, equals(initialQuantity));

        // Test zero quantity
        final zeroResult = await InventoryUtils.tryConsume(
          session,
          accountId: accountId,
          consumableType: consumableType,
          quantity: 0.0,
        );

        expect(zeroResult.success, isFalse);
        expect(zeroResult.errorMessage, contains('Quantity must be positive'));

        // Test negative quantity
        final negativeResult = await InventoryUtils.tryConsume(
          session,
          accountId: accountId,
          consumableType: consumableType,
          quantity: -1.0,
        );

        expect(negativeResult.success, isFalse);
        expect(
          negativeResult.errorMessage,
          contains('Quantity must be positive'),
        );

        // Test consumption from non-existent consumable type
        final nonExistentType = _generateRandomConsumableType();

        final nonExistentResult = await InventoryUtils.tryConsume(
          session,
          accountId: accountId,
          consumableType: nonExistentType,
          quantity: 1.0,
        );

        expect(nonExistentResult.success, isFalse);
        expect(nonExistentResult.availableBalance, equals(0.0));
        expect(
          nonExistentResult.errorMessage,
          contains('Insufficient balance'),
        );

        // Clean up
        await _cleanupTestData(session, accountId);
      },
    );

    test('Concurrent consumption operations (atomicity test)', () async {
      // Create a real account for this test
      final publicKey = _generateRandomPublicKey();
      const encryptedDataKey = 'test_encrypted_data_key_concurrent';

      final account = await endpoints.account.createAccount(
        sessionBuilder,
        publicKey,
        encryptedDataKey,
      );
      final accountId = account.id!;
      final session = sessionBuilder.build();

      final consumableType = _generateRandomConsumableType();
      const initialQuantity = 100.0;
      const consumeQuantity = 10.0;
      const numConcurrentOperations = 5;

      // Add initial inventory
      await InventoryManager.addToInventory(
        session,
        accountId: accountId,
        consumableType: consumableType,
        quantity: initialQuantity,
      );

      // Launch concurrent consumption operations
      final futures = <Future<ConsumeResult>>[];
      for (int i = 0; i < numConcurrentOperations; i++) {
        futures.add(
          InventoryUtils.tryConsume(
            session,
            accountId: accountId,
            consumableType: consumableType,
            quantity: consumeQuantity,
          ),
        );
      }

      final results = await Future.wait(futures);

      // Count successful operations
      final successfulOperations = results.where((r) => r.success).length;

      // Verify final balance matches expected result
      final finalBalance = await InventoryManager.getBalance(
        session,
        accountId: accountId,
        consumableType: consumableType,
      );

      final expectedBalance =
          initialQuantity - (successfulOperations * consumeQuantity);
      expect(finalBalance, closeTo(expectedBalance, 0.0001));

      // Verify all successful operations have consistent available balance
      final successfulResults = results.where((r) => r.success).toList();
      if (successfulResults.isNotEmpty) {
        // Each successful result should show the balance after its operation
        // Due to concurrent execution, we can't predict exact order, but all should be valid
        for (final result in successfulResults) {
          expect(result.availableBalance, greaterThanOrEqualTo(0.0));
          expect(result.availableBalance, lessThanOrEqualTo(initialQuantity));
        }
      }

      // Clean up
      await _cleanupTestData(session, accountId);
    });
  });
}

// Test data generators (same as inventory_manager_property_test.dart)
String _generateRandomPublicKey() {
  final random = Random();
  final buffer = StringBuffer();

  // Generate 64 hex characters for Ed25519 public key
  for (int i = 0; i < 64; i++) {
    buffer.write(random.nextInt(16).toRadixString(16));
  }

  return buffer.toString();
}

String _generateRandomConsumableType() {
  final random = Random();
  const prefixes = ['storage', 'api', 'compute', 'bandwidth', 'credits'];
  const suffixes = ['days', 'calls', 'hours', 'gb', 'units'];

  final prefix = prefixes[random.nextInt(prefixes.length)];
  final suffix = suffixes[random.nextInt(suffixes.length)];
  final number = random.nextInt(1000);

  return '${prefix}_${suffix}_$number';
}

double _generateRandomQuantity() {
  final random = Random();
  // Generate quantities between 1.0 and 100.0 for consumption tests
  return (random.nextDouble() * 99.0) + 1.0;
}

// Clean up test data
Future<void> _cleanupTestData(Session session, int accountId) async {
  try {
    await AccountInventory.db.deleteWhere(
      session,
      where: (t) => t.accountId.equals(accountId),
    );
  } catch (e) {
    // Ignore cleanup errors in tests
  }
}
