import 'dart:convert';
import '../generated/payment_rail.dart';
import '../generated/payment_request.dart';
import '../generated/payment_result.dart';

/// Abstract interface for payment rail implementations
/// 
/// This interface defines the contract that all payment rails must implement
/// to provide consistent payment processing across different payment methods
/// (X402, Monero, Apple IAP, Google IAP).
abstract class PaymentRailInterface {
  /// The type of payment rail this implementation handles
  PaymentRail get railType;
  
  /// Create a payment request for the specified amount and order
  /// 
  /// [amountUSD] - Payment amount in USD
  /// [orderId] - Unique order identifier
  /// 
  /// Returns a [PaymentRequest] with payment details and rail-specific metadata
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String orderId,
  });
  
  /// Process a callback/webhook from the payment rail
  /// 
  /// [callbackData] - Raw callback data from the payment service
  /// 
  /// Returns a [PaymentResult] indicating success/failure and transaction details
  Future<PaymentResult> processCallback(Map<String, dynamic> callbackData);
}

/// Extension to provide convenient access to rail-specific data
extension PaymentRequestExtension on PaymentRequest {
  /// Get rail data as a Map<String, dynamic>
  Map<String, dynamic> get railData {
    try {
      return jsonDecode(railDataJson) as Map<String, dynamic>;
    } catch (e) {
      return <String, dynamic>{};
    }
  }
  
  /// Create a PaymentRequest with rail data from a Map
  static PaymentRequest withRailData({
    required String paymentRef,
    required double amountUSD,
    required String orderId,
    required Map<String, dynamic> railData,
  }) {
    return PaymentRequest(
      paymentRef: paymentRef,
      amountUSD: amountUSD,
      orderId: orderId,
      railDataJson: jsonEncode(railData),
    );
  }
}