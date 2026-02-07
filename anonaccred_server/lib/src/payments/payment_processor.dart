import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../exception_factory.dart';

/// Simple payment processor utilities for transaction status updates
///
/// Provides basic methods for updating transaction status and payment references
/// without complex state management or validation logic.
class PaymentProcessor {
  /// Updates the status of a transaction by external ID
  ///
  /// This method performs a simple status update without complex validation.
  /// Database constraints will handle any invalid state transitions.
  ///
  /// Requirement 9.2: Log payment status changes with timestamps and transaction references
  static Future<void> updateTransactionStatus(
    Session session,
    String externalId,
    OrderStatus status,
  ) async {
    try {
      // Log status change initiation (Requirement 9.2)
      session.log(
        'Transaction status update initiated - ExternalId: $externalId, NewStatus: $status, Timestamp: ${DateTime.now().toIso8601String()}',
        level: LogLevel.info,
      );

      final updatedRows = await TransactionPayment.db.updateWhere(
        session,
        where: (t) => t.externalId.equals(externalId),
        columnValues: (t) => [t.status(status)],
      );

      if (updatedRows.isEmpty) {
        // Log error with operation context (Requirement 9.3)
        session.log(
          'Transaction status update failed - Transaction not found: $externalId',
          level: LogLevel.error,
        );

        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.orderInvalidProduct,
          message: 'Transaction not found for external ID: $externalId',
          orderId: externalId,
          details: {'operation': 'updateTransactionStatus'},
        );
      }

      // Log successful status change (Requirement 9.2)
      session.log(
        'Transaction status updated successfully - ExternalId: $externalId, Status: $status, UpdatedRows: ${updatedRows.length}',
        level: LogLevel.info,
      );
    } catch (e) {
      if (e is PaymentException) {
        rethrow;
      }

      // Log error with complete error details and operation context (Requirement 9.3)
      session.log(
        'Transaction status update failed - ExternalId: $externalId, Status: $status, Error: ${e.toString()}',
        level: LogLevel.error,
      );

      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.databaseError,
        message: 'Failed to update transaction status: ${e.toString()}',
        orderId: externalId,
        details: {
          'operation': 'updateTransactionStatus',
          'status': status.toString(),
          'error': e.toString(),
        },
      );
    }
  }

  /// Updates the payment reference for a transaction by external ID
  ///
  /// Stores the payment reference returned by payment rails for tracking purposes.
  static Future<void> updatePaymentRef(
    Session session,
    String externalId,
    String paymentRef,
  ) async {
    try {
      final updatedRows = await TransactionPayment.db.updateWhere(
        session,
        where: (t) => t.externalId.equals(externalId),
        columnValues: (t) => [t.paymentRef(paymentRef)],
      );

      if (updatedRows.isEmpty) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.orderInvalidProduct,
          message: 'Transaction not found for external ID: $externalId',
          orderId: externalId,
          details: {'operation': 'updatePaymentRef'},
        );
      }
    } catch (e) {
      if (e is PaymentException) {
        rethrow;
      }
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.databaseError,
        message: 'Failed to update payment reference: ${e.toString()}',
        orderId: externalId,
        details: {
          'operation': 'updatePaymentRef',
          'paymentRef': paymentRef,
          'error': e.toString(),
        },
      );
    }
  }

  /// Updates the transaction timestamp for a transaction by external ID
  ///
  /// Stores the payment provider timestamp for refund matching.
  ///
  /// Requirement 9.2: Log payment status changes with timestamps and transaction references
  static Future<void> updateTransactionTimestamp(
    Session session,
    String externalId,
    DateTime transactionTimestamp,
  ) async {
    try {
      // Log transaction timestamp update initiation (Requirement 9.2)
      session.log(
        'Transaction timestamp update initiated - ExternalId: $externalId, Timestamp: ${transactionTimestamp.toIso8601String()}',
        level: LogLevel.info,
      );

      final updatedRows = await TransactionPayment.db.updateWhere(
        session,
        where: (t) => t.externalId.equals(externalId),
        columnValues: (t) => [t.transactionTimestamp(transactionTimestamp)],
      );

      if (updatedRows.isEmpty) {
        // Log error with operation context (Requirement 9.3)
        session.log(
          'Transaction timestamp update failed - Transaction not found: $externalId',
          level: LogLevel.error,
        );

        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.orderInvalidProduct,
          message: 'Transaction not found for external ID: $externalId',
          orderId: externalId,
          details: {'operation': 'updateTransactionTimestamp'},
        );
      }

      // Log successful transaction timestamp update (Requirement 9.2)
      session.log(
        'Transaction timestamp updated successfully - ExternalId: $externalId, Timestamp: ${transactionTimestamp.toIso8601String()}',
        level: LogLevel.info,
      );
    } catch (e) {
      if (e is PaymentException) {
        rethrow;
      }

      // Log error with complete error details and operation context (Requirement 9.3)
      session.log(
        'Transaction timestamp update failed - ExternalId: $externalId, Error: ${e.toString()}',
        level: LogLevel.error,
      );

      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.databaseError,
        message: 'Failed to update transaction timestamp: ${e.toString()}',
        orderId: externalId,
        details: {
          'operation': 'updateTransactionTimestamp',
          'timestamp': transactionTimestamp.toIso8601String(),
          'error': e.toString(),
        },
      );
    }
  }

  /// Updates both status and payment reference in a single operation
  ///
  /// Useful for payment rails that provide both pieces of information simultaneously.
  static Future<void> updateStatusAndPaymentRef(
    Session session,
    String externalId,
    OrderStatus status,
    String paymentRef,
  ) async {
    try {
      final updatedRows = await TransactionPayment.db.updateWhere(
        session,
        where: (t) => t.externalId.equals(externalId),
        columnValues: (t) => [t.status(status), t.paymentRef(paymentRef)],
      );

      if (updatedRows.isEmpty) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.orderInvalidProduct,
          message: 'Transaction not found for external ID: $externalId',
          orderId: externalId,
          details: {'operation': 'updateStatusAndPaymentRef'},
        );
      }
    } catch (e) {
      if (e is PaymentException) {
        rethrow;
      }
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.databaseError,
        message:
            'Failed to update status and payment reference: ${e.toString()}',
        orderId: externalId,
        details: {
          'operation': 'updateStatusAndPaymentRef',
          'status': status.toString(),
          'paymentRef': paymentRef,
          'error': e.toString(),
        },
      );
    }
  }

  /// Retrieves a transaction by external ID
  ///
  /// Helper method for payment rails that need to check transaction details.
  static Future<TransactionPayment?> getTransactionByExternalId(
    Session session,
    String externalId,
  ) async {
    try {
      return await TransactionPayment.db.findFirstRow(
        session,
        where: (t) => t.externalId.equals(externalId),
      );
    } catch (e) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.databaseError,
        message: 'Failed to retrieve transaction: ${e.toString()}',
        orderId: externalId,
        details: {
          'operation': 'getTransactionByExternalId',
          'error': e.toString(),
        },
      );
    }
  }
}
