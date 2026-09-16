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
import 'currency.dart' as _iez2mem4;
import 'order_status.dart' as _idpqotwg;
import 'payment_rail.dart' as _i4hkjqgd;

abstract class TransactionPayment
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  TransactionPayment._({
    this.id,
    required this.railProductId,
    required this.internalTransactionId,
    required this.priceCurrency,
    required this.price,
    required this.paymentRail,
    required this.paymentCurrency,
    required this.paymentAmount,
    this.paymentRef,
    required this.transactionTimestamp,
    this.clientReference,
    required this.status,
    this.railDataJson,
  });

  factory TransactionPayment({
    int? id,
    required int railProductId,
    required String internalTransactionId,
    required _iez2mem4.Currency priceCurrency,
    required double price,
    required _i4hkjqgd.PaymentRail paymentRail,
    required _iez2mem4.Currency paymentCurrency,
    required double paymentAmount,
    String? paymentRef,
    required DateTime transactionTimestamp,
    String? clientReference,
    required _idpqotwg.OrderStatus status,
    String? railDataJson,
  }) = _TransactionPaymentImpl;

  factory TransactionPayment.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransactionPayment(
      id: jsonSerialization['id'] as int?,
      railProductId: jsonSerialization['railProductId'] as int,
      internalTransactionId:
          jsonSerialization['internalTransactionId'] as String,
      priceCurrency: _iez2mem4.Currency.fromJson(
        (jsonSerialization['priceCurrency'] as String),
      ),
      price: (jsonSerialization['price'] as num).toDouble(),
      paymentRail: _i4hkjqgd.PaymentRail.fromJson(
        (jsonSerialization['paymentRail'] as String),
      ),
      paymentCurrency: _iez2mem4.Currency.fromJson(
        (jsonSerialization['paymentCurrency'] as String),
      ),
      paymentAmount: (jsonSerialization['paymentAmount'] as num).toDouble(),
      paymentRef: jsonSerialization['paymentRef'] as String?,
      transactionTimestamp: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['transactionTimestamp'],
      ),
      clientReference: jsonSerialization['clientReference'] as String?,
      status: _idpqotwg.OrderStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      railDataJson: jsonSerialization['railDataJson'] as String?,
    );
  }

  static final t = TransactionPaymentTable();

  static const db = TransactionPaymentRepository._();

  @override
  int? id;

  int railProductId;

  String internalTransactionId;

  _iez2mem4.Currency priceCurrency;

  double price;

  _i4hkjqgd.PaymentRail paymentRail;

  _iez2mem4.Currency paymentCurrency;

  double paymentAmount;

  String? paymentRef;

  DateTime transactionTimestamp;

  String? clientReference;

  _idpqotwg.OrderStatus status;

  String? railDataJson;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [TransactionPayment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TransactionPayment copyWith({
    int? id,
    int? railProductId,
    String? internalTransactionId,
    _iez2mem4.Currency? priceCurrency,
    double? price,
    _i4hkjqgd.PaymentRail? paymentRail,
    _iez2mem4.Currency? paymentCurrency,
    double? paymentAmount,
    String? paymentRef,
    DateTime? transactionTimestamp,
    String? clientReference,
    _idpqotwg.OrderStatus? status,
    String? railDataJson,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.TransactionPayment',
      if (id != null) 'id': id,
      'railProductId': railProductId,
      'internalTransactionId': internalTransactionId,
      'priceCurrency': priceCurrency.toJson(),
      'price': price,
      'paymentRail': paymentRail.toJson(),
      'paymentCurrency': paymentCurrency.toJson(),
      'paymentAmount': paymentAmount,
      if (paymentRef != null) 'paymentRef': paymentRef,
      'transactionTimestamp': transactionTimestamp.toJson(),
      if (clientReference != null) 'clientReference': clientReference,
      'status': status.toJson(),
      if (railDataJson != null) 'railDataJson': railDataJson,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.TransactionPayment',
      if (id != null) 'id': id,
      'railProductId': railProductId,
      'internalTransactionId': internalTransactionId,
      'priceCurrency': priceCurrency.toJson(),
      'price': price,
      'paymentRail': paymentRail.toJson(),
      'paymentCurrency': paymentCurrency.toJson(),
      'paymentAmount': paymentAmount,
      if (paymentRef != null) 'paymentRef': paymentRef,
      'transactionTimestamp': transactionTimestamp.toJson(),
      if (clientReference != null) 'clientReference': clientReference,
      'status': status.toJson(),
      if (railDataJson != null) 'railDataJson': railDataJson,
    };
  }

  static TransactionPaymentInclude include() {
    return TransactionPaymentInclude._();
  }

  static TransactionPaymentIncludeList includeList({
    _is.WhereExpressionBuilder<TransactionPaymentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TransactionPaymentTable>? orderBy,
    _is.OrderByListBuilder<TransactionPaymentTable>? orderByList,
    TransactionPaymentInclude? include,
  }) {
    return TransactionPaymentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TransactionPayment.t),
      orderByList: orderByList?.call(TransactionPayment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransactionPaymentImpl extends TransactionPayment {
  _TransactionPaymentImpl({
    int? id,
    required int railProductId,
    required String internalTransactionId,
    required _iez2mem4.Currency priceCurrency,
    required double price,
    required _i4hkjqgd.PaymentRail paymentRail,
    required _iez2mem4.Currency paymentCurrency,
    required double paymentAmount,
    String? paymentRef,
    required DateTime transactionTimestamp,
    String? clientReference,
    required _idpqotwg.OrderStatus status,
    String? railDataJson,
  }) : super._(
         id: id,
         railProductId: railProductId,
         internalTransactionId: internalTransactionId,
         priceCurrency: priceCurrency,
         price: price,
         paymentRail: paymentRail,
         paymentCurrency: paymentCurrency,
         paymentAmount: paymentAmount,
         paymentRef: paymentRef,
         transactionTimestamp: transactionTimestamp,
         clientReference: clientReference,
         status: status,
         railDataJson: railDataJson,
       );

  /// Returns a shallow copy of this [TransactionPayment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TransactionPayment copyWith({
    Object? id = _Undefined,
    int? railProductId,
    String? internalTransactionId,
    _iez2mem4.Currency? priceCurrency,
    double? price,
    _i4hkjqgd.PaymentRail? paymentRail,
    _iez2mem4.Currency? paymentCurrency,
    double? paymentAmount,
    Object? paymentRef = _Undefined,
    DateTime? transactionTimestamp,
    Object? clientReference = _Undefined,
    _idpqotwg.OrderStatus? status,
    Object? railDataJson = _Undefined,
  }) {
    return TransactionPayment(
      id: id is int? ? id : this.id,
      railProductId: railProductId ?? this.railProductId,
      internalTransactionId:
          internalTransactionId ?? this.internalTransactionId,
      priceCurrency: priceCurrency ?? this.priceCurrency,
      price: price ?? this.price,
      paymentRail: paymentRail ?? this.paymentRail,
      paymentCurrency: paymentCurrency ?? this.paymentCurrency,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentRef: paymentRef is String? ? paymentRef : this.paymentRef,
      transactionTimestamp: transactionTimestamp ?? this.transactionTimestamp,
      clientReference: clientReference is String?
          ? clientReference
          : this.clientReference,
      status: status ?? this.status,
      railDataJson: railDataJson is String? ? railDataJson : this.railDataJson,
    );
  }
}

class TransactionPaymentUpdateTable
    extends _is.UpdateTable<TransactionPaymentTable> {
  TransactionPaymentUpdateTable(super.table);

  _is.ColumnValue<int, int> railProductId(int value) =>
      _is.ColumnValue(table.railProductId, value);

  _is.ColumnValue<String, String> internalTransactionId(String value) =>
      _is.ColumnValue(table.internalTransactionId, value);

  _is.ColumnValue<_iez2mem4.Currency, _iez2mem4.Currency> priceCurrency(
    _iez2mem4.Currency value,
  ) => _is.ColumnValue(table.priceCurrency, value);

  _is.ColumnValue<double, double> price(double value) =>
      _is.ColumnValue(table.price, value);

  _is.ColumnValue<_i4hkjqgd.PaymentRail, _i4hkjqgd.PaymentRail> paymentRail(
    _i4hkjqgd.PaymentRail value,
  ) => _is.ColumnValue(table.paymentRail, value);

  _is.ColumnValue<_iez2mem4.Currency, _iez2mem4.Currency> paymentCurrency(
    _iez2mem4.Currency value,
  ) => _is.ColumnValue(table.paymentCurrency, value);

  _is.ColumnValue<double, double> paymentAmount(double value) =>
      _is.ColumnValue(table.paymentAmount, value);

  _is.ColumnValue<String, String> paymentRef(String? value) =>
      _is.ColumnValue(table.paymentRef, value);

  _is.ColumnValue<DateTime, DateTime> transactionTimestamp(DateTime value) =>
      _is.ColumnValue(table.transactionTimestamp, value);

  _is.ColumnValue<String, String> clientReference(String? value) =>
      _is.ColumnValue(table.clientReference, value);

  _is.ColumnValue<_idpqotwg.OrderStatus, _idpqotwg.OrderStatus> status(
    _idpqotwg.OrderStatus value,
  ) => _is.ColumnValue(table.status, value);

  _is.ColumnValue<String, String> railDataJson(String? value) =>
      _is.ColumnValue(table.railDataJson, value);
}

class TransactionPaymentTable extends _is.Table<int?> {
  TransactionPaymentTable({super.tableRelation})
    : super(tableName: 'transaction_payment') {
    updateTable = TransactionPaymentUpdateTable(this);
    railProductId = _is.ColumnInt('railProductId', this);
    internalTransactionId = _is.ColumnString('internalTransactionId', this);
    priceCurrency = _is.ColumnEnum(
      'priceCurrency',
      this,
      _is.EnumSerialization.byName,
    );
    price = _is.ColumnDouble('price', this);
    paymentRail = _is.ColumnEnum(
      'paymentRail',
      this,
      _is.EnumSerialization.byName,
    );
    paymentCurrency = _is.ColumnEnum(
      'paymentCurrency',
      this,
      _is.EnumSerialization.byName,
    );
    paymentAmount = _is.ColumnDouble('paymentAmount', this);
    paymentRef = _is.ColumnString('paymentRef', this);
    transactionTimestamp = _is.ColumnDateTime('transactionTimestamp', this);
    clientReference = _is.ColumnString('clientReference', this);
    status = _is.ColumnEnum('status', this, _is.EnumSerialization.byName);
    railDataJson = _is.ColumnString('railDataJson', this);
  }

  late final TransactionPaymentUpdateTable updateTable;

  late final _is.ColumnInt railProductId;

  late final _is.ColumnString internalTransactionId;

  late final _is.ColumnEnum<_iez2mem4.Currency> priceCurrency;

  late final _is.ColumnDouble price;

  late final _is.ColumnEnum<_i4hkjqgd.PaymentRail> paymentRail;

  late final _is.ColumnEnum<_iez2mem4.Currency> paymentCurrency;

  late final _is.ColumnDouble paymentAmount;

  late final _is.ColumnString paymentRef;

  late final _is.ColumnDateTime transactionTimestamp;

  late final _is.ColumnString clientReference;

  late final _is.ColumnEnum<_idpqotwg.OrderStatus> status;

  late final _is.ColumnString railDataJson;

  @override
  List<_is.Column> get columns => [
    id,
    railProductId,
    internalTransactionId,
    priceCurrency,
    price,
    paymentRail,
    paymentCurrency,
    paymentAmount,
    paymentRef,
    transactionTimestamp,
    clientReference,
    status,
    railDataJson,
  ];
}

class TransactionPaymentInclude extends _is.IncludeObject {
  TransactionPaymentInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => TransactionPayment.t;
}

class TransactionPaymentIncludeList extends _is.IncludeList {
  TransactionPaymentIncludeList._({
    _is.WhereExpressionBuilder<TransactionPaymentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TransactionPayment.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => TransactionPayment.t;
}

class TransactionPaymentRepository {
  const TransactionPaymentRepository._();

  /// Returns a list of [TransactionPayment]s matching the given query parameters.
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
  Future<List<TransactionPayment>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TransactionPaymentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TransactionPaymentTable>? orderBy,
    _is.OrderByListBuilder<TransactionPaymentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<TransactionPayment>(
      where: where?.call(TransactionPayment.t),
      orderBy: orderBy?.call(TransactionPayment.t),
      orderByList: orderByList?.call(TransactionPayment.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [TransactionPayment] matching the given query parameters.
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
  Future<TransactionPayment?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TransactionPaymentTable>? where,
    int? offset,
    _is.OrderByBuilder<TransactionPaymentTable>? orderBy,
    _is.OrderByListBuilder<TransactionPaymentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<TransactionPayment>(
      where: where?.call(TransactionPayment.t),
      orderBy: orderBy?.call(TransactionPayment.t),
      orderByList: orderByList?.call(TransactionPayment.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [TransactionPayment] by its [id] or null if no such row exists.
  Future<TransactionPayment?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<TransactionPayment>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [TransactionPayment]s in the list and returns the inserted rows.
  ///
  /// The returned [TransactionPayment]s will have their `id` fields set.
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
  Future<List<TransactionPayment>> insert(
    _is.DatabaseSession session,
    List<TransactionPayment> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<TransactionPayment>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [TransactionPayment] and returns the inserted row.
  ///
  /// The returned [TransactionPayment] will have its `id` field set.
  Future<TransactionPayment> insertRow(
    _is.DatabaseSession session,
    TransactionPayment row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<TransactionPayment>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [TransactionPayment]s in the list and returns the resulting rows.
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
  /// The returned [TransactionPayment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TransactionPayment>> upsert(
    _is.DatabaseSession session,
    List<TransactionPayment> rows, {
    required _is.ColumnSelections<TransactionPaymentTable> conflictColumns,
    _is.ColumnSelections<TransactionPaymentTable>? updateColumns,
    _is.WhereExpressionBuilder<TransactionPaymentTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<TransactionPayment>(
      rows,
      conflictColumns: conflictColumns(TransactionPayment.t),
      updateColumns: updateColumns?.call(TransactionPayment.t),
      updateWhere: updateWhere?.call(TransactionPayment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [TransactionPayment] and returns the resulting row.
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
  /// The returned [TransactionPayment] will have its `id` field set.
  Future<TransactionPayment?> upsertRow(
    _is.DatabaseSession session,
    TransactionPayment row, {
    required _is.ColumnSelections<TransactionPaymentTable> conflictColumns,
    _is.ColumnSelections<TransactionPaymentTable>? updateColumns,
    _is.WhereExpressionBuilder<TransactionPaymentTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<TransactionPayment>(
      row,
      conflictColumns: conflictColumns(TransactionPayment.t),
      updateColumns: updateColumns?.call(TransactionPayment.t),
      updateWhere: updateWhere?.call(TransactionPayment.t),
      transaction: transaction,
    );
  }

  /// Updates all [TransactionPayment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TransactionPayment>> update(
    _is.DatabaseSession session,
    List<TransactionPayment> rows, {
    _is.ColumnSelections<TransactionPaymentTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<TransactionPayment>(
      rows,
      columns: columns?.call(TransactionPayment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [TransactionPayment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TransactionPayment> updateRow(
    _is.DatabaseSession session,
    TransactionPayment row, {
    _is.ColumnSelections<TransactionPaymentTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<TransactionPayment>(
      row,
      columns: columns?.call(TransactionPayment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TransactionPayment] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TransactionPayment?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<TransactionPaymentUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<TransactionPayment>(
      id,
      columnValues: columnValues(TransactionPayment.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TransactionPayment]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TransactionPayment>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<TransactionPaymentUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<TransactionPaymentTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TransactionPaymentTable>? orderBy,
    _is.OrderByListBuilder<TransactionPaymentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<TransactionPayment>(
      columnValues: columnValues(TransactionPayment.t.updateTable),
      where: where(TransactionPayment.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TransactionPayment.t),
      orderByList: orderByList?.call(TransactionPayment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [TransactionPayment]s in the list and returns the deleted rows.
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
  Future<List<TransactionPayment>> delete(
    _is.DatabaseSession session,
    List<TransactionPayment> rows, {
    _is.OrderByBuilder<TransactionPaymentTable>? orderBy,
    _is.OrderByListBuilder<TransactionPaymentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<TransactionPayment>(
      rows,
      orderBy: orderBy?.call(TransactionPayment.t),
      orderByList: orderByList?.call(TransactionPayment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [TransactionPayment].
  Future<TransactionPayment> deleteRow(
    _is.DatabaseSession session,
    TransactionPayment row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TransactionPayment>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TransactionPayment>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TransactionPaymentTable> where,
    _is.OrderByBuilder<TransactionPaymentTable>? orderBy,
    _is.OrderByListBuilder<TransactionPaymentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<TransactionPayment>(
      where: where(TransactionPayment.t),
      orderBy: orderBy?.call(TransactionPayment.t),
      orderByList: orderByList?.call(TransactionPayment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TransactionPaymentTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<TransactionPayment>(
      where: where?.call(TransactionPayment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [TransactionPayment] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TransactionPaymentTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<TransactionPayment>(
      where: where(TransactionPayment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
