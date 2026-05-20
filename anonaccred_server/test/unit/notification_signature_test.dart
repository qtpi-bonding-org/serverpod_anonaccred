import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:test/test.dart';

void main() {
  group('NotificationSignatureValidator - EC key concepts', () {
    test('EC P-256 key can be constructed from x/y coordinates', () {
      // Generate a known EC key pair for testing
      final keyParams = ECKeyGeneratorParameters(ECDomainParameters('secp256r1'));
      final secureRandom = FortunaRandom()
        ..seed(KeyParameter(Uint8List.fromList(List.generate(32, (i) => i))));

      final keyGen = ECKeyGenerator()
        ..init(ParametersWithRandom(keyParams, secureRandom));

      final pair = keyGen.generateKeyPair();
      final publicKey = pair.publicKey as ECPublicKey;

      // Extract x and y
      final x = publicKey.Q!.x!.toBigInteger()!;
      final y = publicKey.Q!.y!.toBigInteger()!;

      // Reconstruct from x/y (this is what the fixed code does)
      final curve = ECDomainParameters('secp256r1');
      final reconstructed = curve.curve.createPoint(x, y);
      final rebuiltKey = ECPublicKey(reconstructed, curve);

      expect(rebuiltKey.Q!.x!.toBigInteger(), equals(x));
      expect(rebuiltKey.Q!.y!.toBigInteger(), equals(y));
    });

    test('base64url-encoded x/y can round-trip to BigInt', () {
      // Simulate what Apple JWKS provides: base64url-encoded x and y
      final xBytes = Uint8List(32);
      final yBytes = Uint8List(32);
      xBytes[0] = 0x01;
      xBytes[31] = 0xFF;
      yBytes[0] = 0xAB;
      yBytes[31] = 0xCD;

      final xB64 = base64Url.encode(xBytes).replaceAll('=', '');
      final yB64 = base64Url.encode(yBytes).replaceAll('=', '');

      // Decode back
      final xDecoded = _base64UrlDecodeBigInt(xB64);
      final yDecoded = _base64UrlDecodeBigInt(yB64);

      // Verify they are non-zero
      expect(xDecoded > BigInt.zero, isTrue);
      expect(yDecoded > BigInt.zero, isTrue);

      // Verify specific byte values survived
      final xHex = xDecoded.toRadixString(16).padLeft(64, '0');
      expect(xHex.substring(0, 2), equals('01'));
      expect(xHex.substring(62, 64), equals('ff'));
    });

    test('ES256 sign and verify with EC key from x/y coordinates', () {
      // Generate key pair
      final keyParams = ECKeyGeneratorParameters(ECDomainParameters('secp256r1'));
      final secureRandom = FortunaRandom()
        ..seed(KeyParameter(Uint8List.fromList(List.generate(32, (i) => i + 42))));

      final keyGen = ECKeyGenerator()
        ..init(ParametersWithRandom(keyParams, secureRandom));

      final pair = keyGen.generateKeyPair();
      final privateKey = pair.privateKey as ECPrivateKey;
      final publicKey = pair.publicKey as ECPublicKey;

      // Sign a message
      final message = Uint8List.fromList(utf8.encode('test.payload'));
      final signer = ECDSASigner(SHA256Digest())
        ..init(true, ParametersWithRandom(
          PrivateKeyParameter<ECPrivateKey>(privateKey),
          secureRandom,
        ));

      final signature = signer.generateSignature(message) as ECSignature;

      // Verify with reconstructed public key (from x/y — the fixed code path)
      final x = publicKey.Q!.x!.toBigInteger()!;
      final y = publicKey.Q!.y!.toBigInteger()!;
      final curve = ECDomainParameters('secp256r1');
      final reconstructed = ECPublicKey(curve.curve.createPoint(x, y), curve);

      final verifier = ECDSASigner(SHA256Digest())
        ..init(false, PublicKeyParameter<ECPublicKey>(reconstructed));

      expect(verifier.verifySignature(message, signature), isTrue);
    });
  });
}

/// Mirrors the _base64UrlDecodeBigInt from notification_signature_validator.dart
BigInt _base64UrlDecodeBigInt(String input) {
  final normalized = input.replaceAll('-', '+').replaceAll('_', '/');
  final padded = normalized.padRight(
    normalized.length + (4 - normalized.length % 4) % 4,
    '=',
  );
  final bytes = base64Decode(padded);
  return BigInt.parse(
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
    radix: 16,
  );
}
