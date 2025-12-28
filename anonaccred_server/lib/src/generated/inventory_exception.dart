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

abstract class InventoryException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  InventoryException._({
    required this.code,
    required this.message,
    this.details,
    this.accountId,
    this.consumableType,
  });

  factory InventoryException({
    required String code,
    required String message,
    Map<String, String>? details,
    int? accountId,
    String? consumableType,
  }) = _InventoryExceptionImpl;

  factory InventoryException.fromJson(Map<String, dynamic> jsonSerialization) {
    return InventoryException(
      code: jsonSerialization['code'] as String,
      message: jsonSerialization['message'] as String,
      details: jsonSerialization['details'] == null
          ? null
          : _i2.Protocol().deserialize<Map<String, String>>(
              jsonSerialization['details'],
            ),
      accountId: jsonSerialization['accountId'] as int?,
      consumableType: jsonSerialization['consumableType'] as String?,
    );
  }

  String code;

  String message;

  Map<String, String>? details;

  int? accountId;

  String? consumableType;

  /// Returns a shallow copy of this [InventoryException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  InventoryException copyWith({
    String? code,
    String? message,
    Map<String, String>? details,
    int? accountId,
    String? consumableType,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.InventoryException',
      'code': code,
      'message': message,
      if (details != null) 'details': details?.toJson(),
      if (accountId != null) 'accountId': accountId,
      if (consumableType != null) 'consumableType': consumableType,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.InventoryException',
      'code': code,
      'message': message,
      if (details != null) 'details': details?.toJson(),
      if (accountId != null) 'accountId': accountId,
      if (consumableType != null) 'consumableType': consumableType,
    };
  }

  @override
  String toString() {
    return 'InventoryException(code: $code, message: $message, details: $details, accountId: $accountId, consumableType: $consumableType)';
  }
}

class _Undefined {}

class _InventoryExceptionImpl extends InventoryException {
  _InventoryExceptionImpl({
    required String code,
    required String message,
    Map<String, String>? details,
    int? accountId,
    String? consumableType,
  }) : super._(
         code: code,
         message: message,
         details: details,
         accountId: accountId,
         consumableType: consumableType,
       );

  /// Returns a shallow copy of this [InventoryException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  InventoryException copyWith({
    String? code,
    String? message,
    Object? details = _Undefined,
    Object? accountId = _Undefined,
    Object? consumableType = _Undefined,
  }) {
    return InventoryException(
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
      accountId: accountId is int? ? accountId : this.accountId,
      consumableType: consumableType is String?
          ? consumableType
          : this.consumableType,
    );
  }
}
