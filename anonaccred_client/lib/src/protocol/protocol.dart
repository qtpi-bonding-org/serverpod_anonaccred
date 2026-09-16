/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:anonaccount_client/anonaccount_client.dart' as _i3nzkmxo;
import 'package:anonaccred_client/src/protocol/account_entitlement.dart'
    as _iwyotwlc;
import 'package:anonaccred_client/src/protocol/group_entitlement.dart'
    as _iskjyox1;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'account_entitlement.dart' as _iy7wdaeu;
import 'api_response.dart' as _ivocdqwh;
import 'consume_result.dart' as _imwsjh26;
import 'consumption_log.dart' as _iupk08di;
import 'currency.dart' as _iez2mem4;
import 'entitlement.dart' as _ico1e66l;
import 'entitlement_type.dart' as _i02qbmjp;
import 'ephemeral_accreditation.dart' as _if0a11t5;
import 'ephemeral_accreditation_group.dart' as _inxw1hvq;
import 'group_consumption_log.dart' as _im17zz1w;
import 'group_entitlement.dart' as _icykdmu9;
import 'iap_validation_response.dart' as _iomp5ggy;
import 'inventory_exception.dart' as _ic3ogqfy;
import 'module_class.dart' as _izah8b1s;
import 'order_status.dart' as _idpqotwg;
import 'payment_exception.dart' as _i8wa6pax;
import 'payment_rail.dart' as _i4hkjqgd;
import 'payment_request.dart' as _ikpjr0wv;
import 'payment_result.dart' as _iu7zczvw;
import 'rail_product.dart' as _ii096092;
import 'rail_product_grant.dart' as _ip94uwhy;
import 'receipt_hash.dart' as _i7pzcogb;
import 'refund_claim.dart' as _i4ysmc15;
import 'transaction_payment.dart' as _i849cfmo;
export 'account_entitlement.dart';
export 'api_response.dart';
export 'consume_result.dart';
export 'consumption_log.dart';
export 'currency.dart';
export 'entitlement.dart';
export 'entitlement_type.dart';
export 'ephemeral_accreditation.dart';
export 'ephemeral_accreditation_group.dart';
export 'group_consumption_log.dart';
export 'group_entitlement.dart';
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
export 'refund_claim.dart';
export 'transaction_payment.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  final Set<_isc.SerializationManager> _hostProtocols = {};

  void registerHostProtocol(
    String projectName,
    _isc.SerializationManager protocol,
  ) {
    _hostProtocols.add(protocol);
  }

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    if (className == null) return null;
    if (!className.startsWith('anonaccred.')) return className;
    return className.substring(11);
  }

  @override
  T deserialize<T>(dynamic data, [Type? t]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _iy7wdaeu.AccountEntitlement) {
      return _iy7wdaeu.AccountEntitlement.fromJson(data) as T;
    }
    if (t == _ivocdqwh.ApiResponse) {
      return _ivocdqwh.ApiResponse.fromJson(data) as T;
    }
    if (t == _imwsjh26.ConsumeResult) {
      return _imwsjh26.ConsumeResult.fromJson(data) as T;
    }
    if (t == _iupk08di.ConsumptionLog) {
      return _iupk08di.ConsumptionLog.fromJson(data) as T;
    }
    if (t == _iez2mem4.Currency) {
      return _iez2mem4.Currency.fromJson(data) as T;
    }
    if (t == _ico1e66l.Entitlement) {
      return _ico1e66l.Entitlement.fromJson(data) as T;
    }
    if (t == _i02qbmjp.EntitlementType) {
      return _i02qbmjp.EntitlementType.fromJson(data) as T;
    }
    if (t == _if0a11t5.EphemeralAccreditation) {
      return _if0a11t5.EphemeralAccreditation.fromJson(data) as T;
    }
    if (t == _inxw1hvq.EphemeralAccreditationGroup) {
      return _inxw1hvq.EphemeralAccreditationGroup.fromJson(data) as T;
    }
    if (t == _im17zz1w.GroupConsumptionLog) {
      return _im17zz1w.GroupConsumptionLog.fromJson(data) as T;
    }
    if (t == _icykdmu9.GroupEntitlement) {
      return _icykdmu9.GroupEntitlement.fromJson(data) as T;
    }
    if (t == _iomp5ggy.IapValidationResponse) {
      return _iomp5ggy.IapValidationResponse.fromJson(data) as T;
    }
    if (t == _ic3ogqfy.InventoryException) {
      return _ic3ogqfy.InventoryException.fromJson(data) as T;
    }
    if (t == _izah8b1s.ModuleClass) {
      return _izah8b1s.ModuleClass.fromJson(data) as T;
    }
    if (t == _idpqotwg.OrderStatus) {
      return _idpqotwg.OrderStatus.fromJson(data) as T;
    }
    if (t == _i8wa6pax.PaymentException) {
      return _i8wa6pax.PaymentException.fromJson(data) as T;
    }
    if (t == _i4hkjqgd.PaymentRail) {
      return _i4hkjqgd.PaymentRail.fromJson(data) as T;
    }
    if (t == _ikpjr0wv.PaymentRequest) {
      return _ikpjr0wv.PaymentRequest.fromJson(data) as T;
    }
    if (t == _iu7zczvw.PaymentResult) {
      return _iu7zczvw.PaymentResult.fromJson(data) as T;
    }
    if (t == _ii096092.RailProduct) {
      return _ii096092.RailProduct.fromJson(data) as T;
    }
    if (t == _ip94uwhy.RailProductGrant) {
      return _ip94uwhy.RailProductGrant.fromJson(data) as T;
    }
    if (t == _i7pzcogb.ReceiptHash) {
      return _i7pzcogb.ReceiptHash.fromJson(data) as T;
    }
    if (t == _i4ysmc15.RefundClaim) {
      return _i4ysmc15.RefundClaim.fromJson(data) as T;
    }
    if (t == _i849cfmo.TransactionPayment) {
      return _i849cfmo.TransactionPayment.fromJson(data) as T;
    }
    if (t == _isc.getType<_iy7wdaeu.AccountEntitlement?>()) {
      return (data != null ? _iy7wdaeu.AccountEntitlement.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ivocdqwh.ApiResponse?>()) {
      return (data != null ? _ivocdqwh.ApiResponse.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_imwsjh26.ConsumeResult?>()) {
      return (data != null ? _imwsjh26.ConsumeResult.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iupk08di.ConsumptionLog?>()) {
      return (data != null ? _iupk08di.ConsumptionLog.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iez2mem4.Currency?>()) {
      return (data != null ? _iez2mem4.Currency.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ico1e66l.Entitlement?>()) {
      return (data != null ? _ico1e66l.Entitlement.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i02qbmjp.EntitlementType?>()) {
      return (data != null ? _i02qbmjp.EntitlementType.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_if0a11t5.EphemeralAccreditation?>()) {
      return (data != null
              ? _if0a11t5.EphemeralAccreditation.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_inxw1hvq.EphemeralAccreditationGroup?>()) {
      return (data != null
              ? _inxw1hvq.EphemeralAccreditationGroup.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_im17zz1w.GroupConsumptionLog?>()) {
      return (data != null
              ? _im17zz1w.GroupConsumptionLog.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_icykdmu9.GroupEntitlement?>()) {
      return (data != null ? _icykdmu9.GroupEntitlement.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iomp5ggy.IapValidationResponse?>()) {
      return (data != null
              ? _iomp5ggy.IapValidationResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ic3ogqfy.InventoryException?>()) {
      return (data != null ? _ic3ogqfy.InventoryException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_izah8b1s.ModuleClass?>()) {
      return (data != null ? _izah8b1s.ModuleClass.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_idpqotwg.OrderStatus?>()) {
      return (data != null ? _idpqotwg.OrderStatus.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i8wa6pax.PaymentException?>()) {
      return (data != null ? _i8wa6pax.PaymentException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i4hkjqgd.PaymentRail?>()) {
      return (data != null ? _i4hkjqgd.PaymentRail.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ikpjr0wv.PaymentRequest?>()) {
      return (data != null ? _ikpjr0wv.PaymentRequest.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iu7zczvw.PaymentResult?>()) {
      return (data != null ? _iu7zczvw.PaymentResult.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ii096092.RailProduct?>()) {
      return (data != null ? _ii096092.RailProduct.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ip94uwhy.RailProductGrant?>()) {
      return (data != null ? _ip94uwhy.RailProductGrant.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i7pzcogb.ReceiptHash?>()) {
      return (data != null ? _i7pzcogb.ReceiptHash.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i4ysmc15.RefundClaim?>()) {
      return (data != null ? _i4ysmc15.RefundClaim.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i849cfmo.TransactionPayment?>()) {
      return (data != null ? _i849cfmo.TransactionPayment.fromJson(data) : null)
          as T;
    }
    if (t == List<_iwyotwlc.AccountEntitlement>) {
      return (data as List)
              .map((e) => deserialize<_iwyotwlc.AccountEntitlement>(e))
              .toList()
          as T;
    }
    if (t == List<_iskjyox1.GroupEntitlement>) {
      return (data as List)
              .map((e) => deserialize<_iskjyox1.GroupEntitlement>(e))
              .toList()
          as T;
    }
    try {
      return _i3nzkmxo.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iy7wdaeu.AccountEntitlement => 'AccountEntitlement',
      _ivocdqwh.ApiResponse => 'ApiResponse',
      _imwsjh26.ConsumeResult => 'ConsumeResult',
      _iupk08di.ConsumptionLog => 'ConsumptionLog',
      _iez2mem4.Currency => 'Currency',
      _ico1e66l.Entitlement => 'Entitlement',
      _i02qbmjp.EntitlementType => 'EntitlementType',
      _if0a11t5.EphemeralAccreditation => 'EphemeralAccreditation',
      _inxw1hvq.EphemeralAccreditationGroup => 'EphemeralAccreditationGroup',
      _im17zz1w.GroupConsumptionLog => 'GroupConsumptionLog',
      _icykdmu9.GroupEntitlement => 'GroupEntitlement',
      _iomp5ggy.IapValidationResponse => 'IapValidationResponse',
      _ic3ogqfy.InventoryException => 'InventoryException',
      _izah8b1s.ModuleClass => 'ModuleClass',
      _idpqotwg.OrderStatus => 'OrderStatus',
      _i8wa6pax.PaymentException => 'PaymentException',
      _i4hkjqgd.PaymentRail => 'PaymentRail',
      _ikpjr0wv.PaymentRequest => 'PaymentRequest',
      _iu7zczvw.PaymentResult => 'PaymentResult',
      _ii096092.RailProduct => 'RailProduct',
      _ip94uwhy.RailProductGrant => 'RailProductGrant',
      _i7pzcogb.ReceiptHash => 'ReceiptHash',
      _i4ysmc15.RefundClaim => 'RefundClaim',
      _i849cfmo.TransactionPayment => 'TransactionPayment',
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
      case _iy7wdaeu.AccountEntitlement():
        return 'AccountEntitlement';
      case _ivocdqwh.ApiResponse():
        return 'ApiResponse';
      case _imwsjh26.ConsumeResult():
        return 'ConsumeResult';
      case _iupk08di.ConsumptionLog():
        return 'ConsumptionLog';
      case _iez2mem4.Currency():
        return 'Currency';
      case _ico1e66l.Entitlement():
        return 'Entitlement';
      case _i02qbmjp.EntitlementType():
        return 'EntitlementType';
      case _if0a11t5.EphemeralAccreditation():
        return 'EphemeralAccreditation';
      case _inxw1hvq.EphemeralAccreditationGroup():
        return 'EphemeralAccreditationGroup';
      case _im17zz1w.GroupConsumptionLog():
        return 'GroupConsumptionLog';
      case _icykdmu9.GroupEntitlement():
        return 'GroupEntitlement';
      case _iomp5ggy.IapValidationResponse():
        return 'IapValidationResponse';
      case _ic3ogqfy.InventoryException():
        return 'InventoryException';
      case _izah8b1s.ModuleClass():
        return 'ModuleClass';
      case _idpqotwg.OrderStatus():
        return 'OrderStatus';
      case _i8wa6pax.PaymentException():
        return 'PaymentException';
      case _i4hkjqgd.PaymentRail():
        return 'PaymentRail';
      case _ikpjr0wv.PaymentRequest():
        return 'PaymentRequest';
      case _iu7zczvw.PaymentResult():
        return 'PaymentResult';
      case _ii096092.RailProduct():
        return 'RailProduct';
      case _ip94uwhy.RailProductGrant():
        return 'RailProductGrant';
      case _i7pzcogb.ReceiptHash():
        return 'ReceiptHash';
      case _i4ysmc15.RefundClaim():
        return 'RefundClaim';
      case _i849cfmo.TransactionPayment():
        return 'TransactionPayment';
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
      return deserialize<_iy7wdaeu.AccountEntitlement>(data['data']);
    }
    if (dataClassName == 'ApiResponse') {
      return deserialize<_ivocdqwh.ApiResponse>(data['data']);
    }
    if (dataClassName == 'ConsumeResult') {
      return deserialize<_imwsjh26.ConsumeResult>(data['data']);
    }
    if (dataClassName == 'ConsumptionLog') {
      return deserialize<_iupk08di.ConsumptionLog>(data['data']);
    }
    if (dataClassName == 'Currency') {
      return deserialize<_iez2mem4.Currency>(data['data']);
    }
    if (dataClassName == 'Entitlement') {
      return deserialize<_ico1e66l.Entitlement>(data['data']);
    }
    if (dataClassName == 'EntitlementType') {
      return deserialize<_i02qbmjp.EntitlementType>(data['data']);
    }
    if (dataClassName == 'EphemeralAccreditation') {
      return deserialize<_if0a11t5.EphemeralAccreditation>(data['data']);
    }
    if (dataClassName == 'EphemeralAccreditationGroup') {
      return deserialize<_inxw1hvq.EphemeralAccreditationGroup>(data['data']);
    }
    if (dataClassName == 'GroupConsumptionLog') {
      return deserialize<_im17zz1w.GroupConsumptionLog>(data['data']);
    }
    if (dataClassName == 'GroupEntitlement') {
      return deserialize<_icykdmu9.GroupEntitlement>(data['data']);
    }
    if (dataClassName == 'IapValidationResponse') {
      return deserialize<_iomp5ggy.IapValidationResponse>(data['data']);
    }
    if (dataClassName == 'InventoryException') {
      return deserialize<_ic3ogqfy.InventoryException>(data['data']);
    }
    if (dataClassName == 'ModuleClass') {
      return deserialize<_izah8b1s.ModuleClass>(data['data']);
    }
    if (dataClassName == 'OrderStatus') {
      return deserialize<_idpqotwg.OrderStatus>(data['data']);
    }
    if (dataClassName == 'PaymentException') {
      return deserialize<_i8wa6pax.PaymentException>(data['data']);
    }
    if (dataClassName == 'PaymentRail') {
      return deserialize<_i4hkjqgd.PaymentRail>(data['data']);
    }
    if (dataClassName == 'PaymentRequest') {
      return deserialize<_ikpjr0wv.PaymentRequest>(data['data']);
    }
    if (dataClassName == 'PaymentResult') {
      return deserialize<_iu7zczvw.PaymentResult>(data['data']);
    }
    if (dataClassName == 'RailProduct') {
      return deserialize<_ii096092.RailProduct>(data['data']);
    }
    if (dataClassName == 'RailProductGrant') {
      return deserialize<_ip94uwhy.RailProductGrant>(data['data']);
    }
    if (dataClassName == 'ReceiptHash') {
      return deserialize<_i7pzcogb.ReceiptHash>(data['data']);
    }
    if (dataClassName == 'RefundClaim') {
      return deserialize<_i4ysmc15.RefundClaim>(data['data']);
    }
    if (dataClassName == 'TransactionPayment') {
      return deserialize<_i849cfmo.TransactionPayment>(data['data']);
    }
    return super.deserializeByClassName(data);
  }

  @override
  Object? dynamicFieldToJson(Object? object, {bool forProtocol = false}) {
    if ((object is List || object is Set || object is Map) ||
        getClassNameForObject(object) != null) {
      return super.dynamicFieldToJson(object, forProtocol: forProtocol);
    }
    for (final protocol in _hostProtocols) {
      final className = protocol.getClassNameForObject(object);
      if (className == null) continue;
      final host = protocol.getModuleName();
      final wrapped = {
        'className': className.contains('.') ? className : '$host.$className',
        'data': object,
      };
      return forProtocol
          ? _isc.SerializationManager.toEncodableForProtocol(wrapped)
          : _isc.SerializationManager.toEncodable(wrapped);
    }
    return super.dynamicFieldToJson(object, forProtocol: forProtocol);
  }

  @override
  dynamic deserializeDynamicFieldValue(Object? value) {
    if (value == null) return null;
    if (value is! Map<String, dynamic> || value['className'] is! String) {
      throw FormatException(
        'Dynamic fields are encoded as a Map with className and data, but got '
        '${value.runtimeType} instead.',
      );
    }
    final className = value['className'] as String;
    for (final protocol in _hostProtocols) {
      final host = protocol.getModuleName();
      final hostPrefix = '$host.';
      if (className.startsWith(hostPrefix)) {
        final strippedClassName = className.substring(hostPrefix.length);
        if (strippedClassName.contains('.')) {
          throw FormatException(
            'Dynamic field className must not use multiple prefixes: $className',
          );
        }
        final hostData = Map<String, dynamic>.from(value);
        hostData['className'] = strippedClassName;
        return protocol.deserializeByClassName(hostData);
      }
    }
    if (className.contains('.')) {
      for (final protocol in _hostProtocols) {
        try {
          return protocol.deserializeByClassName(value);
        } on _isc.DeserializationClassNameNotFoundException catch (_) {}
      }
    }
    return deserializeByClassName(value);
  }

  @override
  String getModuleName() => 'anonaccred';

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
      return _i3nzkmxo.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
