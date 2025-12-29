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
import 'package:serverpod/protocol.dart' as _i2;
import 'account.dart' as _i3;
import 'account_device.dart' as _i4;
import 'anonaccred_exception.dart' as _i5;
import 'authentication_exception.dart' as _i6;
import 'authentication_result.dart' as _i7;
import 'consume_result.dart' as _i8;
import 'enums.dart' as _i9;
import 'inventory.dart' as _i10;
import 'inventory_exception.dart' as _i11;
import 'module_class.dart' as _i12;
import 'order_status.dart' as _i13;
import 'payment_exception.dart' as _i14;
import 'payment_rail.dart' as _i15;
import 'payment_request.dart' as _i16;
import 'payment_result.dart' as _i17;
import 'transaction.dart' as _i18;
import 'transaction_consumable.dart' as _i19;
import 'package:anonaccred_server/src/generated/inventory.dart' as _i20;
import 'package:anonaccred_server/src/generated/account_device.dart' as _i21;
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

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'account_device',
      dartName: 'AccountDevice',
      schema: 'public',
      module: 'anonaccred',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'account_device_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'accountId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'publicSubKey',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'encryptedDataKey',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'label',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'lastActive',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'isRevoked',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'account_device_fk_0',
          columns: ['accountId'],
          referenceTable: 'anon_account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'account_device_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'auth_lookup_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'publicSubKey',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'isRevoked',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'account_inventory',
      dartName: 'AccountInventory',
      schema: 'public',
      module: 'anonaccred',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'account_inventory_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'accountId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'consumableType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'quantity',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'lastUpdated',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'account_inventory_fk_0',
          columns: ['accountId'],
          referenceTable: 'anon_account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'account_inventory_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'inventory_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'accountId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'consumableType',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'anon_account',
      dartName: 'AnonAccount',
      schema: 'public',
      module: 'anonaccred',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'anon_account_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'publicMasterKey',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'encryptedDataKey',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'ultimatePublicKey',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'anon_account_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'ultimate_key_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'ultimatePublicKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'transaction_consumable',
      dartName: 'TransactionConsumable',
      schema: 'public',
      module: 'anonaccred',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'transaction_consumable_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'transactionId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'consumableType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'quantity',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'transaction_consumable_fk_0',
          columns: ['transactionId'],
          referenceTable: 'transaction_payment',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'transaction_consumable_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'transaction_payment',
      dartName: 'TransactionPayment',
      schema: 'public',
      module: 'anonaccred',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'transaction_payment_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'externalId',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'accountId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'priceCurrency',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:Currency',
        ),
        _i2.ColumnDefinition(
          name: 'price',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'paymentRail',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:PaymentRail',
        ),
        _i2.ColumnDefinition(
          name: 'paymentCurrency',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:Currency',
        ),
        _i2.ColumnDefinition(
          name: 'paymentAmount',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'paymentRef',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'transactionHash',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'status',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:OrderStatus',
          columnDefault: '\'pending\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'timestamp',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'transaction_payment_fk_0',
          columns: ['accountId'],
          referenceTable: 'anon_account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'transaction_payment_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
  ];

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

    if (t == _i3.AnonAccount) {
      return _i3.AnonAccount.fromJson(data) as T;
    }
    if (t == _i4.AccountDevice) {
      return _i4.AccountDevice.fromJson(data) as T;
    }
    if (t == _i5.AnonAccredException) {
      return _i5.AnonAccredException.fromJson(data) as T;
    }
    if (t == _i6.AuthenticationException) {
      return _i6.AuthenticationException.fromJson(data) as T;
    }
    if (t == _i7.AuthenticationResult) {
      return _i7.AuthenticationResult.fromJson(data) as T;
    }
    if (t == _i8.ConsumeResult) {
      return _i8.ConsumeResult.fromJson(data) as T;
    }
    if (t == _i9.Currency) {
      return _i9.Currency.fromJson(data) as T;
    }
    if (t == _i10.AccountInventory) {
      return _i10.AccountInventory.fromJson(data) as T;
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
    if (t == _i18.TransactionPayment) {
      return _i18.TransactionPayment.fromJson(data) as T;
    }
    if (t == _i19.TransactionConsumable) {
      return _i19.TransactionConsumable.fromJson(data) as T;
    }
    if (t == _i1.getType<_i3.AnonAccount?>()) {
      return (data != null ? _i3.AnonAccount.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.AccountDevice?>()) {
      return (data != null ? _i4.AccountDevice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.AnonAccredException?>()) {
      return (data != null ? _i5.AnonAccredException.fromJson(data) : null)
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
    if (t == _i1.getType<_i8.ConsumeResult?>()) {
      return (data != null ? _i8.ConsumeResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.Currency?>()) {
      return (data != null ? _i9.Currency.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.AccountInventory?>()) {
      return (data != null ? _i10.AccountInventory.fromJson(data) : null) as T;
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
    if (t == _i1.getType<_i18.TransactionPayment?>()) {
      return (data != null ? _i18.TransactionPayment.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i19.TransactionConsumable?>()) {
      return (data != null ? _i19.TransactionConsumable.fromJson(data) : null)
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
    if (t == List<_i20.AccountInventory>) {
      return (data as List)
              .map((e) => deserialize<_i20.AccountInventory>(e))
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
    if (t == List<_i21.AccountDevice>) {
      return (data as List)
              .map((e) => deserialize<_i21.AccountDevice>(e))
              .toList()
          as T;
    }
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i3.AnonAccount => 'AnonAccount',
      _i4.AccountDevice => 'AccountDevice',
      _i5.AnonAccredException => 'AnonAccredException',
      _i6.AuthenticationException => 'AuthenticationException',
      _i7.AuthenticationResult => 'AuthenticationResult',
      _i8.ConsumeResult => 'ConsumeResult',
      _i9.Currency => 'Currency',
      _i10.AccountInventory => 'AccountInventory',
      _i11.InventoryException => 'InventoryException',
      _i12.ModuleClass => 'ModuleClass',
      _i13.OrderStatus => 'OrderStatus',
      _i14.PaymentException => 'PaymentException',
      _i15.PaymentRail => 'PaymentRail',
      _i16.PaymentRequest => 'PaymentRequest',
      _i17.PaymentResult => 'PaymentResult',
      _i18.TransactionPayment => 'TransactionPayment',
      _i19.TransactionConsumable => 'TransactionConsumable',
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
      case _i3.AnonAccount():
        return 'AnonAccount';
      case _i4.AccountDevice():
        return 'AccountDevice';
      case _i5.AnonAccredException():
        return 'AnonAccredException';
      case _i6.AuthenticationException():
        return 'AuthenticationException';
      case _i7.AuthenticationResult():
        return 'AuthenticationResult';
      case _i8.ConsumeResult():
        return 'ConsumeResult';
      case _i9.Currency():
        return 'Currency';
      case _i10.AccountInventory():
        return 'AccountInventory';
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
      case _i18.TransactionPayment():
        return 'TransactionPayment';
      case _i19.TransactionConsumable():
        return 'TransactionConsumable';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
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
      return deserialize<_i3.AnonAccount>(data['data']);
    }
    if (dataClassName == 'AccountDevice') {
      return deserialize<_i4.AccountDevice>(data['data']);
    }
    if (dataClassName == 'AnonAccredException') {
      return deserialize<_i5.AnonAccredException>(data['data']);
    }
    if (dataClassName == 'AuthenticationException') {
      return deserialize<_i6.AuthenticationException>(data['data']);
    }
    if (dataClassName == 'AuthenticationResult') {
      return deserialize<_i7.AuthenticationResult>(data['data']);
    }
    if (dataClassName == 'ConsumeResult') {
      return deserialize<_i8.ConsumeResult>(data['data']);
    }
    if (dataClassName == 'Currency') {
      return deserialize<_i9.Currency>(data['data']);
    }
    if (dataClassName == 'AccountInventory') {
      return deserialize<_i10.AccountInventory>(data['data']);
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
    if (dataClassName == 'TransactionPayment') {
      return deserialize<_i18.TransactionPayment>(data['data']);
    }
    if (dataClassName == 'TransactionConsumable') {
      return deserialize<_i19.TransactionConsumable>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i3.AnonAccount:
        return _i3.AnonAccount.t;
      case _i4.AccountDevice:
        return _i4.AccountDevice.t;
      case _i10.AccountInventory:
        return _i10.AccountInventory.t;
      case _i18.TransactionPayment:
        return _i18.TransactionPayment.t;
      case _i19.TransactionConsumable:
        return _i19.TransactionConsumable.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'anonaccred';
}
