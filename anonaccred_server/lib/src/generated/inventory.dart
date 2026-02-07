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

abstract class AccountInventory
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  AccountInventory._({
    this.id,
    required this.accountId,
    required this.consumableType,
    required this.quantity,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory AccountInventory({
    int? id,
    required int accountId,
    required String consumableType,
    required double quantity,
    DateTime? lastUpdated,
  }) = _AccountInventoryImpl;

  factory AccountInventory.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountInventory(
      id: jsonSerialization['id'] as int?,
      accountId: jsonSerialization['accountId'] as int,
      consumableType: jsonSerialization['consumableType'] as String,
      quantity: (jsonSerialization['quantity'] as num).toDouble(),
      lastUpdated: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastUpdated'],
      ),
    );
  }

  static final t = AccountInventoryTable();

  static const db = AccountInventoryRepository._();

  @override
  int? id;

  int accountId;

  String consumableType;

  double quantity;

  DateTime lastUpdated;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [AccountInventory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AccountInventory copyWith({
    int? id,
    int? accountId,
    String? consumableType,
    double? quantity,
    DateTime? lastUpdated,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.AccountInventory',
      if (id != null) 'id': id,
      'accountId': accountId,
      'consumableType': consumableType,
      'quantity': quantity,
      'lastUpdated': lastUpdated.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.AccountInventory',
      if (id != null) 'id': id,
      'accountId': accountId,
      'consumableType': consumableType,
      'quantity': quantity,
      'lastUpdated': lastUpdated.toJson(),
    };
  }

  static AccountInventoryInclude include() {
    return AccountInventoryInclude._();
  }

  static AccountInventoryIncludeList includeList({
    _i1.WhereExpressionBuilder<AccountInventoryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AccountInventoryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AccountInventoryTable>? orderByList,
    AccountInventoryInclude? include,
  }) {
    return AccountInventoryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccountInventory.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AccountInventory.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountInventoryImpl extends AccountInventory {
  _AccountInventoryImpl({
    int? id,
    required int accountId,
    required String consumableType,
    required double quantity,
    DateTime? lastUpdated,
  }) : super._(
         id: id,
         accountId: accountId,
         consumableType: consumableType,
         quantity: quantity,
         lastUpdated: lastUpdated,
       );

  /// Returns a shallow copy of this [AccountInventory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AccountInventory copyWith({
    Object? id = _Undefined,
    int? accountId,
    String? consumableType,
    double? quantity,
    DateTime? lastUpdated,
  }) {
    return AccountInventory(
      id: id is int? ? id : this.id,
      accountId: accountId ?? this.accountId,
      consumableType: consumableType ?? this.consumableType,
      quantity: quantity ?? this.quantity,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class AccountInventoryUpdateTable
    extends _i1.UpdateTable<AccountInventoryTable> {
  AccountInventoryUpdateTable(super.table);

  _i1.ColumnValue<int, int> accountId(int value) => _i1.ColumnValue(
    table.accountId,
    value,
  );

  _i1.ColumnValue<String, String> consumableType(String value) =>
      _i1.ColumnValue(
        table.consumableType,
        value,
      );

  _i1.ColumnValue<double, double> quantity(double value) => _i1.ColumnValue(
    table.quantity,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> lastUpdated(DateTime value) =>
      _i1.ColumnValue(
        table.lastUpdated,
        value,
      );
}

class AccountInventoryTable extends _i1.Table<int?> {
  AccountInventoryTable({super.tableRelation})
    : super(tableName: 'account_inventory') {
    updateTable = AccountInventoryUpdateTable(this);
    accountId = _i1.ColumnInt(
      'accountId',
      this,
    );
    consumableType = _i1.ColumnString(
      'consumableType',
      this,
    );
    quantity = _i1.ColumnDouble(
      'quantity',
      this,
    );
    lastUpdated = _i1.ColumnDateTime(
      'lastUpdated',
      this,
      hasDefault: true,
    );
  }

  late final AccountInventoryUpdateTable updateTable;

  late final _i1.ColumnInt accountId;

  late final _i1.ColumnString consumableType;

  late final _i1.ColumnDouble quantity;

  late final _i1.ColumnDateTime lastUpdated;

  @override
  List<_i1.Column> get columns => [
    id,
    accountId,
    consumableType,
    quantity,
    lastUpdated,
  ];
}

class AccountInventoryInclude extends _i1.IncludeObject {
  AccountInventoryInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => AccountInventory.t;
}

class AccountInventoryIncludeList extends _i1.IncludeList {
  AccountInventoryIncludeList._({
    _i1.WhereExpressionBuilder<AccountInventoryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AccountInventory.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => AccountInventory.t;
}

class AccountInventoryRepository {
  const AccountInventoryRepository._();

  /// Returns a list of [AccountInventory]s matching the given query parameters.
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
  Future<List<AccountInventory>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AccountInventoryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AccountInventoryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AccountInventoryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<AccountInventory>(
      where: where?.call(AccountInventory.t),
      orderBy: orderBy?.call(AccountInventory.t),
      orderByList: orderByList?.call(AccountInventory.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [AccountInventory] matching the given query parameters.
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
  Future<AccountInventory?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AccountInventoryTable>? where,
    int? offset,
    _i1.OrderByBuilder<AccountInventoryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AccountInventoryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<AccountInventory>(
      where: where?.call(AccountInventory.t),
      orderBy: orderBy?.call(AccountInventory.t),
      orderByList: orderByList?.call(AccountInventory.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [AccountInventory] by its [id] or null if no such row exists.
  Future<AccountInventory?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<AccountInventory>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [AccountInventory]s in the list and returns the inserted rows.
  ///
  /// The returned [AccountInventory]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<AccountInventory>> insert(
    _i1.Session session,
    List<AccountInventory> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<AccountInventory>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [AccountInventory] and returns the inserted row.
  ///
  /// The returned [AccountInventory] will have its `id` field set.
  Future<AccountInventory> insertRow(
    _i1.Session session,
    AccountInventory row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AccountInventory>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [AccountInventory]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AccountInventory>> update(
    _i1.Session session,
    List<AccountInventory> rows, {
    _i1.ColumnSelections<AccountInventoryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AccountInventory>(
      rows,
      columns: columns?.call(AccountInventory.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AccountInventory]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AccountInventory> updateRow(
    _i1.Session session,
    AccountInventory row, {
    _i1.ColumnSelections<AccountInventoryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AccountInventory>(
      row,
      columns: columns?.call(AccountInventory.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AccountInventory] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AccountInventory?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<AccountInventoryUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AccountInventory>(
      id,
      columnValues: columnValues(AccountInventory.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AccountInventory]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AccountInventory>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<AccountInventoryUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<AccountInventoryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AccountInventoryTable>? orderBy,
    _i1.OrderByListBuilder<AccountInventoryTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AccountInventory>(
      columnValues: columnValues(AccountInventory.t.updateTable),
      where: where(AccountInventory.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccountInventory.t),
      orderByList: orderByList?.call(AccountInventory.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AccountInventory]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AccountInventory>> delete(
    _i1.Session session,
    List<AccountInventory> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AccountInventory>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [AccountInventory].
  Future<AccountInventory> deleteRow(
    _i1.Session session,
    AccountInventory row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AccountInventory>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AccountInventory>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<AccountInventoryTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AccountInventory>(
      where: where(AccountInventory.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AccountInventoryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AccountInventory>(
      where: where?.call(AccountInventory.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
