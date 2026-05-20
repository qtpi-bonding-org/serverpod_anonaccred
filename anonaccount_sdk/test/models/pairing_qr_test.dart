import 'dart:convert';
import 'package:anonaccount_sdk/src/crypto/key_gen.dart';
import 'package:anonaccount_sdk/src/models/generated_pairing_qr.dart';
import 'package:anonaccount_sdk/src/models/scanned_pairing_qr.dart';
import 'package:test/test.dart';

void main() {
  test('GeneratedPairingQr exposes payload + keys + signing pubkey hex', () async {
    final duo = await KeyGen.generateDeviceKey();
    final qr = GeneratedPairingQr(
      qrPayloadJson: jsonEncode({
        'action': 'pair',
        'devicePublicKeyJwk': '{}',
        'label': 'iPhone',
      }),
      deviceKey: duo,
      signingPubkeyHex: 'a' * 128,
    );
    expect(qr.signingPubkeyHex, 'a' * 128);
    expect(qr.deviceKey, duo);
    expect(jsonDecode(qr.qrPayloadJson), isMap);
  });

  test('ScannedPairingQr.fromJson decodes the wire shape', () {
    final wire = jsonEncode({
      'action': 'pair',
      'theirSigningPubkeyHex': 'b' * 128,
      'theirEncryptionPubkeyJwk': '{"kty":"EC"}',
      'label': 'MacBook',
    });
    final scanned = ScannedPairingQr.fromQrJson(wire);
    expect(scanned.theirSigningPubkeyHex, 'b' * 128);
    expect(scanned.label, 'MacBook');
    expect(scanned.theirEncryptionPubkeyJwk, '{"kty":"EC"}');
  });

  test('ScannedPairingQr.fromQrJson rejects non-pair actions', () {
    final wire = jsonEncode({
      'action': 'unknown',
      'theirSigningPubkeyHex': 'x',
      'theirEncryptionPubkeyJwk': '{}',
      'label': 'L',
    });
    expect(
      () => ScannedPairingQr.fromQrJson(wire),
      throwsA(isA<FormatException>()),
    );
  });
}
