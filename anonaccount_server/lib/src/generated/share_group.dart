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

abstract class ShareGroup
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  ShareGroup._({
    this.id,
    required this.ultimateSigningPublicKeyHex,
    required this.ultimatePublicKey,
    required this.encryptedDataKey,
    DateTime? createdAt,
    int? keyEpoch,
  }) : createdAt = createdAt ?? DateTime.now(),
       keyEpoch = keyEpoch ?? 0;

  factory ShareGroup({
    _i1.UuidValue? id,
    required String ultimateSigningPublicKeyHex,
    required String ultimatePublicKey,
    required String encryptedDataKey,
    DateTime? createdAt,
    int? keyEpoch,
  }) = _ShareGroupImpl;

  factory ShareGroup.fromJson(Map<String, dynamic> jsonSerialization) {
    return ShareGroup(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ultimateSigningPublicKeyHex:
          jsonSerialization['ultimateSigningPublicKeyHex'] as String,
      ultimatePublicKey: jsonSerialization['ultimatePublicKey'] as String,
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      keyEpoch: jsonSerialization['keyEpoch'] as int?,
    );
  }

  static final t = ShareGroupTable();

  static const db = ShareGroupRepository._();

  @override
  _i1.UuidValue? id;

  String ultimateSigningPublicKeyHex;

  String ultimatePublicKey;

  String encryptedDataKey;

  DateTime createdAt;

  int keyEpoch;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [ShareGroup]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ShareGroup copyWith({
    _i1.UuidValue? id,
    String? ultimateSigningPublicKeyHex,
    String? ultimatePublicKey,
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
      'ultimatePublicKey': ultimatePublicKey,
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
      'ultimatePublicKey': ultimatePublicKey,
      'encryptedDataKey': encryptedDataKey,
      'createdAt': createdAt.toJson(),
      'keyEpoch': keyEpoch,
    };
  }

  static ShareGroupInclude include() {
    return ShareGroupInclude._();
  }

  static ShareGroupIncludeList includeList({
    _i1.WhereExpressionBuilder<ShareGroupTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ShareGroupTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ShareGroupTable>? orderByList,
    ShareGroupInclude? include,
  }) {
    return ShareGroupIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ShareGroup.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ShareGroup.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ShareGroupImpl extends ShareGroup {
  _ShareGroupImpl({
    _i1.UuidValue? id,
    required String ultimateSigningPublicKeyHex,
    required String ultimatePublicKey,
    required String encryptedDataKey,
    DateTime? createdAt,
    int? keyEpoch,
  }) : super._(
         id: id,
         ultimateSigningPublicKeyHex: ultimateSigningPublicKeyHex,
         ultimatePublicKey: ultimatePublicKey,
         encryptedDataKey: encryptedDataKey,
         createdAt: createdAt,
         keyEpoch: keyEpoch,
       );

  /// Returns a shallow copy of this [ShareGroup]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ShareGroup copyWith({
    Object? id = _Undefined,
    String? ultimateSigningPublicKeyHex,
    String? ultimatePublicKey,
    String? encryptedDataKey,
    DateTime? createdAt,
    int? keyEpoch,
  }) {
    return ShareGroup(
      id: id is _i1.UuidValue? ? id : this.id,
      ultimateSigningPublicKeyHex:
          ultimateSigningPublicKeyHex ?? this.ultimateSigningPublicKeyHex,
      ultimatePublicKey: ultimatePublicKey ?? this.ultimatePublicKey,
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      createdAt: createdAt ?? this.createdAt,
      keyEpoch: keyEpoch ?? this.keyEpoch,
    );
  }
}

class ShareGroupUpdateTable extends _i1.UpdateTable<ShareGroupTable> {
  ShareGroupUpdateTable(super.table);

  _i1.ColumnValue<String, String> ultimateSigningPublicKeyHex(String value) =>
      _i1.ColumnValue(
        table.ultimateSigningPublicKeyHex,
        value,
      );

  _i1.ColumnValue<String, String> ultimatePublicKey(String value) =>
      _i1.ColumnValue(
        table.ultimatePublicKey,
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

  _i1.ColumnValue<int, int> keyEpoch(int value) => _i1.ColumnValue(
    table.keyEpoch,
    value,
  );
}

class ShareGroupTable extends _i1.Table<_i1.UuidValue?> {
  ShareGroupTable({super.tableRelation}) : super(tableName: 'share_group') {
    updateTable = ShareGroupUpdateTable(this);
    ultimateSigningPublicKeyHex = _i1.ColumnString(
      'ultimateSigningPublicKeyHex',
      this,
    );
    ultimatePublicKey = _i1.ColumnString(
      'ultimatePublicKey',
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
    keyEpoch = _i1.ColumnInt(
      'keyEpoch',
      this,
      hasDefault: true,
    );
  }

  late final ShareGroupUpdateTable updateTable;

  late final _i1.ColumnString ultimateSigningPublicKeyHex;

  late final _i1.ColumnString ultimatePublicKey;

  late final _i1.ColumnString encryptedDataKey;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnInt keyEpoch;

  @override
  List<_i1.Column> get columns => [
    id,
    ultimateSigningPublicKeyHex,
    ultimatePublicKey,
    encryptedDataKey,
    createdAt,
    keyEpoch,
  ];
}

class ShareGroupInclude extends _i1.IncludeObject {
  ShareGroupInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => ShareGroup.t;
}

class ShareGroupIncludeList extends _i1.IncludeList {
  ShareGroupIncludeList._({
    _i1.WhereExpressionBuilder<ShareGroupTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ShareGroup.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => ShareGroup.t;
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ShareGroupTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ShareGroupTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ShareGroupTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ShareGroup>(
      where: where?.call(ShareGroup.t),
      orderBy: orderBy?.call(ShareGroup.t),
      orderByList: orderByList?.call(ShareGroup.t),
      orderDescending: orderDescending,
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ShareGroupTable>? where,
    int? offset,
    _i1.OrderByBuilder<ShareGroupTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ShareGroupTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ShareGroup>(
      where: where?.call(ShareGroup.t),
      orderBy: orderBy?.call(ShareGroup.t),
      orderByList: orderByList?.call(ShareGroup.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ShareGroup] by its [id] or null if no such row exists.
  Future<ShareGroup?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
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
  Future<List<ShareGroup>> insert(
    _i1.Session session,
    List<ShareGroup> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ShareGroup>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ShareGroup] and returns the inserted row.
  ///
  /// The returned [ShareGroup] will have its `id` field set.
  Future<ShareGroup> insertRow(
    _i1.Session session,
    ShareGroup row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ShareGroup>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ShareGroup]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ShareGroup>> update(
    _i1.Session session,
    List<ShareGroup> rows, {
    _i1.ColumnSelections<ShareGroupTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ShareGroup>(
      rows,
      columns: columns?.call(ShareGroup.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ShareGroup]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ShareGroup> updateRow(
    _i1.Session session,
    ShareGroup row, {
    _i1.ColumnSelections<ShareGroupTable>? columns,
    _i1.Transaction? transaction,
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
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<ShareGroupUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ShareGroup>(
      id,
      columnValues: columnValues(ShareGroup.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ShareGroup]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ShareGroup>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<ShareGroupUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ShareGroupTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ShareGroupTable>? orderBy,
    _i1.OrderByListBuilder<ShareGroupTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ShareGroup>(
      columnValues: columnValues(ShareGroup.t.updateTable),
      where: where(ShareGroup.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ShareGroup.t),
      orderByList: orderByList?.call(ShareGroup.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ShareGroup]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ShareGroup>> delete(
    _i1.Session session,
    List<ShareGroup> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ShareGroup>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ShareGroup].
  Future<ShareGroup> deleteRow(
    _i1.Session session,
    ShareGroup row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ShareGroup>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ShareGroup>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ShareGroupTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ShareGroup>(
      where: where(ShareGroup.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ShareGroupTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ShareGroup>(
      where: where?.call(ShareGroup.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ShareGroup] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ShareGroupTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ShareGroup>(
      where: where(ShareGroup.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
