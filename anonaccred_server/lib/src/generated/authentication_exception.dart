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

abstract class AuthenticationException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  AuthenticationException._({
    required this.code,
    required this.message,
    this.details,
    this.operation,
  });

  factory AuthenticationException({
    required String code,
    required String message,
    Map<String, String>? details,
    String? operation,
  }) = _AuthenticationExceptionImpl;

  factory AuthenticationException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AuthenticationException(
      code: jsonSerialization['code'] as String,
      message: jsonSerialization['message'] as String,
      details: jsonSerialization['details'] == null
          ? null
          : _i2.Protocol().deserialize<Map<String, String>>(
              jsonSerialization['details'],
            ),
      operation: jsonSerialization['operation'] as String?,
    );
  }

  String code;

  String message;

  Map<String, String>? details;

  String? operation;

  /// Returns a shallow copy of this [AuthenticationException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AuthenticationException copyWith({
    String? code,
    String? message,
    Map<String, String>? details,
    String? operation,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.AuthenticationException',
      'code': code,
      'message': message,
      if (details != null) 'details': details?.toJson(),
      if (operation != null) 'operation': operation,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.AuthenticationException',
      'code': code,
      'message': message,
      if (details != null) 'details': details?.toJson(),
      if (operation != null) 'operation': operation,
    };
  }

  @override
  String toString() {
    return 'AuthenticationException(code: $code, message: $message, details: $details, operation: $operation)';
  }
}

class _Undefined {}

class _AuthenticationExceptionImpl extends AuthenticationException {
  _AuthenticationExceptionImpl({
    required String code,
    required String message,
    Map<String, String>? details,
    String? operation,
  }) : super._(
         code: code,
         message: message,
         details: details,
         operation: operation,
       );

  /// Returns a shallow copy of this [AuthenticationException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AuthenticationException copyWith({
    String? code,
    String? message,
    Object? details = _Undefined,
    Object? operation = _Undefined,
  }) {
    return AuthenticationException(
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
      operation: operation is String? ? operation : this.operation,
    );
  }
}
