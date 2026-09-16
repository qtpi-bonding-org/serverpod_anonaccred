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

abstract class AccountCreationResponse
    implements _is.SerializableModel, _is.ProtocolSerialization {
  AccountCreationResponse._({
    required this.ultimateSigningPublicKeyHex,
    required this.encryptedDataKey,
    required this.ultimateEncryptionPublicKeyHex,
    required this.createdAt,
  });

  factory AccountCreationResponse({
    required String ultimateSigningPublicKeyHex,
    required String encryptedDataKey,
    required String ultimateEncryptionPublicKeyHex,
    required DateTime createdAt,
  }) = _AccountCreationResponseImpl;

  factory AccountCreationResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AccountCreationResponse(
      ultimateSigningPublicKeyHex:
          jsonSerialization['ultimateSigningPublicKeyHex'] as String,
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      ultimateEncryptionPublicKeyHex:
          jsonSerialization['ultimateEncryptionPublicKeyHex'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  String ultimateSigningPublicKeyHex;

  String encryptedDataKey;

  String ultimateEncryptionPublicKeyHex;

  DateTime createdAt;

  /// Returns a shallow copy of this [AccountCreationResponse]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AccountCreationResponse copyWith({
    String? ultimateSigningPublicKeyHex,
    String? encryptedDataKey,
    String? ultimateEncryptionPublicKeyHex,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.AccountCreationResponse',
      'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'ultimateEncryptionPublicKeyHex': ultimateEncryptionPublicKeyHex,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.AccountCreationResponse',
      'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'ultimateEncryptionPublicKeyHex': ultimateEncryptionPublicKeyHex,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _AccountCreationResponseImpl extends AccountCreationResponse {
  _AccountCreationResponseImpl({
    required String ultimateSigningPublicKeyHex,
    required String encryptedDataKey,
    required String ultimateEncryptionPublicKeyHex,
    required DateTime createdAt,
  }) : super._(
         ultimateSigningPublicKeyHex: ultimateSigningPublicKeyHex,
         encryptedDataKey: encryptedDataKey,
         ultimateEncryptionPublicKeyHex: ultimateEncryptionPublicKeyHex,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AccountCreationResponse]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AccountCreationResponse copyWith({
    String? ultimateSigningPublicKeyHex,
    String? encryptedDataKey,
    String? ultimateEncryptionPublicKeyHex,
    DateTime? createdAt,
  }) {
    return AccountCreationResponse(
      ultimateSigningPublicKeyHex:
          ultimateSigningPublicKeyHex ?? this.ultimateSigningPublicKeyHex,
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      ultimateEncryptionPublicKeyHex:
          ultimateEncryptionPublicKeyHex ?? this.ultimateEncryptionPublicKeyHex,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
