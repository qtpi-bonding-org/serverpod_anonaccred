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
import 'package:anonaccount_client/src/protocol/protocol.dart' as _i2;

abstract class AuthenticationException
    implements _i1.SerializableException, _i1.SerializableModel {
  AuthenticationException._({
    required this.code,
    required this.message,
    this.operation,
    this.details,
  });

  factory AuthenticationException({
    required String code,
    required String message,
    String? operation,
    Map<String, String>? details,
  }) = _AuthenticationExceptionImpl;

  factory AuthenticationException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AuthenticationException(
      code: jsonSerialization['code'] as String,
      message: jsonSerialization['message'] as String,
      operation: jsonSerialization['operation'] as String?,
      details: jsonSerialization['details'] == null
          ? null
          : _i2.Protocol().deserialize<Map<String, String>>(
              jsonSerialization['details'],
            ),
    );
  }

  String code;

  String message;

  String? operation;

  Map<String, String>? details;

  /// Returns a shallow copy of this [AuthenticationException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AuthenticationException copyWith({
    String? code,
    String? message,
    String? operation,
    Map<String, String>? details,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.AuthenticationException',
      'code': code,
      'message': message,
      if (operation != null) 'operation': operation,
      if (details != null) 'details': details?.toJson(),
    };
  }

  @override
  String toString() {
    return 'AuthenticationException(code: $code, message: $message, operation: $operation, details: $details)';
  }
}

class _Undefined {}

class _AuthenticationExceptionImpl extends AuthenticationException {
  _AuthenticationExceptionImpl({
    required String code,
    required String message,
    String? operation,
    Map<String, String>? details,
  }) : super._(
         code: code,
         message: message,
         operation: operation,
         details: details,
       );

  /// Returns a shallow copy of this [AuthenticationException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AuthenticationException copyWith({
    String? code,
    String? message,
    Object? operation = _Undefined,
    Object? details = _Undefined,
  }) {
    return AuthenticationException(
      code: code ?? this.code,
      message: message ?? this.message,
      operation: operation is String? ? operation : this.operation,
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
    );
  }
}
