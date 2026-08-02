import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'scanned_pairing_qr.freezed.dart';
part 'scanned_pairing_qr.g.dart';

/// What [AnonaccountPairing.parseQr] returns to the approving device
/// (side A) after decoding the joiner's QR/link payload.
///
/// The encryption public key is carried as SEC1 uncompressed hex, matching
/// every other public key in the system — not JWK. Rehydrate it to a
/// runtime `EcdhPublicKey` via `webcrypto`'s `importPublicKeySec1Hex` (or
/// `dart_jwk_duo`'s equivalent) at the point of use.
@freezed
class ScannedPairingQr with _$ScannedPairingQr {
  const ScannedPairingQr._();

  const factory ScannedPairingQr({
    required String theirSigningPubkeyHex,
    required String theirEncryptionPubkeyHex,
    required String label,
  }) = _ScannedPairingQr;

  factory ScannedPairingQr.fromJson(Map<String, dynamic> json) =>
      _$ScannedPairingQrFromJson(json);

  /// Decode an incoming QR JSON string. Throws [FormatException] if the
  /// payload is malformed or `action != 'pair'`.
  factory ScannedPairingQr.fromQrJson(String qrJson) {
    final raw = jsonDecode(qrJson);
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('QR payload is not a JSON object');
    }
    if (raw['action'] != 'pair') {
      throw FormatException('Unsupported QR action: ${raw['action']}');
    }
    return ScannedPairingQr(
      theirSigningPubkeyHex: raw['theirSigningPubkeyHex'] as String,
      theirEncryptionPubkeyHex: raw['theirEncryptionPubkeyHex'] as String,
      label: raw['label'] as String,
    );
  }
}
