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
import 'payment_rail.dart' as _i2;

abstract class RefundClaim
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  RefundClaim._({
    this.id,
    required this.paymentRail,
    required this.paymentRef,
    DateTime? claimedAt,
  }) : claimedAt = claimedAt ?? DateTime.now();

  factory RefundClaim({
    int? id,
    required _i2.PaymentRail paymentRail,
    required String paymentRef,
    DateTime? claimedAt,
  }) = _RefundClaimImpl;

  factory RefundClaim.fromJson(Map<String, dynamic> jsonSerialization) {
    return RefundClaim(
      id: jsonSerialization['id'] as int?,
      paymentRail: _i2.PaymentRail.fromJson(
        (jsonSerialization['paymentRail'] as String),
      ),
      paymentRef: jsonSerialization['paymentRef'] as String,
      claimedAt: jsonSerialization['claimedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['claimedAt']),
    );
  }

  static final t = RefundClaimTable();

  static const db = RefundClaimRepository._();

  @override
  int? id;

  _i2.PaymentRail paymentRail;

  String paymentRef;

  DateTime claimedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [RefundClaim]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RefundClaim copyWith({
    int? id,
    _i2.PaymentRail? paymentRail,
    String? paymentRef,
    DateTime? claimedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.RefundClaim',
      if (id != null) 'id': id,
      'paymentRail': paymentRail.toJson(),
      'paymentRef': paymentRef,
      'claimedAt': claimedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.RefundClaim',
      if (id != null) 'id': id,
      'paymentRail': paymentRail.toJson(),
      'paymentRef': paymentRef,
      'claimedAt': claimedAt.toJson(),
    };
  }

  static RefundClaimInclude include() {
    return RefundClaimInclude._();
  }

  static RefundClaimIncludeList includeList({
    _i1.WhereExpressionBuilder<RefundClaimTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RefundClaimTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RefundClaimTable>? orderByList,
    RefundClaimInclude? include,
  }) {
    return RefundClaimIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RefundClaim.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(RefundClaim.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RefundClaimImpl extends RefundClaim {
  _RefundClaimImpl({
    int? id,
    required _i2.PaymentRail paymentRail,
    required String paymentRef,
    DateTime? claimedAt,
  }) : super._(
         id: id,
         paymentRail: paymentRail,
         paymentRef: paymentRef,
         claimedAt: claimedAt,
       );

  /// Returns a shallow copy of this [RefundClaim]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RefundClaim copyWith({
    Object? id = _Undefined,
    _i2.PaymentRail? paymentRail,
    String? paymentRef,
    DateTime? claimedAt,
  }) {
    return RefundClaim(
      id: id is int? ? id : this.id,
      paymentRail: paymentRail ?? this.paymentRail,
      paymentRef: paymentRef ?? this.paymentRef,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }
}

class RefundClaimUpdateTable extends _i1.UpdateTable<RefundClaimTable> {
  RefundClaimUpdateTable(super.table);

  _i1.ColumnValue<_i2.PaymentRail, _i2.PaymentRail> paymentRail(
    _i2.PaymentRail value,
  ) => _i1.ColumnValue(
    table.paymentRail,
    value,
  );

  _i1.ColumnValue<String, String> paymentRef(String value) => _i1.ColumnValue(
    table.paymentRef,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> claimedAt(DateTime value) =>
      _i1.ColumnValue(
        table.claimedAt,
        value,
      );
}

class RefundClaimTable extends _i1.Table<int?> {
  RefundClaimTable({super.tableRelation}) : super(tableName: 'refund_claim') {
    updateTable = RefundClaimUpdateTable(this);
    paymentRail = _i1.ColumnEnum(
      'paymentRail',
      this,
      _i1.EnumSerialization.byName,
    );
    paymentRef = _i1.ColumnString(
      'paymentRef',
      this,
    );
    claimedAt = _i1.ColumnDateTime(
      'claimedAt',
      this,
      hasDefault: true,
    );
  }

  late final RefundClaimUpdateTable updateTable;

  late final _i1.ColumnEnum<_i2.PaymentRail> paymentRail;

  late final _i1.ColumnString paymentRef;

  late final _i1.ColumnDateTime claimedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    paymentRail,
    paymentRef,
    claimedAt,
  ];
}

class RefundClaimInclude extends _i1.IncludeObject {
  RefundClaimInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => RefundClaim.t;
}

class RefundClaimIncludeList extends _i1.IncludeList {
  RefundClaimIncludeList._({
    _i1.WhereExpressionBuilder<RefundClaimTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RefundClaim.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => RefundClaim.t;
}

class RefundClaimRepository {
  const RefundClaimRepository._();

  /// Returns a list of [RefundClaim]s matching the given query parameters.
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
  Future<List<RefundClaim>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RefundClaimTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RefundClaimTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RefundClaimTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RefundClaim>(
      where: where?.call(RefundClaim.t),
      orderBy: orderBy?.call(RefundClaim.t),
      orderByList: orderByList?.call(RefundClaim.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RefundClaim] matching the given query parameters.
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
  Future<RefundClaim?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RefundClaimTable>? where,
    int? offset,
    _i1.OrderByBuilder<RefundClaimTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RefundClaimTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RefundClaim>(
      where: where?.call(RefundClaim.t),
      orderBy: orderBy?.call(RefundClaim.t),
      orderByList: orderByList?.call(RefundClaim.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RefundClaim] by its [id] or null if no such row exists.
  Future<RefundClaim?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RefundClaim>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RefundClaim]s in the list and returns the inserted rows.
  ///
  /// The returned [RefundClaim]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<RefundClaim>> insert(
    _i1.Session session,
    List<RefundClaim> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<RefundClaim>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [RefundClaim] and returns the inserted row.
  ///
  /// The returned [RefundClaim] will have its `id` field set.
  Future<RefundClaim> insertRow(
    _i1.Session session,
    RefundClaim row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<RefundClaim>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [RefundClaim]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<RefundClaim>> update(
    _i1.Session session,
    List<RefundClaim> rows, {
    _i1.ColumnSelections<RefundClaimTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<RefundClaim>(
      rows,
      columns: columns?.call(RefundClaim.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RefundClaim]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RefundClaim> updateRow(
    _i1.Session session,
    RefundClaim row, {
    _i1.ColumnSelections<RefundClaimTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<RefundClaim>(
      row,
      columns: columns?.call(RefundClaim.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RefundClaim] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RefundClaim?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<RefundClaimUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<RefundClaim>(
      id,
      columnValues: columnValues(RefundClaim.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RefundClaim]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<RefundClaim>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<RefundClaimUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<RefundClaimTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RefundClaimTable>? orderBy,
    _i1.OrderByListBuilder<RefundClaimTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<RefundClaim>(
      columnValues: columnValues(RefundClaim.t.updateTable),
      where: where(RefundClaim.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RefundClaim.t),
      orderByList: orderByList?.call(RefundClaim.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [RefundClaim]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<RefundClaim>> delete(
    _i1.Session session,
    List<RefundClaim> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<RefundClaim>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [RefundClaim].
  Future<RefundClaim> deleteRow(
    _i1.Session session,
    RefundClaim row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RefundClaim>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<RefundClaim>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<RefundClaimTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<RefundClaim>(
      where: where(RefundClaim.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RefundClaimTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<RefundClaim>(
      where: where?.call(RefundClaim.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RefundClaim] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<RefundClaimTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RefundClaim>(
      where: where(RefundClaim.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
