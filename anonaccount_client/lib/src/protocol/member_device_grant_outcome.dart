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

abstract class MemberDeviceGrantOutcome implements _i1.SerializableModel {
  MemberDeviceGrantOutcome._({
    required this.groupMemberId,
    required this.accountDeviceId,
  });

  factory MemberDeviceGrantOutcome({
    required _i1.UuidValue groupMemberId,
    required _i1.UuidValue accountDeviceId,
  }) = _MemberDeviceGrantOutcomeImpl;

  factory MemberDeviceGrantOutcome.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MemberDeviceGrantOutcome(
      groupMemberId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['groupMemberId'],
      ),
      accountDeviceId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountDeviceId'],
      ),
    );
  }

  _i1.UuidValue groupMemberId;

  _i1.UuidValue accountDeviceId;

  /// Returns a shallow copy of this [MemberDeviceGrantOutcome]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MemberDeviceGrantOutcome copyWith({
    _i1.UuidValue? groupMemberId,
    _i1.UuidValue? accountDeviceId,
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
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MemberDeviceGrantOutcomeImpl extends MemberDeviceGrantOutcome {
  _MemberDeviceGrantOutcomeImpl({
    required _i1.UuidValue groupMemberId,
    required _i1.UuidValue accountDeviceId,
  }) : super._(
         groupMemberId: groupMemberId,
         accountDeviceId: accountDeviceId,
       );

  /// Returns a shallow copy of this [MemberDeviceGrantOutcome]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MemberDeviceGrantOutcome copyWith({
    _i1.UuidValue? groupMemberId,
    _i1.UuidValue? accountDeviceId,
  }) {
    return MemberDeviceGrantOutcome(
      groupMemberId: groupMemberId ?? this.groupMemberId,
      accountDeviceId: accountDeviceId ?? this.accountDeviceId,
    );
  }
}
