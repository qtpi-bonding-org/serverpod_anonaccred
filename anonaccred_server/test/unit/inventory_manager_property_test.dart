import 'dart:math';
import 'package:test/test.dart';
import 'package:anonaccred_server/anonaccred_server.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

/// **Feature: anonaccred-phase3, Property 4: Inventory Addition Consistency**
/// **Validates: Requirements 3.1, 3.4**

void main() {
  withServerpod('Inventory Manager Property Tests', (sessionBuilder, endpoints) {
    final random = Random();

    test('Property 4: Inventory Addition Consistency - For any inventory addition operation, the system should correctly increment balances or create new records while updating timestamps', () async {
      // Run 5 iterations during development (can be increased to 100+ for production)
      for (int i = 0; i < 5; i++) {
        // Generate random test data
        final consumableType = _generateRandomConsumableType();
        final quantity = _generateRandomQuantity();
        
        // Create a real account for this test
        final publicKey = _generateRandomPublicKey();
        final encryptedDataKey = 'test_encrypted_data_key_$i';
        
        final account = await endpoints.account.createAccount(
          sessionBuilder,
          publicKey,
          encryptedDataKey,
        );
        final accountId = account.id!;
        
        // Build session for this test iteration
        final session = sessionBuilder.build();
        
        // Test initial state - should have zero balance
        final initialBalance = await InventoryManager.getBalance(
          session,
          accountId: accountId,
          consumableType: consumableType,
        );
        expect(initialBalance, equals(0.0));
        
        // Test initial inventory - should be empty
        final initialInventory = await InventoryManager.getInventory(
          session,
          accountId,
        );
        final initialRecord = initialInventory.where(
          (inv) => inv.consumableType == consumableType,
        ).firstOrNull;
        expect(initialRecord, isNull);
        
        // Record timestamp before addition
        final beforeAddition = DateTime.now();
        
        // Add inventory (Requirement 3.1)
        await InventoryManager.addToInventory(
          session,
          accountId: accountId,
          consumableType: consumableType,
          quantity: quantity,
        );
        
        // Record timestamp after addition
        final afterAddition = DateTime.now();
        
        // Verify balance was incremented correctly
        final newBalance = await InventoryManager.getBalance(
          session,
          accountId: accountId,
          consumableType: consumableType,
        );
        expect(newBalance, equals(quantity));
        
        // Verify inventory record was created
        final newInventory = await InventoryManager.getInventory(
          session,
          accountId,
        );
        final newRecord = newInventory.where(
          (inv) => inv.consumableType == consumableType,
        ).first;
        
        expect(newRecord.accountId, equals(accountId));
        expect(newRecord.consumableType, equals(consumableType));
        expect(newRecord.quantity, equals(quantity));
        
        // Verify timestamp was updated (Requirement 3.4)
        expect(newRecord.lastUpdated.isAfter(beforeAddition) || 
               newRecord.lastUpdated.isAtSameMomentAs(beforeAddition), isTrue);
        expect(newRecord.lastUpdated.isBefore(afterAddition) || 
               newRecord.lastUpdated.isAtSameMomentAs(afterAddition), isTrue);
        
        // Test adding more to existing inventory
        final additionalQuantity = _generateRandomQuantity();
        final beforeSecondAddition = DateTime.now();
        
        await InventoryManager.addToInventory(
          session,
          accountId: accountId,
          consumableType: consumableType,
          quantity: additionalQuantity,
        );
        
        final afterSecondAddition = DateTime.now();
        
        // Verify balance was incremented correctly
        final finalBalance = await InventoryManager.getBalance(
          session,
          accountId: accountId,
          consumableType: consumableType,
        );
        expect(finalBalance, equals(quantity + additionalQuantity));
        
        // Verify timestamp was updated again
        final finalInventory = await InventoryManager.getInventory(
          session,
          accountId,
        );
        final finalRecord = finalInventory.where(
          (inv) => inv.consumableType == consumableType,
        ).first;
        
        expect(finalRecord.lastUpdated.isAfter(beforeSecondAddition) || 
               finalRecord.lastUpdated.isAtSameMomentAs(beforeSecondAddition), isTrue);
        expect(finalRecord.lastUpdated.isBefore(afterSecondAddition) || 
               finalRecord.lastUpdated.isAtSameMomentAs(afterSecondAddition), isTrue);
        
        // Test multiple consumable types for same account
        final secondConsumableType = _generateRandomConsumableType();
        final secondQuantity = _generateRandomQuantity();
        
        await InventoryManager.addToInventory(
          session,
          accountId: accountId,
          consumableType: secondConsumableType,
          quantity: secondQuantity,
        );
        
        // Verify both consumables exist independently
        final firstBalance = await InventoryManager.getBalance(
          session,
          accountId: accountId,
          consumableType: consumableType,
        );
        final secondBalance = await InventoryManager.getBalance(
          session,
          accountId: accountId,
          consumableType: secondConsumableType,
        );
        
        expect(firstBalance, equals(quantity + additionalQuantity));
        expect(secondBalance, equals(secondQuantity));
        
        // Verify inventory contains both records
        final multiInventory = await InventoryManager.getInventory(
          session,
          accountId,
        );
        expect(multiInventory.length, greaterThanOrEqualTo(2));
        
        final firstRecord = multiInventory.where(
          (inv) => inv.consumableType == consumableType,
        ).first;
        final secondRecord = multiInventory.where(
          (inv) => inv.consumableType == secondConsumableType,
        ).first;
        
        expect(firstRecord.quantity, equals(quantity + additionalQuantity));
        expect(secondRecord.quantity, equals(secondQuantity));
        
        // Clean up for next iteration
        await _cleanupTestData(session, accountId);
      }
    });

    test('Property 4 Extension: Invalid quantity rejection', () async {
      final consumableType = _generateRandomConsumableType();
      
      // Create a real account for this test
      final publicKey = _generateRandomPublicKey();
      final encryptedDataKey = 'test_encrypted_data_key_invalid';
      
      final account = await endpoints.account.createAccount(
        sessionBuilder,
        publicKey,
        encryptedDataKey,
      );
      final accountId = account.id!;
      final session = sessionBuilder.build();
      
      // Test zero quantity
      expect(
        () => InventoryManager.addToInventory(
          session,
          accountId: accountId,
          consumableType: consumableType,
          quantity: 0.0,
        ),
        throwsA(isA<InventoryException>()),
      );
      
      // Test negative quantity
      expect(
        () => InventoryManager.addToInventory(
          session,
          accountId: accountId,
          consumableType: consumableType,
          quantity: -1.0,
        ),
        throwsA(isA<InventoryException>()),
      );
      
      // Verify no inventory was created
      final balance = await InventoryManager.getBalance(
        session,
        accountId: accountId,
        consumableType: consumableType,
      );
      expect(balance, equals(0.0));
    });

    test('Property 4 Extension: Fractional quantities support', () async {
      final consumableType = _generateRandomConsumableType();
      
      // Create a real account for this test
      final publicKey = _generateRandomPublicKey();
      final encryptedDataKey = 'test_encrypted_data_key_fractional';
      
      final account = await endpoints.account.createAccount(
        sessionBuilder,
        publicKey,
        encryptedDataKey,
      );
      final accountId = account.id!;
      final session = sessionBuilder.build();
      
      // Test fractional quantity
      const fractionalQuantity = 0.5;
      
      await InventoryManager.addToInventory(
        session,
        accountId: accountId,
        consumableType: consumableType,
        quantity: fractionalQuantity,
      );
      
      final balance = await InventoryManager.getBalance(
        session,
        accountId: accountId,
        consumableType: consumableType,
      );
      expect(balance, equals(fractionalQuantity));
      
      // Add more fractional quantity
      const additionalFraction = 0.25;
      
      await InventoryManager.addToInventory(
        session,
        accountId: accountId,
        consumableType: consumableType,
        quantity: additionalFraction,
      );
      
      final finalBalance = await InventoryManager.getBalance(
        session,
        accountId: accountId,
        consumableType: consumableType,
      );
      expect(finalBalance, equals(fractionalQuantity + additionalFraction));
      
      // Clean up
      await _cleanupTestData(session, accountId);
    });

    /// **Feature: anonaccred-phase3, Property 5: Inventory Query Accuracy**
    /// **Validates: Requirements 3.2, 3.3, 5.1, 5.2, 5.4**
    test('Property 5: Inventory Query Accuracy - For any inventory query operation, the system should return accurate balance information without modifying existing data', () async {
      // Run 5 iterations during development (can be increased to 100+ for production)
      for (int i = 0; i < 5; i++) {
        // Create a real account for this test
        final publicKey = _generateRandomPublicKey();
        final encryptedDataKey = 'test_encrypted_data_key_query_$i';
        
        final account = await endpoints.account.createAccount(
          sessionBuilder,
          publicKey,
          encryptedDataKey,
        );
        final accountId = account.id!;
        final session = sessionBuilder.build();
        
        // Test empty account inventory query (Requirement 5.3 - handled in Property 6)
        final emptyInventory = await InventoryManager.getInventory(session, accountId);
        expect(emptyInventory, isEmpty);
        
        // Test balance query for non-existent consumable (Requirement 3.3)
        final nonExistentType = _generateRandomConsumableType();
        final zeroBalance = await InventoryManager.getBalance(
          session,
          accountId: accountId,
          consumableType: nonExistentType,
        );
        expect(zeroBalance, equals(0.0));
        
        // Add some inventory items
        final consumableTypes = <String>[];
        final quantities = <double>[];
        final numItems = random.nextInt(5) + 1; // 1-5 items
        
        for (int j = 0; j < numItems; j++) {
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
        
        // Test inventory query returns all items (Requirement 3.2, 5.1)
        final fullInventory = await InventoryManager.getInventory(session, accountId);
        expect(fullInventory.length, equals(numItems));
        
        // Verify each item is present with correct data
        for (int j = 0; j < numItems; j++) {
          final expectedType = consumableTypes[j];
          final expectedQuantity = quantities[j];
          
          // Find the inventory record for this consumable type
          final inventoryRecord = fullInventory.where(
            (inv) => inv.consumableType == expectedType,
          ).first;
          
          expect(inventoryRecord.accountId, equals(accountId));
          expect(inventoryRecord.consumableType, equals(expectedType));
          expect(inventoryRecord.quantity, equals(expectedQuantity));
          expect(inventoryRecord.lastUpdated, isNotNull);
          
          // Test specific balance query (Requirement 3.3, 5.2)
          final specificBalance = await InventoryManager.getBalance(
            session,
            accountId: accountId,
            consumableType: expectedType,
          );
          expect(specificBalance, equals(expectedQuantity));
        }
        
        // Test that queries don't modify data (Requirement 5.4)
        final inventoryBeforeQueries = await InventoryManager.getInventory(session, accountId);
        
        // Perform multiple queries
        for (int j = 0; j < 3; j++) {
          await InventoryManager.getInventory(session, accountId);
          for (final type in consumableTypes) {
            await InventoryManager.getBalance(
              session,
              accountId: accountId,
              consumableType: type,
            );
          }
        }
        
        // Verify data is unchanged
        final inventoryAfterQueries = await InventoryManager.getInventory(session, accountId);
        expect(inventoryAfterQueries.length, equals(inventoryBeforeQueries.length));
        
        for (int j = 0; j < inventoryBeforeQueries.length; j++) {
          final before = inventoryBeforeQueries[j];
          final after = inventoryAfterQueries.where(
            (inv) => inv.consumableType == before.consumableType,
          ).first;
          
          expect(after.quantity, equals(before.quantity));
          expect(after.lastUpdated, equals(before.lastUpdated));
        }
        
        // Test concurrent queries don't interfere (Requirement 5.4)
        final futures = <Future>[];
        for (int j = 0; j < 5; j++) {
          futures.add(InventoryManager.getInventory(session, accountId));
          for (final type in consumableTypes) {
            futures.add(InventoryManager.getBalance(
              session,
              accountId: accountId,
              consumableType: type,
            ));
          }
        }
        
        final results = await Future.wait(futures);
        
        // Verify all concurrent queries returned consistent results
        final inventoryResults = results.where((r) => r is List<AccountInventory>).cast<List<AccountInventory>>();
        for (final inventoryResult in inventoryResults) {
          expect(inventoryResult.length, equals(numItems));
        }
        
        // Clean up for next iteration
        await _cleanupTestData(session, accountId);
      }
    });

    /// **Feature: anonaccred-phase3, Property 6: Empty Account Handling**
    /// **Validates: Requirements 5.3**
    test('Property 6: Empty Account Handling - For any query on non-existent accounts, the system should return empty inventory lists without errors', () async {
      // Run 5 iterations during development (can be increased to 100+ for production)
      for (int i = 0; i < 5; i++) {
        // Create a real account for this test
        final publicKey = _generateRandomPublicKey();
        final encryptedDataKey = 'test_encrypted_data_key_empty_$i';
        
        final account = await endpoints.account.createAccount(
          sessionBuilder,
          publicKey,
          encryptedDataKey,
        );
        final accountId = account.id!;
        final session = sessionBuilder.build();
        
        // Test empty account inventory query (Requirement 5.3)
        final emptyInventory = await InventoryManager.getInventory(session, accountId);
        expect(emptyInventory, isEmpty);
        expect(emptyInventory, isA<List<AccountInventory>>());
        
        // Test balance query for any consumable type on empty account
        final consumableType = _generateRandomConsumableType();
        final balance = await InventoryManager.getBalance(
          session,
          accountId: accountId,
          consumableType: consumableType,
        );
        expect(balance, equals(0.0));
        
        // Test multiple consumable types on empty account
        for (int j = 0; j < 3; j++) {
          final randomType = _generateRandomConsumableType();
          final randomBalance = await InventoryManager.getBalance(
            session,
            accountId: accountId,
            consumableType: randomType,
          );
          expect(randomBalance, equals(0.0));
        }
        
        // Verify inventory is still empty after queries
        final stillEmptyInventory = await InventoryManager.getInventory(session, accountId);
        expect(stillEmptyInventory, isEmpty);
      }
    });
  });
}

// Test data generators
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
  // Generate quantities between 0.01 and 999.99
  return (random.nextDouble() * 999.98) + 0.01;
}

// Clean up test data
Future<void> _cleanupTestData(session, int accountId) async {
  try {
    await AccountInventory.db.deleteWhere(
      session,
      where: (t) => t.accountId.equals(accountId),
    );
  } catch (e) {
    // Ignore cleanup errors in tests
  }
}