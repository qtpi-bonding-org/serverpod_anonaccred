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
import 'package:anonaccount_client/src/protocol/protocol.dart' as _i3;

abstract class AccountDevice implements _i1.SerializableModel {
  AccountDevice._({
    this.id,
    required this.anonAccountId,
    this.anonAccount,
    required this.deviceSigningPublicKeyHex,
    required this.encryptedDataKey,
    required this.label,
    DateTime? lastActive,
    bool? isRevoked,
    int? keyEpoch,
  }) : lastActive = lastActive ?? DateTime.now(),
       isRevoked = isRevoked ?? false,
       keyEpoch = keyEpoch ?? 0;

  factory AccountDevice({
    _i1.UuidValue? id,
    required _i1.UuidValue anonAccountId,
    _i2.AnonAccount? anonAccount,
    required String deviceSigningPublicKeyHex,
    required String encryptedDataKey,
    required String label,
    DateTime? lastActive,
    bool? isRevoked,
    int? keyEpoch,
  }) = _AccountDeviceImpl;

  factory AccountDevice.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountDevice(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      anonAccountId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['anonAccountId'],
      ),
      anonAccount: jsonSerialization['anonAccount'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.AnonAccount>(
              jsonSerialization['anonAccount'],
            ),
      deviceSigningPublicKeyHex:
          jsonSerialization['deviceSigningPublicKeyHex'] as String,
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      label: jsonSerialization['label'] as String,
      lastActive: jsonSerialization['lastActive'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastActive']),
      isRevoked: jsonSerialization['isRevoked'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isRevoked']),
      keyEpoch: jsonSerialization['keyEpoch'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue anonAccountId;

  _i2.AnonAccount? anonAccount;

  String deviceSigningPublicKeyHex;

  String encryptedDataKey;

  String label;

  DateTime lastActive;

  bool isRevoked;

  int keyEpoch;

  /// Returns a shallow copy of this [AccountDevice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AccountDevice copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? anonAccountId,
    _i2.AnonAccount? anonAccount,
    String? deviceSigningPublicKeyHex,
    String? encryptedDataKey,
    String? label,
    DateTime? lastActive,
    bool? isRevoked,
    int? keyEpoch,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.AccountDevice',
      if (id != null) 'id': id?.toJson(),
      'anonAccountId': anonAccountId.toJson(),
      if (anonAccount != null) 'anonAccount': anonAccount?.toJson(),
      'deviceSigningPublicKeyHex': deviceSigningPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'label': label,
      'lastActive': lastActive.toJson(),
      'isRevoked': isRevoked,
      'keyEpoch': keyEpoch,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountDeviceImpl extends AccountDevice {
  _AccountDeviceImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue anonAccountId,
    _i2.AnonAccount? anonAccount,
    required String deviceSigningPublicKeyHex,
    required String encryptedDataKey,
    required String label,
    DateTime? lastActive,
    bool? isRevoked,
    int? keyEpoch,
  }) : super._(
         id: id,
         anonAccountId: anonAccountId,
         anonAccount: anonAccount,
         deviceSigningPublicKeyHex: deviceSigningPublicKeyHex,
         encryptedDataKey: encryptedDataKey,
         label: label,
         lastActive: lastActive,
         isRevoked: isRevoked,
         keyEpoch: keyEpoch,
       );

  /// Returns a shallow copy of this [AccountDevice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AccountDevice copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? anonAccountId,
    Object? anonAccount = _Undefined,
    String? deviceSigningPublicKeyHex,
    String? encryptedDataKey,
    String? label,
    DateTime? lastActive,
    bool? isRevoked,
    int? keyEpoch,
  }) {
    return AccountDevice(
      id: id is _i1.UuidValue? ? id : this.id,
      anonAccountId: anonAccountId ?? this.anonAccountId,
      anonAccount: anonAccount is _i2.AnonAccount?
          ? anonAccount
          : this.anonAccount?.copyWith(),
      deviceSigningPublicKeyHex:
          deviceSigningPublicKeyHex ?? this.deviceSigningPublicKeyHex,
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      label: label ?? this.label,
      lastActive: lastActive ?? this.lastActive,
      isRevoked: isRevoked ?? this.isRevoked,
      keyEpoch: keyEpoch ?? this.keyEpoch,
    );
  }
}
