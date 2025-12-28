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

abstract class AnonAccount
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  AnonAccount._({
    this.id,
    required this.publicMasterKey,
    required this.encryptedDataKey,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AnonAccount({
    int? id,
    required String publicMasterKey,
    required String encryptedDataKey,
    DateTime? createdAt,
  }) = _AnonAccountImpl;

  factory AnonAccount.fromJson(Map<String, dynamic> jsonSerialization) {
    return AnonAccount(
      id: jsonSerialization['id'] as int?,
      publicMasterKey: jsonSerialization['publicMasterKey'] as String,
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = AnonAccountTable();

  static const db = AnonAccountRepository._();

  @override
  int? id;

  String publicMasterKey;

  String encryptedDataKey;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [AnonAccount]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AnonAccount copyWith({
    int? id,
    String? publicMasterKey,
    String? encryptedDataKey,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.AnonAccount',
      if (id != null) 'id': id,
      'publicMasterKey': publicMasterKey,
      'encryptedDataKey': encryptedDataKey,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.AnonAccount',
      if (id != null) 'id': id,
      'publicMasterKey': publicMasterKey,
      'encryptedDataKey': encryptedDataKey,
      'createdAt': createdAt.toJson(),
    };
  }

  static AnonAccountInclude include() {
    return AnonAccountInclude._();
  }

  static AnonAccountIncludeList includeList({
    _i1.WhereExpressionBuilder<AnonAccountTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AnonAccountTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AnonAccountTable>? orderByList,
    AnonAccountInclude? include,
  }) {
    return AnonAccountIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AnonAccount.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AnonAccount.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AnonAccountImpl extends AnonAccount {
  _AnonAccountImpl({
    int? id,
    required String publicMasterKey,
    required String encryptedDataKey,
    DateTime? createdAt,
  }) : super._(
         id: id,
         publicMasterKey: publicMasterKey,
         encryptedDataKey: encryptedDataKey,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AnonAccount]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AnonAccount copyWith({
    Object? id = _Undefined,
    String? publicMasterKey,
    String? encryptedDataKey,
    DateTime? createdAt,
  }) {
    return AnonAccount(
      id: id is int? ? id : this.id,
      publicMasterKey: publicMasterKey ?? this.publicMasterKey,
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AnonAccountUpdateTable extends _i1.UpdateTable<AnonAccountTable> {
  AnonAccountUpdateTable(super.table);

  _i1.ColumnValue<String, String> publicMasterKey(String value) =>
      _i1.ColumnValue(
        table.publicMasterKey,
        value,
      );

  _i1.ColumnValue<String, String> encryptedDataKey(String value) =>
      _i1.ColumnValue(
        table.encryptedDataKey,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class AnonAccountTable extends _i1.Table<int?> {
  AnonAccountTable({super.tableRelation}) : super(tableName: 'anon_account') {
    updateTable = AnonAccountUpdateTable(this);
    publicMasterKey = _i1.ColumnString(
      'publicMasterKey',
      this,
    );
    encryptedDataKey = _i1.ColumnString(
      'encryptedDataKey',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final AnonAccountUpdateTable updateTable;

  late final _i1.ColumnString publicMasterKey;

  late final _i1.ColumnString encryptedDataKey;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    publicMasterKey,
    encryptedDataKey,
    createdAt,
  ];
}

class AnonAccountInclude extends _i1.IncludeObject {
  AnonAccountInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => AnonAccount.t;
}

class AnonAccountIncludeList extends _i1.IncludeList {
  AnonAccountIncludeList._({
    _i1.WhereExpressionBuilder<AnonAccountTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AnonAccount.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => AnonAccount.t;
}

class AnonAccountRepository {
  const AnonAccountRepository._();

  /// Returns a list of [AnonAccount]s matching the given query parameters.
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
  Future<List<AnonAccount>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AnonAccountTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AnonAccountTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AnonAccountTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<AnonAccount>(
      where: where?.call(AnonAccount.t),
      orderBy: orderBy?.call(AnonAccount.t),
      orderByList: orderByList?.call(AnonAccount.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [AnonAccount] matching the given query parameters.
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
  Future<AnonAccount?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AnonAccountTable>? where,
    int? offset,
    _i1.OrderByBuilder<AnonAccountTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AnonAccountTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<AnonAccount>(
      where: where?.call(AnonAccount.t),
      orderBy: orderBy?.call(AnonAccount.t),
      orderByList: orderByList?.call(AnonAccount.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [AnonAccount] by its [id] or null if no such row exists.
  Future<AnonAccount?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<AnonAccount>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [AnonAccount]s in the list and returns the inserted rows.
  ///
  /// The returned [AnonAccount]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<AnonAccount>> insert(
    _i1.Session session,
    List<AnonAccount> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<AnonAccount>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [AnonAccount] and returns the inserted row.
  ///
  /// The returned [AnonAccount] will have its `id` field set.
  Future<AnonAccount> insertRow(
    _i1.Session session,
    AnonAccount row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AnonAccount>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [AnonAccount]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AnonAccount>> update(
    _i1.Session session,
    List<AnonAccount> rows, {
    _i1.ColumnSelections<AnonAccountTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AnonAccount>(
      rows,
      columns: columns?.call(AnonAccount.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AnonAccount]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AnonAccount> updateRow(
    _i1.Session session,
    AnonAccount row, {
    _i1.ColumnSelections<AnonAccountTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AnonAccount>(
      row,
      columns: columns?.call(AnonAccount.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AnonAccount] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AnonAccount?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<AnonAccountUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AnonAccount>(
      id,
      columnValues: columnValues(AnonAccount.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AnonAccount]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AnonAccount>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<AnonAccountUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<AnonAccountTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AnonAccountTable>? orderBy,
    _i1.OrderByListBuilder<AnonAccountTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AnonAccount>(
      columnValues: columnValues(AnonAccount.t.updateTable),
      where: where(AnonAccount.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AnonAccount.t),
      orderByList: orderByList?.call(AnonAccount.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AnonAccount]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AnonAccount>> delete(
    _i1.Session session,
    List<AnonAccount> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AnonAccount>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [AnonAccount].
  Future<AnonAccount> deleteRow(
    _i1.Session session,
    AnonAccount row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AnonAccount>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AnonAccount>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<AnonAccountTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AnonAccount>(
      where: where(AnonAccount.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AnonAccountTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AnonAccount>(
      where: where?.call(AnonAccount.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
