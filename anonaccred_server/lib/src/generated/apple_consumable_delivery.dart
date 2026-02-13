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

abstract class AppleConsumableDelivery
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  AppleConsumableDelivery._({
    this.id,
    required this.transactionId,
    required this.originalTransactionId,
    required this.productId,
    required this.accountId,
    required this.consumableType,
    required this.quantity,
    required this.orderId,
    required this.deliveredAt,
  });

  factory AppleConsumableDelivery({
    int? id,
    required String transactionId,
    required String originalTransactionId,
    required String productId,
    required int accountId,
    required String consumableType,
    required double quantity,
    required String orderId,
    required DateTime deliveredAt,
  }) = _AppleConsumableDeliveryImpl;

  factory AppleConsumableDelivery.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AppleConsumableDelivery(
      id: jsonSerialization['id'] as int?,
      transactionId: jsonSerialization['transactionId'] as String,
      originalTransactionId:
          jsonSerialization['originalTransactionId'] as String,
      productId: jsonSerialization['productId'] as String,
      accountId: jsonSerialization['accountId'] as int,
      consumableType: jsonSerialization['consumableType'] as String,
      quantity: (jsonSerialization['quantity'] as num).toDouble(),
      orderId: jsonSerialization['orderId'] as String,
      deliveredAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['deliveredAt'],
      ),
    );
  }

  static final t = AppleConsumableDeliveryTable();

  static const db = AppleConsumableDeliveryRepository._();

  @override
  int? id;

  String transactionId;

  String originalTransactionId;

  String productId;

  int accountId;

  String consumableType;

  double quantity;

  String orderId;

  DateTime deliveredAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [AppleConsumableDelivery]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AppleConsumableDelivery copyWith({
    int? id,
    String? transactionId,
    String? originalTransactionId,
    String? productId,
    int? accountId,
    String? consumableType,
    double? quantity,
    String? orderId,
    DateTime? deliveredAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppleConsumableDelivery',
      if (id != null) 'id': id,
      'transactionId': transactionId,
      'originalTransactionId': originalTransactionId,
      'productId': productId,
      'accountId': accountId,
      'consumableType': consumableType,
      'quantity': quantity,
      'orderId': orderId,
      'deliveredAt': deliveredAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppleConsumableDelivery',
      if (id != null) 'id': id,
      'transactionId': transactionId,
      'originalTransactionId': originalTransactionId,
      'productId': productId,
      'accountId': accountId,
      'consumableType': consumableType,
      'quantity': quantity,
      'orderId': orderId,
      'deliveredAt': deliveredAt.toJson(),
    };
  }

  static AppleConsumableDeliveryInclude include() {
    return AppleConsumableDeliveryInclude._();
  }

  static AppleConsumableDeliveryIncludeList includeList({
    _i1.WhereExpressionBuilder<AppleConsumableDeliveryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AppleConsumableDeliveryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AppleConsumableDeliveryTable>? orderByList,
    AppleConsumableDeliveryInclude? include,
  }) {
    return AppleConsumableDeliveryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AppleConsumableDelivery.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AppleConsumableDelivery.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AppleConsumableDeliveryImpl extends AppleConsumableDelivery {
  _AppleConsumableDeliveryImpl({
    int? id,
    required String transactionId,
    required String originalTransactionId,
    required String productId,
    required int accountId,
    required String consumableType,
    required double quantity,
    required String orderId,
    required DateTime deliveredAt,
  }) : super._(
         id: id,
         transactionId: transactionId,
         originalTransactionId: originalTransactionId,
         productId: productId,
         accountId: accountId,
         consumableType: consumableType,
         quantity: quantity,
         orderId: orderId,
         deliveredAt: deliveredAt,
       );

  /// Returns a shallow copy of this [AppleConsumableDelivery]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AppleConsumableDelivery copyWith({
    Object? id = _Undefined,
    String? transactionId,
    String? originalTransactionId,
    String? productId,
    int? accountId,
    String? consumableType,
    double? quantity,
    String? orderId,
    DateTime? deliveredAt,
  }) {
    return AppleConsumableDelivery(
      id: id is int? ? id : this.id,
      transactionId: transactionId ?? this.transactionId,
      originalTransactionId:
          originalTransactionId ?? this.originalTransactionId,
      productId: productId ?? this.productId,
      accountId: accountId ?? this.accountId,
      consumableType: consumableType ?? this.consumableType,
      quantity: quantity ?? this.quantity,
      orderId: orderId ?? this.orderId,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}

class AppleConsumableDeliveryUpdateTable
    extends _i1.UpdateTable<AppleConsumableDeliveryTable> {
  AppleConsumableDeliveryUpdateTable(super.table);

  _i1.ColumnValue<String, String> transactionId(String value) =>
      _i1.ColumnValue(
        table.transactionId,
        value,
      );

  _i1.ColumnValue<String, String> originalTransactionId(String value) =>
      _i1.ColumnValue(
        table.originalTransactionId,
        value,
      );

  _i1.ColumnValue<String, String> productId(String value) => _i1.ColumnValue(
    table.productId,
    value,
  );

  _i1.ColumnValue<int, int> accountId(int value) => _i1.ColumnValue(
    table.accountId,
    value,
  );

  _i1.ColumnValue<String, String> consumableType(String value) =>
      _i1.ColumnValue(
        table.consumableType,
        value,
      );

  _i1.ColumnValue<double, double> quantity(double value) => _i1.ColumnValue(
    table.quantity,
    value,
  );

  _i1.ColumnValue<String, String> orderId(String value) => _i1.ColumnValue(
    table.orderId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> deliveredAt(DateTime value) =>
      _i1.ColumnValue(
        table.deliveredAt,
        value,
      );
}

class AppleConsumableDeliveryTable extends _i1.Table<int?> {
  AppleConsumableDeliveryTable({super.tableRelation})
    : super(tableName: 'apple_consumable_delivery') {
    updateTable = AppleConsumableDeliveryUpdateTable(this);
    transactionId = _i1.ColumnString(
      'transactionId',
      this,
    );
    originalTransactionId = _i1.ColumnString(
      'originalTransactionId',
      this,
    );
    productId = _i1.ColumnString(
      'productId',
      this,
    );
    accountId = _i1.ColumnInt(
      'accountId',
      this,
    );
    consumableType = _i1.ColumnString(
      'consumableType',
      this,
    );
    quantity = _i1.ColumnDouble(
      'quantity',
      this,
    );
    orderId = _i1.ColumnString(
      'orderId',
      this,
    );
    deliveredAt = _i1.ColumnDateTime(
      'deliveredAt',
      this,
    );
  }

  late final AppleConsumableDeliveryUpdateTable updateTable;

  late final _i1.ColumnString transactionId;

  late final _i1.ColumnString originalTransactionId;

  late final _i1.ColumnString productId;

  late final _i1.ColumnInt accountId;

  late final _i1.ColumnString consumableType;

  late final _i1.ColumnDouble quantity;

  late final _i1.ColumnString orderId;

  late final _i1.ColumnDateTime deliveredAt;

  @override
  List<_i1.Column> get columns => [
    id,
    transactionId,
    originalTransactionId,
    productId,
    accountId,
    consumableType,
    quantity,
    orderId,
    deliveredAt,
  ];
}

class AppleConsumableDeliveryInclude extends _i1.IncludeObject {
  AppleConsumableDeliveryInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => AppleConsumableDelivery.t;
}

class AppleConsumableDeliveryIncludeList extends _i1.IncludeList {
  AppleConsumableDeliveryIncludeList._({
    _i1.WhereExpressionBuilder<AppleConsumableDeliveryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AppleConsumableDelivery.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => AppleConsumableDelivery.t;
}

class AppleConsumableDeliveryRepository {
  const AppleConsumableDeliveryRepository._();

  /// Returns a list of [AppleConsumableDelivery]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<AppleConsumableDelivery>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AppleConsumableDeliveryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AppleConsumableDeliveryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AppleConsumableDeliveryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<AppleConsumableDelivery>(
      where: where?.call(AppleConsumableDelivery.t),
      orderBy: orderBy?.call(AppleConsumableDelivery.t),
      orderByList: orderByList?.call(AppleConsumableDelivery.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [AppleConsumableDelivery] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<AppleConsumableDelivery?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AppleConsumableDeliveryTable>? where,
    int? offset,
    _i1.OrderByBuilder<AppleConsumableDeliveryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AppleConsumableDeliveryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<AppleConsumableDelivery>(
      where: where?.call(AppleConsumableDelivery.t),
      orderBy: orderBy?.call(AppleConsumableDelivery.t),
      orderByList: orderByList?.call(AppleConsumableDelivery.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [AppleConsumableDelivery] by its [id] or null if no such row exists.
  Future<AppleConsumableDelivery?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<AppleConsumableDelivery>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [AppleConsumableDelivery]s in the list and returns the inserted rows.
  ///
  /// The returned [AppleConsumableDelivery]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<AppleConsumableDelivery>> insert(
    _i1.Session session,
    List<AppleConsumableDelivery> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<AppleConsumableDelivery>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [AppleConsumableDelivery] and returns the inserted row.
  ///
  /// The returned [AppleConsumableDelivery] will have its `id` field set.
  Future<AppleConsumableDelivery> insertRow(
    _i1.Session session,
    AppleConsumableDelivery row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AppleConsumableDelivery>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [AppleConsumableDelivery]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AppleConsumableDelivery>> update(
    _i1.Session session,
    List<AppleConsumableDelivery> rows, {
    _i1.ColumnSelections<AppleConsumableDeliveryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AppleConsumableDelivery>(
      rows,
      columns: columns?.call(AppleConsumableDelivery.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AppleConsumableDelivery]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AppleConsumableDelivery> updateRow(
    _i1.Session session,
    AppleConsumableDelivery row, {
    _i1.ColumnSelections<AppleConsumableDeliveryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AppleConsumableDelivery>(
      row,
      columns: columns?.call(AppleConsumableDelivery.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AppleConsumableDelivery] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AppleConsumableDelivery?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<AppleConsumableDeliveryUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AppleConsumableDelivery>(
      id,
      columnValues: columnValues(AppleConsumableDelivery.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AppleConsumableDelivery]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AppleConsumableDelivery>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<AppleConsumableDeliveryUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<AppleConsumableDeliveryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AppleConsumableDeliveryTable>? orderBy,
    _i1.OrderByListBuilder<AppleConsumableDeliveryTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AppleConsumableDelivery>(
      columnValues: columnValues(AppleConsumableDelivery.t.updateTable),
      where: where(AppleConsumableDelivery.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AppleConsumableDelivery.t),
      orderByList: orderByList?.call(AppleConsumableDelivery.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AppleConsumableDelivery]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AppleConsumableDelivery>> delete(
    _i1.Session session,
    List<AppleConsumableDelivery> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AppleConsumableDelivery>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [AppleConsumableDelivery].
  Future<AppleConsumableDelivery> deleteRow(
    _i1.Session session,
    AppleConsumableDelivery row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AppleConsumableDelivery>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AppleConsumableDelivery>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<AppleConsumableDeliveryTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AppleConsumableDelivery>(
      where: where(AppleConsumableDelivery.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AppleConsumableDeliveryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AppleConsumableDelivery>(
      where: where?.call(AppleConsumableDelivery.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
