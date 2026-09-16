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
import 'payment_rail.dart' as _i4hkjqgd;

abstract class RefundClaim
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  RefundClaim._({
    this.id,
    required this.paymentRail,
    required this.paymentRef,
    DateTime? claimedAt,
  }) : claimedAt = claimedAt ?? DateTime.now();

  factory RefundClaim({
    int? id,
    required _i4hkjqgd.PaymentRail paymentRail,
    required String paymentRef,
    DateTime? claimedAt,
  }) = _RefundClaimImpl;

  factory RefundClaim.fromJson(Map<String, dynamic> jsonSerialization) {
    return RefundClaim(
      id: jsonSerialization['id'] as int?,
      paymentRail: _i4hkjqgd.PaymentRail.fromJson(
        (jsonSerialization['paymentRail'] as String),
      ),
      paymentRef: jsonSerialization['paymentRef'] as String,
      claimedAt: jsonSerialization['claimedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['claimedAt']),
    );
  }

  static final t = RefundClaimTable();

  static const db = RefundClaimRepository._();

  @override
  int? id;

  _i4hkjqgd.PaymentRail paymentRail;

  String paymentRef;

  DateTime claimedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [RefundClaim]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RefundClaim copyWith({
    int? id,
    _i4hkjqgd.PaymentRail? paymentRail,
    String? paymentRef,
    DateTime? claimedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.RefundClaim',
      if (id != null) 'id': id,
      'paymentRail': paymentRail.toJson(),
      'paymentRef': paymentRef,
      'claimedAt': claimedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.RefundClaim',
      if (id != null) 'id': id,
      'paymentRail': paymentRail.toJson(),
      'paymentRef': paymentRef,
      'claimedAt': claimedAt.toJson(),
    };
  }

  static RefundClaimInclude include() {
    return RefundClaimInclude._();
  }

  static RefundClaimIncludeList includeList({
    _is.WhereExpressionBuilder<RefundClaimTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RefundClaimTable>? orderBy,
    _is.OrderByListBuilder<RefundClaimTable>? orderByList,
    RefundClaimInclude? include,
  }) {
    return RefundClaimIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RefundClaim.t),
      orderByList: orderByList?.call(RefundClaim.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RefundClaimImpl extends RefundClaim {
  _RefundClaimImpl({
    int? id,
    required _i4hkjqgd.PaymentRail paymentRail,
    required String paymentRef,
    DateTime? claimedAt,
  }) : super._(
         id: id,
         paymentRail: paymentRail,
         paymentRef: paymentRef,
         claimedAt: claimedAt,
       );

  /// Returns a shallow copy of this [RefundClaim]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RefundClaim copyWith({
    Object? id = _Undefined,
    _i4hkjqgd.PaymentRail? paymentRail,
    String? paymentRef,
    DateTime? claimedAt,
  }) {
    return RefundClaim(
      id: id is int? ? id : this.id,
      paymentRail: paymentRail ?? this.paymentRail,
      paymentRef: paymentRef ?? this.paymentRef,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }
}

class RefundClaimUpdateTable extends _is.UpdateTable<RefundClaimTable> {
  RefundClaimUpdateTable(super.table);

  _is.ColumnValue<_i4hkjqgd.PaymentRail, _i4hkjqgd.PaymentRail> paymentRail(
    _i4hkjqgd.PaymentRail value,
  ) => _is.ColumnValue(table.paymentRail, value);

  _is.ColumnValue<String, String> paymentRef(String value) =>
      _is.ColumnValue(table.paymentRef, value);

  _is.ColumnValue<DateTime, DateTime> claimedAt(DateTime value) =>
      _is.ColumnValue(table.claimedAt, value);
}

class RefundClaimTable extends _is.Table<int?> {
  RefundClaimTable({super.tableRelation}) : super(tableName: 'refund_claim') {
    updateTable = RefundClaimUpdateTable(this);
    paymentRail = _is.ColumnEnum(
      'paymentRail',
      this,
      _is.EnumSerialization.byName,
    );
    paymentRef = _is.ColumnString('paymentRef', this);
    claimedAt = _is.ColumnDateTime('claimedAt', this, hasDefault: true);
  }

  late final RefundClaimUpdateTable updateTable;

  late final _is.ColumnEnum<_i4hkjqgd.PaymentRail> paymentRail;

  late final _is.ColumnString paymentRef;

  late final _is.ColumnDateTime claimedAt;

  @override
  List<_is.Column> get columns => [id, paymentRail, paymentRef, claimedAt];
}

class RefundClaimInclude extends _is.IncludeObject {
  RefundClaimInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => RefundClaim.t;
}

class RefundClaimIncludeList extends _is.IncludeList {
  RefundClaimIncludeList._({
    _is.WhereExpressionBuilder<RefundClaimTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RefundClaim.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => RefundClaim.t;
}

class RefundClaimRepository {
  const RefundClaimRepository._();

  /// Returns a list of [RefundClaim]s matching the given query parameters.
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
  Future<List<RefundClaim>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RefundClaimTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RefundClaimTable>? orderBy,
    _is.OrderByListBuilder<RefundClaimTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RefundClaim>(
      where: where?.call(RefundClaim.t),
      orderBy: orderBy?.call(RefundClaim.t),
      orderByList: orderByList?.call(RefundClaim.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RefundClaim] matching the given query parameters.
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
  Future<RefundClaim?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RefundClaimTable>? where,
    int? offset,
    _is.OrderByBuilder<RefundClaimTable>? orderBy,
    _is.OrderByListBuilder<RefundClaimTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RefundClaim>(
      where: where?.call(RefundClaim.t),
      orderBy: orderBy?.call(RefundClaim.t),
      orderByList: orderByList?.call(RefundClaim.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RefundClaim] by its [id] or null if no such row exists.
  Future<RefundClaim?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RefundClaim>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RefundClaim]s in the list and returns the inserted rows.
  ///
  /// The returned [RefundClaim]s will have their `id` fields set.
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
  Future<List<RefundClaim>> insert(
    _is.DatabaseSession session,
    List<RefundClaim> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RefundClaim>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RefundClaim] and returns the inserted row.
  ///
  /// The returned [RefundClaim] will have its `id` field set.
  Future<RefundClaim> insertRow(
    _is.DatabaseSession session,
    RefundClaim row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RefundClaim>(row, transaction: transaction);
  }

  /// Upserts all [RefundClaim]s in the list and returns the resulting rows.
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
  /// The returned [RefundClaim]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RefundClaim>> upsert(
    _is.DatabaseSession session,
    List<RefundClaim> rows, {
    required _is.ColumnSelections<RefundClaimTable> conflictColumns,
    _is.ColumnSelections<RefundClaimTable>? updateColumns,
    _is.WhereExpressionBuilder<RefundClaimTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RefundClaim>(
      rows,
      conflictColumns: conflictColumns(RefundClaim.t),
      updateColumns: updateColumns?.call(RefundClaim.t),
      updateWhere: updateWhere?.call(RefundClaim.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RefundClaim] and returns the resulting row.
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
  /// The returned [RefundClaim] will have its `id` field set.
  Future<RefundClaim?> upsertRow(
    _is.DatabaseSession session,
    RefundClaim row, {
    required _is.ColumnSelections<RefundClaimTable> conflictColumns,
    _is.ColumnSelections<RefundClaimTable>? updateColumns,
    _is.WhereExpressionBuilder<RefundClaimTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RefundClaim>(
      row,
      conflictColumns: conflictColumns(RefundClaim.t),
      updateColumns: updateColumns?.call(RefundClaim.t),
      updateWhere: updateWhere?.call(RefundClaim.t),
      transaction: transaction,
    );
  }

  /// Updates all [RefundClaim]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RefundClaim>> update(
    _is.DatabaseSession session,
    List<RefundClaim> rows, {
    _is.ColumnSelections<RefundClaimTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RefundClaim>(
      rows,
      columns: columns?.call(RefundClaim.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RefundClaim]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RefundClaim> updateRow(
    _is.DatabaseSession session,
    RefundClaim row, {
    _is.ColumnSelections<RefundClaimTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RefundClaim>(
      row,
      columns: columns?.call(RefundClaim.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RefundClaim] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RefundClaim?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RefundClaimUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RefundClaim>(
      id,
      columnValues: columnValues(RefundClaim.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RefundClaim]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RefundClaim>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RefundClaimUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<RefundClaimTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RefundClaimTable>? orderBy,
    _is.OrderByListBuilder<RefundClaimTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RefundClaim>(
      columnValues: columnValues(RefundClaim.t.updateTable),
      where: where(RefundClaim.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RefundClaim.t),
      orderByList: orderByList?.call(RefundClaim.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RefundClaim]s in the list and returns the deleted rows.
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
  Future<List<RefundClaim>> delete(
    _is.DatabaseSession session,
    List<RefundClaim> rows, {
    _is.OrderByBuilder<RefundClaimTable>? orderBy,
    _is.OrderByListBuilder<RefundClaimTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RefundClaim>(
      rows,
      orderBy: orderBy?.call(RefundClaim.t),
      orderByList: orderByList?.call(RefundClaim.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RefundClaim].
  Future<RefundClaim> deleteRow(
    _is.DatabaseSession session,
    RefundClaim row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RefundClaim>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RefundClaim>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RefundClaimTable> where,
    _is.OrderByBuilder<RefundClaimTable>? orderBy,
    _is.OrderByListBuilder<RefundClaimTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RefundClaim>(
      where: where(RefundClaim.t),
      orderBy: orderBy?.call(RefundClaim.t),
      orderByList: orderByList?.call(RefundClaim.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RefundClaimTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RefundClaim>(
      where: where?.call(RefundClaim.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RefundClaim] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RefundClaimTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RefundClaim>(
      where: where(RefundClaim.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
