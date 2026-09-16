/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:anonaccount_protocol/anonaccount_protocol.dart' as _ijl9ntd6;
import 'package:anonaccount_server/src/generated/account_device.dart'
    as _i048gg9e;
import 'package:anonaccount_server/src/generated/group_member_view.dart'
    as _i7ifz6hk;
import 'package:anonaccount_server/src/generated/group_membership_view.dart'
    as _ivankdcm;
import 'package:anonaccount_server/src/generated/member_device_grant.dart'
    as _ij4d8jf2;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'account.dart' as _iulmo8pc;
import 'account_creation_response.dart' as _i6fwxwud;
import 'account_device.dart' as _iepmyrfy;
import 'anonaccount_exception.dart' as _isa71u4f;
import 'authentication_exception.dart' as _ip8v2uua;
import 'authentication_result.dart' as _if3kndoe;
import 'challenge_exists.dart' as _i3oy6vzg;
import 'device_pairing_event.dart' as _ipncc0vk;
import 'device_pairing_info.dart' as _ib6tjkvl;
import 'encrypted_data_key_response.dart' as _i3v40fce;
import 'grant_attestor.dart' as _iayw0ozf;
import 'grant_member_device_result.dart' as _iimy53uo;
import 'group_member.dart' as _igiek2ee;
import 'group_member_device.dart' as _ijdcafmt;
import 'group_member_role.dart' as _imgpb098;
import 'group_member_view.dart' as _iizktvdn;
import 'group_membership_view.dart' as _ilz3mlqj;
import 'group_owner.dart' as _ibp98ugq;
import 'member_device_grant.dart' as _i3iqayiq;
import 'member_device_grant_outcome.dart' as _igy7ui1b;
import 'public_challenge.dart' as _iju4wcr1;
import 'public_challenge_response.dart' as _i8x07tkq;
import 'rate_limit_counter.dart' as _i6yhx6i0;
import 'shard_routing.dart' as _igkybre3;
import 'share_group.dart' as _i97quwy2;
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
export 'grant_attestor.dart';
export 'grant_member_device_result.dart';
export 'group_member.dart';
export 'group_member_device.dart';
export 'group_member_role.dart';
export 'group_member_view.dart';
export 'group_membership_view.dart';
export 'group_owner.dart';
export 'member_device_grant.dart';
export 'member_device_grant_outcome.dart';
export 'public_challenge.dart';
export 'public_challenge_response.dart';
export 'rate_limit_counter.dart';
export 'shard_routing.dart';
export 'share_group.dart';
export 'package:anonaccount_protocol/anonaccount_protocol.dart' hide Protocol;

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  final Set<_is.SerializationManager> _hostProtocols = {};

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'account_device',
      dartName: 'AccountDevice',
      schema: 'public',
      module: 'anonaccount',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'anonAccountId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'deviceSigningPublicKeyHex',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'deviceEncryptionPublicKeyHex',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'encryptedDataKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'label',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'addedByAttestorPublicKeyHex',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'addedByAttestation',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'lastActive',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'isRevoked',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'revokedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'keyEpoch',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'account_device_fk_0',
          columns: ['anonAccountId'],
          referenceTable: 'anon_account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'device_signing_key_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'deviceSigningPublicKeyHex',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'account_devices_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
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
    _isp.TableDefinition(
      name: 'anon_account',
      dartName: 'AnonAccount',
      schema: 'public',
      module: 'anonaccount',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'ultimateSigningPublicKeyHex',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'encryptedDataKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'ultimateEncryptionPublicKeyHex',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'keyEpoch',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'ultimate_signing_key_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
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
    _isp.TableDefinition(
      name: 'group_member',
      dartName: 'GroupMember',
      schema: 'public',
      module: 'anonaccount',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'shareGroupId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'anonAccountId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'role',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:GroupMemberRole',
        ),
        _isp.ColumnDefinition(
          name: 'memberSigningPublicKeyHex',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'memberEncryptionPublicKeyHex',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'encryptedDataKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'encryptedMemberKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'joinedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'isRevoked',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'addedByAttestorPublicKeyHex',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'addedByAttestation',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'revokedByAttestorPublicKeyHex',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'revokedByAttestation',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'revokedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'keyEpoch',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'roleChangedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'roleChangedByAttestorPublicKeyHex',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'roleChangedByAttestation',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'group_member_fk_0',
          columns: ['shareGroupId'],
          referenceTable: 'share_group',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'group_member_fk_1',
          columns: ['anonAccountId'],
          referenceTable: 'anon_account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'group_member_signing_key_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'memberSigningPublicKeyHex',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'group_member_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'shareGroupId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'anonAccountId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'group_member_account_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
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
    _isp.TableDefinition(
      name: 'group_member_device',
      dartName: 'GroupMemberDevice',
      schema: 'public',
      module: 'anonaccount',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'groupMemberId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'accountDeviceId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'encryptedDataKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'addedByAttestorPublicKeyHex',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'addedByAttestation',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'isRevoked',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'revokedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'keyEpoch',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'group_member_device_fk_0',
          columns: ['groupMemberId'],
          referenceTable: 'group_member',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'group_member_device_fk_1',
          columns: ['accountDeviceId'],
          referenceTable: 'account_device',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'group_member_device_active_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'groupMemberId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'accountDeviceId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'group_member_device_device_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
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
    _isp.TableDefinition(
      name: 'group_owner',
      dartName: 'GroupOwner',
      schema: 'public',
      module: 'anonaccount',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'shareGroupId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'anonAccountId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'encryptedUltimateKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'addedByAttestorPublicKeyHex',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'addedByAttestation',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'keyEpoch',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'isRevoked',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'revokedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'revokedByAttestorPublicKeyHex',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'revokedByAttestation',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'group_owner_fk_0',
          columns: ['shareGroupId'],
          referenceTable: 'share_group',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'group_owner_fk_1',
          columns: ['anonAccountId'],
          referenceTable: 'anon_account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'group_owner_active_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'shareGroupId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'anonAccountId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'group_owner_account_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
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
    _isp.TableDefinition(
      name: 'public_challenges',
      dartName: 'PublicChallenge',
      schema: 'public',
      module: 'anonaccount',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'challenge',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'public_challenges_challenge_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'challenge',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'public_challenges_expires_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
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
    _isp.TableDefinition(
      name: 'shard_routing',
      dartName: 'ShardRouting',
      schema: 'public',
      module: 'anonaccount',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'tenantId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'tenantType',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'shardName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'shard_01\'',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'shard_routing_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'tenantId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
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
    _isp.TableDefinition(
      name: 'share_group',
      dartName: 'ShareGroup',
      schema: 'public',
      module: 'anonaccount',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'ultimateSigningPublicKeyHex',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'ultimateEncryptionPublicKeyHex',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'encryptedDataKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'keyEpoch',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'share_group_ultimate_signing_key_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
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
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._ijl9ntd6.Protocol() is _is.DatabaseSerializationManager
        ? (_ijl9ntd6.Protocol() as _is.DatabaseSerializationManager)
              .getTargetTableDefinitions()
        : [],
  ];

  void registerHostProtocol(
    String projectName,
    _is.SerializationManager protocol,
  ) {
    _hostProtocols.add(protocol);
    _ijl9ntd6.Protocol().registerHostProtocol(projectName, protocol);
  }

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    if (className == null) return null;
    if (!className.startsWith('anonaccount.')) return className;
    return className.substring(12);
  }

  @override
  T deserialize<T>(dynamic data, [Type? t]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _iulmo8pc.AnonAccount) {
      return _iulmo8pc.AnonAccount.fromJson(data) as T;
    }
    if (t == _i6fwxwud.AccountCreationResponse) {
      return _i6fwxwud.AccountCreationResponse.fromJson(data) as T;
    }
    if (t == _iepmyrfy.AccountDevice) {
      return _iepmyrfy.AccountDevice.fromJson(data) as T;
    }
    if (t == _isa71u4f.AnonAccountException) {
      return _isa71u4f.AnonAccountException.fromJson(data) as T;
    }
    if (t == _ip8v2uua.AuthenticationException) {
      return _ip8v2uua.AuthenticationException.fromJson(data) as T;
    }
    if (t == _if3kndoe.AuthenticationResult) {
      return _if3kndoe.AuthenticationResult.fromJson(data) as T;
    }
    if (t == _i3oy6vzg.ChallengeExists) {
      return _i3oy6vzg.ChallengeExists.fromJson(data) as T;
    }
    if (t == _ipncc0vk.DevicePairingEvent) {
      return _ipncc0vk.DevicePairingEvent.fromJson(data) as T;
    }
    if (t == _ib6tjkvl.DevicePairingInfo) {
      return _ib6tjkvl.DevicePairingInfo.fromJson(data) as T;
    }
    if (t == _i3v40fce.EncryptedDataKeyResponse) {
      return _i3v40fce.EncryptedDataKeyResponse.fromJson(data) as T;
    }
    if (t == _iayw0ozf.GrantAttestor) {
      return _iayw0ozf.GrantAttestor.fromJson(data) as T;
    }
    if (t == _iimy53uo.GrantMemberDeviceResult) {
      return _iimy53uo.GrantMemberDeviceResult.fromJson(data) as T;
    }
    if (t == _igiek2ee.GroupMember) {
      return _igiek2ee.GroupMember.fromJson(data) as T;
    }
    if (t == _ijdcafmt.GroupMemberDevice) {
      return _ijdcafmt.GroupMemberDevice.fromJson(data) as T;
    }
    if (t == _imgpb098.GroupMemberRole) {
      return _imgpb098.GroupMemberRole.fromJson(data) as T;
    }
    if (t == _iizktvdn.GroupMemberView) {
      return _iizktvdn.GroupMemberView.fromJson(data) as T;
    }
    if (t == _ilz3mlqj.GroupMembershipView) {
      return _ilz3mlqj.GroupMembershipView.fromJson(data) as T;
    }
    if (t == _ibp98ugq.GroupOwner) {
      return _ibp98ugq.GroupOwner.fromJson(data) as T;
    }
    if (t == _i3iqayiq.MemberDeviceGrant) {
      return _i3iqayiq.MemberDeviceGrant.fromJson(data) as T;
    }
    if (t == _igy7ui1b.MemberDeviceGrantOutcome) {
      return _igy7ui1b.MemberDeviceGrantOutcome.fromJson(data) as T;
    }
    if (t == _iju4wcr1.PublicChallenge) {
      return _iju4wcr1.PublicChallenge.fromJson(data) as T;
    }
    if (t == _i8x07tkq.PublicChallengeResponse) {
      return _i8x07tkq.PublicChallengeResponse.fromJson(data) as T;
    }
    if (t == _i6yhx6i0.RateLimitCounter) {
      return _i6yhx6i0.RateLimitCounter.fromJson(data) as T;
    }
    if (t == _igkybre3.ShardRouting) {
      return _igkybre3.ShardRouting.fromJson(data) as T;
    }
    if (t == _i97quwy2.ShareGroup) {
      return _i97quwy2.ShareGroup.fromJson(data) as T;
    }
    if (t == _is.getType<_iulmo8pc.AnonAccount?>()) {
      return (data != null ? _iulmo8pc.AnonAccount.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i6fwxwud.AccountCreationResponse?>()) {
      return (data != null
              ? _i6fwxwud.AccountCreationResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iepmyrfy.AccountDevice?>()) {
      return (data != null ? _iepmyrfy.AccountDevice.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_isa71u4f.AnonAccountException?>()) {
      return (data != null
              ? _isa71u4f.AnonAccountException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ip8v2uua.AuthenticationException?>()) {
      return (data != null
              ? _ip8v2uua.AuthenticationException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_if3kndoe.AuthenticationResult?>()) {
      return (data != null
              ? _if3kndoe.AuthenticationResult.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i3oy6vzg.ChallengeExists?>()) {
      return (data != null ? _i3oy6vzg.ChallengeExists.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ipncc0vk.DevicePairingEvent?>()) {
      return (data != null ? _ipncc0vk.DevicePairingEvent.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ib6tjkvl.DevicePairingInfo?>()) {
      return (data != null ? _ib6tjkvl.DevicePairingInfo.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i3v40fce.EncryptedDataKeyResponse?>()) {
      return (data != null
              ? _i3v40fce.EncryptedDataKeyResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iayw0ozf.GrantAttestor?>()) {
      return (data != null ? _iayw0ozf.GrantAttestor.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iimy53uo.GrantMemberDeviceResult?>()) {
      return (data != null
              ? _iimy53uo.GrantMemberDeviceResult.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_igiek2ee.GroupMember?>()) {
      return (data != null ? _igiek2ee.GroupMember.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ijdcafmt.GroupMemberDevice?>()) {
      return (data != null ? _ijdcafmt.GroupMemberDevice.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_imgpb098.GroupMemberRole?>()) {
      return (data != null ? _imgpb098.GroupMemberRole.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iizktvdn.GroupMemberView?>()) {
      return (data != null ? _iizktvdn.GroupMemberView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ilz3mlqj.GroupMembershipView?>()) {
      return (data != null
              ? _ilz3mlqj.GroupMembershipView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ibp98ugq.GroupOwner?>()) {
      return (data != null ? _ibp98ugq.GroupOwner.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i3iqayiq.MemberDeviceGrant?>()) {
      return (data != null ? _i3iqayiq.MemberDeviceGrant.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_igy7ui1b.MemberDeviceGrantOutcome?>()) {
      return (data != null
              ? _igy7ui1b.MemberDeviceGrantOutcome.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iju4wcr1.PublicChallenge?>()) {
      return (data != null ? _iju4wcr1.PublicChallenge.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i8x07tkq.PublicChallengeResponse?>()) {
      return (data != null
              ? _i8x07tkq.PublicChallengeResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i6yhx6i0.RateLimitCounter?>()) {
      return (data != null ? _i6yhx6i0.RateLimitCounter.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_igkybre3.ShardRouting?>()) {
      return (data != null ? _igkybre3.ShardRouting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i97quwy2.ShareGroup?>()) {
      return (data != null ? _i97quwy2.ShareGroup.fromJson(data) : null) as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == _is.getType<Map<String, String>?>()) {
      return (data != null
              ? (data as Map).map(
                  (k, v) =>
                      MapEntry(deserialize<String>(k), deserialize<String>(v)),
                )
              : null)
          as T;
    }
    if (t == List<_igy7ui1b.MemberDeviceGrantOutcome>) {
      return (data as List)
              .map((e) => deserialize<_igy7ui1b.MemberDeviceGrantOutcome>(e))
              .toList()
          as T;
    }
    if (t == List<_i048gg9e.AccountDevice>) {
      return (data as List)
              .map((e) => deserialize<_i048gg9e.AccountDevice>(e))
              .toList()
          as T;
    }
    if (t == List<_ivankdcm.GroupMembershipView>) {
      return (data as List)
              .map((e) => deserialize<_ivankdcm.GroupMembershipView>(e))
              .toList()
          as T;
    }
    if (t == List<_i7ifz6hk.GroupMemberView>) {
      return (data as List)
              .map((e) => deserialize<_i7ifz6hk.GroupMemberView>(e))
              .toList()
          as T;
    }
    if (t == List<_ij4d8jf2.MemberDeviceGrant>) {
      return (data as List)
              .map((e) => deserialize<_ij4d8jf2.MemberDeviceGrant>(e))
              .toList()
          as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _ijl9ntd6.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iulmo8pc.AnonAccount => 'AnonAccount',
      _i6fwxwud.AccountCreationResponse => 'AccountCreationResponse',
      _iepmyrfy.AccountDevice => 'AccountDevice',
      _isa71u4f.AnonAccountException => 'AnonAccountException',
      _ip8v2uua.AuthenticationException => 'AuthenticationException',
      _if3kndoe.AuthenticationResult => 'AuthenticationResult',
      _i3oy6vzg.ChallengeExists => 'ChallengeExists',
      _ipncc0vk.DevicePairingEvent => 'DevicePairingEvent',
      _ib6tjkvl.DevicePairingInfo => 'DevicePairingInfo',
      _i3v40fce.EncryptedDataKeyResponse => 'EncryptedDataKeyResponse',
      _iayw0ozf.GrantAttestor => 'GrantAttestor',
      _iimy53uo.GrantMemberDeviceResult => 'GrantMemberDeviceResult',
      _igiek2ee.GroupMember => 'GroupMember',
      _ijdcafmt.GroupMemberDevice => 'GroupMemberDevice',
      _imgpb098.GroupMemberRole => 'GroupMemberRole',
      _iizktvdn.GroupMemberView => 'GroupMemberView',
      _ilz3mlqj.GroupMembershipView => 'GroupMembershipView',
      _ibp98ugq.GroupOwner => 'GroupOwner',
      _i3iqayiq.MemberDeviceGrant => 'MemberDeviceGrant',
      _igy7ui1b.MemberDeviceGrantOutcome => 'MemberDeviceGrantOutcome',
      _iju4wcr1.PublicChallenge => 'PublicChallenge',
      _i8x07tkq.PublicChallengeResponse => 'PublicChallengeResponse',
      _i6yhx6i0.RateLimitCounter => 'RateLimitCounter',
      _igkybre3.ShardRouting => 'ShardRouting',
      _i97quwy2.ShareGroup => 'ShareGroup',
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
      case _iulmo8pc.AnonAccount():
        return 'AnonAccount';
      case _i6fwxwud.AccountCreationResponse():
        return 'AccountCreationResponse';
      case _iepmyrfy.AccountDevice():
        return 'AccountDevice';
      case _isa71u4f.AnonAccountException():
        return 'AnonAccountException';
      case _ip8v2uua.AuthenticationException():
        return 'AuthenticationException';
      case _if3kndoe.AuthenticationResult():
        return 'AuthenticationResult';
      case _i3oy6vzg.ChallengeExists():
        return 'ChallengeExists';
      case _ipncc0vk.DevicePairingEvent():
        return 'DevicePairingEvent';
      case _ib6tjkvl.DevicePairingInfo():
        return 'DevicePairingInfo';
      case _i3v40fce.EncryptedDataKeyResponse():
        return 'EncryptedDataKeyResponse';
      case _iayw0ozf.GrantAttestor():
        return 'GrantAttestor';
      case _iimy53uo.GrantMemberDeviceResult():
        return 'GrantMemberDeviceResult';
      case _igiek2ee.GroupMember():
        return 'GroupMember';
      case _ijdcafmt.GroupMemberDevice():
        return 'GroupMemberDevice';
      case _imgpb098.GroupMemberRole():
        return 'GroupMemberRole';
      case _iizktvdn.GroupMemberView():
        return 'GroupMemberView';
      case _ilz3mlqj.GroupMembershipView():
        return 'GroupMembershipView';
      case _ibp98ugq.GroupOwner():
        return 'GroupOwner';
      case _i3iqayiq.MemberDeviceGrant():
        return 'MemberDeviceGrant';
      case _igy7ui1b.MemberDeviceGrantOutcome():
        return 'MemberDeviceGrantOutcome';
      case _iju4wcr1.PublicChallenge():
        return 'PublicChallenge';
      case _i8x07tkq.PublicChallengeResponse():
        return 'PublicChallengeResponse';
      case _i6yhx6i0.RateLimitCounter():
        return 'RateLimitCounter';
      case _igkybre3.ShardRouting():
        return 'ShardRouting';
      case _i97quwy2.ShareGroup():
        return 'ShareGroup';
    }
    className = _ijl9ntd6.Protocol().getClassNameForObject(data);
    if (className != null) return className;
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
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
      return deserialize<_iulmo8pc.AnonAccount>(data['data']);
    }
    if (dataClassName == 'AccountCreationResponse') {
      return deserialize<_i6fwxwud.AccountCreationResponse>(data['data']);
    }
    if (dataClassName == 'AccountDevice') {
      return deserialize<_iepmyrfy.AccountDevice>(data['data']);
    }
    if (dataClassName == 'AnonAccountException') {
      return deserialize<_isa71u4f.AnonAccountException>(data['data']);
    }
    if (dataClassName == 'AuthenticationException') {
      return deserialize<_ip8v2uua.AuthenticationException>(data['data']);
    }
    if (dataClassName == 'AuthenticationResult') {
      return deserialize<_if3kndoe.AuthenticationResult>(data['data']);
    }
    if (dataClassName == 'ChallengeExists') {
      return deserialize<_i3oy6vzg.ChallengeExists>(data['data']);
    }
    if (dataClassName == 'DevicePairingEvent') {
      return deserialize<_ipncc0vk.DevicePairingEvent>(data['data']);
    }
    if (dataClassName == 'DevicePairingInfo') {
      return deserialize<_ib6tjkvl.DevicePairingInfo>(data['data']);
    }
    if (dataClassName == 'EncryptedDataKeyResponse') {
      return deserialize<_i3v40fce.EncryptedDataKeyResponse>(data['data']);
    }
    if (dataClassName == 'GrantAttestor') {
      return deserialize<_iayw0ozf.GrantAttestor>(data['data']);
    }
    if (dataClassName == 'GrantMemberDeviceResult') {
      return deserialize<_iimy53uo.GrantMemberDeviceResult>(data['data']);
    }
    if (dataClassName == 'GroupMember') {
      return deserialize<_igiek2ee.GroupMember>(data['data']);
    }
    if (dataClassName == 'GroupMemberDevice') {
      return deserialize<_ijdcafmt.GroupMemberDevice>(data['data']);
    }
    if (dataClassName == 'GroupMemberRole') {
      return deserialize<_imgpb098.GroupMemberRole>(data['data']);
    }
    if (dataClassName == 'GroupMemberView') {
      return deserialize<_iizktvdn.GroupMemberView>(data['data']);
    }
    if (dataClassName == 'GroupMembershipView') {
      return deserialize<_ilz3mlqj.GroupMembershipView>(data['data']);
    }
    if (dataClassName == 'GroupOwner') {
      return deserialize<_ibp98ugq.GroupOwner>(data['data']);
    }
    if (dataClassName == 'MemberDeviceGrant') {
      return deserialize<_i3iqayiq.MemberDeviceGrant>(data['data']);
    }
    if (dataClassName == 'MemberDeviceGrantOutcome') {
      return deserialize<_igy7ui1b.MemberDeviceGrantOutcome>(data['data']);
    }
    if (dataClassName == 'PublicChallenge') {
      return deserialize<_iju4wcr1.PublicChallenge>(data['data']);
    }
    if (dataClassName == 'PublicChallengeResponse') {
      return deserialize<_i8x07tkq.PublicChallengeResponse>(data['data']);
    }
    if (dataClassName == 'RateLimitCounter') {
      return deserialize<_i6yhx6i0.RateLimitCounter>(data['data']);
    }
    if (dataClassName == 'ShardRouting') {
      return deserialize<_igkybre3.ShardRouting>(data['data']);
    }
    if (dataClassName == 'ShareGroup') {
      return deserialize<_i97quwy2.ShareGroup>(data['data']);
    }
    try {
      return _ijl9ntd6.Protocol().deserializeByClassName(data);
    } on _is.DeserializationClassNameNotFoundException catch (_) {}
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  Object? dynamicFieldToJson(Object? object, {bool forProtocol = false}) {
    if ((object is List || object is Set || object is Map) ||
        getClassNameForObject(object) != null) {
      return super.dynamicFieldToJson(object, forProtocol: forProtocol);
    }
    for (final protocol in _hostProtocols) {
      final className = protocol.getClassNameForObject(object);
      if (className == null) continue;
      final host = protocol.getModuleName();
      final wrapped = {
        'className': className.contains('.') ? className : '$host.$className',
        'data': object,
      };
      return forProtocol
          ? _is.SerializationManager.toEncodableForProtocol(wrapped)
          : _is.SerializationManager.toEncodable(wrapped);
    }
    return super.dynamicFieldToJson(object, forProtocol: forProtocol);
  }

  @override
  dynamic deserializeDynamicFieldValue(Object? value) {
    if (value == null) return null;
    if (value is! Map<String, dynamic> || value['className'] is! String) {
      throw FormatException(
        'Dynamic fields are encoded as a Map with className and data, but got '
        '${value.runtimeType} instead.',
      );
    }
    final className = value['className'] as String;
    for (final protocol in _hostProtocols) {
      final host = protocol.getModuleName();
      final hostPrefix = '$host.';
      if (className.startsWith(hostPrefix)) {
        final strippedClassName = className.substring(hostPrefix.length);
        if (strippedClassName.contains('.')) {
          throw FormatException(
            'Dynamic field className must not use multiple prefixes: $className',
          );
        }
        final hostData = Map<String, dynamic>.from(value);
        hostData['className'] = strippedClassName;
        return protocol.deserializeByClassName(hostData);
      }
    }
    if (className.contains('.')) {
      for (final protocol in _hostProtocols) {
        try {
          return protocol.deserializeByClassName(value);
        } on _is.DeserializationClassNameNotFoundException catch (_) {}
      }
    }
    return deserializeByClassName(value);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var protocol = _ijl9ntd6.Protocol();
      var table = protocol is _is.DatabaseSerializationManager
          ? (protocol as _is.DatabaseSerializationManager).getTableForType(t)
          : null;
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _iulmo8pc.AnonAccount:
        return _iulmo8pc.AnonAccount.t;
      case _iepmyrfy.AccountDevice:
        return _iepmyrfy.AccountDevice.t;
      case _igiek2ee.GroupMember:
        return _igiek2ee.GroupMember.t;
      case _ijdcafmt.GroupMemberDevice:
        return _ijdcafmt.GroupMemberDevice.t;
      case _ibp98ugq.GroupOwner:
        return _ibp98ugq.GroupOwner.t;
      case _iju4wcr1.PublicChallenge:
        return _iju4wcr1.PublicChallenge.t;
      case _igkybre3.ShardRouting:
        return _igkybre3.ShardRouting.t;
      case _i97quwy2.ShareGroup:
        return _i97quwy2.ShareGroup.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
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
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
