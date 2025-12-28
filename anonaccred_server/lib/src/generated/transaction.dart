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
import 'order_status.dart' as _i2;
import 'enums.dart' as _i3;
import 'payment_rail.dart' as _i4;

abstract class TransactionPayment
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  TransactionPayment._({
    this.id,
    required this.externalId,
    required this.accountId,
    required this.priceCurrency,
    required this.price,
    required this.paymentRail,
    required this.paymentCurrency,
    required this.paymentAmount,
    this.paymentRef,
    this.transactionHash,
    _i2.OrderStatus? status,
    DateTime? timestamp,
  }) : status = status ?? _i2.OrderStatus.pending,
       timestamp = timestamp ?? DateTime.now();

  factory TransactionPayment({
    int? id,
    required String externalId,
    required int accountId,
    required _i3.Currency priceCurrency,
    required double price,
    required _i4.PaymentRail paymentRail,
    required _i3.Currency paymentCurrency,
    required double paymentAmount,
    String? paymentRef,
    String? transactionHash,
    _i2.OrderStatus? status,
    DateTime? timestamp,
  }) = _TransactionPaymentImpl;

  factory TransactionPayment.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransactionPayment(
      id: jsonSerialization['id'] as int?,
      externalId: jsonSerialization['externalId'] as String,
      accountId: jsonSerialization['accountId'] as int,
      priceCurrency: _i3.Currency.fromJson(
        (jsonSerialization['priceCurrency'] as String),
      ),
      price: (jsonSerialization['price'] as num).toDouble(),
      paymentRail: _i4.PaymentRail.fromJson(
        (jsonSerialization['paymentRail'] as String),
      ),
      paymentCurrency: _i3.Currency.fromJson(
        (jsonSerialization['paymentCurrency'] as String),
      ),
      paymentAmount: (jsonSerialization['paymentAmount'] as num).toDouble(),
      paymentRef: jsonSerialization['paymentRef'] as String?,
      transactionHash: jsonSerialization['transactionHash'] as String?,
      status: _i2.OrderStatus.fromJson((jsonSerialization['status'] as String)),
      timestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
    );
  }

  static final t = TransactionPaymentTable();

  static const db = TransactionPaymentRepository._();

  @override
  int? id;

  String externalId;

  int accountId;

  _i3.Currency priceCurrency;

  double price;

  _i4.PaymentRail paymentRail;

  _i3.Currency paymentCurrency;

  double paymentAmount;

  String? paymentRef;

  String? transactionHash;

  _i2.OrderStatus status;

  DateTime timestamp;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [TransactionPayment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TransactionPayment copyWith({
    int? id,
    String? externalId,
    int? accountId,
    _i3.Currency? priceCurrency,
    double? price,
    _i4.PaymentRail? paymentRail,
    _i3.Currency? paymentCurrency,
    double? paymentAmount,
    String? paymentRef,
    String? transactionHash,
    _i2.OrderStatus? status,
    DateTime? timestamp,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.TransactionPayment',
      if (id != null) 'id': id,
      'externalId': externalId,
      'accountId': accountId,
      'priceCurrency': priceCurrency.toJson(),
      'price': price,
      'paymentRail': paymentRail.toJson(),
      'paymentCurrency': paymentCurrency.toJson(),
      'paymentAmount': paymentAmount,
      if (paymentRef != null) 'paymentRef': paymentRef,
      if (transactionHash != null) 'transactionHash': transactionHash,
      'status': status.toJson(),
      'timestamp': timestamp.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.TransactionPayment',
      if (id != null) 'id': id,
      'externalId': externalId,
      'accountId': accountId,
      'priceCurrency': priceCurrency.toJson(),
      'price': price,
      'paymentRail': paymentRail.toJson(),
      'paymentCurrency': paymentCurrency.toJson(),
      'paymentAmount': paymentAmount,
      if (paymentRef != null) 'paymentRef': paymentRef,
      if (transactionHash != null) 'transactionHash': transactionHash,
      'status': status.toJson(),
      'timestamp': timestamp.toJson(),
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
    required String externalId,
    required int accountId,
    required _i3.Currency priceCurrency,
    required double price,
    required _i4.PaymentRail paymentRail,
    required _i3.Currency paymentCurrency,
    required double paymentAmount,
    String? paymentRef,
    String? transactionHash,
    _i2.OrderStatus? status,
    DateTime? timestamp,
  }) : super._(
         id: id,
         externalId: externalId,
         accountId: accountId,
         priceCurrency: priceCurrency,
         price: price,
         paymentRail: paymentRail,
         paymentCurrency: paymentCurrency,
         paymentAmount: paymentAmount,
         paymentRef: paymentRef,
         transactionHash: transactionHash,
         status: status,
         timestamp: timestamp,
       );

  /// Returns a shallow copy of this [TransactionPayment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TransactionPayment copyWith({
    Object? id = _Undefined,
    String? externalId,
    int? accountId,
    _i3.Currency? priceCurrency,
    double? price,
    _i4.PaymentRail? paymentRail,
    _i3.Currency? paymentCurrency,
    double? paymentAmount,
    Object? paymentRef = _Undefined,
    Object? transactionHash = _Undefined,
    _i2.OrderStatus? status,
    DateTime? timestamp,
  }) {
    return TransactionPayment(
      id: id is int? ? id : this.id,
      externalId: externalId ?? this.externalId,
      accountId: accountId ?? this.accountId,
      priceCurrency: priceCurrency ?? this.priceCurrency,
      price: price ?? this.price,
      paymentRail: paymentRail ?? this.paymentRail,
      paymentCurrency: paymentCurrency ?? this.paymentCurrency,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentRef: paymentRef is String? ? paymentRef : this.paymentRef,
      transactionHash: transactionHash is String?
          ? transactionHash
          : this.transactionHash,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class TransactionPaymentUpdateTable
    extends _i1.UpdateTable<TransactionPaymentTable> {
  TransactionPaymentUpdateTable(super.table);

  _i1.ColumnValue<String, String> externalId(String value) => _i1.ColumnValue(
    table.externalId,
    value,
  );

  _i1.ColumnValue<int, int> accountId(int value) => _i1.ColumnValue(
    table.accountId,
    value,
  );

  _i1.ColumnValue<_i3.Currency, _i3.Currency> priceCurrency(
    _i3.Currency value,
  ) => _i1.ColumnValue(
    table.priceCurrency,
    value,
  );

  _i1.ColumnValue<double, double> price(double value) => _i1.ColumnValue(
    table.price,
    value,
  );

  _i1.ColumnValue<_i4.PaymentRail, _i4.PaymentRail> paymentRail(
    _i4.PaymentRail value,
  ) => _i1.ColumnValue(
    table.paymentRail,
    value,
  );

  _i1.ColumnValue<_i3.Currency, _i3.Currency> paymentCurrency(
    _i3.Currency value,
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

  _i1.ColumnValue<String, String> transactionHash(String? value) =>
      _i1.ColumnValue(
        table.transactionHash,
        value,
      );

  _i1.ColumnValue<_i2.OrderStatus, _i2.OrderStatus> status(
    _i2.OrderStatus value,
  ) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> timestamp(DateTime value) =>
      _i1.ColumnValue(
        table.timestamp,
        value,
      );
}

class TransactionPaymentTable extends _i1.Table<int?> {
  TransactionPaymentTable({super.tableRelation})
    : super(tableName: 'transaction_payment') {
    updateTable = TransactionPaymentUpdateTable(this);
    externalId = _i1.ColumnString(
      'externalId',
      this,
    );
    accountId = _i1.ColumnInt(
      'accountId',
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
    transactionHash = _i1.ColumnString(
      'transactionHash',
      this,
    );
    status = _i1.ColumnEnum(
      'status',
      this,
      _i1.EnumSerialization.byName,
      hasDefault: true,
    );
    timestamp = _i1.ColumnDateTime(
      'timestamp',
      this,
      hasDefault: true,
    );
  }

  late final TransactionPaymentUpdateTable updateTable;

  late final _i1.ColumnString externalId;

  late final _i1.ColumnInt accountId;

  late final _i1.ColumnEnum<_i3.Currency> priceCurrency;

  late final _i1.ColumnDouble price;

  late final _i1.ColumnEnum<_i4.PaymentRail> paymentRail;

  late final _i1.ColumnEnum<_i3.Currency> paymentCurrency;

  late final _i1.ColumnDouble paymentAmount;

  late final _i1.ColumnString paymentRef;

  late final _i1.ColumnString transactionHash;

  late final _i1.ColumnEnum<_i2.OrderStatus> status;

  late final _i1.ColumnDateTime timestamp;

  @override
  List<_i1.Column> get columns => [
    id,
    externalId,
    accountId,
    priceCurrency,
    price,
    paymentRail,
    paymentCurrency,
    paymentAmount,
    paymentRef,
    transactionHash,
    status,
    timestamp,
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
  }) async {
    return session.db.find<TransactionPayment>(
      where: where?.call(TransactionPayment.t),
      orderBy: orderBy?.call(TransactionPayment.t),
      orderByList: orderByList?.call(TransactionPayment.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
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
  }) async {
    return session.db.findFirstRow<TransactionPayment>(
      where: where?.call(TransactionPayment.t),
      orderBy: orderBy?.call(TransactionPayment.t),
      orderByList: orderByList?.call(TransactionPayment.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [TransactionPayment] by its [id] or null if no such row exists.
  Future<TransactionPayment?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<TransactionPayment>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [TransactionPayment]s in the list and returns the inserted rows.
  ///
  /// The returned [TransactionPayment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<TransactionPayment>> insert(
    _i1.Session session,
    List<TransactionPayment> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<TransactionPayment>(
      rows,
      transaction: transaction,
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
}
