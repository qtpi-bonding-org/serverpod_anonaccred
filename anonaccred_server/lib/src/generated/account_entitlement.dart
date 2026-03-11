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

abstract class AccountEntitlement
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  AccountEntitlement._({
    this.id,
    required this.accountId,
    required this.entitlementId,
    this.entitlement,
    required this.balance,
  });

  factory AccountEntitlement({
    int? id,
    required int accountId,
    required int entitlementId,
    _i2.Entitlement? entitlement,
    required double balance,
  }) = _AccountEntitlementImpl;

  factory AccountEntitlement.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountEntitlement(
      id: jsonSerialization['id'] as int?,
      accountId: jsonSerialization['accountId'] as int,
      entitlementId: jsonSerialization['entitlementId'] as int,
      entitlement: jsonSerialization['entitlement'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.Entitlement>(
              jsonSerialization['entitlement'],
            ),
      balance: (jsonSerialization['balance'] as num).toDouble(),
    );
  }

  static final t = AccountEntitlementTable();

  static const db = AccountEntitlementRepository._();

  @override
  int? id;

  int accountId;

  int entitlementId;

  _i2.Entitlement? entitlement;

  double balance;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [AccountEntitlement]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AccountEntitlement copyWith({
    int? id,
    int? accountId,
    int? entitlementId,
    _i2.Entitlement? entitlement,
    double? balance,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.AccountEntitlement',
      if (id != null) 'id': id,
      'accountId': accountId,
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
      'accountId': accountId,
      'entitlementId': entitlementId,
      if (entitlement != null) 'entitlement': entitlement?.toJsonForProtocol(),
      'balance': balance,
    };
  }

  static AccountEntitlementInclude include({
    _i2.EntitlementInclude? entitlement,
  }) {
    return AccountEntitlementInclude._(entitlement: entitlement);
  }

  static AccountEntitlementIncludeList includeList({
    _i1.WhereExpressionBuilder<AccountEntitlementTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AccountEntitlementTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AccountEntitlementTable>? orderByList,
    AccountEntitlementInclude? include,
  }) {
    return AccountEntitlementIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccountEntitlement.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AccountEntitlement.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountEntitlementImpl extends AccountEntitlement {
  _AccountEntitlementImpl({
    int? id,
    required int accountId,
    required int entitlementId,
    _i2.Entitlement? entitlement,
    required double balance,
  }) : super._(
         id: id,
         accountId: accountId,
         entitlementId: entitlementId,
         entitlement: entitlement,
         balance: balance,
       );

  /// Returns a shallow copy of this [AccountEntitlement]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AccountEntitlement copyWith({
    Object? id = _Undefined,
    int? accountId,
    int? entitlementId,
    Object? entitlement = _Undefined,
    double? balance,
  }) {
    return AccountEntitlement(
      id: id is int? ? id : this.id,
      accountId: accountId ?? this.accountId,
      entitlementId: entitlementId ?? this.entitlementId,
      entitlement: entitlement is _i2.Entitlement?
          ? entitlement
          : this.entitlement?.copyWith(),
      balance: balance ?? this.balance,
    );
  }
}

class AccountEntitlementUpdateTable
    extends _i1.UpdateTable<AccountEntitlementTable> {
  AccountEntitlementUpdateTable(super.table);

  _i1.ColumnValue<int, int> accountId(int value) => _i1.ColumnValue(
    table.accountId,
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

class AccountEntitlementTable extends _i1.Table<int?> {
  AccountEntitlementTable({super.tableRelation})
    : super(tableName: 'account_entitlement') {
    updateTable = AccountEntitlementUpdateTable(this);
    accountId = _i1.ColumnInt(
      'accountId',
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

  late final AccountEntitlementUpdateTable updateTable;

  late final _i1.ColumnInt accountId;

  late final _i1.ColumnInt entitlementId;

  _i2.EntitlementTable? _entitlement;

  late final _i1.ColumnDouble balance;

  _i2.EntitlementTable get entitlement {
    if (_entitlement != null) return _entitlement!;
    _entitlement = _i1.createRelationTable(
      relationFieldName: 'entitlement',
      field: AccountEntitlement.t.entitlementId,
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
    accountId,
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

class AccountEntitlementInclude extends _i1.IncludeObject {
  AccountEntitlementInclude._({_i2.EntitlementInclude? entitlement}) {
    _entitlement = entitlement;
  }

  _i2.EntitlementInclude? _entitlement;

  @override
  Map<String, _i1.Include?> get includes => {'entitlement': _entitlement};

  @override
  _i1.Table<int?> get table => AccountEntitlement.t;
}

class AccountEntitlementIncludeList extends _i1.IncludeList {
  AccountEntitlementIncludeList._({
    _i1.WhereExpressionBuilder<AccountEntitlementTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AccountEntitlement.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => AccountEntitlement.t;
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AccountEntitlementTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AccountEntitlementTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AccountEntitlementTable>? orderByList,
    _i1.Transaction? transaction,
    AccountEntitlementInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AccountEntitlement>(
      where: where?.call(AccountEntitlement.t),
      orderBy: orderBy?.call(AccountEntitlement.t),
      orderByList: orderByList?.call(AccountEntitlement.t),
      orderDescending: orderDescending,
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AccountEntitlementTable>? where,
    int? offset,
    _i1.OrderByBuilder<AccountEntitlementTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AccountEntitlementTable>? orderByList,
    _i1.Transaction? transaction,
    AccountEntitlementInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AccountEntitlement>(
      where: where?.call(AccountEntitlement.t),
      orderBy: orderBy?.call(AccountEntitlement.t),
      orderByList: orderByList?.call(AccountEntitlement.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AccountEntitlement] by its [id] or null if no such row exists.
  Future<AccountEntitlement?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    AccountEntitlementInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
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
  Future<List<AccountEntitlement>> insert(
    _i1.Session session,
    List<AccountEntitlement> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<AccountEntitlement>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [AccountEntitlement] and returns the inserted row.
  ///
  /// The returned [AccountEntitlement] will have its `id` field set.
  Future<AccountEntitlement> insertRow(
    _i1.Session session,
    AccountEntitlement row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AccountEntitlement>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [AccountEntitlement]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AccountEntitlement>> update(
    _i1.Session session,
    List<AccountEntitlement> rows, {
    _i1.ColumnSelections<AccountEntitlementTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AccountEntitlement>(
      rows,
      columns: columns?.call(AccountEntitlement.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AccountEntitlement]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AccountEntitlement> updateRow(
    _i1.Session session,
    AccountEntitlement row, {
    _i1.ColumnSelections<AccountEntitlementTable>? columns,
    _i1.Transaction? transaction,
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
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<AccountEntitlementUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AccountEntitlement>(
      id,
      columnValues: columnValues(AccountEntitlement.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AccountEntitlement]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AccountEntitlement>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<AccountEntitlementUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<AccountEntitlementTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AccountEntitlementTable>? orderBy,
    _i1.OrderByListBuilder<AccountEntitlementTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AccountEntitlement>(
      columnValues: columnValues(AccountEntitlement.t.updateTable),
      where: where(AccountEntitlement.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccountEntitlement.t),
      orderByList: orderByList?.call(AccountEntitlement.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AccountEntitlement]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AccountEntitlement>> delete(
    _i1.Session session,
    List<AccountEntitlement> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AccountEntitlement>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [AccountEntitlement].
  Future<AccountEntitlement> deleteRow(
    _i1.Session session,
    AccountEntitlement row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AccountEntitlement>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AccountEntitlement>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<AccountEntitlementTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AccountEntitlement>(
      where: where(AccountEntitlement.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AccountEntitlementTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AccountEntitlement>(
      where: where?.call(AccountEntitlement.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AccountEntitlement] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<AccountEntitlementTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
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
    _i1.Session session,
    AccountEntitlement accountEntitlement,
    _i2.Entitlement entitlement, {
    _i1.Transaction? transaction,
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
