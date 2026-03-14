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

abstract class PublicChallenge
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  PublicChallenge._({
    this.id,
    required this.challenge,
    required this.expiresAt,
  });

  factory PublicChallenge({
    int? id,
    required String challenge,
    required DateTime expiresAt,
  }) = _PublicChallengeImpl;

  factory PublicChallenge.fromJson(Map<String, dynamic> jsonSerialization) {
    return PublicChallenge(
      id: jsonSerialization['id'] as int?,
      challenge: jsonSerialization['challenge'] as String,
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  static final t = PublicChallengeTable();

  static const db = PublicChallengeRepository._();

  @override
  int? id;

  String challenge;

  DateTime expiresAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [PublicChallenge]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PublicChallenge copyWith({
    int? id,
    String? challenge,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.PublicChallenge',
      if (id != null) 'id': id,
      'challenge': challenge,
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.PublicChallenge',
      if (id != null) 'id': id,
      'challenge': challenge,
      'expiresAt': expiresAt.toJson(),
    };
  }

  static PublicChallengeInclude include() {
    return PublicChallengeInclude._();
  }

  static PublicChallengeIncludeList includeList({
    _i1.WhereExpressionBuilder<PublicChallengeTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PublicChallengeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PublicChallengeTable>? orderByList,
    PublicChallengeInclude? include,
  }) {
    return PublicChallengeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PublicChallenge.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PublicChallenge.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PublicChallengeImpl extends PublicChallenge {
  _PublicChallengeImpl({
    int? id,
    required String challenge,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         challenge: challenge,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [PublicChallenge]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PublicChallenge copyWith({
    Object? id = _Undefined,
    String? challenge,
    DateTime? expiresAt,
  }) {
    return PublicChallenge(
      id: id is int? ? id : this.id,
      challenge: challenge ?? this.challenge,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class PublicChallengeUpdateTable extends _i1.UpdateTable<PublicChallengeTable> {
  PublicChallengeUpdateTable(super.table);

  _i1.ColumnValue<String, String> challenge(String value) => _i1.ColumnValue(
    table.challenge,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _i1.ColumnValue(
        table.expiresAt,
        value,
      );
}

class PublicChallengeTable extends _i1.Table<int?> {
  PublicChallengeTable({super.tableRelation})
    : super(tableName: 'public_challenges') {
    updateTable = PublicChallengeUpdateTable(this);
    challenge = _i1.ColumnString(
      'challenge',
      this,
    );
    expiresAt = _i1.ColumnDateTime(
      'expiresAt',
      this,
    );
  }

  late final PublicChallengeUpdateTable updateTable;

  late final _i1.ColumnString challenge;

  late final _i1.ColumnDateTime expiresAt;

  @override
  List<_i1.Column> get columns => [
    id,
    challenge,
    expiresAt,
  ];
}

class PublicChallengeInclude extends _i1.IncludeObject {
  PublicChallengeInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => PublicChallenge.t;
}

class PublicChallengeIncludeList extends _i1.IncludeList {
  PublicChallengeIncludeList._({
    _i1.WhereExpressionBuilder<PublicChallengeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PublicChallenge.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => PublicChallenge.t;
}

class PublicChallengeRepository {
  const PublicChallengeRepository._();

  /// Returns a list of [PublicChallenge]s matching the given query parameters.
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
  Future<List<PublicChallenge>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PublicChallengeTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PublicChallengeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PublicChallengeTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PublicChallenge>(
      where: where?.call(PublicChallenge.t),
      orderBy: orderBy?.call(PublicChallenge.t),
      orderByList: orderByList?.call(PublicChallenge.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PublicChallenge] matching the given query parameters.
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
  Future<PublicChallenge?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PublicChallengeTable>? where,
    int? offset,
    _i1.OrderByBuilder<PublicChallengeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PublicChallengeTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PublicChallenge>(
      where: where?.call(PublicChallenge.t),
      orderBy: orderBy?.call(PublicChallenge.t),
      orderByList: orderByList?.call(PublicChallenge.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PublicChallenge] by its [id] or null if no such row exists.
  Future<PublicChallenge?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PublicChallenge>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PublicChallenge]s in the list and returns the inserted rows.
  ///
  /// The returned [PublicChallenge]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<PublicChallenge>> insert(
    _i1.Session session,
    List<PublicChallenge> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<PublicChallenge>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [PublicChallenge] and returns the inserted row.
  ///
  /// The returned [PublicChallenge] will have its `id` field set.
  Future<PublicChallenge> insertRow(
    _i1.Session session,
    PublicChallenge row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PublicChallenge>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PublicChallenge]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PublicChallenge>> update(
    _i1.Session session,
    List<PublicChallenge> rows, {
    _i1.ColumnSelections<PublicChallengeTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PublicChallenge>(
      rows,
      columns: columns?.call(PublicChallenge.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PublicChallenge]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PublicChallenge> updateRow(
    _i1.Session session,
    PublicChallenge row, {
    _i1.ColumnSelections<PublicChallengeTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PublicChallenge>(
      row,
      columns: columns?.call(PublicChallenge.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PublicChallenge] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PublicChallenge?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<PublicChallengeUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PublicChallenge>(
      id,
      columnValues: columnValues(PublicChallenge.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PublicChallenge]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PublicChallenge>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<PublicChallengeUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<PublicChallengeTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PublicChallengeTable>? orderBy,
    _i1.OrderByListBuilder<PublicChallengeTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PublicChallenge>(
      columnValues: columnValues(PublicChallenge.t.updateTable),
      where: where(PublicChallenge.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PublicChallenge.t),
      orderByList: orderByList?.call(PublicChallenge.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PublicChallenge]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PublicChallenge>> delete(
    _i1.Session session,
    List<PublicChallenge> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PublicChallenge>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PublicChallenge].
  Future<PublicChallenge> deleteRow(
    _i1.Session session,
    PublicChallenge row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PublicChallenge>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PublicChallenge>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PublicChallengeTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PublicChallenge>(
      where: where(PublicChallenge.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PublicChallengeTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PublicChallenge>(
      where: where?.call(PublicChallenge.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PublicChallenge] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PublicChallengeTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PublicChallenge>(
      where: where(PublicChallenge.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
