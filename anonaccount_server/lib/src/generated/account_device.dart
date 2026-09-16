/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:anonaccount_server/src/generated/protocol.dart' as _i1j1ale0;
import 'package:serverpod/serverpod.dart' as _is;
import 'account.dart' as _iulmo8pc;

abstract class AccountDevice
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  AccountDevice._({
    this.id,
    required this.anonAccountId,
    this.anonAccount,
    required this.deviceSigningPublicKeyHex,
    required this.deviceEncryptionPublicKeyHex,
    required this.encryptedDataKey,
    required this.label,
    required this.addedByAttestorPublicKeyHex,
    required this.addedByAttestation,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isRevoked,
    this.revokedAt,
    int? keyEpoch,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastActive = lastActive ?? DateTime.now(),
       isRevoked = isRevoked ?? false,
       keyEpoch = keyEpoch ?? 0;

  factory AccountDevice({
    _is.UuidValue? id,
    required _is.UuidValue anonAccountId,
    _iulmo8pc.AnonAccount? anonAccount,
    required String deviceSigningPublicKeyHex,
    required String deviceEncryptionPublicKeyHex,
    required String encryptedDataKey,
    required String label,
    required String addedByAttestorPublicKeyHex,
    required String addedByAttestation,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isRevoked,
    DateTime? revokedAt,
    int? keyEpoch,
  }) = _AccountDeviceImpl;

  factory AccountDevice.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountDevice(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      anonAccountId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['anonAccountId'],
      ),
      anonAccount: jsonSerialization['anonAccount'] == null
          ? null
          : _i1j1ale0.Protocol().deserialize<_iulmo8pc.AnonAccount>(
              jsonSerialization['anonAccount'],
            ),
      deviceSigningPublicKeyHex:
          jsonSerialization['deviceSigningPublicKeyHex'] as String,
      deviceEncryptionPublicKeyHex:
          jsonSerialization['deviceEncryptionPublicKeyHex'] as String,
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      label: jsonSerialization['label'] as String,
      addedByAttestorPublicKeyHex:
          jsonSerialization['addedByAttestorPublicKeyHex'] as String,
      addedByAttestation: jsonSerialization['addedByAttestation'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      lastActive: jsonSerialization['lastActive'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['lastActive']),
      isRevoked: jsonSerialization['isRevoked'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isRevoked']),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
      keyEpoch: jsonSerialization['keyEpoch'] as int?,
    );
  }

  static final t = AccountDeviceTable();

  static const db = AccountDeviceRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue anonAccountId;

  _iulmo8pc.AnonAccount? anonAccount;

  String deviceSigningPublicKeyHex;

  String deviceEncryptionPublicKeyHex;

  String encryptedDataKey;

  String label;

  String addedByAttestorPublicKeyHex;

  String addedByAttestation;

  DateTime createdAt;

  DateTime lastActive;

  bool isRevoked;

  DateTime? revokedAt;

  int keyEpoch;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AccountDevice]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AccountDevice copyWith({
    _is.UuidValue? id,
    _is.UuidValue? anonAccountId,
    _iulmo8pc.AnonAccount? anonAccount,
    String? deviceSigningPublicKeyHex,
    String? deviceEncryptionPublicKeyHex,
    String? encryptedDataKey,
    String? label,
    String? addedByAttestorPublicKeyHex,
    String? addedByAttestation,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isRevoked,
    DateTime? revokedAt,
    int? keyEpoch,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.AccountDevice',
      if (id != null) 'id': id?.toJson(),
      'anonAccountId': anonAccountId.toJson(),
      if (anonAccount != null) 'anonAccount': anonAccount?.toJson(),
      'deviceSigningPublicKeyHex': deviceSigningPublicKeyHex,
      'deviceEncryptionPublicKeyHex': deviceEncryptionPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'label': label,
      'addedByAttestorPublicKeyHex': addedByAttestorPublicKeyHex,
      'addedByAttestation': addedByAttestation,
      'createdAt': createdAt.toJson(),
      'lastActive': lastActive.toJson(),
      'isRevoked': isRevoked,
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      'keyEpoch': keyEpoch,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.AccountDevice',
      if (id != null) 'id': id?.toJson(),
      'anonAccountId': anonAccountId.toJson(),
      if (anonAccount != null) 'anonAccount': anonAccount?.toJsonForProtocol(),
      'deviceSigningPublicKeyHex': deviceSigningPublicKeyHex,
      'deviceEncryptionPublicKeyHex': deviceEncryptionPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'label': label,
      'addedByAttestorPublicKeyHex': addedByAttestorPublicKeyHex,
      'addedByAttestation': addedByAttestation,
      'createdAt': createdAt.toJson(),
      'lastActive': lastActive.toJson(),
      'isRevoked': isRevoked,
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      'keyEpoch': keyEpoch,
    };
  }

  static AccountDeviceInclude include({
    _iulmo8pc.AnonAccountInclude? anonAccount,
  }) {
    return AccountDeviceInclude._(anonAccount: anonAccount);
  }

  static AccountDeviceIncludeList includeList({
    _is.WhereExpressionBuilder<AccountDeviceTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountDeviceTable>? orderBy,
    _is.OrderByListBuilder<AccountDeviceTable>? orderByList,
    AccountDeviceInclude? include,
  }) {
    return AccountDeviceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccountDevice.t),
      orderByList: orderByList?.call(AccountDevice.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountDeviceImpl extends AccountDevice {
  _AccountDeviceImpl({
    _is.UuidValue? id,
    required _is.UuidValue anonAccountId,
    _iulmo8pc.AnonAccount? anonAccount,
    required String deviceSigningPublicKeyHex,
    required String deviceEncryptionPublicKeyHex,
    required String encryptedDataKey,
    required String label,
    required String addedByAttestorPublicKeyHex,
    required String addedByAttestation,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isRevoked,
    DateTime? revokedAt,
    int? keyEpoch,
  }) : super._(
         id: id,
         anonAccountId: anonAccountId,
         anonAccount: anonAccount,
         deviceSigningPublicKeyHex: deviceSigningPublicKeyHex,
         deviceEncryptionPublicKeyHex: deviceEncryptionPublicKeyHex,
         encryptedDataKey: encryptedDataKey,
         label: label,
         addedByAttestorPublicKeyHex: addedByAttestorPublicKeyHex,
         addedByAttestation: addedByAttestation,
         createdAt: createdAt,
         lastActive: lastActive,
         isRevoked: isRevoked,
         revokedAt: revokedAt,
         keyEpoch: keyEpoch,
       );

  /// Returns a shallow copy of this [AccountDevice]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AccountDevice copyWith({
    Object? id = _Undefined,
    _is.UuidValue? anonAccountId,
    Object? anonAccount = _Undefined,
    String? deviceSigningPublicKeyHex,
    String? deviceEncryptionPublicKeyHex,
    String? encryptedDataKey,
    String? label,
    String? addedByAttestorPublicKeyHex,
    String? addedByAttestation,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isRevoked,
    Object? revokedAt = _Undefined,
    int? keyEpoch,
  }) {
    return AccountDevice(
      id: id is _is.UuidValue? ? id : this.id,
      anonAccountId: anonAccountId ?? this.anonAccountId,
      anonAccount: anonAccount is _iulmo8pc.AnonAccount?
          ? anonAccount
          : this.anonAccount?.copyWith(),
      deviceSigningPublicKeyHex:
          deviceSigningPublicKeyHex ?? this.deviceSigningPublicKeyHex,
      deviceEncryptionPublicKeyHex:
          deviceEncryptionPublicKeyHex ?? this.deviceEncryptionPublicKeyHex,
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      label: label ?? this.label,
      addedByAttestorPublicKeyHex:
          addedByAttestorPublicKeyHex ?? this.addedByAttestorPublicKeyHex,
      addedByAttestation: addedByAttestation ?? this.addedByAttestation,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      isRevoked: isRevoked ?? this.isRevoked,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
      keyEpoch: keyEpoch ?? this.keyEpoch,
    );
  }
}

class AccountDeviceUpdateTable extends _is.UpdateTable<AccountDeviceTable> {
  AccountDeviceUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> anonAccountId(
    _is.UuidValue value,
  ) => _is.ColumnValue(table.anonAccountId, value);

  _is.ColumnValue<String, String> deviceSigningPublicKeyHex(String value) =>
      _is.ColumnValue(table.deviceSigningPublicKeyHex, value);

  _is.ColumnValue<String, String> deviceEncryptionPublicKeyHex(String value) =>
      _is.ColumnValue(table.deviceEncryptionPublicKeyHex, value);

  _is.ColumnValue<String, String> encryptedDataKey(String value) =>
      _is.ColumnValue(table.encryptedDataKey, value);

  _is.ColumnValue<String, String> label(String value) =>
      _is.ColumnValue(table.label, value);

  _is.ColumnValue<String, String> addedByAttestorPublicKeyHex(String value) =>
      _is.ColumnValue(table.addedByAttestorPublicKeyHex, value);

  _is.ColumnValue<String, String> addedByAttestation(String value) =>
      _is.ColumnValue(table.addedByAttestation, value);

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(table.createdAt, value);

  _is.ColumnValue<DateTime, DateTime> lastActive(DateTime value) =>
      _is.ColumnValue(table.lastActive, value);

  _is.ColumnValue<bool, bool> isRevoked(bool value) =>
      _is.ColumnValue(table.isRevoked, value);

  _is.ColumnValue<DateTime, DateTime> revokedAt(DateTime? value) =>
      _is.ColumnValue(table.revokedAt, value);

  _is.ColumnValue<int, int> keyEpoch(int value) =>
      _is.ColumnValue(table.keyEpoch, value);
}

class AccountDeviceTable extends _is.Table<_is.UuidValue?> {
  AccountDeviceTable({super.tableRelation})
    : super(tableName: 'account_device') {
    updateTable = AccountDeviceUpdateTable(this);
    anonAccountId = _is.ColumnUuid('anonAccountId', this);
    deviceSigningPublicKeyHex = _is.ColumnString(
      'deviceSigningPublicKeyHex',
      this,
    );
    deviceEncryptionPublicKeyHex = _is.ColumnString(
      'deviceEncryptionPublicKeyHex',
      this,
    );
    encryptedDataKey = _is.ColumnString('encryptedDataKey', this);
    label = _is.ColumnString('label', this);
    addedByAttestorPublicKeyHex = _is.ColumnString(
      'addedByAttestorPublicKeyHex',
      this,
    );
    addedByAttestation = _is.ColumnString('addedByAttestation', this);
    createdAt = _is.ColumnDateTime('createdAt', this, hasDefault: true);
    lastActive = _is.ColumnDateTime('lastActive', this, hasDefault: true);
    isRevoked = _is.ColumnBool('isRevoked', this, hasDefault: true);
    revokedAt = _is.ColumnDateTime('revokedAt', this);
    keyEpoch = _is.ColumnInt('keyEpoch', this, hasDefault: true);
  }

  late final AccountDeviceUpdateTable updateTable;

  late final _is.ColumnUuid anonAccountId;

  _iulmo8pc.AnonAccountTable? _anonAccount;

  late final _is.ColumnString deviceSigningPublicKeyHex;

  late final _is.ColumnString deviceEncryptionPublicKeyHex;

  late final _is.ColumnString encryptedDataKey;

  late final _is.ColumnString label;

  late final _is.ColumnString addedByAttestorPublicKeyHex;

  late final _is.ColumnString addedByAttestation;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime lastActive;

  late final _is.ColumnBool isRevoked;

  late final _is.ColumnDateTime revokedAt;

  late final _is.ColumnInt keyEpoch;

  _iulmo8pc.AnonAccountTable get anonAccount {
    if (_anonAccount != null) return _anonAccount!;
    _anonAccount = _is.createRelationTable(
      relationFieldName: 'anonAccount',
      field: AccountDevice.t.anonAccountId,
      foreignField: _iulmo8pc.AnonAccount.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iulmo8pc.AnonAccountTable(tableRelation: foreignTableRelation),
    );
    return _anonAccount!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    anonAccountId,
    deviceSigningPublicKeyHex,
    deviceEncryptionPublicKeyHex,
    encryptedDataKey,
    label,
    addedByAttestorPublicKeyHex,
    addedByAttestation,
    createdAt,
    lastActive,
    isRevoked,
    revokedAt,
    keyEpoch,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'anonAccount') {
      return anonAccount;
    }
    return null;
  }
}

class AccountDeviceInclude extends _is.IncludeObject {
  AccountDeviceInclude._({_iulmo8pc.AnonAccountInclude? anonAccount}) {
    _anonAccount = anonAccount;
  }

  _iulmo8pc.AnonAccountInclude? _anonAccount;

  @override
  Map<String, _is.Include?> get includes => {'anonAccount': _anonAccount};

  @override
  _is.Table<_is.UuidValue?> get table => AccountDevice.t;
}

class AccountDeviceIncludeList extends _is.IncludeList {
  AccountDeviceIncludeList._({
    _is.WhereExpressionBuilder<AccountDeviceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AccountDevice.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => AccountDevice.t;
}

class AccountDeviceRepository {
  const AccountDeviceRepository._();

  final attachRow = const AccountDeviceAttachRowRepository._();

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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountDeviceTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountDeviceTable>? orderBy,
    _is.OrderByListBuilder<AccountDeviceTable>? orderByList,
    _is.Transaction? transaction,
    AccountDeviceInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AccountDevice>(
      where: where?.call(AccountDevice.t),
      orderBy: orderBy?.call(AccountDevice.t),
      orderByList: orderByList?.call(AccountDevice.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountDeviceTable>? where,
    int? offset,
    _is.OrderByBuilder<AccountDeviceTable>? orderBy,
    _is.OrderByListBuilder<AccountDeviceTable>? orderByList,
    _is.Transaction? transaction,
    AccountDeviceInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AccountDevice>(
      where: where?.call(AccountDevice.t),
      orderBy: orderBy?.call(AccountDevice.t),
      orderByList: orderByList?.call(AccountDevice.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AccountDevice] by its [id] or null if no such row exists.
  Future<AccountDevice?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    AccountDeviceInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AccountDevice>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AccountDevice]s in the list and returns the inserted rows.
  ///
  /// The returned [AccountDevice]s will have their `id` fields set.
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
  Future<List<AccountDevice>> insert(
    _is.DatabaseSession session,
    List<AccountDevice> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AccountDevice>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AccountDevice] and returns the inserted row.
  ///
  /// The returned [AccountDevice] will have its `id` field set.
  Future<AccountDevice> insertRow(
    _is.DatabaseSession session,
    AccountDevice row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AccountDevice>(row, transaction: transaction);
  }

  /// Upserts all [AccountDevice]s in the list and returns the resulting rows.
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
  /// The returned [AccountDevice]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccountDevice>> upsert(
    _is.DatabaseSession session,
    List<AccountDevice> rows, {
    required _is.ColumnSelections<AccountDeviceTable> conflictColumns,
    _is.ColumnSelections<AccountDeviceTable>? updateColumns,
    _is.WhereExpressionBuilder<AccountDeviceTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AccountDevice>(
      rows,
      conflictColumns: conflictColumns(AccountDevice.t),
      updateColumns: updateColumns?.call(AccountDevice.t),
      updateWhere: updateWhere?.call(AccountDevice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AccountDevice] and returns the resulting row.
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
  /// The returned [AccountDevice] will have its `id` field set.
  Future<AccountDevice?> upsertRow(
    _is.DatabaseSession session,
    AccountDevice row, {
    required _is.ColumnSelections<AccountDeviceTable> conflictColumns,
    _is.ColumnSelections<AccountDeviceTable>? updateColumns,
    _is.WhereExpressionBuilder<AccountDeviceTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AccountDevice>(
      row,
      conflictColumns: conflictColumns(AccountDevice.t),
      updateColumns: updateColumns?.call(AccountDevice.t),
      updateWhere: updateWhere?.call(AccountDevice.t),
      transaction: transaction,
    );
  }

  /// Updates all [AccountDevice]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccountDevice>> update(
    _is.DatabaseSession session,
    List<AccountDevice> rows, {
    _is.ColumnSelections<AccountDeviceTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AccountDevice>(
      rows,
      columns: columns?.call(AccountDevice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AccountDevice]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AccountDevice> updateRow(
    _is.DatabaseSession session,
    AccountDevice row, {
    _is.ColumnSelections<AccountDeviceTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<AccountDeviceUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AccountDevice>(
      id,
      columnValues: columnValues(AccountDevice.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AccountDevice]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccountDevice>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AccountDeviceUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AccountDeviceTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountDeviceTable>? orderBy,
    _is.OrderByListBuilder<AccountDeviceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AccountDevice>(
      columnValues: columnValues(AccountDevice.t.updateTable),
      where: where(AccountDevice.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccountDevice.t),
      orderByList: orderByList?.call(AccountDevice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AccountDevice]s in the list and returns the deleted rows.
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
  Future<List<AccountDevice>> delete(
    _is.DatabaseSession session,
    List<AccountDevice> rows, {
    _is.OrderByBuilder<AccountDeviceTable>? orderBy,
    _is.OrderByListBuilder<AccountDeviceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AccountDevice>(
      rows,
      orderBy: orderBy?.call(AccountDevice.t),
      orderByList: orderByList?.call(AccountDevice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AccountDevice].
  Future<AccountDevice> deleteRow(
    _is.DatabaseSession session,
    AccountDevice row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AccountDevice>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccountDevice>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AccountDeviceTable> where,
    _is.OrderByBuilder<AccountDeviceTable>? orderBy,
    _is.OrderByListBuilder<AccountDeviceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AccountDevice>(
      where: where(AccountDevice.t),
      orderBy: orderBy?.call(AccountDevice.t),
      orderByList: orderByList?.call(AccountDevice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountDeviceTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AccountDevice>(
      where: where?.call(AccountDevice.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AccountDevice] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AccountDeviceTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AccountDevice>(
      where: where(AccountDevice.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class AccountDeviceAttachRowRepository {
  const AccountDeviceAttachRowRepository._();

  /// Creates a relation between the given [AccountDevice] and [AnonAccount]
  /// by setting the [AccountDevice]'s foreign key `anonAccountId` to refer to the [AnonAccount].
  Future<void> anonAccount(
    _is.DatabaseSession session,
    AccountDevice accountDevice,
    _iulmo8pc.AnonAccount anonAccount, {
    _is.Transaction? transaction,
  }) async {
    if (accountDevice.id == null) {
      throw ArgumentError.notNull('accountDevice.id');
    }
    if (anonAccount.id == null) {
      throw ArgumentError.notNull('anonAccount.id');
    }

    var $accountDevice = accountDevice.copyWith(anonAccountId: anonAccount.id);
    await session.db.updateRow<AccountDevice>(
      $accountDevice,
      columns: [AccountDevice.t.anonAccountId],
      transaction: transaction,
    );
  }
}
