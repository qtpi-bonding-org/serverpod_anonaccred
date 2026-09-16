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

abstract class AccountEntitlement
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  AccountEntitlement._({
    this.id,
    required this.accountUuid,
    required this.entitlementId,
    this.entitlement,
    required this.balance,
  });

  factory AccountEntitlement({
    int? id,
    required _is.UuidValue accountUuid,
    required int entitlementId,
    _ico1e66l.Entitlement? entitlement,
    required double balance,
  }) = _AccountEntitlementImpl;

  factory AccountEntitlement.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountEntitlement(
      id: jsonSerialization['id'] as int?,
      accountUuid: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountUuid'],
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

  static final t = AccountEntitlementTable();

  static const db = AccountEntitlementRepository._();

  @override
  int? id;

  _is.UuidValue accountUuid;

  int entitlementId;

  _ico1e66l.Entitlement? entitlement;

  double balance;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AccountEntitlement]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AccountEntitlement copyWith({
    int? id,
    _is.UuidValue? accountUuid,
    int? entitlementId,
    _ico1e66l.Entitlement? entitlement,
    double? balance,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.AccountEntitlement',
      if (id != null) 'id': id,
      'accountUuid': accountUuid.toJson(),
      'entitlementId': entitlementId,
      if (entitlement != null) 'entitlement': entitlement?.toJson(),
      'balance': balance,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.AccountEntitlement',
      if (id != null) 'id': id,
      'accountUuid': accountUuid.toJson(),
      'entitlementId': entitlementId,
      if (entitlement != null) 'entitlement': entitlement?.toJsonForProtocol(),
      'balance': balance,
    };
  }

  static AccountEntitlementInclude include({
    _ico1e66l.EntitlementInclude? entitlement,
  }) {
    return AccountEntitlementInclude._(entitlement: entitlement);
  }

  static AccountEntitlementIncludeList includeList({
    _is.WhereExpressionBuilder<AccountEntitlementTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountEntitlementTable>? orderBy,
    _is.OrderByListBuilder<AccountEntitlementTable>? orderByList,
    AccountEntitlementInclude? include,
  }) {
    return AccountEntitlementIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccountEntitlement.t),
      orderByList: orderByList?.call(AccountEntitlement.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountEntitlementImpl extends AccountEntitlement {
  _AccountEntitlementImpl({
    int? id,
    required _is.UuidValue accountUuid,
    required int entitlementId,
    _ico1e66l.Entitlement? entitlement,
    required double balance,
  }) : super._(
         id: id,
         accountUuid: accountUuid,
         entitlementId: entitlementId,
         entitlement: entitlement,
         balance: balance,
       );

  /// Returns a shallow copy of this [AccountEntitlement]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AccountEntitlement copyWith({
    Object? id = _Undefined,
    _is.UuidValue? accountUuid,
    int? entitlementId,
    Object? entitlement = _Undefined,
    double? balance,
  }) {
    return AccountEntitlement(
      id: id is int? ? id : this.id,
      accountUuid: accountUuid ?? this.accountUuid,
      entitlementId: entitlementId ?? this.entitlementId,
      entitlement: entitlement is _ico1e66l.Entitlement?
          ? entitlement
          : this.entitlement?.copyWith(),
      balance: balance ?? this.balance,
    );
  }
}

class AccountEntitlementUpdateTable
    extends _is.UpdateTable<AccountEntitlementTable> {
  AccountEntitlementUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> accountUuid(
    _is.UuidValue value,
  ) => _is.ColumnValue(table.accountUuid, value);

  _is.ColumnValue<int, int> entitlementId(int value) =>
      _is.ColumnValue(table.entitlementId, value);

  _is.ColumnValue<double, double> balance(double value) =>
      _is.ColumnValue(table.balance, value);
}

class AccountEntitlementTable extends _is.Table<int?> {
  AccountEntitlementTable({super.tableRelation})
    : super(tableName: 'account_entitlement') {
    updateTable = AccountEntitlementUpdateTable(this);
    accountUuid = _is.ColumnUuid('accountUuid', this);
    entitlementId = _is.ColumnInt('entitlementId', this);
    balance = _is.ColumnDouble('balance', this);
  }

  late final AccountEntitlementUpdateTable updateTable;

  late final _is.ColumnUuid accountUuid;

  late final _is.ColumnInt entitlementId;

  _ico1e66l.EntitlementTable? _entitlement;

  late final _is.ColumnDouble balance;

  _ico1e66l.EntitlementTable get entitlement {
    if (_entitlement != null) return _entitlement!;
    _entitlement = _is.createRelationTable(
      relationFieldName: 'entitlement',
      field: AccountEntitlement.t.entitlementId,
      foreignField: _ico1e66l.Entitlement.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _ico1e66l.EntitlementTable(tableRelation: foreignTableRelation),
    );
    return _entitlement!;
  }

  @override
  List<_is.Column> get columns => [id, accountUuid, entitlementId, balance];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'entitlement') {
      return entitlement;
    }
    return null;
  }
}

class AccountEntitlementInclude extends _is.IncludeObject {
  AccountEntitlementInclude._({_ico1e66l.EntitlementInclude? entitlement}) {
    _entitlement = entitlement;
  }

  _ico1e66l.EntitlementInclude? _entitlement;

  @override
  Map<String, _is.Include?> get includes => {'entitlement': _entitlement};

  @override
  _is.Table<int?> get table => AccountEntitlement.t;
}

class AccountEntitlementIncludeList extends _is.IncludeList {
  AccountEntitlementIncludeList._({
    _is.WhereExpressionBuilder<AccountEntitlementTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AccountEntitlement.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AccountEntitlement.t;
}

class AccountEntitlementRepository {
  const AccountEntitlementRepository._();

  final attachRow = const AccountEntitlementAttachRowRepository._();

  /// Returns a list of [AccountEntitlement]s matching the given query parameters.
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
  Future<List<AccountEntitlement>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountEntitlementTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountEntitlementTable>? orderBy,
    _is.OrderByListBuilder<AccountEntitlementTable>? orderByList,
    _is.Transaction? transaction,
    AccountEntitlementInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AccountEntitlement>(
      where: where?.call(AccountEntitlement.t),
      orderBy: orderBy?.call(AccountEntitlement.t),
      orderByList: orderByList?.call(AccountEntitlement.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AccountEntitlement] matching the given query parameters.
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
  Future<AccountEntitlement?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountEntitlementTable>? where,
    int? offset,
    _is.OrderByBuilder<AccountEntitlementTable>? orderBy,
    _is.OrderByListBuilder<AccountEntitlementTable>? orderByList,
    _is.Transaction? transaction,
    AccountEntitlementInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AccountEntitlement>(
      where: where?.call(AccountEntitlement.t),
      orderBy: orderBy?.call(AccountEntitlement.t),
      orderByList: orderByList?.call(AccountEntitlement.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AccountEntitlement] by its [id] or null if no such row exists.
  Future<AccountEntitlement?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    AccountEntitlementInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AccountEntitlement>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AccountEntitlement]s in the list and returns the inserted rows.
  ///
  /// The returned [AccountEntitlement]s will have their `id` fields set.
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
  Future<List<AccountEntitlement>> insert(
    _is.DatabaseSession session,
    List<AccountEntitlement> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AccountEntitlement>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AccountEntitlement] and returns the inserted row.
  ///
  /// The returned [AccountEntitlement] will have its `id` field set.
  Future<AccountEntitlement> insertRow(
    _is.DatabaseSession session,
    AccountEntitlement row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AccountEntitlement>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AccountEntitlement]s in the list and returns the resulting rows.
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
  /// The returned [AccountEntitlement]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccountEntitlement>> upsert(
    _is.DatabaseSession session,
    List<AccountEntitlement> rows, {
    required _is.ColumnSelections<AccountEntitlementTable> conflictColumns,
    _is.ColumnSelections<AccountEntitlementTable>? updateColumns,
    _is.WhereExpressionBuilder<AccountEntitlementTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AccountEntitlement>(
      rows,
      conflictColumns: conflictColumns(AccountEntitlement.t),
      updateColumns: updateColumns?.call(AccountEntitlement.t),
      updateWhere: updateWhere?.call(AccountEntitlement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AccountEntitlement] and returns the resulting row.
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
  /// The returned [AccountEntitlement] will have its `id` field set.
  Future<AccountEntitlement?> upsertRow(
    _is.DatabaseSession session,
    AccountEntitlement row, {
    required _is.ColumnSelections<AccountEntitlementTable> conflictColumns,
    _is.ColumnSelections<AccountEntitlementTable>? updateColumns,
    _is.WhereExpressionBuilder<AccountEntitlementTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AccountEntitlement>(
      row,
      conflictColumns: conflictColumns(AccountEntitlement.t),
      updateColumns: updateColumns?.call(AccountEntitlement.t),
      updateWhere: updateWhere?.call(AccountEntitlement.t),
      transaction: transaction,
    );
  }

  /// Updates all [AccountEntitlement]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccountEntitlement>> update(
    _is.DatabaseSession session,
    List<AccountEntitlement> rows, {
    _is.ColumnSelections<AccountEntitlementTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AccountEntitlement>(
      rows,
      columns: columns?.call(AccountEntitlement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AccountEntitlement]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AccountEntitlement> updateRow(
    _is.DatabaseSession session,
    AccountEntitlement row, {
    _is.ColumnSelections<AccountEntitlementTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AccountEntitlement>(
      row,
      columns: columns?.call(AccountEntitlement.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AccountEntitlement] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AccountEntitlement?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AccountEntitlementUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AccountEntitlement>(
      id,
      columnValues: columnValues(AccountEntitlement.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AccountEntitlement]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccountEntitlement>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AccountEntitlementUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<AccountEntitlementTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountEntitlementTable>? orderBy,
    _is.OrderByListBuilder<AccountEntitlementTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AccountEntitlement>(
      columnValues: columnValues(AccountEntitlement.t.updateTable),
      where: where(AccountEntitlement.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccountEntitlement.t),
      orderByList: orderByList?.call(AccountEntitlement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AccountEntitlement]s in the list and returns the deleted rows.
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
  Future<List<AccountEntitlement>> delete(
    _is.DatabaseSession session,
    List<AccountEntitlement> rows, {
    _is.OrderByBuilder<AccountEntitlementTable>? orderBy,
    _is.OrderByListBuilder<AccountEntitlementTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AccountEntitlement>(
      rows,
      orderBy: orderBy?.call(AccountEntitlement.t),
      orderByList: orderByList?.call(AccountEntitlement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AccountEntitlement].
  Future<AccountEntitlement> deleteRow(
    _is.DatabaseSession session,
    AccountEntitlement row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AccountEntitlement>(
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
  Future<List<AccountEntitlement>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AccountEntitlementTable> where,
    _is.OrderByBuilder<AccountEntitlementTable>? orderBy,
    _is.OrderByListBuilder<AccountEntitlementTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AccountEntitlement>(
      where: where(AccountEntitlement.t),
      orderBy: orderBy?.call(AccountEntitlement.t),
      orderByList: orderByList?.call(AccountEntitlement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountEntitlementTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AccountEntitlement>(
      where: where?.call(AccountEntitlement.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AccountEntitlement] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AccountEntitlementTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AccountEntitlement>(
      where: where(AccountEntitlement.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class AccountEntitlementAttachRowRepository {
  const AccountEntitlementAttachRowRepository._();

  /// Creates a relation between the given [AccountEntitlement] and [Entitlement]
  /// by setting the [AccountEntitlement]'s foreign key `entitlementId` to refer to the [Entitlement].
  Future<void> entitlement(
    _is.DatabaseSession session,
    AccountEntitlement accountEntitlement,
    _ico1e66l.Entitlement entitlement, {
    _is.Transaction? transaction,
  }) async {
    if (accountEntitlement.id == null) {
      throw ArgumentError.notNull('accountEntitlement.id');
    }
    if (entitlement.id == null) {
      throw ArgumentError.notNull('entitlement.id');
    }

    var $accountEntitlement = accountEntitlement.copyWith(
      entitlementId: entitlement.id,
    );
    await session.db.updateRow<AccountEntitlement>(
      $accountEntitlement,
      columns: [AccountEntitlement.t.entitlementId],
      transaction: transaction,
    );
  }
}
