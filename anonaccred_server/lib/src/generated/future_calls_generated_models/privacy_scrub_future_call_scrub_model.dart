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

abstract class PrivacyScrubFutureCallScrubModel
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  PrivacyScrubFutureCallScrubModel._({required this.retentionDays});

  factory PrivacyScrubFutureCallScrubModel({required int retentionDays}) =
      _PrivacyScrubFutureCallScrubModelImpl;

  factory PrivacyScrubFutureCallScrubModel.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return PrivacyScrubFutureCallScrubModel(
      retentionDays: jsonSerialization['retentionDays'] as int,
    );
  }

  int retentionDays;

  /// Returns a shallow copy of this [PrivacyScrubFutureCallScrubModel]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PrivacyScrubFutureCallScrubModel copyWith({int? retentionDays});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.PrivacyScrubFutureCallScrubModel',
      'retentionDays': retentionDays,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PrivacyScrubFutureCallScrubModelImpl
    extends PrivacyScrubFutureCallScrubModel {
  _PrivacyScrubFutureCallScrubModelImpl({required int retentionDays})
    : super._(retentionDays: retentionDays);

  /// Returns a shallow copy of this [PrivacyScrubFutureCallScrubModel]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PrivacyScrubFutureCallScrubModel copyWith({int? retentionDays}) {
    return PrivacyScrubFutureCallScrubModel(
      retentionDays: retentionDays ?? this.retentionDays,
    );
  }
}
