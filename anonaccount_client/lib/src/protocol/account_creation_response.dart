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

abstract class AccountCreationResponse implements _i1.SerializableModel {
  AccountCreationResponse._({
    required this.ultimateSigningPublicKeyHex,
    required this.encryptedDataKey,
    required this.ultimatePublicKey,
    required this.createdAt,
  });

  factory AccountCreationResponse({
    required String ultimateSigningPublicKeyHex,
    required String encryptedDataKey,
    required String ultimatePublicKey,
    required DateTime createdAt,
  }) = _AccountCreationResponseImpl;

  factory AccountCreationResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AccountCreationResponse(
      ultimateSigningPublicKeyHex:
          jsonSerialization['ultimateSigningPublicKeyHex'] as String,
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      ultimatePublicKey: jsonSerialization['ultimatePublicKey'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  String ultimateSigningPublicKeyHex;

  String encryptedDataKey;

  String ultimatePublicKey;

  DateTime createdAt;

  /// Returns a shallow copy of this [AccountCreationResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AccountCreationResponse copyWith({
    String? ultimateSigningPublicKeyHex,
    String? encryptedDataKey,
    String? ultimatePublicKey,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.AccountCreationResponse',
      'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
      'encryptedDataKey': encryptedDataKey,
      'ultimatePublicKey': ultimatePublicKey,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AccountCreationResponseImpl extends AccountCreationResponse {
  _AccountCreationResponseImpl({
    required String ultimateSigningPublicKeyHex,
    required String encryptedDataKey,
    required String ultimatePublicKey,
    required DateTime createdAt,
  }) : super._(
         ultimateSigningPublicKeyHex: ultimateSigningPublicKeyHex,
         encryptedDataKey: encryptedDataKey,
         ultimatePublicKey: ultimatePublicKey,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AccountCreationResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AccountCreationResponse copyWith({
    String? ultimateSigningPublicKeyHex,
    String? encryptedDataKey,
    String? ultimatePublicKey,
    DateTime? createdAt,
  }) {
    return AccountCreationResponse(
      ultimateSigningPublicKeyHex:
          ultimateSigningPublicKeyHex ?? this.ultimateSigningPublicKeyHex,
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      ultimatePublicKey: ultimatePublicKey ?? this.ultimatePublicKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
