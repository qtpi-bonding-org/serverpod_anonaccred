import 'package:serverpod/serverpod.dart';
import 'package:anonaccount_server/anonaccount_server.dart';

import '../exception_factory.dart';
import '../generated/protocol.dart';

/// Simple payment processor utilities for transaction status updates.
///
/// Provides basic methods for updating transaction status and payment references.
/// Aligned with the "Reactive & Anonymous" model using internalTransactionId.
class PaymentProcessor {
  /// Updates the status of a transaction by internalTransactionId
  static Future<void> updateTransactionStatus(
    Session session,
    String internalTransactionId,
    OrderStatus status,
  ) async {
    try {
      session.log(
        'Transaction status update initiated - ID: $internalTransactionId, NewStatus: $status',
        level: LogLevel.info,
      );

      final updatedRows = await TransactionPayment.db.updateWhere(
        session,
        where: (t) => t.internalTransactionId.equals(internalTransactionId),
        columnValues: (t) => [t.status(status)],
      );

      if (updatedRows.isEmpty) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.orderFulfillmentFailed,
          message: 'Transaction not found for ID: $internalTransactionId',
          internalTransactionId: internalTransactionId,
          details: {'operation': 'updateTransactionStatus'},
        );
      }
    } catch (e) {
      if (e is PaymentException) rethrow;

      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Failed to update transaction status: ${e.toString()}',
        internalTransactionId: internalTransactionId,
        details: {'error': e.toString()},
      );
    }
  }

  /// Updates the merchant reference (paymentRef) for a transaction
  static Future<void> updatePaymentRef(
    Session session,
    String internalTransactionId,
    String paymentRef,
  ) async {
    try {
      final updatedRows = await TransactionPayment.db.updateWhere(
        session,
        where: (t) => t.internalTransactionId.equals(internalTransactionId),
        columnValues: (t) => [t.paymentRef(paymentRef)],
      );

      if (updatedRows.isEmpty) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.orderFulfillmentFailed,
          message: 'Transaction not found for ID: $internalTransactionId',
          internalTransactionId: internalTransactionId,
        );
      }
    } catch (e) {
      if (e is PaymentException) rethrow;
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Failed to update payment reference: ${e.toString()}',
        internalTransactionId: internalTransactionId,
      );
    }
  }

  /// Updates the exact merchant timestamp (transactionTimestamp)
  static Future<void> updateTransactionTimestamp(
    Session session,
    String internalTransactionId,
    DateTime transactionTimestamp,
  ) async {
    try {
      final updatedRows = await TransactionPayment.db.updateWhere(
        session,
        where: (t) => t.internalTransactionId.equals(internalTransactionId),
        columnValues: (t) => [t.transactionTimestamp(transactionTimestamp)],
      );

      if (updatedRows.isEmpty) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.orderFulfillmentFailed,
          message: 'Transaction not found for ID: $internalTransactionId',
          internalTransactionId: internalTransactionId,
        );
      }
    } catch (e) {
      if (e is PaymentException) rethrow;
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Failed to update transaction timestamp: ${e.toString()}',
        internalTransactionId: internalTransactionId,
      );
    }
  }

  /// Updates both status and payment reference for a transaction
  static Future<void> updateStatusAndPaymentRef(
    Session session,
    String internalTransactionId,
    OrderStatus status,
    String paymentRef,
  ) async {
    try {
      final updatedRows = await TransactionPayment.db.updateWhere(
        session,
        where: (t) => t.internalTransactionId.equals(internalTransactionId),
        columnValues: (t) => [t.status(status), t.paymentRef(paymentRef)],
      );

      if (updatedRows.isEmpty) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.orderFulfillmentFailed,
          message: 'Transaction not found for ID: $internalTransactionId',
          internalTransactionId: internalTransactionId,
        );
      }
    } catch (e) {
      if (e is PaymentException) rethrow;
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Failed to update transaction status and ref: ${e.toString()}',
        internalTransactionId: internalTransactionId,
      );
    }
  }

  /// Retrieves a transaction by internalTransactionId
  static Future<TransactionPayment?> getTransactionById(
    Session session,
    String internalTransactionId,
  ) async {
    try {
      return await TransactionPayment.db.findFirstRow(
        session,
        where: (t) => t.internalTransactionId.equals(internalTransactionId),
      );
    } catch (e) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Failed to retrieve transaction: ${e.toString()}',
        internalTransactionId: internalTransactionId,
      );
    }
  }
}
