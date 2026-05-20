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

abstract class RailProductGrant
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [RailProductGrant]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
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
    _i1.WhereExpressionBuilder<RailProductGrantTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RailProductGrantTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RailProductGrantTable>? orderByList,
    RailProductGrantInclude? include,
  }) {
    return RailProductGrantIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RailProductGrant.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(RailProductGrant.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
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
  @_i1.useResult
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
    extends _i1.UpdateTable<RailProductGrantTable> {
  RailProductGrantUpdateTable(super.table);

  _i1.ColumnValue<int, int> railProductId(int value) => _i1.ColumnValue(
    table.railProductId,
    value,
  );

  _i1.ColumnValue<int, int> entitlementId(int value) => _i1.ColumnValue(
    table.entitlementId,
    value,
  );

  _i1.ColumnValue<double, double> quantity(double value) => _i1.ColumnValue(
    table.quantity,
    value,
  );
}

class RailProductGrantTable extends _i1.Table<int?> {
  RailProductGrantTable({super.tableRelation})
    : super(tableName: 'rail_product_grant') {
    updateTable = RailProductGrantUpdateTable(this);
    railProductId = _i1.ColumnInt(
      'railProductId',
      this,
    );
    entitlementId = _i1.ColumnInt(
      'entitlementId',
      this,
    );
    quantity = _i1.ColumnDouble(
      'quantity',
      this,
    );
  }

  late final RailProductGrantUpdateTable updateTable;

  late final _i1.ColumnInt railProductId;

  late final _i1.ColumnInt entitlementId;

  late final _i1.ColumnDouble quantity;

  @override
  List<_i1.Column> get columns => [
    id,
    railProductId,
    entitlementId,
    quantity,
  ];
}

class RailProductGrantInclude extends _i1.IncludeObject {
  RailProductGrantInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => RailProductGrant.t;
}

class RailProductGrantIncludeList extends _i1.IncludeList {
  RailProductGrantIncludeList._({
    _i1.WhereExpressionBuilder<RailProductGrantTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RailProductGrant.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => RailProductGrant.t;
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RailProductGrantTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RailProductGrantTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RailProductGrantTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RailProductGrant>(
      where: where?.call(RailProductGrant.t),
      orderBy: orderBy?.call(RailProductGrant.t),
      orderByList: orderByList?.call(RailProductGrant.t),
      orderDescending: orderDescending,
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RailProductGrantTable>? where,
    int? offset,
    _i1.OrderByBuilder<RailProductGrantTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RailProductGrantTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RailProductGrant>(
      where: where?.call(RailProductGrant.t),
      orderBy: orderBy?.call(RailProductGrant.t),
      orderByList: orderByList?.call(RailProductGrant.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RailProductGrant] by its [id] or null if no such row exists.
  Future<RailProductGrant?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
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
  Future<List<RailProductGrant>> insert(
    _i1.Session session,
    List<RailProductGrant> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<RailProductGrant>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [RailProductGrant] and returns the inserted row.
  ///
  /// The returned [RailProductGrant] will have its `id` field set.
  Future<RailProductGrant> insertRow(
    _i1.Session session,
    RailProductGrant row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<RailProductGrant>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [RailProductGrant]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<RailProductGrant>> update(
    _i1.Session session,
    List<RailProductGrant> rows, {
    _i1.ColumnSelections<RailProductGrantTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<RailProductGrant>(
      rows,
      columns: columns?.call(RailProductGrant.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RailProductGrant]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RailProductGrant> updateRow(
    _i1.Session session,
    RailProductGrant row, {
    _i1.ColumnSelections<RailProductGrantTable>? columns,
    _i1.Transaction? transaction,
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
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<RailProductGrantUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<RailProductGrant>(
      id,
      columnValues: columnValues(RailProductGrant.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RailProductGrant]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<RailProductGrant>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<RailProductGrantUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<RailProductGrantTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RailProductGrantTable>? orderBy,
    _i1.OrderByListBuilder<RailProductGrantTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<RailProductGrant>(
      columnValues: columnValues(RailProductGrant.t.updateTable),
      where: where(RailProductGrant.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RailProductGrant.t),
      orderByList: orderByList?.call(RailProductGrant.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [RailProductGrant]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<RailProductGrant>> delete(
    _i1.Session session,
    List<RailProductGrant> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<RailProductGrant>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [RailProductGrant].
  Future<RailProductGrant> deleteRow(
    _i1.Session session,
    RailProductGrant row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RailProductGrant>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<RailProductGrant>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<RailProductGrantTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<RailProductGrant>(
      where: where(RailProductGrant.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RailProductGrantTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<RailProductGrant>(
      where: where?.call(RailProductGrant.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RailProductGrant] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<RailProductGrantTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RailProductGrant>(
      where: where(RailProductGrant.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
