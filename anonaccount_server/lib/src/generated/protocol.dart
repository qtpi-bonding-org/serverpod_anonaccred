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
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i3;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i4;
import 'account.dart' as _i5;
import 'account_creation_response.dart' as _i6;
import 'account_device.dart' as _i7;
import 'anonaccount_exception.dart' as _i8;
import 'authentication_exception.dart' as _i9;
import 'authentication_result.dart' as _i10;
import 'challenge_exists.dart' as _i11;
import 'device_pairing_event.dart' as _i12;
import 'device_pairing_info.dart' as _i13;
import 'encrypted_data_key_response.dart' as _i14;
import 'grant_tier.dart' as _i15;
import 'group_member.dart' as _i16;
import 'group_member_device.dart' as _i17;
import 'group_member_role.dart' as _i18;
import 'member_device_grant.dart' as _i19;
import 'public_challenge.dart' as _i20;
import 'public_challenge_response.dart' as _i21;
import 'public_key_duo.dart' as _i22;
import 'rate_limit_counter.dart' as _i23;
import 'shard_routing.dart' as _i24;
import 'share_group.dart' as _i25;
import 'package:anonaccount_server/src/generated/account_device.dart' as _i26;
import 'package:anonaccount_server/src/generated/group_member.dart' as _i27;
export 'account.dart';
export 'account_creation_response.dart';
export 'account_device.dart';
export 'anonaccount_exception.dart';
export 'authentication_exception.dart';
export 'authentication_result.dart';
export 'challenge_exists.dart';
export 'device_pairing_event.dart';
export 'device_pairing_info.dart';
export 'encrypted_data_key_response.dart';
export 'grant_tier.dart';
export 'group_member.dart';
export 'group_member_device.dart';
export 'group_member_role.dart';
export 'member_device_grant.dart';
export 'public_challenge.dart';
export 'public_challenge_response.dart';
export 'public_key_duo.dart';
export 'rate_limit_counter.dart';
export 'shard_routing.dart';
export 'share_group.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'account_device',
      dartName: 'AccountDevice',
      schema: 'public',
      module: 'anonaccount',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'anonAccountId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'deviceSigningPublicKeyHex',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'deviceEncryptionPublicKeyHex',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'encryptedDataKey',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'label',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'addedBySignerPublicKeyHex',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'addedByAttestation',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'lastActive',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'isRevoked',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'revokedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'keyEpoch',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'account_device_fk_0',
          columns: ['anonAccountId'],
          referenceTable: 'anon_account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'account_device_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'device_signing_key_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'deviceSigningPublicKeyHex',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'account_devices_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'anonAccountId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'anon_account',
      dartName: 'AnonAccount',
      schema: 'public',
      module: 'anonaccount',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'ultimateSigningPublicKeyHex',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'encryptedDataKey',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'ultimateEncryptionPublicKeyHex',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'anon_account_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'ultimate_signing_key_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'ultimateSigningPublicKeyHex',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'group_member',
      dartName: 'GroupMember',
      schema: 'public',
      module: 'anonaccount',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'shareGroupId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'anonAccountId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'role',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:GroupMemberRole',
        ),
        _i2.ColumnDefinition(
          name: 'memberSigningPublicKeyHex',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'memberEncryptionPublicKeyHex',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'encryptedDataKey',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'joinedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'lastActive',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'isRevoked',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'addedBySignerPublicKeyHex',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'addedByAttestation',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'revokedBySignerPublicKeyHex',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'revokedByAttestation',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'revokedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'group_member_fk_0',
          columns: ['shareGroupId'],
          referenceTable: 'share_group',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'group_member_fk_1',
          columns: ['anonAccountId'],
          referenceTable: 'anon_account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'group_member_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'group_member_signing_key_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'memberSigningPublicKeyHex',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'group_member_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'shareGroupId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'anonAccountId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'group_member_account_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'anonAccountId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'group_member_device',
      dartName: 'GroupMemberDevice',
      schema: 'public',
      module: 'anonaccount',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'groupMemberId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'accountDeviceId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'encryptedDataKey',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'addedBySignerPublicKeyHex',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'addedByAttestation',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'isRevoked',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'revokedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'group_member_device_fk_0',
          columns: ['groupMemberId'],
          referenceTable: 'group_member',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'group_member_device_fk_1',
          columns: ['accountDeviceId'],
          referenceTable: 'account_device',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'group_member_device_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'group_member_device_active_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'groupMemberId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'accountDeviceId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'group_member_device_device_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'accountDeviceId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'public_challenges',
      dartName: 'PublicChallenge',
      schema: 'public',
      module: 'anonaccount',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'public_challenges_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'challenge',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'expiresAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'public_challenges_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'public_challenges_challenge_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'challenge',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'public_challenges_expires_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'expiresAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'shard_routing',
      dartName: 'ShardRouting',
      schema: 'public',
      module: 'anonaccount',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'tenantId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'tenantType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'shardName',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'shard_01\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'shard_routing_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'shard_routing_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'tenantId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'tenantType',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'share_group',
      dartName: 'ShareGroup',
      schema: 'public',
      module: 'anonaccount',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'ultimateSigningPublicKeyHex',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'ultimateEncryptionPublicKeyHex',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'encryptedDataKey',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'keyEpoch',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'share_group_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'share_group_ultimate_signing_key_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'ultimateSigningPublicKeyHex',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i4.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    if (className == null) return null;
    if (!className.startsWith('anonaccount.')) return className;
    return className.substring(12);
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i5.AnonAccount) {
      return _i5.AnonAccount.fromJson(data) as T;
    }
    if (t == _i6.AccountCreationResponse) {
      return _i6.AccountCreationResponse.fromJson(data) as T;
    }
    if (t == _i7.AccountDevice) {
      return _i7.AccountDevice.fromJson(data) as T;
    }
    if (t == _i8.AnonAccountException) {
      return _i8.AnonAccountException.fromJson(data) as T;
    }
    if (t == _i9.AuthenticationException) {
      return _i9.AuthenticationException.fromJson(data) as T;
    }
    if (t == _i10.AuthenticationResult) {
      return _i10.AuthenticationResult.fromJson(data) as T;
    }
    if (t == _i11.ChallengeExists) {
      return _i11.ChallengeExists.fromJson(data) as T;
    }
    if (t == _i12.DevicePairingEvent) {
      return _i12.DevicePairingEvent.fromJson(data) as T;
    }
    if (t == _i13.DevicePairingInfo) {
      return _i13.DevicePairingInfo.fromJson(data) as T;
    }
    if (t == _i14.EncryptedDataKeyResponse) {
      return _i14.EncryptedDataKeyResponse.fromJson(data) as T;
    }
    if (t == _i15.GrantTier) {
      return _i15.GrantTier.fromJson(data) as T;
    }
    if (t == _i16.GroupMember) {
      return _i16.GroupMember.fromJson(data) as T;
    }
    if (t == _i17.GroupMemberDevice) {
      return _i17.GroupMemberDevice.fromJson(data) as T;
    }
    if (t == _i18.GroupMemberRole) {
      return _i18.GroupMemberRole.fromJson(data) as T;
    }
    if (t == _i19.MemberDeviceGrant) {
      return _i19.MemberDeviceGrant.fromJson(data) as T;
    }
    if (t == _i20.PublicChallenge) {
      return _i20.PublicChallenge.fromJson(data) as T;
    }
    if (t == _i21.PublicChallengeResponse) {
      return _i21.PublicChallengeResponse.fromJson(data) as T;
    }
    if (t == _i22.PublicKeyDuo) {
      return _i22.PublicKeyDuo.fromJson(data) as T;
    }
    if (t == _i23.RateLimitCounter) {
      return _i23.RateLimitCounter.fromJson(data) as T;
    }
    if (t == _i24.ShardRouting) {
      return _i24.ShardRouting.fromJson(data) as T;
    }
    if (t == _i25.ShareGroup) {
      return _i25.ShareGroup.fromJson(data) as T;
    }
    if (t == _i1.getType<_i5.AnonAccount?>()) {
      return (data != null ? _i5.AnonAccount.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.AccountCreationResponse?>()) {
      return (data != null ? _i6.AccountCreationResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i7.AccountDevice?>()) {
      return (data != null ? _i7.AccountDevice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.AnonAccountException?>()) {
      return (data != null ? _i8.AnonAccountException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i9.AuthenticationException?>()) {
      return (data != null ? _i9.AuthenticationException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.AuthenticationResult?>()) {
      return (data != null ? _i10.AuthenticationResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i11.ChallengeExists?>()) {
      return (data != null ? _i11.ChallengeExists.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.DevicePairingEvent?>()) {
      return (data != null ? _i12.DevicePairingEvent.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i13.DevicePairingInfo?>()) {
      return (data != null ? _i13.DevicePairingInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.EncryptedDataKeyResponse?>()) {
      return (data != null
              ? _i14.EncryptedDataKeyResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i15.GrantTier?>()) {
      return (data != null ? _i15.GrantTier.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.GroupMember?>()) {
      return (data != null ? _i16.GroupMember.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.GroupMemberDevice?>()) {
      return (data != null ? _i17.GroupMemberDevice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.GroupMemberRole?>()) {
      return (data != null ? _i18.GroupMemberRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.MemberDeviceGrant?>()) {
      return (data != null ? _i19.MemberDeviceGrant.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.PublicChallenge?>()) {
      return (data != null ? _i20.PublicChallenge.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.PublicChallengeResponse?>()) {
      return (data != null ? _i21.PublicChallengeResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i22.PublicKeyDuo?>()) {
      return (data != null ? _i22.PublicKeyDuo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.RateLimitCounter?>()) {
      return (data != null ? _i23.RateLimitCounter.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.ShardRouting?>()) {
      return (data != null ? _i24.ShardRouting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.ShareGroup?>()) {
      return (data != null ? _i25.ShareGroup.fromJson(data) : null) as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == _i1.getType<Map<String, String>?>()) {
      return (data != null
              ? (data as Map).map(
                  (k, v) =>
                      MapEntry(deserialize<String>(k), deserialize<String>(v)),
                )
              : null)
          as T;
    }
    if (t == List<_i26.AccountDevice>) {
      return (data as List)
              .map((e) => deserialize<_i26.AccountDevice>(e))
              .toList()
          as T;
    }
    if (t == List<_i27.GroupMember>) {
      return (data as List)
              .map((e) => deserialize<_i27.GroupMember>(e))
              .toList()
          as T;
    }
    try {
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i4.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i5.AnonAccount => 'AnonAccount',
      _i6.AccountCreationResponse => 'AccountCreationResponse',
      _i7.AccountDevice => 'AccountDevice',
      _i8.AnonAccountException => 'AnonAccountException',
      _i9.AuthenticationException => 'AuthenticationException',
      _i10.AuthenticationResult => 'AuthenticationResult',
      _i11.ChallengeExists => 'ChallengeExists',
      _i12.DevicePairingEvent => 'DevicePairingEvent',
      _i13.DevicePairingInfo => 'DevicePairingInfo',
      _i14.EncryptedDataKeyResponse => 'EncryptedDataKeyResponse',
      _i15.GrantTier => 'GrantTier',
      _i16.GroupMember => 'GroupMember',
      _i17.GroupMemberDevice => 'GroupMemberDevice',
      _i18.GroupMemberRole => 'GroupMemberRole',
      _i19.MemberDeviceGrant => 'MemberDeviceGrant',
      _i20.PublicChallenge => 'PublicChallenge',
      _i21.PublicChallengeResponse => 'PublicChallengeResponse',
      _i22.PublicKeyDuo => 'PublicKeyDuo',
      _i23.RateLimitCounter => 'RateLimitCounter',
      _i24.ShardRouting => 'ShardRouting',
      _i25.ShareGroup => 'ShareGroup',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('anonaccount.', '');
    }

    switch (data) {
      case _i5.AnonAccount():
        return 'AnonAccount';
      case _i6.AccountCreationResponse():
        return 'AccountCreationResponse';
      case _i7.AccountDevice():
        return 'AccountDevice';
      case _i8.AnonAccountException():
        return 'AnonAccountException';
      case _i9.AuthenticationException():
        return 'AuthenticationException';
      case _i10.AuthenticationResult():
        return 'AuthenticationResult';
      case _i11.ChallengeExists():
        return 'ChallengeExists';
      case _i12.DevicePairingEvent():
        return 'DevicePairingEvent';
      case _i13.DevicePairingInfo():
        return 'DevicePairingInfo';
      case _i14.EncryptedDataKeyResponse():
        return 'EncryptedDataKeyResponse';
      case _i15.GrantTier():
        return 'GrantTier';
      case _i16.GroupMember():
        return 'GroupMember';
      case _i17.GroupMemberDevice():
        return 'GroupMemberDevice';
      case _i18.GroupMemberRole():
        return 'GroupMemberRole';
      case _i19.MemberDeviceGrant():
        return 'MemberDeviceGrant';
      case _i20.PublicChallenge():
        return 'PublicChallenge';
      case _i21.PublicChallengeResponse():
        return 'PublicChallengeResponse';
      case _i22.PublicKeyDuo():
        return 'PublicKeyDuo';
      case _i23.RateLimitCounter():
        return 'RateLimitCounter';
      case _i24.ShardRouting():
        return 'ShardRouting';
      case _i25.ShareGroup():
        return 'ShareGroup';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    className = _i3.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i4.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AnonAccount') {
      return deserialize<_i5.AnonAccount>(data['data']);
    }
    if (dataClassName == 'AccountCreationResponse') {
      return deserialize<_i6.AccountCreationResponse>(data['data']);
    }
    if (dataClassName == 'AccountDevice') {
      return deserialize<_i7.AccountDevice>(data['data']);
    }
    if (dataClassName == 'AnonAccountException') {
      return deserialize<_i8.AnonAccountException>(data['data']);
    }
    if (dataClassName == 'AuthenticationException') {
      return deserialize<_i9.AuthenticationException>(data['data']);
    }
    if (dataClassName == 'AuthenticationResult') {
      return deserialize<_i10.AuthenticationResult>(data['data']);
    }
    if (dataClassName == 'ChallengeExists') {
      return deserialize<_i11.ChallengeExists>(data['data']);
    }
    if (dataClassName == 'DevicePairingEvent') {
      return deserialize<_i12.DevicePairingEvent>(data['data']);
    }
    if (dataClassName == 'DevicePairingInfo') {
      return deserialize<_i13.DevicePairingInfo>(data['data']);
    }
    if (dataClassName == 'EncryptedDataKeyResponse') {
      return deserialize<_i14.EncryptedDataKeyResponse>(data['data']);
    }
    if (dataClassName == 'GrantTier') {
      return deserialize<_i15.GrantTier>(data['data']);
    }
    if (dataClassName == 'GroupMember') {
      return deserialize<_i16.GroupMember>(data['data']);
    }
    if (dataClassName == 'GroupMemberDevice') {
      return deserialize<_i17.GroupMemberDevice>(data['data']);
    }
    if (dataClassName == 'GroupMemberRole') {
      return deserialize<_i18.GroupMemberRole>(data['data']);
    }
    if (dataClassName == 'MemberDeviceGrant') {
      return deserialize<_i19.MemberDeviceGrant>(data['data']);
    }
    if (dataClassName == 'PublicChallenge') {
      return deserialize<_i20.PublicChallenge>(data['data']);
    }
    if (dataClassName == 'PublicChallengeResponse') {
      return deserialize<_i21.PublicChallengeResponse>(data['data']);
    }
    if (dataClassName == 'PublicKeyDuo') {
      return deserialize<_i22.PublicKeyDuo>(data['data']);
    }
    if (dataClassName == 'RateLimitCounter') {
      return deserialize<_i23.RateLimitCounter>(data['data']);
    }
    if (dataClassName == 'ShardRouting') {
      return deserialize<_i24.ShardRouting>(data['data']);
    }
    if (dataClassName == 'ShareGroup') {
      return deserialize<_i25.ShareGroup>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i3.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i4.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i4.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i5.AnonAccount:
        return _i5.AnonAccount.t;
      case _i7.AccountDevice:
        return _i7.AccountDevice.t;
      case _i16.GroupMember:
        return _i16.GroupMember.t;
      case _i17.GroupMemberDevice:
        return _i17.GroupMemberDevice.t;
      case _i20.PublicChallenge:
        return _i20.PublicChallenge.t;
      case _i24.ShardRouting:
        return _i24.ShardRouting.t;
      case _i25.ShareGroup:
        return _i25.ShareGroup.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'anonaccount';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i3.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i4.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
