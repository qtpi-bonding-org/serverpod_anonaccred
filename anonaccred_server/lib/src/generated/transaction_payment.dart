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
import 'currency.dart' as _i2;
import 'payment_rail.dart' as _i3;
import 'order_status.dart' as _i4;

abstract class TransactionPayment
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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
    required _i2.Currency priceCurrency,
    required double price,
    required _i3.PaymentRail paymentRail,
    required _i2.Currency paymentCurrency,
    required double paymentAmount,
    String? paymentRef,
    required DateTime transactionTimestamp,
    String? clientReference,
    required _i4.OrderStatus status,
    String? railDataJson,
  }) = _TransactionPaymentImpl;

  factory TransactionPayment.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransactionPayment(
      id: jsonSerialization['id'] as int?,
      railProductId: jsonSerialization['railProductId'] as int,
      internalTransactionId:
          jsonSerialization['internalTransactionId'] as String,
      priceCurrency: _i2.Currency.fromJson(
        (jsonSerialization['priceCurrency'] as String),
      ),
      price: (jsonSerialization['price'] as num).toDouble(),
      paymentRail: _i3.PaymentRail.fromJson(
        (jsonSerialization['paymentRail'] as String),
      ),
      paymentCurrency: _i2.Currency.fromJson(
        (jsonSerialization['paymentCurrency'] as String),
      ),
      paymentAmount: (jsonSerialization['paymentAmount'] as num).toDouble(),
      paymentRef: jsonSerialization['paymentRef'] as String?,
      transactionTimestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['transactionTimestamp'],
      ),
      clientReference: jsonSerialization['clientReference'] as String?,
      status: _i4.OrderStatus.fromJson((jsonSerialization['status'] as String)),
      railDataJson: jsonSerialization['railDataJson'] as String?,
    );
  }

  static final t = TransactionPaymentTable();

  static const db = TransactionPaymentRepository._();

  @override
  int? id;

  int railProductId;

  String internalTransactionId;

  _i2.Currency priceCurrency;

  double price;

  _i3.PaymentRail paymentRail;

  _i2.Currency paymentCurrency;

  double paymentAmount;

  String? paymentRef;

  DateTime transactionTimestamp;

  String? clientReference;

  _i4.OrderStatus status;

  String? railDataJson;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [TransactionPayment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TransactionPayment copyWith({
    int? id,
    int? railProductId,
    String? internalTransactionId,
    _i2.Currency? priceCurrency,
    double? price,
    _i3.PaymentRail? paymentRail,
    _i2.Currency? paymentCurrency,
    double? paymentAmount,
    String? paymentRef,
    DateTime? transactionTimestamp,
    String? clientReference,
    _i4.OrderStatus? status,
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
    _i1.WhereExpressionBuilder<TransactionPaymentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TransactionPaymentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TransactionPaymentTable>? orderByList,
    TransactionPaymentInclude? include,
  }) {
    return TransactionPaymentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TransactionPayment.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(TransactionPayment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransactionPaymentImpl extends TransactionPayment {
  _TransactionPaymentImpl({
    int? id,
    required int railProductId,
    required String internalTransactionId,
    required _i2.Currency priceCurrency,
    required double price,
    required _i3.PaymentRail paymentRail,
    required _i2.Currency paymentCurrency,
    required double paymentAmount,
    String? paymentRef,
    required DateTime transactionTimestamp,
    String? clientReference,
    required _i4.OrderStatus status,
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
  @_i1.useResult
  @override
  TransactionPayment copyWith({
    Object? id = _Undefined,
    int? railProductId,
    String? internalTransactionId,
    _i2.Currency? priceCurrency,
    double? price,
    _i3.PaymentRail? paymentRail,
    _i2.Currency? paymentCurrency,
    double? paymentAmount,
    Object? paymentRef = _Undefined,
    DateTime? transactionTimestamp,
    Object? clientReference = _Undefined,
    _i4.OrderStatus? status,
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
    extends _i1.UpdateTable<TransactionPaymentTable> {
  TransactionPaymentUpdateTable(super.table);

  _i1.ColumnValue<int, int> railProductId(int value) => _i1.ColumnValue(
    table.railProductId,
    value,
  );

  _i1.ColumnValue<String, String> internalTransactionId(String value) =>
      _i1.ColumnValue(
        table.internalTransactionId,
        value,
      );

  _i1.ColumnValue<_i2.Currency, _i2.Currency> priceCurrency(
    _i2.Currency value,
  ) => _i1.ColumnValue(
    table.priceCurrency,
    value,
  );

  _i1.ColumnValue<double, double> price(double value) => _i1.ColumnValue(
    table.price,
    value,
  );

  _i1.ColumnValue<_i3.PaymentRail, _i3.PaymentRail> paymentRail(
    _i3.PaymentRail value,
  ) => _i1.ColumnValue(
    table.paymentRail,
    value,
  );

  _i1.ColumnValue<_i2.Currency, _i2.Currency> paymentCurrency(
    _i2.Currency value,
  ) => _i1.ColumnValue(
    table.paymentCurrency,
    value,
  );

  _i1.ColumnValue<double, double> paymentAmount(double value) =>
      _i1.ColumnValue(
        table.paymentAmount,
        value,
      );

  _i1.ColumnValue<String, String> paymentRef(String? value) => _i1.ColumnValue(
    table.paymentRef,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> transactionTimestamp(DateTime value) =>
      _i1.ColumnValue(
        table.transactionTimestamp,
        value,
      );

  _i1.ColumnValue<String, String> clientReference(String? value) =>
      _i1.ColumnValue(
        table.clientReference,
        value,
      );

  _i1.ColumnValue<_i4.OrderStatus, _i4.OrderStatus> status(
    _i4.OrderStatus value,
  ) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<String, String> railDataJson(String? value) =>
      _i1.ColumnValue(
        table.railDataJson,
        value,
      );
}

class TransactionPaymentTable extends _i1.Table<int?> {
  TransactionPaymentTable({super.tableRelation})
    : super(tableName: 'transaction_payment') {
    updateTable = TransactionPaymentUpdateTable(this);
    railProductId = _i1.ColumnInt(
      'railProductId',
      this,
    );
    internalTransactionId = _i1.ColumnString(
      'internalTransactionId',
      this,
    );
    priceCurrency = _i1.ColumnEnum(
      'priceCurrency',
      this,
      _i1.EnumSerialization.byName,
    );
    price = _i1.ColumnDouble(
      'price',
      this,
    );
    paymentRail = _i1.ColumnEnum(
      'paymentRail',
      this,
      _i1.EnumSerialization.byName,
    );
    paymentCurrency = _i1.ColumnEnum(
      'paymentCurrency',
      this,
      _i1.EnumSerialization.byName,
    );
    paymentAmount = _i1.ColumnDouble(
      'paymentAmount',
      this,
    );
    paymentRef = _i1.ColumnString(
      'paymentRef',
      this,
    );
    transactionTimestamp = _i1.ColumnDateTime(
      'transactionTimestamp',
      this,
    );
    clientReference = _i1.ColumnString(
      'clientReference',
      this,
    );
    status = _i1.ColumnEnum(
      'status',
      this,
      _i1.EnumSerialization.byName,
    );
    railDataJson = _i1.ColumnString(
      'railDataJson',
      this,
    );
  }

  late final TransactionPaymentUpdateTable updateTable;

  late final _i1.ColumnInt railProductId;

  late final _i1.ColumnString internalTransactionId;

  late final _i1.ColumnEnum<_i2.Currency> priceCurrency;

  late final _i1.ColumnDouble price;

  late final _i1.ColumnEnum<_i3.PaymentRail> paymentRail;

  late final _i1.ColumnEnum<_i2.Currency> paymentCurrency;

  late final _i1.ColumnDouble paymentAmount;

  late final _i1.ColumnString paymentRef;

  late final _i1.ColumnDateTime transactionTimestamp;

  late final _i1.ColumnString clientReference;

  late final _i1.ColumnEnum<_i4.OrderStatus> status;

  late final _i1.ColumnString railDataJson;

  @override
  List<_i1.Column> get columns => [
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

class TransactionPaymentInclude extends _i1.IncludeObject {
  TransactionPaymentInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => TransactionPayment.t;
}

class TransactionPaymentIncludeList extends _i1.IncludeList {
  TransactionPaymentIncludeList._({
    _i1.WhereExpressionBuilder<TransactionPaymentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TransactionPayment.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => TransactionPayment.t;
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TransactionPaymentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TransactionPaymentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TransactionPaymentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<TransactionPayment>(
      where: where?.call(TransactionPayment.t),
      orderBy: orderBy?.call(TransactionPayment.t),
      orderByList: orderByList?.call(TransactionPayment.t),
      orderDescending: orderDescending,
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TransactionPaymentTable>? where,
    int? offset,
    _i1.OrderByBuilder<TransactionPaymentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TransactionPaymentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<TransactionPayment>(
      where: where?.call(TransactionPayment.t),
      orderBy: orderBy?.call(TransactionPayment.t),
      orderByList: orderByList?.call(TransactionPayment.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [TransactionPayment] by its [id] or null if no such row exists.
  Future<TransactionPayment?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
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
  Future<List<TransactionPayment>> insert(
    _i1.Session session,
    List<TransactionPayment> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<TransactionPayment>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [TransactionPayment] and returns the inserted row.
  ///
  /// The returned [TransactionPayment] will have its `id` field set.
  Future<TransactionPayment> insertRow(
    _i1.Session session,
    TransactionPayment row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<TransactionPayment>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [TransactionPayment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<TransactionPayment>> update(
    _i1.Session session,
    List<TransactionPayment> rows, {
    _i1.ColumnSelections<TransactionPaymentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<TransactionPayment>(
      rows,
      columns: columns?.call(TransactionPayment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TransactionPayment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TransactionPayment> updateRow(
    _i1.Session session,
    TransactionPayment row, {
    _i1.ColumnSelections<TransactionPaymentTable>? columns,
    _i1.Transaction? transaction,
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
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<TransactionPaymentUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<TransactionPayment>(
      id,
      columnValues: columnValues(TransactionPayment.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TransactionPayment]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<TransactionPayment>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<TransactionPaymentUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<TransactionPaymentTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TransactionPaymentTable>? orderBy,
    _i1.OrderByListBuilder<TransactionPaymentTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<TransactionPayment>(
      columnValues: columnValues(TransactionPayment.t.updateTable),
      where: where(TransactionPayment.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TransactionPayment.t),
      orderByList: orderByList?.call(TransactionPayment.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [TransactionPayment]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<TransactionPayment>> delete(
    _i1.Session session,
    List<TransactionPayment> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<TransactionPayment>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [TransactionPayment].
  Future<TransactionPayment> deleteRow(
    _i1.Session session,
    TransactionPayment row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TransactionPayment>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<TransactionPayment>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<TransactionPaymentTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<TransactionPayment>(
      where: where(TransactionPayment.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TransactionPaymentTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<TransactionPayment>(
      where: where?.call(TransactionPayment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [TransactionPayment] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<TransactionPaymentTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<TransactionPayment>(
      where: where(TransactionPayment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
