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
import 'public_challenge.dart' as _i15;
import 'public_challenge_response.dart' as _i16;
import 'rate_limit_counter.dart' as _i17;
import 'package:anonaccount_server/src/generated/account_device.dart' as _i18;
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
export 'public_challenge.dart';
export 'public_challenge_response.dart';
export 'rate_limit_counter.dart';

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
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'account_device_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'accountUuid',
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
      ],
      foreignKeys: [],
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
          indexName: 'auth_lookup_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'deviceSigningPublicKeyHex',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'isRevoked',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'account_devices_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'accountUuid',
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
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'anon_account_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'accountUuid',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
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
          name: 'ultimatePublicKey',
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
          indexName: 'ultimate_key_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'ultimatePublicKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'account_uuid_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'accountUuid',
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
    if (t == _i15.PublicChallenge) {
      return _i15.PublicChallenge.fromJson(data) as T;
    }
    if (t == _i16.PublicChallengeResponse) {
      return _i16.PublicChallengeResponse.fromJson(data) as T;
    }
    if (t == _i17.RateLimitCounter) {
      return _i17.RateLimitCounter.fromJson(data) as T;
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
    if (t == _i1.getType<_i15.PublicChallenge?>()) {
      return (data != null ? _i15.PublicChallenge.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.PublicChallengeResponse?>()) {
      return (data != null ? _i16.PublicChallengeResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i17.RateLimitCounter?>()) {
      return (data != null ? _i17.RateLimitCounter.fromJson(data) : null) as T;
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
    if (t == List<_i18.AccountDevice>) {
      return (data as List)
              .map((e) => deserialize<_i18.AccountDevice>(e))
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
      _i15.PublicChallenge => 'PublicChallenge',
      _i16.PublicChallengeResponse => 'PublicChallengeResponse',
      _i17.RateLimitCounter => 'RateLimitCounter',
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
      case _i15.PublicChallenge():
        return 'PublicChallenge';
      case _i16.PublicChallengeResponse():
        return 'PublicChallengeResponse';
      case _i17.RateLimitCounter():
        return 'RateLimitCounter';
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
    if (dataClassName == 'PublicChallenge') {
      return deserialize<_i15.PublicChallenge>(data['data']);
    }
    if (dataClassName == 'PublicChallengeResponse') {
      return deserialize<_i16.PublicChallengeResponse>(data['data']);
    }
    if (dataClassName == 'RateLimitCounter') {
      return deserialize<_i17.RateLimitCounter>(data['data']);
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
      case _i15.PublicChallenge:
        return _i15.PublicChallenge.t;
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
