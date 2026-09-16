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

abstract class EphemeralAccreditation
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  EphemeralAccreditation._({
    this.id,
    required this.accountUuid,
    required this.transactionTimestamp,
  });

  factory EphemeralAccreditation({
    int? id,
    required _is.UuidValue accountUuid,
    required DateTime transactionTimestamp,
  }) = _EphemeralAccreditationImpl;

  factory EphemeralAccreditation.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return EphemeralAccreditation(
      id: jsonSerialization['id'] as int?,
      accountUuid: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountUuid'],
      ),
      transactionTimestamp: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['transactionTimestamp'],
      ),
    );
  }

  static final t = EphemeralAccreditationTable();

  static const db = EphemeralAccreditationRepository._();

  @override
  int? id;

  _is.UuidValue accountUuid;

  DateTime transactionTimestamp;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [EphemeralAccreditation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  EphemeralAccreditation copyWith({
    int? id,
    _is.UuidValue? accountUuid,
    DateTime? transactionTimestamp,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.EphemeralAccreditation',
      if (id != null) 'id': id,
      'accountUuid': accountUuid.toJson(),
      'transactionTimestamp': transactionTimestamp.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.EphemeralAccreditation',
      if (id != null) 'id': id,
      'accountUuid': accountUuid.toJson(),
      'transactionTimestamp': transactionTimestamp.toJson(),
    };
  }

  static EphemeralAccreditationInclude include() {
    return EphemeralAccreditationInclude._();
  }

  static EphemeralAccreditationIncludeList includeList({
    _is.WhereExpressionBuilder<EphemeralAccreditationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EphemeralAccreditationTable>? orderBy,
    _is.OrderByListBuilder<EphemeralAccreditationTable>? orderByList,
    EphemeralAccreditationInclude? include,
  }) {
    return EphemeralAccreditationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EphemeralAccreditation.t),
      orderByList: orderByList?.call(EphemeralAccreditation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EphemeralAccreditationImpl extends EphemeralAccreditation {
  _EphemeralAccreditationImpl({
    int? id,
    required _is.UuidValue accountUuid,
    required DateTime transactionTimestamp,
  }) : super._(
         id: id,
         accountUuid: accountUuid,
         transactionTimestamp: transactionTimestamp,
       );

  /// Returns a shallow copy of this [EphemeralAccreditation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  EphemeralAccreditation copyWith({
    Object? id = _Undefined,
    _is.UuidValue? accountUuid,
    DateTime? transactionTimestamp,
  }) {
    return EphemeralAccreditation(
      id: id is int? ? id : this.id,
      accountUuid: accountUuid ?? this.accountUuid,
      transactionTimestamp: transactionTimestamp ?? this.transactionTimestamp,
    );
  }
}

class EphemeralAccreditationUpdateTable
    extends _is.UpdateTable<EphemeralAccreditationTable> {
  EphemeralAccreditationUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> accountUuid(
    _is.UuidValue value,
  ) => _is.ColumnValue(table.accountUuid, value);

  _is.ColumnValue<DateTime, DateTime> transactionTimestamp(DateTime value) =>
      _is.ColumnValue(table.transactionTimestamp, value);
}

class EphemeralAccreditationTable extends _is.Table<int?> {
  EphemeralAccreditationTable({super.tableRelation})
    : super(tableName: 'ephemeral_accreditation') {
    updateTable = EphemeralAccreditationUpdateTable(this);
    accountUuid = _is.ColumnUuid('accountUuid', this);
    transactionTimestamp = _is.ColumnDateTime('transactionTimestamp', this);
  }

  late final EphemeralAccreditationUpdateTable updateTable;

  late final _is.ColumnUuid accountUuid;

  late final _is.ColumnDateTime transactionTimestamp;

  @override
  List<_is.Column> get columns => [id, accountUuid, transactionTimestamp];
}

class EphemeralAccreditationInclude extends _is.IncludeObject {
  EphemeralAccreditationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => EphemeralAccreditation.t;
}

class EphemeralAccreditationIncludeList extends _is.IncludeList {
  EphemeralAccreditationIncludeList._({
    _is.WhereExpressionBuilder<EphemeralAccreditationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(EphemeralAccreditation.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => EphemeralAccreditation.t;
}

class EphemeralAccreditationRepository {
  const EphemeralAccreditationRepository._();

  /// Returns a list of [EphemeralAccreditation]s matching the given query parameters.
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
  Future<List<EphemeralAccreditation>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EphemeralAccreditationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EphemeralAccreditationTable>? orderBy,
    _is.OrderByListBuilder<EphemeralAccreditationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<EphemeralAccreditation>(
      where: where?.call(EphemeralAccreditation.t),
      orderBy: orderBy?.call(EphemeralAccreditation.t),
      orderByList: orderByList?.call(EphemeralAccreditation.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [EphemeralAccreditation] matching the given query parameters.
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
  Future<EphemeralAccreditation?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EphemeralAccreditationTable>? where,
    int? offset,
    _is.OrderByBuilder<EphemeralAccreditationTable>? orderBy,
    _is.OrderByListBuilder<EphemeralAccreditationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<EphemeralAccreditation>(
      where: where?.call(EphemeralAccreditation.t),
      orderBy: orderBy?.call(EphemeralAccreditation.t),
      orderByList: orderByList?.call(EphemeralAccreditation.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [EphemeralAccreditation] by its [id] or null if no such row exists.
  Future<EphemeralAccreditation?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<EphemeralAccreditation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [EphemeralAccreditation]s in the list and returns the inserted rows.
  ///
  /// The returned [EphemeralAccreditation]s will have their `id` fields set.
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
  Future<List<EphemeralAccreditation>> insert(
    _is.DatabaseSession session,
    List<EphemeralAccreditation> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<EphemeralAccreditation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [EphemeralAccreditation] and returns the inserted row.
  ///
  /// The returned [EphemeralAccreditation] will have its `id` field set.
  Future<EphemeralAccreditation> insertRow(
    _is.DatabaseSession session,
    EphemeralAccreditation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<EphemeralAccreditation>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [EphemeralAccreditation]s in the list and returns the resulting rows.
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
  /// The returned [EphemeralAccreditation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EphemeralAccreditation>> upsert(
    _is.DatabaseSession session,
    List<EphemeralAccreditation> rows, {
    required _is.ColumnSelections<EphemeralAccreditationTable> conflictColumns,
    _is.ColumnSelections<EphemeralAccreditationTable>? updateColumns,
    _is.WhereExpressionBuilder<EphemeralAccreditationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<EphemeralAccreditation>(
      rows,
      conflictColumns: conflictColumns(EphemeralAccreditation.t),
      updateColumns: updateColumns?.call(EphemeralAccreditation.t),
      updateWhere: updateWhere?.call(EphemeralAccreditation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [EphemeralAccreditation] and returns the resulting row.
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
  /// The returned [EphemeralAccreditation] will have its `id` field set.
  Future<EphemeralAccreditation?> upsertRow(
    _is.DatabaseSession session,
    EphemeralAccreditation row, {
    required _is.ColumnSelections<EphemeralAccreditationTable> conflictColumns,
    _is.ColumnSelections<EphemeralAccreditationTable>? updateColumns,
    _is.WhereExpressionBuilder<EphemeralAccreditationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<EphemeralAccreditation>(
      row,
      conflictColumns: conflictColumns(EphemeralAccreditation.t),
      updateColumns: updateColumns?.call(EphemeralAccreditation.t),
      updateWhere: updateWhere?.call(EphemeralAccreditation.t),
      transaction: transaction,
    );
  }

  /// Updates all [EphemeralAccreditation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EphemeralAccreditation>> update(
    _is.DatabaseSession session,
    List<EphemeralAccreditation> rows, {
    _is.ColumnSelections<EphemeralAccreditationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<EphemeralAccreditation>(
      rows,
      columns: columns?.call(EphemeralAccreditation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [EphemeralAccreditation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<EphemeralAccreditation> updateRow(
    _is.DatabaseSession session,
    EphemeralAccreditation row, {
    _is.ColumnSelections<EphemeralAccreditationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<EphemeralAccreditation>(
      row,
      columns: columns?.call(EphemeralAccreditation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EphemeralAccreditation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<EphemeralAccreditation?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<EphemeralAccreditationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<EphemeralAccreditation>(
      id,
      columnValues: columnValues(EphemeralAccreditation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [EphemeralAccreditation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EphemeralAccreditation>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<EphemeralAccreditationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<EphemeralAccreditationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EphemeralAccreditationTable>? orderBy,
    _is.OrderByListBuilder<EphemeralAccreditationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<EphemeralAccreditation>(
      columnValues: columnValues(EphemeralAccreditation.t.updateTable),
      where: where(EphemeralAccreditation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EphemeralAccreditation.t),
      orderByList: orderByList?.call(EphemeralAccreditation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [EphemeralAccreditation]s in the list and returns the deleted rows.
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
  Future<List<EphemeralAccreditation>> delete(
    _is.DatabaseSession session,
    List<EphemeralAccreditation> rows, {
    _is.OrderByBuilder<EphemeralAccreditationTable>? orderBy,
    _is.OrderByListBuilder<EphemeralAccreditationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<EphemeralAccreditation>(
      rows,
      orderBy: orderBy?.call(EphemeralAccreditation.t),
      orderByList: orderByList?.call(EphemeralAccreditation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [EphemeralAccreditation].
  Future<EphemeralAccreditation> deleteRow(
    _is.DatabaseSession session,
    EphemeralAccreditation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<EphemeralAccreditation>(
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
  Future<List<EphemeralAccreditation>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<EphemeralAccreditationTable> where,
    _is.OrderByBuilder<EphemeralAccreditationTable>? orderBy,
    _is.OrderByListBuilder<EphemeralAccreditationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<EphemeralAccreditation>(
      where: where(EphemeralAccreditation.t),
      orderBy: orderBy?.call(EphemeralAccreditation.t),
      orderByList: orderByList?.call(EphemeralAccreditation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EphemeralAccreditationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<EphemeralAccreditation>(
      where: where?.call(EphemeralAccreditation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [EphemeralAccreditation] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<EphemeralAccreditationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<EphemeralAccreditation>(
      where: where(EphemeralAccreditation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
