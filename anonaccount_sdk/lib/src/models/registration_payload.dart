import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'registration_payload.freezed.dart';
part 'registration_payload.g.dart';

/// The wire-bound payload sent to `client.account.createAccount`. The
/// `signature` covers [signableData] using the ultimate signing key.
///
/// Persisted by consumers between account creation and `registerAccount`
/// to support the "create now, register later" flow.
@freezed
class RegistrationPayload with _$RegistrationPayload {
  const RegistrationPayload._();

  const factory RegistrationPayload({
    required String devicePublicKeyHex,
    required String ultimatePublicKeyHex,
    required String recoveryBlob,
    required String deviceBlob,
    required String signature,
    required String deviceKeyAttestation,
    String? crossDeviceKeyAttestation,
    required DateTime createdAt,
    @Default(1) int version,
  }) = _RegistrationPayload;

  factory RegistrationPayload.fromJson(Map<String, dynamic> json) =>
      _$RegistrationPayloadFromJson(json);

  /// The exact byte sequence the ultimate key signs. Field order is part
  /// of the protocol — do not reorder.
  String get signableData =>
      '$devicePublicKeyHex:$ultimatePublicKeyHex:$recoveryBlob:$deviceBlob:'
      '${createdAt.toIso8601String()}';

  String toJsonString() => jsonEncode(toJson());
}
