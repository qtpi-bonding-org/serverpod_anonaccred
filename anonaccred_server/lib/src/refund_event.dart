import 'generated/protocol.dart';

/// Standardized refund event DTO that any payment rail produces
/// when it detects a refund notification.
class RefundEvent {
  RefundEvent({
    required this.rail,
    required this.receiptHash,
    required this.paymentRef,
    this.productId,
    this.purchaseTimestamp,
    this.rawData,
  });

  /// Which payment rail this refund came from.
  final PaymentRail rail;

  /// SHA256 of the original store identifier (matches ReceiptHash.hash).
  final String receiptHash;

  /// Store reference that matches TransactionPayment.paymentRef
  /// (transactionId for Apple, orderId for Google).
  final String paymentRef;

  /// Optional: the store product ID.
  final String? productId;

  /// Optional: the original purchase timestamp.
  final DateTime? purchaseTimestamp;

  /// Optional: raw notification data for debugging.
  final Map<String, dynamic>? rawData;
}
