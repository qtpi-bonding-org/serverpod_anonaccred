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

abstract class DevicePairingEvent
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  DevicePairingEvent._({
    required this.encryptedDataKey,
    required this.signingKeyHex,
  });

  factory DevicePairingEvent({
    required String encryptedDataKey,
    required String signingKeyHex,
  }) = _DevicePairingEventImpl;

  factory DevicePairingEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return DevicePairingEvent(
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      signingKeyHex: jsonSerialization['signingKeyHex'] as String,
    );
  }

  String encryptedDataKey;

  String signingKeyHex;

  /// Returns a shallow copy of this [DevicePairingEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DevicePairingEvent copyWith({
    String? encryptedDataKey,
    String? signingKeyHex,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.DevicePairingEvent',
      'encryptedDataKey': encryptedDataKey,
      'signingKeyHex': signingKeyHex,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccred.DevicePairingEvent',
      'encryptedDataKey': encryptedDataKey,
      'signingKeyHex': signingKeyHex,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _DevicePairingEventImpl extends DevicePairingEvent {
  _DevicePairingEventImpl({
    required String encryptedDataKey,
    required String signingKeyHex,
  }) : super._(
         encryptedDataKey: encryptedDataKey,
         signingKeyHex: signingKeyHex,
       );

  /// Returns a shallow copy of this [DevicePairingEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DevicePairingEvent copyWith({
    String? encryptedDataKey,
    String? signingKeyHex,
  }) {
    return DevicePairingEvent(
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      signingKeyHex: signingKeyHex ?? this.signingKeyHex,
    );
  }
}
