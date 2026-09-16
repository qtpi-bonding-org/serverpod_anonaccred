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

abstract class ShareGroup
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  ShareGroup._({
    this.id,
    required this.ultimateSigningPublicKeyHex,
    required this.ultimateEncryptionPublicKeyHex,
    required this.encryptedDataKey,
    DateTime? createdAt,
    int? keyEpoch,
  }) : createdAt = createdAt ?? DateTime.now(),
       keyEpoch = keyEpoch ?? 0;

  factory ShareGroup({
    _is.UuidValue? id,
    required String ultimateSigningPublicKeyHex,
    required String ultimateEncryptionPublicKeyHex,
    required String encryptedDataKey,
    DateTime? createdAt,
    int? keyEpoch,
  }) = _ShareGroupImpl;

  factory ShareGroup.fromJson(Map<String, dynamic> jsonSerialization) {
    return ShareGroup(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ultimateSigningPublicKeyHex:
          jsonSerialization['ultimateSigningPublicKeyHex'] as String,
      ultimateEncryptionPublicKeyHex:
          jsonSerialization['ultimateEncryptionPublicKeyHex'] as String,
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      keyEpoch: jsonSerialization['keyEpoch'] as int?,
    );
  }

  static final t = ShareGroupTable();

  static const db = ShareGroupRepository._();

  @override
  _is.UuidValue? id;

  String ultimateSigningPublicKeyHex;

  String ultimateEncryptionPublicKeyHex;

  String encryptedDataKey;

  DateTime createdAt;

  int keyEpoch;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [ShareGroup]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ShareGroup copyWith({
    _is.UuidValue? id,
    String? ultimateSigningPublicKeyHex,
    String? ultimateEncryptionPublicKeyHex,
    String? encryptedDataKey,
    DateTime? createdAt,
    int? keyEpoch,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.ShareGroup',
      if (id != null) 'id': id?.toJson(),
      'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
      'ultimateEncryptionPublicKeyHex': ultimateEncryptionPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'createdAt': createdAt.toJson(),
      'keyEpoch': keyEpoch,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.ShareGroup',
      if (id != null) 'id': id?.toJson(),
      'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
      'ultimateEncryptionPublicKeyHex': ultimateEncryptionPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'createdAt': createdAt.toJson(),
      'keyEpoch': keyEpoch,
    };
  }

  static ShareGroupInclude include() {
    return ShareGroupInclude._();
  }

  static ShareGroupIncludeList includeList({
    _is.WhereExpressionBuilder<ShareGroupTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ShareGroupTable>? orderBy,
    _is.OrderByListBuilder<ShareGroupTable>? orderByList,
    ShareGroupInclude? include,
  }) {
    return ShareGroupIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ShareGroup.t),
      orderByList: orderByList?.call(ShareGroup.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ShareGroupImpl extends ShareGroup {
  _ShareGroupImpl({
    _is.UuidValue? id,
    required String ultimateSigningPublicKeyHex,
    required String ultimateEncryptionPublicKeyHex,
    required String encryptedDataKey,
    DateTime? createdAt,
    int? keyEpoch,
  }) : super._(
         id: id,
         ultimateSigningPublicKeyHex: ultimateSigningPublicKeyHex,
         ultimateEncryptionPublicKeyHex: ultimateEncryptionPublicKeyHex,
         encryptedDataKey: encryptedDataKey,
         createdAt: createdAt,
         keyEpoch: keyEpoch,
       );

  /// Returns a shallow copy of this [ShareGroup]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ShareGroup copyWith({
    Object? id = _Undefined,
    String? ultimateSigningPublicKeyHex,
    String? ultimateEncryptionPublicKeyHex,
    String? encryptedDataKey,
    DateTime? createdAt,
    int? keyEpoch,
  }) {
    return ShareGroup(
      id: id is _is.UuidValue? ? id : this.id,
      ultimateSigningPublicKeyHex:
          ultimateSigningPublicKeyHex ?? this.ultimateSigningPublicKeyHex,
      ultimateEncryptionPublicKeyHex:
          ultimateEncryptionPublicKeyHex ?? this.ultimateEncryptionPublicKeyHex,
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      createdAt: createdAt ?? this.createdAt,
      keyEpoch: keyEpoch ?? this.keyEpoch,
    );
  }
}

class ShareGroupUpdateTable extends _is.UpdateTable<ShareGroupTable> {
  ShareGroupUpdateTable(super.table);

  _is.ColumnValue<String, String> ultimateSigningPublicKeyHex(String value) =>
      _is.ColumnValue(table.ultimateSigningPublicKeyHex, value);

  _is.ColumnValue<String, String> ultimateEncryptionPublicKeyHex(
    String value,
  ) => _is.ColumnValue(table.ultimateEncryptionPublicKeyHex, value);

  _is.ColumnValue<String, String> encryptedDataKey(String value) =>
      _is.ColumnValue(table.encryptedDataKey, value);

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(table.createdAt, value);

  _is.ColumnValue<int, int> keyEpoch(int value) =>
      _is.ColumnValue(table.keyEpoch, value);
}

class ShareGroupTable extends _is.Table<_is.UuidValue?> {
  ShareGroupTable({super.tableRelation}) : super(tableName: 'share_group') {
    updateTable = ShareGroupUpdateTable(this);
    ultimateSigningPublicKeyHex = _is.ColumnString(
      'ultimateSigningPublicKeyHex',
      this,
    );
    ultimateEncryptionPublicKeyHex = _is.ColumnString(
      'ultimateEncryptionPublicKeyHex',
      this,
    );
    encryptedDataKey = _is.ColumnString('encryptedDataKey', this);
    createdAt = _is.ColumnDateTime('createdAt', this, hasDefault: true);
    keyEpoch = _is.ColumnInt('keyEpoch', this, hasDefault: true);
  }

  late final ShareGroupUpdateTable updateTable;

  late final _is.ColumnString ultimateSigningPublicKeyHex;

  late final _is.ColumnString ultimateEncryptionPublicKeyHex;

  late final _is.ColumnString encryptedDataKey;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnInt keyEpoch;

  @override
  List<_is.Column> get columns => [
    id,
    ultimateSigningPublicKeyHex,
    ultimateEncryptionPublicKeyHex,
    encryptedDataKey,
    createdAt,
    keyEpoch,
  ];
}

class ShareGroupInclude extends _is.IncludeObject {
  ShareGroupInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => ShareGroup.t;
}

class ShareGroupIncludeList extends _is.IncludeList {
  ShareGroupIncludeList._({
    _is.WhereExpressionBuilder<ShareGroupTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ShareGroup.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => ShareGroup.t;
}

class ShareGroupRepository {
  const ShareGroupRepository._();

  /// Returns a list of [ShareGroup]s matching the given query parameters.
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
  Future<List<ShareGroup>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ShareGroupTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ShareGroupTable>? orderBy,
    _is.OrderByListBuilder<ShareGroupTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ShareGroup>(
      where: where?.call(ShareGroup.t),
      orderBy: orderBy?.call(ShareGroup.t),
      orderByList: orderByList?.call(ShareGroup.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ShareGroup] matching the given query parameters.
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
  Future<ShareGroup?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ShareGroupTable>? where,
    int? offset,
    _is.OrderByBuilder<ShareGroupTable>? orderBy,
    _is.OrderByListBuilder<ShareGroupTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ShareGroup>(
      where: where?.call(ShareGroup.t),
      orderBy: orderBy?.call(ShareGroup.t),
      orderByList: orderByList?.call(ShareGroup.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ShareGroup] by its [id] or null if no such row exists.
  Future<ShareGroup?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ShareGroup>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ShareGroup]s in the list and returns the inserted rows.
  ///
  /// The returned [ShareGroup]s will have their `id` fields set.
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
  Future<List<ShareGroup>> insert(
    _is.DatabaseSession session,
    List<ShareGroup> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ShareGroup>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ShareGroup] and returns the inserted row.
  ///
  /// The returned [ShareGroup] will have its `id` field set.
  Future<ShareGroup> insertRow(
    _is.DatabaseSession session,
    ShareGroup row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ShareGroup>(row, transaction: transaction);
  }

  /// Upserts all [ShareGroup]s in the list and returns the resulting rows.
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
  /// The returned [ShareGroup]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ShareGroup>> upsert(
    _is.DatabaseSession session,
    List<ShareGroup> rows, {
    required _is.ColumnSelections<ShareGroupTable> conflictColumns,
    _is.ColumnSelections<ShareGroupTable>? updateColumns,
    _is.WhereExpressionBuilder<ShareGroupTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ShareGroup>(
      rows,
      conflictColumns: conflictColumns(ShareGroup.t),
      updateColumns: updateColumns?.call(ShareGroup.t),
      updateWhere: updateWhere?.call(ShareGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ShareGroup] and returns the resulting row.
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
  /// The returned [ShareGroup] will have its `id` field set.
  Future<ShareGroup?> upsertRow(
    _is.DatabaseSession session,
    ShareGroup row, {
    required _is.ColumnSelections<ShareGroupTable> conflictColumns,
    _is.ColumnSelections<ShareGroupTable>? updateColumns,
    _is.WhereExpressionBuilder<ShareGroupTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ShareGroup>(
      row,
      conflictColumns: conflictColumns(ShareGroup.t),
      updateColumns: updateColumns?.call(ShareGroup.t),
      updateWhere: updateWhere?.call(ShareGroup.t),
      transaction: transaction,
    );
  }

  /// Updates all [ShareGroup]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ShareGroup>> update(
    _is.DatabaseSession session,
    List<ShareGroup> rows, {
    _is.ColumnSelections<ShareGroupTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ShareGroup>(
      rows,
      columns: columns?.call(ShareGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ShareGroup]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ShareGroup> updateRow(
    _is.DatabaseSession session,
    ShareGroup row, {
    _is.ColumnSelections<ShareGroupTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ShareGroup>(
      row,
      columns: columns?.call(ShareGroup.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ShareGroup] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ShareGroup?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<ShareGroupUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ShareGroup>(
      id,
      columnValues: columnValues(ShareGroup.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ShareGroup]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ShareGroup>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ShareGroupUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ShareGroupTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ShareGroupTable>? orderBy,
    _is.OrderByListBuilder<ShareGroupTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ShareGroup>(
      columnValues: columnValues(ShareGroup.t.updateTable),
      where: where(ShareGroup.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ShareGroup.t),
      orderByList: orderByList?.call(ShareGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ShareGroup]s in the list and returns the deleted rows.
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
  Future<List<ShareGroup>> delete(
    _is.DatabaseSession session,
    List<ShareGroup> rows, {
    _is.OrderByBuilder<ShareGroupTable>? orderBy,
    _is.OrderByListBuilder<ShareGroupTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ShareGroup>(
      rows,
      orderBy: orderBy?.call(ShareGroup.t),
      orderByList: orderByList?.call(ShareGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ShareGroup].
  Future<ShareGroup> deleteRow(
    _is.DatabaseSession session,
    ShareGroup row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ShareGroup>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ShareGroup>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ShareGroupTable> where,
    _is.OrderByBuilder<ShareGroupTable>? orderBy,
    _is.OrderByListBuilder<ShareGroupTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ShareGroup>(
      where: where(ShareGroup.t),
      orderBy: orderBy?.call(ShareGroup.t),
      orderByList: orderByList?.call(ShareGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ShareGroupTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ShareGroup>(
      where: where?.call(ShareGroup.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ShareGroup] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ShareGroupTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ShareGroup>(
      where: where(ShareGroup.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
