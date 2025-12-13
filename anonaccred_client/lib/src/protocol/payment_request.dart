/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class PaymentRequest implements _i1.SerializableModel {
  PaymentRequest._({
    required this.paymentRef,
    required this.amountUSD,
    required this.orderId,
    required this.railDataJson,
  });

  factory PaymentRequest({
    required String paymentRef,
    required double amountUSD,
    required String orderId,
    required String railDataJson,
  }) = _PaymentRequestImpl;

  factory PaymentRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaymentRequest(
      paymentRef: jsonSerialization['paymentRef'] as String,
      amountUSD: (jsonSerialization['amountUSD'] as num).toDouble(),
      orderId: jsonSerialization['orderId'] as String,
      railDataJson: jsonSerialization['railDataJson'] as String,
    );
  }

  String paymentRef;

  double amountUSD;

  String orderId;

  String railDataJson;

  /// Returns a shallow copy of this [PaymentRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PaymentRequest copyWith({
    String? paymentRef,
    double? amountUSD,
    String? orderId,
    String? railDataJson,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.PaymentRequest',
      'paymentRef': paymentRef,
      'amountUSD': amountUSD,
      'orderId': orderId,
      'railDataJson': railDataJson,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PaymentRequestImpl extends PaymentRequest {
  _PaymentRequestImpl({
    required String paymentRef,
    required double amountUSD,
    required String orderId,
    required String railDataJson,
  }) : super._(
         paymentRef: paymentRef,
         amountUSD: amountUSD,
         orderId: orderId,
         railDataJson: railDataJson,
       );

  /// Returns a shallow copy of this [PaymentRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PaymentRequest copyWith({
    String? paymentRef,
    double? amountUSD,
    String? orderId,
    String? railDataJson,
  }) {
    return PaymentRequest(
      paymentRef: paymentRef ?? this.paymentRef,
      amountUSD: amountUSD ?? this.amountUSD,
      orderId: orderId ?? this.orderId,
      railDataJson: railDataJson ?? this.railDataJson,
    );
  }
}
