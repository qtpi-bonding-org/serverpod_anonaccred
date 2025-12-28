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

abstract class PaymentResult
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  PaymentResult._({
    required this.success,
    this.orderId,
    this.transactionHash,
    this.errorMessage,
  });

  factory PaymentResult({
    required bool success,
    String? orderId,
    String? transactionHash,
    String? errorMessage,
  }) = _PaymentResultImpl;

  factory PaymentResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaymentResult(
      success: jsonSerialization['success'] as bool,
      orderId: jsonSerialization['orderId'] as String?,
      transactionHash: jsonSerialization['transactionHash'] as String?,
      errorMessage: jsonSerialization['errorMessage'] as String?,
    );
  }

  bool success;

  String? orderId;

  String? transactionHash;

  String? errorMessage;

  /// Returns a shallow copy of this [PaymentResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PaymentResult copyWith({
    bool? success,
    String? orderId,
    String? transactionHash,
    String? errorMessage,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.PaymentResult',
      'success': success,
      if (orderId != null) 'orderId': orderId,
      if (transactionHash != null) 'transactionHash': transactionHash,
      if (errorMessage != null) 'errorMessage': errorMessage,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.PaymentResult',
      'success': success,
      if (orderId != null) 'orderId': orderId,
      if (transactionHash != null) 'transactionHash': transactionHash,
      if (errorMessage != null) 'errorMessage': errorMessage,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PaymentResultImpl extends PaymentResult {
  _PaymentResultImpl({
    required bool success,
    String? orderId,
    String? transactionHash,
    String? errorMessage,
  }) : super._(
         success: success,
         orderId: orderId,
         transactionHash: transactionHash,
         errorMessage: errorMessage,
       );

  /// Returns a shallow copy of this [PaymentResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PaymentResult copyWith({
    bool? success,
    Object? orderId = _Undefined,
    Object? transactionHash = _Undefined,
    Object? errorMessage = _Undefined,
  }) {
    return PaymentResult(
      success: success ?? this.success,
      orderId: orderId is String? ? orderId : this.orderId,
      transactionHash: transactionHash is String?
          ? transactionHash
          : this.transactionHash,
      errorMessage: errorMessage is String? ? errorMessage : this.errorMessage,
    );
  }
}
