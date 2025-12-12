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
import 'anonaccred_exception.dart' as _i2;
import 'authentication_exception.dart' as _i3;
import 'inventory_exception.dart' as _i4;
import 'module_class.dart' as _i5;
import 'payment_exception.dart' as _i6;
export 'anonaccred_exception.dart';
export 'authentication_exception.dart';
export 'inventory_exception.dart';
export 'module_class.dart';
export 'payment_exception.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    if (className == null) return null;
    if (!className.startsWith('anonaccred.')) return className;
    return className.substring(11);
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

    if (t == _i2.AnonAccredException) {
      return _i2.AnonAccredException.fromJson(data) as T;
    }
    if (t == _i3.AuthenticationException) {
      return _i3.AuthenticationException.fromJson(data) as T;
    }
    if (t == _i4.InventoryException) {
      return _i4.InventoryException.fromJson(data) as T;
    }
    if (t == _i5.ModuleClass) {
      return _i5.ModuleClass.fromJson(data) as T;
    }
    if (t == _i6.PaymentException) {
      return _i6.PaymentException.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AnonAccredException?>()) {
      return (data != null ? _i2.AnonAccredException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i3.AuthenticationException?>()) {
      return (data != null ? _i3.AuthenticationException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i4.InventoryException?>()) {
      return (data != null ? _i4.InventoryException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.ModuleClass?>()) {
      return (data != null ? _i5.ModuleClass.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.PaymentException?>()) {
      return (data != null ? _i6.PaymentException.fromJson(data) : null) as T;
    }
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AnonAccredException => 'AnonAccredException',
      _i3.AuthenticationException => 'AuthenticationException',
      _i4.InventoryException => 'InventoryException',
      _i5.ModuleClass => 'ModuleClass',
      _i6.PaymentException => 'PaymentException',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('anonaccred.', '');
    }

    switch (data) {
      case _i2.AnonAccredException():
        return 'AnonAccredException';
      case _i3.AuthenticationException():
        return 'AuthenticationException';
      case _i4.InventoryException():
        return 'InventoryException';
      case _i5.ModuleClass():
        return 'ModuleClass';
      case _i6.PaymentException():
        return 'PaymentException';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AnonAccredException') {
      return deserialize<_i2.AnonAccredException>(data['data']);
    }
    if (dataClassName == 'AuthenticationException') {
      return deserialize<_i3.AuthenticationException>(data['data']);
    }
    if (dataClassName == 'InventoryException') {
      return deserialize<_i4.InventoryException>(data['data']);
    }
    if (dataClassName == 'ModuleClass') {
      return deserialize<_i5.ModuleClass>(data['data']);
    }
    if (dataClassName == 'PaymentException') {
      return deserialize<_i6.PaymentException>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
