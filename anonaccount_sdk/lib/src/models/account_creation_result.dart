import 'package:freezed_annotation/freezed_annotation.dart';

import 'registration_payload.dart';

part 'account_creation_result.freezed.dart';

/// Returned by [AnonaccountAuth.createAccount]. The ultimate key has
/// already been used to sign [payload] via the consumer's `AccountKeyStore`
/// and is not exposed here — the store owns its custody/backup lifecycle.
@freezed
class AccountCreationResult with _$AccountCreationResult {
  const factory AccountCreationResult({
    required RegistrationPayload payload,
  }) = _AccountCreationResult;
}
