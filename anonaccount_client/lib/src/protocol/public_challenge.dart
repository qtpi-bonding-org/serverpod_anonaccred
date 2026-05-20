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

abstract class PublicChallenge implements _i1.SerializableModel {
  PublicChallenge._({
    this.id,
    required this.challenge,
    required this.expiresAt,
  });

  factory PublicChallenge({
    int? id,
    required String challenge,
    required DateTime expiresAt,
  }) = _PublicChallengeImpl;

  factory PublicChallenge.fromJson(Map<String, dynamic> jsonSerialization) {
    return PublicChallenge(
      id: jsonSerialization['id'] as int?,
      challenge: jsonSerialization['challenge'] as String,
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String challenge;

  DateTime expiresAt;

  /// Returns a shallow copy of this [PublicChallenge]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PublicChallenge copyWith({
    int? id,
    String? challenge,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.PublicChallenge',
      if (id != null) 'id': id,
      'challenge': challenge,
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PublicChallengeImpl extends PublicChallenge {
  _PublicChallengeImpl({
    int? id,
    required String challenge,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         challenge: challenge,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [PublicChallenge]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PublicChallenge copyWith({
    Object? id = _Undefined,
    String? challenge,
    DateTime? expiresAt,
  }) {
    return PublicChallenge(
      id: id is int? ? id : this.id,
      challenge: challenge ?? this.challenge,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
