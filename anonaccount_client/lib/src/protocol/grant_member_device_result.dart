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
import 'package:anonaccount_client/src/protocol/protocol.dart' as _iki990kh;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'member_device_grant_outcome.dart' as _igy7ui1b;

abstract class GrantMemberDeviceResult
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  GrantMemberDeviceResult._({
    required this.granted,
    required this.alreadyGranted,
  });

  factory GrantMemberDeviceResult({
    required List<_igy7ui1b.MemberDeviceGrantOutcome> granted,
    required List<_igy7ui1b.MemberDeviceGrantOutcome> alreadyGranted,
  }) = _GrantMemberDeviceResultImpl;

  factory GrantMemberDeviceResult.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return GrantMemberDeviceResult(
      granted: _iki990kh.Protocol()
          .deserialize<List<_igy7ui1b.MemberDeviceGrantOutcome>>(
            jsonSerialization['granted'],
          ),
      alreadyGranted: _iki990kh.Protocol()
          .deserialize<List<_igy7ui1b.MemberDeviceGrantOutcome>>(
            jsonSerialization['alreadyGranted'],
          ),
    );
  }

  List<_igy7ui1b.MemberDeviceGrantOutcome> granted;

  List<_igy7ui1b.MemberDeviceGrantOutcome> alreadyGranted;

  /// Returns a shallow copy of this [GrantMemberDeviceResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  GrantMemberDeviceResult copyWith({
    List<_igy7ui1b.MemberDeviceGrantOutcome>? granted,
    List<_igy7ui1b.MemberDeviceGrantOutcome>? alreadyGranted,
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
    return _isc.SerializationManager.encode(this);
  }
}

class _GrantMemberDeviceResultImpl extends GrantMemberDeviceResult {
  _GrantMemberDeviceResultImpl({
    required List<_igy7ui1b.MemberDeviceGrantOutcome> granted,
    required List<_igy7ui1b.MemberDeviceGrantOutcome> alreadyGranted,
  }) : super._(granted: granted, alreadyGranted: alreadyGranted);

  /// Returns a shallow copy of this [GrantMemberDeviceResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  GrantMemberDeviceResult copyWith({
    List<_igy7ui1b.MemberDeviceGrantOutcome>? granted,
    List<_igy7ui1b.MemberDeviceGrantOutcome>? alreadyGranted,
  }) {
    return GrantMemberDeviceResult(
      granted: granted ?? this.granted.map((e0) => e0.copyWith()).toList(),
      alreadyGranted:
          alreadyGranted ??
          this.alreadyGranted.map((e0) => e0.copyWith()).toList(),
    );
  }
}
