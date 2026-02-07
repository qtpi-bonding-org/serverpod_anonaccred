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

abstract class TransactionConsumable
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  TransactionConsumable._({
    this.id,
    required this.transactionId,
    required this.consumableType,
    required this.quantity,
  });

  factory TransactionConsumable({
    int? id,
    required int transactionId,
    required String consumableType,
    required double quantity,
  }) = _TransactionConsumableImpl;

  factory TransactionConsumable.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return TransactionConsumable(
      id: jsonSerialization['id'] as int?,
      transactionId: jsonSerialization['transactionId'] as int,
      consumableType: jsonSerialization['consumableType'] as String,
      quantity: (jsonSerialization['quantity'] as num).toDouble(),
    );
  }

  static final t = TransactionConsumableTable();

  static const db = TransactionConsumableRepository._();

  @override
  int? id;

  int transactionId;

  String consumableType;

  double quantity;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [TransactionConsumable]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TransactionConsumable copyWith({
    int? id,
    int? transactionId,
    String? consumableType,
    double? quantity,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.TransactionConsumable',
      if (id != null) 'id': id,
      'transactionId': transactionId,
      'consumableType': consumableType,
      'quantity': quantity,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.TransactionConsumable',
      if (id != null) 'id': id,
      'transactionId': transactionId,
      'consumableType': consumableType,
      'quantity': quantity,
    };
  }

  static TransactionConsumableInclude include() {
    return TransactionConsumableInclude._();
  }

  static TransactionConsumableIncludeList includeList({
    _i1.WhereExpressionBuilder<TransactionConsumableTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TransactionConsumableTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TransactionConsumableTable>? orderByList,
    TransactionConsumableInclude? include,
  }) {
    return TransactionConsumableIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TransactionConsumable.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(TransactionConsumable.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransactionConsumableImpl extends TransactionConsumable {
  _TransactionConsumableImpl({
    int? id,
    required int transactionId,
    required String consumableType,
    required double quantity,
  }) : super._(
         id: id,
         transactionId: transactionId,
         consumableType: consumableType,
         quantity: quantity,
       );

  /// Returns a shallow copy of this [TransactionConsumable]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TransactionConsumable copyWith({
    Object? id = _Undefined,
    int? transactionId,
    String? consumableType,
    double? quantity,
  }) {
    return TransactionConsumable(
      id: id is int? ? id : this.id,
      transactionId: transactionId ?? this.transactionId,
      consumableType: consumableType ?? this.consumableType,
      quantity: quantity ?? this.quantity,
    );
  }
}

class TransactionConsumableUpdateTable
    extends _i1.UpdateTable<TransactionConsumableTable> {
  TransactionConsumableUpdateTable(super.table);

  _i1.ColumnValue<int, int> transactionId(int value) => _i1.ColumnValue(
    table.transactionId,
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
}

class TransactionConsumableTable extends _i1.Table<int?> {
  TransactionConsumableTable({super.tableRelation})
    : super(tableName: 'transaction_consumable') {
    updateTable = TransactionConsumableUpdateTable(this);
    transactionId = _i1.ColumnInt(
      'transactionId',
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
  }

  late final TransactionConsumableUpdateTable updateTable;

  late final _i1.ColumnInt transactionId;

  late final _i1.ColumnString consumableType;

  late final _i1.ColumnDouble quantity;

  @override
  List<_i1.Column> get columns => [
    id,
    transactionId,
    consumableType,
    quantity,
  ];
}

class TransactionConsumableInclude extends _i1.IncludeObject {
  TransactionConsumableInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => TransactionConsumable.t;
}

class TransactionConsumableIncludeList extends _i1.IncludeList {
  TransactionConsumableIncludeList._({
    _i1.WhereExpressionBuilder<TransactionConsumableTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TransactionConsumable.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => TransactionConsumable.t;
}

class TransactionConsumableRepository {
  const TransactionConsumableRepository._();

  /// Returns a list of [TransactionConsumable]s matching the given query parameters.
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
  Future<List<TransactionConsumable>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TransactionConsumableTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TransactionConsumableTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TransactionConsumableTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<TransactionConsumable>(
      where: where?.call(TransactionConsumable.t),
      orderBy: orderBy?.call(TransactionConsumable.t),
      orderByList: orderByList?.call(TransactionConsumable.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [TransactionConsumable] matching the given query parameters.
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
  Future<TransactionConsumable?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TransactionConsumableTable>? where,
    int? offset,
    _i1.OrderByBuilder<TransactionConsumableTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TransactionConsumableTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<TransactionConsumable>(
      where: where?.call(TransactionConsumable.t),
      orderBy: orderBy?.call(TransactionConsumable.t),
      orderByList: orderByList?.call(TransactionConsumable.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [TransactionConsumable] by its [id] or null if no such row exists.
  Future<TransactionConsumable?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<TransactionConsumable>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [TransactionConsumable]s in the list and returns the inserted rows.
  ///
  /// The returned [TransactionConsumable]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<TransactionConsumable>> insert(
    _i1.Session session,
    List<TransactionConsumable> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<TransactionConsumable>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [TransactionConsumable] and returns the inserted row.
  ///
  /// The returned [TransactionConsumable] will have its `id` field set.
  Future<TransactionConsumable> insertRow(
    _i1.Session session,
    TransactionConsumable row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<TransactionConsumable>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [TransactionConsumable]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<TransactionConsumable>> update(
    _i1.Session session,
    List<TransactionConsumable> rows, {
    _i1.ColumnSelections<TransactionConsumableTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<TransactionConsumable>(
      rows,
      columns: columns?.call(TransactionConsumable.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TransactionConsumable]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TransactionConsumable> updateRow(
    _i1.Session session,
    TransactionConsumable row, {
    _i1.ColumnSelections<TransactionConsumableTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<TransactionConsumable>(
      row,
      columns: columns?.call(TransactionConsumable.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TransactionConsumable] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TransactionConsumable?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<TransactionConsumableUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<TransactionConsumable>(
      id,
      columnValues: columnValues(TransactionConsumable.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TransactionConsumable]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<TransactionConsumable>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<TransactionConsumableUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<TransactionConsumableTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TransactionConsumableTable>? orderBy,
    _i1.OrderByListBuilder<TransactionConsumableTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<TransactionConsumable>(
      columnValues: columnValues(TransactionConsumable.t.updateTable),
      where: where(TransactionConsumable.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TransactionConsumable.t),
      orderByList: orderByList?.call(TransactionConsumable.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [TransactionConsumable]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<TransactionConsumable>> delete(
    _i1.Session session,
    List<TransactionConsumable> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<TransactionConsumable>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [TransactionConsumable].
  Future<TransactionConsumable> deleteRow(
    _i1.Session session,
    TransactionConsumable row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TransactionConsumable>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<TransactionConsumable>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<TransactionConsumableTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<TransactionConsumable>(
      where: where(TransactionConsumable.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TransactionConsumableTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<TransactionConsumable>(
      where: where?.call(TransactionConsumable.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
