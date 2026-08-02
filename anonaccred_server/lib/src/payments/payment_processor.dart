import 'package:serverpod/serverpod.dart';
import 'package:anonaccount_server/anonaccount_server.dart';

import '../protocol_failures.dart';
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
  ) async => tryOperation(
        session,
        'updateTransactionStatus',
        () async {
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
        },
        onFailure: ({
          required String code,
          required String message,
          required String operation,
          required Map<String, String> details,
        }) =>
            PaymentException(
          code: code,
          message: message,
          internalTransactionId: internalTransactionId,
          details: details,
        ),
        code: AnonAccountErrorCodes.databaseError,
      );

  /// Updates the merchant reference (paymentRef) for a transaction
  static Future<void> updatePaymentRef(
    Session session,
    String internalTransactionId,
    String paymentRef,
  ) async => tryOperation(
        session,
        'updatePaymentRef',
        () async {
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
        },
        onFailure: ({
          required String code,
          required String message,
          required String operation,
          required Map<String, String> details,
        }) =>
            PaymentException(
          code: code,
          message: message,
          internalTransactionId: internalTransactionId,
          details: details,
        ),
        code: AnonAccountErrorCodes.databaseError,
      );

  /// Updates the exact merchant timestamp (transactionTimestamp)
  static Future<void> updateTransactionTimestamp(
    Session session,
    String internalTransactionId,
    DateTime transactionTimestamp,
  ) async => tryOperation(
        session,
        'updateTransactionTimestamp',
        () async {
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
        },
        onFailure: ({
          required String code,
          required String message,
          required String operation,
          required Map<String, String> details,
        }) =>
            PaymentException(
          code: code,
          message: message,
          internalTransactionId: internalTransactionId,
          details: details,
        ),
        code: AnonAccountErrorCodes.databaseError,
      );

  /// Updates both status and payment reference for a transaction
  static Future<void> updateStatusAndPaymentRef(
    Session session,
    String internalTransactionId,
    OrderStatus status,
    String paymentRef,
  ) async => tryOperation(
        session,
        'updateStatusAndPaymentRef',
        () async {
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
        },
        onFailure: ({
          required String code,
          required String message,
          required String operation,
          required Map<String, String> details,
        }) =>
            PaymentException(
          code: code,
          message: message,
          internalTransactionId: internalTransactionId,
          details: details,
        ),
        code: AnonAccountErrorCodes.databaseError,
      );

  /// Retrieves a transaction by internalTransactionId
  static Future<TransactionPayment?> getTransactionById(
    Session session,
    String internalTransactionId,
  ) async => tryOperation(
        session,
        'getTransactionById',
        () => TransactionPayment.db.findFirstRow(
          session,
          where: (t) => t.internalTransactionId.equals(internalTransactionId),
        ),
        onFailure: ({
          required String code,
          required String message,
          required String operation,
          required Map<String, String> details,
        }) =>
            PaymentException(
          code: code,
          message: message,
          internalTransactionId: internalTransactionId,
          details: details,
        ),
        code: AnonAccountErrorCodes.databaseError,
      );
}
