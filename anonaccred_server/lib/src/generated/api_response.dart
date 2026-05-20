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

abstract class ApiResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ApiResponse._({
    required this.success,
    this.jsonData,
    this.httpStatus,
    this.error,
  });

  factory ApiResponse({
    required bool success,
    String? jsonData,
    int? httpStatus,
    String? error,
  }) = _ApiResponseImpl;

  factory ApiResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return ApiResponse(
      success: _i1.BoolJsonExtension.fromJson(jsonSerialization['success']),
      jsonData: jsonSerialization['jsonData'] as String?,
      httpStatus: jsonSerialization['httpStatus'] as int?,
      error: jsonSerialization['error'] as String?,
    );
  }

  bool success;

  String? jsonData;

  int? httpStatus;

  String? error;

  /// Returns a shallow copy of this [ApiResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ApiResponse copyWith({
    bool? success,
    String? jsonData,
    int? httpStatus,
    String? error,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.ApiResponse',
      'success': success,
      if (jsonData != null) 'jsonData': jsonData,
      if (httpStatus != null) 'httpStatus': httpStatus,
      if (error != null) 'error': error,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.ApiResponse',
      'success': success,
      if (jsonData != null) 'jsonData': jsonData,
      if (httpStatus != null) 'httpStatus': httpStatus,
      if (error != null) 'error': error,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ApiResponseImpl extends ApiResponse {
  _ApiResponseImpl({
    required bool success,
    String? jsonData,
    int? httpStatus,
    String? error,
  }) : super._(
         success: success,
         jsonData: jsonData,
         httpStatus: httpStatus,
         error: error,
       );

  /// Returns a shallow copy of this [ApiResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ApiResponse copyWith({
    bool? success,
    Object? jsonData = _Undefined,
    Object? httpStatus = _Undefined,
    Object? error = _Undefined,
  }) {
    return ApiResponse(
      success: success ?? this.success,
      jsonData: jsonData is String? ? jsonData : this.jsonData,
      httpStatus: httpStatus is int? ? httpStatus : this.httpStatus,
      error: error is String? ? error : this.error,
    );
  }
}
