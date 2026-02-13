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

abstract class AccountDevice
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  AccountDevice._({
    this.id,
    required this.accountId,
    required this.deviceSigningPublicKeyHex,
    required this.encryptedDataKey,
    required this.label,
    DateTime? lastActive,
    bool? isRevoked,
  }) : lastActive = lastActive ?? DateTime.now(),
       isRevoked = isRevoked ?? false;

  factory AccountDevice({
    int? id,
    required int accountId,
    required String deviceSigningPublicKeyHex,
    required String encryptedDataKey,
    required String label,
    DateTime? lastActive,
    bool? isRevoked,
  }) = _AccountDeviceImpl;

  factory AccountDevice.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountDevice(
      id: jsonSerialization['id'] as int?,
      accountId: jsonSerialization['accountId'] as int,
      deviceSigningPublicKeyHex:
          jsonSerialization['deviceSigningPublicKeyHex'] as String,
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      label: jsonSerialization['label'] as String,
      lastActive: jsonSerialization['lastActive'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastActive']),
      isRevoked: jsonSerialization['isRevoked'] as bool?,
    );
  }

  static final t = AccountDeviceTable();

  static const db = AccountDeviceRepository._();

  @override
  int? id;

  int accountId;

  String deviceSigningPublicKeyHex;

  String encryptedDataKey;

  String label;

  DateTime lastActive;

  bool isRevoked;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [AccountDevice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AccountDevice copyWith({
    int? id,
    int? accountId,
    String? deviceSigningPublicKeyHex,
    String? encryptedDataKey,
    String? label,
    DateTime? lastActive,
    bool? isRevoked,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.AccountDevice',
      if (id != null) 'id': id,
      'accountId': accountId,
      'deviceSigningPublicKeyHex': deviceSigningPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'label': label,
      'lastActive': lastActive.toJson(),
      'isRevoked': isRevoked,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.AccountDevice',
      if (id != null) 'id': id,
      'accountId': accountId,
      'deviceSigningPublicKeyHex': deviceSigningPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'label': label,
      'lastActive': lastActive.toJson(),
      'isRevoked': isRevoked,
    };
  }

  static AccountDeviceInclude include() {
    return AccountDeviceInclude._();
  }

  static AccountDeviceIncludeList includeList({
    _i1.WhereExpressionBuilder<AccountDeviceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AccountDeviceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AccountDeviceTable>? orderByList,
    AccountDeviceInclude? include,
  }) {
    return AccountDeviceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccountDevice.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AccountDevice.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountDeviceImpl extends AccountDevice {
  _AccountDeviceImpl({
    int? id,
    required int accountId,
    required String deviceSigningPublicKeyHex,
    required String encryptedDataKey,
    required String label,
    DateTime? lastActive,
    bool? isRevoked,
  }) : super._(
         id: id,
         accountId: accountId,
         deviceSigningPublicKeyHex: deviceSigningPublicKeyHex,
         encryptedDataKey: encryptedDataKey,
         label: label,
         lastActive: lastActive,
         isRevoked: isRevoked,
       );

  /// Returns a shallow copy of this [AccountDevice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AccountDevice copyWith({
    Object? id = _Undefined,
    int? accountId,
    String? deviceSigningPublicKeyHex,
    String? encryptedDataKey,
    String? label,
    DateTime? lastActive,
    bool? isRevoked,
  }) {
    return AccountDevice(
      id: id is int? ? id : this.id,
      accountId: accountId ?? this.accountId,
      deviceSigningPublicKeyHex:
          deviceSigningPublicKeyHex ?? this.deviceSigningPublicKeyHex,
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      label: label ?? this.label,
      lastActive: lastActive ?? this.lastActive,
      isRevoked: isRevoked ?? this.isRevoked,
    );
  }
}

class AccountDeviceUpdateTable extends _i1.UpdateTable<AccountDeviceTable> {
  AccountDeviceUpdateTable(super.table);

  _i1.ColumnValue<int, int> accountId(int value) => _i1.ColumnValue(
    table.accountId,
    value,
  );

  _i1.ColumnValue<String, String> deviceSigningPublicKeyHex(String value) =>
      _i1.ColumnValue(
        table.deviceSigningPublicKeyHex,
        value,
      );

  _i1.ColumnValue<String, String> encryptedDataKey(String value) =>
      _i1.ColumnValue(
        table.encryptedDataKey,
        value,
      );

  _i1.ColumnValue<String, String> label(String value) => _i1.ColumnValue(
    table.label,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> lastActive(DateTime value) =>
      _i1.ColumnValue(
        table.lastActive,
        value,
      );

  _i1.ColumnValue<bool, bool> isRevoked(bool value) => _i1.ColumnValue(
    table.isRevoked,
    value,
  );
}

class AccountDeviceTable extends _i1.Table<int?> {
  AccountDeviceTable({super.tableRelation})
    : super(tableName: 'account_device') {
    updateTable = AccountDeviceUpdateTable(this);
    accountId = _i1.ColumnInt(
      'accountId',
      this,
    );
    deviceSigningPublicKeyHex = _i1.ColumnString(
      'deviceSigningPublicKeyHex',
      this,
    );
    encryptedDataKey = _i1.ColumnString(
      'encryptedDataKey',
      this,
    );
    label = _i1.ColumnString(
      'label',
      this,
    );
    lastActive = _i1.ColumnDateTime(
      'lastActive',
      this,
      hasDefault: true,
    );
    isRevoked = _i1.ColumnBool(
      'isRevoked',
      this,
      hasDefault: true,
    );
  }

  late final AccountDeviceUpdateTable updateTable;

  late final _i1.ColumnInt accountId;

  late final _i1.ColumnString deviceSigningPublicKeyHex;

  late final _i1.ColumnString encryptedDataKey;

  late final _i1.ColumnString label;

  late final _i1.ColumnDateTime lastActive;

  late final _i1.ColumnBool isRevoked;

  @override
  List<_i1.Column> get columns => [
    id,
    accountId,
    deviceSigningPublicKeyHex,
    encryptedDataKey,
    label,
    lastActive,
    isRevoked,
  ];
}

class AccountDeviceInclude extends _i1.IncludeObject {
  AccountDeviceInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => AccountDevice.t;
}

class AccountDeviceIncludeList extends _i1.IncludeList {
  AccountDeviceIncludeList._({
    _i1.WhereExpressionBuilder<AccountDeviceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AccountDevice.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => AccountDevice.t;
}

class AccountDeviceRepository {
  const AccountDeviceRepository._();

  /// Returns a list of [AccountDevice]s matching the given query parameters.
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
  Future<List<AccountDevice>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AccountDeviceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AccountDeviceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AccountDeviceTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<AccountDevice>(
      where: where?.call(AccountDevice.t),
      orderBy: orderBy?.call(AccountDevice.t),
      orderByList: orderByList?.call(AccountDevice.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [AccountDevice] matching the given query parameters.
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
  Future<AccountDevice?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AccountDeviceTable>? where,
    int? offset,
    _i1.OrderByBuilder<AccountDeviceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AccountDeviceTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<AccountDevice>(
      where: where?.call(AccountDevice.t),
      orderBy: orderBy?.call(AccountDevice.t),
      orderByList: orderByList?.call(AccountDevice.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [AccountDevice] by its [id] or null if no such row exists.
  Future<AccountDevice?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<AccountDevice>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [AccountDevice]s in the list and returns the inserted rows.
  ///
  /// The returned [AccountDevice]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<AccountDevice>> insert(
    _i1.Session session,
    List<AccountDevice> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<AccountDevice>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [AccountDevice] and returns the inserted row.
  ///
  /// The returned [AccountDevice] will have its `id` field set.
  Future<AccountDevice> insertRow(
    _i1.Session session,
    AccountDevice row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AccountDevice>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [AccountDevice]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AccountDevice>> update(
    _i1.Session session,
    List<AccountDevice> rows, {
    _i1.ColumnSelections<AccountDeviceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AccountDevice>(
      rows,
      columns: columns?.call(AccountDevice.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AccountDevice]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AccountDevice> updateRow(
    _i1.Session session,
    AccountDevice row, {
    _i1.ColumnSelections<AccountDeviceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AccountDevice>(
      row,
      columns: columns?.call(AccountDevice.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AccountDevice] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AccountDevice?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<AccountDeviceUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AccountDevice>(
      id,
      columnValues: columnValues(AccountDevice.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AccountDevice]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AccountDevice>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<AccountDeviceUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<AccountDeviceTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AccountDeviceTable>? orderBy,
    _i1.OrderByListBuilder<AccountDeviceTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AccountDevice>(
      columnValues: columnValues(AccountDevice.t.updateTable),
      where: where(AccountDevice.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccountDevice.t),
      orderByList: orderByList?.call(AccountDevice.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AccountDevice]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AccountDevice>> delete(
    _i1.Session session,
    List<AccountDevice> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AccountDevice>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [AccountDevice].
  Future<AccountDevice> deleteRow(
    _i1.Session session,
    AccountDevice row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AccountDevice>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AccountDevice>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<AccountDeviceTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AccountDevice>(
      where: where(AccountDevice.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AccountDeviceTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AccountDevice>(
      where: where?.call(AccountDevice.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
