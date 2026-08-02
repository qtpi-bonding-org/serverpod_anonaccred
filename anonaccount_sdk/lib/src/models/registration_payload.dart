import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'registration_payload.freezed.dart';
part 'registration_payload.g.dart';

/// The wire-bound payload sent to `client.account.createAccount`.
///
/// Persisted by consumers between account creation and `registerAccount`
/// to support the "create now, register later" flow.
///
/// Carries both halves of each key pair (signing + encryption), matching the
/// server's `PublicKeyDuo` wire model — the account/device principal parity
/// work standardised every public key on SEC1 uncompressed hex and made the
/// device attestation cover both halves of the device key.
@freezed
abstract class RegistrationPayload with _$RegistrationPayload {
  const RegistrationPayload._();

  const factory RegistrationPayload({
    required String devicePublicKeyHex,
    required String deviceEncryptionPublicKeyHex,
    required String ultimatePublicKeyHex,
    required String ultimateEncryptionPublicKeyHex,
    required String recoveryBlob,
    required String deviceBlob,
    required String deviceKeyAttestation,
    required DateTime createdAt,
    @Default(1) int version,
  }) = _RegistrationPayload;

  factory RegistrationPayload.fromJson(Map<String, dynamic> json) =>
      _$RegistrationPayloadFromJson(json);

  String toJsonString() => jsonEncode(toJson());
}
