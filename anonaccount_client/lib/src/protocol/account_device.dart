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
import 'account.dart' as _iulmo8pc;

abstract class AccountDevice
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AccountDevice._({
    this.id,
    required this.anonAccountId,
    this.anonAccount,
    required this.deviceSigningPublicKeyHex,
    required this.deviceEncryptionPublicKeyHex,
    required this.encryptedDataKey,
    required this.label,
    required this.addedByAttestorPublicKeyHex,
    required this.addedByAttestation,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isRevoked,
    this.revokedAt,
    int? keyEpoch,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastActive = lastActive ?? DateTime.now(),
       isRevoked = isRevoked ?? false,
       keyEpoch = keyEpoch ?? 0;

  factory AccountDevice({
    _isc.UuidValue? id,
    required _isc.UuidValue anonAccountId,
    _iulmo8pc.AnonAccount? anonAccount,
    required String deviceSigningPublicKeyHex,
    required String deviceEncryptionPublicKeyHex,
    required String encryptedDataKey,
    required String label,
    required String addedByAttestorPublicKeyHex,
    required String addedByAttestation,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isRevoked,
    DateTime? revokedAt,
    int? keyEpoch,
  }) = _AccountDeviceImpl;

  factory AccountDevice.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountDevice(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      anonAccountId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['anonAccountId'],
      ),
      anonAccount: jsonSerialization['anonAccount'] == null
          ? null
          : _iki990kh.Protocol().deserialize<_iulmo8pc.AnonAccount>(
              jsonSerialization['anonAccount'],
            ),
      deviceSigningPublicKeyHex:
          jsonSerialization['deviceSigningPublicKeyHex'] as String,
      deviceEncryptionPublicKeyHex:
          jsonSerialization['deviceEncryptionPublicKeyHex'] as String,
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      label: jsonSerialization['label'] as String,
      addedByAttestorPublicKeyHex:
          jsonSerialization['addedByAttestorPublicKeyHex'] as String,
      addedByAttestation: jsonSerialization['addedByAttestation'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      lastActive: jsonSerialization['lastActive'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastActive'],
            ),
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

  _isc.UuidValue anonAccountId;

  _iulmo8pc.AnonAccount? anonAccount;

  String deviceSigningPublicKeyHex;

  String deviceEncryptionPublicKeyHex;

  String encryptedDataKey;

  String label;

  String addedByAttestorPublicKeyHex;

  String addedByAttestation;

  DateTime createdAt;

  DateTime lastActive;

  bool isRevoked;

  DateTime? revokedAt;

  int keyEpoch;

  /// Returns a shallow copy of this [AccountDevice]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AccountDevice copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? anonAccountId,
    _iulmo8pc.AnonAccount? anonAccount,
    String? deviceSigningPublicKeyHex,
    String? deviceEncryptionPublicKeyHex,
    String? encryptedDataKey,
    String? label,
    String? addedByAttestorPublicKeyHex,
    String? addedByAttestation,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isRevoked,
    DateTime? revokedAt,
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
      'deviceEncryptionPublicKeyHex': deviceEncryptionPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'label': label,
      'addedByAttestorPublicKeyHex': addedByAttestorPublicKeyHex,
      'addedByAttestation': addedByAttestation,
      'createdAt': createdAt.toJson(),
      'lastActive': lastActive.toJson(),
      'isRevoked': isRevoked,
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      'keyEpoch': keyEpoch,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.AccountDevice',
      if (id != null) 'id': id?.toJson(),
      'anonAccountId': anonAccountId.toJson(),
      if (anonAccount != null) 'anonAccount': anonAccount?.toJsonForProtocol(),
      'deviceSigningPublicKeyHex': deviceSigningPublicKeyHex,
      'deviceEncryptionPublicKeyHex': deviceEncryptionPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'label': label,
      'addedByAttestorPublicKeyHex': addedByAttestorPublicKeyHex,
      'addedByAttestation': addedByAttestation,
      'createdAt': createdAt.toJson(),
      'lastActive': lastActive.toJson(),
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

class _AccountDeviceImpl extends AccountDevice {
  _AccountDeviceImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue anonAccountId,
    _iulmo8pc.AnonAccount? anonAccount,
    required String deviceSigningPublicKeyHex,
    required String deviceEncryptionPublicKeyHex,
    required String encryptedDataKey,
    required String label,
    required String addedByAttestorPublicKeyHex,
    required String addedByAttestation,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isRevoked,
    DateTime? revokedAt,
    int? keyEpoch,
  }) : super._(
         id: id,
         anonAccountId: anonAccountId,
         anonAccount: anonAccount,
         deviceSigningPublicKeyHex: deviceSigningPublicKeyHex,
         deviceEncryptionPublicKeyHex: deviceEncryptionPublicKeyHex,
         encryptedDataKey: encryptedDataKey,
         label: label,
         addedByAttestorPublicKeyHex: addedByAttestorPublicKeyHex,
         addedByAttestation: addedByAttestation,
         createdAt: createdAt,
         lastActive: lastActive,
         isRevoked: isRevoked,
         revokedAt: revokedAt,
         keyEpoch: keyEpoch,
       );

  /// Returns a shallow copy of this [AccountDevice]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AccountDevice copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? anonAccountId,
    Object? anonAccount = _Undefined,
    String? deviceSigningPublicKeyHex,
    String? deviceEncryptionPublicKeyHex,
    String? encryptedDataKey,
    String? label,
    String? addedByAttestorPublicKeyHex,
    String? addedByAttestation,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isRevoked,
    Object? revokedAt = _Undefined,
    int? keyEpoch,
  }) {
    return AccountDevice(
      id: id is _isc.UuidValue? ? id : this.id,
      anonAccountId: anonAccountId ?? this.anonAccountId,
      anonAccount: anonAccount is _iulmo8pc.AnonAccount?
          ? anonAccount
          : this.anonAccount?.copyWith(),
      deviceSigningPublicKeyHex:
          deviceSigningPublicKeyHex ?? this.deviceSigningPublicKeyHex,
      deviceEncryptionPublicKeyHex:
          deviceEncryptionPublicKeyHex ?? this.deviceEncryptionPublicKeyHex,
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      label: label ?? this.label,
      addedByAttestorPublicKeyHex:
          addedByAttestorPublicKeyHex ?? this.addedByAttestorPublicKeyHex,
      addedByAttestation: addedByAttestation ?? this.addedByAttestation,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      isRevoked: isRevoked ?? this.isRevoked,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
      keyEpoch: keyEpoch ?? this.keyEpoch,
    );
  }
}
