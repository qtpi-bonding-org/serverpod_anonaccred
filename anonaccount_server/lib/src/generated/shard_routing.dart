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

abstract class ShardRouting
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  ShardRouting._({
    this.id,
    required this.tenantId,
    required this.tenantType,
    String? shardName,
    DateTime? updatedAt,
  }) : shardName = shardName ?? 'shard_01',
       updatedAt = updatedAt ?? DateTime.now();

  factory ShardRouting({
    _i1.UuidValue? id,
    required _i1.UuidValue tenantId,
    required String tenantType,
    String? shardName,
    DateTime? updatedAt,
  }) = _ShardRoutingImpl;

  factory ShardRouting.fromJson(Map<String, dynamic> jsonSerialization) {
    return ShardRouting(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      tenantType: jsonSerialization['tenantType'] as String,
      shardName: jsonSerialization['shardName'] as String?,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = ShardRoutingTable();

  static const db = ShardRoutingRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue tenantId;

  String tenantType;

  String shardName;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [ShardRouting]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ShardRouting copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? tenantId,
    String? tenantType,
    String? shardName,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.ShardRouting',
      if (id != null) 'id': id?.toJson(),
      'tenantId': tenantId.toJson(),
      'tenantType': tenantType,
      'shardName': shardName,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.ShardRouting',
      if (id != null) 'id': id?.toJson(),
      'tenantId': tenantId.toJson(),
      'tenantType': tenantType,
      'shardName': shardName,
      'updatedAt': updatedAt.toJson(),
    };
  }

  static ShardRoutingInclude include() {
    return ShardRoutingInclude._();
  }

  static ShardRoutingIncludeList includeList({
    _i1.WhereExpressionBuilder<ShardRoutingTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ShardRoutingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ShardRoutingTable>? orderByList,
    ShardRoutingInclude? include,
  }) {
    return ShardRoutingIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ShardRouting.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ShardRouting.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ShardRoutingImpl extends ShardRouting {
  _ShardRoutingImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue tenantId,
    required String tenantType,
    String? shardName,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         tenantId: tenantId,
         tenantType: tenantType,
         shardName: shardName,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [ShardRouting]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ShardRouting copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? tenantId,
    String? tenantType,
    String? shardName,
    DateTime? updatedAt,
  }) {
    return ShardRouting(
      id: id is _i1.UuidValue? ? id : this.id,
      tenantId: tenantId ?? this.tenantId,
      tenantType: tenantType ?? this.tenantType,
      shardName: shardName ?? this.shardName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ShardRoutingUpdateTable extends _i1.UpdateTable<ShardRoutingTable> {
  ShardRoutingUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> tenantId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.tenantId,
        value,
      );

  _i1.ColumnValue<String, String> tenantType(String value) => _i1.ColumnValue(
    table.tenantType,
    value,
  );

  _i1.ColumnValue<String, String> shardName(String value) => _i1.ColumnValue(
    table.shardName,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class ShardRoutingTable extends _i1.Table<_i1.UuidValue?> {
  ShardRoutingTable({super.tableRelation}) : super(tableName: 'shard_routing') {
    updateTable = ShardRoutingUpdateTable(this);
    tenantId = _i1.ColumnUuid(
      'tenantId',
      this,
    );
    tenantType = _i1.ColumnString(
      'tenantType',
      this,
    );
    shardName = _i1.ColumnString(
      'shardName',
      this,
      hasDefault: true,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final ShardRoutingUpdateTable updateTable;

  late final _i1.ColumnUuid tenantId;

  late final _i1.ColumnString tenantType;

  late final _i1.ColumnString shardName;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    tenantId,
    tenantType,
    shardName,
    updatedAt,
  ];
}

class ShardRoutingInclude extends _i1.IncludeObject {
  ShardRoutingInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => ShardRouting.t;
}

class ShardRoutingIncludeList extends _i1.IncludeList {
  ShardRoutingIncludeList._({
    _i1.WhereExpressionBuilder<ShardRoutingTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ShardRouting.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => ShardRouting.t;
}

class ShardRoutingRepository {
  const ShardRoutingRepository._();

  /// Returns a list of [ShardRouting]s matching the given query parameters.
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
  Future<List<ShardRouting>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ShardRoutingTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ShardRoutingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ShardRoutingTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ShardRouting>(
      where: where?.call(ShardRouting.t),
      orderBy: orderBy?.call(ShardRouting.t),
      orderByList: orderByList?.call(ShardRouting.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ShardRouting] matching the given query parameters.
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
  Future<ShardRouting?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ShardRoutingTable>? where,
    int? offset,
    _i1.OrderByBuilder<ShardRoutingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ShardRoutingTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ShardRouting>(
      where: where?.call(ShardRouting.t),
      orderBy: orderBy?.call(ShardRouting.t),
      orderByList: orderByList?.call(ShardRouting.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ShardRouting] by its [id] or null if no such row exists.
  Future<ShardRouting?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ShardRouting>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ShardRouting]s in the list and returns the inserted rows.
  ///
  /// The returned [ShardRouting]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ShardRouting>> insert(
    _i1.Session session,
    List<ShardRouting> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ShardRouting>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ShardRouting] and returns the inserted row.
  ///
  /// The returned [ShardRouting] will have its `id` field set.
  Future<ShardRouting> insertRow(
    _i1.Session session,
    ShardRouting row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ShardRouting>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ShardRouting]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ShardRouting>> update(
    _i1.Session session,
    List<ShardRouting> rows, {
    _i1.ColumnSelections<ShardRoutingTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ShardRouting>(
      rows,
      columns: columns?.call(ShardRouting.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ShardRouting]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ShardRouting> updateRow(
    _i1.Session session,
    ShardRouting row, {
    _i1.ColumnSelections<ShardRoutingTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ShardRouting>(
      row,
      columns: columns?.call(ShardRouting.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ShardRouting] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ShardRouting?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<ShardRoutingUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ShardRouting>(
      id,
      columnValues: columnValues(ShardRouting.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ShardRouting]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ShardRouting>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<ShardRoutingUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ShardRoutingTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ShardRoutingTable>? orderBy,
    _i1.OrderByListBuilder<ShardRoutingTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ShardRouting>(
      columnValues: columnValues(ShardRouting.t.updateTable),
      where: where(ShardRouting.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ShardRouting.t),
      orderByList: orderByList?.call(ShardRouting.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ShardRouting]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ShardRouting>> delete(
    _i1.Session session,
    List<ShardRouting> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ShardRouting>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ShardRouting].
  Future<ShardRouting> deleteRow(
    _i1.Session session,
    ShardRouting row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ShardRouting>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ShardRouting>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ShardRoutingTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ShardRouting>(
      where: where(ShardRouting.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ShardRoutingTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ShardRouting>(
      where: where?.call(ShardRouting.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ShardRouting] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ShardRoutingTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ShardRouting>(
      where: where(ShardRouting.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
