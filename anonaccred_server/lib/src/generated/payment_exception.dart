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
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:anonaccred_server/src/generated/protocol.dart' as _i2;

abstract class PaymentException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  PaymentException._({
    required this.code,
    required this.message,
    this.details,
    this.orderId,
    this.paymentRail,
  });

  factory PaymentException({
    required String code,
    required String message,
    Map<String, String>? details,
    String? orderId,
    String? paymentRail,
  }) = _PaymentExceptionImpl;

  factory PaymentException.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaymentException(
      code: jsonSerialization['code'] as String,
      message: jsonSerialization['message'] as String,
      details: jsonSerialization['details'] == null
          ? null
          : _i2.Protocol().deserialize<Map<String, String>>(
              jsonSerialization['details'],
            ),
      orderId: jsonSerialization['orderId'] as String?,
      paymentRail: jsonSerialization['paymentRail'] as String?,
    );
  }

  String code;

  String message;

  Map<String, String>? details;

  String? orderId;

  String? paymentRail;

  /// Returns a shallow copy of this [PaymentException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PaymentException copyWith({
    String? code,
    String? message,
    Map<String, String>? details,
    String? orderId,
    String? paymentRail,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.PaymentException',
      'code': code,
      'message': message,
      if (details != null) 'details': details?.toJson(),
      if (orderId != null) 'orderId': orderId,
      if (paymentRail != null) 'paymentRail': paymentRail,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.PaymentException',
      'code': code,
      'message': message,
      if (details != null) 'details': details?.toJson(),
      if (orderId != null) 'orderId': orderId,
      if (paymentRail != null) 'paymentRail': paymentRail,
    };
  }

  @override
  String toString() {
    return 'PaymentException(code: $code, message: $message, details: $details, orderId: $orderId, paymentRail: $paymentRail)';
  }
}

class _Undefined {}

class _PaymentExceptionImpl extends PaymentException {
  _PaymentExceptionImpl({
    required String code,
    required String message,
    Map<String, String>? details,
    String? orderId,
    String? paymentRail,
  }) : super._(
         code: code,
         message: message,
         details: details,
         orderId: orderId,
         paymentRail: paymentRail,
       );

  /// Returns a shallow copy of this [PaymentException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PaymentException copyWith({
    String? code,
    String? message,
    Object? details = _Undefined,
    Object? orderId = _Undefined,
    Object? paymentRail = _Undefined,
  }) {
    return PaymentException(
      code: code ?? this.code,
      message: message ?? this.message,
      details: details is Map<String, String>?
          ? details
          : this.details?.map(
              (
                key0,
                value0,
              ) => MapEntry(
                key0,
                value0,
              ),
            ),
      orderId: orderId is String? ? orderId : this.orderId,
      paymentRail: paymentRail is String? ? paymentRail : this.paymentRail,
    );
  }
}
