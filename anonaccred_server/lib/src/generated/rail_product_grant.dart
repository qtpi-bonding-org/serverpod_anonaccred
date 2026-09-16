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

abstract class RailProductGrant
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  RailProductGrant._({
    this.id,
    required this.railProductId,
    required this.entitlementId,
    required this.quantity,
  });

  factory RailProductGrant({
    int? id,
    required int railProductId,
    required int entitlementId,
    required double quantity,
  }) = _RailProductGrantImpl;

  factory RailProductGrant.fromJson(Map<String, dynamic> jsonSerialization) {
    return RailProductGrant(
      id: jsonSerialization['id'] as int?,
      railProductId: jsonSerialization['railProductId'] as int,
      entitlementId: jsonSerialization['entitlementId'] as int,
      quantity: (jsonSerialization['quantity'] as num).toDouble(),
    );
  }

  static final t = RailProductGrantTable();

  static const db = RailProductGrantRepository._();

  @override
  int? id;

  int railProductId;

  int entitlementId;

  double quantity;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [RailProductGrant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RailProductGrant copyWith({
    int? id,
    int? railProductId,
    int? entitlementId,
    double? quantity,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.RailProductGrant',
      if (id != null) 'id': id,
      'railProductId': railProductId,
      'entitlementId': entitlementId,
      'quantity': quantity,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.RailProductGrant',
      if (id != null) 'id': id,
      'railProductId': railProductId,
      'entitlementId': entitlementId,
      'quantity': quantity,
    };
  }

  static RailProductGrantInclude include() {
    return RailProductGrantInclude._();
  }

  static RailProductGrantIncludeList includeList({
    _is.WhereExpressionBuilder<RailProductGrantTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RailProductGrantTable>? orderBy,
    _is.OrderByListBuilder<RailProductGrantTable>? orderByList,
    RailProductGrantInclude? include,
  }) {
    return RailProductGrantIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RailProductGrant.t),
      orderByList: orderByList?.call(RailProductGrant.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RailProductGrantImpl extends RailProductGrant {
  _RailProductGrantImpl({
    int? id,
    required int railProductId,
    required int entitlementId,
    required double quantity,
  }) : super._(
         id: id,
         railProductId: railProductId,
         entitlementId: entitlementId,
         quantity: quantity,
       );

  /// Returns a shallow copy of this [RailProductGrant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RailProductGrant copyWith({
    Object? id = _Undefined,
    int? railProductId,
    int? entitlementId,
    double? quantity,
  }) {
    return RailProductGrant(
      id: id is int? ? id : this.id,
      railProductId: railProductId ?? this.railProductId,
      entitlementId: entitlementId ?? this.entitlementId,
      quantity: quantity ?? this.quantity,
    );
  }
}

class RailProductGrantUpdateTable
    extends _is.UpdateTable<RailProductGrantTable> {
  RailProductGrantUpdateTable(super.table);

  _is.ColumnValue<int, int> railProductId(int value) =>
      _is.ColumnValue(table.railProductId, value);

  _is.ColumnValue<int, int> entitlementId(int value) =>
      _is.ColumnValue(table.entitlementId, value);

  _is.ColumnValue<double, double> quantity(double value) =>
      _is.ColumnValue(table.quantity, value);
}

class RailProductGrantTable extends _is.Table<int?> {
  RailProductGrantTable({super.tableRelation})
    : super(tableName: 'rail_product_grant') {
    updateTable = RailProductGrantUpdateTable(this);
    railProductId = _is.ColumnInt('railProductId', this);
    entitlementId = _is.ColumnInt('entitlementId', this);
    quantity = _is.ColumnDouble('quantity', this);
  }

  late final RailProductGrantUpdateTable updateTable;

  late final _is.ColumnInt railProductId;

  late final _is.ColumnInt entitlementId;

  late final _is.ColumnDouble quantity;

  @override
  List<_is.Column> get columns => [id, railProductId, entitlementId, quantity];
}

class RailProductGrantInclude extends _is.IncludeObject {
  RailProductGrantInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => RailProductGrant.t;
}

class RailProductGrantIncludeList extends _is.IncludeList {
  RailProductGrantIncludeList._({
    _is.WhereExpressionBuilder<RailProductGrantTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RailProductGrant.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => RailProductGrant.t;
}

class RailProductGrantRepository {
  const RailProductGrantRepository._();

  /// Returns a list of [RailProductGrant]s matching the given query parameters.
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
  Future<List<RailProductGrant>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RailProductGrantTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RailProductGrantTable>? orderBy,
    _is.OrderByListBuilder<RailProductGrantTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RailProductGrant>(
      where: where?.call(RailProductGrant.t),
      orderBy: orderBy?.call(RailProductGrant.t),
      orderByList: orderByList?.call(RailProductGrant.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RailProductGrant] matching the given query parameters.
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
  Future<RailProductGrant?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RailProductGrantTable>? where,
    int? offset,
    _is.OrderByBuilder<RailProductGrantTable>? orderBy,
    _is.OrderByListBuilder<RailProductGrantTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RailProductGrant>(
      where: where?.call(RailProductGrant.t),
      orderBy: orderBy?.call(RailProductGrant.t),
      orderByList: orderByList?.call(RailProductGrant.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RailProductGrant] by its [id] or null if no such row exists.
  Future<RailProductGrant?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RailProductGrant>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RailProductGrant]s in the list and returns the inserted rows.
  ///
  /// The returned [RailProductGrant]s will have their `id` fields set.
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
  Future<List<RailProductGrant>> insert(
    _is.DatabaseSession session,
    List<RailProductGrant> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RailProductGrant>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RailProductGrant] and returns the inserted row.
  ///
  /// The returned [RailProductGrant] will have its `id` field set.
  Future<RailProductGrant> insertRow(
    _is.DatabaseSession session,
    RailProductGrant row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RailProductGrant>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RailProductGrant]s in the list and returns the resulting rows.
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
  /// The returned [RailProductGrant]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RailProductGrant>> upsert(
    _is.DatabaseSession session,
    List<RailProductGrant> rows, {
    required _is.ColumnSelections<RailProductGrantTable> conflictColumns,
    _is.ColumnSelections<RailProductGrantTable>? updateColumns,
    _is.WhereExpressionBuilder<RailProductGrantTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RailProductGrant>(
      rows,
      conflictColumns: conflictColumns(RailProductGrant.t),
      updateColumns: updateColumns?.call(RailProductGrant.t),
      updateWhere: updateWhere?.call(RailProductGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RailProductGrant] and returns the resulting row.
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
  /// The returned [RailProductGrant] will have its `id` field set.
  Future<RailProductGrant?> upsertRow(
    _is.DatabaseSession session,
    RailProductGrant row, {
    required _is.ColumnSelections<RailProductGrantTable> conflictColumns,
    _is.ColumnSelections<RailProductGrantTable>? updateColumns,
    _is.WhereExpressionBuilder<RailProductGrantTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RailProductGrant>(
      row,
      conflictColumns: conflictColumns(RailProductGrant.t),
      updateColumns: updateColumns?.call(RailProductGrant.t),
      updateWhere: updateWhere?.call(RailProductGrant.t),
      transaction: transaction,
    );
  }

  /// Updates all [RailProductGrant]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RailProductGrant>> update(
    _is.DatabaseSession session,
    List<RailProductGrant> rows, {
    _is.ColumnSelections<RailProductGrantTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RailProductGrant>(
      rows,
      columns: columns?.call(RailProductGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RailProductGrant]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RailProductGrant> updateRow(
    _is.DatabaseSession session,
    RailProductGrant row, {
    _is.ColumnSelections<RailProductGrantTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RailProductGrant>(
      row,
      columns: columns?.call(RailProductGrant.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RailProductGrant] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RailProductGrant?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RailProductGrantUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RailProductGrant>(
      id,
      columnValues: columnValues(RailProductGrant.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RailProductGrant]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RailProductGrant>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RailProductGrantUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<RailProductGrantTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RailProductGrantTable>? orderBy,
    _is.OrderByListBuilder<RailProductGrantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RailProductGrant>(
      columnValues: columnValues(RailProductGrant.t.updateTable),
      where: where(RailProductGrant.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RailProductGrant.t),
      orderByList: orderByList?.call(RailProductGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RailProductGrant]s in the list and returns the deleted rows.
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
  Future<List<RailProductGrant>> delete(
    _is.DatabaseSession session,
    List<RailProductGrant> rows, {
    _is.OrderByBuilder<RailProductGrantTable>? orderBy,
    _is.OrderByListBuilder<RailProductGrantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RailProductGrant>(
      rows,
      orderBy: orderBy?.call(RailProductGrant.t),
      orderByList: orderByList?.call(RailProductGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RailProductGrant].
  Future<RailProductGrant> deleteRow(
    _is.DatabaseSession session,
    RailProductGrant row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RailProductGrant>(
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
  Future<List<RailProductGrant>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RailProductGrantTable> where,
    _is.OrderByBuilder<RailProductGrantTable>? orderBy,
    _is.OrderByListBuilder<RailProductGrantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RailProductGrant>(
      where: where(RailProductGrant.t),
      orderBy: orderBy?.call(RailProductGrant.t),
      orderByList: orderByList?.call(RailProductGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RailProductGrantTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RailProductGrant>(
      where: where?.call(RailProductGrant.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RailProductGrant] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RailProductGrantTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RailProductGrant>(
      where: where(RailProductGrant.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
