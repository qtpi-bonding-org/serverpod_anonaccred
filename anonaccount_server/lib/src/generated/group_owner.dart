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
import 'share_group.dart' as _i2;
import 'account.dart' as _i3;
import 'package:anonaccount_server/src/generated/protocol.dart' as _i4;

abstract class GroupOwner
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  GroupOwner._({
    this.id,
    required this.shareGroupId,
    this.shareGroup,
    required this.anonAccountId,
    this.anonAccount,
    required this.encryptedUltimateKey,
    required this.addedByAttestorPublicKeyHex,
    required this.addedByAttestation,
    int? keyEpoch,
    DateTime? createdAt,
    bool? isRevoked,
    this.revokedAt,
    this.revokedByAttestorPublicKeyHex,
    this.revokedByAttestation,
  }) : keyEpoch = keyEpoch ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       isRevoked = isRevoked ?? false;

  factory GroupOwner({
    _i1.UuidValue? id,
    required _i1.UuidValue shareGroupId,
    _i2.ShareGroup? shareGroup,
    required _i1.UuidValue anonAccountId,
    _i3.AnonAccount? anonAccount,
    required String encryptedUltimateKey,
    required String addedByAttestorPublicKeyHex,
    required String addedByAttestation,
    int? keyEpoch,
    DateTime? createdAt,
    bool? isRevoked,
    DateTime? revokedAt,
    String? revokedByAttestorPublicKeyHex,
    String? revokedByAttestation,
  }) = _GroupOwnerImpl;

  factory GroupOwner.fromJson(Map<String, dynamic> jsonSerialization) {
    return GroupOwner(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      shareGroupId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['shareGroupId'],
      ),
      shareGroup: jsonSerialization['shareGroup'] == null
          ? null
          : _i4.Protocol().deserialize<_i2.ShareGroup>(
              jsonSerialization['shareGroup'],
            ),
      anonAccountId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['anonAccountId'],
      ),
      anonAccount: jsonSerialization['anonAccount'] == null
          ? null
          : _i4.Protocol().deserialize<_i3.AnonAccount>(
              jsonSerialization['anonAccount'],
            ),
      encryptedUltimateKey: jsonSerialization['encryptedUltimateKey'] as String,
      addedByAttestorPublicKeyHex:
          jsonSerialization['addedByAttestorPublicKeyHex'] as String,
      addedByAttestation: jsonSerialization['addedByAttestation'] as String,
      keyEpoch: jsonSerialization['keyEpoch'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      isRevoked: jsonSerialization['isRevoked'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isRevoked']),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
      revokedByAttestorPublicKeyHex:
          jsonSerialization['revokedByAttestorPublicKeyHex'] as String?,
      revokedByAttestation:
          jsonSerialization['revokedByAttestation'] as String?,
    );
  }

  static final t = GroupOwnerTable();

  static const db = GroupOwnerRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue shareGroupId;

  _i2.ShareGroup? shareGroup;

  _i1.UuidValue anonAccountId;

  _i3.AnonAccount? anonAccount;

  String encryptedUltimateKey;

  String addedByAttestorPublicKeyHex;

  String addedByAttestation;

  int keyEpoch;

  DateTime createdAt;

  bool isRevoked;

  DateTime? revokedAt;

  String? revokedByAttestorPublicKeyHex;

  String? revokedByAttestation;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [GroupOwner]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GroupOwner copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? shareGroupId,
    _i2.ShareGroup? shareGroup,
    _i1.UuidValue? anonAccountId,
    _i3.AnonAccount? anonAccount,
    String? encryptedUltimateKey,
    String? addedByAttestorPublicKeyHex,
    String? addedByAttestation,
    int? keyEpoch,
    DateTime? createdAt,
    bool? isRevoked,
    DateTime? revokedAt,
    String? revokedByAttestorPublicKeyHex,
    String? revokedByAttestation,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.GroupOwner',
      if (id != null) 'id': id?.toJson(),
      'shareGroupId': shareGroupId.toJson(),
      if (shareGroup != null) 'shareGroup': shareGroup?.toJson(),
      'anonAccountId': anonAccountId.toJson(),
      if (anonAccount != null) 'anonAccount': anonAccount?.toJson(),
      'encryptedUltimateKey': encryptedUltimateKey,
      'addedByAttestorPublicKeyHex': addedByAttestorPublicKeyHex,
      'addedByAttestation': addedByAttestation,
      'keyEpoch': keyEpoch,
      'createdAt': createdAt.toJson(),
      'isRevoked': isRevoked,
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      if (revokedByAttestorPublicKeyHex != null)
        'revokedByAttestorPublicKeyHex': revokedByAttestorPublicKeyHex,
      if (revokedByAttestation != null)
        'revokedByAttestation': revokedByAttestation,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.GroupOwner',
      if (id != null) 'id': id?.toJson(),
      'shareGroupId': shareGroupId.toJson(),
      if (shareGroup != null) 'shareGroup': shareGroup?.toJsonForProtocol(),
      'anonAccountId': anonAccountId.toJson(),
      if (anonAccount != null) 'anonAccount': anonAccount?.toJsonForProtocol(),
      'encryptedUltimateKey': encryptedUltimateKey,
      'addedByAttestorPublicKeyHex': addedByAttestorPublicKeyHex,
      'addedByAttestation': addedByAttestation,
      'keyEpoch': keyEpoch,
      'createdAt': createdAt.toJson(),
      'isRevoked': isRevoked,
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      if (revokedByAttestorPublicKeyHex != null)
        'revokedByAttestorPublicKeyHex': revokedByAttestorPublicKeyHex,
      if (revokedByAttestation != null)
        'revokedByAttestation': revokedByAttestation,
    };
  }

  static GroupOwnerInclude include({
    _i2.ShareGroupInclude? shareGroup,
    _i3.AnonAccountInclude? anonAccount,
  }) {
    return GroupOwnerInclude._(
      shareGroup: shareGroup,
      anonAccount: anonAccount,
    );
  }

  static GroupOwnerIncludeList includeList({
    _i1.WhereExpressionBuilder<GroupOwnerTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GroupOwnerTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GroupOwnerTable>? orderByList,
    GroupOwnerInclude? include,
  }) {
    return GroupOwnerIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupOwner.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(GroupOwner.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupOwnerImpl extends GroupOwner {
  _GroupOwnerImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue shareGroupId,
    _i2.ShareGroup? shareGroup,
    required _i1.UuidValue anonAccountId,
    _i3.AnonAccount? anonAccount,
    required String encryptedUltimateKey,
    required String addedByAttestorPublicKeyHex,
    required String addedByAttestation,
    int? keyEpoch,
    DateTime? createdAt,
    bool? isRevoked,
    DateTime? revokedAt,
    String? revokedByAttestorPublicKeyHex,
    String? revokedByAttestation,
  }) : super._(
         id: id,
         shareGroupId: shareGroupId,
         shareGroup: shareGroup,
         anonAccountId: anonAccountId,
         anonAccount: anonAccount,
         encryptedUltimateKey: encryptedUltimateKey,
         addedByAttestorPublicKeyHex: addedByAttestorPublicKeyHex,
         addedByAttestation: addedByAttestation,
         keyEpoch: keyEpoch,
         createdAt: createdAt,
         isRevoked: isRevoked,
         revokedAt: revokedAt,
         revokedByAttestorPublicKeyHex: revokedByAttestorPublicKeyHex,
         revokedByAttestation: revokedByAttestation,
       );

  /// Returns a shallow copy of this [GroupOwner]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GroupOwner copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? shareGroupId,
    Object? shareGroup = _Undefined,
    _i1.UuidValue? anonAccountId,
    Object? anonAccount = _Undefined,
    String? encryptedUltimateKey,
    String? addedByAttestorPublicKeyHex,
    String? addedByAttestation,
    int? keyEpoch,
    DateTime? createdAt,
    bool? isRevoked,
    Object? revokedAt = _Undefined,
    Object? revokedByAttestorPublicKeyHex = _Undefined,
    Object? revokedByAttestation = _Undefined,
  }) {
    return GroupOwner(
      id: id is _i1.UuidValue? ? id : this.id,
      shareGroupId: shareGroupId ?? this.shareGroupId,
      shareGroup: shareGroup is _i2.ShareGroup?
          ? shareGroup
          : this.shareGroup?.copyWith(),
      anonAccountId: anonAccountId ?? this.anonAccountId,
      anonAccount: anonAccount is _i3.AnonAccount?
          ? anonAccount
          : this.anonAccount?.copyWith(),
      encryptedUltimateKey: encryptedUltimateKey ?? this.encryptedUltimateKey,
      addedByAttestorPublicKeyHex:
          addedByAttestorPublicKeyHex ?? this.addedByAttestorPublicKeyHex,
      addedByAttestation: addedByAttestation ?? this.addedByAttestation,
      keyEpoch: keyEpoch ?? this.keyEpoch,
      createdAt: createdAt ?? this.createdAt,
      isRevoked: isRevoked ?? this.isRevoked,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
      revokedByAttestorPublicKeyHex: revokedByAttestorPublicKeyHex is String?
          ? revokedByAttestorPublicKeyHex
          : this.revokedByAttestorPublicKeyHex,
      revokedByAttestation: revokedByAttestation is String?
          ? revokedByAttestation
          : this.revokedByAttestation,
    );
  }
}

class GroupOwnerUpdateTable extends _i1.UpdateTable<GroupOwnerTable> {
  GroupOwnerUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> shareGroupId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.shareGroupId,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> anonAccountId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.anonAccountId,
    value,
  );

  _i1.ColumnValue<String, String> encryptedUltimateKey(String value) =>
      _i1.ColumnValue(
        table.encryptedUltimateKey,
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

  _i1.ColumnValue<int, int> keyEpoch(int value) => _i1.ColumnValue(
    table.keyEpoch,
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

  _i1.ColumnValue<String, String> revokedByAttestorPublicKeyHex(
    String? value,
  ) => _i1.ColumnValue(
    table.revokedByAttestorPublicKeyHex,
    value,
  );

  _i1.ColumnValue<String, String> revokedByAttestation(String? value) =>
      _i1.ColumnValue(
        table.revokedByAttestation,
        value,
      );
}

class GroupOwnerTable extends _i1.Table<_i1.UuidValue?> {
  GroupOwnerTable({super.tableRelation}) : super(tableName: 'group_owner') {
    updateTable = GroupOwnerUpdateTable(this);
    shareGroupId = _i1.ColumnUuid(
      'shareGroupId',
      this,
    );
    anonAccountId = _i1.ColumnUuid(
      'anonAccountId',
      this,
    );
    encryptedUltimateKey = _i1.ColumnString(
      'encryptedUltimateKey',
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
    keyEpoch = _i1.ColumnInt(
      'keyEpoch',
      this,
      hasDefault: true,
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
    revokedByAttestorPublicKeyHex = _i1.ColumnString(
      'revokedByAttestorPublicKeyHex',
      this,
    );
    revokedByAttestation = _i1.ColumnString(
      'revokedByAttestation',
      this,
    );
  }

  late final GroupOwnerUpdateTable updateTable;

  late final _i1.ColumnUuid shareGroupId;

  _i2.ShareGroupTable? _shareGroup;

  late final _i1.ColumnUuid anonAccountId;

  _i3.AnonAccountTable? _anonAccount;

  late final _i1.ColumnString encryptedUltimateKey;

  late final _i1.ColumnString addedByAttestorPublicKeyHex;

  late final _i1.ColumnString addedByAttestation;

  late final _i1.ColumnInt keyEpoch;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnBool isRevoked;

  late final _i1.ColumnDateTime revokedAt;

  late final _i1.ColumnString revokedByAttestorPublicKeyHex;

  late final _i1.ColumnString revokedByAttestation;

  _i2.ShareGroupTable get shareGroup {
    if (_shareGroup != null) return _shareGroup!;
    _shareGroup = _i1.createRelationTable(
      relationFieldName: 'shareGroup',
      field: GroupOwner.t.shareGroupId,
      foreignField: _i2.ShareGroup.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.ShareGroupTable(tableRelation: foreignTableRelation),
    );
    return _shareGroup!;
  }

  _i3.AnonAccountTable get anonAccount {
    if (_anonAccount != null) return _anonAccount!;
    _anonAccount = _i1.createRelationTable(
      relationFieldName: 'anonAccount',
      field: GroupOwner.t.anonAccountId,
      foreignField: _i3.AnonAccount.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i3.AnonAccountTable(tableRelation: foreignTableRelation),
    );
    return _anonAccount!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    shareGroupId,
    anonAccountId,
    encryptedUltimateKey,
    addedByAttestorPublicKeyHex,
    addedByAttestation,
    keyEpoch,
    createdAt,
    isRevoked,
    revokedAt,
    revokedByAttestorPublicKeyHex,
    revokedByAttestation,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'shareGroup') {
      return shareGroup;
    }
    if (relationField == 'anonAccount') {
      return anonAccount;
    }
    return null;
  }
}

class GroupOwnerInclude extends _i1.IncludeObject {
  GroupOwnerInclude._({
    _i2.ShareGroupInclude? shareGroup,
    _i3.AnonAccountInclude? anonAccount,
  }) {
    _shareGroup = shareGroup;
    _anonAccount = anonAccount;
  }

  _i2.ShareGroupInclude? _shareGroup;

  _i3.AnonAccountInclude? _anonAccount;

  @override
  Map<String, _i1.Include?> get includes => {
    'shareGroup': _shareGroup,
    'anonAccount': _anonAccount,
  };

  @override
  _i1.Table<_i1.UuidValue?> get table => GroupOwner.t;
}

class GroupOwnerIncludeList extends _i1.IncludeList {
  GroupOwnerIncludeList._({
    _i1.WhereExpressionBuilder<GroupOwnerTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GroupOwner.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => GroupOwner.t;
}

class GroupOwnerRepository {
  const GroupOwnerRepository._();

  final attachRow = const GroupOwnerAttachRowRepository._();

  /// Returns a list of [GroupOwner]s matching the given query parameters.
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
  Future<List<GroupOwner>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GroupOwnerTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GroupOwnerTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GroupOwnerTable>? orderByList,
    _i1.Transaction? transaction,
    GroupOwnerInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GroupOwner>(
      where: where?.call(GroupOwner.t),
      orderBy: orderBy?.call(GroupOwner.t),
      orderByList: orderByList?.call(GroupOwner.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [GroupOwner] matching the given query parameters.
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
  Future<GroupOwner?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GroupOwnerTable>? where,
    int? offset,
    _i1.OrderByBuilder<GroupOwnerTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GroupOwnerTable>? orderByList,
    _i1.Transaction? transaction,
    GroupOwnerInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GroupOwner>(
      where: where?.call(GroupOwner.t),
      orderBy: orderBy?.call(GroupOwner.t),
      orderByList: orderByList?.call(GroupOwner.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GroupOwner] by its [id] or null if no such row exists.
  Future<GroupOwner?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    GroupOwnerInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<GroupOwner>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [GroupOwner]s in the list and returns the inserted rows.
  ///
  /// The returned [GroupOwner]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<GroupOwner>> insert(
    _i1.Session session,
    List<GroupOwner> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<GroupOwner>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [GroupOwner] and returns the inserted row.
  ///
  /// The returned [GroupOwner] will have its `id` field set.
  Future<GroupOwner> insertRow(
    _i1.Session session,
    GroupOwner row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<GroupOwner>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [GroupOwner]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<GroupOwner>> update(
    _i1.Session session,
    List<GroupOwner> rows, {
    _i1.ColumnSelections<GroupOwnerTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<GroupOwner>(
      rows,
      columns: columns?.call(GroupOwner.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GroupOwner]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GroupOwner> updateRow(
    _i1.Session session,
    GroupOwner row, {
    _i1.ColumnSelections<GroupOwnerTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<GroupOwner>(
      row,
      columns: columns?.call(GroupOwner.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GroupOwner] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<GroupOwner?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<GroupOwnerUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<GroupOwner>(
      id,
      columnValues: columnValues(GroupOwner.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GroupOwner]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<GroupOwner>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<GroupOwnerUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<GroupOwnerTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GroupOwnerTable>? orderBy,
    _i1.OrderByListBuilder<GroupOwnerTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<GroupOwner>(
      columnValues: columnValues(GroupOwner.t.updateTable),
      where: where(GroupOwner.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupOwner.t),
      orderByList: orderByList?.call(GroupOwner.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [GroupOwner]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<GroupOwner>> delete(
    _i1.Session session,
    List<GroupOwner> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<GroupOwner>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [GroupOwner].
  Future<GroupOwner> deleteRow(
    _i1.Session session,
    GroupOwner row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GroupOwner>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<GroupOwner>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<GroupOwnerTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<GroupOwner>(
      where: where(GroupOwner.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GroupOwnerTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<GroupOwner>(
      where: where?.call(GroupOwner.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GroupOwner] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<GroupOwnerTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<GroupOwner>(
      where: where(GroupOwner.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class GroupOwnerAttachRowRepository {
  const GroupOwnerAttachRowRepository._();

  /// Creates a relation between the given [GroupOwner] and [ShareGroup]
  /// by setting the [GroupOwner]'s foreign key `shareGroupId` to refer to the [ShareGroup].
  Future<void> shareGroup(
    _i1.Session session,
    GroupOwner groupOwner,
    _i2.ShareGroup shareGroup, {
    _i1.Transaction? transaction,
  }) async {
    if (groupOwner.id == null) {
      throw ArgumentError.notNull('groupOwner.id');
    }
    if (shareGroup.id == null) {
      throw ArgumentError.notNull('shareGroup.id');
    }

    var $groupOwner = groupOwner.copyWith(shareGroupId: shareGroup.id);
    await session.db.updateRow<GroupOwner>(
      $groupOwner,
      columns: [GroupOwner.t.shareGroupId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [GroupOwner] and [AnonAccount]
  /// by setting the [GroupOwner]'s foreign key `anonAccountId` to refer to the [AnonAccount].
  Future<void> anonAccount(
    _i1.Session session,
    GroupOwner groupOwner,
    _i3.AnonAccount anonAccount, {
    _i1.Transaction? transaction,
  }) async {
    if (groupOwner.id == null) {
      throw ArgumentError.notNull('groupOwner.id');
    }
    if (anonAccount.id == null) {
      throw ArgumentError.notNull('anonAccount.id');
    }

    var $groupOwner = groupOwner.copyWith(anonAccountId: anonAccount.id);
    await session.db.updateRow<GroupOwner>(
      $groupOwner,
      columns: [GroupOwner.t.anonAccountId],
      transaction: transaction,
    );
  }
}
