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

abstract class EphemeralAccreditation
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  EphemeralAccreditation._({
    this.id,
    required this.accountId,
    required this.transactionTimestamp,
  });

  factory EphemeralAccreditation({
    int? id,
    required int accountId,
    required DateTime transactionTimestamp,
  }) = _EphemeralAccreditationImpl;

  factory EphemeralAccreditation.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return EphemeralAccreditation(
      id: jsonSerialization['id'] as int?,
      accountId: jsonSerialization['accountId'] as int,
      transactionTimestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['transactionTimestamp'],
      ),
    );
  }

  static final t = EphemeralAccreditationTable();

  static const db = EphemeralAccreditationRepository._();

  @override
  int? id;

  int accountId;

  DateTime transactionTimestamp;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [EphemeralAccreditation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EphemeralAccreditation copyWith({
    int? id,
    int? accountId,
    DateTime? transactionTimestamp,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.EphemeralAccreditation',
      if (id != null) 'id': id,
      'accountId': accountId,
      'transactionTimestamp': transactionTimestamp.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.EphemeralAccreditation',
      if (id != null) 'id': id,
      'accountId': accountId,
      'transactionTimestamp': transactionTimestamp.toJson(),
    };
  }

  static EphemeralAccreditationInclude include() {
    return EphemeralAccreditationInclude._();
  }

  static EphemeralAccreditationIncludeList includeList({
    _i1.WhereExpressionBuilder<EphemeralAccreditationTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EphemeralAccreditationTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EphemeralAccreditationTable>? orderByList,
    EphemeralAccreditationInclude? include,
  }) {
    return EphemeralAccreditationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EphemeralAccreditation.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(EphemeralAccreditation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EphemeralAccreditationImpl extends EphemeralAccreditation {
  _EphemeralAccreditationImpl({
    int? id,
    required int accountId,
    required DateTime transactionTimestamp,
  }) : super._(
         id: id,
         accountId: accountId,
         transactionTimestamp: transactionTimestamp,
       );

  /// Returns a shallow copy of this [EphemeralAccreditation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EphemeralAccreditation copyWith({
    Object? id = _Undefined,
    int? accountId,
    DateTime? transactionTimestamp,
  }) {
    return EphemeralAccreditation(
      id: id is int? ? id : this.id,
      accountId: accountId ?? this.accountId,
      transactionTimestamp: transactionTimestamp ?? this.transactionTimestamp,
    );
  }
}

class EphemeralAccreditationUpdateTable
    extends _i1.UpdateTable<EphemeralAccreditationTable> {
  EphemeralAccreditationUpdateTable(super.table);

  _i1.ColumnValue<int, int> accountId(int value) => _i1.ColumnValue(
    table.accountId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> transactionTimestamp(DateTime value) =>
      _i1.ColumnValue(
        table.transactionTimestamp,
        value,
      );
}

class EphemeralAccreditationTable extends _i1.Table<int?> {
  EphemeralAccreditationTable({super.tableRelation})
    : super(tableName: 'ephemeral_accreditation') {
    updateTable = EphemeralAccreditationUpdateTable(this);
    accountId = _i1.ColumnInt(
      'accountId',
      this,
    );
    transactionTimestamp = _i1.ColumnDateTime(
      'transactionTimestamp',
      this,
    );
  }

  late final EphemeralAccreditationUpdateTable updateTable;

  late final _i1.ColumnInt accountId;

  late final _i1.ColumnDateTime transactionTimestamp;

  @override
  List<_i1.Column> get columns => [
    id,
    accountId,
    transactionTimestamp,
  ];
}

class EphemeralAccreditationInclude extends _i1.IncludeObject {
  EphemeralAccreditationInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => EphemeralAccreditation.t;
}

class EphemeralAccreditationIncludeList extends _i1.IncludeList {
  EphemeralAccreditationIncludeList._({
    _i1.WhereExpressionBuilder<EphemeralAccreditationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(EphemeralAccreditation.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => EphemeralAccreditation.t;
}

class EphemeralAccreditationRepository {
  const EphemeralAccreditationRepository._();

  /// Returns a list of [EphemeralAccreditation]s matching the given query parameters.
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
  Future<List<EphemeralAccreditation>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<EphemeralAccreditationTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EphemeralAccreditationTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EphemeralAccreditationTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<EphemeralAccreditation>(
      where: where?.call(EphemeralAccreditation.t),
      orderBy: orderBy?.call(EphemeralAccreditation.t),
      orderByList: orderByList?.call(EphemeralAccreditation.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [EphemeralAccreditation] matching the given query parameters.
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
  Future<EphemeralAccreditation?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<EphemeralAccreditationTable>? where,
    int? offset,
    _i1.OrderByBuilder<EphemeralAccreditationTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EphemeralAccreditationTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<EphemeralAccreditation>(
      where: where?.call(EphemeralAccreditation.t),
      orderBy: orderBy?.call(EphemeralAccreditation.t),
      orderByList: orderByList?.call(EphemeralAccreditation.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [EphemeralAccreditation] by its [id] or null if no such row exists.
  Future<EphemeralAccreditation?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<EphemeralAccreditation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [EphemeralAccreditation]s in the list and returns the inserted rows.
  ///
  /// The returned [EphemeralAccreditation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<EphemeralAccreditation>> insert(
    _i1.Session session,
    List<EphemeralAccreditation> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<EphemeralAccreditation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [EphemeralAccreditation] and returns the inserted row.
  ///
  /// The returned [EphemeralAccreditation] will have its `id` field set.
  Future<EphemeralAccreditation> insertRow(
    _i1.Session session,
    EphemeralAccreditation row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<EphemeralAccreditation>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [EphemeralAccreditation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<EphemeralAccreditation>> update(
    _i1.Session session,
    List<EphemeralAccreditation> rows, {
    _i1.ColumnSelections<EphemeralAccreditationTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<EphemeralAccreditation>(
      rows,
      columns: columns?.call(EphemeralAccreditation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EphemeralAccreditation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<EphemeralAccreditation> updateRow(
    _i1.Session session,
    EphemeralAccreditation row, {
    _i1.ColumnSelections<EphemeralAccreditationTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<EphemeralAccreditation>(
      row,
      columns: columns?.call(EphemeralAccreditation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EphemeralAccreditation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<EphemeralAccreditation?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<EphemeralAccreditationUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<EphemeralAccreditation>(
      id,
      columnValues: columnValues(EphemeralAccreditation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [EphemeralAccreditation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<EphemeralAccreditation>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<EphemeralAccreditationUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<EphemeralAccreditationTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EphemeralAccreditationTable>? orderBy,
    _i1.OrderByListBuilder<EphemeralAccreditationTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<EphemeralAccreditation>(
      columnValues: columnValues(EphemeralAccreditation.t.updateTable),
      where: where(EphemeralAccreditation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EphemeralAccreditation.t),
      orderByList: orderByList?.call(EphemeralAccreditation.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [EphemeralAccreditation]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<EphemeralAccreditation>> delete(
    _i1.Session session,
    List<EphemeralAccreditation> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<EphemeralAccreditation>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [EphemeralAccreditation].
  Future<EphemeralAccreditation> deleteRow(
    _i1.Session session,
    EphemeralAccreditation row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<EphemeralAccreditation>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<EphemeralAccreditation>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<EphemeralAccreditationTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<EphemeralAccreditation>(
      where: where(EphemeralAccreditation.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<EphemeralAccreditationTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<EphemeralAccreditation>(
      where: where?.call(EphemeralAccreditation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [EphemeralAccreditation] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<EphemeralAccreditationTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<EphemeralAccreditation>(
      where: where(EphemeralAccreditation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
