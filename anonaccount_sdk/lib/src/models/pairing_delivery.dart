import 'package:freezed_annotation/freezed_annotation.dart';

part 'pairing_delivery.freezed.dart';

/// One event from [AnonaccountPairing.monitorRegistration]. Public material
/// only — [encryptedDataKey] is the wrapped account symmetric key, the
/// ultimate public keys let the newly paired device write group member-key
/// backups without a second round trip.
@freezed
abstract class PairingDelivery with _$PairingDelivery {
  const factory PairingDelivery({
    required String encryptedDataKey,
    required String ultimateEncryptionPublicKeyHex,
    required String ultimateSigningPublicKeyHex,
  }) = _PairingDelivery;
}
