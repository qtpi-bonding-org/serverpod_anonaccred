import 'dart:convert';
import 'dart:typed_data';

import 'package:anonaccount_client/anonaccount_client.dart' as wire;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeCaller extends Mock implements wire.Caller {}

void main() {
  group('generateQr', () {
    test('returns a fresh device key + parseable QR payload', () async {
      final pairing = AnonaccountPairing(_FakeCaller());
      final qr = await pairing.generateQr(deviceLabel: 'iPhone-15');
      expect(qr.signingPubkeyHex, hasLength(128));

      final decoded = jsonDecode(qr.qrPayloadJson) as Map<String, dynamic>;
      expect(decoded['action'], 'pair');
      expect(decoded['theirSigningPubkeyHex'], qr.signingPubkeyHex);
      expect(decoded['theirEncryptionPubkeyJwk'], isA<String>());
      expect(decoded['label'], 'iPhone-15');
    });
  });

  group('parseQr', () {
    test('round-trips with generateQr output', () async {
      final pairing = AnonaccountPairing(_FakeCaller());
      final qr = await pairing.generateQr(deviceLabel: 'iPhone-15');
      final scanned = pairing.parseQr(qr.qrPayloadJson);
      expect(scanned.theirSigningPubkeyHex, qr.signingPubkeyHex);
      expect(scanned.label, 'iPhone-15');
    });

    test('throws on malformed JSON', () {
      final pairing = AnonaccountPairing(_FakeCaller());
      expect(
        () => pairing.parseQr('not-json'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('completePairing', () {
    test('unwraps to a working AesGcmSecretKey', () async {
      final pairing = AnonaccountPairing(_FakeCaller());
      final myDeviceKey = await KeyGen.generateDeviceKey();
      final originalJwk = await KeyGen.generateSymmetricKeyJwk();

      // Approver side wraps the JWK to our public encryption key.
      final blob = await AsymmetricCrypto.wrapForRecipient(
        originalJwk,
        myDeviceKey.encryptionKeyPair.publicKey,
      );

      final aesKey = await pairing.completePairing(
        wrappedKey: blob,
        myDeviceKey: myDeviceKey,
      );

      // Round-trip an arbitrary payload to confirm the imported key works.
      final ct = await SymmetricCrypto.encrypt(
        Uint8List.fromList([1, 2, 3]),
        aesKey,
      );
      final pt = await SymmetricCrypto.decrypt(ct, aesKey);
      expect(pt, equals(Uint8List.fromList([1, 2, 3])));
    });
  });
}
