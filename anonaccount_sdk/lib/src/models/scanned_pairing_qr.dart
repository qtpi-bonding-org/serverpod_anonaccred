import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'scanned_pairing_qr.freezed.dart';
part 'scanned_pairing_qr.g.dart';

/// What [AnonaccountPairing.parseQr] returns to the approving device
/// (side A) after decoding the joiner's QR/link payload.
///
/// The encryption public key is delivered as a JWK string here so the
/// model can be JSON-serialized by consumers; rehydrate it to a
/// runtime [EcdhPublicKey] via `webcrypto` at the point of use.
@freezed
class ScannedPairingQr with _$ScannedPairingQr {
  const ScannedPairingQr._();

  const factory ScannedPairingQr({
    required String theirSigningPubkeyHex,
    required String theirEncryptionPubkeyJwk,
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
      theirEncryptionPubkeyJwk: raw['theirEncryptionPubkeyJwk'] as String,
      label: raw['label'] as String,
    );
  }
}
