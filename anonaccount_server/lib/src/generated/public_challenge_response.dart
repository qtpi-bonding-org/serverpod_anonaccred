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

abstract class PublicChallengeResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  PublicChallengeResponse._({
    required this.challenge,
    required this.difficulty,
    required this.expiresAt,
  });

  factory PublicChallengeResponse({
    required String challenge,
    required int difficulty,
    required int expiresAt,
  }) = _PublicChallengeResponseImpl;

  factory PublicChallengeResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return PublicChallengeResponse(
      challenge: jsonSerialization['challenge'] as String,
      difficulty: jsonSerialization['difficulty'] as int,
      expiresAt: jsonSerialization['expiresAt'] as int,
    );
  }

  String challenge;

  int difficulty;

  int expiresAt;

  /// Returns a shallow copy of this [PublicChallengeResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PublicChallengeResponse copyWith({
    String? challenge,
    int? difficulty,
    int? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.PublicChallengeResponse',
      'challenge': challenge,
      'difficulty': difficulty,
      'expiresAt': expiresAt,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.PublicChallengeResponse',
      'challenge': challenge,
      'difficulty': difficulty,
      'expiresAt': expiresAt,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PublicChallengeResponseImpl extends PublicChallengeResponse {
  _PublicChallengeResponseImpl({
    required String challenge,
    required int difficulty,
    required int expiresAt,
  }) : super._(
         challenge: challenge,
         difficulty: difficulty,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [PublicChallengeResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PublicChallengeResponse copyWith({
    String? challenge,
    int? difficulty,
    int? expiresAt,
  }) {
    return PublicChallengeResponse(
      challenge: challenge ?? this.challenge,
      difficulty: difficulty ?? this.difficulty,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
