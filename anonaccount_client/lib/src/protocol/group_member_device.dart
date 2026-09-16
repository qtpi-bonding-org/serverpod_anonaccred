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
import 'package:anonaccount_client/src/protocol/protocol.dart' as _iki990kh;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'account_device.dart' as _iepmyrfy;
import 'group_member.dart' as _igiek2ee;

abstract class GroupMemberDevice
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    _isc.UuidValue? id,
    required _isc.UuidValue groupMemberId,
    _igiek2ee.GroupMember? groupMember,
    required _isc.UuidValue accountDeviceId,
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
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      groupMemberId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['groupMemberId'],
      ),
      groupMember: jsonSerialization['groupMember'] == null
          ? null
          : _iki990kh.Protocol().deserialize<_igiek2ee.GroupMember>(
              jsonSerialization['groupMember'],
            ),
      accountDeviceId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountDeviceId'],
      ),
      accountDevice: jsonSerialization['accountDevice'] == null
          ? null
          : _iki990kh.Protocol().deserialize<_iepmyrfy.AccountDevice>(
              jsonSerialization['accountDevice'],
            ),
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      addedByAttestorPublicKeyHex:
          jsonSerialization['addedByAttestorPublicKeyHex'] as String,
      addedByAttestation: jsonSerialization['addedByAttestation'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      isRevoked: jsonSerialization['isRevoked'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isRevoked']),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
      keyEpoch: jsonSerialization['keyEpoch'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue groupMemberId;

  _igiek2ee.GroupMember? groupMember;

  _isc.UuidValue accountDeviceId;

  _iepmyrfy.AccountDevice? accountDevice;

  String encryptedDataKey;

  String addedByAttestorPublicKeyHex;

  String addedByAttestation;

  DateTime createdAt;

  bool isRevoked;

  DateTime? revokedAt;

  int keyEpoch;

  /// Returns a shallow copy of this [GroupMemberDevice]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  GroupMemberDevice copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? groupMemberId,
    _igiek2ee.GroupMember? groupMember,
    _isc.UuidValue? accountDeviceId,
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GroupMemberDeviceImpl extends GroupMemberDevice {
  _GroupMemberDeviceImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue groupMemberId,
    _igiek2ee.GroupMember? groupMember,
    required _isc.UuidValue accountDeviceId,
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
  @_isc.useResult
  @override
  GroupMemberDevice copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? groupMemberId,
    Object? groupMember = _Undefined,
    _isc.UuidValue? accountDeviceId,
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
      id: id is _isc.UuidValue? ? id : this.id,
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
