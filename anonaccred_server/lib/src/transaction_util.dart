import 'package:serverpod/serverpod.dart';
import 'exception_factory.dart';
import 'generated/protocol.dart';
import 'inventory_util.dart';

/// Utility class for transaction management operations
/// 
/// Provides transaction recording with complete line items and atomic
/// consistency between payments and inventory updates.
class TransactionUtil {
  /// Records a complete transaction with line items
  /// 
  /// Creates a TransactionPayment record with associated TransactionConsumable
  /// line items. All operations are performed atomically.
  /// 
  /// [transactionData] - Complete transaction information
  /// 
  /// Returns the created TransactionPayment with populated line items
  /// 
  /// Throws [PaymentException] if transaction recording fails
  static Future<TransactionPayment> recordTransaction(
    Session session,
    TransactionData transactionData,
  ) async {
    return await session.db.transaction((transaction) async {
      try {
        // Validate transaction data
        _validateTransactionData(transactionData);
        
        // Create the payment record
        final payment = await TransactionPayment.db.insertRow(
          session,
          TransactionPayment(
            externalId: transactionData.externalId,
            accountId: transactionData.accountId,
            priceCurrency: transactionData.priceCurrency,
            price: transactionData.price,
            paymentRail: transactionData.paymentRail,
            paymentCurrency: transactionData.paymentCurrency,
            paymentAmount: transactionData.paymentAmount,
            paymentRef: transactionData.paymentRef,
            status: transactionData.status,
          ),
          transaction: transaction,
        );

        // Create line items
        for (final lineItem in transactionData.lineItems) {
          await TransactionConsumable.db.insertRow(
            session,
            TransactionConsumable(
              transactionId: payment.id!,
              consumableType: lineItem.consumableType,
              quantity: lineItem.quantity,
            ),
            transaction: transaction,
          );
        }

        return payment;
      } catch (e) {
        if (e is PaymentException) {
          rethrow;
        }
        
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.databaseError,
          message: 'Failed to record transaction: ${e.toString()}',
          orderId: transactionData.externalId,
          paymentRail: transactionData.paymentRail.name,
          details: {'error': e.toString()},
        );
      }
    });
  }

  /// Processes a complete payment with inventory updates
  /// 
  /// Records the transaction and updates inventory balances atomically.
  /// Ensures consistency between payment completion and inventory updates.
  /// 
  /// [transactionData] - Complete transaction information
  /// 
  /// Returns the created TransactionPayment
  /// 
  /// Throws [PaymentException] or [InventoryException] if processing fails
  static Future<TransactionPayment> processPaymentWithInventory(
    Session session,
    TransactionData transactionData,
  ) async {
    return await session.db.transaction((transaction) async {
      // Record the transaction
      final payment = await recordTransaction(session, transactionData);
      
      // Update inventory for each line item (only if payment is successful)
      if (transactionData.status == OrderStatus.paid) {
        final inventoryOperations = transactionData.lineItems.map(
          (lineItem) => InventoryOperation(
            accountId: transactionData.accountId,
            consumableType: lineItem.consumableType,
            quantityDelta: lineItem.quantity,
          ),
        ).toList();
        
        await InventoryUtil.performAtomicInventoryOperations(
          session,
          inventoryOperations,
        );
      }
      
      return payment;
    });
  }

  /// Generates a payment receipt with complete transaction details
  /// 
  /// Creates a structured receipt containing pricing, payment rail information,
  /// and line item details.
  /// 
  /// [transactionId] - The transaction to generate receipt for
  /// 
  /// Returns a PaymentReceipt with complete details
  /// 
  /// Throws [PaymentException] if transaction not found
  static Future<PaymentReceipt> generatePaymentReceipt(
    Session session,
    int transactionId,
  ) async {
    try {
      // Get the transaction payment
      final payment = await TransactionPayment.db.findById(session, transactionId);
      if (payment == null) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.paymentFailed,
          message: 'Transaction not found: $transactionId',
          details: {'transactionId': transactionId.toString()},
        );
      }

      // Get the line items
      final lineItems = await TransactionConsumable.db.find(
        session,
        where: (t) => t.transactionId.equals(transactionId),
        orderBy: (t) => t.consumableType,
      );

      return PaymentReceipt(
        transactionId: payment.id!,
        externalId: payment.externalId,
        accountId: payment.accountId,
        priceCurrency: payment.priceCurrency,
        price: payment.price,
        paymentRail: payment.paymentRail,
        paymentCurrency: payment.paymentCurrency,
        paymentAmount: payment.paymentAmount,
        paymentRef: payment.paymentRef,
        status: payment.status,
        timestamp: payment.timestamp,
        lineItems: lineItems.map((item) => ReceiptLineItem(
          consumableType: item.consumableType,
          quantity: item.quantity,
        )).toList(),
      );
    } catch (e) {
      if (e is PaymentException) {
        rethrow;
      }
      
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.databaseError,
        message: 'Failed to generate payment receipt: ${e.toString()}',
        details: {
          'transactionId': transactionId.toString(),
          'error': e.toString(),
        },
      );
    }
  }

  /// Updates transaction status
  /// 
  /// Updates the status of an existing transaction. If status changes to 'paid',
  /// inventory will be updated accordingly.
  /// 
  /// [transactionId] - The transaction to update
  /// [newStatus] - The new status to set
  /// [paymentRef] - Optional payment reference to update
  /// 
  /// Returns the updated TransactionPayment
  static Future<TransactionPayment> updateTransactionStatus(
    Session session, {
    required int transactionId,
    required OrderStatus newStatus,
    String? paymentRef,
  }) async {
    return await session.db.transaction((transaction) async {
      try {
        // Get current transaction
        final payment = await TransactionPayment.db.findById(
          session, 
          transactionId,
          transaction: transaction,
        );
        
        if (payment == null) {
          throw AnonAccredExceptionFactory.createPaymentException(
            code: AnonAccredErrorCodes.paymentFailed,
            message: 'Transaction not found: $transactionId',
            details: {'transactionId': transactionId.toString()},
          );
        }

        final oldStatus = payment.status;
        
        // Update the payment status
        final updatedPayment = await TransactionPayment.db.updateRow(
          session,
          payment.copyWith(
            status: newStatus,
            paymentRef: paymentRef ?? payment.paymentRef,
          ),
          transaction: transaction,
        );

        // If status changed from non-paid to paid, update inventory
        if (oldStatus != OrderStatus.paid && newStatus == OrderStatus.paid) {
          final lineItems = await TransactionConsumable.db.find(
            session,
            where: (t) => t.transactionId.equals(transactionId),
            transaction: transaction,
          );

          final inventoryOperations = lineItems.map(
            (lineItem) => InventoryOperation(
              accountId: payment.accountId,
              consumableType: lineItem.consumableType,
              quantityDelta: lineItem.quantity,
            ),
          ).toList();

          await InventoryUtil.performAtomicInventoryOperations(
            session,
            inventoryOperations,
          );
        }

        return updatedPayment;
      } catch (e) {
        if (e is PaymentException || e is InventoryException) {
          rethrow;
        }
        
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.databaseError,
          message: 'Failed to update transaction status: ${e.toString()}',
          details: {
            'transactionId': transactionId.toString(),
            'error': e.toString(),
          },
        );
      }
    });
  }

  /// Validates transaction data before processing
  static void _validateTransactionData(TransactionData transactionData) {
    if (transactionData.externalId.trim().isEmpty) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentFailed,
        message: 'External ID cannot be empty',
        orderId: transactionData.externalId,
      );
    }

    if (transactionData.price <= 0) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentFailed,
        message: 'Price must be positive',
        orderId: transactionData.externalId,
        details: {'price': transactionData.price.toString()},
      );
    }

    if (transactionData.paymentAmount <= 0) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentFailed,
        message: 'Payment amount must be positive',
        orderId: transactionData.externalId,
        details: {'paymentAmount': transactionData.paymentAmount.toString()},
      );
    }

    if (transactionData.lineItems.isEmpty) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentFailed,
        message: 'Transaction must have at least one line item',
        orderId: transactionData.externalId,
      );
    }

    // Validate each line item
    for (final lineItem in transactionData.lineItems) {
      InventoryUtil.validateConsumableType(lineItem.consumableType);
      
      if (lineItem.quantity <= 0) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.paymentFailed,
          message: 'Line item quantity must be positive',
          orderId: transactionData.externalId,
          details: {
            'consumableType': lineItem.consumableType,
            'quantity': lineItem.quantity.toString(),
          },
        );
      }
    }
  }
}

/// Complete transaction data for recording
class TransactionData {
  final String externalId;
  final int accountId;
  final Currency priceCurrency;
  final double price;
  final PaymentRail paymentRail;
  final Currency paymentCurrency;
  final double paymentAmount;
  final String? paymentRef;
  final OrderStatus status;
  final List<TransactionLineItem> lineItems;

  const TransactionData({
    required this.externalId,
    required this.accountId,
    required this.priceCurrency,
    required this.price,
    required this.paymentRail,
    required this.paymentCurrency,
    required this.paymentAmount,
    this.paymentRef,
    required this.status,
    required this.lineItems,
  });
}

/// Line item for transaction recording
class TransactionLineItem {
  final String consumableType;
  final double quantity;

  const TransactionLineItem({
    required this.consumableType,
    required this.quantity,
  });
}

/// Payment receipt with complete transaction details
class PaymentReceipt {
  final int transactionId;
  final String externalId;
  final int accountId;
  final Currency priceCurrency;
  final double price;
  final PaymentRail paymentRail;
  final Currency paymentCurrency;
  final double paymentAmount;
  final String? paymentRef;
  final OrderStatus status;
  final DateTime timestamp;
  final List<ReceiptLineItem> lineItems;

  const PaymentReceipt({
    required this.transactionId,
    required this.externalId,
    required this.accountId,
    required this.priceCurrency,
    required this.price,
    required this.paymentRail,
    required this.paymentCurrency,
    required this.paymentAmount,
    this.paymentRef,
    required this.status,
    required this.timestamp,
    required this.lineItems,
  });
}

/// Line item in payment receipt
class ReceiptLineItem {
  final String consumableType;
  final double quantity;

  const ReceiptLineItem({
    required this.consumableType,
    required this.quantity,
  });
}