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

abstract class RailProduct
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  RailProduct._({
    this.id,
    required this.rail,
    required this.storeProductId,
    required this.isActive,
  });

  factory RailProduct({
    int? id,
    required _i4hkjqgd.PaymentRail rail,
    required String storeProductId,
    required bool isActive,
  }) = _RailProductImpl;

  factory RailProduct.fromJson(Map<String, dynamic> jsonSerialization) {
    return RailProduct(
      id: jsonSerialization['id'] as int?,
      rail: _i4hkjqgd.PaymentRail.fromJson(
        (jsonSerialization['rail'] as String),
      ),
      storeProductId: jsonSerialization['storeProductId'] as String,
      isActive: _is.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
    );
  }

  static final t = RailProductTable();

  static const db = RailProductRepository._();

  @override
  int? id;

  _i4hkjqgd.PaymentRail rail;

  String storeProductId;

  bool isActive;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [RailProduct]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RailProduct copyWith({
    int? id,
    _i4hkjqgd.PaymentRail? rail,
    String? storeProductId,
    bool? isActive,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.RailProduct',
      if (id != null) 'id': id,
      'rail': rail.toJson(),
      'storeProductId': storeProductId,
      'isActive': isActive,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.RailProduct',
      if (id != null) 'id': id,
      'rail': rail.toJson(),
      'storeProductId': storeProductId,
      'isActive': isActive,
    };
  }

  static RailProductInclude include() {
    return RailProductInclude._();
  }

  static RailProductIncludeList includeList({
    _is.WhereExpressionBuilder<RailProductTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RailProductTable>? orderBy,
    _is.OrderByListBuilder<RailProductTable>? orderByList,
    RailProductInclude? include,
  }) {
    return RailProductIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RailProduct.t),
      orderByList: orderByList?.call(RailProduct.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RailProductImpl extends RailProduct {
  _RailProductImpl({
    int? id,
    required _i4hkjqgd.PaymentRail rail,
    required String storeProductId,
    required bool isActive,
  }) : super._(
         id: id,
         rail: rail,
         storeProductId: storeProductId,
         isActive: isActive,
       );

  /// Returns a shallow copy of this [RailProduct]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RailProduct copyWith({
    Object? id = _Undefined,
    _i4hkjqgd.PaymentRail? rail,
    String? storeProductId,
    bool? isActive,
  }) {
    return RailProduct(
      id: id is int? ? id : this.id,
      rail: rail ?? this.rail,
      storeProductId: storeProductId ?? this.storeProductId,
      isActive: isActive ?? this.isActive,
    );
  }
}

class RailProductUpdateTable extends _is.UpdateTable<RailProductTable> {
  RailProductUpdateTable(super.table);

  _is.ColumnValue<_i4hkjqgd.PaymentRail, _i4hkjqgd.PaymentRail> rail(
    _i4hkjqgd.PaymentRail value,
  ) => _is.ColumnValue(table.rail, value);

  _is.ColumnValue<String, String> storeProductId(String value) =>
      _is.ColumnValue(table.storeProductId, value);

  _is.ColumnValue<bool, bool> isActive(bool value) =>
      _is.ColumnValue(table.isActive, value);
}

class RailProductTable extends _is.Table<int?> {
  RailProductTable({super.tableRelation}) : super(tableName: 'rail_product') {
    updateTable = RailProductUpdateTable(this);
    rail = _is.ColumnEnum('rail', this, _is.EnumSerialization.byName);
    storeProductId = _is.ColumnString('storeProductId', this);
    isActive = _is.ColumnBool('isActive', this);
  }

  late final RailProductUpdateTable updateTable;

  late final _is.ColumnEnum<_i4hkjqgd.PaymentRail> rail;

  late final _is.ColumnString storeProductId;

  late final _is.ColumnBool isActive;

  @override
  List<_is.Column> get columns => [id, rail, storeProductId, isActive];
}

class RailProductInclude extends _is.IncludeObject {
  RailProductInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => RailProduct.t;
}

class RailProductIncludeList extends _is.IncludeList {
  RailProductIncludeList._({
    _is.WhereExpressionBuilder<RailProductTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RailProduct.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => RailProduct.t;
}

class RailProductRepository {
  const RailProductRepository._();

  /// Returns a list of [RailProduct]s matching the given query parameters.
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
  Future<List<RailProduct>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RailProductTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RailProductTable>? orderBy,
    _is.OrderByListBuilder<RailProductTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RailProduct>(
      where: where?.call(RailProduct.t),
      orderBy: orderBy?.call(RailProduct.t),
      orderByList: orderByList?.call(RailProduct.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RailProduct] matching the given query parameters.
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
  Future<RailProduct?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RailProductTable>? where,
    int? offset,
    _is.OrderByBuilder<RailProductTable>? orderBy,
    _is.OrderByListBuilder<RailProductTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RailProduct>(
      where: where?.call(RailProduct.t),
      orderBy: orderBy?.call(RailProduct.t),
      orderByList: orderByList?.call(RailProduct.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RailProduct] by its [id] or null if no such row exists.
  Future<RailProduct?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RailProduct>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RailProduct]s in the list and returns the inserted rows.
  ///
  /// The returned [RailProduct]s will have their `id` fields set.
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
  Future<List<RailProduct>> insert(
    _is.DatabaseSession session,
    List<RailProduct> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RailProduct>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RailProduct] and returns the inserted row.
  ///
  /// The returned [RailProduct] will have its `id` field set.
  Future<RailProduct> insertRow(
    _is.DatabaseSession session,
    RailProduct row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RailProduct>(row, transaction: transaction);
  }

  /// Upserts all [RailProduct]s in the list and returns the resulting rows.
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
  /// The returned [RailProduct]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RailProduct>> upsert(
    _is.DatabaseSession session,
    List<RailProduct> rows, {
    required _is.ColumnSelections<RailProductTable> conflictColumns,
    _is.ColumnSelections<RailProductTable>? updateColumns,
    _is.WhereExpressionBuilder<RailProductTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RailProduct>(
      rows,
      conflictColumns: conflictColumns(RailProduct.t),
      updateColumns: updateColumns?.call(RailProduct.t),
      updateWhere: updateWhere?.call(RailProduct.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RailProduct] and returns the resulting row.
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
  /// The returned [RailProduct] will have its `id` field set.
  Future<RailProduct?> upsertRow(
    _is.DatabaseSession session,
    RailProduct row, {
    required _is.ColumnSelections<RailProductTable> conflictColumns,
    _is.ColumnSelections<RailProductTable>? updateColumns,
    _is.WhereExpressionBuilder<RailProductTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RailProduct>(
      row,
      conflictColumns: conflictColumns(RailProduct.t),
      updateColumns: updateColumns?.call(RailProduct.t),
      updateWhere: updateWhere?.call(RailProduct.t),
      transaction: transaction,
    );
  }

  /// Updates all [RailProduct]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RailProduct>> update(
    _is.DatabaseSession session,
    List<RailProduct> rows, {
    _is.ColumnSelections<RailProductTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RailProduct>(
      rows,
      columns: columns?.call(RailProduct.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RailProduct]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RailProduct> updateRow(
    _is.DatabaseSession session,
    RailProduct row, {
    _is.ColumnSelections<RailProductTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RailProduct>(
      row,
      columns: columns?.call(RailProduct.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RailProduct] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RailProduct?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RailProductUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RailProduct>(
      id,
      columnValues: columnValues(RailProduct.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RailProduct]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RailProduct>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RailProductUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<RailProductTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RailProductTable>? orderBy,
    _is.OrderByListBuilder<RailProductTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RailProduct>(
      columnValues: columnValues(RailProduct.t.updateTable),
      where: where(RailProduct.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RailProduct.t),
      orderByList: orderByList?.call(RailProduct.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RailProduct]s in the list and returns the deleted rows.
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
  Future<List<RailProduct>> delete(
    _is.DatabaseSession session,
    List<RailProduct> rows, {
    _is.OrderByBuilder<RailProductTable>? orderBy,
    _is.OrderByListBuilder<RailProductTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RailProduct>(
      rows,
      orderBy: orderBy?.call(RailProduct.t),
      orderByList: orderByList?.call(RailProduct.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RailProduct].
  Future<RailProduct> deleteRow(
    _is.DatabaseSession session,
    RailProduct row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RailProduct>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RailProduct>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RailProductTable> where,
    _is.OrderByBuilder<RailProductTable>? orderBy,
    _is.OrderByListBuilder<RailProductTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RailProduct>(
      where: where(RailProduct.t),
      orderBy: orderBy?.call(RailProduct.t),
      orderByList: orderByList?.call(RailProduct.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RailProductTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RailProduct>(
      where: where?.call(RailProduct.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RailProduct] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RailProductTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RailProduct>(
      where: where(RailProduct.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
