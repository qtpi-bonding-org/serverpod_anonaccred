import 'package:dart_jwk_duo/dart_jwk_duo.dart' show KeyDuo;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_keys.freezed.dart';

/// The cryptographic material produced by account creation.
///
/// - [ultimateKey] is the long-term recovery key the user must back up.
/// - [deviceKey] is short-lived to this device.
/// - [symmetricKeyJwk] is the AES-256 data key, JWK-encoded as a JSON
///   string (this is the on-the-wire shape — the runtime
///   `AesGcmSecretKey` is recovered by the consumer's storage layer).
///
/// This model deliberately does **not** carry the encrypted blobs sent
/// to the server. Those live on RegistrationPayload in Phase 2.
@freezed
abstract class AccountKeys with _$AccountKeys {
  const AccountKeys._();

  const factory AccountKeys({
    required KeyDuo ultimateKey,
    required KeyDuo deviceKey,
    required String symmetricKeyJwk,
  }) = _AccountKeys;

  /// Written by hand because [symmetricKeyJwk] is the AES-256 data key
  /// itself. Freezed 3 skips generating one when the class defines its own.
  @override
  String toString() => 'AccountKeys(ultimateKey: <KeyDuo>, '
      'deviceKey: <KeyDuo>, symmetricKeyJwk: <redacted>)';
}
