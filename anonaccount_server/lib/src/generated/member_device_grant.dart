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
import 'grant_attestor.dart' as _i2;

abstract class MemberDeviceGrant
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  MemberDeviceGrant._({
    required this.groupMemberId,
    required this.accountDeviceId,
    required this.encryptedDataKey,
    required this.attestorSigningPublicKeyHex,
    required this.attestor,
    required this.attestation,
  });

  factory MemberDeviceGrant({
    required _i1.UuidValue groupMemberId,
    required _i1.UuidValue accountDeviceId,
    required String encryptedDataKey,
    required String attestorSigningPublicKeyHex,
    required _i2.GrantAttestor attestor,
    required String attestation,
  }) = _MemberDeviceGrantImpl;

  factory MemberDeviceGrant.fromJson(Map<String, dynamic> jsonSerialization) {
    return MemberDeviceGrant(
      groupMemberId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['groupMemberId'],
      ),
      accountDeviceId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountDeviceId'],
      ),
      encryptedDataKey: jsonSerialization['encryptedDataKey'] as String,
      attestorSigningPublicKeyHex:
          jsonSerialization['attestorSigningPublicKeyHex'] as String,
      attestor: _i2.GrantAttestor.fromJson(
        (jsonSerialization['attestor'] as String),
      ),
      attestation: jsonSerialization['attestation'] as String,
    );
  }

  _i1.UuidValue groupMemberId;

  _i1.UuidValue accountDeviceId;

  String encryptedDataKey;

  String attestorSigningPublicKeyHex;

  _i2.GrantAttestor attestor;

  String attestation;

  /// Returns a shallow copy of this [MemberDeviceGrant]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MemberDeviceGrant copyWith({
    _i1.UuidValue? groupMemberId,
    _i1.UuidValue? accountDeviceId,
    String? encryptedDataKey,
    String? attestorSigningPublicKeyHex,
    _i2.GrantAttestor? attestor,
    String? attestation,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.MemberDeviceGrant',
      'groupMemberId': groupMemberId.toJson(),
      'accountDeviceId': accountDeviceId.toJson(),
      'encryptedDataKey': encryptedDataKey,
      'attestorSigningPublicKeyHex': attestorSigningPublicKeyHex,
      'attestor': attestor.toJson(),
      'attestation': attestation,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.MemberDeviceGrant',
      'groupMemberId': groupMemberId.toJson(),
      'accountDeviceId': accountDeviceId.toJson(),
      'encryptedDataKey': encryptedDataKey,
      'attestorSigningPublicKeyHex': attestorSigningPublicKeyHex,
      'attestor': attestor.toJson(),
      'attestation': attestation,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MemberDeviceGrantImpl extends MemberDeviceGrant {
  _MemberDeviceGrantImpl({
    required _i1.UuidValue groupMemberId,
    required _i1.UuidValue accountDeviceId,
    required String encryptedDataKey,
    required String attestorSigningPublicKeyHex,
    required _i2.GrantAttestor attestor,
    required String attestation,
  }) : super._(
         groupMemberId: groupMemberId,
         accountDeviceId: accountDeviceId,
         encryptedDataKey: encryptedDataKey,
         attestorSigningPublicKeyHex: attestorSigningPublicKeyHex,
         attestor: attestor,
         attestation: attestation,
       );

  /// Returns a shallow copy of this [MemberDeviceGrant]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MemberDeviceGrant copyWith({
    _i1.UuidValue? groupMemberId,
    _i1.UuidValue? accountDeviceId,
    String? encryptedDataKey,
    String? attestorSigningPublicKeyHex,
    _i2.GrantAttestor? attestor,
    String? attestation,
  }) {
    return MemberDeviceGrant(
      groupMemberId: groupMemberId ?? this.groupMemberId,
      accountDeviceId: accountDeviceId ?? this.accountDeviceId,
      encryptedDataKey: encryptedDataKey ?? this.encryptedDataKey,
      attestorSigningPublicKeyHex:
          attestorSigningPublicKeyHex ?? this.attestorSigningPublicKeyHex,
      attestor: attestor ?? this.attestor,
      attestation: attestation ?? this.attestation,
    );
  }
}
