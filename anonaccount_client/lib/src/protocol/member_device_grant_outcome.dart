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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class MemberDeviceGrantOutcome
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  MemberDeviceGrantOutcome._({
    required this.groupMemberId,
    required this.accountDeviceId,
  });

  factory MemberDeviceGrantOutcome({
    required _isc.UuidValue groupMemberId,
    required _isc.UuidValue accountDeviceId,
  }) = _MemberDeviceGrantOutcomeImpl;

  factory MemberDeviceGrantOutcome.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MemberDeviceGrantOutcome(
      groupMemberId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['groupMemberId'],
      ),
      accountDeviceId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountDeviceId'],
      ),
    );
  }

  _isc.UuidValue groupMemberId;

  _isc.UuidValue accountDeviceId;

  /// Returns a shallow copy of this [MemberDeviceGrantOutcome]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  MemberDeviceGrantOutcome copyWith({
    _isc.UuidValue? groupMemberId,
    _isc.UuidValue? accountDeviceId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccount.MemberDeviceGrantOutcome',
      'groupMemberId': groupMemberId.toJson(),
      'accountDeviceId': accountDeviceId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'anonaccount.MemberDeviceGrantOutcome',
      'groupMemberId': groupMemberId.toJson(),
      'accountDeviceId': accountDeviceId.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _MemberDeviceGrantOutcomeImpl extends MemberDeviceGrantOutcome {
  _MemberDeviceGrantOutcomeImpl({
    required _isc.UuidValue groupMemberId,
    required _isc.UuidValue accountDeviceId,
  }) : super._(groupMemberId: groupMemberId, accountDeviceId: accountDeviceId);

  /// Returns a shallow copy of this [MemberDeviceGrantOutcome]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  MemberDeviceGrantOutcome copyWith({
    _isc.UuidValue? groupMemberId,
    _isc.UuidValue? accountDeviceId,
  }) {
    return MemberDeviceGrantOutcome(
      groupMemberId: groupMemberId ?? this.groupMemberId,
      accountDeviceId: accountDeviceId ?? this.accountDeviceId,
    );
  }
}
