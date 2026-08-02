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
import 'member_device_grant_outcome.dart' as _i2;
import 'package:anonaccount_server/src/generated/protocol.dart' as _i3;

abstract class GrantMemberDeviceResult
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  GrantMemberDeviceResult._({
    required this.granted,
    required this.alreadyGranted,
  });

  factory GrantMemberDeviceResult({
    required List<_i2.MemberDeviceGrantOutcome> granted,
    required List<_i2.MemberDeviceGrantOutcome> alreadyGranted,
  }) = _GrantMemberDeviceResultImpl;

  factory GrantMemberDeviceResult.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return GrantMemberDeviceResult(
      granted: _i3.Protocol().deserialize<List<_i2.MemberDeviceGrantOutcome>>(
        jsonSerialization['granted'],
      ),
      alreadyGranted: _i3.Protocol()
          .deserialize<List<_i2.MemberDeviceGrantOutcome>>(
            jsonSerialization['alreadyGranted'],
          ),
    );
  }

  List<_i2.MemberDeviceGrantOutcome> granted;

  List<_i2.MemberDeviceGrantOutcome> alreadyGranted;

  /// Returns a shallow copy of this [GrantMemberDeviceResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GrantMemberDeviceResult copyWith({
    List<_i2.MemberDeviceGrantOutcome>? granted,
    List<_i2.MemberDeviceGrantOutcome>? alreadyGranted,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.GrantMemberDeviceResult',
      'granted': granted.toJson(valueToJson: (v) => v.toJson()),
      'alreadyGranted': alreadyGranted.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.GrantMemberDeviceResult',
      'granted': granted.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'alreadyGranted': alreadyGranted.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _GrantMemberDeviceResultImpl extends GrantMemberDeviceResult {
  _GrantMemberDeviceResultImpl({
    required List<_i2.MemberDeviceGrantOutcome> granted,
    required List<_i2.MemberDeviceGrantOutcome> alreadyGranted,
  }) : super._(
         granted: granted,
         alreadyGranted: alreadyGranted,
       );

  /// Returns a shallow copy of this [GrantMemberDeviceResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GrantMemberDeviceResult copyWith({
    List<_i2.MemberDeviceGrantOutcome>? granted,
    List<_i2.MemberDeviceGrantOutcome>? alreadyGranted,
  }) {
    return GrantMemberDeviceResult(
      granted: granted ?? this.granted.map((e0) => e0.copyWith()).toList(),
      alreadyGranted:
          alreadyGranted ??
          this.alreadyGranted.map((e0) => e0.copyWith()).toList(),
    );
  }
}
