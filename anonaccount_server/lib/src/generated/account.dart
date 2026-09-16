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

abstract class AnonAccount
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  AnonAccount._({
    this.id,
    required this.ultimateSigningPublicKeyHex,
    required this.encryptedDataKey,
    required this.ultimateEncryptionPublicKeyHex,
    DateTime? createdAt,
    int? keyEpoch,
  }) : createdAt = createdAt ?? DateTime.now(),
       keyEpoch = keyEpoch ?? 0;

  factory AnonAccount({
    _is.UuidValue? id,
    required String ultimateSigningPublicKeyHex,
    required String encryptedDataKey,
    required String ultimateEncryptionPublicKeyHex,
    DateTime? createdAt,
    int? keyEpoch,
  }) = _AnonAccountImpl;

  factory AnonAccount.fromJson(Map<String, dynamic> jsonSerialization) {
    return AnonAccount(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ultimateSigningPublicKeyHex:
          jsonSerialization['ultimateSigningPublicKeyHex'] as String,
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      ultimateEncryptionPublicKeyHex:
          jsonSerialization['ultimateEncryptionPublicKeyHex'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      keyEpoch: jsonSerialization['keyEpoch'] as int?,
    );
  }

  static final t = AnonAccountTable();

  static const db = AnonAccountRepository._();

  @override
  _is.UuidValue? id;

  String ultimateSigningPublicKeyHex;

  String encryptedDataKey;

  String ultimateEncryptionPublicKeyHex;

  DateTime createdAt;

  int keyEpoch;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AnonAccount]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AnonAccount copyWith({
    _is.UuidValue? id,
    String? ultimateSigningPublicKeyHex,
    String? encryptedDataKey,
    String? ultimateEncryptionPublicKeyHex,
    DateTime? createdAt,
    int? keyEpoch,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.AnonAccount',
      if (id != null) 'id': id?.toJson(),
      'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'ultimateEncryptionPublicKeyHex': ultimateEncryptionPublicKeyHex,
      'createdAt': createdAt.toJson(),
      'keyEpoch': keyEpoch,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.AnonAccount',
      if (id != null) 'id': id?.toJson(),
      'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'ultimateEncryptionPublicKeyHex': ultimateEncryptionPublicKeyHex,
      'createdAt': createdAt.toJson(),
      'keyEpoch': keyEpoch,
    };
  }

  static AnonAccountInclude include() {
    return AnonAccountInclude._();
  }

  static AnonAccountIncludeList includeList({
    _is.WhereExpressionBuilder<AnonAccountTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AnonAccountTable>? orderBy,
    _is.OrderByListBuilder<AnonAccountTable>? orderByList,
    AnonAccountInclude? include,
  }) {
    return AnonAccountIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AnonAccount.t),
      orderByList: orderByList?.call(AnonAccount.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AnonAccountImpl extends AnonAccount {
  _AnonAccountImpl({
    _is.UuidValue? id,
    required String ultimateSigningPublicKeyHex,
    required String encryptedDataKey,
    required String ultimateEncryptionPublicKeyHex,
    DateTime? createdAt,
    int? keyEpoch,
  }) : super._(
         id: id,
         ultimateSigningPublicKeyHex: ultimateSigningPublicKeyHex,
         encryptedDataKey: encryptedDataKey,
         ultimateEncryptionPublicKeyHex: ultimateEncryptionPublicKeyHex,
         createdAt: createdAt,
         keyEpoch: keyEpoch,
       );

  /// Returns a shallow copy of this [AnonAccount]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AnonAccount copyWith({
    Object? id = _Undefined,
    String? ultimateSigningPublicKeyHex,
    String? encryptedDataKey,
    String? ultimateEncryptionPublicKeyHex,
    DateTime? createdAt,
    int? keyEpoch,
  }) {
    return AnonAccount(
      id: id is _is.UuidValue? ? id : this.id,
      ultimateSigningPublicKeyHex:
          ultimateSigningPublicKeyHex ?? this.ultimateSigningPublicKeyHex,
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      ultimateEncryptionPublicKeyHex:
          ultimateEncryptionPublicKeyHex ?? this.ultimateEncryptionPublicKeyHex,
      createdAt: createdAt ?? this.createdAt,
      keyEpoch: keyEpoch ?? this.keyEpoch,
    );
  }
}

class AnonAccountUpdateTable extends _is.UpdateTable<AnonAccountTable> {
  AnonAccountUpdateTable(super.table);

  _is.ColumnValue<String, String> ultimateSigningPublicKeyHex(String value) =>
      _is.ColumnValue(table.ultimateSigningPublicKeyHex, value);

  _is.ColumnValue<String, String> encryptedDataKey(String value) =>
      _is.ColumnValue(table.encryptedDataKey, value);

  _is.ColumnValue<String, String> ultimateEncryptionPublicKeyHex(
    String value,
  ) => _is.ColumnValue(table.ultimateEncryptionPublicKeyHex, value);

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(table.createdAt, value);

  _is.ColumnValue<int, int> keyEpoch(int value) =>
      _is.ColumnValue(table.keyEpoch, value);
}

class AnonAccountTable extends _is.Table<_is.UuidValue?> {
  AnonAccountTable({super.tableRelation}) : super(tableName: 'anon_account') {
    updateTable = AnonAccountUpdateTable(this);
    ultimateSigningPublicKeyHex = _is.ColumnString(
      'ultimateSigningPublicKeyHex',
      this,
    );
    encryptedDataKey = _is.ColumnString('encryptedDataKey', this);
    ultimateEncryptionPublicKeyHex = _is.ColumnString(
      'ultimateEncryptionPublicKeyHex',
      this,
    );
    createdAt = _is.ColumnDateTime('createdAt', this, hasDefault: true);
    keyEpoch = _is.ColumnInt('keyEpoch', this, hasDefault: true);
  }

  late final AnonAccountUpdateTable updateTable;

  late final _is.ColumnString ultimateSigningPublicKeyHex;

  late final _is.ColumnString encryptedDataKey;

  late final _is.ColumnString ultimateEncryptionPublicKeyHex;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnInt keyEpoch;

  @override
  List<_is.Column> get columns => [
    id,
    ultimateSigningPublicKeyHex,
    encryptedDataKey,
    ultimateEncryptionPublicKeyHex,
    createdAt,
    keyEpoch,
  ];
}

class AnonAccountInclude extends _is.IncludeObject {
  AnonAccountInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => AnonAccount.t;
}

class AnonAccountIncludeList extends _is.IncludeList {
  AnonAccountIncludeList._({
    _is.WhereExpressionBuilder<AnonAccountTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AnonAccount.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => AnonAccount.t;
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AnonAccountTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AnonAccountTable>? orderBy,
    _is.OrderByListBuilder<AnonAccountTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AnonAccount>(
      where: where?.call(AnonAccount.t),
      orderBy: orderBy?.call(AnonAccount.t),
      orderByList: orderByList?.call(AnonAccount.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AnonAccountTable>? where,
    int? offset,
    _is.OrderByBuilder<AnonAccountTable>? orderBy,
    _is.OrderByListBuilder<AnonAccountTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AnonAccount>(
      where: where?.call(AnonAccount.t),
      orderBy: orderBy?.call(AnonAccount.t),
      orderByList: orderByList?.call(AnonAccount.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AnonAccount] by its [id] or null if no such row exists.
  Future<AnonAccount?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AnonAccount>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AnonAccount]s in the list and returns the inserted rows.
  ///
  /// The returned [AnonAccount]s will have their `id` fields set.
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
  Future<List<AnonAccount>> insert(
    _is.DatabaseSession session,
    List<AnonAccount> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AnonAccount>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AnonAccount] and returns the inserted row.
  ///
  /// The returned [AnonAccount] will have its `id` field set.
  Future<AnonAccount> insertRow(
    _is.DatabaseSession session,
    AnonAccount row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AnonAccount>(row, transaction: transaction);
  }

  /// Upserts all [AnonAccount]s in the list and returns the resulting rows.
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
  /// The returned [AnonAccount]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AnonAccount>> upsert(
    _is.DatabaseSession session,
    List<AnonAccount> rows, {
    required _is.ColumnSelections<AnonAccountTable> conflictColumns,
    _is.ColumnSelections<AnonAccountTable>? updateColumns,
    _is.WhereExpressionBuilder<AnonAccountTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AnonAccount>(
      rows,
      conflictColumns: conflictColumns(AnonAccount.t),
      updateColumns: updateColumns?.call(AnonAccount.t),
      updateWhere: updateWhere?.call(AnonAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AnonAccount] and returns the resulting row.
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
  /// The returned [AnonAccount] will have its `id` field set.
  Future<AnonAccount?> upsertRow(
    _is.DatabaseSession session,
    AnonAccount row, {
    required _is.ColumnSelections<AnonAccountTable> conflictColumns,
    _is.ColumnSelections<AnonAccountTable>? updateColumns,
    _is.WhereExpressionBuilder<AnonAccountTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AnonAccount>(
      row,
      conflictColumns: conflictColumns(AnonAccount.t),
      updateColumns: updateColumns?.call(AnonAccount.t),
      updateWhere: updateWhere?.call(AnonAccount.t),
      transaction: transaction,
    );
  }

  /// Updates all [AnonAccount]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AnonAccount>> update(
    _is.DatabaseSession session,
    List<AnonAccount> rows, {
    _is.ColumnSelections<AnonAccountTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AnonAccount>(
      rows,
      columns: columns?.call(AnonAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AnonAccount]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AnonAccount> updateRow(
    _is.DatabaseSession session,
    AnonAccount row, {
    _is.ColumnSelections<AnonAccountTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<AnonAccountUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AnonAccount>(
      id,
      columnValues: columnValues(AnonAccount.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AnonAccount]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AnonAccount>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AnonAccountUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AnonAccountTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AnonAccountTable>? orderBy,
    _is.OrderByListBuilder<AnonAccountTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AnonAccount>(
      columnValues: columnValues(AnonAccount.t.updateTable),
      where: where(AnonAccount.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AnonAccount.t),
      orderByList: orderByList?.call(AnonAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AnonAccount]s in the list and returns the deleted rows.
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
  Future<List<AnonAccount>> delete(
    _is.DatabaseSession session,
    List<AnonAccount> rows, {
    _is.OrderByBuilder<AnonAccountTable>? orderBy,
    _is.OrderByListBuilder<AnonAccountTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AnonAccount>(
      rows,
      orderBy: orderBy?.call(AnonAccount.t),
      orderByList: orderByList?.call(AnonAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AnonAccount].
  Future<AnonAccount> deleteRow(
    _is.DatabaseSession session,
    AnonAccount row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AnonAccount>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AnonAccount>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AnonAccountTable> where,
    _is.OrderByBuilder<AnonAccountTable>? orderBy,
    _is.OrderByListBuilder<AnonAccountTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AnonAccount>(
      where: where(AnonAccount.t),
      orderBy: orderBy?.call(AnonAccount.t),
      orderByList: orderByList?.call(AnonAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AnonAccountTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AnonAccount>(
      where: where?.call(AnonAccount.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AnonAccount] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AnonAccountTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AnonAccount>(
      where: where(AnonAccount.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
