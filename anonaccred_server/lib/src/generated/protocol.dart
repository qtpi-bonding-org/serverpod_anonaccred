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
import 'package:anonaccount_server/anonaccount_server.dart' as _i3;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i4;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i5;
import 'account_entitlement.dart' as _i6;
import 'api_response.dart' as _i7;
import 'consume_result.dart' as _i8;
import 'consumption_log.dart' as _i9;
import 'currency.dart' as _i10;
import 'entitlement.dart' as _i11;
import 'entitlement_type.dart' as _i12;
import 'ephemeral_accreditation.dart' as _i13;
import 'iap_validation_response.dart' as _i14;
import 'inventory_exception.dart' as _i15;
import 'module_class.dart' as _i16;
import 'order_status.dart' as _i17;
import 'payment_exception.dart' as _i18;
import 'payment_rail.dart' as _i19;
import 'payment_request.dart' as _i20;
import 'payment_result.dart' as _i21;
import 'rail_product.dart' as _i22;
import 'rail_product_grant.dart' as _i23;
import 'receipt_hash.dart' as _i24;
import 'transaction_payment.dart' as _i25;
import 'package:anonaccred_server/src/generated/account_entitlement.dart'
    as _i26;
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

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'account_entitlement',
      dartName: 'AccountEntitlement',
      schema: 'public',
      module: 'anonaccred',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'account_entitlement_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'accountUuid',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'entitlementId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'balance',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'account_entitlement_fk_0',
          columns: ['entitlementId'],
          referenceTable: 'entitlement',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'account_entitlement_pkey',
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
          indexName: 'account_entitlement_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'accountUuid',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'entitlementId',
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
      name: 'consumption_log',
      dartName: 'ConsumptionLog',
      schema: 'public',
      module: 'anonaccred',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'consumption_log_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'accountUuid',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'entitlementId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'amount',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'reason',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
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
          constraintName: 'consumption_log_fk_0',
          columns: ['entitlementId'],
          referenceTable: 'entitlement',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'consumption_log_pkey',
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
          indexName: 'account_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'accountUuid',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'entitlement_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'entitlementId',
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
      name: 'entitlement',
      dartName: 'Entitlement',
      schema: 'public',
      module: 'anonaccred',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'entitlement_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'tag',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'type',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:EntitlementType',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'entitlement_pkey',
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
          indexName: 'tag_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'tag',
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
      name: 'ephemeral_accreditation',
      dartName: 'EphemeralAccreditation',
      schema: 'public',
      module: 'anonaccred',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault:
              'nextval(\'ephemeral_accreditation_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'accountUuid',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'transactionTimestamp',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'ephemeral_accreditation_pkey',
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
          indexName: 'lookup_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'transactionTimestamp',
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
      name: 'rail_product',
      dartName: 'RailProduct',
      schema: 'public',
      module: 'anonaccred',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'rail_product_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'rail',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:PaymentRail',
        ),
        _i2.ColumnDefinition(
          name: 'storeProductId',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'isActive',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'rail_product_pkey',
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
          indexName: 'store_product_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'rail',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'storeProductId',
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
      name: 'rail_product_grant',
      dartName: 'RailProductGrant',
      schema: 'public',
      module: 'anonaccred',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'rail_product_grant_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'railProductId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'entitlementId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
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
          constraintName: 'rail_product_grant_fk_0',
          columns: ['railProductId'],
          referenceTable: 'rail_product',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'rail_product_grant_fk_1',
          columns: ['entitlementId'],
          referenceTable: 'entitlement',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'rail_product_grant_pkey',
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
      name: 'receipt_hash',
      dartName: 'ReceiptHash',
      schema: 'public',
      module: 'anonaccred',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'receipt_hash_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'hash',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'paymentRail',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:PaymentRail',
        ),
        _i2.ColumnDefinition(
          name: 'processedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'receipt_hash_pkey',
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
          indexName: 'hash_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'hash',
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
          name: 'railProductId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'internalTransactionId',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
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
          name: 'transactionTimestamp',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'clientReference',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'status',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:OrderStatus',
        ),
        _i2.ColumnDefinition(
          name: 'railDataJson',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'transaction_payment_fk_0',
          columns: ['railProductId'],
          referenceTable: 'rail_product',
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
        _i2.IndexDefinition(
          indexName: 'internal_tx_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'internalTransactionId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'timestamp_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'transactionTimestamp',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i4.Protocol.targetTableDefinitions,
    ..._i5.Protocol.targetTableDefinitions,
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

    if (t == _i6.AccountEntitlement) {
      return _i6.AccountEntitlement.fromJson(data) as T;
    }
    if (t == _i7.ApiResponse) {
      return _i7.ApiResponse.fromJson(data) as T;
    }
    if (t == _i8.ConsumeResult) {
      return _i8.ConsumeResult.fromJson(data) as T;
    }
    if (t == _i9.ConsumptionLog) {
      return _i9.ConsumptionLog.fromJson(data) as T;
    }
    if (t == _i10.Currency) {
      return _i10.Currency.fromJson(data) as T;
    }
    if (t == _i11.Entitlement) {
      return _i11.Entitlement.fromJson(data) as T;
    }
    if (t == _i12.EntitlementType) {
      return _i12.EntitlementType.fromJson(data) as T;
    }
    if (t == _i13.EphemeralAccreditation) {
      return _i13.EphemeralAccreditation.fromJson(data) as T;
    }
    if (t == _i14.IapValidationResponse) {
      return _i14.IapValidationResponse.fromJson(data) as T;
    }
    if (t == _i15.InventoryException) {
      return _i15.InventoryException.fromJson(data) as T;
    }
    if (t == _i16.ModuleClass) {
      return _i16.ModuleClass.fromJson(data) as T;
    }
    if (t == _i17.OrderStatus) {
      return _i17.OrderStatus.fromJson(data) as T;
    }
    if (t == _i18.PaymentException) {
      return _i18.PaymentException.fromJson(data) as T;
    }
    if (t == _i19.PaymentRail) {
      return _i19.PaymentRail.fromJson(data) as T;
    }
    if (t == _i20.PaymentRequest) {
      return _i20.PaymentRequest.fromJson(data) as T;
    }
    if (t == _i21.PaymentResult) {
      return _i21.PaymentResult.fromJson(data) as T;
    }
    if (t == _i22.RailProduct) {
      return _i22.RailProduct.fromJson(data) as T;
    }
    if (t == _i23.RailProductGrant) {
      return _i23.RailProductGrant.fromJson(data) as T;
    }
    if (t == _i24.ReceiptHash) {
      return _i24.ReceiptHash.fromJson(data) as T;
    }
    if (t == _i25.TransactionPayment) {
      return _i25.TransactionPayment.fromJson(data) as T;
    }
    if (t == _i1.getType<_i6.AccountEntitlement?>()) {
      return (data != null ? _i6.AccountEntitlement.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.ApiResponse?>()) {
      return (data != null ? _i7.ApiResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.ConsumeResult?>()) {
      return (data != null ? _i8.ConsumeResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.ConsumptionLog?>()) {
      return (data != null ? _i9.ConsumptionLog.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.Currency?>()) {
      return (data != null ? _i10.Currency.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.Entitlement?>()) {
      return (data != null ? _i11.Entitlement.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.EntitlementType?>()) {
      return (data != null ? _i12.EntitlementType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.EphemeralAccreditation?>()) {
      return (data != null ? _i13.EphemeralAccreditation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i14.IapValidationResponse?>()) {
      return (data != null ? _i14.IapValidationResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i15.InventoryException?>()) {
      return (data != null ? _i15.InventoryException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.ModuleClass?>()) {
      return (data != null ? _i16.ModuleClass.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.OrderStatus?>()) {
      return (data != null ? _i17.OrderStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.PaymentException?>()) {
      return (data != null ? _i18.PaymentException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.PaymentRail?>()) {
      return (data != null ? _i19.PaymentRail.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.PaymentRequest?>()) {
      return (data != null ? _i20.PaymentRequest.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.PaymentResult?>()) {
      return (data != null ? _i21.PaymentResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.RailProduct?>()) {
      return (data != null ? _i22.RailProduct.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.RailProductGrant?>()) {
      return (data != null ? _i23.RailProductGrant.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.ReceiptHash?>()) {
      return (data != null ? _i24.ReceiptHash.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.TransactionPayment?>()) {
      return (data != null ? _i25.TransactionPayment.fromJson(data) : null)
          as T;
    }
    if (t == List<_i26.AccountEntitlement>) {
      return (data as List)
              .map((e) => deserialize<_i26.AccountEntitlement>(e))
              .toList()
          as T;
    }
    try {
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i4.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i5.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i6.AccountEntitlement => 'AccountEntitlement',
      _i7.ApiResponse => 'ApiResponse',
      _i8.ConsumeResult => 'ConsumeResult',
      _i9.ConsumptionLog => 'ConsumptionLog',
      _i10.Currency => 'Currency',
      _i11.Entitlement => 'Entitlement',
      _i12.EntitlementType => 'EntitlementType',
      _i13.EphemeralAccreditation => 'EphemeralAccreditation',
      _i14.IapValidationResponse => 'IapValidationResponse',
      _i15.InventoryException => 'InventoryException',
      _i16.ModuleClass => 'ModuleClass',
      _i17.OrderStatus => 'OrderStatus',
      _i18.PaymentException => 'PaymentException',
      _i19.PaymentRail => 'PaymentRail',
      _i20.PaymentRequest => 'PaymentRequest',
      _i21.PaymentResult => 'PaymentResult',
      _i22.RailProduct => 'RailProduct',
      _i23.RailProductGrant => 'RailProductGrant',
      _i24.ReceiptHash => 'ReceiptHash',
      _i25.TransactionPayment => 'TransactionPayment',
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
      case _i6.AccountEntitlement():
        return 'AccountEntitlement';
      case _i7.ApiResponse():
        return 'ApiResponse';
      case _i8.ConsumeResult():
        return 'ConsumeResult';
      case _i9.ConsumptionLog():
        return 'ConsumptionLog';
      case _i10.Currency():
        return 'Currency';
      case _i11.Entitlement():
        return 'Entitlement';
      case _i12.EntitlementType():
        return 'EntitlementType';
      case _i13.EphemeralAccreditation():
        return 'EphemeralAccreditation';
      case _i14.IapValidationResponse():
        return 'IapValidationResponse';
      case _i15.InventoryException():
        return 'InventoryException';
      case _i16.ModuleClass():
        return 'ModuleClass';
      case _i17.OrderStatus():
        return 'OrderStatus';
      case _i18.PaymentException():
        return 'PaymentException';
      case _i19.PaymentRail():
        return 'PaymentRail';
      case _i20.PaymentRequest():
        return 'PaymentRequest';
      case _i21.PaymentResult():
        return 'PaymentResult';
      case _i22.RailProduct():
        return 'RailProduct';
      case _i23.RailProductGrant():
        return 'RailProductGrant';
      case _i24.ReceiptHash():
        return 'ReceiptHash';
      case _i25.TransactionPayment():
        return 'TransactionPayment';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    className = _i3.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'anonaccount.$className';
    }
    className = _i4.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i5.Protocol().getClassNameForObject(data);
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
      return deserialize<_i6.AccountEntitlement>(data['data']);
    }
    if (dataClassName == 'ApiResponse') {
      return deserialize<_i7.ApiResponse>(data['data']);
    }
    if (dataClassName == 'ConsumeResult') {
      return deserialize<_i8.ConsumeResult>(data['data']);
    }
    if (dataClassName == 'ConsumptionLog') {
      return deserialize<_i9.ConsumptionLog>(data['data']);
    }
    if (dataClassName == 'Currency') {
      return deserialize<_i10.Currency>(data['data']);
    }
    if (dataClassName == 'Entitlement') {
      return deserialize<_i11.Entitlement>(data['data']);
    }
    if (dataClassName == 'EntitlementType') {
      return deserialize<_i12.EntitlementType>(data['data']);
    }
    if (dataClassName == 'EphemeralAccreditation') {
      return deserialize<_i13.EphemeralAccreditation>(data['data']);
    }
    if (dataClassName == 'IapValidationResponse') {
      return deserialize<_i14.IapValidationResponse>(data['data']);
    }
    if (dataClassName == 'InventoryException') {
      return deserialize<_i15.InventoryException>(data['data']);
    }
    if (dataClassName == 'ModuleClass') {
      return deserialize<_i16.ModuleClass>(data['data']);
    }
    if (dataClassName == 'OrderStatus') {
      return deserialize<_i17.OrderStatus>(data['data']);
    }
    if (dataClassName == 'PaymentException') {
      return deserialize<_i18.PaymentException>(data['data']);
    }
    if (dataClassName == 'PaymentRail') {
      return deserialize<_i19.PaymentRail>(data['data']);
    }
    if (dataClassName == 'PaymentRequest') {
      return deserialize<_i20.PaymentRequest>(data['data']);
    }
    if (dataClassName == 'PaymentResult') {
      return deserialize<_i21.PaymentResult>(data['data']);
    }
    if (dataClassName == 'RailProduct') {
      return deserialize<_i22.RailProduct>(data['data']);
    }
    if (dataClassName == 'RailProductGrant') {
      return deserialize<_i23.RailProductGrant>(data['data']);
    }
    if (dataClassName == 'ReceiptHash') {
      return deserialize<_i24.ReceiptHash>(data['data']);
    }
    if (dataClassName == 'TransactionPayment') {
      return deserialize<_i25.TransactionPayment>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('anonaccount.')) {
      data['className'] = dataClassName.substring(12);
      return _i3.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i4.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i5.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i4.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i5.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i6.AccountEntitlement:
        return _i6.AccountEntitlement.t;
      case _i9.ConsumptionLog:
        return _i9.ConsumptionLog.t;
      case _i11.Entitlement:
        return _i11.Entitlement.t;
      case _i13.EphemeralAccreditation:
        return _i13.EphemeralAccreditation.t;
      case _i22.RailProduct:
        return _i22.RailProduct.t;
      case _i23.RailProductGrant:
        return _i23.RailProductGrant.t;
      case _i24.ReceiptHash:
        return _i24.ReceiptHash.t;
      case _i25.TransactionPayment:
        return _i25.TransactionPayment.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

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
      return _i3.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i4.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i5.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
