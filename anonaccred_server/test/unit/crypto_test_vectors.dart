import 'dart:convert';
import 'package:webcrypto/webcrypto.dart';

/// Generate ECDSA P-256 test vectors for testing
Future<void> main() async {
  // Generate a key pair for testing
  final keyPair = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
  
  // Export public key in raw format
  final publicKeyBytes = await keyPair.publicKey.exportRawKey();
  
  // Remove the 0x04 prefix to get x||y format (128 hex chars)
  final publicKeyHex = publicKeyBytes.sublist(1).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  
  // Test message
  const message = 'test challenge message';
  final messageBytes = utf8.encode(message);
  
  // Sign the message
  final signatureBytes = await keyPair.privateKey.signBytes(messageBytes, Hash.sha256);
  final signatureHex = signatureBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  
  print('=== ECDSA P-256 Test Vectors ===');
  print('Public Key (128 hex chars): $publicKeyHex');
  print('Message: $message');
  print('Signature (128 hex chars): $signatureHex');
  print('Public Key Length: ${publicKeyHex.length}');
  print('Signature Length: ${signatureHex.length}');
}