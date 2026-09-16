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

abstract class EphemeralAccreditationGroup
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  EphemeralAccreditationGroup._({
    this.id,
    required this.accountUuid,
    required this.shareGroupUuid,
    required this.transactionTimestamp,
  });

  factory EphemeralAccreditationGroup({
    int? id,
    required _is.UuidValue accountUuid,
    required _is.UuidValue shareGroupUuid,
    required DateTime transactionTimestamp,
  }) = _EphemeralAccreditationGroupImpl;

  factory EphemeralAccreditationGroup.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return EphemeralAccreditationGroup(
      id: jsonSerialization['id'] as int?,
      accountUuid: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountUuid'],
      ),
      shareGroupUuid: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['shareGroupUuid'],
      ),
      transactionTimestamp: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['transactionTimestamp'],
      ),
    );
  }

  static final t = EphemeralAccreditationGroupTable();

  static const db = EphemeralAccreditationGroupRepository._();

  @override
  int? id;

  _is.UuidValue accountUuid;

  _is.UuidValue shareGroupUuid;

  DateTime transactionTimestamp;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [EphemeralAccreditationGroup]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  EphemeralAccreditationGroup copyWith({
    int? id,
    _is.UuidValue? accountUuid,
    _is.UuidValue? shareGroupUuid,
    DateTime? transactionTimestamp,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.EphemeralAccreditationGroup',
      if (id != null) 'id': id,
      'accountUuid': accountUuid.toJson(),
      'shareGroupUuid': shareGroupUuid.toJson(),
      'transactionTimestamp': transactionTimestamp.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.EphemeralAccreditationGroup',
      if (id != null) 'id': id,
      'accountUuid': accountUuid.toJson(),
      'shareGroupUuid': shareGroupUuid.toJson(),
      'transactionTimestamp': transactionTimestamp.toJson(),
    };
  }

  static EphemeralAccreditationGroupInclude include() {
    return EphemeralAccreditationGroupInclude._();
  }

  static EphemeralAccreditationGroupIncludeList includeList({
    _is.WhereExpressionBuilder<EphemeralAccreditationGroupTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EphemeralAccreditationGroupTable>? orderBy,
    _is.OrderByListBuilder<EphemeralAccreditationGroupTable>? orderByList,
    EphemeralAccreditationGroupInclude? include,
  }) {
    return EphemeralAccreditationGroupIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EphemeralAccreditationGroup.t),
      orderByList: orderByList?.call(EphemeralAccreditationGroup.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EphemeralAccreditationGroupImpl extends EphemeralAccreditationGroup {
  _EphemeralAccreditationGroupImpl({
    int? id,
    required _is.UuidValue accountUuid,
    required _is.UuidValue shareGroupUuid,
    required DateTime transactionTimestamp,
  }) : super._(
         id: id,
         accountUuid: accountUuid,
         shareGroupUuid: shareGroupUuid,
         transactionTimestamp: transactionTimestamp,
       );

  /// Returns a shallow copy of this [EphemeralAccreditationGroup]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  EphemeralAccreditationGroup copyWith({
    Object? id = _Undefined,
    _is.UuidValue? accountUuid,
    _is.UuidValue? shareGroupUuid,
    DateTime? transactionTimestamp,
  }) {
    return EphemeralAccreditationGroup(
      id: id is int? ? id : this.id,
      accountUuid: accountUuid ?? this.accountUuid,
      shareGroupUuid: shareGroupUuid ?? this.shareGroupUuid,
      transactionTimestamp: transactionTimestamp ?? this.transactionTimestamp,
    );
  }
}

class EphemeralAccreditationGroupUpdateTable
    extends _is.UpdateTable<EphemeralAccreditationGroupTable> {
  EphemeralAccreditationGroupUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> accountUuid(
    _is.UuidValue value,
  ) => _is.ColumnValue(table.accountUuid, value);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> shareGroupUuid(
    _is.UuidValue value,
  ) => _is.ColumnValue(table.shareGroupUuid, value);

  _is.ColumnValue<DateTime, DateTime> transactionTimestamp(DateTime value) =>
      _is.ColumnValue(table.transactionTimestamp, value);
}

class EphemeralAccreditationGroupTable extends _is.Table<int?> {
  EphemeralAccreditationGroupTable({super.tableRelation})
    : super(tableName: 'ephemeral_accreditation_group') {
    updateTable = EphemeralAccreditationGroupUpdateTable(this);
    accountUuid = _is.ColumnUuid('accountUuid', this);
    shareGroupUuid = _is.ColumnUuid('shareGroupUuid', this);
    transactionTimestamp = _is.ColumnDateTime('transactionTimestamp', this);
  }

  late final EphemeralAccreditationGroupUpdateTable updateTable;

  late final _is.ColumnUuid accountUuid;

  late final _is.ColumnUuid shareGroupUuid;

  late final _is.ColumnDateTime transactionTimestamp;

  @override
  List<_is.Column> get columns => [
    id,
    accountUuid,
    shareGroupUuid,
    transactionTimestamp,
  ];
}

class EphemeralAccreditationGroupInclude extends _is.IncludeObject {
  EphemeralAccreditationGroupInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => EphemeralAccreditationGroup.t;
}

class EphemeralAccreditationGroupIncludeList extends _is.IncludeList {
  EphemeralAccreditationGroupIncludeList._({
    _is.WhereExpressionBuilder<EphemeralAccreditationGroupTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(EphemeralAccreditationGroup.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => EphemeralAccreditationGroup.t;
}

class EphemeralAccreditationGroupRepository {
  const EphemeralAccreditationGroupRepository._();

  /// Returns a list of [EphemeralAccreditationGroup]s matching the given query parameters.
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
  Future<List<EphemeralAccreditationGroup>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EphemeralAccreditationGroupTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EphemeralAccreditationGroupTable>? orderBy,
    _is.OrderByListBuilder<EphemeralAccreditationGroupTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<EphemeralAccreditationGroup>(
      where: where?.call(EphemeralAccreditationGroup.t),
      orderBy: orderBy?.call(EphemeralAccreditationGroup.t),
      orderByList: orderByList?.call(EphemeralAccreditationGroup.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [EphemeralAccreditationGroup] matching the given query parameters.
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
  Future<EphemeralAccreditationGroup?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EphemeralAccreditationGroupTable>? where,
    int? offset,
    _is.OrderByBuilder<EphemeralAccreditationGroupTable>? orderBy,
    _is.OrderByListBuilder<EphemeralAccreditationGroupTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<EphemeralAccreditationGroup>(
      where: where?.call(EphemeralAccreditationGroup.t),
      orderBy: orderBy?.call(EphemeralAccreditationGroup.t),
      orderByList: orderByList?.call(EphemeralAccreditationGroup.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [EphemeralAccreditationGroup] by its [id] or null if no such row exists.
  Future<EphemeralAccreditationGroup?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<EphemeralAccreditationGroup>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [EphemeralAccreditationGroup]s in the list and returns the inserted rows.
  ///
  /// The returned [EphemeralAccreditationGroup]s will have their `id` fields set.
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
  Future<List<EphemeralAccreditationGroup>> insert(
    _is.DatabaseSession session,
    List<EphemeralAccreditationGroup> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<EphemeralAccreditationGroup>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [EphemeralAccreditationGroup] and returns the inserted row.
  ///
  /// The returned [EphemeralAccreditationGroup] will have its `id` field set.
  Future<EphemeralAccreditationGroup> insertRow(
    _is.DatabaseSession session,
    EphemeralAccreditationGroup row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<EphemeralAccreditationGroup>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [EphemeralAccreditationGroup]s in the list and returns the resulting rows.
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
  /// The returned [EphemeralAccreditationGroup]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EphemeralAccreditationGroup>> upsert(
    _is.DatabaseSession session,
    List<EphemeralAccreditationGroup> rows, {
    required _is.ColumnSelections<EphemeralAccreditationGroupTable>
    conflictColumns,
    _is.ColumnSelections<EphemeralAccreditationGroupTable>? updateColumns,
    _is.WhereExpressionBuilder<EphemeralAccreditationGroupTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<EphemeralAccreditationGroup>(
      rows,
      conflictColumns: conflictColumns(EphemeralAccreditationGroup.t),
      updateColumns: updateColumns?.call(EphemeralAccreditationGroup.t),
      updateWhere: updateWhere?.call(EphemeralAccreditationGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [EphemeralAccreditationGroup] and returns the resulting row.
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
  /// The returned [EphemeralAccreditationGroup] will have its `id` field set.
  Future<EphemeralAccreditationGroup?> upsertRow(
    _is.DatabaseSession session,
    EphemeralAccreditationGroup row, {
    required _is.ColumnSelections<EphemeralAccreditationGroupTable>
    conflictColumns,
    _is.ColumnSelections<EphemeralAccreditationGroupTable>? updateColumns,
    _is.WhereExpressionBuilder<EphemeralAccreditationGroupTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<EphemeralAccreditationGroup>(
      row,
      conflictColumns: conflictColumns(EphemeralAccreditationGroup.t),
      updateColumns: updateColumns?.call(EphemeralAccreditationGroup.t),
      updateWhere: updateWhere?.call(EphemeralAccreditationGroup.t),
      transaction: transaction,
    );
  }

  /// Updates all [EphemeralAccreditationGroup]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EphemeralAccreditationGroup>> update(
    _is.DatabaseSession session,
    List<EphemeralAccreditationGroup> rows, {
    _is.ColumnSelections<EphemeralAccreditationGroupTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<EphemeralAccreditationGroup>(
      rows,
      columns: columns?.call(EphemeralAccreditationGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [EphemeralAccreditationGroup]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<EphemeralAccreditationGroup> updateRow(
    _is.DatabaseSession session,
    EphemeralAccreditationGroup row, {
    _is.ColumnSelections<EphemeralAccreditationGroupTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<EphemeralAccreditationGroup>(
      row,
      columns: columns?.call(EphemeralAccreditationGroup.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EphemeralAccreditationGroup] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<EphemeralAccreditationGroup?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<EphemeralAccreditationGroupUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<EphemeralAccreditationGroup>(
      id,
      columnValues: columnValues(EphemeralAccreditationGroup.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [EphemeralAccreditationGroup]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EphemeralAccreditationGroup>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<EphemeralAccreditationGroupUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<EphemeralAccreditationGroupTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EphemeralAccreditationGroupTable>? orderBy,
    _is.OrderByListBuilder<EphemeralAccreditationGroupTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<EphemeralAccreditationGroup>(
      columnValues: columnValues(EphemeralAccreditationGroup.t.updateTable),
      where: where(EphemeralAccreditationGroup.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EphemeralAccreditationGroup.t),
      orderByList: orderByList?.call(EphemeralAccreditationGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [EphemeralAccreditationGroup]s in the list and returns the deleted rows.
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
  Future<List<EphemeralAccreditationGroup>> delete(
    _is.DatabaseSession session,
    List<EphemeralAccreditationGroup> rows, {
    _is.OrderByBuilder<EphemeralAccreditationGroupTable>? orderBy,
    _is.OrderByListBuilder<EphemeralAccreditationGroupTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<EphemeralAccreditationGroup>(
      rows,
      orderBy: orderBy?.call(EphemeralAccreditationGroup.t),
      orderByList: orderByList?.call(EphemeralAccreditationGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [EphemeralAccreditationGroup].
  Future<EphemeralAccreditationGroup> deleteRow(
    _is.DatabaseSession session,
    EphemeralAccreditationGroup row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<EphemeralAccreditationGroup>(
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
  Future<List<EphemeralAccreditationGroup>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<EphemeralAccreditationGroupTable> where,
    _is.OrderByBuilder<EphemeralAccreditationGroupTable>? orderBy,
    _is.OrderByListBuilder<EphemeralAccreditationGroupTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<EphemeralAccreditationGroup>(
      where: where(EphemeralAccreditationGroup.t),
      orderBy: orderBy?.call(EphemeralAccreditationGroup.t),
      orderByList: orderByList?.call(EphemeralAccreditationGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EphemeralAccreditationGroupTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<EphemeralAccreditationGroup>(
      where: where?.call(EphemeralAccreditationGroup.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [EphemeralAccreditationGroup] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<EphemeralAccreditationGroupTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<EphemeralAccreditationGroup>(
      where: where(EphemeralAccreditationGroup.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
