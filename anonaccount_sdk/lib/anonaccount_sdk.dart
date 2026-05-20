/// anonaccount_sdk — handcrafted Dart wrapper around anonaccount_client.
///
/// Pure Dart, stateless. See the design spec at
/// `2026-05-20-anonaccount-sdk.md` (repo root).
library anonaccount_sdk;

// Re-exports of upstream types consumers will need.
export 'package:dart_jwk_duo/dart_jwk_duo.dart'
    show KeyDuo, IKeyDuo, SigningKeyPair, EncryptionKeyPair;
export 'package:webcrypto/webcrypto.dart'
    show AesGcmSecretKey, EcdhPublicKey, EcdhPrivateKey, EllipticCurve;

// Filled in as later tasks land.
export 'src/auth/exceptions.dart';
export 'src/util/crypto_logger.dart';
export 'src/util/secure_memory_utils.dart';
export 'src/crypto/hashcash.dart';
export 'src/util/error_recovery.dart';
