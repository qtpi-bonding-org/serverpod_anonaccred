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

abstract class ShardRouting
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  ShardRouting._({
    this.id,
    required this.tenantId,
    required this.tenantType,
    String? shardName,
    DateTime? updatedAt,
  }) : shardName = shardName ?? 'shard_01',
       updatedAt = updatedAt ?? DateTime.now();

  factory ShardRouting({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required String tenantType,
    String? shardName,
    DateTime? updatedAt,
  }) = _ShardRoutingImpl;

  factory ShardRouting.fromJson(Map<String, dynamic> jsonSerialization) {
    return ShardRouting(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      tenantType: jsonSerialization['tenantType'] as String,
      shardName: jsonSerialization['shardName'] as String?,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = ShardRoutingTable();

  static const db = ShardRoutingRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue tenantId;

  String tenantType;

  String shardName;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [ShardRouting]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ShardRouting copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    String? tenantType,
    String? shardName,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.ShardRouting',
      if (id != null) 'id': id?.toJson(),
      'tenantId': tenantId.toJson(),
      'tenantType': tenantType,
      'shardName': shardName,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.ShardRouting',
      if (id != null) 'id': id?.toJson(),
      'tenantId': tenantId.toJson(),
      'tenantType': tenantType,
      'shardName': shardName,
      'updatedAt': updatedAt.toJson(),
    };
  }

  static ShardRoutingInclude include() {
    return ShardRoutingInclude._();
  }

  static ShardRoutingIncludeList includeList({
    _is.WhereExpressionBuilder<ShardRoutingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ShardRoutingTable>? orderBy,
    _is.OrderByListBuilder<ShardRoutingTable>? orderByList,
    ShardRoutingInclude? include,
  }) {
    return ShardRoutingIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ShardRouting.t),
      orderByList: orderByList?.call(ShardRouting.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ShardRoutingImpl extends ShardRouting {
  _ShardRoutingImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required String tenantType,
    String? shardName,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         tenantId: tenantId,
         tenantType: tenantType,
         shardName: shardName,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [ShardRouting]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ShardRouting copyWith({
    Object? id = _Undefined,
    _is.UuidValue? tenantId,
    String? tenantType,
    String? shardName,
    DateTime? updatedAt,
  }) {
    return ShardRouting(
      id: id is _is.UuidValue? ? id : this.id,
      tenantId: tenantId ?? this.tenantId,
      tenantType: tenantType ?? this.tenantType,
      shardName: shardName ?? this.shardName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ShardRoutingUpdateTable extends _is.UpdateTable<ShardRoutingTable> {
  ShardRoutingUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(table.tenantId, value);

  _is.ColumnValue<String, String> tenantType(String value) =>
      _is.ColumnValue(table.tenantType, value);

  _is.ColumnValue<String, String> shardName(String value) =>
      _is.ColumnValue(table.shardName, value);

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(table.updatedAt, value);
}

class ShardRoutingTable extends _is.Table<_is.UuidValue?> {
  ShardRoutingTable({super.tableRelation}) : super(tableName: 'shard_routing') {
    updateTable = ShardRoutingUpdateTable(this);
    tenantId = _is.ColumnUuid('tenantId', this);
    tenantType = _is.ColumnString('tenantType', this);
    shardName = _is.ColumnString('shardName', this, hasDefault: true);
    updatedAt = _is.ColumnDateTime('updatedAt', this, hasDefault: true);
  }

  late final ShardRoutingUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnString tenantType;

  late final _is.ColumnString shardName;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    tenantId,
    tenantType,
    shardName,
    updatedAt,
  ];
}

class ShardRoutingInclude extends _is.IncludeObject {
  ShardRoutingInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => ShardRouting.t;
}

class ShardRoutingIncludeList extends _is.IncludeList {
  ShardRoutingIncludeList._({
    _is.WhereExpressionBuilder<ShardRoutingTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ShardRouting.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => ShardRouting.t;
}

class ShardRoutingRepository {
  const ShardRoutingRepository._();

  /// Returns a list of [ShardRouting]s matching the given query parameters.
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
  Future<List<ShardRouting>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ShardRoutingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ShardRoutingTable>? orderBy,
    _is.OrderByListBuilder<ShardRoutingTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ShardRouting>(
      where: where?.call(ShardRouting.t),
      orderBy: orderBy?.call(ShardRouting.t),
      orderByList: orderByList?.call(ShardRouting.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ShardRouting] matching the given query parameters.
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
  Future<ShardRouting?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ShardRoutingTable>? where,
    int? offset,
    _is.OrderByBuilder<ShardRoutingTable>? orderBy,
    _is.OrderByListBuilder<ShardRoutingTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ShardRouting>(
      where: where?.call(ShardRouting.t),
      orderBy: orderBy?.call(ShardRouting.t),
      orderByList: orderByList?.call(ShardRouting.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ShardRouting] by its [id] or null if no such row exists.
  Future<ShardRouting?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ShardRouting>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ShardRouting]s in the list and returns the inserted rows.
  ///
  /// The returned [ShardRouting]s will have their `id` fields set.
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
  Future<List<ShardRouting>> insert(
    _is.DatabaseSession session,
    List<ShardRouting> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ShardRouting>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ShardRouting] and returns the inserted row.
  ///
  /// The returned [ShardRouting] will have its `id` field set.
  Future<ShardRouting> insertRow(
    _is.DatabaseSession session,
    ShardRouting row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ShardRouting>(row, transaction: transaction);
  }

  /// Upserts all [ShardRouting]s in the list and returns the resulting rows.
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
  /// The returned [ShardRouting]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ShardRouting>> upsert(
    _is.DatabaseSession session,
    List<ShardRouting> rows, {
    required _is.ColumnSelections<ShardRoutingTable> conflictColumns,
    _is.ColumnSelections<ShardRoutingTable>? updateColumns,
    _is.WhereExpressionBuilder<ShardRoutingTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ShardRouting>(
      rows,
      conflictColumns: conflictColumns(ShardRouting.t),
      updateColumns: updateColumns?.call(ShardRouting.t),
      updateWhere: updateWhere?.call(ShardRouting.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ShardRouting] and returns the resulting row.
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
  /// The returned [ShardRouting] will have its `id` field set.
  Future<ShardRouting?> upsertRow(
    _is.DatabaseSession session,
    ShardRouting row, {
    required _is.ColumnSelections<ShardRoutingTable> conflictColumns,
    _is.ColumnSelections<ShardRoutingTable>? updateColumns,
    _is.WhereExpressionBuilder<ShardRoutingTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ShardRouting>(
      row,
      conflictColumns: conflictColumns(ShardRouting.t),
      updateColumns: updateColumns?.call(ShardRouting.t),
      updateWhere: updateWhere?.call(ShardRouting.t),
      transaction: transaction,
    );
  }

  /// Updates all [ShardRouting]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ShardRouting>> update(
    _is.DatabaseSession session,
    List<ShardRouting> rows, {
    _is.ColumnSelections<ShardRoutingTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ShardRouting>(
      rows,
      columns: columns?.call(ShardRouting.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ShardRouting]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ShardRouting> updateRow(
    _is.DatabaseSession session,
    ShardRouting row, {
    _is.ColumnSelections<ShardRoutingTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ShardRouting>(
      row,
      columns: columns?.call(ShardRouting.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ShardRouting] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ShardRouting?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<ShardRoutingUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ShardRouting>(
      id,
      columnValues: columnValues(ShardRouting.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ShardRouting]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ShardRouting>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ShardRoutingUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ShardRoutingTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ShardRoutingTable>? orderBy,
    _is.OrderByListBuilder<ShardRoutingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ShardRouting>(
      columnValues: columnValues(ShardRouting.t.updateTable),
      where: where(ShardRouting.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ShardRouting.t),
      orderByList: orderByList?.call(ShardRouting.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ShardRouting]s in the list and returns the deleted rows.
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
  Future<List<ShardRouting>> delete(
    _is.DatabaseSession session,
    List<ShardRouting> rows, {
    _is.OrderByBuilder<ShardRoutingTable>? orderBy,
    _is.OrderByListBuilder<ShardRoutingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ShardRouting>(
      rows,
      orderBy: orderBy?.call(ShardRouting.t),
      orderByList: orderByList?.call(ShardRouting.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ShardRouting].
  Future<ShardRouting> deleteRow(
    _is.DatabaseSession session,
    ShardRouting row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ShardRouting>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ShardRouting>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ShardRoutingTable> where,
    _is.OrderByBuilder<ShardRoutingTable>? orderBy,
    _is.OrderByListBuilder<ShardRoutingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ShardRouting>(
      where: where(ShardRouting.t),
      orderBy: orderBy?.call(ShardRouting.t),
      orderByList: orderByList?.call(ShardRouting.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ShardRoutingTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ShardRouting>(
      where: where?.call(ShardRouting.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ShardRouting] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ShardRoutingTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ShardRouting>(
      where: where(ShardRouting.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
