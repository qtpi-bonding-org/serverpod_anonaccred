import 'package:dart_jwk_duo/dart_jwk_duo.dart' show KeyDuo;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated_pairing_qr.freezed.dart';

/// What [AnonaccountPairing.generateQr] returns to the joining device
/// (side B). The consumer:
///   - displays `qrPayloadJson` (typically encoded as a QR or shared as
///     a deep link) to side A,
///   - persists `deviceKey` locally,
///   - feeds `signingPubkeyHex` to `monitorRegistration` to learn when
///     side A has wrapped the symmetric key.
@freezed
class GeneratedPairingQr with _$GeneratedPairingQr {
  const factory GeneratedPairingQr({
    required String qrPayloadJson,
    required KeyDuo deviceKey,
    required String signingPubkeyHex,
  }) = _GeneratedPairingQr;
}
