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

abstract class ReceiptHash
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ReceiptHash._({
    this.id,
    required this.hash,
    required this.paymentRail,
    DateTime? processedAt,
  }) : processedAt = processedAt ?? DateTime.now();

  factory ReceiptHash({
    int? id,
    required String hash,
    required _i4hkjqgd.PaymentRail paymentRail,
    DateTime? processedAt,
  }) = _ReceiptHashImpl;

  factory ReceiptHash.fromJson(Map<String, dynamic> jsonSerialization) {
    return ReceiptHash(
      id: jsonSerialization['id'] as int?,
      hash: jsonSerialization['hash'] as String,
      paymentRail: _i4hkjqgd.PaymentRail.fromJson(
        (jsonSerialization['paymentRail'] as String),
      ),
      processedAt: jsonSerialization['processedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['processedAt'],
            ),
    );
  }

  static final t = ReceiptHashTable();

  static const db = ReceiptHashRepository._();

  @override
  int? id;

  String hash;

  _i4hkjqgd.PaymentRail paymentRail;

  DateTime processedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ReceiptHash]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ReceiptHash copyWith({
    int? id,
    String? hash,
    _i4hkjqgd.PaymentRail? paymentRail,
    DateTime? processedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.ReceiptHash',
      if (id != null) 'id': id,
      'hash': hash,
      'paymentRail': paymentRail.toJson(),
      'processedAt': processedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.ReceiptHash',
      if (id != null) 'id': id,
      'hash': hash,
      'paymentRail': paymentRail.toJson(),
      'processedAt': processedAt.toJson(),
    };
  }

  static ReceiptHashInclude include() {
    return ReceiptHashInclude._();
  }

  static ReceiptHashIncludeList includeList({
    _is.WhereExpressionBuilder<ReceiptHashTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ReceiptHashTable>? orderBy,
    _is.OrderByListBuilder<ReceiptHashTable>? orderByList,
    ReceiptHashInclude? include,
  }) {
    return ReceiptHashIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ReceiptHash.t),
      orderByList: orderByList?.call(ReceiptHash.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ReceiptHashImpl extends ReceiptHash {
  _ReceiptHashImpl({
    int? id,
    required String hash,
    required _i4hkjqgd.PaymentRail paymentRail,
    DateTime? processedAt,
  }) : super._(
         id: id,
         hash: hash,
         paymentRail: paymentRail,
         processedAt: processedAt,
       );

  /// Returns a shallow copy of this [ReceiptHash]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ReceiptHash copyWith({
    Object? id = _Undefined,
    String? hash,
    _i4hkjqgd.PaymentRail? paymentRail,
    DateTime? processedAt,
  }) {
    return ReceiptHash(
      id: id is int? ? id : this.id,
      hash: hash ?? this.hash,
      paymentRail: paymentRail ?? this.paymentRail,
      processedAt: processedAt ?? this.processedAt,
    );
  }
}

class ReceiptHashUpdateTable extends _is.UpdateTable<ReceiptHashTable> {
  ReceiptHashUpdateTable(super.table);

  _is.ColumnValue<String, String> hash(String value) =>
      _is.ColumnValue(table.hash, value);

  _is.ColumnValue<_i4hkjqgd.PaymentRail, _i4hkjqgd.PaymentRail> paymentRail(
    _i4hkjqgd.PaymentRail value,
  ) => _is.ColumnValue(table.paymentRail, value);

  _is.ColumnValue<DateTime, DateTime> processedAt(DateTime value) =>
      _is.ColumnValue(table.processedAt, value);
}

class ReceiptHashTable extends _is.Table<int?> {
  ReceiptHashTable({super.tableRelation}) : super(tableName: 'receipt_hash') {
    updateTable = ReceiptHashUpdateTable(this);
    hash = _is.ColumnString('hash', this);
    paymentRail = _is.ColumnEnum(
      'paymentRail',
      this,
      _is.EnumSerialization.byName,
    );
    processedAt = _is.ColumnDateTime('processedAt', this, hasDefault: true);
  }

  late final ReceiptHashUpdateTable updateTable;

  late final _is.ColumnString hash;

  late final _is.ColumnEnum<_i4hkjqgd.PaymentRail> paymentRail;

  late final _is.ColumnDateTime processedAt;

  @override
  List<_is.Column> get columns => [id, hash, paymentRail, processedAt];
}

class ReceiptHashInclude extends _is.IncludeObject {
  ReceiptHashInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ReceiptHash.t;
}

class ReceiptHashIncludeList extends _is.IncludeList {
  ReceiptHashIncludeList._({
    _is.WhereExpressionBuilder<ReceiptHashTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ReceiptHash.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ReceiptHash.t;
}

class ReceiptHashRepository {
  const ReceiptHashRepository._();

  /// Returns a list of [ReceiptHash]s matching the given query parameters.
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
  Future<List<ReceiptHash>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ReceiptHashTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ReceiptHashTable>? orderBy,
    _is.OrderByListBuilder<ReceiptHashTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ReceiptHash>(
      where: where?.call(ReceiptHash.t),
      orderBy: orderBy?.call(ReceiptHash.t),
      orderByList: orderByList?.call(ReceiptHash.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ReceiptHash] matching the given query parameters.
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
  Future<ReceiptHash?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ReceiptHashTable>? where,
    int? offset,
    _is.OrderByBuilder<ReceiptHashTable>? orderBy,
    _is.OrderByListBuilder<ReceiptHashTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ReceiptHash>(
      where: where?.call(ReceiptHash.t),
      orderBy: orderBy?.call(ReceiptHash.t),
      orderByList: orderByList?.call(ReceiptHash.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ReceiptHash] by its [id] or null if no such row exists.
  Future<ReceiptHash?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ReceiptHash>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ReceiptHash]s in the list and returns the inserted rows.
  ///
  /// The returned [ReceiptHash]s will have their `id` fields set.
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
  Future<List<ReceiptHash>> insert(
    _is.DatabaseSession session,
    List<ReceiptHash> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ReceiptHash>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ReceiptHash] and returns the inserted row.
  ///
  /// The returned [ReceiptHash] will have its `id` field set.
  Future<ReceiptHash> insertRow(
    _is.DatabaseSession session,
    ReceiptHash row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ReceiptHash>(row, transaction: transaction);
  }

  /// Upserts all [ReceiptHash]s in the list and returns the resulting rows.
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
  /// The returned [ReceiptHash]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ReceiptHash>> upsert(
    _is.DatabaseSession session,
    List<ReceiptHash> rows, {
    required _is.ColumnSelections<ReceiptHashTable> conflictColumns,
    _is.ColumnSelections<ReceiptHashTable>? updateColumns,
    _is.WhereExpressionBuilder<ReceiptHashTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ReceiptHash>(
      rows,
      conflictColumns: conflictColumns(ReceiptHash.t),
      updateColumns: updateColumns?.call(ReceiptHash.t),
      updateWhere: updateWhere?.call(ReceiptHash.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ReceiptHash] and returns the resulting row.
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
  /// The returned [ReceiptHash] will have its `id` field set.
  Future<ReceiptHash?> upsertRow(
    _is.DatabaseSession session,
    ReceiptHash row, {
    required _is.ColumnSelections<ReceiptHashTable> conflictColumns,
    _is.ColumnSelections<ReceiptHashTable>? updateColumns,
    _is.WhereExpressionBuilder<ReceiptHashTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ReceiptHash>(
      row,
      conflictColumns: conflictColumns(ReceiptHash.t),
      updateColumns: updateColumns?.call(ReceiptHash.t),
      updateWhere: updateWhere?.call(ReceiptHash.t),
      transaction: transaction,
    );
  }

  /// Updates all [ReceiptHash]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ReceiptHash>> update(
    _is.DatabaseSession session,
    List<ReceiptHash> rows, {
    _is.ColumnSelections<ReceiptHashTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ReceiptHash>(
      rows,
      columns: columns?.call(ReceiptHash.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ReceiptHash]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ReceiptHash> updateRow(
    _is.DatabaseSession session,
    ReceiptHash row, {
    _is.ColumnSelections<ReceiptHashTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ReceiptHash>(
      row,
      columns: columns?.call(ReceiptHash.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ReceiptHash] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ReceiptHash?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ReceiptHashUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ReceiptHash>(
      id,
      columnValues: columnValues(ReceiptHash.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ReceiptHash]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ReceiptHash>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ReceiptHashUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ReceiptHashTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ReceiptHashTable>? orderBy,
    _is.OrderByListBuilder<ReceiptHashTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ReceiptHash>(
      columnValues: columnValues(ReceiptHash.t.updateTable),
      where: where(ReceiptHash.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ReceiptHash.t),
      orderByList: orderByList?.call(ReceiptHash.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ReceiptHash]s in the list and returns the deleted rows.
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
  Future<List<ReceiptHash>> delete(
    _is.DatabaseSession session,
    List<ReceiptHash> rows, {
    _is.OrderByBuilder<ReceiptHashTable>? orderBy,
    _is.OrderByListBuilder<ReceiptHashTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ReceiptHash>(
      rows,
      orderBy: orderBy?.call(ReceiptHash.t),
      orderByList: orderByList?.call(ReceiptHash.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ReceiptHash].
  Future<ReceiptHash> deleteRow(
    _is.DatabaseSession session,
    ReceiptHash row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ReceiptHash>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ReceiptHash>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ReceiptHashTable> where,
    _is.OrderByBuilder<ReceiptHashTable>? orderBy,
    _is.OrderByListBuilder<ReceiptHashTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ReceiptHash>(
      where: where(ReceiptHash.t),
      orderBy: orderBy?.call(ReceiptHash.t),
      orderByList: orderByList?.call(ReceiptHash.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ReceiptHashTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ReceiptHash>(
      where: where?.call(ReceiptHash.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ReceiptHash] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ReceiptHashTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ReceiptHash>(
      where: where(ReceiptHash.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
