// anonaccount_server/lib/src/key_format.dart

/// The single definition of a valid public key on the server.
///
/// Every public key in this system — signing or encryption, account world or
/// group world — is SEC1 uncompressed (`04 || x || y`): 65 bytes, 130 hex
/// characters, lowercase.
///
/// Deliberately does NOT check that the point lies on P-256. That would mean
/// parsing keys into curve points, i.e. handling key objects server-side,
/// which conventions rule 12 keeps out of the server. Curve membership is
/// enforced client-side on import by webcrypto/BoringSSL. A malformed key is
/// therefore stored and fails later, client-side.
///
/// Lowercasing is load-bearing, not cosmetic: hex is case-insensitive but
/// Postgres `=` and btree unique indexes are not. Storing mixed case would
/// let two spellings of one key compare unequal, defeating distinctness
/// checks, unique indexes and account lookups alike.
class PublicKeyFormat {
  const PublicKeyFormat._();

  /// SEC1 uncompressed P-256: `04` tag + 32-byte x + 32-byte y, in hex.
  static const int sec1HexLength = 130;
  static const String uncompressedTag = '04';

  static final RegExp _hex = RegExp(r'^[0-9a-f]+$');

  /// Validates [key] and returns its canonical (lowercase) form.
  ///
  /// Throws [FormatException] if it is not a well-formed SEC1 uncompressed
  /// public key hex string.
  static String normalize(String key) {
    final lowered = key.toLowerCase();
    if (lowered.length != sec1HexLength) {
      throw FormatException(
        'Public key must be $sec1HexLength hex characters '
        '(SEC1 uncompressed); got ${key.length}',
      );
    }
    if (!_hex.hasMatch(lowered)) {
      throw const FormatException(
        'Public key must contain only hex characters',
      );
    }
    if (!lowered.startsWith(uncompressedTag)) {
      throw FormatException(
        'Public key must begin with the SEC1 uncompressed tag '
        '$uncompressedTag',
      );
    }
    return lowered;
  }

  /// Whether [key] is a well-formed SEC1 uncompressed public key hex string.
  static bool isValid(String key) {
    try {
      normalize(key);
      return true;
    } on FormatException {
      return false;
    }
  }
}
