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

abstract class IapValidationResponse implements _i1.SerializableModel {
  IapValidationResponse._({
    required this.success,
    this.productId,
    this.tag,
    this.amount,
    required this.fromCache,
    this.error,
  });

  factory IapValidationResponse({
    required bool success,
    String? productId,
    String? tag,
    double? amount,
    required bool fromCache,
    String? error,
  }) = _IapValidationResponseImpl;

  factory IapValidationResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return IapValidationResponse(
      success: _i1.BoolJsonExtension.fromJson(jsonSerialization['success']),
      productId: jsonSerialization['productId'] as String?,
      tag: jsonSerialization['tag'] as String?,
      amount: (jsonSerialization['amount'] as num?)?.toDouble(),
      fromCache: _i1.BoolJsonExtension.fromJson(jsonSerialization['fromCache']),
      error: jsonSerialization['error'] as String?,
    );
  }

  bool success;

  String? productId;

  String? tag;

  double? amount;

  bool fromCache;

  String? error;

  /// Returns a shallow copy of this [IapValidationResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  IapValidationResponse copyWith({
    bool? success,
    String? productId,
    String? tag,
    double? amount,
    bool? fromCache,
    String? error,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.IapValidationResponse',
      'success': success,
      if (productId != null) 'productId': productId,
      if (tag != null) 'tag': tag,
      if (amount != null) 'amount': amount,
      'fromCache': fromCache,
      if (error != null) 'error': error,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IapValidationResponseImpl extends IapValidationResponse {
  _IapValidationResponseImpl({
    required bool success,
    String? productId,
    String? tag,
    double? amount,
    required bool fromCache,
    String? error,
  }) : super._(
         success: success,
         productId: productId,
         tag: tag,
         amount: amount,
         fromCache: fromCache,
         error: error,
       );

  /// Returns a shallow copy of this [IapValidationResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  IapValidationResponse copyWith({
    bool? success,
    Object? productId = _Undefined,
    Object? tag = _Undefined,
    Object? amount = _Undefined,
    bool? fromCache,
    Object? error = _Undefined,
  }) {
    return IapValidationResponse(
      success: success ?? this.success,
      productId: productId is String? ? productId : this.productId,
      tag: tag is String? ? tag : this.tag,
      amount: amount is double? ? amount : this.amount,
      fromCache: fromCache ?? this.fromCache,
      error: error is String? ? error : this.error,
    );
  }
}
