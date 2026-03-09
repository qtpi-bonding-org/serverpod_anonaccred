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
import 'account.dart' as _i2;
import 'account_device.dart' as _i3;
import 'anonaccount_exception.dart' as _i4;
import 'authentication_exception.dart' as _i5;
import 'authentication_result.dart' as _i6;
import 'device_pairing_event.dart' as _i7;
import 'device_pairing_info.dart' as _i8;
import 'package:anonaccount_client/src/protocol/account_device.dart' as _i9;
export 'account.dart';
export 'account_device.dart';
export 'anonaccount_exception.dart';
export 'authentication_exception.dart';
export 'authentication_result.dart';
export 'device_pairing_event.dart';
export 'device_pairing_info.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    if (className == null) return null;
    if (!className.startsWith('anonaccount.')) return className;
    return className.substring(12);
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.AnonAccount) {
      return _i2.AnonAccount.fromJson(data) as T;
    }
    if (t == _i3.AccountDevice) {
      return _i3.AccountDevice.fromJson(data) as T;
    }
    if (t == _i4.AnonAccountException) {
      return _i4.AnonAccountException.fromJson(data) as T;
    }
    if (t == _i5.AuthenticationException) {
      return _i5.AuthenticationException.fromJson(data) as T;
    }
    if (t == _i6.AuthenticationResult) {
      return _i6.AuthenticationResult.fromJson(data) as T;
    }
    if (t == _i7.DevicePairingEvent) {
      return _i7.DevicePairingEvent.fromJson(data) as T;
    }
    if (t == _i8.DevicePairingInfo) {
      return _i8.DevicePairingInfo.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AnonAccount?>()) {
      return (data != null ? _i2.AnonAccount.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.AccountDevice?>()) {
      return (data != null ? _i3.AccountDevice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.AnonAccountException?>()) {
      return (data != null ? _i4.AnonAccountException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i5.AuthenticationException?>()) {
      return (data != null ? _i5.AuthenticationException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i6.AuthenticationResult?>()) {
      return (data != null ? _i6.AuthenticationResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i7.DevicePairingEvent?>()) {
      return (data != null ? _i7.DevicePairingEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.DevicePairingInfo?>()) {
      return (data != null ? _i8.DevicePairingInfo.fromJson(data) : null) as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == _i1.getType<Map<String, String>?>()) {
      return (data != null
              ? (data as Map).map(
                  (k, v) =>
                      MapEntry(deserialize<String>(k), deserialize<String>(v)),
                )
              : null)
          as T;
    }
    if (t == List<_i9.AccountDevice>) {
      return (data as List)
              .map((e) => deserialize<_i9.AccountDevice>(e))
              .toList()
          as T;
    }
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AnonAccount => 'AnonAccount',
      _i3.AccountDevice => 'AccountDevice',
      _i4.AnonAccountException => 'AnonAccountException',
      _i5.AuthenticationException => 'AuthenticationException',
      _i6.AuthenticationResult => 'AuthenticationResult',
      _i7.DevicePairingEvent => 'DevicePairingEvent',
      _i8.DevicePairingInfo => 'DevicePairingInfo',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('anonaccount.', '');
    }

    switch (data) {
      case _i2.AnonAccount():
        return 'AnonAccount';
      case _i3.AccountDevice():
        return 'AccountDevice';
      case _i4.AnonAccountException():
        return 'AnonAccountException';
      case _i5.AuthenticationException():
        return 'AuthenticationException';
      case _i6.AuthenticationResult():
        return 'AuthenticationResult';
      case _i7.DevicePairingEvent():
        return 'DevicePairingEvent';
      case _i8.DevicePairingInfo():
        return 'DevicePairingInfo';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AnonAccount') {
      return deserialize<_i2.AnonAccount>(data['data']);
    }
    if (dataClassName == 'AccountDevice') {
      return deserialize<_i3.AccountDevice>(data['data']);
    }
    if (dataClassName == 'AnonAccountException') {
      return deserialize<_i4.AnonAccountException>(data['data']);
    }
    if (dataClassName == 'AuthenticationException') {
      return deserialize<_i5.AuthenticationException>(data['data']);
    }
    if (dataClassName == 'AuthenticationResult') {
      return deserialize<_i6.AuthenticationResult>(data['data']);
    }
    if (dataClassName == 'DevicePairingEvent') {
      return deserialize<_i7.DevicePairingEvent>(data['data']);
    }
    if (dataClassName == 'DevicePairingInfo') {
      return deserialize<_i8.DevicePairingInfo>(data['data']);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
