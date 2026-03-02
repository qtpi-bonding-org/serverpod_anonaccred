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

abstract class ReceiptHash
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ReceiptHash._({
    this.id,
    required this.hash,
    required this.paymentRail,
    DateTime? processedAt,
  }) : processedAt = processedAt ?? DateTime.now();

  factory ReceiptHash({
    int? id,
    required String hash,
    required _i2.PaymentRail paymentRail,
    DateTime? processedAt,
  }) = _ReceiptHashImpl;

  factory ReceiptHash.fromJson(Map<String, dynamic> jsonSerialization) {
    return ReceiptHash(
      id: jsonSerialization['id'] as int?,
      hash: jsonSerialization['hash'] as String,
      paymentRail: _i2.PaymentRail.fromJson(
        (jsonSerialization['paymentRail'] as String),
      ),
      processedAt: jsonSerialization['processedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['processedAt'],
            ),
    );
  }

  static final t = ReceiptHashTable();

  static const db = ReceiptHashRepository._();

  @override
  int? id;

  String hash;

  _i2.PaymentRail paymentRail;

  DateTime processedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ReceiptHash]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ReceiptHash copyWith({
    int? id,
    String? hash,
    _i2.PaymentRail? paymentRail,
    DateTime? processedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.ReceiptHash',
      if (id != null) 'id': id,
      'hash': hash,
      'paymentRail': paymentRail.toJson(),
      'processedAt': processedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.ReceiptHash',
      if (id != null) 'id': id,
      'hash': hash,
      'paymentRail': paymentRail.toJson(),
      'processedAt': processedAt.toJson(),
    };
  }

  static ReceiptHashInclude include() {
    return ReceiptHashInclude._();
  }

  static ReceiptHashIncludeList includeList({
    _i1.WhereExpressionBuilder<ReceiptHashTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ReceiptHashTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ReceiptHashTable>? orderByList,
    ReceiptHashInclude? include,
  }) {
    return ReceiptHashIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ReceiptHash.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ReceiptHash.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ReceiptHashImpl extends ReceiptHash {
  _ReceiptHashImpl({
    int? id,
    required String hash,
    required _i2.PaymentRail paymentRail,
    DateTime? processedAt,
  }) : super._(
         id: id,
         hash: hash,
         paymentRail: paymentRail,
         processedAt: processedAt,
       );

  /// Returns a shallow copy of this [ReceiptHash]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ReceiptHash copyWith({
    Object? id = _Undefined,
    String? hash,
    _i2.PaymentRail? paymentRail,
    DateTime? processedAt,
  }) {
    return ReceiptHash(
      id: id is int? ? id : this.id,
      hash: hash ?? this.hash,
      paymentRail: paymentRail ?? this.paymentRail,
      processedAt: processedAt ?? this.processedAt,
    );
  }
}

class ReceiptHashUpdateTable extends _i1.UpdateTable<ReceiptHashTable> {
  ReceiptHashUpdateTable(super.table);

  _i1.ColumnValue<String, String> hash(String value) => _i1.ColumnValue(
    table.hash,
    value,
  );

  _i1.ColumnValue<_i2.PaymentRail, _i2.PaymentRail> paymentRail(
    _i2.PaymentRail value,
  ) => _i1.ColumnValue(
    table.paymentRail,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> processedAt(DateTime value) =>
      _i1.ColumnValue(
        table.processedAt,
        value,
      );
}

class ReceiptHashTable extends _i1.Table<int?> {
  ReceiptHashTable({super.tableRelation}) : super(tableName: 'receipt_hash') {
    updateTable = ReceiptHashUpdateTable(this);
    hash = _i1.ColumnString(
      'hash',
      this,
    );
    paymentRail = _i1.ColumnEnum(
      'paymentRail',
      this,
      _i1.EnumSerialization.byName,
    );
    processedAt = _i1.ColumnDateTime(
      'processedAt',
      this,
      hasDefault: true,
    );
  }

  late final ReceiptHashUpdateTable updateTable;

  late final _i1.ColumnString hash;

  late final _i1.ColumnEnum<_i2.PaymentRail> paymentRail;

  late final _i1.ColumnDateTime processedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    hash,
    paymentRail,
    processedAt,
  ];
}

class ReceiptHashInclude extends _i1.IncludeObject {
  ReceiptHashInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ReceiptHash.t;
}

class ReceiptHashIncludeList extends _i1.IncludeList {
  ReceiptHashIncludeList._({
    _i1.WhereExpressionBuilder<ReceiptHashTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ReceiptHash.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ReceiptHash.t;
}

class ReceiptHashRepository {
  const ReceiptHashRepository._();

  /// Returns a list of [ReceiptHash]s matching the given query parameters.
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
  Future<List<ReceiptHash>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ReceiptHashTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ReceiptHashTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ReceiptHashTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<ReceiptHash>(
      where: where?.call(ReceiptHash.t),
      orderBy: orderBy?.call(ReceiptHash.t),
      orderByList: orderByList?.call(ReceiptHash.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [ReceiptHash] matching the given query parameters.
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
  Future<ReceiptHash?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ReceiptHashTable>? where,
    int? offset,
    _i1.OrderByBuilder<ReceiptHashTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ReceiptHashTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<ReceiptHash>(
      where: where?.call(ReceiptHash.t),
      orderBy: orderBy?.call(ReceiptHash.t),
      orderByList: orderByList?.call(ReceiptHash.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [ReceiptHash] by its [id] or null if no such row exists.
  Future<ReceiptHash?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<ReceiptHash>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [ReceiptHash]s in the list and returns the inserted rows.
  ///
  /// The returned [ReceiptHash]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ReceiptHash>> insert(
    _i1.Session session,
    List<ReceiptHash> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ReceiptHash>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ReceiptHash] and returns the inserted row.
  ///
  /// The returned [ReceiptHash] will have its `id` field set.
  Future<ReceiptHash> insertRow(
    _i1.Session session,
    ReceiptHash row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ReceiptHash>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ReceiptHash]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ReceiptHash>> update(
    _i1.Session session,
    List<ReceiptHash> rows, {
    _i1.ColumnSelections<ReceiptHashTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ReceiptHash>(
      rows,
      columns: columns?.call(ReceiptHash.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ReceiptHash]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ReceiptHash> updateRow(
    _i1.Session session,
    ReceiptHash row, {
    _i1.ColumnSelections<ReceiptHashTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ReceiptHash>(
      row,
      columns: columns?.call(ReceiptHash.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ReceiptHash] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ReceiptHash?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<ReceiptHashUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ReceiptHash>(
      id,
      columnValues: columnValues(ReceiptHash.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ReceiptHash]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ReceiptHash>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<ReceiptHashUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ReceiptHashTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ReceiptHashTable>? orderBy,
    _i1.OrderByListBuilder<ReceiptHashTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ReceiptHash>(
      columnValues: columnValues(ReceiptHash.t.updateTable),
      where: where(ReceiptHash.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ReceiptHash.t),
      orderByList: orderByList?.call(ReceiptHash.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ReceiptHash]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ReceiptHash>> delete(
    _i1.Session session,
    List<ReceiptHash> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ReceiptHash>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ReceiptHash].
  Future<ReceiptHash> deleteRow(
    _i1.Session session,
    ReceiptHash row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ReceiptHash>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ReceiptHash>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ReceiptHashTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ReceiptHash>(
      where: where(ReceiptHash.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ReceiptHashTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ReceiptHash>(
      where: where?.call(ReceiptHash.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
