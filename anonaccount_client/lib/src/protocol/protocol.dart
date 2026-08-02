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
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'account.dart' as _i2;
import 'account_creation_response.dart' as _i3;
import 'account_device.dart' as _i4;
import 'anonaccount_exception.dart' as _i5;
import 'authentication_exception.dart' as _i6;
import 'authentication_result.dart' as _i7;
import 'device_pairing_event.dart' as _i8;
import 'device_pairing_info.dart' as _i9;
import 'encrypted_data_key_response.dart' as _i10;
import 'grant_attestor.dart' as _i11;
import 'grant_member_device_result.dart' as _i12;
import 'group_member.dart' as _i13;
import 'group_member_device.dart' as _i14;
import 'group_member_role.dart' as _i15;
import 'group_membership_view.dart' as _i16;
import 'group_owner.dart' as _i17;
import 'member_device_grant.dart' as _i18;
import 'member_device_grant_outcome.dart' as _i19;
import 'public_challenge.dart' as _i20;
import 'public_challenge_response.dart' as _i21;
import 'rate_limit_counter.dart' as _i22;
import 'shard_routing.dart' as _i23;
import 'share_group.dart' as _i24;
import 'package:anonaccount_client/src/protocol/account_device.dart' as _i25;
import 'package:anonaccount_client/src/protocol/group_membership_view.dart'
    as _i26;
import 'package:anonaccount_client/src/protocol/group_member.dart' as _i27;
import 'package:anonaccount_client/src/protocol/member_device_grant.dart'
    as _i28;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i29;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i30;
import 'package:anonaccount_protocol/anonaccount_protocol.dart' as _i31;
export 'account.dart';
export 'account_creation_response.dart';
export 'account_device.dart';
export 'anonaccount_exception.dart';
export 'authentication_exception.dart';
export 'authentication_result.dart';
export 'device_pairing_event.dart';
export 'device_pairing_info.dart';
export 'encrypted_data_key_response.dart';
export 'grant_attestor.dart';
export 'grant_member_device_result.dart';
export 'group_member.dart';
export 'group_member_device.dart';
export 'group_member_role.dart';
export 'group_membership_view.dart';
export 'group_owner.dart';
export 'member_device_grant.dart';
export 'member_device_grant_outcome.dart';
export 'public_challenge.dart';
export 'public_challenge_response.dart';
export 'rate_limit_counter.dart';
export 'shard_routing.dart';
export 'share_group.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

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

    if (t == _i2.AnonAccount) {
      return _i2.AnonAccount.fromJson(data) as T;
    }
    if (t == _i3.AccountCreationResponse) {
      return _i3.AccountCreationResponse.fromJson(data) as T;
    }
    if (t == _i4.AccountDevice) {
      return _i4.AccountDevice.fromJson(data) as T;
    }
    if (t == _i5.AnonAccountException) {
      return _i5.AnonAccountException.fromJson(data) as T;
    }
    if (t == _i6.AuthenticationException) {
      return _i6.AuthenticationException.fromJson(data) as T;
    }
    if (t == _i7.AuthenticationResult) {
      return _i7.AuthenticationResult.fromJson(data) as T;
    }
    if (t == _i8.DevicePairingEvent) {
      return _i8.DevicePairingEvent.fromJson(data) as T;
    }
    if (t == _i9.DevicePairingInfo) {
      return _i9.DevicePairingInfo.fromJson(data) as T;
    }
    if (t == _i10.EncryptedDataKeyResponse) {
      return _i10.EncryptedDataKeyResponse.fromJson(data) as T;
    }
    if (t == _i11.GrantAttestor) {
      return _i11.GrantAttestor.fromJson(data) as T;
    }
    if (t == _i12.GrantMemberDeviceResult) {
      return _i12.GrantMemberDeviceResult.fromJson(data) as T;
    }
    if (t == _i13.GroupMember) {
      return _i13.GroupMember.fromJson(data) as T;
    }
    if (t == _i14.GroupMemberDevice) {
      return _i14.GroupMemberDevice.fromJson(data) as T;
    }
    if (t == _i15.GroupMemberRole) {
      return _i15.GroupMemberRole.fromJson(data) as T;
    }
    if (t == _i16.GroupMembershipView) {
      return _i16.GroupMembershipView.fromJson(data) as T;
    }
    if (t == _i17.GroupOwner) {
      return _i17.GroupOwner.fromJson(data) as T;
    }
    if (t == _i18.MemberDeviceGrant) {
      return _i18.MemberDeviceGrant.fromJson(data) as T;
    }
    if (t == _i19.MemberDeviceGrantOutcome) {
      return _i19.MemberDeviceGrantOutcome.fromJson(data) as T;
    }
    if (t == _i20.PublicChallenge) {
      return _i20.PublicChallenge.fromJson(data) as T;
    }
    if (t == _i21.PublicChallengeResponse) {
      return _i21.PublicChallengeResponse.fromJson(data) as T;
    }
    if (t == _i22.RateLimitCounter) {
      return _i22.RateLimitCounter.fromJson(data) as T;
    }
    if (t == _i23.ShardRouting) {
      return _i23.ShardRouting.fromJson(data) as T;
    }
    if (t == _i24.ShareGroup) {
      return _i24.ShareGroup.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AnonAccount?>()) {
      return (data != null ? _i2.AnonAccount.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.AccountCreationResponse?>()) {
      return (data != null ? _i3.AccountCreationResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i4.AccountDevice?>()) {
      return (data != null ? _i4.AccountDevice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.AnonAccountException?>()) {
      return (data != null ? _i5.AnonAccountException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i6.AuthenticationException?>()) {
      return (data != null ? _i6.AuthenticationException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i7.AuthenticationResult?>()) {
      return (data != null ? _i7.AuthenticationResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i8.DevicePairingEvent?>()) {
      return (data != null ? _i8.DevicePairingEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.DevicePairingInfo?>()) {
      return (data != null ? _i9.DevicePairingInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.EncryptedDataKeyResponse?>()) {
      return (data != null
              ? _i10.EncryptedDataKeyResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i11.GrantAttestor?>()) {
      return (data != null ? _i11.GrantAttestor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.GrantMemberDeviceResult?>()) {
      return (data != null ? _i12.GrantMemberDeviceResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i13.GroupMember?>()) {
      return (data != null ? _i13.GroupMember.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.GroupMemberDevice?>()) {
      return (data != null ? _i14.GroupMemberDevice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.GroupMemberRole?>()) {
      return (data != null ? _i15.GroupMemberRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.GroupMembershipView?>()) {
      return (data != null ? _i16.GroupMembershipView.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i17.GroupOwner?>()) {
      return (data != null ? _i17.GroupOwner.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.MemberDeviceGrant?>()) {
      return (data != null ? _i18.MemberDeviceGrant.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.MemberDeviceGrantOutcome?>()) {
      return (data != null
              ? _i19.MemberDeviceGrantOutcome.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i20.PublicChallenge?>()) {
      return (data != null ? _i20.PublicChallenge.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.PublicChallengeResponse?>()) {
      return (data != null ? _i21.PublicChallengeResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i22.RateLimitCounter?>()) {
      return (data != null ? _i22.RateLimitCounter.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.ShardRouting?>()) {
      return (data != null ? _i23.ShardRouting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.ShareGroup?>()) {
      return (data != null ? _i24.ShareGroup.fromJson(data) : null) as T;
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
    if (t == List<_i19.MemberDeviceGrantOutcome>) {
      return (data as List)
              .map((e) => deserialize<_i19.MemberDeviceGrantOutcome>(e))
              .toList()
          as T;
    }
    if (t == List<_i25.AccountDevice>) {
      return (data as List)
              .map((e) => deserialize<_i25.AccountDevice>(e))
              .toList()
          as T;
    }
    if (t == List<_i26.GroupMembershipView>) {
      return (data as List)
              .map((e) => deserialize<_i26.GroupMembershipView>(e))
              .toList()
          as T;
    }
    if (t == List<_i27.GroupMember>) {
      return (data as List)
              .map((e) => deserialize<_i27.GroupMember>(e))
              .toList()
          as T;
    }
    if (t == List<_i28.MemberDeviceGrant>) {
      return (data as List)
              .map((e) => deserialize<_i28.MemberDeviceGrant>(e))
              .toList()
          as T;
    }
    try {
      return _i29.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i30.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i31.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AnonAccount => 'AnonAccount',
      _i3.AccountCreationResponse => 'AccountCreationResponse',
      _i4.AccountDevice => 'AccountDevice',
      _i5.AnonAccountException => 'AnonAccountException',
      _i6.AuthenticationException => 'AuthenticationException',
      _i7.AuthenticationResult => 'AuthenticationResult',
      _i8.DevicePairingEvent => 'DevicePairingEvent',
      _i9.DevicePairingInfo => 'DevicePairingInfo',
      _i10.EncryptedDataKeyResponse => 'EncryptedDataKeyResponse',
      _i11.GrantAttestor => 'GrantAttestor',
      _i12.GrantMemberDeviceResult => 'GrantMemberDeviceResult',
      _i13.GroupMember => 'GroupMember',
      _i14.GroupMemberDevice => 'GroupMemberDevice',
      _i15.GroupMemberRole => 'GroupMemberRole',
      _i16.GroupMembershipView => 'GroupMembershipView',
      _i17.GroupOwner => 'GroupOwner',
      _i18.MemberDeviceGrant => 'MemberDeviceGrant',
      _i19.MemberDeviceGrantOutcome => 'MemberDeviceGrantOutcome',
      _i20.PublicChallenge => 'PublicChallenge',
      _i21.PublicChallengeResponse => 'PublicChallengeResponse',
      _i22.RateLimitCounter => 'RateLimitCounter',
      _i23.ShardRouting => 'ShardRouting',
      _i24.ShareGroup => 'ShareGroup',
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
      case _i2.AnonAccount():
        return 'AnonAccount';
      case _i3.AccountCreationResponse():
        return 'AccountCreationResponse';
      case _i4.AccountDevice():
        return 'AccountDevice';
      case _i5.AnonAccountException():
        return 'AnonAccountException';
      case _i6.AuthenticationException():
        return 'AuthenticationException';
      case _i7.AuthenticationResult():
        return 'AuthenticationResult';
      case _i8.DevicePairingEvent():
        return 'DevicePairingEvent';
      case _i9.DevicePairingInfo():
        return 'DevicePairingInfo';
      case _i10.EncryptedDataKeyResponse():
        return 'EncryptedDataKeyResponse';
      case _i11.GrantAttestor():
        return 'GrantAttestor';
      case _i12.GrantMemberDeviceResult():
        return 'GrantMemberDeviceResult';
      case _i13.GroupMember():
        return 'GroupMember';
      case _i14.GroupMemberDevice():
        return 'GroupMemberDevice';
      case _i15.GroupMemberRole():
        return 'GroupMemberRole';
      case _i16.GroupMembershipView():
        return 'GroupMembershipView';
      case _i17.GroupOwner():
        return 'GroupOwner';
      case _i18.MemberDeviceGrant():
        return 'MemberDeviceGrant';
      case _i19.MemberDeviceGrantOutcome():
        return 'MemberDeviceGrantOutcome';
      case _i20.PublicChallenge():
        return 'PublicChallenge';
      case _i21.PublicChallengeResponse():
        return 'PublicChallengeResponse';
      case _i22.RateLimitCounter():
        return 'RateLimitCounter';
      case _i23.ShardRouting():
        return 'ShardRouting';
      case _i24.ShareGroup():
        return 'ShareGroup';
    }
    className = _i29.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i30.Protocol().getClassNameForObject(data);
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
      return deserialize<_i2.AnonAccount>(data['data']);
    }
    if (dataClassName == 'AccountCreationResponse') {
      return deserialize<_i3.AccountCreationResponse>(data['data']);
    }
    if (dataClassName == 'AccountDevice') {
      return deserialize<_i4.AccountDevice>(data['data']);
    }
    if (dataClassName == 'AnonAccountException') {
      return deserialize<_i5.AnonAccountException>(data['data']);
    }
    if (dataClassName == 'AuthenticationException') {
      return deserialize<_i6.AuthenticationException>(data['data']);
    }
    if (dataClassName == 'AuthenticationResult') {
      return deserialize<_i7.AuthenticationResult>(data['data']);
    }
    if (dataClassName == 'DevicePairingEvent') {
      return deserialize<_i8.DevicePairingEvent>(data['data']);
    }
    if (dataClassName == 'DevicePairingInfo') {
      return deserialize<_i9.DevicePairingInfo>(data['data']);
    }
    if (dataClassName == 'EncryptedDataKeyResponse') {
      return deserialize<_i10.EncryptedDataKeyResponse>(data['data']);
    }
    if (dataClassName == 'GrantAttestor') {
      return deserialize<_i11.GrantAttestor>(data['data']);
    }
    if (dataClassName == 'GrantMemberDeviceResult') {
      return deserialize<_i12.GrantMemberDeviceResult>(data['data']);
    }
    if (dataClassName == 'GroupMember') {
      return deserialize<_i13.GroupMember>(data['data']);
    }
    if (dataClassName == 'GroupMemberDevice') {
      return deserialize<_i14.GroupMemberDevice>(data['data']);
    }
    if (dataClassName == 'GroupMemberRole') {
      return deserialize<_i15.GroupMemberRole>(data['data']);
    }
    if (dataClassName == 'GroupMembershipView') {
      return deserialize<_i16.GroupMembershipView>(data['data']);
    }
    if (dataClassName == 'GroupOwner') {
      return deserialize<_i17.GroupOwner>(data['data']);
    }
    if (dataClassName == 'MemberDeviceGrant') {
      return deserialize<_i18.MemberDeviceGrant>(data['data']);
    }
    if (dataClassName == 'MemberDeviceGrantOutcome') {
      return deserialize<_i19.MemberDeviceGrantOutcome>(data['data']);
    }
    if (dataClassName == 'PublicChallenge') {
      return deserialize<_i20.PublicChallenge>(data['data']);
    }
    if (dataClassName == 'PublicChallengeResponse') {
      return deserialize<_i21.PublicChallengeResponse>(data['data']);
    }
    if (dataClassName == 'RateLimitCounter') {
      return deserialize<_i22.RateLimitCounter>(data['data']);
    }
    if (dataClassName == 'ShardRouting') {
      return deserialize<_i23.ShardRouting>(data['data']);
    }
    if (dataClassName == 'ShareGroup') {
      return deserialize<_i24.ShareGroup>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i29.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i30.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

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
      return _i29.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i30.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
