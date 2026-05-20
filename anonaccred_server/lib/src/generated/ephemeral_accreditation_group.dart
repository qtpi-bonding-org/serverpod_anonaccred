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

abstract class EphemeralAccreditationGroup
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  EphemeralAccreditationGroup._({
    this.id,
    required this.accountUuid,
    required this.shareGroupUuid,
    required this.transactionTimestamp,
  });

  factory EphemeralAccreditationGroup({
    int? id,
    required _i1.UuidValue accountUuid,
    required _i1.UuidValue shareGroupUuid,
    required DateTime transactionTimestamp,
  }) = _EphemeralAccreditationGroupImpl;

  factory EphemeralAccreditationGroup.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return EphemeralAccreditationGroup(
      id: jsonSerialization['id'] as int?,
      accountUuid: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountUuid'],
      ),
      shareGroupUuid: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['shareGroupUuid'],
      ),
      transactionTimestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['transactionTimestamp'],
      ),
    );
  }

  static final t = EphemeralAccreditationGroupTable();

  static const db = EphemeralAccreditationGroupRepository._();

  @override
  int? id;

  _i1.UuidValue accountUuid;

  _i1.UuidValue shareGroupUuid;

  DateTime transactionTimestamp;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [EphemeralAccreditationGroup]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EphemeralAccreditationGroup copyWith({
    int? id,
    _i1.UuidValue? accountUuid,
    _i1.UuidValue? shareGroupUuid,
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
    _i1.WhereExpressionBuilder<EphemeralAccreditationGroupTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EphemeralAccreditationGroupTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EphemeralAccreditationGroupTable>? orderByList,
    EphemeralAccreditationGroupInclude? include,
  }) {
    return EphemeralAccreditationGroupIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EphemeralAccreditationGroup.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(EphemeralAccreditationGroup.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EphemeralAccreditationGroupImpl extends EphemeralAccreditationGroup {
  _EphemeralAccreditationGroupImpl({
    int? id,
    required _i1.UuidValue accountUuid,
    required _i1.UuidValue shareGroupUuid,
    required DateTime transactionTimestamp,
  }) : super._(
         id: id,
         accountUuid: accountUuid,
         shareGroupUuid: shareGroupUuid,
         transactionTimestamp: transactionTimestamp,
       );

  /// Returns a shallow copy of this [EphemeralAccreditationGroup]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EphemeralAccreditationGroup copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? accountUuid,
    _i1.UuidValue? shareGroupUuid,
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
    extends _i1.UpdateTable<EphemeralAccreditationGroupTable> {
  EphemeralAccreditationGroupUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> accountUuid(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.accountUuid,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> shareGroupUuid(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.shareGroupUuid,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> transactionTimestamp(DateTime value) =>
      _i1.ColumnValue(
        table.transactionTimestamp,
        value,
      );
}

class EphemeralAccreditationGroupTable extends _i1.Table<int?> {
  EphemeralAccreditationGroupTable({super.tableRelation})
    : super(tableName: 'ephemeral_accreditation_group') {
    updateTable = EphemeralAccreditationGroupUpdateTable(this);
    accountUuid = _i1.ColumnUuid(
      'accountUuid',
      this,
    );
    shareGroupUuid = _i1.ColumnUuid(
      'shareGroupUuid',
      this,
    );
    transactionTimestamp = _i1.ColumnDateTime(
      'transactionTimestamp',
      this,
    );
  }

  late final EphemeralAccreditationGroupUpdateTable updateTable;

  late final _i1.ColumnUuid accountUuid;

  late final _i1.ColumnUuid shareGroupUuid;

  late final _i1.ColumnDateTime transactionTimestamp;

  @override
  List<_i1.Column> get columns => [
    id,
    accountUuid,
    shareGroupUuid,
    transactionTimestamp,
  ];
}

class EphemeralAccreditationGroupInclude extends _i1.IncludeObject {
  EphemeralAccreditationGroupInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => EphemeralAccreditationGroup.t;
}

class EphemeralAccreditationGroupIncludeList extends _i1.IncludeList {
  EphemeralAccreditationGroupIncludeList._({
    _i1.WhereExpressionBuilder<EphemeralAccreditationGroupTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(EphemeralAccreditationGroup.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => EphemeralAccreditationGroup.t;
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<EphemeralAccreditationGroupTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EphemeralAccreditationGroupTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EphemeralAccreditationGroupTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<EphemeralAccreditationGroup>(
      where: where?.call(EphemeralAccreditationGroup.t),
      orderBy: orderBy?.call(EphemeralAccreditationGroup.t),
      orderByList: orderByList?.call(EphemeralAccreditationGroup.t),
      orderDescending: orderDescending,
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<EphemeralAccreditationGroupTable>? where,
    int? offset,
    _i1.OrderByBuilder<EphemeralAccreditationGroupTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EphemeralAccreditationGroupTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<EphemeralAccreditationGroup>(
      where: where?.call(EphemeralAccreditationGroup.t),
      orderBy: orderBy?.call(EphemeralAccreditationGroup.t),
      orderByList: orderByList?.call(EphemeralAccreditationGroup.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [EphemeralAccreditationGroup] by its [id] or null if no such row exists.
  Future<EphemeralAccreditationGroup?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
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
  Future<List<EphemeralAccreditationGroup>> insert(
    _i1.Session session,
    List<EphemeralAccreditationGroup> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<EphemeralAccreditationGroup>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [EphemeralAccreditationGroup] and returns the inserted row.
  ///
  /// The returned [EphemeralAccreditationGroup] will have its `id` field set.
  Future<EphemeralAccreditationGroup> insertRow(
    _i1.Session session,
    EphemeralAccreditationGroup row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<EphemeralAccreditationGroup>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [EphemeralAccreditationGroup]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<EphemeralAccreditationGroup>> update(
    _i1.Session session,
    List<EphemeralAccreditationGroup> rows, {
    _i1.ColumnSelections<EphemeralAccreditationGroupTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<EphemeralAccreditationGroup>(
      rows,
      columns: columns?.call(EphemeralAccreditationGroup.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EphemeralAccreditationGroup]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<EphemeralAccreditationGroup> updateRow(
    _i1.Session session,
    EphemeralAccreditationGroup row, {
    _i1.ColumnSelections<EphemeralAccreditationGroupTable>? columns,
    _i1.Transaction? transaction,
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
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<EphemeralAccreditationGroupUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<EphemeralAccreditationGroup>(
      id,
      columnValues: columnValues(EphemeralAccreditationGroup.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [EphemeralAccreditationGroup]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<EphemeralAccreditationGroup>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<EphemeralAccreditationGroupUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<EphemeralAccreditationGroupTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EphemeralAccreditationGroupTable>? orderBy,
    _i1.OrderByListBuilder<EphemeralAccreditationGroupTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<EphemeralAccreditationGroup>(
      columnValues: columnValues(EphemeralAccreditationGroup.t.updateTable),
      where: where(EphemeralAccreditationGroup.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EphemeralAccreditationGroup.t),
      orderByList: orderByList?.call(EphemeralAccreditationGroup.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [EphemeralAccreditationGroup]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<EphemeralAccreditationGroup>> delete(
    _i1.Session session,
    List<EphemeralAccreditationGroup> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<EphemeralAccreditationGroup>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [EphemeralAccreditationGroup].
  Future<EphemeralAccreditationGroup> deleteRow(
    _i1.Session session,
    EphemeralAccreditationGroup row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<EphemeralAccreditationGroup>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<EphemeralAccreditationGroup>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<EphemeralAccreditationGroupTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<EphemeralAccreditationGroup>(
      where: where(EphemeralAccreditationGroup.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<EphemeralAccreditationGroupTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<EphemeralAccreditationGroup>(
      where: where?.call(EphemeralAccreditationGroup.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [EphemeralAccreditationGroup] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<EphemeralAccreditationGroupTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<EphemeralAccreditationGroup>(
      where: where(EphemeralAccreditationGroup.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
