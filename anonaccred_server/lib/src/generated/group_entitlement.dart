/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:anonaccred_server/src/generated/protocol.dart' as _irewcktm;
import 'package:serverpod/serverpod.dart' as _is;
import 'entitlement.dart' as _ico1e66l;

abstract class GroupEntitlement
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  GroupEntitlement._({
    this.id,
    required this.shareGroupUuid,
    required this.entitlementId,
    this.entitlement,
    required this.balance,
  });

  factory GroupEntitlement({
    int? id,
    required _is.UuidValue shareGroupUuid,
    required int entitlementId,
    _ico1e66l.Entitlement? entitlement,
    required double balance,
  }) = _GroupEntitlementImpl;

  factory GroupEntitlement.fromJson(Map<String, dynamic> jsonSerialization) {
    return GroupEntitlement(
      id: jsonSerialization['id'] as int?,
      shareGroupUuid: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['shareGroupUuid'],
      ),
      entitlementId: jsonSerialization['entitlementId'] as int,
      entitlement: jsonSerialization['entitlement'] == null
          ? null
          : _irewcktm.Protocol().deserialize<_ico1e66l.Entitlement>(
              jsonSerialization['entitlement'],
            ),
      balance: (jsonSerialization['balance'] as num).toDouble(),
    );
  }

  static final t = GroupEntitlementTable();

  static const db = GroupEntitlementRepository._();

  @override
  int? id;

  _is.UuidValue shareGroupUuid;

  int entitlementId;

  _ico1e66l.Entitlement? entitlement;

  double balance;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [GroupEntitlement]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  GroupEntitlement copyWith({
    int? id,
    _is.UuidValue? shareGroupUuid,
    int? entitlementId,
    _ico1e66l.Entitlement? entitlement,
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
    _ico1e66l.EntitlementInclude? entitlement,
  }) {
    return GroupEntitlementInclude._(entitlement: entitlement);
  }

  static GroupEntitlementIncludeList includeList({
    _is.WhereExpressionBuilder<GroupEntitlementTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupEntitlementTable>? orderBy,
    _is.OrderByListBuilder<GroupEntitlementTable>? orderByList,
    GroupEntitlementInclude? include,
  }) {
    return GroupEntitlementIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupEntitlement.t),
      orderByList: orderByList?.call(GroupEntitlement.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupEntitlementImpl extends GroupEntitlement {
  _GroupEntitlementImpl({
    int? id,
    required _is.UuidValue shareGroupUuid,
    required int entitlementId,
    _ico1e66l.Entitlement? entitlement,
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
  @_is.useResult
  @override
  GroupEntitlement copyWith({
    Object? id = _Undefined,
    _is.UuidValue? shareGroupUuid,
    int? entitlementId,
    Object? entitlement = _Undefined,
    double? balance,
  }) {
    return GroupEntitlement(
      id: id is int? ? id : this.id,
      shareGroupUuid: shareGroupUuid ?? this.shareGroupUuid,
      entitlementId: entitlementId ?? this.entitlementId,
      entitlement: entitlement is _ico1e66l.Entitlement?
          ? entitlement
          : this.entitlement?.copyWith(),
      balance: balance ?? this.balance,
    );
  }
}

class GroupEntitlementUpdateTable
    extends _is.UpdateTable<GroupEntitlementTable> {
  GroupEntitlementUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> shareGroupUuid(
    _is.UuidValue value,
  ) => _is.ColumnValue(table.shareGroupUuid, value);

  _is.ColumnValue<int, int> entitlementId(int value) =>
      _is.ColumnValue(table.entitlementId, value);

  _is.ColumnValue<double, double> balance(double value) =>
      _is.ColumnValue(table.balance, value);
}

class GroupEntitlementTable extends _is.Table<int?> {
  GroupEntitlementTable({super.tableRelation})
    : super(tableName: 'group_entitlement') {
    updateTable = GroupEntitlementUpdateTable(this);
    shareGroupUuid = _is.ColumnUuid('shareGroupUuid', this);
    entitlementId = _is.ColumnInt('entitlementId', this);
    balance = _is.ColumnDouble('balance', this);
  }

  late final GroupEntitlementUpdateTable updateTable;

  late final _is.ColumnUuid shareGroupUuid;

  late final _is.ColumnInt entitlementId;

  _ico1e66l.EntitlementTable? _entitlement;

  late final _is.ColumnDouble balance;

  _ico1e66l.EntitlementTable get entitlement {
    if (_entitlement != null) return _entitlement!;
    _entitlement = _is.createRelationTable(
      relationFieldName: 'entitlement',
      field: GroupEntitlement.t.entitlementId,
      foreignField: _ico1e66l.Entitlement.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _ico1e66l.EntitlementTable(tableRelation: foreignTableRelation),
    );
    return _entitlement!;
  }

  @override
  List<_is.Column> get columns => [id, shareGroupUuid, entitlementId, balance];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'entitlement') {
      return entitlement;
    }
    return null;
  }
}

class GroupEntitlementInclude extends _is.IncludeObject {
  GroupEntitlementInclude._({_ico1e66l.EntitlementInclude? entitlement}) {
    _entitlement = entitlement;
  }

  _ico1e66l.EntitlementInclude? _entitlement;

  @override
  Map<String, _is.Include?> get includes => {'entitlement': _entitlement};

  @override
  _is.Table<int?> get table => GroupEntitlement.t;
}

class GroupEntitlementIncludeList extends _is.IncludeList {
  GroupEntitlementIncludeList._({
    _is.WhereExpressionBuilder<GroupEntitlementTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GroupEntitlement.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => GroupEntitlement.t;
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupEntitlementTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupEntitlementTable>? orderBy,
    _is.OrderByListBuilder<GroupEntitlementTable>? orderByList,
    _is.Transaction? transaction,
    GroupEntitlementInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GroupEntitlement>(
      where: where?.call(GroupEntitlement.t),
      orderBy: orderBy?.call(GroupEntitlement.t),
      orderByList: orderByList?.call(GroupEntitlement.t),
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupEntitlementTable>? where,
    int? offset,
    _is.OrderByBuilder<GroupEntitlementTable>? orderBy,
    _is.OrderByListBuilder<GroupEntitlementTable>? orderByList,
    _is.Transaction? transaction,
    GroupEntitlementInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GroupEntitlement>(
      where: where?.call(GroupEntitlement.t),
      orderBy: orderBy?.call(GroupEntitlement.t),
      orderByList: orderByList?.call(GroupEntitlement.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GroupEntitlement] by its [id] or null if no such row exists.
  Future<GroupEntitlement?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    GroupEntitlementInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupEntitlement>> insert(
    _is.DatabaseSession session,
    List<GroupEntitlement> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<GroupEntitlement>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [GroupEntitlement] and returns the inserted row.
  ///
  /// The returned [GroupEntitlement] will have its `id` field set.
  Future<GroupEntitlement> insertRow(
    _is.DatabaseSession session,
    GroupEntitlement row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<GroupEntitlement>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [GroupEntitlement]s in the list and returns the resulting rows.
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
  /// The returned [GroupEntitlement]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupEntitlement>> upsert(
    _is.DatabaseSession session,
    List<GroupEntitlement> rows, {
    required _is.ColumnSelections<GroupEntitlementTable> conflictColumns,
    _is.ColumnSelections<GroupEntitlementTable>? updateColumns,
    _is.WhereExpressionBuilder<GroupEntitlementTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<GroupEntitlement>(
      rows,
      conflictColumns: conflictColumns(GroupEntitlement.t),
      updateColumns: updateColumns?.call(GroupEntitlement.t),
      updateWhere: updateWhere?.call(GroupEntitlement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [GroupEntitlement] and returns the resulting row.
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
  /// The returned [GroupEntitlement] will have its `id` field set.
  Future<GroupEntitlement?> upsertRow(
    _is.DatabaseSession session,
    GroupEntitlement row, {
    required _is.ColumnSelections<GroupEntitlementTable> conflictColumns,
    _is.ColumnSelections<GroupEntitlementTable>? updateColumns,
    _is.WhereExpressionBuilder<GroupEntitlementTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<GroupEntitlement>(
      row,
      conflictColumns: conflictColumns(GroupEntitlement.t),
      updateColumns: updateColumns?.call(GroupEntitlement.t),
      updateWhere: updateWhere?.call(GroupEntitlement.t),
      transaction: transaction,
    );
  }

  /// Updates all [GroupEntitlement]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupEntitlement>> update(
    _is.DatabaseSession session,
    List<GroupEntitlement> rows, {
    _is.ColumnSelections<GroupEntitlementTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<GroupEntitlement>(
      rows,
      columns: columns?.call(GroupEntitlement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [GroupEntitlement]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GroupEntitlement> updateRow(
    _is.DatabaseSession session,
    GroupEntitlement row, {
    _is.ColumnSelections<GroupEntitlementTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<GroupEntitlementUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<GroupEntitlement>(
      id,
      columnValues: columnValues(GroupEntitlement.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GroupEntitlement]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupEntitlement>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<GroupEntitlementUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<GroupEntitlementTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupEntitlementTable>? orderBy,
    _is.OrderByListBuilder<GroupEntitlementTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<GroupEntitlement>(
      columnValues: columnValues(GroupEntitlement.t.updateTable),
      where: where(GroupEntitlement.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupEntitlement.t),
      orderByList: orderByList?.call(GroupEntitlement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [GroupEntitlement]s in the list and returns the deleted rows.
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
  Future<List<GroupEntitlement>> delete(
    _is.DatabaseSession session,
    List<GroupEntitlement> rows, {
    _is.OrderByBuilder<GroupEntitlementTable>? orderBy,
    _is.OrderByListBuilder<GroupEntitlementTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<GroupEntitlement>(
      rows,
      orderBy: orderBy?.call(GroupEntitlement.t),
      orderByList: orderByList?.call(GroupEntitlement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [GroupEntitlement].
  Future<GroupEntitlement> deleteRow(
    _is.DatabaseSession session,
    GroupEntitlement row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GroupEntitlement>(
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
  Future<List<GroupEntitlement>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GroupEntitlementTable> where,
    _is.OrderByBuilder<GroupEntitlementTable>? orderBy,
    _is.OrderByListBuilder<GroupEntitlementTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<GroupEntitlement>(
      where: where(GroupEntitlement.t),
      orderBy: orderBy?.call(GroupEntitlement.t),
      orderByList: orderByList?.call(GroupEntitlement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupEntitlementTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<GroupEntitlement>(
      where: where?.call(GroupEntitlement.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GroupEntitlement] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GroupEntitlementTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
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
    _is.DatabaseSession session,
    GroupEntitlement groupEntitlement,
    _ico1e66l.Entitlement entitlement, {
    _is.Transaction? transaction,
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
