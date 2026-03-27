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
import 'package:anonaccount_server/src/generated/protocol.dart' as _i2;

abstract class AuthenticationResult
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AuthenticationResult._({
    required this.success,
    this.deviceId,
    this.accountPublicKeyHex,
    this.errorCode,
    this.errorMessage,
    this.details,
  });

  factory AuthenticationResult({
    required bool success,
    _i1.UuidValue? deviceId,
    String? accountPublicKeyHex,
    String? errorCode,
    String? errorMessage,
    Map<String, String>? details,
  }) = _AuthenticationResultImpl;

  factory AuthenticationResult.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AuthenticationResult(
      success: _i1.BoolJsonExtension.fromJson(jsonSerialization['success']),
      deviceId: jsonSerialization['deviceId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['deviceId']),
      accountPublicKeyHex: jsonSerialization['accountPublicKeyHex'] as String?,
      errorCode: jsonSerialization['errorCode'] as String?,
      errorMessage: jsonSerialization['errorMessage'] as String?,
      details: jsonSerialization['details'] == null
          ? null
          : _i2.Protocol().deserialize<Map<String, String>>(
              jsonSerialization['details'],
            ),
    );
  }

  bool success;

  _i1.UuidValue? deviceId;

  String? accountPublicKeyHex;

  String? errorCode;

  String? errorMessage;

  Map<String, String>? details;

  /// Returns a shallow copy of this [AuthenticationResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AuthenticationResult copyWith({
    bool? success,
    _i1.UuidValue? deviceId,
    String? accountPublicKeyHex,
    String? errorCode,
    String? errorMessage,
    Map<String, String>? details,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.AuthenticationResult',
      'success': success,
      if (deviceId != null) 'deviceId': deviceId?.toJson(),
      if (accountPublicKeyHex != null)
        'accountPublicKeyHex': accountPublicKeyHex,
      if (errorCode != null) 'errorCode': errorCode,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (details != null) 'details': details?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.AuthenticationResult',
      'success': success,
      if (deviceId != null) 'deviceId': deviceId?.toJson(),
      if (accountPublicKeyHex != null)
        'accountPublicKeyHex': accountPublicKeyHex,
      if (errorCode != null) 'errorCode': errorCode,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (details != null) 'details': details?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AuthenticationResultImpl extends AuthenticationResult {
  _AuthenticationResultImpl({
    required bool success,
    _i1.UuidValue? deviceId,
    String? accountPublicKeyHex,
    String? errorCode,
    String? errorMessage,
    Map<String, String>? details,
  }) : super._(
         success: success,
         deviceId: deviceId,
         accountPublicKeyHex: accountPublicKeyHex,
         errorCode: errorCode,
         errorMessage: errorMessage,
         details: details,
       );

  /// Returns a shallow copy of this [AuthenticationResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AuthenticationResult copyWith({
    bool? success,
    Object? deviceId = _Undefined,
    Object? accountPublicKeyHex = _Undefined,
    Object? errorCode = _Undefined,
    Object? errorMessage = _Undefined,
    Object? details = _Undefined,
  }) {
    return AuthenticationResult(
      success: success ?? this.success,
      deviceId: deviceId is _i1.UuidValue? ? deviceId : this.deviceId,
      accountPublicKeyHex: accountPublicKeyHex is String?
          ? accountPublicKeyHex
          : this.accountPublicKeyHex,
      errorCode: errorCode is String? ? errorCode : this.errorCode,
      errorMessage: errorMessage is String? ? errorMessage : this.errorMessage,
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
