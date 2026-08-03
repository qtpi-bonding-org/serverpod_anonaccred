// ignore: implementation_imports
import 'package:anonaccount_client/anonaccount_client.dart' show UuidValue;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recovered_membership.freezed.dart';

/// One membership's outcome from [AnonaccountAuth.recoverAccount]. Carries
/// no key material: a recovered member key is written straight to the
/// caller's `MemberKeyStore`, the same custody convention `recoverAccount`
/// already uses for the account data key. [recovered] tells the caller
/// which memberships got a usable key and which did not, without handing
/// back anything the store does not already have.
@freezed
abstract class RecoveredMembership with _$RecoveredMembership {
  const factory RecoveredMembership({
    required String groupId,
    required UuidValue memberId,
    required bool recovered,
    required bool? ownerKeyRecovered,
  }) = _RecoveredMembership;
}
