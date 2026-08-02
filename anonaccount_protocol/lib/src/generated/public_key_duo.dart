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
import 'package:serverpod_serialization/serverpod_serialization.dart' as _i1;

abstract class PublicKeyDuo implements _i1.SerializableModel {
  PublicKeyDuo._({
    required this.signingPublicKeyHex,
    required this.encryptionPublicKeyHex,
  });

  factory PublicKeyDuo({
    required String signingPublicKeyHex,
    required String encryptionPublicKeyHex,
  }) = _PublicKeyDuoImpl;

  factory PublicKeyDuo.fromJson(Map<String, dynamic> jsonSerialization) {
    return PublicKeyDuo(
      signingPublicKeyHex: jsonSerialization['signingPublicKeyHex'] as String,
      encryptionPublicKeyHex:
          jsonSerialization['encryptionPublicKeyHex'] as String,
    );
  }

  String signingPublicKeyHex;

  String encryptionPublicKeyHex;

  /// Returns a shallow copy of this [PublicKeyDuo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PublicKeyDuo copyWith({
    String? signingPublicKeyHex,
    String? encryptionPublicKeyHex,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.PublicKeyDuo',
      'signingPublicKeyHex': signingPublicKeyHex,
      'encryptionPublicKeyHex': encryptionPublicKeyHex,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PublicKeyDuoImpl extends PublicKeyDuo {
  _PublicKeyDuoImpl({
    required String signingPublicKeyHex,
    required String encryptionPublicKeyHex,
  }) : super._(
         signingPublicKeyHex: signingPublicKeyHex,
         encryptionPublicKeyHex: encryptionPublicKeyHex,
       );

  /// Returns a shallow copy of this [PublicKeyDuo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PublicKeyDuo copyWith({
    String? signingPublicKeyHex,
    String? encryptionPublicKeyHex,
  }) {
    return PublicKeyDuo(
      signingPublicKeyHex: signingPublicKeyHex ?? this.signingPublicKeyHex,
      encryptionPublicKeyHex:
          encryptionPublicKeyHex ?? this.encryptionPublicKeyHex,
    );
  }
}
