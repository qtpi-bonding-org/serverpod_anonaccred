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

abstract class GroupConsumptionLog
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  GroupConsumptionLog._({
    this.id,
    required this.shareGroupUuid,
    required this.entitlementId,
    required this.amount,
    required this.reason,
    DateTime? timestamp,
    this.consumingAccountUuid,
  }) : timestamp = timestamp ?? DateTime.now();

  factory GroupConsumptionLog({
    int? id,
    required _is.UuidValue shareGroupUuid,
    required int entitlementId,
    required double amount,
    required String reason,
    DateTime? timestamp,
    _is.UuidValue? consumingAccountUuid,
  }) = _GroupConsumptionLogImpl;

  factory GroupConsumptionLog.fromJson(Map<String, dynamic> jsonSerialization) {
    return GroupConsumptionLog(
      id: jsonSerialization['id'] as int?,
      shareGroupUuid: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['shareGroupUuid'],
      ),
      entitlementId: jsonSerialization['entitlementId'] as int,
      amount: (jsonSerialization['amount'] as num).toDouble(),
      reason: jsonSerialization['reason'] as String,
      timestamp: jsonSerialization['timestamp'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['timestamp']),
      consumingAccountUuid: jsonSerialization['consumingAccountUuid'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['consumingAccountUuid'],
            ),
    );
  }

  static final t = GroupConsumptionLogTable();

  static const db = GroupConsumptionLogRepository._();

  @override
  int? id;

  _is.UuidValue shareGroupUuid;

  int entitlementId;

  double amount;

  String reason;

  DateTime timestamp;

  _is.UuidValue? consumingAccountUuid;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [GroupConsumptionLog]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  GroupConsumptionLog copyWith({
    int? id,
    _is.UuidValue? shareGroupUuid,
    int? entitlementId,
    double? amount,
    String? reason,
    DateTime? timestamp,
    _is.UuidValue? consumingAccountUuid,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.GroupConsumptionLog',
      if (id != null) 'id': id,
      'shareGroupUuid': shareGroupUuid.toJson(),
      'entitlementId': entitlementId,
      'amount': amount,
      'reason': reason,
      'timestamp': timestamp.toJson(),
      if (consumingAccountUuid != null)
        'consumingAccountUuid': consumingAccountUuid?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.GroupConsumptionLog',
      if (id != null) 'id': id,
      'shareGroupUuid': shareGroupUuid.toJson(),
      'entitlementId': entitlementId,
      'amount': amount,
      'reason': reason,
      'timestamp': timestamp.toJson(),
      if (consumingAccountUuid != null)
        'consumingAccountUuid': consumingAccountUuid?.toJson(),
    };
  }

  static GroupConsumptionLogInclude include() {
    return GroupConsumptionLogInclude._();
  }

  static GroupConsumptionLogIncludeList includeList({
    _is.WhereExpressionBuilder<GroupConsumptionLogTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupConsumptionLogTable>? orderBy,
    _is.OrderByListBuilder<GroupConsumptionLogTable>? orderByList,
    GroupConsumptionLogInclude? include,
  }) {
    return GroupConsumptionLogIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupConsumptionLog.t),
      orderByList: orderByList?.call(GroupConsumptionLog.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupConsumptionLogImpl extends GroupConsumptionLog {
  _GroupConsumptionLogImpl({
    int? id,
    required _is.UuidValue shareGroupUuid,
    required int entitlementId,
    required double amount,
    required String reason,
    DateTime? timestamp,
    _is.UuidValue? consumingAccountUuid,
  }) : super._(
         id: id,
         shareGroupUuid: shareGroupUuid,
         entitlementId: entitlementId,
         amount: amount,
         reason: reason,
         timestamp: timestamp,
         consumingAccountUuid: consumingAccountUuid,
       );

  /// Returns a shallow copy of this [GroupConsumptionLog]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  GroupConsumptionLog copyWith({
    Object? id = _Undefined,
    _is.UuidValue? shareGroupUuid,
    int? entitlementId,
    double? amount,
    String? reason,
    DateTime? timestamp,
    Object? consumingAccountUuid = _Undefined,
  }) {
    return GroupConsumptionLog(
      id: id is int? ? id : this.id,
      shareGroupUuid: shareGroupUuid ?? this.shareGroupUuid,
      entitlementId: entitlementId ?? this.entitlementId,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
      consumingAccountUuid: consumingAccountUuid is _is.UuidValue?
          ? consumingAccountUuid
          : this.consumingAccountUuid,
    );
  }
}

class GroupConsumptionLogUpdateTable
    extends _is.UpdateTable<GroupConsumptionLogTable> {
  GroupConsumptionLogUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> shareGroupUuid(
    _is.UuidValue value,
  ) => _is.ColumnValue(table.shareGroupUuid, value);

  _is.ColumnValue<int, int> entitlementId(int value) =>
      _is.ColumnValue(table.entitlementId, value);

  _is.ColumnValue<double, double> amount(double value) =>
      _is.ColumnValue(table.amount, value);

  _is.ColumnValue<String, String> reason(String value) =>
      _is.ColumnValue(table.reason, value);

  _is.ColumnValue<DateTime, DateTime> timestamp(DateTime value) =>
      _is.ColumnValue(table.timestamp, value);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> consumingAccountUuid(
    _is.UuidValue? value,
  ) => _is.ColumnValue(table.consumingAccountUuid, value);
}

class GroupConsumptionLogTable extends _is.Table<int?> {
  GroupConsumptionLogTable({super.tableRelation})
    : super(tableName: 'group_consumption_log') {
    updateTable = GroupConsumptionLogUpdateTable(this);
    shareGroupUuid = _is.ColumnUuid('shareGroupUuid', this);
    entitlementId = _is.ColumnInt('entitlementId', this);
    amount = _is.ColumnDouble('amount', this);
    reason = _is.ColumnString('reason', this);
    timestamp = _is.ColumnDateTime('timestamp', this, hasDefault: true);
    consumingAccountUuid = _is.ColumnUuid('consumingAccountUuid', this);
  }

  late final GroupConsumptionLogUpdateTable updateTable;

  late final _is.ColumnUuid shareGroupUuid;

  late final _is.ColumnInt entitlementId;

  late final _is.ColumnDouble amount;

  late final _is.ColumnString reason;

  late final _is.ColumnDateTime timestamp;

  late final _is.ColumnUuid consumingAccountUuid;

  @override
  List<_is.Column> get columns => [
    id,
    shareGroupUuid,
    entitlementId,
    amount,
    reason,
    timestamp,
    consumingAccountUuid,
  ];
}

class GroupConsumptionLogInclude extends _is.IncludeObject {
  GroupConsumptionLogInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => GroupConsumptionLog.t;
}

class GroupConsumptionLogIncludeList extends _is.IncludeList {
  GroupConsumptionLogIncludeList._({
    _is.WhereExpressionBuilder<GroupConsumptionLogTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GroupConsumptionLog.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => GroupConsumptionLog.t;
}

class GroupConsumptionLogRepository {
  const GroupConsumptionLogRepository._();

  /// Returns a list of [GroupConsumptionLog]s matching the given query parameters.
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
  Future<List<GroupConsumptionLog>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupConsumptionLogTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupConsumptionLogTable>? orderBy,
    _is.OrderByListBuilder<GroupConsumptionLogTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GroupConsumptionLog>(
      where: where?.call(GroupConsumptionLog.t),
      orderBy: orderBy?.call(GroupConsumptionLog.t),
      orderByList: orderByList?.call(GroupConsumptionLog.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [GroupConsumptionLog] matching the given query parameters.
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
  Future<GroupConsumptionLog?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupConsumptionLogTable>? where,
    int? offset,
    _is.OrderByBuilder<GroupConsumptionLogTable>? orderBy,
    _is.OrderByListBuilder<GroupConsumptionLogTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GroupConsumptionLog>(
      where: where?.call(GroupConsumptionLog.t),
      orderBy: orderBy?.call(GroupConsumptionLog.t),
      orderByList: orderByList?.call(GroupConsumptionLog.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GroupConsumptionLog] by its [id] or null if no such row exists.
  Future<GroupConsumptionLog?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<GroupConsumptionLog>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [GroupConsumptionLog]s in the list and returns the inserted rows.
  ///
  /// The returned [GroupConsumptionLog]s will have their `id` fields set.
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
  Future<List<GroupConsumptionLog>> insert(
    _is.DatabaseSession session,
    List<GroupConsumptionLog> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<GroupConsumptionLog>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [GroupConsumptionLog] and returns the inserted row.
  ///
  /// The returned [GroupConsumptionLog] will have its `id` field set.
  Future<GroupConsumptionLog> insertRow(
    _is.DatabaseSession session,
    GroupConsumptionLog row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<GroupConsumptionLog>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [GroupConsumptionLog]s in the list and returns the resulting rows.
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
  /// The returned [GroupConsumptionLog]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupConsumptionLog>> upsert(
    _is.DatabaseSession session,
    List<GroupConsumptionLog> rows, {
    required _is.ColumnSelections<GroupConsumptionLogTable> conflictColumns,
    _is.ColumnSelections<GroupConsumptionLogTable>? updateColumns,
    _is.WhereExpressionBuilder<GroupConsumptionLogTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<GroupConsumptionLog>(
      rows,
      conflictColumns: conflictColumns(GroupConsumptionLog.t),
      updateColumns: updateColumns?.call(GroupConsumptionLog.t),
      updateWhere: updateWhere?.call(GroupConsumptionLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [GroupConsumptionLog] and returns the resulting row.
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
  /// The returned [GroupConsumptionLog] will have its `id` field set.
  Future<GroupConsumptionLog?> upsertRow(
    _is.DatabaseSession session,
    GroupConsumptionLog row, {
    required _is.ColumnSelections<GroupConsumptionLogTable> conflictColumns,
    _is.ColumnSelections<GroupConsumptionLogTable>? updateColumns,
    _is.WhereExpressionBuilder<GroupConsumptionLogTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<GroupConsumptionLog>(
      row,
      conflictColumns: conflictColumns(GroupConsumptionLog.t),
      updateColumns: updateColumns?.call(GroupConsumptionLog.t),
      updateWhere: updateWhere?.call(GroupConsumptionLog.t),
      transaction: transaction,
    );
  }

  /// Updates all [GroupConsumptionLog]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupConsumptionLog>> update(
    _is.DatabaseSession session,
    List<GroupConsumptionLog> rows, {
    _is.ColumnSelections<GroupConsumptionLogTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<GroupConsumptionLog>(
      rows,
      columns: columns?.call(GroupConsumptionLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [GroupConsumptionLog]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GroupConsumptionLog> updateRow(
    _is.DatabaseSession session,
    GroupConsumptionLog row, {
    _is.ColumnSelections<GroupConsumptionLogTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<GroupConsumptionLog>(
      row,
      columns: columns?.call(GroupConsumptionLog.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GroupConsumptionLog] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<GroupConsumptionLog?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<GroupConsumptionLogUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<GroupConsumptionLog>(
      id,
      columnValues: columnValues(GroupConsumptionLog.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GroupConsumptionLog]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupConsumptionLog>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<GroupConsumptionLogUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<GroupConsumptionLogTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupConsumptionLogTable>? orderBy,
    _is.OrderByListBuilder<GroupConsumptionLogTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<GroupConsumptionLog>(
      columnValues: columnValues(GroupConsumptionLog.t.updateTable),
      where: where(GroupConsumptionLog.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupConsumptionLog.t),
      orderByList: orderByList?.call(GroupConsumptionLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [GroupConsumptionLog]s in the list and returns the deleted rows.
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
  Future<List<GroupConsumptionLog>> delete(
    _is.DatabaseSession session,
    List<GroupConsumptionLog> rows, {
    _is.OrderByBuilder<GroupConsumptionLogTable>? orderBy,
    _is.OrderByListBuilder<GroupConsumptionLogTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<GroupConsumptionLog>(
      rows,
      orderBy: orderBy?.call(GroupConsumptionLog.t),
      orderByList: orderByList?.call(GroupConsumptionLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [GroupConsumptionLog].
  Future<GroupConsumptionLog> deleteRow(
    _is.DatabaseSession session,
    GroupConsumptionLog row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GroupConsumptionLog>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupConsumptionLog>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GroupConsumptionLogTable> where,
    _is.OrderByBuilder<GroupConsumptionLogTable>? orderBy,
    _is.OrderByListBuilder<GroupConsumptionLogTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<GroupConsumptionLog>(
      where: where(GroupConsumptionLog.t),
      orderBy: orderBy?.call(GroupConsumptionLog.t),
      orderByList: orderByList?.call(GroupConsumptionLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupConsumptionLogTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<GroupConsumptionLog>(
      where: where?.call(GroupConsumptionLog.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GroupConsumptionLog] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GroupConsumptionLogTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<GroupConsumptionLog>(
      where: where(GroupConsumptionLog.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
