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
import 'group_member.dart' as _i2;
import 'account_device.dart' as _i3;
import 'package:anonaccount_client/src/protocol/protocol.dart' as _i4;

abstract class GroupMemberDevice implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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
