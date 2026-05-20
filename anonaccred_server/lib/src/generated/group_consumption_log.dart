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

abstract class GroupConsumptionLog
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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
    required _i1.UuidValue shareGroupUuid,
    required int entitlementId,
    required double amount,
    required String reason,
    DateTime? timestamp,
    _i1.UuidValue? consumingAccountUuid,
  }) = _GroupConsumptionLogImpl;

  factory GroupConsumptionLog.fromJson(Map<String, dynamic> jsonSerialization) {
    return GroupConsumptionLog(
      id: jsonSerialization['id'] as int?,
      shareGroupUuid: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['shareGroupUuid'],
      ),
      entitlementId: jsonSerialization['entitlementId'] as int,
      amount: (jsonSerialization['amount'] as num).toDouble(),
      reason: jsonSerialization['reason'] as String,
      timestamp: jsonSerialization['timestamp'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['timestamp']),
      consumingAccountUuid: jsonSerialization['consumingAccountUuid'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['consumingAccountUuid'],
            ),
    );
  }

  static final t = GroupConsumptionLogTable();

  static const db = GroupConsumptionLogRepository._();

  @override
  int? id;

  _i1.UuidValue shareGroupUuid;

  int entitlementId;

  double amount;

  String reason;

  DateTime timestamp;

  _i1.UuidValue? consumingAccountUuid;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [GroupConsumptionLog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GroupConsumptionLog copyWith({
    int? id,
    _i1.UuidValue? shareGroupUuid,
    int? entitlementId,
    double? amount,
    String? reason,
    DateTime? timestamp,
    _i1.UuidValue? consumingAccountUuid,
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
    _i1.WhereExpressionBuilder<GroupConsumptionLogTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GroupConsumptionLogTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GroupConsumptionLogTable>? orderByList,
    GroupConsumptionLogInclude? include,
  }) {
    return GroupConsumptionLogIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupConsumptionLog.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(GroupConsumptionLog.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupConsumptionLogImpl extends GroupConsumptionLog {
  _GroupConsumptionLogImpl({
    int? id,
    required _i1.UuidValue shareGroupUuid,
    required int entitlementId,
    required double amount,
    required String reason,
    DateTime? timestamp,
    _i1.UuidValue? consumingAccountUuid,
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
  @_i1.useResult
  @override
  GroupConsumptionLog copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? shareGroupUuid,
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
      consumingAccountUuid: consumingAccountUuid is _i1.UuidValue?
          ? consumingAccountUuid
          : this.consumingAccountUuid,
    );
  }
}

class GroupConsumptionLogUpdateTable
    extends _i1.UpdateTable<GroupConsumptionLogTable> {
  GroupConsumptionLogUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> shareGroupUuid(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.shareGroupUuid,
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

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> consumingAccountUuid(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.consumingAccountUuid,
    value,
  );
}

class GroupConsumptionLogTable extends _i1.Table<int?> {
  GroupConsumptionLogTable({super.tableRelation})
    : super(tableName: 'group_consumption_log') {
    updateTable = GroupConsumptionLogUpdateTable(this);
    shareGroupUuid = _i1.ColumnUuid(
      'shareGroupUuid',
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
    consumingAccountUuid = _i1.ColumnUuid(
      'consumingAccountUuid',
      this,
    );
  }

  late final GroupConsumptionLogUpdateTable updateTable;

  late final _i1.ColumnUuid shareGroupUuid;

  late final _i1.ColumnInt entitlementId;

  late final _i1.ColumnDouble amount;

  late final _i1.ColumnString reason;

  late final _i1.ColumnDateTime timestamp;

  late final _i1.ColumnUuid consumingAccountUuid;

  @override
  List<_i1.Column> get columns => [
    id,
    shareGroupUuid,
    entitlementId,
    amount,
    reason,
    timestamp,
    consumingAccountUuid,
  ];
}

class GroupConsumptionLogInclude extends _i1.IncludeObject {
  GroupConsumptionLogInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => GroupConsumptionLog.t;
}

class GroupConsumptionLogIncludeList extends _i1.IncludeList {
  GroupConsumptionLogIncludeList._({
    _i1.WhereExpressionBuilder<GroupConsumptionLogTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GroupConsumptionLog.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => GroupConsumptionLog.t;
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GroupConsumptionLogTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GroupConsumptionLogTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GroupConsumptionLogTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GroupConsumptionLog>(
      where: where?.call(GroupConsumptionLog.t),
      orderBy: orderBy?.call(GroupConsumptionLog.t),
      orderByList: orderByList?.call(GroupConsumptionLog.t),
      orderDescending: orderDescending,
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GroupConsumptionLogTable>? where,
    int? offset,
    _i1.OrderByBuilder<GroupConsumptionLogTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GroupConsumptionLogTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GroupConsumptionLog>(
      where: where?.call(GroupConsumptionLog.t),
      orderBy: orderBy?.call(GroupConsumptionLog.t),
      orderByList: orderByList?.call(GroupConsumptionLog.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GroupConsumptionLog] by its [id] or null if no such row exists.
  Future<GroupConsumptionLog?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
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
  Future<List<GroupConsumptionLog>> insert(
    _i1.Session session,
    List<GroupConsumptionLog> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<GroupConsumptionLog>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [GroupConsumptionLog] and returns the inserted row.
  ///
  /// The returned [GroupConsumptionLog] will have its `id` field set.
  Future<GroupConsumptionLog> insertRow(
    _i1.Session session,
    GroupConsumptionLog row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<GroupConsumptionLog>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [GroupConsumptionLog]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<GroupConsumptionLog>> update(
    _i1.Session session,
    List<GroupConsumptionLog> rows, {
    _i1.ColumnSelections<GroupConsumptionLogTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<GroupConsumptionLog>(
      rows,
      columns: columns?.call(GroupConsumptionLog.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GroupConsumptionLog]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GroupConsumptionLog> updateRow(
    _i1.Session session,
    GroupConsumptionLog row, {
    _i1.ColumnSelections<GroupConsumptionLogTable>? columns,
    _i1.Transaction? transaction,
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
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<GroupConsumptionLogUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<GroupConsumptionLog>(
      id,
      columnValues: columnValues(GroupConsumptionLog.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GroupConsumptionLog]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<GroupConsumptionLog>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<GroupConsumptionLogUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<GroupConsumptionLogTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GroupConsumptionLogTable>? orderBy,
    _i1.OrderByListBuilder<GroupConsumptionLogTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<GroupConsumptionLog>(
      columnValues: columnValues(GroupConsumptionLog.t.updateTable),
      where: where(GroupConsumptionLog.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupConsumptionLog.t),
      orderByList: orderByList?.call(GroupConsumptionLog.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [GroupConsumptionLog]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<GroupConsumptionLog>> delete(
    _i1.Session session,
    List<GroupConsumptionLog> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<GroupConsumptionLog>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [GroupConsumptionLog].
  Future<GroupConsumptionLog> deleteRow(
    _i1.Session session,
    GroupConsumptionLog row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GroupConsumptionLog>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<GroupConsumptionLog>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<GroupConsumptionLogTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<GroupConsumptionLog>(
      where: where(GroupConsumptionLog.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GroupConsumptionLogTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<GroupConsumptionLog>(
      where: where?.call(GroupConsumptionLog.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GroupConsumptionLog] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<GroupConsumptionLogTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<GroupConsumptionLog>(
      where: where(GroupConsumptionLog.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
