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
export 'src/models/models.dart';
export 'src/crypto/symmetric.dart';
export 'src/crypto/signing.dart';
export 'src/crypto/asymmetric.dart';
export 'src/crypto/key_gen.dart';

export 'package:anonaccount_client/anonaccount_client.dart'
    show
        Caller,
        EndpointAccount,
        EndpointDevice,
        EndpointDeviceManagement,
        EndpointEntrypoint,
        EndpointGroup,
        AccountMethods,
        DeviceMethods,
        DataKeyMethods,
        AccountDevice,
        AccountCreationResponse,
        AuthenticationResult,
        PublicChallengeResponse,
        ShareGroup,
        GroupMember,
        GroupMemberRole,
        UuidValue;

export 'src/auth/anonaccount_auth.dart';
export 'src/auth/pairing.dart';
export 'src/auth/groups.dart';
