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
import 'package:serverpod/serverpod.dart' as _is;

abstract class DevicePairingEvent
    implements _is.SerializableModel, _is.ProtocolSerialization {
  DevicePairingEvent._({
    required this.encryptedDataKey,
    required this.signingKeyHex,
    required this.ultimateEncryptionPublicKeyHex,
    required this.ultimateSigningPublicKeyHex,
  });

  factory DevicePairingEvent({
    required String encryptedDataKey,
    required String signingKeyHex,
    required String ultimateEncryptionPublicKeyHex,
    required String ultimateSigningPublicKeyHex,
  }) = _DevicePairingEventImpl;

  factory DevicePairingEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return DevicePairingEvent(
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      signingKeyHex: jsonSerialization['signingKeyHex'] as String,
      ultimateEncryptionPublicKeyHex:
          jsonSerialization['ultimateEncryptionPublicKeyHex'] as String,
      ultimateSigningPublicKeyHex:
          jsonSerialization['ultimateSigningPublicKeyHex'] as String,
    );
  }

  String encryptedDataKey;

  String signingKeyHex;

  String ultimateEncryptionPublicKeyHex;

  String ultimateSigningPublicKeyHex;

  /// Returns a shallow copy of this [DevicePairingEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DevicePairingEvent copyWith({
    String? encryptedDataKey,
    String? signingKeyHex,
    String? ultimateEncryptionPublicKeyHex,
    String? ultimateSigningPublicKeyHex,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.DevicePairingEvent',
      'encryptedDataKey': encryptedDataKey,
      'signingKeyHex': signingKeyHex,
      'ultimateEncryptionPublicKeyHex': ultimateEncryptionPublicKeyHex,
      'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.DevicePairingEvent',
      'encryptedDataKey': encryptedDataKey,
      'signingKeyHex': signingKeyHex,
      'ultimateEncryptionPublicKeyHex': ultimateEncryptionPublicKeyHex,
      'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _DevicePairingEventImpl extends DevicePairingEvent {
  _DevicePairingEventImpl({
    required String encryptedDataKey,
    required String signingKeyHex,
    required String ultimateEncryptionPublicKeyHex,
    required String ultimateSigningPublicKeyHex,
  }) : super._(
         encryptedDataKey: encryptedDataKey,
         signingKeyHex: signingKeyHex,
         ultimateEncryptionPublicKeyHex: ultimateEncryptionPublicKeyHex,
         ultimateSigningPublicKeyHex: ultimateSigningPublicKeyHex,
       );

  /// Returns a shallow copy of this [DevicePairingEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DevicePairingEvent copyWith({
    String? encryptedDataKey,
    String? signingKeyHex,
    String? ultimateEncryptionPublicKeyHex,
    String? ultimateSigningPublicKeyHex,
  }) {
    return DevicePairingEvent(
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      signingKeyHex: signingKeyHex ?? this.signingKeyHex,
      ultimateEncryptionPublicKeyHex:
          ultimateEncryptionPublicKeyHex ?? this.ultimateEncryptionPublicKeyHex,
      ultimateSigningPublicKeyHex:
          ultimateSigningPublicKeyHex ?? this.ultimateSigningPublicKeyHex,
    );
  }
}
