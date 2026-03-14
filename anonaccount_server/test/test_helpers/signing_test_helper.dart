import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

/// Reusable ECDSA P-256 signing helper for tests.
///
/// Provides a pre-generated test keypair and signing methods that mirror
/// the server's CryptoUtils.verifySignature algorithm:
/// - Pass raw message bytes to ECDSASigner(SHA256Digest())
/// - The signer hashes internally (single SHA-256)
/// - NEVER pre-hash before passing to signer
class SigningTestHelper {
  // Pre-generated test ECDSA P-256 keypair
  // Private key (first 32 bytes are the scalar d)
  static const String testPrivateKeyHex =
      'a6392173dc58e75001c12b2edefaa29e52c61dce0b04bead66da3288d4d44a25'
      '0000000000000000000000000000000000000000000000000000000000000000';

  // Corresponding public key (x || y, 64 bytes = 128 hex chars)
  static const String testPublicKeyHex =
      'b8f7b02e0f4e2175c5292732a5004b5c0b0f7fb7845000602ef03ee71e94ab39'
      '86fe2f21de8f5945c65d838f2d3a616d7760fdff2d8c0c69ff52f88780287627';

  /// Sign a message string with the test private key.
  ///
  /// Returns 128-char hex signature (r || s, each 32 bytes).
  static String sign(String message) {
    final messageBytes = utf8.encode(message);
    final privKeyBytes = _hexToBytes(testPrivateKeyHex);
    final d = _bytesToBigInt(privKeyBytes.sublist(0, 32));
    final domainParams = ECDomainParameters('secp256r1');
    final privateKey = ECPrivateKey(d, domainParams);

    final signer = ECDSASigner(SHA256Digest());
    signer.init(
      true,
      ParametersWithRandom(
        PrivateKeyParameter<ECPrivateKey>(privateKey),
        _getSecureRandom(),
      ),
    );

    final signature = signer.generateSignature(
      Uint8List.fromList(messageBytes),
    ) as ECSignature;

    final rBytes = _bigIntToBytes(signature.r, 32);
    final sBytes = _bigIntToBytes(signature.s, 32);
    return _bytesToHex(Uint8List.fromList([...rBytes, ...sBytes]));
  }

  /// Generate a fresh ECDSA P-256 keypair for tests that need unique keys.
  ///
  /// Returns (privateKeyHex, publicKeyHex) tuple.
  static (String privateKeyHex, String publicKeyHex) generateKeypair() {
    final domainParams = ECDomainParameters('secp256r1');
    final keyGen = ECKeyGenerator()
      ..init(ParametersWithRandom(
        ECKeyGeneratorParameters(domainParams),
        _getSecureRandom(),
      ));

    final keyPair = keyGen.generateKeyPair();
    final ECPrivateKey privateKey = keyPair.privateKey;
    final ECPublicKey publicKey = keyPair.publicKey;

    final dHex = _bytesToHex(_bigIntToBytes(privateKey.d!, 32));
    // Pad private key to 128 hex (64 bytes) for consistency
    final privateKeyHex = dHex.padRight(128, '0');

    final xHex = _bytesToHex(_bigIntToBytes(publicKey.Q!.x!.toBigInteger()!, 32));
    final yHex = _bytesToHex(_bigIntToBytes(publicKey.Q!.y!.toBigInteger()!, 32));
    final publicKeyHex = '$xHex$yHex';

    return (privateKeyHex, publicKeyHex);
  }

  /// Sign a message with a specific private key hex.
  static String signWith(String message, String privateKeyHex) {
    final messageBytes = utf8.encode(message);
    final privKeyBytes = _hexToBytes(privateKeyHex);
    final d = _bytesToBigInt(privKeyBytes.sublist(0, 32));
    final domainParams = ECDomainParameters('secp256r1');
    final privateKey = ECPrivateKey(d, domainParams);

    final signer = ECDSASigner(SHA256Digest());
    signer.init(
      true,
      ParametersWithRandom(
        PrivateKeyParameter<ECPrivateKey>(privateKey),
        _getSecureRandom(),
      ),
    );

    final signature = signer.generateSignature(
      Uint8List.fromList(messageBytes),
    ) as ECSignature;

    final rBytes = _bigIntToBytes(signature.r, 32);
    final sBytes = _bigIntToBytes(signature.s, 32);
    return _bytesToHex(Uint8List.fromList([...rBytes, ...sBytes]));
  }

  static SecureRandom _getSecureRandom() {
    final random = FortunaRandom();
    final seedSource = Random.secure();
    final seeds = List<int>.generate(32, (_) => seedSource.nextInt(256));
    random.seed(KeyParameter(Uint8List.fromList(seeds)));
    return random;
  }

  static Uint8List _hexToBytes(String hex) {
    final bytes = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < hex.length; i += 2) {
      bytes[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }
    return bytes;
  }

  static String _bytesToHex(Uint8List bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  static BigInt _bytesToBigInt(Uint8List bytes) {
    var result = BigInt.zero;
    for (var i = 0; i < bytes.length; i++) {
      result = (result << 8) | BigInt.from(bytes[i]);
    }
    return result;
  }

  static Uint8List _bigIntToBytes(BigInt value, int length) {
    final bytes = Uint8List(length);
    var temp = value;
    for (var i = length - 1; i >= 0; i--) {
      bytes[i] = (temp & BigInt.from(0xff)).toInt();
      temp = temp >> 8;
    }
    return bytes;
  }
}
