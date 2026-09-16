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
import 'package:serverpod/serverpod.dart' as _is;

abstract class MemberDeviceGrantOutcome
    implements _is.SerializableModel, _is.ProtocolSerialization {
  MemberDeviceGrantOutcome._({
    required this.groupMemberId,
    required this.accountDeviceId,
  });

  factory MemberDeviceGrantOutcome({
    required _is.UuidValue groupMemberId,
    required _is.UuidValue accountDeviceId,
  }) = _MemberDeviceGrantOutcomeImpl;

  factory MemberDeviceGrantOutcome.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MemberDeviceGrantOutcome(
      groupMemberId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['groupMemberId'],
      ),
      accountDeviceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountDeviceId'],
      ),
    );
  }

  _is.UuidValue groupMemberId;

  _is.UuidValue accountDeviceId;

  /// Returns a shallow copy of this [MemberDeviceGrantOutcome]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  MemberDeviceGrantOutcome copyWith({
    _is.UuidValue? groupMemberId,
    _is.UuidValue? accountDeviceId,
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
    return _is.SerializationManager.encode(this);
  }
}

class _MemberDeviceGrantOutcomeImpl extends MemberDeviceGrantOutcome {
  _MemberDeviceGrantOutcomeImpl({
    required _is.UuidValue groupMemberId,
    required _is.UuidValue accountDeviceId,
  }) : super._(groupMemberId: groupMemberId, accountDeviceId: accountDeviceId);

  /// Returns a shallow copy of this [MemberDeviceGrantOutcome]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  MemberDeviceGrantOutcome copyWith({
    _is.UuidValue? groupMemberId,
    _is.UuidValue? accountDeviceId,
  }) {
    return MemberDeviceGrantOutcome(
      groupMemberId: groupMemberId ?? this.groupMemberId,
      accountDeviceId: accountDeviceId ?? this.accountDeviceId,
    );
  }
}
