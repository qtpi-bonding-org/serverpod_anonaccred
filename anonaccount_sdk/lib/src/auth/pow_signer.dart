import 'package:dart_jwk_duo/dart_jwk_duo.dart' show KeyDuo;
import 'package:meta/meta.dart';

import '../crypto/hashcash.dart';
import '../crypto/signing.dart';

/// Tuple of the four parameters every PoW-protected endpoint accepts.
///
/// Internal helper. Not exported from the public barrel.
@immutable
class PowEnvelope {
  const PowEnvelope({
    required this.challenge,
    required this.proofOfWork,
    required this.signature,
    required this.publicKeyHex,
  });

  final String challenge;
  final String proofOfWork;
  final String signature;
  final String publicKeyHex;
}

/// Builds [PowEnvelope]s for SDK methods that wrap PoW-protected
/// endpoints.
class PowSigner {
  const PowSigner._();

  /// Default hashcash difficulty. Override via [difficulty] in tests
  /// to keep them fast — production callers leave it at the default.
  static const int defaultDifficulty = 20;

  /// Composes the outer envelope. The signature covers
  /// `'$challenge:$methodName:$publicKeyHex'`.
  static Future<PowEnvelope> build({
    required String challenge,
    required String methodName,
    required KeyDuo signingKey,
    required String publicKeyHex,
    int difficulty = defaultDifficulty,
  }) async {
    final proofOfWork = await Hashcash.mint(challenge, difficulty: difficulty);
    final payload = '$challenge:$methodName:$publicKeyHex';
    final signature = await SigningCrypto.signChallenge(payload, signingKey);
    return PowEnvelope(
      challenge: challenge,
      proofOfWork: proofOfWork,
      signature: signature,
      publicKeyHex: publicKeyHex,
    );
  }
}
