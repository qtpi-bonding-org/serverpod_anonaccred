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

/// Response model for encrypted data key retrieval.
///
/// Contains only the encrypted blob — callers must decrypt with their private key.
/// Used by both retrieveEncryptedDataKey (device path) and recoverEncryptedDataKey (ultimate path).
abstract class EncryptedDataKeyResponse implements _i1.SerializableModel {
  EncryptedDataKeyResponse._({required this.encryptedDataKey});

  factory EncryptedDataKeyResponse({required String encryptedDataKey}) =
      _EncryptedDataKeyResponseImpl;

  factory EncryptedDataKeyResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return EncryptedDataKeyResponse(
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
    );
  }

  String encryptedDataKey;

  /// Returns a shallow copy of this [EncryptedDataKeyResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EncryptedDataKeyResponse copyWith({String? encryptedDataKey});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.EncryptedDataKeyResponse',
      'encryptedDataKey': encryptedDataKey,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _EncryptedDataKeyResponseImpl extends EncryptedDataKeyResponse {
  _EncryptedDataKeyResponseImpl({required String encryptedDataKey})
    : super._(encryptedDataKey: encryptedDataKey);

  /// Returns a shallow copy of this [EncryptedDataKeyResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EncryptedDataKeyResponse copyWith({String? encryptedDataKey}) {
    return EncryptedDataKeyResponse(
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
    );
  }
}
