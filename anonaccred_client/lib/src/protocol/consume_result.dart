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

abstract class ConsumeResult implements _i1.SerializableModel {
  ConsumeResult._({
    required this.success,
    required this.availableBalance,
    this.errorMessage,
  });

  factory ConsumeResult({
    required bool success,
    required double availableBalance,
    String? errorMessage,
  }) = _ConsumeResultImpl;

  factory ConsumeResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return ConsumeResult(
      success: jsonSerialization['success'] as bool,
      availableBalance: (jsonSerialization['availableBalance'] as num)
          .toDouble(),
      errorMessage: jsonSerialization['errorMessage'] as String?,
    );
  }

  bool success;

  double availableBalance;

  String? errorMessage;

  /// Returns a shallow copy of this [ConsumeResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ConsumeResult copyWith({
    bool? success,
    double? availableBalance,
    String? errorMessage,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.ConsumeResult',
      'success': success,
      'availableBalance': availableBalance,
      if (errorMessage != null) 'errorMessage': errorMessage,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ConsumeResultImpl extends ConsumeResult {
  _ConsumeResultImpl({
    required bool success,
    required double availableBalance,
    String? errorMessage,
  }) : super._(
         success: success,
         availableBalance: availableBalance,
         errorMessage: errorMessage,
       );

  /// Returns a shallow copy of this [ConsumeResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ConsumeResult copyWith({
    bool? success,
    double? availableBalance,
    Object? errorMessage = _Undefined,
  }) {
    return ConsumeResult(
      success: success ?? this.success,
      availableBalance: availableBalance ?? this.availableBalance,
      errorMessage: errorMessage is String? ? errorMessage : this.errorMessage,
    );
  }
}
