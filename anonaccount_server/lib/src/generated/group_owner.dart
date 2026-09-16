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
import 'share_group.dart' as _i97quwy2;

abstract class GroupOwner
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
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
    _is.UuidValue? id,
    required _is.UuidValue shareGroupId,
    _i97quwy2.ShareGroup? shareGroup,
    required _is.UuidValue anonAccountId,
    _iulmo8pc.AnonAccount? anonAccount,
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
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      shareGroupId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['shareGroupId'],
      ),
      shareGroup: jsonSerialization['shareGroup'] == null
          ? null
          : _i1j1ale0.Protocol().deserialize<_i97quwy2.ShareGroup>(
              jsonSerialization['shareGroup'],
            ),
      anonAccountId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['anonAccountId'],
      ),
      anonAccount: jsonSerialization['anonAccount'] == null
          ? null
          : _i1j1ale0.Protocol().deserialize<_iulmo8pc.AnonAccount>(
              jsonSerialization['anonAccount'],
            ),
      encryptedUltimateKey: jsonSerialization['encryptedUltimateKey'] as String,
      addedByAttestorPublicKeyHex:
          jsonSerialization['addedByAttestorPublicKeyHex'] as String,
      addedByAttestation: jsonSerialization['addedByAttestation'] as String,
      keyEpoch: jsonSerialization['keyEpoch'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      isRevoked: jsonSerialization['isRevoked'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isRevoked']),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
      revokedByAttestorPublicKeyHex:
          jsonSerialization['revokedByAttestorPublicKeyHex'] as String?,
      revokedByAttestation:
          jsonSerialization['revokedByAttestation'] as String?,
    );
  }

  static final t = GroupOwnerTable();

  static const db = GroupOwnerRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue shareGroupId;

  _i97quwy2.ShareGroup? shareGroup;

  _is.UuidValue anonAccountId;

  _iulmo8pc.AnonAccount? anonAccount;

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
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [GroupOwner]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  GroupOwner copyWith({
    _is.UuidValue? id,
    _is.UuidValue? shareGroupId,
    _i97quwy2.ShareGroup? shareGroup,
    _is.UuidValue? anonAccountId,
    _iulmo8pc.AnonAccount? anonAccount,
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
    _i97quwy2.ShareGroupInclude? shareGroup,
    _iulmo8pc.AnonAccountInclude? anonAccount,
  }) {
    return GroupOwnerInclude._(
      shareGroup: shareGroup,
      anonAccount: anonAccount,
    );
  }

  static GroupOwnerIncludeList includeList({
    _is.WhereExpressionBuilder<GroupOwnerTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupOwnerTable>? orderBy,
    _is.OrderByListBuilder<GroupOwnerTable>? orderByList,
    GroupOwnerInclude? include,
  }) {
    return GroupOwnerIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupOwner.t),
      orderByList: orderByList?.call(GroupOwner.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupOwnerImpl extends GroupOwner {
  _GroupOwnerImpl({
    _is.UuidValue? id,
    required _is.UuidValue shareGroupId,
    _i97quwy2.ShareGroup? shareGroup,
    required _is.UuidValue anonAccountId,
    _iulmo8pc.AnonAccount? anonAccount,
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
  @_is.useResult
  @override
  GroupOwner copyWith({
    Object? id = _Undefined,
    _is.UuidValue? shareGroupId,
    Object? shareGroup = _Undefined,
    _is.UuidValue? anonAccountId,
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
      id: id is _is.UuidValue? ? id : this.id,
      shareGroupId: shareGroupId ?? this.shareGroupId,
      shareGroup: shareGroup is _i97quwy2.ShareGroup?
          ? shareGroup
          : this.shareGroup?.copyWith(),
      anonAccountId: anonAccountId ?? this.anonAccountId,
      anonAccount: anonAccount is _iulmo8pc.AnonAccount?
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

class GroupOwnerUpdateTable extends _is.UpdateTable<GroupOwnerTable> {
  GroupOwnerUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> shareGroupId(
    _is.UuidValue value,
  ) => _is.ColumnValue(table.shareGroupId, value);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> anonAccountId(
    _is.UuidValue value,
  ) => _is.ColumnValue(table.anonAccountId, value);

  _is.ColumnValue<String, String> encryptedUltimateKey(String value) =>
      _is.ColumnValue(table.encryptedUltimateKey, value);

  _is.ColumnValue<String, String> addedByAttestorPublicKeyHex(String value) =>
      _is.ColumnValue(table.addedByAttestorPublicKeyHex, value);

  _is.ColumnValue<String, String> addedByAttestation(String value) =>
      _is.ColumnValue(table.addedByAttestation, value);

  _is.ColumnValue<int, int> keyEpoch(int value) =>
      _is.ColumnValue(table.keyEpoch, value);

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(table.createdAt, value);

  _is.ColumnValue<bool, bool> isRevoked(bool value) =>
      _is.ColumnValue(table.isRevoked, value);

  _is.ColumnValue<DateTime, DateTime> revokedAt(DateTime? value) =>
      _is.ColumnValue(table.revokedAt, value);

  _is.ColumnValue<String, String> revokedByAttestorPublicKeyHex(
    String? value,
  ) => _is.ColumnValue(table.revokedByAttestorPublicKeyHex, value);

  _is.ColumnValue<String, String> revokedByAttestation(String? value) =>
      _is.ColumnValue(table.revokedByAttestation, value);
}

class GroupOwnerTable extends _is.Table<_is.UuidValue?> {
  GroupOwnerTable({super.tableRelation}) : super(tableName: 'group_owner') {
    updateTable = GroupOwnerUpdateTable(this);
    shareGroupId = _is.ColumnUuid('shareGroupId', this);
    anonAccountId = _is.ColumnUuid('anonAccountId', this);
    encryptedUltimateKey = _is.ColumnString('encryptedUltimateKey', this);
    addedByAttestorPublicKeyHex = _is.ColumnString(
      'addedByAttestorPublicKeyHex',
      this,
    );
    addedByAttestation = _is.ColumnString('addedByAttestation', this);
    keyEpoch = _is.ColumnInt('keyEpoch', this, hasDefault: true);
    createdAt = _is.ColumnDateTime('createdAt', this, hasDefault: true);
    isRevoked = _is.ColumnBool('isRevoked', this, hasDefault: true);
    revokedAt = _is.ColumnDateTime('revokedAt', this);
    revokedByAttestorPublicKeyHex = _is.ColumnString(
      'revokedByAttestorPublicKeyHex',
      this,
    );
    revokedByAttestation = _is.ColumnString('revokedByAttestation', this);
  }

  late final GroupOwnerUpdateTable updateTable;

  late final _is.ColumnUuid shareGroupId;

  _i97quwy2.ShareGroupTable? _shareGroup;

  late final _is.ColumnUuid anonAccountId;

  _iulmo8pc.AnonAccountTable? _anonAccount;

  late final _is.ColumnString encryptedUltimateKey;

  late final _is.ColumnString addedByAttestorPublicKeyHex;

  late final _is.ColumnString addedByAttestation;

  late final _is.ColumnInt keyEpoch;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnBool isRevoked;

  late final _is.ColumnDateTime revokedAt;

  late final _is.ColumnString revokedByAttestorPublicKeyHex;

  late final _is.ColumnString revokedByAttestation;

  _i97quwy2.ShareGroupTable get shareGroup {
    if (_shareGroup != null) return _shareGroup!;
    _shareGroup = _is.createRelationTable(
      relationFieldName: 'shareGroup',
      field: GroupOwner.t.shareGroupId,
      foreignField: _i97quwy2.ShareGroup.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i97quwy2.ShareGroupTable(tableRelation: foreignTableRelation),
    );
    return _shareGroup!;
  }

  _iulmo8pc.AnonAccountTable get anonAccount {
    if (_anonAccount != null) return _anonAccount!;
    _anonAccount = _is.createRelationTable(
      relationFieldName: 'anonAccount',
      field: GroupOwner.t.anonAccountId,
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
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'shareGroup') {
      return shareGroup;
    }
    if (relationField == 'anonAccount') {
      return anonAccount;
    }
    return null;
  }
}

class GroupOwnerInclude extends _is.IncludeObject {
  GroupOwnerInclude._({
    _i97quwy2.ShareGroupInclude? shareGroup,
    _iulmo8pc.AnonAccountInclude? anonAccount,
  }) {
    _shareGroup = shareGroup;
    _anonAccount = anonAccount;
  }

  _i97quwy2.ShareGroupInclude? _shareGroup;

  _iulmo8pc.AnonAccountInclude? _anonAccount;

  @override
  Map<String, _is.Include?> get includes => {
    'shareGroup': _shareGroup,
    'anonAccount': _anonAccount,
  };

  @override
  _is.Table<_is.UuidValue?> get table => GroupOwner.t;
}

class GroupOwnerIncludeList extends _is.IncludeList {
  GroupOwnerIncludeList._({
    _is.WhereExpressionBuilder<GroupOwnerTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GroupOwner.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => GroupOwner.t;
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupOwnerTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupOwnerTable>? orderBy,
    _is.OrderByListBuilder<GroupOwnerTable>? orderByList,
    _is.Transaction? transaction,
    GroupOwnerInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GroupOwner>(
      where: where?.call(GroupOwner.t),
      orderBy: orderBy?.call(GroupOwner.t),
      orderByList: orderByList?.call(GroupOwner.t),
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupOwnerTable>? where,
    int? offset,
    _is.OrderByBuilder<GroupOwnerTable>? orderBy,
    _is.OrderByListBuilder<GroupOwnerTable>? orderByList,
    _is.Transaction? transaction,
    GroupOwnerInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GroupOwner>(
      where: where?.call(GroupOwner.t),
      orderBy: orderBy?.call(GroupOwner.t),
      orderByList: orderByList?.call(GroupOwner.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GroupOwner] by its [id] or null if no such row exists.
  Future<GroupOwner?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    GroupOwnerInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupOwner>> insert(
    _is.DatabaseSession session,
    List<GroupOwner> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<GroupOwner>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [GroupOwner] and returns the inserted row.
  ///
  /// The returned [GroupOwner] will have its `id` field set.
  Future<GroupOwner> insertRow(
    _is.DatabaseSession session,
    GroupOwner row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<GroupOwner>(row, transaction: transaction);
  }

  /// Upserts all [GroupOwner]s in the list and returns the resulting rows.
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
  /// The returned [GroupOwner]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupOwner>> upsert(
    _is.DatabaseSession session,
    List<GroupOwner> rows, {
    required _is.ColumnSelections<GroupOwnerTable> conflictColumns,
    _is.ColumnSelections<GroupOwnerTable>? updateColumns,
    _is.WhereExpressionBuilder<GroupOwnerTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<GroupOwner>(
      rows,
      conflictColumns: conflictColumns(GroupOwner.t),
      updateColumns: updateColumns?.call(GroupOwner.t),
      updateWhere: updateWhere?.call(GroupOwner.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [GroupOwner] and returns the resulting row.
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
  /// The returned [GroupOwner] will have its `id` field set.
  Future<GroupOwner?> upsertRow(
    _is.DatabaseSession session,
    GroupOwner row, {
    required _is.ColumnSelections<GroupOwnerTable> conflictColumns,
    _is.ColumnSelections<GroupOwnerTable>? updateColumns,
    _is.WhereExpressionBuilder<GroupOwnerTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<GroupOwner>(
      row,
      conflictColumns: conflictColumns(GroupOwner.t),
      updateColumns: updateColumns?.call(GroupOwner.t),
      updateWhere: updateWhere?.call(GroupOwner.t),
      transaction: transaction,
    );
  }

  /// Updates all [GroupOwner]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupOwner>> update(
    _is.DatabaseSession session,
    List<GroupOwner> rows, {
    _is.ColumnSelections<GroupOwnerTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<GroupOwner>(
      rows,
      columns: columns?.call(GroupOwner.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [GroupOwner]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GroupOwner> updateRow(
    _is.DatabaseSession session,
    GroupOwner row, {
    _is.ColumnSelections<GroupOwnerTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<GroupOwnerUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<GroupOwner>(
      id,
      columnValues: columnValues(GroupOwner.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GroupOwner]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupOwner>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<GroupOwnerUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<GroupOwnerTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupOwnerTable>? orderBy,
    _is.OrderByListBuilder<GroupOwnerTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<GroupOwner>(
      columnValues: columnValues(GroupOwner.t.updateTable),
      where: where(GroupOwner.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupOwner.t),
      orderByList: orderByList?.call(GroupOwner.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [GroupOwner]s in the list and returns the deleted rows.
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
  Future<List<GroupOwner>> delete(
    _is.DatabaseSession session,
    List<GroupOwner> rows, {
    _is.OrderByBuilder<GroupOwnerTable>? orderBy,
    _is.OrderByListBuilder<GroupOwnerTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<GroupOwner>(
      rows,
      orderBy: orderBy?.call(GroupOwner.t),
      orderByList: orderByList?.call(GroupOwner.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [GroupOwner].
  Future<GroupOwner> deleteRow(
    _is.DatabaseSession session,
    GroupOwner row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GroupOwner>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupOwner>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GroupOwnerTable> where,
    _is.OrderByBuilder<GroupOwnerTable>? orderBy,
    _is.OrderByListBuilder<GroupOwnerTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<GroupOwner>(
      where: where(GroupOwner.t),
      orderBy: orderBy?.call(GroupOwner.t),
      orderByList: orderByList?.call(GroupOwner.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupOwnerTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<GroupOwner>(
      where: where?.call(GroupOwner.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GroupOwner] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GroupOwnerTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
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
    _is.DatabaseSession session,
    GroupOwner groupOwner,
    _i97quwy2.ShareGroup shareGroup, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    GroupOwner groupOwner,
    _iulmo8pc.AnonAccount anonAccount, {
    _is.Transaction? transaction,
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
