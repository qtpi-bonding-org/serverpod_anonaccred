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

abstract class ConsumptionLog
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ConsumptionLog._({
    this.id,
    required this.accountId,
    required this.entitlementId,
    required this.amount,
    required this.reason,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ConsumptionLog({
    int? id,
    required int accountId,
    required int entitlementId,
    required double amount,
    required String reason,
    DateTime? timestamp,
  }) = _ConsumptionLogImpl;

  factory ConsumptionLog.fromJson(Map<String, dynamic> jsonSerialization) {
    return ConsumptionLog(
      id: jsonSerialization['id'] as int?,
      accountId: jsonSerialization['accountId'] as int,
      entitlementId: jsonSerialization['entitlementId'] as int,
      amount: (jsonSerialization['amount'] as num).toDouble(),
      reason: jsonSerialization['reason'] as String,
      timestamp: jsonSerialization['timestamp'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['timestamp']),
    );
  }

  static final t = ConsumptionLogTable();

  static const db = ConsumptionLogRepository._();

  @override
  int? id;

  int accountId;

  int entitlementId;

  double amount;

  String reason;

  DateTime timestamp;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ConsumptionLog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ConsumptionLog copyWith({
    int? id,
    int? accountId,
    int? entitlementId,
    double? amount,
    String? reason,
    DateTime? timestamp,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.ConsumptionLog',
      if (id != null) 'id': id,
      'accountId': accountId,
      'entitlementId': entitlementId,
      'amount': amount,
      'reason': reason,
      'timestamp': timestamp.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.ConsumptionLog',
      if (id != null) 'id': id,
      'accountId': accountId,
      'entitlementId': entitlementId,
      'amount': amount,
      'reason': reason,
      'timestamp': timestamp.toJson(),
    };
  }

  static ConsumptionLogInclude include() {
    return ConsumptionLogInclude._();
  }

  static ConsumptionLogIncludeList includeList({
    _i1.WhereExpressionBuilder<ConsumptionLogTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ConsumptionLogTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ConsumptionLogTable>? orderByList,
    ConsumptionLogInclude? include,
  }) {
    return ConsumptionLogIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ConsumptionLog.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ConsumptionLog.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ConsumptionLogImpl extends ConsumptionLog {
  _ConsumptionLogImpl({
    int? id,
    required int accountId,
    required int entitlementId,
    required double amount,
    required String reason,
    DateTime? timestamp,
  }) : super._(
         id: id,
         accountId: accountId,
         entitlementId: entitlementId,
         amount: amount,
         reason: reason,
         timestamp: timestamp,
       );

  /// Returns a shallow copy of this [ConsumptionLog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ConsumptionLog copyWith({
    Object? id = _Undefined,
    int? accountId,
    int? entitlementId,
    double? amount,
    String? reason,
    DateTime? timestamp,
  }) {
    return ConsumptionLog(
      id: id is int? ? id : this.id,
      accountId: accountId ?? this.accountId,
      entitlementId: entitlementId ?? this.entitlementId,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class ConsumptionLogUpdateTable extends _i1.UpdateTable<ConsumptionLogTable> {
  ConsumptionLogUpdateTable(super.table);

  _i1.ColumnValue<int, int> accountId(int value) => _i1.ColumnValue(
    table.accountId,
    value,
  );

  _i1.ColumnValue<int, int> entitlementId(int value) => _i1.ColumnValue(
    table.entitlementId,
    value,
  );

  _i1.ColumnValue<double, double> amount(double value) => _i1.ColumnValue(
    table.amount,
    value,
  );

  _i1.ColumnValue<String, String> reason(String value) => _i1.ColumnValue(
    table.reason,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> timestamp(DateTime value) =>
      _i1.ColumnValue(
        table.timestamp,
        value,
      );
}

class ConsumptionLogTable extends _i1.Table<int?> {
  ConsumptionLogTable({super.tableRelation})
    : super(tableName: 'consumption_log') {
    updateTable = ConsumptionLogUpdateTable(this);
    accountId = _i1.ColumnInt(
      'accountId',
      this,
    );
    entitlementId = _i1.ColumnInt(
      'entitlementId',
      this,
    );
    amount = _i1.ColumnDouble(
      'amount',
      this,
    );
    reason = _i1.ColumnString(
      'reason',
      this,
    );
    timestamp = _i1.ColumnDateTime(
      'timestamp',
      this,
      hasDefault: true,
    );
  }

  late final ConsumptionLogUpdateTable updateTable;

  late final _i1.ColumnInt accountId;

  late final _i1.ColumnInt entitlementId;

  late final _i1.ColumnDouble amount;

  late final _i1.ColumnString reason;

  late final _i1.ColumnDateTime timestamp;

  @override
  List<_i1.Column> get columns => [
    id,
    accountId,
    entitlementId,
    amount,
    reason,
    timestamp,
  ];
}

class ConsumptionLogInclude extends _i1.IncludeObject {
  ConsumptionLogInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ConsumptionLog.t;
}

class ConsumptionLogIncludeList extends _i1.IncludeList {
  ConsumptionLogIncludeList._({
    _i1.WhereExpressionBuilder<ConsumptionLogTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ConsumptionLog.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ConsumptionLog.t;
}

class ConsumptionLogRepository {
  const ConsumptionLogRepository._();

  /// Returns a list of [ConsumptionLog]s matching the given query parameters.
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
  Future<List<ConsumptionLog>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ConsumptionLogTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ConsumptionLogTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ConsumptionLogTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ConsumptionLog>(
      where: where?.call(ConsumptionLog.t),
      orderBy: orderBy?.call(ConsumptionLog.t),
      orderByList: orderByList?.call(ConsumptionLog.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ConsumptionLog] matching the given query parameters.
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
  Future<ConsumptionLog?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ConsumptionLogTable>? where,
    int? offset,
    _i1.OrderByBuilder<ConsumptionLogTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ConsumptionLogTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ConsumptionLog>(
      where: where?.call(ConsumptionLog.t),
      orderBy: orderBy?.call(ConsumptionLog.t),
      orderByList: orderByList?.call(ConsumptionLog.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ConsumptionLog] by its [id] or null if no such row exists.
  Future<ConsumptionLog?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ConsumptionLog>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ConsumptionLog]s in the list and returns the inserted rows.
  ///
  /// The returned [ConsumptionLog]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ConsumptionLog>> insert(
    _i1.Session session,
    List<ConsumptionLog> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ConsumptionLog>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ConsumptionLog] and returns the inserted row.
  ///
  /// The returned [ConsumptionLog] will have its `id` field set.
  Future<ConsumptionLog> insertRow(
    _i1.Session session,
    ConsumptionLog row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ConsumptionLog>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ConsumptionLog]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ConsumptionLog>> update(
    _i1.Session session,
    List<ConsumptionLog> rows, {
    _i1.ColumnSelections<ConsumptionLogTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ConsumptionLog>(
      rows,
      columns: columns?.call(ConsumptionLog.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ConsumptionLog]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ConsumptionLog> updateRow(
    _i1.Session session,
    ConsumptionLog row, {
    _i1.ColumnSelections<ConsumptionLogTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ConsumptionLog>(
      row,
      columns: columns?.call(ConsumptionLog.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ConsumptionLog] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ConsumptionLog?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<ConsumptionLogUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ConsumptionLog>(
      id,
      columnValues: columnValues(ConsumptionLog.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ConsumptionLog]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ConsumptionLog>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<ConsumptionLogUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ConsumptionLogTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ConsumptionLogTable>? orderBy,
    _i1.OrderByListBuilder<ConsumptionLogTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ConsumptionLog>(
      columnValues: columnValues(ConsumptionLog.t.updateTable),
      where: where(ConsumptionLog.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ConsumptionLog.t),
      orderByList: orderByList?.call(ConsumptionLog.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ConsumptionLog]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ConsumptionLog>> delete(
    _i1.Session session,
    List<ConsumptionLog> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ConsumptionLog>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ConsumptionLog].
  Future<ConsumptionLog> deleteRow(
    _i1.Session session,
    ConsumptionLog row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ConsumptionLog>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ConsumptionLog>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ConsumptionLogTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ConsumptionLog>(
      where: where(ConsumptionLog.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ConsumptionLogTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ConsumptionLog>(
      where: where?.call(ConsumptionLog.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ConsumptionLog] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ConsumptionLogTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ConsumptionLog>(
      where: where(ConsumptionLog.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
