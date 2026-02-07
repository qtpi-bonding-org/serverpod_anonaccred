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

/// Device pairing info returned when polling for registration completion.
///
/// Contains only the encrypted data key blob - no account identifiers exposed.
/// Device B uses this to complete pairing after Device A registers it.
abstract class DevicePairingInfo implements _i1.SerializableModel {
  DevicePairingInfo._({required this.encryptedDataKey});

  factory DevicePairingInfo({required String encryptedDataKey}) =
      _DevicePairingInfoImpl;

  factory DevicePairingInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return DevicePairingInfo(
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
    );
  }

  /// SDK encrypted with device's RSA public key (base64 encoded).
  /// Only the device with the matching private key can decrypt this.
  String encryptedDataKey;

  /// Returns a shallow copy of this [DevicePairingInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DevicePairingInfo copyWith({String? encryptedDataKey});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.DevicePairingInfo',
      'encryptedDataKey': encryptedDataKey,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _DevicePairingInfoImpl extends DevicePairingInfo {
  _DevicePairingInfoImpl({required String encryptedDataKey})
    : super._(encryptedDataKey: encryptedDataKey);

  /// Returns a shallow copy of this [DevicePairingInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DevicePairingInfo copyWith({String? encryptedDataKey}) {
    return DevicePairingInfo(
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
    );
  }
}
