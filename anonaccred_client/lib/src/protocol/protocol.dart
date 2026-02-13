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
import 'apple_consumable_delivery.dart' as _i5;
import 'authentication_exception.dart' as _i6;
import 'authentication_result.dart' as _i7;
import 'consumable_delivery.dart' as _i8;
import 'consume_result.dart' as _i9;
import 'device_pairing_event.dart' as _i10;
import 'device_pairing_info.dart' as _i11;
import 'enums.dart' as _i12;
import 'inventory.dart' as _i13;
import 'inventory_exception.dart' as _i14;
import 'module_class.dart' as _i15;
import 'order_status.dart' as _i16;
import 'payment_exception.dart' as _i17;
import 'payment_rail.dart' as _i18;
import 'payment_request.dart' as _i19;
import 'payment_result.dart' as _i20;
import 'transaction.dart' as _i21;
import 'transaction_consumable.dart' as _i22;
import 'package:anonaccred_client/src/protocol/inventory.dart' as _i23;
import 'package:anonaccred_client/src/protocol/account_device.dart' as _i24;
export 'account.dart';
export 'account_device.dart';
export 'anonaccred_exception.dart';
export 'apple_consumable_delivery.dart';
export 'authentication_exception.dart';
export 'authentication_result.dart';
export 'consumable_delivery.dart';
export 'consume_result.dart';
export 'device_pairing_event.dart';
export 'device_pairing_info.dart';
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
    if (t == _i5.AppleConsumableDelivery) {
      return _i5.AppleConsumableDelivery.fromJson(data) as T;
    }
    if (t == _i6.AuthenticationException) {
      return _i6.AuthenticationException.fromJson(data) as T;
    }
    if (t == _i7.AuthenticationResult) {
      return _i7.AuthenticationResult.fromJson(data) as T;
    }
    if (t == _i8.ConsumableDelivery) {
      return _i8.ConsumableDelivery.fromJson(data) as T;
    }
    if (t == _i9.ConsumeResult) {
      return _i9.ConsumeResult.fromJson(data) as T;
    }
    if (t == _i10.DevicePairingEvent) {
      return _i10.DevicePairingEvent.fromJson(data) as T;
    }
    if (t == _i11.DevicePairingInfo) {
      return _i11.DevicePairingInfo.fromJson(data) as T;
    }
    if (t == _i12.Currency) {
      return _i12.Currency.fromJson(data) as T;
    }
    if (t == _i13.AccountInventory) {
      return _i13.AccountInventory.fromJson(data) as T;
    }
    if (t == _i14.InventoryException) {
      return _i14.InventoryException.fromJson(data) as T;
    }
    if (t == _i15.ModuleClass) {
      return _i15.ModuleClass.fromJson(data) as T;
    }
    if (t == _i16.OrderStatus) {
      return _i16.OrderStatus.fromJson(data) as T;
    }
    if (t == _i17.PaymentException) {
      return _i17.PaymentException.fromJson(data) as T;
    }
    if (t == _i18.PaymentRail) {
      return _i18.PaymentRail.fromJson(data) as T;
    }
    if (t == _i19.PaymentRequest) {
      return _i19.PaymentRequest.fromJson(data) as T;
    }
    if (t == _i20.PaymentResult) {
      return _i20.PaymentResult.fromJson(data) as T;
    }
    if (t == _i21.TransactionPayment) {
      return _i21.TransactionPayment.fromJson(data) as T;
    }
    if (t == _i22.TransactionConsumable) {
      return _i22.TransactionConsumable.fromJson(data) as T;
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
    if (t == _i1.getType<_i5.AppleConsumableDelivery?>()) {
      return (data != null ? _i5.AppleConsumableDelivery.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i6.AuthenticationException?>()) {
      return (data != null ? _i6.AuthenticationException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i7.AuthenticationResult?>()) {
      return (data != null ? _i7.AuthenticationResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i8.ConsumableDelivery?>()) {
      return (data != null ? _i8.ConsumableDelivery.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.ConsumeResult?>()) {
      return (data != null ? _i9.ConsumeResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.DevicePairingEvent?>()) {
      return (data != null ? _i10.DevicePairingEvent.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i11.DevicePairingInfo?>()) {
      return (data != null ? _i11.DevicePairingInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.Currency?>()) {
      return (data != null ? _i12.Currency.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.AccountInventory?>()) {
      return (data != null ? _i13.AccountInventory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.InventoryException?>()) {
      return (data != null ? _i14.InventoryException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i15.ModuleClass?>()) {
      return (data != null ? _i15.ModuleClass.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.OrderStatus?>()) {
      return (data != null ? _i16.OrderStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.PaymentException?>()) {
      return (data != null ? _i17.PaymentException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.PaymentRail?>()) {
      return (data != null ? _i18.PaymentRail.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.PaymentRequest?>()) {
      return (data != null ? _i19.PaymentRequest.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.PaymentResult?>()) {
      return (data != null ? _i20.PaymentResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.TransactionPayment?>()) {
      return (data != null ? _i21.TransactionPayment.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i22.TransactionConsumable?>()) {
      return (data != null ? _i22.TransactionConsumable.fromJson(data) : null)
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
    if (t == List<_i23.AccountInventory>) {
      return (data as List)
              .map((e) => deserialize<_i23.AccountInventory>(e))
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
    if (t == List<_i24.AccountDevice>) {
      return (data as List)
              .map((e) => deserialize<_i24.AccountDevice>(e))
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
      _i5.AppleConsumableDelivery => 'AppleConsumableDelivery',
      _i6.AuthenticationException => 'AuthenticationException',
      _i7.AuthenticationResult => 'AuthenticationResult',
      _i8.ConsumableDelivery => 'ConsumableDelivery',
      _i9.ConsumeResult => 'ConsumeResult',
      _i10.DevicePairingEvent => 'DevicePairingEvent',
      _i11.DevicePairingInfo => 'DevicePairingInfo',
      _i12.Currency => 'Currency',
      _i13.AccountInventory => 'AccountInventory',
      _i14.InventoryException => 'InventoryException',
      _i15.ModuleClass => 'ModuleClass',
      _i16.OrderStatus => 'OrderStatus',
      _i17.PaymentException => 'PaymentException',
      _i18.PaymentRail => 'PaymentRail',
      _i19.PaymentRequest => 'PaymentRequest',
      _i20.PaymentResult => 'PaymentResult',
      _i21.TransactionPayment => 'TransactionPayment',
      _i22.TransactionConsumable => 'TransactionConsumable',
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
      case _i5.AppleConsumableDelivery():
        return 'AppleConsumableDelivery';
      case _i6.AuthenticationException():
        return 'AuthenticationException';
      case _i7.AuthenticationResult():
        return 'AuthenticationResult';
      case _i8.ConsumableDelivery():
        return 'ConsumableDelivery';
      case _i9.ConsumeResult():
        return 'ConsumeResult';
      case _i10.DevicePairingEvent():
        return 'DevicePairingEvent';
      case _i11.DevicePairingInfo():
        return 'DevicePairingInfo';
      case _i12.Currency():
        return 'Currency';
      case _i13.AccountInventory():
        return 'AccountInventory';
      case _i14.InventoryException():
        return 'InventoryException';
      case _i15.ModuleClass():
        return 'ModuleClass';
      case _i16.OrderStatus():
        return 'OrderStatus';
      case _i17.PaymentException():
        return 'PaymentException';
      case _i18.PaymentRail():
        return 'PaymentRail';
      case _i19.PaymentRequest():
        return 'PaymentRequest';
      case _i20.PaymentResult():
        return 'PaymentResult';
      case _i21.TransactionPayment():
        return 'TransactionPayment';
      case _i22.TransactionConsumable():
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
    if (dataClassName == 'AppleConsumableDelivery') {
      return deserialize<_i5.AppleConsumableDelivery>(data['data']);
    }
    if (dataClassName == 'AuthenticationException') {
      return deserialize<_i6.AuthenticationException>(data['data']);
    }
    if (dataClassName == 'AuthenticationResult') {
      return deserialize<_i7.AuthenticationResult>(data['data']);
    }
    if (dataClassName == 'ConsumableDelivery') {
      return deserialize<_i8.ConsumableDelivery>(data['data']);
    }
    if (dataClassName == 'ConsumeResult') {
      return deserialize<_i9.ConsumeResult>(data['data']);
    }
    if (dataClassName == 'DevicePairingEvent') {
      return deserialize<_i10.DevicePairingEvent>(data['data']);
    }
    if (dataClassName == 'DevicePairingInfo') {
      return deserialize<_i11.DevicePairingInfo>(data['data']);
    }
    if (dataClassName == 'Currency') {
      return deserialize<_i12.Currency>(data['data']);
    }
    if (dataClassName == 'AccountInventory') {
      return deserialize<_i13.AccountInventory>(data['data']);
    }
    if (dataClassName == 'InventoryException') {
      return deserialize<_i14.InventoryException>(data['data']);
    }
    if (dataClassName == 'ModuleClass') {
      return deserialize<_i15.ModuleClass>(data['data']);
    }
    if (dataClassName == 'OrderStatus') {
      return deserialize<_i16.OrderStatus>(data['data']);
    }
    if (dataClassName == 'PaymentException') {
      return deserialize<_i17.PaymentException>(data['data']);
    }
    if (dataClassName == 'PaymentRail') {
      return deserialize<_i18.PaymentRail>(data['data']);
    }
    if (dataClassName == 'PaymentRequest') {
      return deserialize<_i19.PaymentRequest>(data['data']);
    }
    if (dataClassName == 'PaymentResult') {
      return deserialize<_i20.PaymentResult>(data['data']);
    }
    if (dataClassName == 'TransactionPayment') {
      return deserialize<_i21.TransactionPayment>(data['data']);
    }
    if (dataClassName == 'TransactionConsumable') {
      return deserialize<_i22.TransactionConsumable>(data['data']);
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
