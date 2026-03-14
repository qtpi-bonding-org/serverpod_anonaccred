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

abstract class RateLimitCounter implements _i1.SerializableModel {
  RateLimitCounter._({required this.count});

  factory RateLimitCounter({required int count}) = _RateLimitCounterImpl;

  factory RateLimitCounter.fromJson(Map<String, dynamic> jsonSerialization) {
    return RateLimitCounter(count: jsonSerialization['count'] as int);
  }

  int count;

  /// Returns a shallow copy of this [RateLimitCounter]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RateLimitCounter copyWith({int? count});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.RateLimitCounter',
      'count': count,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _RateLimitCounterImpl extends RateLimitCounter {
  _RateLimitCounterImpl({required int count}) : super._(count: count);

  /// Returns a shallow copy of this [RateLimitCounter]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RateLimitCounter copyWith({int? count}) {
    return RateLimitCounter(count: count ?? this.count);
  }
}
