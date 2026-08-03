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
import 'group_member_role.dart' as _i4;
import 'package:anonaccount_server/src/generated/protocol.dart' as _i5;

abstract class GroupMember
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
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
    _i1.UuidValue? id,
    required _i1.UuidValue shareGroupId,
    _i2.ShareGroup? shareGroup,
    required _i1.UuidValue anonAccountId,
    _i3.AnonAccount? anonAccount,
    required _i4.GroupMemberRole role,
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
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      shareGroupId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['shareGroupId'],
      ),
      shareGroup: jsonSerialization['shareGroup'] == null
          ? null
          : _i5.Protocol().deserialize<_i2.ShareGroup>(
              jsonSerialization['shareGroup'],
            ),
      anonAccountId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['anonAccountId'],
      ),
      anonAccount: jsonSerialization['anonAccount'] == null
          ? null
          : _i5.Protocol().deserialize<_i3.AnonAccount>(
              jsonSerialization['anonAccount'],
            ),
      role: _i4.GroupMemberRole.fromJson((jsonSerialization['role'] as String)),
      memberSigningPublicKeyHex:
          jsonSerialization['memberSigningPublicKeyHex'] as String,
      memberEncryptionPublicKeyHex:
          jsonSerialization['memberEncryptionPublicKeyHex'] as String,
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      encryptedMemberKey: jsonSerialization['encryptedMemberKey'] as String,
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
      isRevoked: jsonSerialization['isRevoked'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isRevoked']),
      addedByAttestorPublicKeyHex:
          jsonSerialization['addedByAttestorPublicKeyHex'] as String,
      addedByAttestation: jsonSerialization['addedByAttestation'] as String,
      revokedByAttestorPublicKeyHex:
          jsonSerialization['revokedByAttestorPublicKeyHex'] as String?,
      revokedByAttestation:
          jsonSerialization['revokedByAttestation'] as String?,
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
      keyEpoch: jsonSerialization['keyEpoch'] as int?,
      roleChangedAt: jsonSerialization['roleChangedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
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
  _i1.UuidValue? id;

  _i1.UuidValue shareGroupId;

  _i2.ShareGroup? shareGroup;

  _i1.UuidValue anonAccountId;

  _i3.AnonAccount? anonAccount;

  _i4.GroupMemberRole role;

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
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [GroupMember]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GroupMember copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? shareGroupId,
    _i2.ShareGroup? shareGroup,
    _i1.UuidValue? anonAccountId,
    _i3.AnonAccount? anonAccount,
    _i4.GroupMemberRole? role,
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
    _i2.ShareGroupInclude? shareGroup,
    _i3.AnonAccountInclude? anonAccount,
  }) {
    return GroupMemberInclude._(
      shareGroup: shareGroup,
      anonAccount: anonAccount,
    );
  }

  static GroupMemberIncludeList includeList({
    _i1.WhereExpressionBuilder<GroupMemberTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GroupMemberTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GroupMemberTable>? orderByList,
    GroupMemberInclude? include,
  }) {
    return GroupMemberIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupMember.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(GroupMember.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupMemberImpl extends GroupMember {
  _GroupMemberImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue shareGroupId,
    _i2.ShareGroup? shareGroup,
    required _i1.UuidValue anonAccountId,
    _i3.AnonAccount? anonAccount,
    required _i4.GroupMemberRole role,
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
  @_i1.useResult
  @override
  GroupMember copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? shareGroupId,
    Object? shareGroup = _Undefined,
    _i1.UuidValue? anonAccountId,
    Object? anonAccount = _Undefined,
    _i4.GroupMemberRole? role,
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
      id: id is _i1.UuidValue? ? id : this.id,
      shareGroupId: shareGroupId ?? this.shareGroupId,
      shareGroup: shareGroup is _i2.ShareGroup?
          ? shareGroup
          : this.shareGroup?.copyWith(),
      anonAccountId: anonAccountId ?? this.anonAccountId,
      anonAccount: anonAccount is _i3.AnonAccount?
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

class GroupMemberUpdateTable extends _i1.UpdateTable<GroupMemberTable> {
  GroupMemberUpdateTable(super.table);

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

  _i1.ColumnValue<_i4.GroupMemberRole, _i4.GroupMemberRole> role(
    _i4.GroupMemberRole value,
  ) => _i1.ColumnValue(
    table.role,
    value,
  );

  _i1.ColumnValue<String, String> memberSigningPublicKeyHex(String value) =>
      _i1.ColumnValue(
        table.memberSigningPublicKeyHex,
        value,
      );

  _i1.ColumnValue<String, String> memberEncryptionPublicKeyHex(String value) =>
      _i1.ColumnValue(
        table.memberEncryptionPublicKeyHex,
        value,
      );

  _i1.ColumnValue<String, String> encryptedDataKey(String value) =>
      _i1.ColumnValue(
        table.encryptedDataKey,
        value,
      );

  _i1.ColumnValue<String, String> encryptedMemberKey(String value) =>
      _i1.ColumnValue(
        table.encryptedMemberKey,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> joinedAt(DateTime value) =>
      _i1.ColumnValue(
        table.joinedAt,
        value,
      );

  _i1.ColumnValue<bool, bool> isRevoked(bool value) => _i1.ColumnValue(
    table.isRevoked,
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

  _i1.ColumnValue<DateTime, DateTime> revokedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.revokedAt,
        value,
      );

  _i1.ColumnValue<int, int> keyEpoch(int value) => _i1.ColumnValue(
    table.keyEpoch,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> roleChangedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.roleChangedAt,
        value,
      );

  _i1.ColumnValue<String, String> roleChangedByAttestorPublicKeyHex(
    String? value,
  ) => _i1.ColumnValue(
    table.roleChangedByAttestorPublicKeyHex,
    value,
  );

  _i1.ColumnValue<String, String> roleChangedByAttestation(String? value) =>
      _i1.ColumnValue(
        table.roleChangedByAttestation,
        value,
      );
}

class GroupMemberTable extends _i1.Table<_i1.UuidValue?> {
  GroupMemberTable({super.tableRelation}) : super(tableName: 'group_member') {
    updateTable = GroupMemberUpdateTable(this);
    shareGroupId = _i1.ColumnUuid(
      'shareGroupId',
      this,
    );
    anonAccountId = _i1.ColumnUuid(
      'anonAccountId',
      this,
    );
    role = _i1.ColumnEnum(
      'role',
      this,
      _i1.EnumSerialization.byName,
    );
    memberSigningPublicKeyHex = _i1.ColumnString(
      'memberSigningPublicKeyHex',
      this,
    );
    memberEncryptionPublicKeyHex = _i1.ColumnString(
      'memberEncryptionPublicKeyHex',
      this,
    );
    encryptedDataKey = _i1.ColumnString(
      'encryptedDataKey',
      this,
    );
    encryptedMemberKey = _i1.ColumnString(
      'encryptedMemberKey',
      this,
    );
    joinedAt = _i1.ColumnDateTime(
      'joinedAt',
      this,
      hasDefault: true,
    );
    isRevoked = _i1.ColumnBool(
      'isRevoked',
      this,
      hasDefault: true,
    );
    addedByAttestorPublicKeyHex = _i1.ColumnString(
      'addedByAttestorPublicKeyHex',
      this,
    );
    addedByAttestation = _i1.ColumnString(
      'addedByAttestation',
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
    revokedAt = _i1.ColumnDateTime(
      'revokedAt',
      this,
    );
    keyEpoch = _i1.ColumnInt(
      'keyEpoch',
      this,
      hasDefault: true,
    );
    roleChangedAt = _i1.ColumnDateTime(
      'roleChangedAt',
      this,
    );
    roleChangedByAttestorPublicKeyHex = _i1.ColumnString(
      'roleChangedByAttestorPublicKeyHex',
      this,
    );
    roleChangedByAttestation = _i1.ColumnString(
      'roleChangedByAttestation',
      this,
    );
  }

  late final GroupMemberUpdateTable updateTable;

  late final _i1.ColumnUuid shareGroupId;

  _i2.ShareGroupTable? _shareGroup;

  late final _i1.ColumnUuid anonAccountId;

  _i3.AnonAccountTable? _anonAccount;

  late final _i1.ColumnEnum<_i4.GroupMemberRole> role;

  late final _i1.ColumnString memberSigningPublicKeyHex;

  late final _i1.ColumnString memberEncryptionPublicKeyHex;

  late final _i1.ColumnString encryptedDataKey;

  late final _i1.ColumnString encryptedMemberKey;

  late final _i1.ColumnDateTime joinedAt;

  late final _i1.ColumnBool isRevoked;

  late final _i1.ColumnString addedByAttestorPublicKeyHex;

  late final _i1.ColumnString addedByAttestation;

  late final _i1.ColumnString revokedByAttestorPublicKeyHex;

  late final _i1.ColumnString revokedByAttestation;

  late final _i1.ColumnDateTime revokedAt;

  late final _i1.ColumnInt keyEpoch;

  late final _i1.ColumnDateTime roleChangedAt;

  late final _i1.ColumnString roleChangedByAttestorPublicKeyHex;

  late final _i1.ColumnString roleChangedByAttestation;

  _i2.ShareGroupTable get shareGroup {
    if (_shareGroup != null) return _shareGroup!;
    _shareGroup = _i1.createRelationTable(
      relationFieldName: 'shareGroup',
      field: GroupMember.t.shareGroupId,
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
      field: GroupMember.t.anonAccountId,
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

class GroupMemberInclude extends _i1.IncludeObject {
  GroupMemberInclude._({
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
  _i1.Table<_i1.UuidValue?> get table => GroupMember.t;
}

class GroupMemberIncludeList extends _i1.IncludeList {
  GroupMemberIncludeList._({
    _i1.WhereExpressionBuilder<GroupMemberTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GroupMember.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => GroupMember.t;
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GroupMemberTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GroupMemberTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GroupMemberTable>? orderByList,
    _i1.Transaction? transaction,
    GroupMemberInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GroupMember>(
      where: where?.call(GroupMember.t),
      orderBy: orderBy?.call(GroupMember.t),
      orderByList: orderByList?.call(GroupMember.t),
      orderDescending: orderDescending,
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GroupMemberTable>? where,
    int? offset,
    _i1.OrderByBuilder<GroupMemberTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GroupMemberTable>? orderByList,
    _i1.Transaction? transaction,
    GroupMemberInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GroupMember>(
      where: where?.call(GroupMember.t),
      orderBy: orderBy?.call(GroupMember.t),
      orderByList: orderByList?.call(GroupMember.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GroupMember] by its [id] or null if no such row exists.
  Future<GroupMember?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    GroupMemberInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
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
  Future<List<GroupMember>> insert(
    _i1.Session session,
    List<GroupMember> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<GroupMember>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [GroupMember] and returns the inserted row.
  ///
  /// The returned [GroupMember] will have its `id` field set.
  Future<GroupMember> insertRow(
    _i1.Session session,
    GroupMember row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<GroupMember>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [GroupMember]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<GroupMember>> update(
    _i1.Session session,
    List<GroupMember> rows, {
    _i1.ColumnSelections<GroupMemberTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<GroupMember>(
      rows,
      columns: columns?.call(GroupMember.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GroupMember]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GroupMember> updateRow(
    _i1.Session session,
    GroupMember row, {
    _i1.ColumnSelections<GroupMemberTable>? columns,
    _i1.Transaction? transaction,
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
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<GroupMemberUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<GroupMember>(
      id,
      columnValues: columnValues(GroupMember.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GroupMember]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<GroupMember>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<GroupMemberUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<GroupMemberTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GroupMemberTable>? orderBy,
    _i1.OrderByListBuilder<GroupMemberTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<GroupMember>(
      columnValues: columnValues(GroupMember.t.updateTable),
      where: where(GroupMember.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GroupMember.t),
      orderByList: orderByList?.call(GroupMember.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [GroupMember]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<GroupMember>> delete(
    _i1.Session session,
    List<GroupMember> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<GroupMember>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [GroupMember].
  Future<GroupMember> deleteRow(
    _i1.Session session,
    GroupMember row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GroupMember>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<GroupMember>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<GroupMemberTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<GroupMember>(
      where: where(GroupMember.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GroupMemberTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<GroupMember>(
      where: where?.call(GroupMember.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GroupMember] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<GroupMemberTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
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
    _i1.Session session,
    GroupMember groupMember,
    _i2.ShareGroup shareGroup, {
    _i1.Transaction? transaction,
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
    _i1.Session session,
    GroupMember groupMember,
    _i3.AnonAccount anonAccount, {
    _i1.Transaction? transaction,
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
