import 'dart:convert';
import 'dart:typed_data';
import 'package:asn1lib/asn1lib.dart';
import 'package:crypto/crypto.dart';
import 'package:crypto_keys/crypto_keys.dart';
import 'package:serverpod/serverpod.dart';
import 'package:x509/x509.dart';

import 'package:anonaccount_server/anonaccount_server.dart';

import '../exception_factory.dart';

/// Apple's real Root CA G3 certificate (DER), fetched once from
/// https://www.apple.com/certificateauthority/AppleRootCA-G3.cer and
/// bundled here — Apple's App Store Server Notifications sign each JWS
/// with a certificate chain (the `x5c` header) that must chain to this
/// fixed root, not to a runtime-fetched JWKS. There is no rotation
/// endpoint to poll for this value; Apple publishes root CA changes
/// out-of-band, extremely rarely.
const String _appleRootCaG3DerBase64 =
    'MIICQzCCAcmgAwIBAgIILcX8iNLFS5UwCgYIKoZIzj0EAwMwZzEbMBkGA1UEAwwSQXBwbGUgUm9v'
    'dCBDQSAtIEczMSYwJAYDVQQLDB1BcHBsZSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTETMBEGA1UE'
    'CgwKQXBwbGUgSW5jLjELMAkGA1UEBhMCVVMwHhcNMTQwNDMwMTgxOTA2WhcNMzkwNDMwMTgxOTA2'
    'WjBnMRswGQYDVQQDDBJBcHBsZSBSb290IENBIC0gRzMxJjAkBgNVBAsMHUFwcGxlIENlcnRpZmlj'
    'YXRpb24gQXV0aG9yaXR5MRMwEQYDVQQKDApBcHBsZSBJbmMuMQswCQYDVQQGEwJVUzB2MBAGByqG'
    'SM49AgEGBSuBBAAiA2IABJjpLz1AcqTtkyJygRMc3RCV8cWjTnHcFBbZDuWmBSp3ZHtfTjjTuxxE'
    'tX/1H7YyYl3J6YRbTzBPEVoA/VhYDKX1DyxNB0cTddqXl5dvMVztK517IDvYuVTZXpmkOlEKMaNC'
    'MEAwHQYDVR0OBBYEFLuw3qFYM4iapIqZ3r6966/ayySrMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0P'
    'AQH/BAQDAgEGMAoGCCqGSM49BAMDA2gAMGUCMQCD6cHEFl4aXTQY2e3v9GwOAEZLuN+yRhHFD/3m'
    'eoyhpmvOwgPUnPWTxnS4at+qIxUCMG1mihDK1A3UT82NQz60imOlM27jbdoXt2QfyFMm+YhidDkL'
    'F1vLUagM6BgD56KyKA==';

/// A certificate paired with the two byte views verification needs: the
/// raw DER (compared against the trusted root's raw DER for root pinning)
/// and the raw TBSCertificate bytes (signed by the issuer, and needed
/// as-parsed rather than re-serialized — see `_isSignedBy`).
class _ParsedCertificate {
  _ParsedCertificate({
    required this.rawDer,
    required this.certificate,
    required this.tbsBytes,
  });

  final Uint8List rawDer;
  final X509Certificate certificate;
  final Uint8List tbsBytes;
}

class NotificationSignatureValidator {
  /// Test-only override for the trusted root certificate (DER bytes).
  /// Production code must never set this; tests point it at a throwaway
  /// test root so verification doesn't depend on Apple's real chain.
  static List<int>? trustedRootDerOverride;

  static List<int> get _trustedRootDer =>
      trustedRootDerOverride ?? base64.decode(_appleRootCaG3DerBase64);

  static String? extractSignedPayload(String requestBody) {
    try {
      final decoded = jsonDecode(requestBody) as Map<String, dynamic>;
      return decoded['signedPayload'] as String?;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> validateSignature({required String signedPayload}) async {
    try {
      final parts = signedPayload.split('.');
      if (parts.length != 3) return false;

      final header = _decodeJWTHeader(parts[0]);
      if (header == null) return false;
      if (header['alg'] != 'ES256') return false;

      final x5c = header['x5c'] as List<dynamic>?;
      if (x5c == null || x5c.isEmpty) return false;

      final chain = x5c
          .map((c) => _parseCertDer(base64.decode(c as String)))
          .toList();
      if (!_chainsToTrustedRoot(chain)) return false;

      final leafPublicKey = chain.first.certificate.publicKey;
      final signingInput = '${parts[0]}.${parts[1]}';
      final signatureBytes = _base64UrlDecode(parts[2]);

      // JWS ES256 signature bytes are already the raw, fixed-length R || S
      // concatenation (RFC 7518 A.3) — the same format crypto_keys' EC
      // verifier expects. No DER re-encoding here.
      final verifier = leafPublicKey.createVerifier(
        algorithms.signing.ecdsa.sha256,
      );
      return verifier.verify(
        Uint8List.fromList(utf8.encode(signingInput)),
        Signature(Uint8List.fromList(signatureBytes)),
      );
    } catch (e) {
      return false;
    }
  }

  /// Verifies cert[i] was signed by cert[i+1]'s key for every adjacent
  /// pair, then anchors the terminal certificate to the trusted root.
  ///
  /// Apple's `x5c` header carries leaf + intermediate only — never the
  /// self-signed root, which the verifier is expected to already trust
  /// out-of-band (RFC 7515 section 4.1.6 makes the root's presence optional).
  /// So the terminal cert is accepted either because it *is* the trusted
  /// root by byte identity (root pinning, not just "some self-signed CA"),
  /// or because it was itself signed by the trusted root's key.
  static bool _chainsToTrustedRoot(List<_ParsedCertificate> chain) {
    if (chain.isEmpty) return false;
    for (final cert in chain) {
      if (!_isWithinValidityPeriod(cert)) return false;
    }
    for (var i = 1; i < chain.length; i++) {
      if (!_hasCaBasicConstraints(chain[i])) return false;
    }
    for (var i = 0; i < chain.length - 1; i++) {
      if (!_isSignedBy(chain[i], chain[i + 1])) return false;
    }
    final terminal = chain.last;
    if (_bytesEqual(terminal.rawDer, _trustedRootDer)) return true;
    return _isSignedBy(terminal, _parseCertDer(_trustedRootDer));
  }

  static bool _hasCaBasicConstraints(_ParsedCertificate cert) {
    final extensions = cert.certificate.tbsCertificate.extensions;
    if (extensions == null) return false;
    for (final extension in extensions) {
      final value = extension.extnValue;
      if (value is BasicConstraints) return value.cA;
    }
    return false;
  }

  static bool _isWithinValidityPeriod(_ParsedCertificate cert) {
    final validity = cert.certificate.tbsCertificate.validity;
    if (validity == null) return false;
    final now = DateTime.now();
    return !now.isBefore(validity.notBefore) && !now.isAfter(validity.notAfter);
  }

  static bool _isSignedBy(_ParsedCertificate cert, _ParsedCertificate issuer) {
    try {
      final sig = cert.certificate.signatureValue;
      if (sig == null) return false;

      // X.509 stores the ECDSA signature as a DER SEQUENCE of two
      // INTEGERs (RFC 5480), which is a different encoding than the raw
      // R || S pairs crypto_keys' EC verifier expects — convert.
      final rawSignature = _derDecodeEcdsaSignatureToRaw(sig);
      if (rawSignature == null) return false;

      final verifier = issuer.certificate.publicKey.createVerifier(
        algorithms.signing.ecdsa.sha256,
      );
      // cert.tbsBytes are the TBSCertificate bytes exactly as parsed from
      // the wire, not a re-serialization: x509's TbsCertificate.toAsn1()
      // does not round-trip byte-for-byte (e.g. serial number re-encoding
      // differs), which would break signature verification.
      return verifier.verify(cert.tbsBytes, Signature(rawSignature));
    } catch (e) {
      return false;
    }
  }

  static _ParsedCertificate _parseCertDer(List<int> der) {
    final bytes = Uint8List.fromList(der);
    final sequence = ASN1Parser(bytes).nextObject() as ASN1Sequence;
    final tbsBytes = Uint8List.fromList(sequence.elements[0].encodedBytes);
    return _ParsedCertificate(
      rawDer: bytes,
      certificate: X509Certificate.fromAsn1(sequence),
      tbsBytes: tbsBytes,
    );
  }

  static bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Decodes a DER `SEQUENCE { r INTEGER, s INTEGER }` ECDSA signature
  /// (the X.509 on-wire format) into the fixed-length raw `R || S`
  /// concatenation that crypto_keys' EC verifier expects. Every curve this
  /// validator handles (P-256) uses a 32-byte field element.
  static Uint8List? _derDecodeEcdsaSignatureToRaw(List<int> derSignature) {
    const fieldElementLength = 32;
    try {
      final seq =
          ASN1Parser(Uint8List.fromList(derSignature)).nextObject()
              as ASN1Sequence;
      final r = (seq.elements[0] as ASN1Integer).valueAsBigInteger;
      final s = (seq.elements[1] as ASN1Integer).valueAsBigInteger;
      final rBytes = _bigIntToFixedBytes(r, fieldElementLength);
      final sBytes = _bigIntToFixedBytes(s, fieldElementLength);
      return Uint8List.fromList([...rBytes, ...sBytes]);
    } catch (e) {
      return null;
    }
  }

  static List<int> _bigIntToFixedBytes(BigInt value, int length) {
    var hex = value.toRadixString(16);
    if (hex.length % 2 != 0) hex = '0$hex';
    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    if (bytes.length > length) {
      // A leading 0x00 pad byte (added by DER to keep the INTEGER
      // non-negative) is not part of the field element — drop it.
      bytes.removeRange(0, bytes.length - length);
    } else if (bytes.length < length) {
      bytes.insertAll(0, List.filled(length - bytes.length, 0));
    }
    return bytes;
  }

  static List<int> _base64UrlDecode(String input) {
    final normalized = input.replaceAll('-', '+').replaceAll('_', '/');
    final padded = normalized.padRight(
      normalized.length + (4 - normalized.length % 4) % 4,
      '=',
    );
    return base64Decode(padded);
  }

  static Map<String, dynamic>? _decodeJWTHeader(String headerPart) {
    try {
      final normalized = base64Url.normalize(headerPart);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static Future<void> validateSignatureOrThrow({
    required Session session,
    required String signedPayload,
  }) async {
    final isValid = await validateSignature(signedPayload: signedPayload);
    if (!isValid) {
      final payloadHash = sha256.convert(utf8.encode(signedPayload)).toString();
      session.log(
        'Apple notification signature validation failed - PayloadHash: $payloadHash',
        level: LogLevel.warning,
      );
      throw AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.authInvalidSignature,
        message: 'Invalid Apple notification signature',
        details: {'payload_hash': payloadHash},
      );
    }
  }
}
