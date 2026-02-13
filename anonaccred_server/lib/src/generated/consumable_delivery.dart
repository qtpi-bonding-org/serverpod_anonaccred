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

abstract class ConsumableDelivery
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ConsumableDelivery._({
    this.id,
    required this.purchaseToken,
    required this.productId,
    required this.accountId,
    required this.consumableType,
    required this.quantity,
    required this.orderId,
    required this.deliveredAt,
  });

  factory ConsumableDelivery({
    int? id,
    required String purchaseToken,
    required String productId,
    required int accountId,
    required String consumableType,
    required double quantity,
    required String orderId,
    required DateTime deliveredAt,
  }) = _ConsumableDeliveryImpl;

  factory ConsumableDelivery.fromJson(Map<String, dynamic> jsonSerialization) {
    return ConsumableDelivery(
      id: jsonSerialization['id'] as int?,
      purchaseToken: jsonSerialization['purchaseToken'] as String,
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

  static final t = ConsumableDeliveryTable();

  static const db = ConsumableDeliveryRepository._();

  @override
  int? id;

  String purchaseToken;

  String productId;

  int accountId;

  String consumableType;

  double quantity;

  String orderId;

  DateTime deliveredAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ConsumableDelivery]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ConsumableDelivery copyWith({
    int? id,
    String? purchaseToken,
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
      '__className__': 'anonaccred.ConsumableDelivery',
      if (id != null) 'id': id,
      'purchaseToken': purchaseToken,
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
      '__className__': 'anonaccred.ConsumableDelivery',
      if (id != null) 'id': id,
      'purchaseToken': purchaseToken,
      'productId': productId,
      'accountId': accountId,
      'consumableType': consumableType,
      'quantity': quantity,
      'orderId': orderId,
      'deliveredAt': deliveredAt.toJson(),
    };
  }

  static ConsumableDeliveryInclude include() {
    return ConsumableDeliveryInclude._();
  }

  static ConsumableDeliveryIncludeList includeList({
    _i1.WhereExpressionBuilder<ConsumableDeliveryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ConsumableDeliveryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ConsumableDeliveryTable>? orderByList,
    ConsumableDeliveryInclude? include,
  }) {
    return ConsumableDeliveryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ConsumableDelivery.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ConsumableDelivery.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ConsumableDeliveryImpl extends ConsumableDelivery {
  _ConsumableDeliveryImpl({
    int? id,
    required String purchaseToken,
    required String productId,
    required int accountId,
    required String consumableType,
    required double quantity,
    required String orderId,
    required DateTime deliveredAt,
  }) : super._(
         id: id,
         purchaseToken: purchaseToken,
         productId: productId,
         accountId: accountId,
         consumableType: consumableType,
         quantity: quantity,
         orderId: orderId,
         deliveredAt: deliveredAt,
       );

  /// Returns a shallow copy of this [ConsumableDelivery]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ConsumableDelivery copyWith({
    Object? id = _Undefined,
    String? purchaseToken,
    String? productId,
    int? accountId,
    String? consumableType,
    double? quantity,
    String? orderId,
    DateTime? deliveredAt,
  }) {
    return ConsumableDelivery(
      id: id is int? ? id : this.id,
      purchaseToken: purchaseToken ?? this.purchaseToken,
      productId: productId ?? this.productId,
      accountId: accountId ?? this.accountId,
      consumableType: consumableType ?? this.consumableType,
      quantity: quantity ?? this.quantity,
      orderId: orderId ?? this.orderId,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}

class ConsumableDeliveryUpdateTable
    extends _i1.UpdateTable<ConsumableDeliveryTable> {
  ConsumableDeliveryUpdateTable(super.table);

  _i1.ColumnValue<String, String> purchaseToken(String value) =>
      _i1.ColumnValue(
        table.purchaseToken,
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

class ConsumableDeliveryTable extends _i1.Table<int?> {
  ConsumableDeliveryTable({super.tableRelation})
    : super(tableName: 'consumable_delivery') {
    updateTable = ConsumableDeliveryUpdateTable(this);
    purchaseToken = _i1.ColumnString(
      'purchaseToken',
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

  late final ConsumableDeliveryUpdateTable updateTable;

  late final _i1.ColumnString purchaseToken;

  late final _i1.ColumnString productId;

  late final _i1.ColumnInt accountId;

  late final _i1.ColumnString consumableType;

  late final _i1.ColumnDouble quantity;

  late final _i1.ColumnString orderId;

  late final _i1.ColumnDateTime deliveredAt;

  @override
  List<_i1.Column> get columns => [
    id,
    purchaseToken,
    productId,
    accountId,
    consumableType,
    quantity,
    orderId,
    deliveredAt,
  ];
}

class ConsumableDeliveryInclude extends _i1.IncludeObject {
  ConsumableDeliveryInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ConsumableDelivery.t;
}

class ConsumableDeliveryIncludeList extends _i1.IncludeList {
  ConsumableDeliveryIncludeList._({
    _i1.WhereExpressionBuilder<ConsumableDeliveryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ConsumableDelivery.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ConsumableDelivery.t;
}

class ConsumableDeliveryRepository {
  const ConsumableDeliveryRepository._();

  /// Returns a list of [ConsumableDelivery]s matching the given query parameters.
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
  Future<List<ConsumableDelivery>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ConsumableDeliveryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ConsumableDeliveryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ConsumableDeliveryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<ConsumableDelivery>(
      where: where?.call(ConsumableDelivery.t),
      orderBy: orderBy?.call(ConsumableDelivery.t),
      orderByList: orderByList?.call(ConsumableDelivery.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [ConsumableDelivery] matching the given query parameters.
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
  Future<ConsumableDelivery?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ConsumableDeliveryTable>? where,
    int? offset,
    _i1.OrderByBuilder<ConsumableDeliveryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ConsumableDeliveryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<ConsumableDelivery>(
      where: where?.call(ConsumableDelivery.t),
      orderBy: orderBy?.call(ConsumableDelivery.t),
      orderByList: orderByList?.call(ConsumableDelivery.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [ConsumableDelivery] by its [id] or null if no such row exists.
  Future<ConsumableDelivery?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<ConsumableDelivery>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [ConsumableDelivery]s in the list and returns the inserted rows.
  ///
  /// The returned [ConsumableDelivery]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ConsumableDelivery>> insert(
    _i1.Session session,
    List<ConsumableDelivery> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ConsumableDelivery>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ConsumableDelivery] and returns the inserted row.
  ///
  /// The returned [ConsumableDelivery] will have its `id` field set.
  Future<ConsumableDelivery> insertRow(
    _i1.Session session,
    ConsumableDelivery row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ConsumableDelivery>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ConsumableDelivery]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ConsumableDelivery>> update(
    _i1.Session session,
    List<ConsumableDelivery> rows, {
    _i1.ColumnSelections<ConsumableDeliveryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ConsumableDelivery>(
      rows,
      columns: columns?.call(ConsumableDelivery.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ConsumableDelivery]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ConsumableDelivery> updateRow(
    _i1.Session session,
    ConsumableDelivery row, {
    _i1.ColumnSelections<ConsumableDeliveryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ConsumableDelivery>(
      row,
      columns: columns?.call(ConsumableDelivery.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ConsumableDelivery] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ConsumableDelivery?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<ConsumableDeliveryUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ConsumableDelivery>(
      id,
      columnValues: columnValues(ConsumableDelivery.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ConsumableDelivery]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ConsumableDelivery>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<ConsumableDeliveryUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<ConsumableDeliveryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ConsumableDeliveryTable>? orderBy,
    _i1.OrderByListBuilder<ConsumableDeliveryTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ConsumableDelivery>(
      columnValues: columnValues(ConsumableDelivery.t.updateTable),
      where: where(ConsumableDelivery.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ConsumableDelivery.t),
      orderByList: orderByList?.call(ConsumableDelivery.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ConsumableDelivery]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ConsumableDelivery>> delete(
    _i1.Session session,
    List<ConsumableDelivery> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ConsumableDelivery>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ConsumableDelivery].
  Future<ConsumableDelivery> deleteRow(
    _i1.Session session,
    ConsumableDelivery row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ConsumableDelivery>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ConsumableDelivery>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ConsumableDeliveryTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ConsumableDelivery>(
      where: where(ConsumableDelivery.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ConsumableDeliveryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ConsumableDelivery>(
      where: where?.call(ConsumableDelivery.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
