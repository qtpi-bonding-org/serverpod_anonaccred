/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'entitlement.dart' as _i2;
import 'package:anonaccred_server/src/generated/protocol.dart' as _i3;

abstract class GroupEntitlement
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  GroupEntitlement._({
    this.id,
    required this.shareGroupUuid,
    required this.entitlementId,
    this.entitlement,
    required this.balance,
  });

  factory GroupEntitlement({
    int? id,
    required _i1.UuidValue shareGroupUuid,
    required int entitlementId,
    _i2.Entitlement? entitlement,
    required double balance,
  }) = _GroupEntitlementImpl;

  factory GroupEntitlement.fromJson(Map<String, dynamic> jsonSerialization) {
    return GroupEntitlement(
      id: jsonSerialization['id'] as int?,
      shareGroupUuid: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['shareGroupUuid'],
      ),
      entitlementId: jsonSerialization['entitlementId'] as int,
      entitlement: jsonSerialization['entitlement'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.Entitlement>(
              jsonSerialization['entitlement'],
            ),
      balance: (jsonSerialization['balance'] as num).toDouble(),
    );
  }

  static final t = GroupEntitlementTable();

  static const db = GroupEntitlementRepository._();

  @override
  int? id;

  _i1.UuidValue shareGroupUuid;

  int entitlementId;

  _i2.Entitlement? entitlement;

  double balance;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [GroupEntitlement]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GroupEntitlement copyWith({
    int? id,
    _i1.UuidValue? shareGroupUuid,
    int? entitlementId,
    _i2.Entitlement? entitlement,
    double? balance,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.GroupEntitlement',
      if (id != null) 'id': id,
      'shareGroupUuid': shareGroupUuid.toJson(),
      'entitlementId': entitlementId,
      if (entitlement != null) 'entitlement': entitlement?.toJson(),
      'balance': balance,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.GroupEntitlement',
      if (id != null) 'id': id,
      'shareGroupUuid': shareGroupUuid.toJson(),
      'entitlementId': entitlementId,
      if (entitlement != null) 'entitlement': entitlement?.toJsonForProtocol(),
      'balance': balance,
    };
  }

  static GroupEntitlementInclude include({
    _i2.EntitlementInclude? entitlement,
  }) {
    return GroupEntitlementInclude._(entitlement: entitlement);
  }

  static GroupEntitlementIncludeList includeList({
    _i1.WhereExpressionBuilder<GroupEntitlementTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GroupEntitlementTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GroupEntitlementTable>? orderByList,
    GroupEntitlementInclude? include,
  }) {
    return GroupEntitlementIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupEntitlement.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(GroupEntitlement.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupEntitlementImpl extends GroupEntitlement {
  _GroupEntitlementImpl({
    int? id,
    required _i1.UuidValue shareGroupUuid,
    required int entitlementId,
    _i2.Entitlement? entitlement,
    required double balance,
  }) : super._(
         id: id,
         shareGroupUuid: shareGroupUuid,
         entitlementId: entitlementId,
         entitlement: entitlement,
         balance: balance,
       );

  /// Returns a shallow copy of this [GroupEntitlement]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GroupEntitlement copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? shareGroupUuid,
    int? entitlementId,
    Object? entitlement = _Undefined,
    double? balance,
  }) {
    return GroupEntitlement(
      id: id is int? ? id : this.id,
      shareGroupUuid: shareGroupUuid ?? this.shareGroupUuid,
      entitlementId: entitlementId ?? this.entitlementId,
      entitlement: entitlement is _i2.Entitlement?
          ? entitlement
          : this.entitlement?.copyWith(),
      balance: balance ?? this.balance,
    );
  }
}

class GroupEntitlementUpdateTable
    extends _i1.UpdateTable<GroupEntitlementTable> {
  GroupEntitlementUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> shareGroupUuid(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.shareGroupUuid,
    value,
  );

  _i1.ColumnValue<int, int> entitlementId(int value) => _i1.ColumnValue(
    table.entitlementId,
    value,
  );

  _i1.ColumnValue<double, double> balance(double value) => _i1.ColumnValue(
    table.balance,
    value,
  );
}

class GroupEntitlementTable extends _i1.Table<int?> {
  GroupEntitlementTable({super.tableRelation})
    : super(tableName: 'group_entitlement') {
    updateTable = GroupEntitlementUpdateTable(this);
    shareGroupUuid = _i1.ColumnUuid(
      'shareGroupUuid',
      this,
    );
    entitlementId = _i1.ColumnInt(
      'entitlementId',
      this,
    );
    balance = _i1.ColumnDouble(
      'balance',
      this,
    );
  }

  late final GroupEntitlementUpdateTable updateTable;

  late final _i1.ColumnUuid shareGroupUuid;

  late final _i1.ColumnInt entitlementId;

  _i2.EntitlementTable? _entitlement;

  late final _i1.ColumnDouble balance;

  _i2.EntitlementTable get entitlement {
    if (_entitlement != null) return _entitlement!;
    _entitlement = _i1.createRelationTable(
      relationFieldName: 'entitlement',
      field: GroupEntitlement.t.entitlementId,
      foreignField: _i2.Entitlement.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.EntitlementTable(tableRelation: foreignTableRelation),
    );
    return _entitlement!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    shareGroupUuid,
    entitlementId,
    balance,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'entitlement') {
      return entitlement;
    }
    return null;
  }
}

class GroupEntitlementInclude extends _i1.IncludeObject {
  GroupEntitlementInclude._({_i2.EntitlementInclude? entitlement}) {
    _entitlement = entitlement;
  }

  _i2.EntitlementInclude? _entitlement;

  @override
  Map<String, _i1.Include?> get includes => {'entitlement': _entitlement};

  @override
  _i1.Table<int?> get table => GroupEntitlement.t;
}

class GroupEntitlementIncludeList extends _i1.IncludeList {
  GroupEntitlementIncludeList._({
    _i1.WhereExpressionBuilder<GroupEntitlementTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GroupEntitlement.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => GroupEntitlement.t;
}

class GroupEntitlementRepository {
  const GroupEntitlementRepository._();

  final attachRow = const GroupEntitlementAttachRowRepository._();

  /// Returns a list of [GroupEntitlement]s matching the given query parameters.
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
  Future<List<GroupEntitlement>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GroupEntitlementTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GroupEntitlementTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GroupEntitlementTable>? orderByList,
    _i1.Transaction? transaction,
    GroupEntitlementInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GroupEntitlement>(
      where: where?.call(GroupEntitlement.t),
      orderBy: orderBy?.call(GroupEntitlement.t),
      orderByList: orderByList?.call(GroupEntitlement.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [GroupEntitlement] matching the given query parameters.
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
  Future<GroupEntitlement?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GroupEntitlementTable>? where,
    int? offset,
    _i1.OrderByBuilder<GroupEntitlementTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GroupEntitlementTable>? orderByList,
    _i1.Transaction? transaction,
    GroupEntitlementInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GroupEntitlement>(
      where: where?.call(GroupEntitlement.t),
      orderBy: orderBy?.call(GroupEntitlement.t),
      orderByList: orderByList?.call(GroupEntitlement.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GroupEntitlement] by its [id] or null if no such row exists.
  Future<GroupEntitlement?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    GroupEntitlementInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<GroupEntitlement>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [GroupEntitlement]s in the list and returns the inserted rows.
  ///
  /// The returned [GroupEntitlement]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<GroupEntitlement>> insert(
    _i1.Session session,
    List<GroupEntitlement> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<GroupEntitlement>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [GroupEntitlement] and returns the inserted row.
  ///
  /// The returned [GroupEntitlement] will have its `id` field set.
  Future<GroupEntitlement> insertRow(
    _i1.Session session,
    GroupEntitlement row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<GroupEntitlement>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [GroupEntitlement]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<GroupEntitlement>> update(
    _i1.Session session,
    List<GroupEntitlement> rows, {
    _i1.ColumnSelections<GroupEntitlementTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<GroupEntitlement>(
      rows,
      columns: columns?.call(GroupEntitlement.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GroupEntitlement]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GroupEntitlement> updateRow(
    _i1.Session session,
    GroupEntitlement row, {
    _i1.ColumnSelections<GroupEntitlementTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<GroupEntitlement>(
      row,
      columns: columns?.call(GroupEntitlement.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GroupEntitlement] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<GroupEntitlement?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<GroupEntitlementUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<GroupEntitlement>(
      id,
      columnValues: columnValues(GroupEntitlement.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GroupEntitlement]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<GroupEntitlement>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<GroupEntitlementUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<GroupEntitlementTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GroupEntitlementTable>? orderBy,
    _i1.OrderByListBuilder<GroupEntitlementTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<GroupEntitlement>(
      columnValues: columnValues(GroupEntitlement.t.updateTable),
      where: where(GroupEntitlement.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupEntitlement.t),
      orderByList: orderByList?.call(GroupEntitlement.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [GroupEntitlement]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<GroupEntitlement>> delete(
    _i1.Session session,
    List<GroupEntitlement> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<GroupEntitlement>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [GroupEntitlement].
  Future<GroupEntitlement> deleteRow(
    _i1.Session session,
    GroupEntitlement row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GroupEntitlement>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<GroupEntitlement>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<GroupEntitlementTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<GroupEntitlement>(
      where: where(GroupEntitlement.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GroupEntitlementTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<GroupEntitlement>(
      where: where?.call(GroupEntitlement.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GroupEntitlement] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<GroupEntitlementTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<GroupEntitlement>(
      where: where(GroupEntitlement.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class GroupEntitlementAttachRowRepository {
  const GroupEntitlementAttachRowRepository._();

  /// Creates a relation between the given [GroupEntitlement] and [Entitlement]
  /// by setting the [GroupEntitlement]'s foreign key `entitlementId` to refer to the [Entitlement].
  Future<void> entitlement(
    _i1.Session session,
    GroupEntitlement groupEntitlement,
    _i2.Entitlement entitlement, {
    _i1.Transaction? transaction,
  }) async {
    if (groupEntitlement.id == null) {
      throw ArgumentError.notNull('groupEntitlement.id');
    }
    if (entitlement.id == null) {
      throw ArgumentError.notNull('entitlement.id');
    }

    var $groupEntitlement = groupEntitlement.copyWith(
      entitlementId: entitlement.id,
    );
    await session.db.updateRow<GroupEntitlement>(
      $groupEntitlement,
      columns: [GroupEntitlement.t.entitlementId],
      transaction: transaction,
    );
  }
}
