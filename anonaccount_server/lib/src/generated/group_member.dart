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
import 'group_member_role.dart' as _imgpb098;
import 'share_group.dart' as _i97quwy2;

abstract class GroupMember
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  GroupMember._({
    this.id,
    required this.shareGroupId,
    this.shareGroup,
    required this.anonAccountId,
    this.anonAccount,
    required this.role,
    required this.memberSigningPublicKeyHex,
    required this.memberEncryptionPublicKeyHex,
    required this.encryptedDataKey,
    required this.encryptedMemberKey,
    DateTime? joinedAt,
    bool? isRevoked,
    required this.addedByAttestorPublicKeyHex,
    required this.addedByAttestation,
    this.revokedByAttestorPublicKeyHex,
    this.revokedByAttestation,
    this.revokedAt,
    int? keyEpoch,
    this.roleChangedAt,
    this.roleChangedByAttestorPublicKeyHex,
    this.roleChangedByAttestation,
  }) : joinedAt = joinedAt ?? DateTime.now(),
       isRevoked = isRevoked ?? false,
       keyEpoch = keyEpoch ?? 0;

  factory GroupMember({
    _is.UuidValue? id,
    required _is.UuidValue shareGroupId,
    _i97quwy2.ShareGroup? shareGroup,
    required _is.UuidValue anonAccountId,
    _iulmo8pc.AnonAccount? anonAccount,
    required _imgpb098.GroupMemberRole role,
    required String memberSigningPublicKeyHex,
    required String memberEncryptionPublicKeyHex,
    required String encryptedDataKey,
    required String encryptedMemberKey,
    DateTime? joinedAt,
    bool? isRevoked,
    required String addedByAttestorPublicKeyHex,
    required String addedByAttestation,
    String? revokedByAttestorPublicKeyHex,
    String? revokedByAttestation,
    DateTime? revokedAt,
    int? keyEpoch,
    DateTime? roleChangedAt,
    String? roleChangedByAttestorPublicKeyHex,
    String? roleChangedByAttestation,
  }) = _GroupMemberImpl;

  factory GroupMember.fromJson(Map<String, dynamic> jsonSerialization) {
    return GroupMember(
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
      role: _imgpb098.GroupMemberRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      memberSigningPublicKeyHex:
          jsonSerialization['memberSigningPublicKeyHex'] as String,
      memberEncryptionPublicKeyHex:
          jsonSerialization['memberEncryptionPublicKeyHex'] as String,
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      encryptedMemberKey: jsonSerialization['encryptedMemberKey'] as String,
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
      isRevoked: jsonSerialization['isRevoked'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isRevoked']),
      addedByAttestorPublicKeyHex:
          jsonSerialization['addedByAttestorPublicKeyHex'] as String,
      addedByAttestation: jsonSerialization['addedByAttestation'] as String,
      revokedByAttestorPublicKeyHex:
          jsonSerialization['revokedByAttestorPublicKeyHex'] as String?,
      revokedByAttestation:
          jsonSerialization['revokedByAttestation'] as String?,
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
      keyEpoch: jsonSerialization['keyEpoch'] as int?,
      roleChangedAt: jsonSerialization['roleChangedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['roleChangedAt'],
            ),
      roleChangedByAttestorPublicKeyHex:
          jsonSerialization['roleChangedByAttestorPublicKeyHex'] as String?,
      roleChangedByAttestation:
          jsonSerialization['roleChangedByAttestation'] as String?,
    );
  }

  static final t = GroupMemberTable();

  static const db = GroupMemberRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue shareGroupId;

  _i97quwy2.ShareGroup? shareGroup;

  _is.UuidValue anonAccountId;

  _iulmo8pc.AnonAccount? anonAccount;

  _imgpb098.GroupMemberRole role;

  String memberSigningPublicKeyHex;

  String memberEncryptionPublicKeyHex;

  String encryptedDataKey;

  String encryptedMemberKey;

  DateTime joinedAt;

  bool isRevoked;

  String addedByAttestorPublicKeyHex;

  String addedByAttestation;

  String? revokedByAttestorPublicKeyHex;

  String? revokedByAttestation;

  DateTime? revokedAt;

  int keyEpoch;

  DateTime? roleChangedAt;

  String? roleChangedByAttestorPublicKeyHex;

  String? roleChangedByAttestation;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [GroupMember]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  GroupMember copyWith({
    _is.UuidValue? id,
    _is.UuidValue? shareGroupId,
    _i97quwy2.ShareGroup? shareGroup,
    _is.UuidValue? anonAccountId,
    _iulmo8pc.AnonAccount? anonAccount,
    _imgpb098.GroupMemberRole? role,
    String? memberSigningPublicKeyHex,
    String? memberEncryptionPublicKeyHex,
    String? encryptedDataKey,
    String? encryptedMemberKey,
    DateTime? joinedAt,
    bool? isRevoked,
    String? addedByAttestorPublicKeyHex,
    String? addedByAttestation,
    String? revokedByAttestorPublicKeyHex,
    String? revokedByAttestation,
    DateTime? revokedAt,
    int? keyEpoch,
    DateTime? roleChangedAt,
    String? roleChangedByAttestorPublicKeyHex,
    String? roleChangedByAttestation,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.GroupMember',
      if (id != null) 'id': id?.toJson(),
      'shareGroupId': shareGroupId.toJson(),
      if (shareGroup != null) 'shareGroup': shareGroup?.toJson(),
      'anonAccountId': anonAccountId.toJson(),
      if (anonAccount != null) 'anonAccount': anonAccount?.toJson(),
      'role': role.toJson(),
      'memberSigningPublicKeyHex': memberSigningPublicKeyHex,
      'memberEncryptionPublicKeyHex': memberEncryptionPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'encryptedMemberKey': encryptedMemberKey,
      'joinedAt': joinedAt.toJson(),
      'isRevoked': isRevoked,
      'addedByAttestorPublicKeyHex': addedByAttestorPublicKeyHex,
      'addedByAttestation': addedByAttestation,
      if (revokedByAttestorPublicKeyHex != null)
        'revokedByAttestorPublicKeyHex': revokedByAttestorPublicKeyHex,
      if (revokedByAttestation != null)
        'revokedByAttestation': revokedByAttestation,
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      'keyEpoch': keyEpoch,
      if (roleChangedAt != null) 'roleChangedAt': roleChangedAt?.toJson(),
      if (roleChangedByAttestorPublicKeyHex != null)
        'roleChangedByAttestorPublicKeyHex': roleChangedByAttestorPublicKeyHex,
      if (roleChangedByAttestation != null)
        'roleChangedByAttestation': roleChangedByAttestation,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.GroupMember',
      if (id != null) 'id': id?.toJson(),
      'shareGroupId': shareGroupId.toJson(),
      if (shareGroup != null) 'shareGroup': shareGroup?.toJsonForProtocol(),
      'anonAccountId': anonAccountId.toJson(),
      if (anonAccount != null) 'anonAccount': anonAccount?.toJsonForProtocol(),
      'role': role.toJson(),
      'memberSigningPublicKeyHex': memberSigningPublicKeyHex,
      'memberEncryptionPublicKeyHex': memberEncryptionPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'encryptedMemberKey': encryptedMemberKey,
      'joinedAt': joinedAt.toJson(),
      'isRevoked': isRevoked,
      'addedByAttestorPublicKeyHex': addedByAttestorPublicKeyHex,
      'addedByAttestation': addedByAttestation,
      if (revokedByAttestorPublicKeyHex != null)
        'revokedByAttestorPublicKeyHex': revokedByAttestorPublicKeyHex,
      if (revokedByAttestation != null)
        'revokedByAttestation': revokedByAttestation,
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      'keyEpoch': keyEpoch,
      if (roleChangedAt != null) 'roleChangedAt': roleChangedAt?.toJson(),
      if (roleChangedByAttestorPublicKeyHex != null)
        'roleChangedByAttestorPublicKeyHex': roleChangedByAttestorPublicKeyHex,
      if (roleChangedByAttestation != null)
        'roleChangedByAttestation': roleChangedByAttestation,
    };
  }

  static GroupMemberInclude include({
    _i97quwy2.ShareGroupInclude? shareGroup,
    _iulmo8pc.AnonAccountInclude? anonAccount,
  }) {
    return GroupMemberInclude._(
      shareGroup: shareGroup,
      anonAccount: anonAccount,
    );
  }

  static GroupMemberIncludeList includeList({
    _is.WhereExpressionBuilder<GroupMemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupMemberTable>? orderBy,
    _is.OrderByListBuilder<GroupMemberTable>? orderByList,
    GroupMemberInclude? include,
  }) {
    return GroupMemberIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupMember.t),
      orderByList: orderByList?.call(GroupMember.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupMemberImpl extends GroupMember {
  _GroupMemberImpl({
    _is.UuidValue? id,
    required _is.UuidValue shareGroupId,
    _i97quwy2.ShareGroup? shareGroup,
    required _is.UuidValue anonAccountId,
    _iulmo8pc.AnonAccount? anonAccount,
    required _imgpb098.GroupMemberRole role,
    required String memberSigningPublicKeyHex,
    required String memberEncryptionPublicKeyHex,
    required String encryptedDataKey,
    required String encryptedMemberKey,
    DateTime? joinedAt,
    bool? isRevoked,
    required String addedByAttestorPublicKeyHex,
    required String addedByAttestation,
    String? revokedByAttestorPublicKeyHex,
    String? revokedByAttestation,
    DateTime? revokedAt,
    int? keyEpoch,
    DateTime? roleChangedAt,
    String? roleChangedByAttestorPublicKeyHex,
    String? roleChangedByAttestation,
  }) : super._(
         id: id,
         shareGroupId: shareGroupId,
         shareGroup: shareGroup,
         anonAccountId: anonAccountId,
         anonAccount: anonAccount,
         role: role,
         memberSigningPublicKeyHex: memberSigningPublicKeyHex,
         memberEncryptionPublicKeyHex: memberEncryptionPublicKeyHex,
         encryptedDataKey: encryptedDataKey,
         encryptedMemberKey: encryptedMemberKey,
         joinedAt: joinedAt,
         isRevoked: isRevoked,
         addedByAttestorPublicKeyHex: addedByAttestorPublicKeyHex,
         addedByAttestation: addedByAttestation,
         revokedByAttestorPublicKeyHex: revokedByAttestorPublicKeyHex,
         revokedByAttestation: revokedByAttestation,
         revokedAt: revokedAt,
         keyEpoch: keyEpoch,
         roleChangedAt: roleChangedAt,
         roleChangedByAttestorPublicKeyHex: roleChangedByAttestorPublicKeyHex,
         roleChangedByAttestation: roleChangedByAttestation,
       );

  /// Returns a shallow copy of this [GroupMember]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  GroupMember copyWith({
    Object? id = _Undefined,
    _is.UuidValue? shareGroupId,
    Object? shareGroup = _Undefined,
    _is.UuidValue? anonAccountId,
    Object? anonAccount = _Undefined,
    _imgpb098.GroupMemberRole? role,
    String? memberSigningPublicKeyHex,
    String? memberEncryptionPublicKeyHex,
    String? encryptedDataKey,
    String? encryptedMemberKey,
    DateTime? joinedAt,
    bool? isRevoked,
    String? addedByAttestorPublicKeyHex,
    String? addedByAttestation,
    Object? revokedByAttestorPublicKeyHex = _Undefined,
    Object? revokedByAttestation = _Undefined,
    Object? revokedAt = _Undefined,
    int? keyEpoch,
    Object? roleChangedAt = _Undefined,
    Object? roleChangedByAttestorPublicKeyHex = _Undefined,
    Object? roleChangedByAttestation = _Undefined,
  }) {
    return GroupMember(
      id: id is _is.UuidValue? ? id : this.id,
      shareGroupId: shareGroupId ?? this.shareGroupId,
      shareGroup: shareGroup is _i97quwy2.ShareGroup?
          ? shareGroup
          : this.shareGroup?.copyWith(),
      anonAccountId: anonAccountId ?? this.anonAccountId,
      anonAccount: anonAccount is _iulmo8pc.AnonAccount?
          ? anonAccount
          : this.anonAccount?.copyWith(),
      role: role ?? this.role,
      memberSigningPublicKeyHex:
          memberSigningPublicKeyHex ?? this.memberSigningPublicKeyHex,
      memberEncryptionPublicKeyHex:
          memberEncryptionPublicKeyHex ?? this.memberEncryptionPublicKeyHex,
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      encryptedMemberKey: encryptedMemberKey ?? this.encryptedMemberKey,
      joinedAt: joinedAt ?? this.joinedAt,
      isRevoked: isRevoked ?? this.isRevoked,
      addedByAttestorPublicKeyHex:
          addedByAttestorPublicKeyHex ?? this.addedByAttestorPublicKeyHex,
      addedByAttestation: addedByAttestation ?? this.addedByAttestation,
      revokedByAttestorPublicKeyHex: revokedByAttestorPublicKeyHex is String?
          ? revokedByAttestorPublicKeyHex
          : this.revokedByAttestorPublicKeyHex,
      revokedByAttestation: revokedByAttestation is String?
          ? revokedByAttestation
          : this.revokedByAttestation,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
      keyEpoch: keyEpoch ?? this.keyEpoch,
      roleChangedAt: roleChangedAt is DateTime?
          ? roleChangedAt
          : this.roleChangedAt,
      roleChangedByAttestorPublicKeyHex:
          roleChangedByAttestorPublicKeyHex is String?
          ? roleChangedByAttestorPublicKeyHex
          : this.roleChangedByAttestorPublicKeyHex,
      roleChangedByAttestation: roleChangedByAttestation is String?
          ? roleChangedByAttestation
          : this.roleChangedByAttestation,
    );
  }
}

class GroupMemberUpdateTable extends _is.UpdateTable<GroupMemberTable> {
  GroupMemberUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> shareGroupId(
    _is.UuidValue value,
  ) => _is.ColumnValue(table.shareGroupId, value);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> anonAccountId(
    _is.UuidValue value,
  ) => _is.ColumnValue(table.anonAccountId, value);

  _is.ColumnValue<_imgpb098.GroupMemberRole, _imgpb098.GroupMemberRole> role(
    _imgpb098.GroupMemberRole value,
  ) => _is.ColumnValue(table.role, value);

  _is.ColumnValue<String, String> memberSigningPublicKeyHex(String value) =>
      _is.ColumnValue(table.memberSigningPublicKeyHex, value);

  _is.ColumnValue<String, String> memberEncryptionPublicKeyHex(String value) =>
      _is.ColumnValue(table.memberEncryptionPublicKeyHex, value);

  _is.ColumnValue<String, String> encryptedDataKey(String value) =>
      _is.ColumnValue(table.encryptedDataKey, value);

  _is.ColumnValue<String, String> encryptedMemberKey(String value) =>
      _is.ColumnValue(table.encryptedMemberKey, value);

  _is.ColumnValue<DateTime, DateTime> joinedAt(DateTime value) =>
      _is.ColumnValue(table.joinedAt, value);

  _is.ColumnValue<bool, bool> isRevoked(bool value) =>
      _is.ColumnValue(table.isRevoked, value);

  _is.ColumnValue<String, String> addedByAttestorPublicKeyHex(String value) =>
      _is.ColumnValue(table.addedByAttestorPublicKeyHex, value);

  _is.ColumnValue<String, String> addedByAttestation(String value) =>
      _is.ColumnValue(table.addedByAttestation, value);

  _is.ColumnValue<String, String> revokedByAttestorPublicKeyHex(
    String? value,
  ) => _is.ColumnValue(table.revokedByAttestorPublicKeyHex, value);

  _is.ColumnValue<String, String> revokedByAttestation(String? value) =>
      _is.ColumnValue(table.revokedByAttestation, value);

  _is.ColumnValue<DateTime, DateTime> revokedAt(DateTime? value) =>
      _is.ColumnValue(table.revokedAt, value);

  _is.ColumnValue<int, int> keyEpoch(int value) =>
      _is.ColumnValue(table.keyEpoch, value);

  _is.ColumnValue<DateTime, DateTime> roleChangedAt(DateTime? value) =>
      _is.ColumnValue(table.roleChangedAt, value);

  _is.ColumnValue<String, String> roleChangedByAttestorPublicKeyHex(
    String? value,
  ) => _is.ColumnValue(table.roleChangedByAttestorPublicKeyHex, value);

  _is.ColumnValue<String, String> roleChangedByAttestation(String? value) =>
      _is.ColumnValue(table.roleChangedByAttestation, value);
}

class GroupMemberTable extends _is.Table<_is.UuidValue?> {
  GroupMemberTable({super.tableRelation}) : super(tableName: 'group_member') {
    updateTable = GroupMemberUpdateTable(this);
    shareGroupId = _is.ColumnUuid('shareGroupId', this);
    anonAccountId = _is.ColumnUuid('anonAccountId', this);
    role = _is.ColumnEnum('role', this, _is.EnumSerialization.byName);
    memberSigningPublicKeyHex = _is.ColumnString(
      'memberSigningPublicKeyHex',
      this,
    );
    memberEncryptionPublicKeyHex = _is.ColumnString(
      'memberEncryptionPublicKeyHex',
      this,
    );
    encryptedDataKey = _is.ColumnString('encryptedDataKey', this);
    encryptedMemberKey = _is.ColumnString('encryptedMemberKey', this);
    joinedAt = _is.ColumnDateTime('joinedAt', this, hasDefault: true);
    isRevoked = _is.ColumnBool('isRevoked', this, hasDefault: true);
    addedByAttestorPublicKeyHex = _is.ColumnString(
      'addedByAttestorPublicKeyHex',
      this,
    );
    addedByAttestation = _is.ColumnString('addedByAttestation', this);
    revokedByAttestorPublicKeyHex = _is.ColumnString(
      'revokedByAttestorPublicKeyHex',
      this,
    );
    revokedByAttestation = _is.ColumnString('revokedByAttestation', this);
    revokedAt = _is.ColumnDateTime('revokedAt', this);
    keyEpoch = _is.ColumnInt('keyEpoch', this, hasDefault: true);
    roleChangedAt = _is.ColumnDateTime('roleChangedAt', this);
    roleChangedByAttestorPublicKeyHex = _is.ColumnString(
      'roleChangedByAttestorPublicKeyHex',
      this,
    );
    roleChangedByAttestation = _is.ColumnString(
      'roleChangedByAttestation',
      this,
    );
  }

  late final GroupMemberUpdateTable updateTable;

  late final _is.ColumnUuid shareGroupId;

  _i97quwy2.ShareGroupTable? _shareGroup;

  late final _is.ColumnUuid anonAccountId;

  _iulmo8pc.AnonAccountTable? _anonAccount;

  late final _is.ColumnEnum<_imgpb098.GroupMemberRole> role;

  late final _is.ColumnString memberSigningPublicKeyHex;

  late final _is.ColumnString memberEncryptionPublicKeyHex;

  late final _is.ColumnString encryptedDataKey;

  late final _is.ColumnString encryptedMemberKey;

  late final _is.ColumnDateTime joinedAt;

  late final _is.ColumnBool isRevoked;

  late final _is.ColumnString addedByAttestorPublicKeyHex;

  late final _is.ColumnString addedByAttestation;

  late final _is.ColumnString revokedByAttestorPublicKeyHex;

  late final _is.ColumnString revokedByAttestation;

  late final _is.ColumnDateTime revokedAt;

  late final _is.ColumnInt keyEpoch;

  late final _is.ColumnDateTime roleChangedAt;

  late final _is.ColumnString roleChangedByAttestorPublicKeyHex;

  late final _is.ColumnString roleChangedByAttestation;

  _i97quwy2.ShareGroupTable get shareGroup {
    if (_shareGroup != null) return _shareGroup!;
    _shareGroup = _is.createRelationTable(
      relationFieldName: 'shareGroup',
      field: GroupMember.t.shareGroupId,
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
      field: GroupMember.t.anonAccountId,
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
    role,
    memberSigningPublicKeyHex,
    memberEncryptionPublicKeyHex,
    encryptedDataKey,
    encryptedMemberKey,
    joinedAt,
    isRevoked,
    addedByAttestorPublicKeyHex,
    addedByAttestation,
    revokedByAttestorPublicKeyHex,
    revokedByAttestation,
    revokedAt,
    keyEpoch,
    roleChangedAt,
    roleChangedByAttestorPublicKeyHex,
    roleChangedByAttestation,
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

class GroupMemberInclude extends _is.IncludeObject {
  GroupMemberInclude._({
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
  _is.Table<_is.UuidValue?> get table => GroupMember.t;
}

class GroupMemberIncludeList extends _is.IncludeList {
  GroupMemberIncludeList._({
    _is.WhereExpressionBuilder<GroupMemberTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GroupMember.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => GroupMember.t;
}

class GroupMemberRepository {
  const GroupMemberRepository._();

  final attachRow = const GroupMemberAttachRowRepository._();

  /// Returns a list of [GroupMember]s matching the given query parameters.
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
  Future<List<GroupMember>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupMemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupMemberTable>? orderBy,
    _is.OrderByListBuilder<GroupMemberTable>? orderByList,
    _is.Transaction? transaction,
    GroupMemberInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GroupMember>(
      where: where?.call(GroupMember.t),
      orderBy: orderBy?.call(GroupMember.t),
      orderByList: orderByList?.call(GroupMember.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [GroupMember] matching the given query parameters.
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
  Future<GroupMember?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupMemberTable>? where,
    int? offset,
    _is.OrderByBuilder<GroupMemberTable>? orderBy,
    _is.OrderByListBuilder<GroupMemberTable>? orderByList,
    _is.Transaction? transaction,
    GroupMemberInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GroupMember>(
      where: where?.call(GroupMember.t),
      orderBy: orderBy?.call(GroupMember.t),
      orderByList: orderByList?.call(GroupMember.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GroupMember] by its [id] or null if no such row exists.
  Future<GroupMember?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    GroupMemberInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<GroupMember>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [GroupMember]s in the list and returns the inserted rows.
  ///
  /// The returned [GroupMember]s will have their `id` fields set.
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
  Future<List<GroupMember>> insert(
    _is.DatabaseSession session,
    List<GroupMember> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<GroupMember>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [GroupMember] and returns the inserted row.
  ///
  /// The returned [GroupMember] will have its `id` field set.
  Future<GroupMember> insertRow(
    _is.DatabaseSession session,
    GroupMember row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<GroupMember>(row, transaction: transaction);
  }

  /// Upserts all [GroupMember]s in the list and returns the resulting rows.
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
  /// The returned [GroupMember]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupMember>> upsert(
    _is.DatabaseSession session,
    List<GroupMember> rows, {
    required _is.ColumnSelections<GroupMemberTable> conflictColumns,
    _is.ColumnSelections<GroupMemberTable>? updateColumns,
    _is.WhereExpressionBuilder<GroupMemberTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<GroupMember>(
      rows,
      conflictColumns: conflictColumns(GroupMember.t),
      updateColumns: updateColumns?.call(GroupMember.t),
      updateWhere: updateWhere?.call(GroupMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [GroupMember] and returns the resulting row.
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
  /// The returned [GroupMember] will have its `id` field set.
  Future<GroupMember?> upsertRow(
    _is.DatabaseSession session,
    GroupMember row, {
    required _is.ColumnSelections<GroupMemberTable> conflictColumns,
    _is.ColumnSelections<GroupMemberTable>? updateColumns,
    _is.WhereExpressionBuilder<GroupMemberTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<GroupMember>(
      row,
      conflictColumns: conflictColumns(GroupMember.t),
      updateColumns: updateColumns?.call(GroupMember.t),
      updateWhere: updateWhere?.call(GroupMember.t),
      transaction: transaction,
    );
  }

  /// Updates all [GroupMember]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupMember>> update(
    _is.DatabaseSession session,
    List<GroupMember> rows, {
    _is.ColumnSelections<GroupMemberTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<GroupMember>(
      rows,
      columns: columns?.call(GroupMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [GroupMember]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GroupMember> updateRow(
    _is.DatabaseSession session,
    GroupMember row, {
    _is.ColumnSelections<GroupMemberTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<GroupMember>(
      row,
      columns: columns?.call(GroupMember.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GroupMember] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<GroupMember?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<GroupMemberUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<GroupMember>(
      id,
      columnValues: columnValues(GroupMember.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GroupMember]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupMember>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<GroupMemberUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<GroupMemberTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GroupMemberTable>? orderBy,
    _is.OrderByListBuilder<GroupMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<GroupMember>(
      columnValues: columnValues(GroupMember.t.updateTable),
      where: where(GroupMember.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupMember.t),
      orderByList: orderByList?.call(GroupMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [GroupMember]s in the list and returns the deleted rows.
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
  Future<List<GroupMember>> delete(
    _is.DatabaseSession session,
    List<GroupMember> rows, {
    _is.OrderByBuilder<GroupMemberTable>? orderBy,
    _is.OrderByListBuilder<GroupMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<GroupMember>(
      rows,
      orderBy: orderBy?.call(GroupMember.t),
      orderByList: orderByList?.call(GroupMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [GroupMember].
  Future<GroupMember> deleteRow(
    _is.DatabaseSession session,
    GroupMember row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GroupMember>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GroupMember>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GroupMemberTable> where,
    _is.OrderByBuilder<GroupMemberTable>? orderBy,
    _is.OrderByListBuilder<GroupMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<GroupMember>(
      where: where(GroupMember.t),
      orderBy: orderBy?.call(GroupMember.t),
      orderByList: orderByList?.call(GroupMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GroupMemberTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<GroupMember>(
      where: where?.call(GroupMember.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GroupMember] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GroupMemberTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<GroupMember>(
      where: where(GroupMember.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class GroupMemberAttachRowRepository {
  const GroupMemberAttachRowRepository._();

  /// Creates a relation between the given [GroupMember] and [ShareGroup]
  /// by setting the [GroupMember]'s foreign key `shareGroupId` to refer to the [ShareGroup].
  Future<void> shareGroup(
    _is.DatabaseSession session,
    GroupMember groupMember,
    _i97quwy2.ShareGroup shareGroup, {
    _is.Transaction? transaction,
  }) async {
    if (groupMember.id == null) {
      throw ArgumentError.notNull('groupMember.id');
    }
    if (shareGroup.id == null) {
      throw ArgumentError.notNull('shareGroup.id');
    }

    var $groupMember = groupMember.copyWith(shareGroupId: shareGroup.id);
    await session.db.updateRow<GroupMember>(
      $groupMember,
      columns: [GroupMember.t.shareGroupId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [GroupMember] and [AnonAccount]
  /// by setting the [GroupMember]'s foreign key `anonAccountId` to refer to the [AnonAccount].
  Future<void> anonAccount(
    _is.DatabaseSession session,
    GroupMember groupMember,
    _iulmo8pc.AnonAccount anonAccount, {
    _is.Transaction? transaction,
  }) async {
    if (groupMember.id == null) {
      throw ArgumentError.notNull('groupMember.id');
    }
    if (anonAccount.id == null) {
      throw ArgumentError.notNull('anonAccount.id');
    }

    var $groupMember = groupMember.copyWith(anonAccountId: anonAccount.id);
    await session.db.updateRow<GroupMember>(
      $groupMember,
      columns: [GroupMember.t.anonAccountId],
      transaction: transaction,
    );
  }
}
