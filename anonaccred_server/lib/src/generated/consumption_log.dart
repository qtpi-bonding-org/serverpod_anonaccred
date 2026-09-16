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
import 'package:serverpod/serverpod.dart' as _is;

abstract class ConsumptionLog
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ConsumptionLog._({
    this.id,
    required this.accountUuid,
    required this.entitlementId,
    required this.amount,
    required this.reason,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ConsumptionLog({
    int? id,
    required _is.UuidValue accountUuid,
    required int entitlementId,
    required double amount,
    required String reason,
    DateTime? timestamp,
  }) = _ConsumptionLogImpl;

  factory ConsumptionLog.fromJson(Map<String, dynamic> jsonSerialization) {
    return ConsumptionLog(
      id: jsonSerialization['id'] as int?,
      accountUuid: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountUuid'],
      ),
      entitlementId: jsonSerialization['entitlementId'] as int,
      amount: (jsonSerialization['amount'] as num).toDouble(),
      reason: jsonSerialization['reason'] as String,
      timestamp: jsonSerialization['timestamp'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['timestamp']),
    );
  }

  static final t = ConsumptionLogTable();

  static const db = ConsumptionLogRepository._();

  @override
  int? id;

  _is.UuidValue accountUuid;

  int entitlementId;

  double amount;

  String reason;

  DateTime timestamp;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ConsumptionLog]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ConsumptionLog copyWith({
    int? id,
    _is.UuidValue? accountUuid,
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
      'accountUuid': accountUuid.toJson(),
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
      'accountUuid': accountUuid.toJson(),
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
    _is.WhereExpressionBuilder<ConsumptionLogTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ConsumptionLogTable>? orderBy,
    _is.OrderByListBuilder<ConsumptionLogTable>? orderByList,
    ConsumptionLogInclude? include,
  }) {
    return ConsumptionLogIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ConsumptionLog.t),
      orderByList: orderByList?.call(ConsumptionLog.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ConsumptionLogImpl extends ConsumptionLog {
  _ConsumptionLogImpl({
    int? id,
    required _is.UuidValue accountUuid,
    required int entitlementId,
    required double amount,
    required String reason,
    DateTime? timestamp,
  }) : super._(
         id: id,
         accountUuid: accountUuid,
         entitlementId: entitlementId,
         amount: amount,
         reason: reason,
         timestamp: timestamp,
       );

  /// Returns a shallow copy of this [ConsumptionLog]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ConsumptionLog copyWith({
    Object? id = _Undefined,
    _is.UuidValue? accountUuid,
    int? entitlementId,
    double? amount,
    String? reason,
    DateTime? timestamp,
  }) {
    return ConsumptionLog(
      id: id is int? ? id : this.id,
      accountUuid: accountUuid ?? this.accountUuid,
      entitlementId: entitlementId ?? this.entitlementId,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class ConsumptionLogUpdateTable extends _is.UpdateTable<ConsumptionLogTable> {
  ConsumptionLogUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> accountUuid(
    _is.UuidValue value,
  ) => _is.ColumnValue(table.accountUuid, value);

  _is.ColumnValue<int, int> entitlementId(int value) =>
      _is.ColumnValue(table.entitlementId, value);

  _is.ColumnValue<double, double> amount(double value) =>
      _is.ColumnValue(table.amount, value);

  _is.ColumnValue<String, String> reason(String value) =>
      _is.ColumnValue(table.reason, value);

  _is.ColumnValue<DateTime, DateTime> timestamp(DateTime value) =>
      _is.ColumnValue(table.timestamp, value);
}

class ConsumptionLogTable extends _is.Table<int?> {
  ConsumptionLogTable({super.tableRelation})
    : super(tableName: 'consumption_log') {
    updateTable = ConsumptionLogUpdateTable(this);
    accountUuid = _is.ColumnUuid('accountUuid', this);
    entitlementId = _is.ColumnInt('entitlementId', this);
    amount = _is.ColumnDouble('amount', this);
    reason = _is.ColumnString('reason', this);
    timestamp = _is.ColumnDateTime('timestamp', this, hasDefault: true);
  }

  late final ConsumptionLogUpdateTable updateTable;

  late final _is.ColumnUuid accountUuid;

  late final _is.ColumnInt entitlementId;

  late final _is.ColumnDouble amount;

  late final _is.ColumnString reason;

  late final _is.ColumnDateTime timestamp;

  @override
  List<_is.Column> get columns => [
    id,
    accountUuid,
    entitlementId,
    amount,
    reason,
    timestamp,
  ];
}

class ConsumptionLogInclude extends _is.IncludeObject {
  ConsumptionLogInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ConsumptionLog.t;
}

class ConsumptionLogIncludeList extends _is.IncludeList {
  ConsumptionLogIncludeList._({
    _is.WhereExpressionBuilder<ConsumptionLogTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ConsumptionLog.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ConsumptionLog.t;
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ConsumptionLogTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ConsumptionLogTable>? orderBy,
    _is.OrderByListBuilder<ConsumptionLogTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ConsumptionLog>(
      where: where?.call(ConsumptionLog.t),
      orderBy: orderBy?.call(ConsumptionLog.t),
      orderByList: orderByList?.call(ConsumptionLog.t),
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ConsumptionLogTable>? where,
    int? offset,
    _is.OrderByBuilder<ConsumptionLogTable>? orderBy,
    _is.OrderByListBuilder<ConsumptionLogTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ConsumptionLog>(
      where: where?.call(ConsumptionLog.t),
      orderBy: orderBy?.call(ConsumptionLog.t),
      orderByList: orderByList?.call(ConsumptionLog.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ConsumptionLog] by its [id] or null if no such row exists.
  Future<ConsumptionLog?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ConsumptionLog>> insert(
    _is.DatabaseSession session,
    List<ConsumptionLog> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ConsumptionLog>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ConsumptionLog] and returns the inserted row.
  ///
  /// The returned [ConsumptionLog] will have its `id` field set.
  Future<ConsumptionLog> insertRow(
    _is.DatabaseSession session,
    ConsumptionLog row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ConsumptionLog>(row, transaction: transaction);
  }

  /// Upserts all [ConsumptionLog]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [ConsumptionLog]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ConsumptionLog>> upsert(
    _is.DatabaseSession session,
    List<ConsumptionLog> rows, {
    required _is.ColumnSelections<ConsumptionLogTable> conflictColumns,
    _is.ColumnSelections<ConsumptionLogTable>? updateColumns,
    _is.WhereExpressionBuilder<ConsumptionLogTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ConsumptionLog>(
      rows,
      conflictColumns: conflictColumns(ConsumptionLog.t),
      updateColumns: updateColumns?.call(ConsumptionLog.t),
      updateWhere: updateWhere?.call(ConsumptionLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ConsumptionLog] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [ConsumptionLog] will have its `id` field set.
  Future<ConsumptionLog?> upsertRow(
    _is.DatabaseSession session,
    ConsumptionLog row, {
    required _is.ColumnSelections<ConsumptionLogTable> conflictColumns,
    _is.ColumnSelections<ConsumptionLogTable>? updateColumns,
    _is.WhereExpressionBuilder<ConsumptionLogTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ConsumptionLog>(
      row,
      conflictColumns: conflictColumns(ConsumptionLog.t),
      updateColumns: updateColumns?.call(ConsumptionLog.t),
      updateWhere: updateWhere?.call(ConsumptionLog.t),
      transaction: transaction,
    );
  }

  /// Updates all [ConsumptionLog]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ConsumptionLog>> update(
    _is.DatabaseSession session,
    List<ConsumptionLog> rows, {
    _is.ColumnSelections<ConsumptionLogTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ConsumptionLog>(
      rows,
      columns: columns?.call(ConsumptionLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ConsumptionLog]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ConsumptionLog> updateRow(
    _is.DatabaseSession session,
    ConsumptionLog row, {
    _is.ColumnSelections<ConsumptionLogTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ConsumptionLogUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ConsumptionLog>(
      id,
      columnValues: columnValues(ConsumptionLog.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ConsumptionLog]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ConsumptionLog>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ConsumptionLogUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ConsumptionLogTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ConsumptionLogTable>? orderBy,
    _is.OrderByListBuilder<ConsumptionLogTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ConsumptionLog>(
      columnValues: columnValues(ConsumptionLog.t.updateTable),
      where: where(ConsumptionLog.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ConsumptionLog.t),
      orderByList: orderByList?.call(ConsumptionLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ConsumptionLog]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ConsumptionLog>> delete(
    _is.DatabaseSession session,
    List<ConsumptionLog> rows, {
    _is.OrderByBuilder<ConsumptionLogTable>? orderBy,
    _is.OrderByListBuilder<ConsumptionLogTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ConsumptionLog>(
      rows,
      orderBy: orderBy?.call(ConsumptionLog.t),
      orderByList: orderByList?.call(ConsumptionLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ConsumptionLog].
  Future<ConsumptionLog> deleteRow(
    _is.DatabaseSession session,
    ConsumptionLog row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ConsumptionLog>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ConsumptionLog>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ConsumptionLogTable> where,
    _is.OrderByBuilder<ConsumptionLogTable>? orderBy,
    _is.OrderByListBuilder<ConsumptionLogTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ConsumptionLog>(
      where: where(ConsumptionLog.t),
      orderBy: orderBy?.call(ConsumptionLog.t),
      orderByList: orderByList?.call(ConsumptionLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ConsumptionLogTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ConsumptionLog>(
      where: where?.call(ConsumptionLog.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ConsumptionLog] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ConsumptionLogTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ConsumptionLog>(
      where: where(ConsumptionLog.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
