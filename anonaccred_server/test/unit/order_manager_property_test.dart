import 'dart:math';
import 'package:test/test.dart';
import 'package:anonaccred_server/anonaccred_server.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

/// **Feature: anonaccred-phase3, Property 2: Order Creation Integrity**
/// **Validates: Requirements 2.1, 2.2, 2.4, 2.5**
/// 
/// **Feature: anonaccred-phase3, Property 3: Order Validation**
/// **Validates: Requirements 2.3**

void main() {
  withServerpod('Order Manager Property Tests', (sessionBuilder, endpoints) {
    final random = Random();

    setUp(() {
      // Clear registry before each test to ensure clean state
      PriceRegistry().clearRegistry();
    });

    test('Property 2: Order Creation Integrity - For any valid order creation request, the system should generate a unique transaction with pending status and correct price calculation based on current registry prices', () async {
      // Run 5 iterations during development (can be increased to 100+ for production)
      for (int i = 0; i < 5; i++) {
        final registry = PriceRegistry();
        
        // Generate random test data
        final items = _generateRandomValidItems();
        
        // Create a test account first
        final session = sessionBuilder.build();
        final account = await endpoints.account.createAccount(
          sessionBuilder,
          _generateRandomPublicKey(),
          'encrypted_data_key_test',
        );
        final accountId = account.id!;
        
        // Register all products in the registry first
        for (final entry in items.entries) {
          final price = _generateRandomPrice();
          registry.registerProduct(entry.key, price);
        }
        
        // Calculate expected total
        final expectedTotal = OrderManager.calculateTotal(items);
        
        // Create order (Requirements 2.1, 2.2, 2.4, 2.5)
        final transaction = await OrderManager.createOrder(
          session,
          accountId: accountId,
          items: items,
          priceCurrency: Currency.USD,
          paymentRail: PaymentRail.monero,
          paymentCurrency: Currency.XMR,
        );
        
        // Verify transaction properties (Requirement 2.1)
        expect(transaction.id, isNotNull);
        expect(transaction.accountId, equals(accountId));
        expect(transaction.priceCurrency, equals(Currency.USD));
        expect(transaction.paymentRail, equals(PaymentRail.monero));
        expect(transaction.paymentCurrency, equals(Currency.XMR));
        
        // Verify price calculation (Requirement 2.2)
        expect(transaction.price, equals(expectedTotal));
        expect(transaction.paymentAmount, equals(expectedTotal));
        
        // Verify unique transaction ID (Requirement 2.4)
        expect(transaction.externalId, isNotNull);
        expect(transaction.externalId.length, greaterThan(0));
        
        // Verify initial status (Requirement 2.5)
        expect(transaction.status, equals(OrderStatus.pending));
        
        // Verify timestamp is recent
        final now = DateTime.now();
        final timeDiff = now.difference(transaction.timestamp).inSeconds.abs();
        expect(timeDiff, lessThan(5)); // Within 5 seconds
        
        // Verify consumables were created
        final consumables = await TransactionConsumable.db.find(
          session,
          where: (t) => t.transactionId.equals(transaction.id!),
        );
        
        expect(consumables.length, equals(items.length));
        
        for (final consumable in consumables) {
          expect(items.containsKey(consumable.consumableType), isTrue);
          expect(consumable.quantity, equals(items[consumable.consumableType]));
        }
        
        // Test uniqueness across multiple orders
        final secondTransaction = await OrderManager.createOrder(
          session,
          accountId: accountId,
          items: items,
          priceCurrency: Currency.USD,
          paymentRail: PaymentRail.x402_http,
          paymentCurrency: Currency.USD,
        );
        
        // Verify transactions are unique
        expect(secondTransaction.id, isNot(equals(transaction.id)));
        expect(secondTransaction.externalId, isNot(equals(transaction.externalId)));
        
        // Clean up for next iteration
        await TransactionConsumable.db.deleteWhere(
          session,
          where: (t) => t.transactionId.equals(transaction.id!) | 
                       t.transactionId.equals(secondTransaction.id!),
        );
        await TransactionPayment.db.deleteWhere(
          session,
          where: (t) => t.id.equals(transaction.id!) | 
                       t.id.equals(secondTransaction.id!),
        );
        registry.clearRegistry();
      }
    });

    test('Property 3: Order Validation - For any order creation request with unregistered consumable types, the system should reject the order with appropriate error messaging', () async {
      // Run 5 iterations during development
      for (int i = 0; i < 5; i++) {
        final registry = PriceRegistry();
        
        // Generate test data with some registered and some unregistered products
        final registeredItems = _generateRandomValidItems();
        final unregisteredItems = _generateRandomValidItems();
        
        // Create a test account first
        final session = sessionBuilder.build();
        final account = await endpoints.account.createAccount(
          sessionBuilder,
          _generateRandomPublicKey(),
          'encrypted_data_key_test',
        );
        final accountId = account.id!;
        
        // Register only some products
        for (final entry in registeredItems.entries) {
          final price = _generateRandomPrice();
          registry.registerProduct(entry.key, price);
        }
        
        // Combine registered and unregistered items
        final allItems = <String, double>{};
        allItems.addAll(registeredItems);
        allItems.addAll(unregisteredItems);
        
        // Attempt to create order with unregistered products (Requirement 2.3)
        try {
          await OrderManager.createOrder(
            session,
            accountId: accountId,
            items: allItems,
            priceCurrency: Currency.USD,
            paymentRail: PaymentRail.monero,
            paymentCurrency: Currency.XMR,
          );
          
          // Should not reach here
          fail('Expected PaymentException for unregistered products');
        } on PaymentException catch (e) {
          // Verify error properties
          expect(e.code, equals(AnonAccredErrorCodes.priceRegistryProductNotFound));
          expect(e.message, contains('Product not registered'));
          expect(e.details, isNotNull);
          
          // Verify error contains information about unregistered product
          final unregisteredSku = unregisteredItems.keys.first;
          expect(e.details!['sku'], equals(unregisteredSku));
          expect(e.details!['availableProducts'], isNotNull);
        }
        
        // Test with invalid quantities
        final validItems = _generateRandomValidItems();
        for (final entry in validItems.entries) {
          registry.registerProduct(entry.key, _generateRandomPrice());
        }
        
        // Add item with invalid quantity
        final invalidItems = Map<String, double>.from(validItems);
        invalidItems[validItems.keys.first] = -1.0; // Invalid negative quantity
        
        try {
          await OrderManager.createOrder(
            session,
            accountId: accountId,
            items: invalidItems,
            priceCurrency: Currency.USD,
            paymentRail: PaymentRail.monero,
            paymentCurrency: Currency.XMR,
          );
          
          fail('Expected PaymentException for invalid quantity');
        } on PaymentException catch (e) {
          expect(e.code, equals(AnonAccredErrorCodes.orderInvalidQuantity));
          expect(e.message, contains('Invalid quantity'));
          expect(e.details!['quantity'], equals('-1.0'));
        }
        
        // Test with zero quantity
        invalidItems[validItems.keys.first] = 0.0;
        
        try {
          await OrderManager.createOrder(
            session,
            accountId: accountId,
            items: invalidItems,
            priceCurrency: Currency.USD,
            paymentRail: PaymentRail.monero,
            paymentCurrency: Currency.XMR,
          );
          
          fail('Expected PaymentException for zero quantity');
        } on PaymentException catch (e) {
          expect(e.code, equals(AnonAccredErrorCodes.orderInvalidQuantity));
          expect(e.message, contains('Invalid quantity'));
          expect(e.details!['quantity'], equals('0.0'));
        }
        
        registry.clearRegistry();
      }
    });

    test('Property 2 Extension: Price calculation consistency', () {
      // Test that calculateTotal works independently of order creation
      final registry = PriceRegistry();
      
      for (int i = 0; i < 5; i++) {
        final items = _generateRandomValidItems();
        
        // Register products with known prices
        final expectedTotal = items.entries.fold<double>(0.0, (sum, entry) {
          final price = _generateRandomPrice();
          registry.registerProduct(entry.key, price);
          return sum + (price * entry.value);
        });
        
        // Calculate total using OrderManager
        final calculatedTotal = OrderManager.calculateTotal(items);
        
        expect(calculatedTotal, equals(expectedTotal));
        
        registry.clearRegistry();
      }
    });

    test('Property 2 Extension: Atomic transaction behavior', () async {
      // Test that failed order creation doesn't leave partial data
      final registry = PriceRegistry();
      final session = sessionBuilder.build();
      
      // Create a test account first
      final account = await endpoints.account.createAccount(
        sessionBuilder,
        _generateRandomPublicKey(),
        'encrypted_data_key_test',
      );
      final accountId = account.id!;
      
      // Register some products but not all
      final registeredItems = _generateRandomValidItems();
      final unregisteredItems = _generateRandomValidItems();
      
      for (final entry in registeredItems.entries) {
        registry.registerProduct(entry.key, _generateRandomPrice());
      }
      
      final allItems = <String, double>{};
      allItems.addAll(registeredItems);
      allItems.addAll(unregisteredItems);
      
      // Count existing transactions before attempt
      final initialTransactionCount = await TransactionPayment.db.count(session);
      final initialConsumableCount = await TransactionConsumable.db.count(session);
      
      try {
        await OrderManager.createOrder(
          session,
          accountId: accountId,
          items: allItems,
          priceCurrency: Currency.USD,
          paymentRail: PaymentRail.monero,
          paymentCurrency: Currency.XMR,
        );
        fail('Expected exception for unregistered products');
      } on PaymentException {
        // Expected exception
      }
      
      // Verify no partial data was created
      final finalTransactionCount = await TransactionPayment.db.count(session);
      final finalConsumableCount = await TransactionConsumable.db.count(session);
      
      expect(finalTransactionCount, equals(initialTransactionCount));
      expect(finalConsumableCount, equals(initialConsumableCount));
    });

    /// **Feature: anonaccred-phase3, Property 7: Order Fulfillment Completeness**
    /// **Validates: Requirements 4.1, 4.2, 4.5**
    test('Property 7: Order Fulfillment Completeness - For any order fulfillment operation, the system should add all order items to inventory and update transaction status to completed', () async {
      // Run 5 iterations during development (can be increased to 100+ for production)
      for (int i = 0; i < 5; i++) {
        final registry = PriceRegistry();
        final session = sessionBuilder.build();
        
        // Create a test account first
        final account = await endpoints.account.createAccount(
          sessionBuilder,
          _generateRandomPublicKey(),
          'encrypted_data_key_test',
        );
        final accountId = account.id!;
        
        // Generate random test data
        final items = _generateRandomValidItems();
        
        // Register all products in the registry
        for (final entry in items.entries) {
          final price = _generateRandomPrice();
          registry.registerProduct(entry.key, price);
        }
        
        // Create order first
        final transaction = await OrderManager.createOrder(
          session,
          accountId: accountId,
          items: items,
          priceCurrency: Currency.USD,
          paymentRail: PaymentRail.monero,
          paymentCurrency: Currency.XMR,
        );
        
        // Verify initial state
        expect(transaction.status, equals(OrderStatus.pending));
        
        // Get initial inventory balances
        final initialInventory = await InventoryManager.getInventory(session, accountId);
        final initialBalances = <String, double>{};
        for (final inv in initialInventory) {
          initialBalances[inv.consumableType] = inv.quantity;
        }
        
        // Fulfill the order (Requirements 4.1, 4.2, 4.5)
        await OrderManager.fulfillOrder(session, transaction);
        
        // Verify transaction status updated (Requirement 4.2)
        final updatedTransaction = await TransactionPayment.db.findById(
          session,
          transaction.id!,
        );
        expect(updatedTransaction, isNotNull);
        expect(updatedTransaction!.status, equals(OrderStatus.paid));
        
        // Verify all items were added to inventory (Requirement 4.1)
        final finalInventory = await InventoryManager.getInventory(session, accountId);
        
        for (final entry in items.entries) {
          final consumableType = entry.key;
          final expectedQuantity = entry.value;
          
          // Find the inventory record for this consumable type
          final inventoryRecord = finalInventory.firstWhere(
            (inv) => inv.consumableType == consumableType,
            orElse: () => throw StateError('Inventory record not found for $consumableType'),
          );
          
          // Calculate expected final balance
          final initialBalance = initialBalances[consumableType] ?? 0.0;
          final expectedFinalBalance = initialBalance + expectedQuantity;
          
          expect(inventoryRecord.quantity, equals(expectedFinalBalance));
          expect(inventoryRecord.accountId, equals(accountId));
          
          // Verify timestamp was updated
          expect(inventoryRecord.lastUpdated, isNotNull);
          final timeDiff = DateTime.now().difference(inventoryRecord.lastUpdated).inSeconds.abs();
          expect(timeDiff, lessThan(5)); // Within 5 seconds
        }
        
        // Verify atomic operation (Requirement 4.5) - all items should be added together
        // If we have multiple items, verify they were all processed
        if (items.length > 1) {
          // All consumables should have been processed
          for (final consumableType in items.keys) {
            final balance = await InventoryManager.getBalance(
              session,
              accountId: accountId,
              consumableType: consumableType,
            );
            final initialBalance = initialBalances[consumableType] ?? 0.0;
            final expectedBalance = initialBalance + items[consumableType]!;
            expect(balance, equals(expectedBalance));
          }
        }
        
        // Test fulfillment idempotency - fulfilling again should not change anything
        final preSecondFulfillInventory = await InventoryManager.getInventory(session, accountId);
        
        // Fulfilling the same transaction again should not add items twice
        // (This tests that the system handles duplicate fulfillment requests properly)
        await OrderManager.fulfillOrder(session, transaction);
        
        final postSecondFulfillInventory = await InventoryManager.getInventory(session, accountId);
        
        // Inventory should be the same after second fulfillment
        expect(postSecondFulfillInventory.length, equals(preSecondFulfillInventory.length));
        for (int j = 0; j < preSecondFulfillInventory.length; j++) {
          expect(postSecondFulfillInventory[j].quantity, 
                 equals(preSecondFulfillInventory[j].quantity));
        }
        
        // Clean up for next iteration
        await TransactionConsumable.db.deleteWhere(
          session,
          where: (t) => t.transactionId.equals(transaction.id!),
        );
        await TransactionPayment.db.deleteWhere(
          session,
          where: (t) => t.id.equals(transaction.id!),
        );
        await AccountInventory.db.deleteWhere(
          session,
          where: (t) => t.accountId.equals(accountId),
        );
        registry.clearRegistry();
      }
    });
  });
}

// Test data generators
String _generateRandomPublicKey() {
  final random = Random();
  const chars = '0123456789abcdef';
  return List.generate(64, (index) => chars[random.nextInt(chars.length)]).join();
}

Map<String, double> _generateRandomValidItems() {
  final random = Random();
  const skuPrefixes = ['storage', 'api', 'compute', 'bandwidth', 'credits'];
  const skuSuffixes = ['days', 'calls', 'hours', 'gb', 'units'];
  
  final itemCount = random.nextInt(3) + 1; // 1-3 items
  final items = <String, double>{};
  
  for (int i = 0; i < itemCount; i++) {
    final prefix = skuPrefixes[random.nextInt(skuPrefixes.length)];
    final suffix = skuSuffixes[random.nextInt(skuSuffixes.length)];
    final number = random.nextInt(1000);
    final sku = '${prefix}_${suffix}_$number';
    
    // Generate positive quantities between 0.1 and 100
    final quantity = (random.nextDouble() * 99.9) + 0.1;
    items[sku] = quantity;
  }
  
  return items;
}

double _generateRandomPrice() {
  final random = Random();
  // Generate prices between 0.01 and 999.99
  return (random.nextDouble() * 999.98) + 0.01;
}