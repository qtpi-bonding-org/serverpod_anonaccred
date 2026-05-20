import 'package:freezed_annotation/freezed_annotation.dart';

import 'account_keys.dart';
import 'registration_payload.dart';

part 'account_creation_result.freezed.dart';

/// Returned by [AnonaccountAuth.createAccount]. Contains every piece
/// the consumer must persist before calling [AnonaccountAuth.registerAccount].
///
/// The ultimate key inside [keys] MUST be shown to the user for backup —
/// the SDK does not store it.
@freezed
class AccountCreationResult with _$AccountCreationResult {
  const factory AccountCreationResult({
    required AccountKeys keys,
    required RegistrationPayload payload,
  }) = _AccountCreationResult;
}
