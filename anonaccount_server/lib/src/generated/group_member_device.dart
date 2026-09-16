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
import 'account_device.dart' as _iepmyrfy;
import 'group_member.dart' as _igiek2ee;

abstract class GroupMemberDevice
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  GroupMemberDevice._({
    this.id,
    required this.groupMemberId,
    this.groupMember,
    required this.accountDeviceId,
    this.accountDevice,
    required this.encryptedDataKey,
    required this.addedByAttestorPublicKeyHex,
    required this.addedByAttestation,
    DateTime? createdAt,
    bool? isRevoked,
    this.revokedAt,
    int? keyEpoch,
  }) : createdAt = createdAt ?? DateTime.now(),
       isRevoked = isRevoked ?? false,
       keyEpoch = keyEpoch ?? 0;

  factory GroupMemberDevice({
    _is.UuidValue? id,
    required _is.UuidValue groupMemberId,
    _igiek2ee.GroupMember? groupMember,
    required _is.UuidValue accountDeviceId,
    _iepmyrfy.AccountDevice? accountDevice,
    required String encryptedDataKey,
    required String addedByAttestorPublicKeyHex,
    required String addedByAttestation,
    DateTime? createdAt,
    bool? isRevoked,
    DateTime? revokedAt,
    int? keyEpoch,
  }) = _GroupMemberDeviceImpl;

  factory GroupMemberDevice.fromJson(Map<String, dynamic> jsonSerialization) {
    return GroupMemberDevice(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      groupMemberId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['groupMemberId'],
      ),
      groupMember: jsonSerialization['groupMember'] == null
          ? null
          : _i1j1ale0.Protocol().deserialize<_igiek2ee.GroupMember>(
              jsonSerialization['groupMember'],
            ),
      accountDeviceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountDeviceId'],
      ),
      accountDevice: jsonSerialization['accountDevice'] == null
          ? null
          : _i1j1ale0.Protocol().deserialize<_iepmyrfy.AccountDevice>(
              jsonSerialization['accountDevice'],
            ),
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      addedByAttestorPublicKeyHex:
          jsonSerialization['addedByAttestorPublicKeyHex'] as String,
      addedByAttestation: jsonSerialization['addedByAttestation'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      isRevoked: jsonSerialization['isRevoked'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isRevoked']),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
      keyEpoch: jsonSerialization['keyEpoch'] as int?,
    );
  }

  static final t = GroupMemberDeviceTable();

  static const db = GroupMemberDeviceRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue groupMemberId;

  _igiek2ee.GroupMember? groupMember;

  _is.UuidValue accountDeviceId;

  _iepmyrfy.AccountDevice? accountDevice;

  String encryptedDataKey;

  String addedByAttestorPublicKeyHex;

  String addedByAttestation;

  DateTime createdAt;

  bool isRevoked;

  DateTime? revokedAt;

  int keyEpoch;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [GroupMemberDevice]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  GroupMemberDevice copyWith({
    _is.UuidValue? id,
    _is.UuidValue? groupMemberId,
    _igiek2ee.GroupMember? groupMember,
    _is.UuidValue? accountDeviceId,
    _iepmyrfy.AccountDevice? accountDevice,
    String? encryptedDataKey,
    String? addedByAttestorPublicKeyHex,
    String? addedByAttestation,
    DateTime? createdAt,
    bool? isRevoked,
    DateTime? revokedAt,
    int? keyEpoch,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.GroupMemberDevice',
      if (id != null) 'id': id?.toJson(),
      'groupMemberId': groupMemberId.toJson(),
      if (groupMember != null) 'groupMember': groupMember?.toJson(),
      'accountDeviceId': accountDeviceId.toJson(),
      if (accountDevice != null) 'accountDevice': accountDevice?.toJson(),
      'encryptedDataKey': encryptedDataKey,
      'addedByAttestorPublicKeyHex': addedByAttestorPublicKeyHex,
      'addedByAttestation': addedByAttestation,
      'createdAt': createdAt.toJson(),
      'isRevoked': isRevoked,
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      'keyEpoch': keyEpoch,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.GroupMemberDevice',
      if (id != null) 'id': id?.toJson(),
      'groupMemberId': groupMemberId.toJson(),
      if (groupMember != null) 'groupMember': groupMember?.toJsonForProtocol(),
      'accountDeviceId': accountDeviceId.toJson(),
      if (accountDevice != null)
        'accountDevice': accountDevice?.toJsonForProtocol(),
      'encryptedDataKey': encryptedDataKey,
      'addedByAttestorPublicKeyHex': addedByAttestorPublicKeyHex,
      'addedByAttestation': addedByAttestation,
      'createdAt': createdAt.toJson(),
      'isRevoked': isRevoked,
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      'keyEpoch': keyEpoch,
    };
  }

  static GroupMemberDeviceInclude include({
    _igiek2ee.GroupMemberInclude? groupMember,
    _iepmyrfy.AccountDeviceInclude? accountDevice,
  }) {
    return GroupMemberDeviceInclude._(
      groupMember: groupMember,
      accountDevice: accountDevice,
    );
  }

  static GroupMemberDeviceIncludeList includeList({
    _is.WhereExpressionBuilder<GroupMemberDeviceTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupMemberDeviceTable>? orderBy,
    _is.OrderByListBuilder<GroupMemberDeviceTable>? orderByList,
    GroupMemberDeviceInclude? include,
  }) {
    return GroupMemberDeviceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupMemberDevice.t),
      orderByList: orderByList?.call(GroupMemberDevice.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupMemberDeviceImpl extends GroupMemberDevice {
  _GroupMemberDeviceImpl({
    _is.UuidValue? id,
    required _is.UuidValue groupMemberId,
    _igiek2ee.GroupMember? groupMember,
    required _is.UuidValue accountDeviceId,
    _iepmyrfy.AccountDevice? accountDevice,
    required String encryptedDataKey,
    required String addedByAttestorPublicKeyHex,
    required String addedByAttestation,
    DateTime? createdAt,
    bool? isRevoked,
    DateTime? revokedAt,
    int? keyEpoch,
  }) : super._(
         id: id,
         groupMemberId: groupMemberId,
         groupMember: groupMember,
         accountDeviceId: accountDeviceId,
         accountDevice: accountDevice,
         encryptedDataKey: encryptedDataKey,
         addedByAttestorPublicKeyHex: addedByAttestorPublicKeyHex,
         addedByAttestation: addedByAttestation,
         createdAt: createdAt,
         isRevoked: isRevoked,
         revokedAt: revokedAt,
         keyEpoch: keyEpoch,
       );

  /// Returns a shallow copy of this [GroupMemberDevice]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  GroupMemberDevice copyWith({
    Object? id = _Undefined,
    _is.UuidValue? groupMemberId,
    Object? groupMember = _Undefined,
    _is.UuidValue? accountDeviceId,
    Object? accountDevice = _Undefined,
    String? encryptedDataKey,
    String? addedByAttestorPublicKeyHex,
    String? addedByAttestation,
    DateTime? createdAt,
    bool? isRevoked,
    Object? revokedAt = _Undefined,
    int? keyEpoch,
  }) {
    return GroupMemberDevice(
      id: id is _is.UuidValue? ? id : this.id,
      groupMemberId: groupMemberId ?? this.groupMemberId,
      groupMember: groupMember is _igiek2ee.GroupMember?
          ? groupMember
          : this.groupMember?.copyWith(),
      accountDeviceId: accountDeviceId ?? this.accountDeviceId,
      accountDevice: accountDevice is _iepmyrfy.AccountDevice?
          ? accountDevice
          : this.accountDevice?.copyWith(),
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      addedByAttestorPublicKeyHex:
          addedByAttestorPublicKeyHex ?? this.addedByAttestorPublicKeyHex,
      addedByAttestation: addedByAttestation ?? this.addedByAttestation,
      createdAt: createdAt ?? this.createdAt,
      isRevoked: isRevoked ?? this.isRevoked,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
      keyEpoch: keyEpoch ?? this.keyEpoch,
    );
  }
}

class GroupMemberDeviceUpdateTable
    extends _is.UpdateTable<GroupMemberDeviceTable> {
  GroupMemberDeviceUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> groupMemberId(
    _is.UuidValue value,
  ) => _is.ColumnValue(table.groupMemberId, value);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> accountDeviceId(
    _is.UuidValue value,
  ) => _is.ColumnValue(table.accountDeviceId, value);

  _is.ColumnValue<String, String> encryptedDataKey(String value) =>
      _is.ColumnValue(table.encryptedDataKey, value);

  _is.ColumnValue<String, String> addedByAttestorPublicKeyHex(String value) =>
      _is.ColumnValue(table.addedByAttestorPublicKeyHex, value);

  _is.ColumnValue<String, String> addedByAttestation(String value) =>
      _is.ColumnValue(table.addedByAttestation, value);

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(table.createdAt, value);

  _is.ColumnValue<bool, bool> isRevoked(bool value) =>
      _is.ColumnValue(table.isRevoked, value);

  _is.ColumnValue<DateTime, DateTime> revokedAt(DateTime? value) =>
      _is.ColumnValue(table.revokedAt, value);

  _is.ColumnValue<int, int> keyEpoch(int value) =>
      _is.ColumnValue(table.keyEpoch, value);
}

class GroupMemberDeviceTable extends _is.Table<_is.UuidValue?> {
  GroupMemberDeviceTable({super.tableRelation})
    : super(tableName: 'group_member_device') {
    updateTable = GroupMemberDeviceUpdateTable(this);
    groupMemberId = _is.ColumnUuid('groupMemberId', this);
    accountDeviceId = _is.ColumnUuid('accountDeviceId', this);
    encryptedDataKey = _is.ColumnString('encryptedDataKey', this);
    addedByAttestorPublicKeyHex = _is.ColumnString(
      'addedByAttestorPublicKeyHex',
      this,
    );
    addedByAttestation = _is.ColumnString('addedByAttestation', this);
    createdAt = _is.ColumnDateTime('createdAt', this, hasDefault: true);
    isRevoked = _is.ColumnBool('isRevoked', this, hasDefault: true);
    revokedAt = _is.ColumnDateTime('revokedAt', this);
    keyEpoch = _is.ColumnInt('keyEpoch', this, hasDefault: true);
  }

  late final GroupMemberDeviceUpdateTable updateTable;

  late final _is.ColumnUuid groupMemberId;

  _igiek2ee.GroupMemberTable? _groupMember;

  late final _is.ColumnUuid accountDeviceId;

  _iepmyrfy.AccountDeviceTable? _accountDevice;

  late final _is.ColumnString encryptedDataKey;

  late final _is.ColumnString addedByAttestorPublicKeyHex;

  late final _is.ColumnString addedByAttestation;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnBool isRevoked;

  late final _is.ColumnDateTime revokedAt;

  late final _is.ColumnInt keyEpoch;

  _igiek2ee.GroupMemberTable get groupMember {
    if (_groupMember != null) return _groupMember!;
    _groupMember = _is.createRelationTable(
      relationFieldName: 'groupMember',
      field: GroupMemberDevice.t.groupMemberId,
      foreignField: _igiek2ee.GroupMember.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _igiek2ee.GroupMemberTable(tableRelation: foreignTableRelation),
    );
    return _groupMember!;
  }

  _iepmyrfy.AccountDeviceTable get accountDevice {
    if (_accountDevice != null) return _accountDevice!;
    _accountDevice = _is.createRelationTable(
      relationFieldName: 'accountDevice',
      field: GroupMemberDevice.t.accountDeviceId,
      foreignField: _iepmyrfy.AccountDevice.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iepmyrfy.AccountDeviceTable(tableRelation: foreignTableRelation),
    );
    return _accountDevice!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    groupMemberId,
    accountDeviceId,
    encryptedDataKey,
    addedByAttestorPublicKeyHex,
    addedByAttestation,
    createdAt,
    isRevoked,
    revokedAt,
    keyEpoch,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'groupMember') {
      return groupMember;
    }
    if (relationField == 'accountDevice') {
      return accountDevice;
    }
    return null;
  }
}

class GroupMemberDeviceInclude extends _is.IncludeObject {
  GroupMemberDeviceInclude._({
    _igiek2ee.GroupMemberInclude? groupMember,
    _iepmyrfy.AccountDeviceInclude? accountDevice,
  }) {
    _groupMember = groupMember;
    _accountDevice = accountDevice;
  }

  _igiek2ee.GroupMemberInclude? _groupMember;

  _iepmyrfy.AccountDeviceInclude? _accountDevice;

  @override
  Map<String, _is.Include?> get includes => {
    'groupMember': _groupMember,
    'accountDevice': _accountDevice,
  };

  @override
  _is.Table<_is.UuidValue?> get table => GroupMemberDevice.t;
}

class GroupMemberDeviceIncludeList extends _is.IncludeList {
  GroupMemberDeviceIncludeList._({
    _is.WhereExpressionBuilder<GroupMemberDeviceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GroupMemberDevice.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => GroupMemberDevice.t;
}

class GroupMemberDeviceRepository {
  const GroupMemberDeviceRepository._();

  final attachRow = const GroupMemberDeviceAttachRowRepository._();

  /// Returns a list of [GroupMemberDevice]s matching the given query parameters.
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
  Future<List<GroupMemberDevice>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupMemberDeviceTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupMemberDeviceTable>? orderBy,
    _is.OrderByListBuilder<GroupMemberDeviceTable>? orderByList,
    _is.Transaction? transaction,
    GroupMemberDeviceInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GroupMemberDevice>(
      where: where?.call(GroupMemberDevice.t),
      orderBy: orderBy?.call(GroupMemberDevice.t),
      orderByList: orderByList?.call(GroupMemberDevice.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [GroupMemberDevice] matching the given query parameters.
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
  Future<GroupMemberDevice?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupMemberDeviceTable>? where,
    int? offset,
    _is.OrderByBuilder<GroupMemberDeviceTable>? orderBy,
    _is.OrderByListBuilder<GroupMemberDeviceTable>? orderByList,
    _is.Transaction? transaction,
    GroupMemberDeviceInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GroupMemberDevice>(
      where: where?.call(GroupMemberDevice.t),
      orderBy: orderBy?.call(GroupMemberDevice.t),
      orderByList: orderByList?.call(GroupMemberDevice.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GroupMemberDevice] by its [id] or null if no such row exists.
  Future<GroupMemberDevice?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    GroupMemberDeviceInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<GroupMemberDevice>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [GroupMemberDevice]s in the list and returns the inserted rows.
  ///
  /// The returned [GroupMemberDevice]s will have their `id` fields set.
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
  Future<List<GroupMemberDevice>> insert(
    _is.DatabaseSession session,
    List<GroupMemberDevice> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<GroupMemberDevice>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [GroupMemberDevice] and returns the inserted row.
  ///
  /// The returned [GroupMemberDevice] will have its `id` field set.
  Future<GroupMemberDevice> insertRow(
    _is.DatabaseSession session,
    GroupMemberDevice row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<GroupMemberDevice>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [GroupMemberDevice]s in the list and returns the resulting rows.
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
  /// The returned [GroupMemberDevice]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupMemberDevice>> upsert(
    _is.DatabaseSession session,
    List<GroupMemberDevice> rows, {
    required _is.ColumnSelections<GroupMemberDeviceTable> conflictColumns,
    _is.ColumnSelections<GroupMemberDeviceTable>? updateColumns,
    _is.WhereExpressionBuilder<GroupMemberDeviceTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<GroupMemberDevice>(
      rows,
      conflictColumns: conflictColumns(GroupMemberDevice.t),
      updateColumns: updateColumns?.call(GroupMemberDevice.t),
      updateWhere: updateWhere?.call(GroupMemberDevice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [GroupMemberDevice] and returns the resulting row.
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
  /// The returned [GroupMemberDevice] will have its `id` field set.
  Future<GroupMemberDevice?> upsertRow(
    _is.DatabaseSession session,
    GroupMemberDevice row, {
    required _is.ColumnSelections<GroupMemberDeviceTable> conflictColumns,
    _is.ColumnSelections<GroupMemberDeviceTable>? updateColumns,
    _is.WhereExpressionBuilder<GroupMemberDeviceTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<GroupMemberDevice>(
      row,
      conflictColumns: conflictColumns(GroupMemberDevice.t),
      updateColumns: updateColumns?.call(GroupMemberDevice.t),
      updateWhere: updateWhere?.call(GroupMemberDevice.t),
      transaction: transaction,
    );
  }

  /// Updates all [GroupMemberDevice]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupMemberDevice>> update(
    _is.DatabaseSession session,
    List<GroupMemberDevice> rows, {
    _is.ColumnSelections<GroupMemberDeviceTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<GroupMemberDevice>(
      rows,
      columns: columns?.call(GroupMemberDevice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [GroupMemberDevice]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GroupMemberDevice> updateRow(
    _is.DatabaseSession session,
    GroupMemberDevice row, {
    _is.ColumnSelections<GroupMemberDeviceTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<GroupMemberDevice>(
      row,
      columns: columns?.call(GroupMemberDevice.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GroupMemberDevice] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<GroupMemberDevice?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<GroupMemberDeviceUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<GroupMemberDevice>(
      id,
      columnValues: columnValues(GroupMemberDevice.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GroupMemberDevice]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupMemberDevice>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<GroupMemberDeviceUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<GroupMemberDeviceTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupMemberDeviceTable>? orderBy,
    _is.OrderByListBuilder<GroupMemberDeviceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<GroupMemberDevice>(
      columnValues: columnValues(GroupMemberDevice.t.updateTable),
      where: where(GroupMemberDevice.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupMemberDevice.t),
      orderByList: orderByList?.call(GroupMemberDevice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [GroupMemberDevice]s in the list and returns the deleted rows.
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
  Future<List<GroupMemberDevice>> delete(
    _is.DatabaseSession session,
    List<GroupMemberDevice> rows, {
    _is.OrderByBuilder<GroupMemberDeviceTable>? orderBy,
    _is.OrderByListBuilder<GroupMemberDeviceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<GroupMemberDevice>(
      rows,
      orderBy: orderBy?.call(GroupMemberDevice.t),
      orderByList: orderByList?.call(GroupMemberDevice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [GroupMemberDevice].
  Future<GroupMemberDevice> deleteRow(
    _is.DatabaseSession session,
    GroupMemberDevice row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GroupMemberDevice>(
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
  Future<List<GroupMemberDevice>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GroupMemberDeviceTable> where,
    _is.OrderByBuilder<GroupMemberDeviceTable>? orderBy,
    _is.OrderByListBuilder<GroupMemberDeviceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<GroupMemberDevice>(
      where: where(GroupMemberDevice.t),
      orderBy: orderBy?.call(GroupMemberDevice.t),
      orderByList: orderByList?.call(GroupMemberDevice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupMemberDeviceTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<GroupMemberDevice>(
      where: where?.call(GroupMemberDevice.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GroupMemberDevice] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GroupMemberDeviceTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<GroupMemberDevice>(
      where: where(GroupMemberDevice.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class GroupMemberDeviceAttachRowRepository {
  const GroupMemberDeviceAttachRowRepository._();

  /// Creates a relation between the given [GroupMemberDevice] and [GroupMember]
  /// by setting the [GroupMemberDevice]'s foreign key `groupMemberId` to refer to the [GroupMember].
  Future<void> groupMember(
    _is.DatabaseSession session,
    GroupMemberDevice groupMemberDevice,
    _igiek2ee.GroupMember groupMember, {
    _is.Transaction? transaction,
  }) async {
    if (groupMemberDevice.id == null) {
      throw ArgumentError.notNull('groupMemberDevice.id');
    }
    if (groupMember.id == null) {
      throw ArgumentError.notNull('groupMember.id');
    }

    var $groupMemberDevice = groupMemberDevice.copyWith(
      groupMemberId: groupMember.id,
    );
    await session.db.updateRow<GroupMemberDevice>(
      $groupMemberDevice,
      columns: [GroupMemberDevice.t.groupMemberId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [GroupMemberDevice] and [AccountDevice]
  /// by setting the [GroupMemberDevice]'s foreign key `accountDeviceId` to refer to the [AccountDevice].
  Future<void> accountDevice(
    _is.DatabaseSession session,
    GroupMemberDevice groupMemberDevice,
    _iepmyrfy.AccountDevice accountDevice, {
    _is.Transaction? transaction,
  }) async {
    if (groupMemberDevice.id == null) {
      throw ArgumentError.notNull('groupMemberDevice.id');
    }
    if (accountDevice.id == null) {
      throw ArgumentError.notNull('accountDevice.id');
    }

    var $groupMemberDevice = groupMemberDevice.copyWith(
      accountDeviceId: accountDevice.id,
    );
    await session.db.updateRow<GroupMemberDevice>(
      $groupMemberDevice,
      columns: [GroupMemberDevice.t.accountDeviceId],
      transaction: transaction,
    );
  }
}
