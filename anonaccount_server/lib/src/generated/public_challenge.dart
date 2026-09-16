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

abstract class PublicChallenge
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PublicChallenge._({
    this.id,
    required this.challenge,
    required this.expiresAt,
  });

  factory PublicChallenge({
    int? id,
    required String challenge,
    required DateTime expiresAt,
  }) = _PublicChallengeImpl;

  factory PublicChallenge.fromJson(Map<String, dynamic> jsonSerialization) {
    return PublicChallenge(
      id: jsonSerialization['id'] as int?,
      challenge: jsonSerialization['challenge'] as String,
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  static final t = PublicChallengeTable();

  static const db = PublicChallengeRepository._();

  @override
  int? id;

  String challenge;

  DateTime expiresAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PublicChallenge]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PublicChallenge copyWith({int? id, String? challenge, DateTime? expiresAt});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.PublicChallenge',
      if (id != null) 'id': id,
      'challenge': challenge,
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.PublicChallenge',
      if (id != null) 'id': id,
      'challenge': challenge,
      'expiresAt': expiresAt.toJson(),
    };
  }

  static PublicChallengeInclude include() {
    return PublicChallengeInclude._();
  }

  static PublicChallengeIncludeList includeList({
    _is.WhereExpressionBuilder<PublicChallengeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PublicChallengeTable>? orderBy,
    _is.OrderByListBuilder<PublicChallengeTable>? orderByList,
    PublicChallengeInclude? include,
  }) {
    return PublicChallengeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PublicChallenge.t),
      orderByList: orderByList?.call(PublicChallenge.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PublicChallengeImpl extends PublicChallenge {
  _PublicChallengeImpl({
    int? id,
    required String challenge,
    required DateTime expiresAt,
  }) : super._(id: id, challenge: challenge, expiresAt: expiresAt);

  /// Returns a shallow copy of this [PublicChallenge]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PublicChallenge copyWith({
    Object? id = _Undefined,
    String? challenge,
    DateTime? expiresAt,
  }) {
    return PublicChallenge(
      id: id is int? ? id : this.id,
      challenge: challenge ?? this.challenge,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class PublicChallengeUpdateTable extends _is.UpdateTable<PublicChallengeTable> {
  PublicChallengeUpdateTable(super.table);

  _is.ColumnValue<String, String> challenge(String value) =>
      _is.ColumnValue(table.challenge, value);

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(table.expiresAt, value);
}

class PublicChallengeTable extends _is.Table<int?> {
  PublicChallengeTable({super.tableRelation})
    : super(tableName: 'public_challenges') {
    updateTable = PublicChallengeUpdateTable(this);
    challenge = _is.ColumnString('challenge', this);
    expiresAt = _is.ColumnDateTime('expiresAt', this);
  }

  late final PublicChallengeUpdateTable updateTable;

  late final _is.ColumnString challenge;

  late final _is.ColumnDateTime expiresAt;

  @override
  List<_is.Column> get columns => [id, challenge, expiresAt];
}

class PublicChallengeInclude extends _is.IncludeObject {
  PublicChallengeInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PublicChallenge.t;
}

class PublicChallengeIncludeList extends _is.IncludeList {
  PublicChallengeIncludeList._({
    _is.WhereExpressionBuilder<PublicChallengeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PublicChallenge.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PublicChallenge.t;
}

class PublicChallengeRepository {
  const PublicChallengeRepository._();

  /// Returns a list of [PublicChallenge]s matching the given query parameters.
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
  Future<List<PublicChallenge>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PublicChallengeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PublicChallengeTable>? orderBy,
    _is.OrderByListBuilder<PublicChallengeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PublicChallenge>(
      where: where?.call(PublicChallenge.t),
      orderBy: orderBy?.call(PublicChallenge.t),
      orderByList: orderByList?.call(PublicChallenge.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PublicChallenge] matching the given query parameters.
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
  Future<PublicChallenge?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PublicChallengeTable>? where,
    int? offset,
    _is.OrderByBuilder<PublicChallengeTable>? orderBy,
    _is.OrderByListBuilder<PublicChallengeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PublicChallenge>(
      where: where?.call(PublicChallenge.t),
      orderBy: orderBy?.call(PublicChallenge.t),
      orderByList: orderByList?.call(PublicChallenge.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PublicChallenge] by its [id] or null if no such row exists.
  Future<PublicChallenge?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PublicChallenge>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PublicChallenge]s in the list and returns the inserted rows.
  ///
  /// The returned [PublicChallenge]s will have their `id` fields set.
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
  Future<List<PublicChallenge>> insert(
    _is.DatabaseSession session,
    List<PublicChallenge> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PublicChallenge>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PublicChallenge] and returns the inserted row.
  ///
  /// The returned [PublicChallenge] will have its `id` field set.
  Future<PublicChallenge> insertRow(
    _is.DatabaseSession session,
    PublicChallenge row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PublicChallenge>(row, transaction: transaction);
  }

  /// Upserts all [PublicChallenge]s in the list and returns the resulting rows.
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
  /// The returned [PublicChallenge]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PublicChallenge>> upsert(
    _is.DatabaseSession session,
    List<PublicChallenge> rows, {
    required _is.ColumnSelections<PublicChallengeTable> conflictColumns,
    _is.ColumnSelections<PublicChallengeTable>? updateColumns,
    _is.WhereExpressionBuilder<PublicChallengeTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PublicChallenge>(
      rows,
      conflictColumns: conflictColumns(PublicChallenge.t),
      updateColumns: updateColumns?.call(PublicChallenge.t),
      updateWhere: updateWhere?.call(PublicChallenge.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PublicChallenge] and returns the resulting row.
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
  /// The returned [PublicChallenge] will have its `id` field set.
  Future<PublicChallenge?> upsertRow(
    _is.DatabaseSession session,
    PublicChallenge row, {
    required _is.ColumnSelections<PublicChallengeTable> conflictColumns,
    _is.ColumnSelections<PublicChallengeTable>? updateColumns,
    _is.WhereExpressionBuilder<PublicChallengeTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PublicChallenge>(
      row,
      conflictColumns: conflictColumns(PublicChallenge.t),
      updateColumns: updateColumns?.call(PublicChallenge.t),
      updateWhere: updateWhere?.call(PublicChallenge.t),
      transaction: transaction,
    );
  }

  /// Updates all [PublicChallenge]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PublicChallenge>> update(
    _is.DatabaseSession session,
    List<PublicChallenge> rows, {
    _is.ColumnSelections<PublicChallengeTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PublicChallenge>(
      rows,
      columns: columns?.call(PublicChallenge.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PublicChallenge]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PublicChallenge> updateRow(
    _is.DatabaseSession session,
    PublicChallenge row, {
    _is.ColumnSelections<PublicChallengeTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PublicChallenge>(
      row,
      columns: columns?.call(PublicChallenge.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PublicChallenge] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PublicChallenge?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PublicChallengeUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PublicChallenge>(
      id,
      columnValues: columnValues(PublicChallenge.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PublicChallenge]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PublicChallenge>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PublicChallengeUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<PublicChallengeTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PublicChallengeTable>? orderBy,
    _is.OrderByListBuilder<PublicChallengeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PublicChallenge>(
      columnValues: columnValues(PublicChallenge.t.updateTable),
      where: where(PublicChallenge.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PublicChallenge.t),
      orderByList: orderByList?.call(PublicChallenge.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PublicChallenge]s in the list and returns the deleted rows.
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
  Future<List<PublicChallenge>> delete(
    _is.DatabaseSession session,
    List<PublicChallenge> rows, {
    _is.OrderByBuilder<PublicChallengeTable>? orderBy,
    _is.OrderByListBuilder<PublicChallengeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PublicChallenge>(
      rows,
      orderBy: orderBy?.call(PublicChallenge.t),
      orderByList: orderByList?.call(PublicChallenge.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PublicChallenge].
  Future<PublicChallenge> deleteRow(
    _is.DatabaseSession session,
    PublicChallenge row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PublicChallenge>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PublicChallenge>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PublicChallengeTable> where,
    _is.OrderByBuilder<PublicChallengeTable>? orderBy,
    _is.OrderByListBuilder<PublicChallengeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PublicChallenge>(
      where: where(PublicChallenge.t),
      orderBy: orderBy?.call(PublicChallenge.t),
      orderByList: orderByList?.call(PublicChallenge.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PublicChallengeTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PublicChallenge>(
      where: where?.call(PublicChallenge.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PublicChallenge] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PublicChallengeTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PublicChallenge>(
      where: where(PublicChallenge.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
