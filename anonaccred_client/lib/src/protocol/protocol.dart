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
import 'account_entitlement.dart' as _i2;
import 'api_response.dart' as _i3;
import 'consume_result.dart' as _i4;
import 'consumption_log.dart' as _i5;
import 'currency.dart' as _i6;
import 'entitlement.dart' as _i7;
import 'entitlement_type.dart' as _i8;
import 'ephemeral_accreditation.dart' as _i9;
import 'iap_validation_response.dart' as _i10;
import 'inventory_exception.dart' as _i11;
import 'module_class.dart' as _i12;
import 'order_status.dart' as _i13;
import 'payment_exception.dart' as _i14;
import 'payment_rail.dart' as _i15;
import 'payment_request.dart' as _i16;
import 'payment_result.dart' as _i17;
import 'rail_product.dart' as _i18;
import 'rail_product_grant.dart' as _i19;
import 'receipt_hash.dart' as _i20;
import 'transaction_payment.dart' as _i21;
import 'package:anonaccred_client/src/protocol/account_entitlement.dart'
    as _i22;
import 'package:anonaccount_client/anonaccount_client.dart' as _i23;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i24;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i25;
export 'account_entitlement.dart';
export 'api_response.dart';
export 'consume_result.dart';
export 'consumption_log.dart';
export 'currency.dart';
export 'entitlement.dart';
export 'entitlement_type.dart';
export 'ephemeral_accreditation.dart';
export 'iap_validation_response.dart';
export 'inventory_exception.dart';
export 'module_class.dart';
export 'order_status.dart';
export 'payment_exception.dart';
export 'payment_rail.dart';
export 'payment_request.dart';
export 'payment_result.dart';
export 'rail_product.dart';
export 'rail_product_grant.dart';
export 'receipt_hash.dart';
export 'transaction_payment.dart';
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

    if (t == _i2.AccountEntitlement) {
      return _i2.AccountEntitlement.fromJson(data) as T;
    }
    if (t == _i3.ApiResponse) {
      return _i3.ApiResponse.fromJson(data) as T;
    }
    if (t == _i4.ConsumeResult) {
      return _i4.ConsumeResult.fromJson(data) as T;
    }
    if (t == _i5.ConsumptionLog) {
      return _i5.ConsumptionLog.fromJson(data) as T;
    }
    if (t == _i6.Currency) {
      return _i6.Currency.fromJson(data) as T;
    }
    if (t == _i7.Entitlement) {
      return _i7.Entitlement.fromJson(data) as T;
    }
    if (t == _i8.EntitlementType) {
      return _i8.EntitlementType.fromJson(data) as T;
    }
    if (t == _i9.EphemeralAccreditation) {
      return _i9.EphemeralAccreditation.fromJson(data) as T;
    }
    if (t == _i10.IapValidationResponse) {
      return _i10.IapValidationResponse.fromJson(data) as T;
    }
    if (t == _i11.InventoryException) {
      return _i11.InventoryException.fromJson(data) as T;
    }
    if (t == _i12.ModuleClass) {
      return _i12.ModuleClass.fromJson(data) as T;
    }
    if (t == _i13.OrderStatus) {
      return _i13.OrderStatus.fromJson(data) as T;
    }
    if (t == _i14.PaymentException) {
      return _i14.PaymentException.fromJson(data) as T;
    }
    if (t == _i15.PaymentRail) {
      return _i15.PaymentRail.fromJson(data) as T;
    }
    if (t == _i16.PaymentRequest) {
      return _i16.PaymentRequest.fromJson(data) as T;
    }
    if (t == _i17.PaymentResult) {
      return _i17.PaymentResult.fromJson(data) as T;
    }
    if (t == _i18.RailProduct) {
      return _i18.RailProduct.fromJson(data) as T;
    }
    if (t == _i19.RailProductGrant) {
      return _i19.RailProductGrant.fromJson(data) as T;
    }
    if (t == _i20.ReceiptHash) {
      return _i20.ReceiptHash.fromJson(data) as T;
    }
    if (t == _i21.TransactionPayment) {
      return _i21.TransactionPayment.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AccountEntitlement?>()) {
      return (data != null ? _i2.AccountEntitlement.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.ApiResponse?>()) {
      return (data != null ? _i3.ApiResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.ConsumeResult?>()) {
      return (data != null ? _i4.ConsumeResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.ConsumptionLog?>()) {
      return (data != null ? _i5.ConsumptionLog.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.Currency?>()) {
      return (data != null ? _i6.Currency.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.Entitlement?>()) {
      return (data != null ? _i7.Entitlement.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.EntitlementType?>()) {
      return (data != null ? _i8.EntitlementType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.EphemeralAccreditation?>()) {
      return (data != null ? _i9.EphemeralAccreditation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.IapValidationResponse?>()) {
      return (data != null ? _i10.IapValidationResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i11.InventoryException?>()) {
      return (data != null ? _i11.InventoryException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i12.ModuleClass?>()) {
      return (data != null ? _i12.ModuleClass.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.OrderStatus?>()) {
      return (data != null ? _i13.OrderStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.PaymentException?>()) {
      return (data != null ? _i14.PaymentException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.PaymentRail?>()) {
      return (data != null ? _i15.PaymentRail.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.PaymentRequest?>()) {
      return (data != null ? _i16.PaymentRequest.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.PaymentResult?>()) {
      return (data != null ? _i17.PaymentResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.RailProduct?>()) {
      return (data != null ? _i18.RailProduct.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.RailProductGrant?>()) {
      return (data != null ? _i19.RailProductGrant.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.ReceiptHash?>()) {
      return (data != null ? _i20.ReceiptHash.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.TransactionPayment?>()) {
      return (data != null ? _i21.TransactionPayment.fromJson(data) : null)
          as T;
    }
    if (t == List<_i22.AccountEntitlement>) {
      return (data as List)
              .map((e) => deserialize<_i22.AccountEntitlement>(e))
              .toList()
          as T;
    }
    try {
      return _i23.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i24.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i25.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AccountEntitlement => 'AccountEntitlement',
      _i3.ApiResponse => 'ApiResponse',
      _i4.ConsumeResult => 'ConsumeResult',
      _i5.ConsumptionLog => 'ConsumptionLog',
      _i6.Currency => 'Currency',
      _i7.Entitlement => 'Entitlement',
      _i8.EntitlementType => 'EntitlementType',
      _i9.EphemeralAccreditation => 'EphemeralAccreditation',
      _i10.IapValidationResponse => 'IapValidationResponse',
      _i11.InventoryException => 'InventoryException',
      _i12.ModuleClass => 'ModuleClass',
      _i13.OrderStatus => 'OrderStatus',
      _i14.PaymentException => 'PaymentException',
      _i15.PaymentRail => 'PaymentRail',
      _i16.PaymentRequest => 'PaymentRequest',
      _i17.PaymentResult => 'PaymentResult',
      _i18.RailProduct => 'RailProduct',
      _i19.RailProductGrant => 'RailProductGrant',
      _i20.ReceiptHash => 'ReceiptHash',
      _i21.TransactionPayment => 'TransactionPayment',
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
      case _i2.AccountEntitlement():
        return 'AccountEntitlement';
      case _i3.ApiResponse():
        return 'ApiResponse';
      case _i4.ConsumeResult():
        return 'ConsumeResult';
      case _i5.ConsumptionLog():
        return 'ConsumptionLog';
      case _i6.Currency():
        return 'Currency';
      case _i7.Entitlement():
        return 'Entitlement';
      case _i8.EntitlementType():
        return 'EntitlementType';
      case _i9.EphemeralAccreditation():
        return 'EphemeralAccreditation';
      case _i10.IapValidationResponse():
        return 'IapValidationResponse';
      case _i11.InventoryException():
        return 'InventoryException';
      case _i12.ModuleClass():
        return 'ModuleClass';
      case _i13.OrderStatus():
        return 'OrderStatus';
      case _i14.PaymentException():
        return 'PaymentException';
      case _i15.PaymentRail():
        return 'PaymentRail';
      case _i16.PaymentRequest():
        return 'PaymentRequest';
      case _i17.PaymentResult():
        return 'PaymentResult';
      case _i18.RailProduct():
        return 'RailProduct';
      case _i19.RailProductGrant():
        return 'RailProductGrant';
      case _i20.ReceiptHash():
        return 'ReceiptHash';
      case _i21.TransactionPayment():
        return 'TransactionPayment';
    }
    className = _i23.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'anonaccount.$className';
    }
    className = _i24.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i25.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AccountEntitlement') {
      return deserialize<_i2.AccountEntitlement>(data['data']);
    }
    if (dataClassName == 'ApiResponse') {
      return deserialize<_i3.ApiResponse>(data['data']);
    }
    if (dataClassName == 'ConsumeResult') {
      return deserialize<_i4.ConsumeResult>(data['data']);
    }
    if (dataClassName == 'ConsumptionLog') {
      return deserialize<_i5.ConsumptionLog>(data['data']);
    }
    if (dataClassName == 'Currency') {
      return deserialize<_i6.Currency>(data['data']);
    }
    if (dataClassName == 'Entitlement') {
      return deserialize<_i7.Entitlement>(data['data']);
    }
    if (dataClassName == 'EntitlementType') {
      return deserialize<_i8.EntitlementType>(data['data']);
    }
    if (dataClassName == 'EphemeralAccreditation') {
      return deserialize<_i9.EphemeralAccreditation>(data['data']);
    }
    if (dataClassName == 'IapValidationResponse') {
      return deserialize<_i10.IapValidationResponse>(data['data']);
    }
    if (dataClassName == 'InventoryException') {
      return deserialize<_i11.InventoryException>(data['data']);
    }
    if (dataClassName == 'ModuleClass') {
      return deserialize<_i12.ModuleClass>(data['data']);
    }
    if (dataClassName == 'OrderStatus') {
      return deserialize<_i13.OrderStatus>(data['data']);
    }
    if (dataClassName == 'PaymentException') {
      return deserialize<_i14.PaymentException>(data['data']);
    }
    if (dataClassName == 'PaymentRail') {
      return deserialize<_i15.PaymentRail>(data['data']);
    }
    if (dataClassName == 'PaymentRequest') {
      return deserialize<_i16.PaymentRequest>(data['data']);
    }
    if (dataClassName == 'PaymentResult') {
      return deserialize<_i17.PaymentResult>(data['data']);
    }
    if (dataClassName == 'RailProduct') {
      return deserialize<_i18.RailProduct>(data['data']);
    }
    if (dataClassName == 'RailProductGrant') {
      return deserialize<_i19.RailProductGrant>(data['data']);
    }
    if (dataClassName == 'ReceiptHash') {
      return deserialize<_i20.ReceiptHash>(data['data']);
    }
    if (dataClassName == 'TransactionPayment') {
      return deserialize<_i21.TransactionPayment>(data['data']);
    }
    if (dataClassName.startsWith('anonaccount.')) {
      data['className'] = dataClassName.substring(12);
      return _i23.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i24.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i25.Protocol().deserializeByClassName(data);
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
    try {
      return _i23.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i24.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i25.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
