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
import 'payment_rail.dart' as _i2;

abstract class RailProduct
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  RailProduct._({
    this.id,
    required this.rail,
    required this.storeProductId,
    required this.isActive,
  });

  factory RailProduct({
    int? id,
    required _i2.PaymentRail rail,
    required String storeProductId,
    required bool isActive,
  }) = _RailProductImpl;

  factory RailProduct.fromJson(Map<String, dynamic> jsonSerialization) {
    return RailProduct(
      id: jsonSerialization['id'] as int?,
      rail: _i2.PaymentRail.fromJson((jsonSerialization['rail'] as String)),
      storeProductId: jsonSerialization['storeProductId'] as String,
      isActive: _i1.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
    );
  }

  static final t = RailProductTable();

  static const db = RailProductRepository._();

  @override
  int? id;

  _i2.PaymentRail rail;

  String storeProductId;

  bool isActive;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [RailProduct]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RailProduct copyWith({
    int? id,
    _i2.PaymentRail? rail,
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
    _i1.WhereExpressionBuilder<RailProductTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RailProductTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RailProductTable>? orderByList,
    RailProductInclude? include,
  }) {
    return RailProductIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RailProduct.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(RailProduct.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RailProductImpl extends RailProduct {
  _RailProductImpl({
    int? id,
    required _i2.PaymentRail rail,
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
  @_i1.useResult
  @override
  RailProduct copyWith({
    Object? id = _Undefined,
    _i2.PaymentRail? rail,
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

class RailProductUpdateTable extends _i1.UpdateTable<RailProductTable> {
  RailProductUpdateTable(super.table);

  _i1.ColumnValue<_i2.PaymentRail, _i2.PaymentRail> rail(
    _i2.PaymentRail value,
  ) => _i1.ColumnValue(
    table.rail,
    value,
  );

  _i1.ColumnValue<String, String> storeProductId(String value) =>
      _i1.ColumnValue(
        table.storeProductId,
        value,
      );

  _i1.ColumnValue<bool, bool> isActive(bool value) => _i1.ColumnValue(
    table.isActive,
    value,
  );
}

class RailProductTable extends _i1.Table<int?> {
  RailProductTable({super.tableRelation}) : super(tableName: 'rail_product') {
    updateTable = RailProductUpdateTable(this);
    rail = _i1.ColumnEnum(
      'rail',
      this,
      _i1.EnumSerialization.byName,
    );
    storeProductId = _i1.ColumnString(
      'storeProductId',
      this,
    );
    isActive = _i1.ColumnBool(
      'isActive',
      this,
    );
  }

  late final RailProductUpdateTable updateTable;

  late final _i1.ColumnEnum<_i2.PaymentRail> rail;

  late final _i1.ColumnString storeProductId;

  late final _i1.ColumnBool isActive;

  @override
  List<_i1.Column> get columns => [
    id,
    rail,
    storeProductId,
    isActive,
  ];
}

class RailProductInclude extends _i1.IncludeObject {
  RailProductInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => RailProduct.t;
}

class RailProductIncludeList extends _i1.IncludeList {
  RailProductIncludeList._({
    _i1.WhereExpressionBuilder<RailProductTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RailProduct.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => RailProduct.t;
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RailProductTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RailProductTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RailProductTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RailProduct>(
      where: where?.call(RailProduct.t),
      orderBy: orderBy?.call(RailProduct.t),
      orderByList: orderByList?.call(RailProduct.t),
      orderDescending: orderDescending,
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RailProductTable>? where,
    int? offset,
    _i1.OrderByBuilder<RailProductTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RailProductTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RailProduct>(
      where: where?.call(RailProduct.t),
      orderBy: orderBy?.call(RailProduct.t),
      orderByList: orderByList?.call(RailProduct.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RailProduct] by its [id] or null if no such row exists.
  Future<RailProduct?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
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
  Future<List<RailProduct>> insert(
    _i1.Session session,
    List<RailProduct> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<RailProduct>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [RailProduct] and returns the inserted row.
  ///
  /// The returned [RailProduct] will have its `id` field set.
  Future<RailProduct> insertRow(
    _i1.Session session,
    RailProduct row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<RailProduct>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [RailProduct]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<RailProduct>> update(
    _i1.Session session,
    List<RailProduct> rows, {
    _i1.ColumnSelections<RailProductTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<RailProduct>(
      rows,
      columns: columns?.call(RailProduct.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RailProduct]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RailProduct> updateRow(
    _i1.Session session,
    RailProduct row, {
    _i1.ColumnSelections<RailProductTable>? columns,
    _i1.Transaction? transaction,
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
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<RailProductUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<RailProduct>(
      id,
      columnValues: columnValues(RailProduct.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RailProduct]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<RailProduct>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<RailProductUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<RailProductTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RailProductTable>? orderBy,
    _i1.OrderByListBuilder<RailProductTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<RailProduct>(
      columnValues: columnValues(RailProduct.t.updateTable),
      where: where(RailProduct.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RailProduct.t),
      orderByList: orderByList?.call(RailProduct.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [RailProduct]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<RailProduct>> delete(
    _i1.Session session,
    List<RailProduct> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<RailProduct>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [RailProduct].
  Future<RailProduct> deleteRow(
    _i1.Session session,
    RailProduct row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RailProduct>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<RailProduct>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<RailProductTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<RailProduct>(
      where: where(RailProduct.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RailProductTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<RailProduct>(
      where: where?.call(RailProduct.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RailProduct] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<RailProductTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RailProduct>(
      where: where(RailProduct.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
