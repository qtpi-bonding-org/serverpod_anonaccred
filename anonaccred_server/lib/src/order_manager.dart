/// Order Manager for AnonAccred Commerce Foundation
///
/// Provides static methods for creating and managing purchase orders.
/// Handles order creation, price calculation, and fulfillment operations
/// using the existing TransactionPayment and TransactionConsumable models.
library;

import 'package:serverpod/serverpod.dart';

import 'exception_factory.dart';
import 'generated/protocol.dart';
import 'inventory_manager.dart';

import 'price_registry.dart';

/// Static service for managing order creation and fulfillment
class OrderManager {
  static const _uuid = Uuid();

  /// Creates a new order with the specified items and pricing
  ///
  /// Validates all items against the PriceRegistry, calculates total price,
  /// and creates a pending transaction record with associated consumables.
  ///
  /// Parameters:
  /// - [session]: Serverpod session for database operations
  /// - [accountId]: The account ID creating the order
  /// - [items]: Map of consumable types to quantities
  /// - [priceCurrency]: Currency for pricing (typically USD)
  /// - [paymentRail]: Payment method to be used
  /// - [paymentCurrency]: Currency for payment (may differ from price currency)
  ///
  /// Returns: The created TransactionPayment record
  ///
  /// Throws:
  /// - [PaymentException] if any item is not registered in PriceRegistry
  /// - [PaymentException] if any quantity is invalid (non-positive)
  /// - [AnonAccredException] for database or other system errors
  static Future<TransactionPayment> createOrder(
    Session session, {
    required int accountId,
    required Map<String, double> items,
    required Currency priceCurrency,
    required PaymentRail paymentRail,
    required Currency paymentCurrency,
  }) async {
    try {
      // Validate items and calculate total price
      final totalPrice = calculateTotal(items);

      // Generate unique external ID for tracking
      final externalId = _uuid.v4();

      // Create the main transaction record
      final transaction = TransactionPayment(
        externalId: externalId,
        accountId: accountId,
        priceCurrency: priceCurrency,
        price: totalPrice,
        paymentRail: paymentRail,
        paymentCurrency: paymentCurrency,
        paymentAmount: totalPrice, // For now, assume 1:1 conversion
        status: OrderStatus.pending,
      );

      // Use database transaction for atomicity
      return await session.db.transaction((dbTransaction) async {
        // Insert the main transaction
        final insertedTransaction = await TransactionPayment.db.insertRow(
          session,
          transaction,
          transaction: dbTransaction,
        );

        // Create consumable records for each item
        final consumables = items.entries
            .map(
              (entry) => TransactionConsumable(
                transactionId: insertedTransaction.id!,
                consumableType: entry.key,
                quantity: entry.value,
              ),
            )
            .toList();

        // Insert all consumables
        await TransactionConsumable.db.insert(
          session,
          consumables,
          transaction: dbTransaction,
        );

        return insertedTransaction;
      });
    } on PaymentException {
      rethrow; // Let specific payment exceptions bubble up
    } catch (e) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.orderCreationFailed,
        message: 'Failed to create order: ${e.toString()}',
        details: {
          'accountId': accountId.toString(),
          'itemCount': items.length.toString(),
          'error': e.toString(),
        },
      );
    }
  }

  /// Calculates the total price for a set of items using PriceRegistry
  ///
  /// Validates that all items are registered and have positive quantities.
  ///
  /// Parameters:
  /// - [items]: Map of consumable types to quantities
  ///
  /// Returns: Total price in USD
  ///
  /// Throws:
  /// - [PaymentException] if any item is not registered
  /// - [PaymentException] if any quantity is invalid
  static double calculateTotal(Map<String, double> items) {
    final registry = PriceRegistry();
    var total = 0.0;

    for (final entry in items.entries) {
      final sku = entry.key;
      final quantity = entry.value;

      // Validate quantity
      if (quantity <= 0) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.orderInvalidQuantity,
          message: 'Invalid quantity for item: $sku',
          details: {'sku': sku, 'quantity': quantity.toString()},
        );
      }

      // Get price from registry
      final price = registry.getPrice(sku);
      if (price == null) {
        throw AnonAccredExceptionFactory.createPriceRegistryException(
          code: AnonAccredErrorCodes.priceRegistryProductNotFound,
          message: 'Product not registered in price registry: $sku',
          sku: sku,
          details: {
            'availableProducts': registry.getAvailableProducts().join(', '),
          },
        );
      }

      total += price * quantity;
    }

    return total;
  }

  /// Fulfills a completed order by adding items to account inventory
  ///
  /// Updates the transaction status to completed and adds all order items
  /// to the account's inventory using atomic database operations.
  /// This method is idempotent - calling it multiple times on the same
  /// transaction will not add inventory items multiple times.
  ///
  /// Parameters:
  /// - [session]: Serverpod session for database operations
  /// - [transaction]: The transaction to fulfill
  ///
  /// Throws:
  /// - [PaymentException] for fulfillment failures
  /// - [AnonAccredException] for database or system errors
  static Future<void> fulfillOrder(
    Session session,
    TransactionPayment transaction,
  ) async {
    try {
      // Use database transaction for atomicity
      await session.db.transaction((dbTransaction) async {
        // Get the current transaction state to check if already fulfilled
        final currentTransaction = await TransactionPayment.db.findById(
          session,
          transaction.id!,
          transaction: dbTransaction,
        );

        if (currentTransaction == null) {
          throw AnonAccredExceptionFactory.createPaymentException(
            code: AnonAccredErrorCodes.orderFulfillmentFailed,
            message: 'Transaction not found for fulfillment',
            orderId: transaction.externalId,
            details: {
              'transactionId': transaction.id?.toString() ?? 'null',
              'reason': 'transaction_not_found',
            },
          );
        }

        // Check if already fulfilled (idempotent behavior)
        if (currentTransaction.status == OrderStatus.paid) {
          // Already fulfilled, nothing to do
          return;
        }

        // Only fulfill if status is pending
        if (currentTransaction.status != OrderStatus.pending) {
          throw AnonAccredExceptionFactory.createPaymentException(
            code: AnonAccredErrorCodes.orderFulfillmentFailed,
            message:
                'Cannot fulfill order with status: ${currentTransaction.status}',
            orderId: transaction.externalId,
            details: {
              'currentStatus': currentTransaction.status.toString(),
              'expectedStatus': OrderStatus.pending.toString(),
              'reason': 'invalid_status',
            },
          );
        }

        // Get all consumables for this transaction
        final consumables = await TransactionConsumable.db.find(
          session,
          where: (t) => t.transactionId.equals(transaction.id!),
          transaction: dbTransaction,
        );

        // Add each consumable to inventory using atomic operations
        for (final consumable in consumables) {
          await InventoryManager.updateInventoryBalance(
            session,
            accountId: transaction.accountId,
            consumableType: consumable.consumableType,
            quantityDelta: consumable.quantity,
            transaction: dbTransaction,
          );
        }

        // Update transaction status to completed
        await TransactionPayment.db.updateRow(
          session,
          currentTransaction.copyWith(status: OrderStatus.paid),
          transaction: dbTransaction,
        );
      });
    } catch (e) {
      if (e is PaymentException) {
        rethrow;
      }

      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.orderFulfillmentFailed,
        message: 'Failed to fulfill order: ${e.toString()}',
        orderId: transaction.externalId,
        details: {
          'transactionId': transaction.id?.toString() ?? 'null',
          'accountId': transaction.accountId.toString(),
          'error': e.toString(),
        },
      );
    }
  }
}
