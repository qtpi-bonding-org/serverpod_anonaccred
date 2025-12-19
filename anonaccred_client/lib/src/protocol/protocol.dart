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
import 'anonaccred_exception.dart' as _i4;
import 'authentication_exception.dart' as _i5;
import 'authentication_result.dart' as _i6;
import 'consume_result.dart' as _i7;
import 'enums.dart' as _i8;
import 'inventory.dart' as _i9;
import 'inventory_exception.dart' as _i10;
import 'module_class.dart' as _i11;
import 'order_status.dart' as _i12;
import 'payment_exception.dart' as _i13;
import 'payment_rail.dart' as _i14;
import 'payment_request.dart' as _i15;
import 'payment_result.dart' as _i16;
import 'transaction.dart' as _i17;
import 'transaction_consumable.dart' as _i18;
import 'package:anonaccred_client/src/protocol/inventory.dart' as _i19;
import 'package:anonaccred_client/src/protocol/account_device.dart' as _i20;
export 'account.dart';
export 'account_device.dart';
export 'anonaccred_exception.dart';
export 'authentication_exception.dart';
export 'authentication_result.dart';
export 'consume_result.dart';
export 'enums.dart';
export 'inventory.dart';
export 'inventory_exception.dart';
export 'module_class.dart';
export 'order_status.dart';
export 'payment_exception.dart';
export 'payment_rail.dart';
export 'payment_request.dart';
export 'payment_result.dart';
export 'transaction.dart';
export 'transaction_consumable.dart';
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

    if (t == _i2.AnonAccount) {
      return _i2.AnonAccount.fromJson(data) as T;
    }
    if (t == _i3.AccountDevice) {
      return _i3.AccountDevice.fromJson(data) as T;
    }
    if (t == _i4.AnonAccredException) {
      return _i4.AnonAccredException.fromJson(data) as T;
    }
    if (t == _i5.AuthenticationException) {
      return _i5.AuthenticationException.fromJson(data) as T;
    }
    if (t == _i6.AuthenticationResult) {
      return _i6.AuthenticationResult.fromJson(data) as T;
    }
    if (t == _i7.ConsumeResult) {
      return _i7.ConsumeResult.fromJson(data) as T;
    }
    if (t == _i8.Currency) {
      return _i8.Currency.fromJson(data) as T;
    }
    if (t == _i9.AccountInventory) {
      return _i9.AccountInventory.fromJson(data) as T;
    }
    if (t == _i10.InventoryException) {
      return _i10.InventoryException.fromJson(data) as T;
    }
    if (t == _i11.ModuleClass) {
      return _i11.ModuleClass.fromJson(data) as T;
    }
    if (t == _i12.OrderStatus) {
      return _i12.OrderStatus.fromJson(data) as T;
    }
    if (t == _i13.PaymentException) {
      return _i13.PaymentException.fromJson(data) as T;
    }
    if (t == _i14.PaymentRail) {
      return _i14.PaymentRail.fromJson(data) as T;
    }
    if (t == _i15.PaymentRequest) {
      return _i15.PaymentRequest.fromJson(data) as T;
    }
    if (t == _i16.PaymentResult) {
      return _i16.PaymentResult.fromJson(data) as T;
    }
    if (t == _i17.TransactionPayment) {
      return _i17.TransactionPayment.fromJson(data) as T;
    }
    if (t == _i18.TransactionConsumable) {
      return _i18.TransactionConsumable.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AnonAccount?>()) {
      return (data != null ? _i2.AnonAccount.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.AccountDevice?>()) {
      return (data != null ? _i3.AccountDevice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.AnonAccredException?>()) {
      return (data != null ? _i4.AnonAccredException.fromJson(data) : null)
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
    if (t == _i1.getType<_i7.ConsumeResult?>()) {
      return (data != null ? _i7.ConsumeResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.Currency?>()) {
      return (data != null ? _i8.Currency.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.AccountInventory?>()) {
      return (data != null ? _i9.AccountInventory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.InventoryException?>()) {
      return (data != null ? _i10.InventoryException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i11.ModuleClass?>()) {
      return (data != null ? _i11.ModuleClass.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.OrderStatus?>()) {
      return (data != null ? _i12.OrderStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.PaymentException?>()) {
      return (data != null ? _i13.PaymentException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.PaymentRail?>()) {
      return (data != null ? _i14.PaymentRail.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.PaymentRequest?>()) {
      return (data != null ? _i15.PaymentRequest.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.PaymentResult?>()) {
      return (data != null ? _i16.PaymentResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.TransactionPayment?>()) {
      return (data != null ? _i17.TransactionPayment.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i18.TransactionConsumable?>()) {
      return (data != null ? _i18.TransactionConsumable.fromJson(data) : null)
          as T;
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
    if (t == Map<String, double>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<double>(v)),
          )
          as T;
    }
    if (t == List<_i19.AccountInventory>) {
      return (data as List)
              .map((e) => deserialize<_i19.AccountInventory>(e))
              .toList()
          as T;
    }
    if (t == Map<String, dynamic>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<dynamic>(v)),
          )
          as T;
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
    if (t == List<_i20.AccountDevice>) {
      return (data as List)
              .map((e) => deserialize<_i20.AccountDevice>(e))
              .toList()
          as T;
    }
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AnonAccount => 'AnonAccount',
      _i3.AccountDevice => 'AccountDevice',
      _i4.AnonAccredException => 'AnonAccredException',
      _i5.AuthenticationException => 'AuthenticationException',
      _i6.AuthenticationResult => 'AuthenticationResult',
      _i7.ConsumeResult => 'ConsumeResult',
      _i8.Currency => 'Currency',
      _i9.AccountInventory => 'AccountInventory',
      _i10.InventoryException => 'InventoryException',
      _i11.ModuleClass => 'ModuleClass',
      _i12.OrderStatus => 'OrderStatus',
      _i13.PaymentException => 'PaymentException',
      _i14.PaymentRail => 'PaymentRail',
      _i15.PaymentRequest => 'PaymentRequest',
      _i16.PaymentResult => 'PaymentResult',
      _i17.TransactionPayment => 'TransactionPayment',
      _i18.TransactionConsumable => 'TransactionConsumable',
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
      case _i2.AnonAccount():
        return 'AnonAccount';
      case _i3.AccountDevice():
        return 'AccountDevice';
      case _i4.AnonAccredException():
        return 'AnonAccredException';
      case _i5.AuthenticationException():
        return 'AuthenticationException';
      case _i6.AuthenticationResult():
        return 'AuthenticationResult';
      case _i7.ConsumeResult():
        return 'ConsumeResult';
      case _i8.Currency():
        return 'Currency';
      case _i9.AccountInventory():
        return 'AccountInventory';
      case _i10.InventoryException():
        return 'InventoryException';
      case _i11.ModuleClass():
        return 'ModuleClass';
      case _i12.OrderStatus():
        return 'OrderStatus';
      case _i13.PaymentException():
        return 'PaymentException';
      case _i14.PaymentRail():
        return 'PaymentRail';
      case _i15.PaymentRequest():
        return 'PaymentRequest';
      case _i16.PaymentResult():
        return 'PaymentResult';
      case _i17.TransactionPayment():
        return 'TransactionPayment';
      case _i18.TransactionConsumable():
        return 'TransactionConsumable';
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
    if (dataClassName == 'AnonAccredException') {
      return deserialize<_i4.AnonAccredException>(data['data']);
    }
    if (dataClassName == 'AuthenticationException') {
      return deserialize<_i5.AuthenticationException>(data['data']);
    }
    if (dataClassName == 'AuthenticationResult') {
      return deserialize<_i6.AuthenticationResult>(data['data']);
    }
    if (dataClassName == 'ConsumeResult') {
      return deserialize<_i7.ConsumeResult>(data['data']);
    }
    if (dataClassName == 'Currency') {
      return deserialize<_i8.Currency>(data['data']);
    }
    if (dataClassName == 'AccountInventory') {
      return deserialize<_i9.AccountInventory>(data['data']);
    }
    if (dataClassName == 'InventoryException') {
      return deserialize<_i10.InventoryException>(data['data']);
    }
    if (dataClassName == 'ModuleClass') {
      return deserialize<_i11.ModuleClass>(data['data']);
    }
    if (dataClassName == 'OrderStatus') {
      return deserialize<_i12.OrderStatus>(data['data']);
    }
    if (dataClassName == 'PaymentException') {
      return deserialize<_i13.PaymentException>(data['data']);
    }
    if (dataClassName == 'PaymentRail') {
      return deserialize<_i14.PaymentRail>(data['data']);
    }
    if (dataClassName == 'PaymentRequest') {
      return deserialize<_i15.PaymentRequest>(data['data']);
    }
    if (dataClassName == 'PaymentResult') {
      return deserialize<_i16.PaymentResult>(data['data']);
    }
    if (dataClassName == 'TransactionPayment') {
      return deserialize<_i17.TransactionPayment>(data['data']);
    }
    if (dataClassName == 'TransactionConsumable') {
      return deserialize<_i18.TransactionConsumable>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
