/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'group_member.dart' as _i2;
import 'account_device.dart' as _i3;
import 'package:anonaccount_server/src/generated/protocol.dart' as _i4;

abstract class GroupMemberDevice
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
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
    _i1.UuidValue? id,
    required _i1.UuidValue groupMemberId,
    _i2.GroupMember? groupMember,
    required _i1.UuidValue accountDeviceId,
    _i3.AccountDevice? accountDevice,
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
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      groupMemberId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['groupMemberId'],
      ),
      groupMember: jsonSerialization['groupMember'] == null
          ? null
          : _i4.Protocol().deserialize<_i2.GroupMember>(
              jsonSerialization['groupMember'],
            ),
      accountDeviceId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountDeviceId'],
      ),
      accountDevice: jsonSerialization['accountDevice'] == null
          ? null
          : _i4.Protocol().deserialize<_i3.AccountDevice>(
              jsonSerialization['accountDevice'],
            ),
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      addedByAttestorPublicKeyHex:
          jsonSerialization['addedByAttestorPublicKeyHex'] as String,
      addedByAttestation: jsonSerialization['addedByAttestation'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      isRevoked: jsonSerialization['isRevoked'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isRevoked']),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
      keyEpoch: jsonSerialization['keyEpoch'] as int?,
    );
  }

  static final t = GroupMemberDeviceTable();

  static const db = GroupMemberDeviceRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue groupMemberId;

  _i2.GroupMember? groupMember;

  _i1.UuidValue accountDeviceId;

  _i3.AccountDevice? accountDevice;

  String encryptedDataKey;

  String addedByAttestorPublicKeyHex;

  String addedByAttestation;

  DateTime createdAt;

  bool isRevoked;

  DateTime? revokedAt;

  int keyEpoch;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [GroupMemberDevice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GroupMemberDevice copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? groupMemberId,
    _i2.GroupMember? groupMember,
    _i1.UuidValue? accountDeviceId,
    _i3.AccountDevice? accountDevice,
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
    _i2.GroupMemberInclude? groupMember,
    _i3.AccountDeviceInclude? accountDevice,
  }) {
    return GroupMemberDeviceInclude._(
      groupMember: groupMember,
      accountDevice: accountDevice,
    );
  }

  static GroupMemberDeviceIncludeList includeList({
    _i1.WhereExpressionBuilder<GroupMemberDeviceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GroupMemberDeviceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GroupMemberDeviceTable>? orderByList,
    GroupMemberDeviceInclude? include,
  }) {
    return GroupMemberDeviceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupMemberDevice.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(GroupMemberDevice.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupMemberDeviceImpl extends GroupMemberDevice {
  _GroupMemberDeviceImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue groupMemberId,
    _i2.GroupMember? groupMember,
    required _i1.UuidValue accountDeviceId,
    _i3.AccountDevice? accountDevice,
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
  @_i1.useResult
  @override
  GroupMemberDevice copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? groupMemberId,
    Object? groupMember = _Undefined,
    _i1.UuidValue? accountDeviceId,
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
      id: id is _i1.UuidValue? ? id : this.id,
      groupMemberId: groupMemberId ?? this.groupMemberId,
      groupMember: groupMember is _i2.GroupMember?
          ? groupMember
          : this.groupMember?.copyWith(),
      accountDeviceId: accountDeviceId ?? this.accountDeviceId,
      accountDevice: accountDevice is _i3.AccountDevice?
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
    extends _i1.UpdateTable<GroupMemberDeviceTable> {
  GroupMemberDeviceUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> groupMemberId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.groupMemberId,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> accountDeviceId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.accountDeviceId,
    value,
  );

  _i1.ColumnValue<String, String> encryptedDataKey(String value) =>
      _i1.ColumnValue(
        table.encryptedDataKey,
        value,
      );

  _i1.ColumnValue<String, String> addedByAttestorPublicKeyHex(String value) =>
      _i1.ColumnValue(
        table.addedByAttestorPublicKeyHex,
        value,
      );

  _i1.ColumnValue<String, String> addedByAttestation(String value) =>
      _i1.ColumnValue(
        table.addedByAttestation,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<bool, bool> isRevoked(bool value) => _i1.ColumnValue(
    table.isRevoked,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> revokedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.revokedAt,
        value,
      );

  _i1.ColumnValue<int, int> keyEpoch(int value) => _i1.ColumnValue(
    table.keyEpoch,
    value,
  );
}

class GroupMemberDeviceTable extends _i1.Table<_i1.UuidValue?> {
  GroupMemberDeviceTable({super.tableRelation})
    : super(tableName: 'group_member_device') {
    updateTable = GroupMemberDeviceUpdateTable(this);
    groupMemberId = _i1.ColumnUuid(
      'groupMemberId',
      this,
    );
    accountDeviceId = _i1.ColumnUuid(
      'accountDeviceId',
      this,
    );
    encryptedDataKey = _i1.ColumnString(
      'encryptedDataKey',
      this,
    );
    addedByAttestorPublicKeyHex = _i1.ColumnString(
      'addedByAttestorPublicKeyHex',
      this,
    );
    addedByAttestation = _i1.ColumnString(
      'addedByAttestation',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    isRevoked = _i1.ColumnBool(
      'isRevoked',
      this,
      hasDefault: true,
    );
    revokedAt = _i1.ColumnDateTime(
      'revokedAt',
      this,
    );
    keyEpoch = _i1.ColumnInt(
      'keyEpoch',
      this,
      hasDefault: true,
    );
  }

  late final GroupMemberDeviceUpdateTable updateTable;

  late final _i1.ColumnUuid groupMemberId;

  _i2.GroupMemberTable? _groupMember;

  late final _i1.ColumnUuid accountDeviceId;

  _i3.AccountDeviceTable? _accountDevice;

  late final _i1.ColumnString encryptedDataKey;

  late final _i1.ColumnString addedByAttestorPublicKeyHex;

  late final _i1.ColumnString addedByAttestation;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnBool isRevoked;

  late final _i1.ColumnDateTime revokedAt;

  late final _i1.ColumnInt keyEpoch;

  _i2.GroupMemberTable get groupMember {
    if (_groupMember != null) return _groupMember!;
    _groupMember = _i1.createRelationTable(
      relationFieldName: 'groupMember',
      field: GroupMemberDevice.t.groupMemberId,
      foreignField: _i2.GroupMember.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.GroupMemberTable(tableRelation: foreignTableRelation),
    );
    return _groupMember!;
  }

  _i3.AccountDeviceTable get accountDevice {
    if (_accountDevice != null) return _accountDevice!;
    _accountDevice = _i1.createRelationTable(
      relationFieldName: 'accountDevice',
      field: GroupMemberDevice.t.accountDeviceId,
      foreignField: _i3.AccountDevice.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i3.AccountDeviceTable(tableRelation: foreignTableRelation),
    );
    return _accountDevice!;
  }

  @override
  List<_i1.Column> get columns => [
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
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'groupMember') {
      return groupMember;
    }
    if (relationField == 'accountDevice') {
      return accountDevice;
    }
    return null;
  }
}

class GroupMemberDeviceInclude extends _i1.IncludeObject {
  GroupMemberDeviceInclude._({
    _i2.GroupMemberInclude? groupMember,
    _i3.AccountDeviceInclude? accountDevice,
  }) {
    _groupMember = groupMember;
    _accountDevice = accountDevice;
  }

  _i2.GroupMemberInclude? _groupMember;

  _i3.AccountDeviceInclude? _accountDevice;

  @override
  Map<String, _i1.Include?> get includes => {
    'groupMember': _groupMember,
    'accountDevice': _accountDevice,
  };

  @override
  _i1.Table<_i1.UuidValue?> get table => GroupMemberDevice.t;
}

class GroupMemberDeviceIncludeList extends _i1.IncludeList {
  GroupMemberDeviceIncludeList._({
    _i1.WhereExpressionBuilder<GroupMemberDeviceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GroupMemberDevice.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => GroupMemberDevice.t;
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GroupMemberDeviceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GroupMemberDeviceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GroupMemberDeviceTable>? orderByList,
    _i1.Transaction? transaction,
    GroupMemberDeviceInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GroupMemberDevice>(
      where: where?.call(GroupMemberDevice.t),
      orderBy: orderBy?.call(GroupMemberDevice.t),
      orderByList: orderByList?.call(GroupMemberDevice.t),
      orderDescending: orderDescending,
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GroupMemberDeviceTable>? where,
    int? offset,
    _i1.OrderByBuilder<GroupMemberDeviceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GroupMemberDeviceTable>? orderByList,
    _i1.Transaction? transaction,
    GroupMemberDeviceInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GroupMemberDevice>(
      where: where?.call(GroupMemberDevice.t),
      orderBy: orderBy?.call(GroupMemberDevice.t),
      orderByList: orderByList?.call(GroupMemberDevice.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GroupMemberDevice] by its [id] or null if no such row exists.
  Future<GroupMemberDevice?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    GroupMemberDeviceInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
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
  Future<List<GroupMemberDevice>> insert(
    _i1.Session session,
    List<GroupMemberDevice> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<GroupMemberDevice>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [GroupMemberDevice] and returns the inserted row.
  ///
  /// The returned [GroupMemberDevice] will have its `id` field set.
  Future<GroupMemberDevice> insertRow(
    _i1.Session session,
    GroupMemberDevice row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<GroupMemberDevice>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [GroupMemberDevice]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<GroupMemberDevice>> update(
    _i1.Session session,
    List<GroupMemberDevice> rows, {
    _i1.ColumnSelections<GroupMemberDeviceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<GroupMemberDevice>(
      rows,
      columns: columns?.call(GroupMemberDevice.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GroupMemberDevice]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GroupMemberDevice> updateRow(
    _i1.Session session,
    GroupMemberDevice row, {
    _i1.ColumnSelections<GroupMemberDeviceTable>? columns,
    _i1.Transaction? transaction,
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
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<GroupMemberDeviceUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<GroupMemberDevice>(
      id,
      columnValues: columnValues(GroupMemberDevice.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GroupMemberDevice]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<GroupMemberDevice>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<GroupMemberDeviceUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<GroupMemberDeviceTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GroupMemberDeviceTable>? orderBy,
    _i1.OrderByListBuilder<GroupMemberDeviceTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<GroupMemberDevice>(
      columnValues: columnValues(GroupMemberDevice.t.updateTable),
      where: where(GroupMemberDevice.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupMemberDevice.t),
      orderByList: orderByList?.call(GroupMemberDevice.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [GroupMemberDevice]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<GroupMemberDevice>> delete(
    _i1.Session session,
    List<GroupMemberDevice> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<GroupMemberDevice>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [GroupMemberDevice].
  Future<GroupMemberDevice> deleteRow(
    _i1.Session session,
    GroupMemberDevice row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GroupMemberDevice>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<GroupMemberDevice>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<GroupMemberDeviceTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<GroupMemberDevice>(
      where: where(GroupMemberDevice.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GroupMemberDeviceTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<GroupMemberDevice>(
      where: where?.call(GroupMemberDevice.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GroupMemberDevice] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<GroupMemberDeviceTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
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
    _i1.Session session,
    GroupMemberDevice groupMemberDevice,
    _i2.GroupMember groupMember, {
    _i1.Transaction? transaction,
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
    _i1.Session session,
    GroupMemberDevice groupMemberDevice,
    _i3.AccountDevice accountDevice, {
    _i1.Transaction? transaction,
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
