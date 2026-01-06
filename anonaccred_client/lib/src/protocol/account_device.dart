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

abstract class AccountDevice implements _i1.SerializableModel {
  AccountDevice._({
    this.id,
    required this.accountId,
    required this.deviceSigningPublicKeyHex,
    required this.encryptedDataKey,
    required this.label,
    DateTime? lastActive,
    bool? isRevoked,
  }) : lastActive = lastActive ?? DateTime.now(),
       isRevoked = isRevoked ?? false;

  factory AccountDevice({
    int? id,
    required int accountId,
    required String deviceSigningPublicKeyHex,
    required String encryptedDataKey,
    required String label,
    DateTime? lastActive,
    bool? isRevoked,
  }) = _AccountDeviceImpl;

  factory AccountDevice.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountDevice(
      id: jsonSerialization['id'] as int?,
      accountId: jsonSerialization['accountId'] as int,
      deviceSigningPublicKeyHex:
          jsonSerialization['deviceSigningPublicKeyHex'] as String,
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      label: jsonSerialization['label'] as String,
      lastActive: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastActive'],
      ),
      isRevoked: jsonSerialization['isRevoked'] as bool,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int accountId;

  String deviceSigningPublicKeyHex;

  String encryptedDataKey;

  String label;

  DateTime lastActive;

  bool isRevoked;

  /// Returns a shallow copy of this [AccountDevice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AccountDevice copyWith({
    int? id,
    int? accountId,
    String? deviceSigningPublicKeyHex,
    String? encryptedDataKey,
    String? label,
    DateTime? lastActive,
    bool? isRevoked,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.AccountDevice',
      if (id != null) 'id': id,
      'accountId': accountId,
      'deviceSigningPublicKeyHex': deviceSigningPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'label': label,
      'lastActive': lastActive.toJson(),
      'isRevoked': isRevoked,
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
    int? id,
    required int accountId,
    required String deviceSigningPublicKeyHex,
    required String encryptedDataKey,
    required String label,
    DateTime? lastActive,
    bool? isRevoked,
  }) : super._(
         id: id,
         accountId: accountId,
         deviceSigningPublicKeyHex: deviceSigningPublicKeyHex,
         encryptedDataKey: encryptedDataKey,
         label: label,
         lastActive: lastActive,
         isRevoked: isRevoked,
       );

  /// Returns a shallow copy of this [AccountDevice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AccountDevice copyWith({
    Object? id = _Undefined,
    int? accountId,
    String? deviceSigningPublicKeyHex,
    String? encryptedDataKey,
    String? label,
    DateTime? lastActive,
    bool? isRevoked,
  }) {
    return AccountDevice(
      id: id is int? ? id : this.id,
      accountId: accountId ?? this.accountId,
      deviceSigningPublicKeyHex:
          deviceSigningPublicKeyHex ?? this.deviceSigningPublicKeyHex,
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      label: label ?? this.label,
      lastActive: lastActive ?? this.lastActive,
      isRevoked: isRevoked ?? this.isRevoked,
    );
  }
}
