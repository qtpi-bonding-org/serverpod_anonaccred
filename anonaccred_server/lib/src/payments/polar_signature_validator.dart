import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Standard Webhooks signature validator for Polar.sh deliveries.
///
/// Polar follows the Standard Webhooks spec
/// (https://github.com/standard-webhooks/standard-webhooks). The
/// dashboard shows the secret as `whsec_<base64>`; the actual HMAC key
/// is the base64-decoded portion. Each delivery carries three headers:
///
///   webhook-id          unique delivery UUID
///   webhook-timestamp   unix seconds (as string)
///   webhook-signature   space-separated `v1,<base64(sig)>` values
///
/// The signed payload is `${id}.${timestamp}.${rawBody}` and the
/// algorithm is HMAC-SHA256. This module exists separately from
/// [PolarHttpClient] because signature verification has no network
/// dependency — pure CPU — and is the first thing the webhook route
/// does, before parsing any JSON.
class PolarSignatureValidator {
  PolarSignatureValidator({
    required String secret,
    Duration tolerance = const Duration(minutes: 5),
  })  : _key = _decodeSecret(secret),
        _tolerance = tolerance;

  final List<int> _key;
  final Duration _tolerance;

  /// Verify a webhook delivery. Returns true if the signature is valid
  /// AND the timestamp is within [tolerance] of [now] (defaults to
  /// `DateTime.now()`).
  ///
  /// [signatureHeader] may contain multiple whitespace-separated
  /// `v1,<base64>` entries — Standard Webhooks supports secret
  /// rotation. We accept the delivery if any one entry matches.
  bool verify({
    required String id,
    required String timestamp,
    required String signatureHeader,
    required String rawBody,
    DateTime? now,
  }) {
    if (id.isEmpty || timestamp.isEmpty || signatureHeader.isEmpty) {
      return false;
    }

    final ts = int.tryParse(timestamp);
    if (ts == null) return false;
    final delivered = DateTime.fromMillisecondsSinceEpoch(
      ts * 1000,
      isUtc: true,
    );
    final reference = (now ?? DateTime.now()).toUtc();
    if (reference.difference(delivered).abs() > _tolerance) return false;

    final signedContent = '$id.$timestamp.$rawBody';
    final expected = base64.encode(
      Hmac(sha256, _key).convert(utf8.encode(signedContent)).bytes,
    );

    // Standard Webhooks defines the header as whitespace-separated; use
    // a regex split to be robust against double-spaces / tab insertions
    // some intermediaries introduce.
    for (final entry in signatureHeader.split(RegExp(r'\s+'))) {
      if (!entry.startsWith('v1,')) continue;
      if (_constantTimeEquals(entry.substring('v1,'.length), expected)) {
        return true;
      }
    }
    return false;
  }

  /// Polar / Standard Webhooks secrets ship as `whsec_<base64>`; the
  /// leading scheme is stripped and the base64 body is decoded to raw
  /// key bytes. Secrets that aren't `whsec_`-prefixed are treated as
  /// raw UTF-8 strings (useful for dev environments where the operator
  /// supplied a plain secret).
  static List<int> _decodeSecret(String secret) {
    if (secret.startsWith('whsec_')) {
      return base64.decode(secret.substring('whsec_'.length));
    }
    return utf8.encode(secret);
  }

  /// Constant-time compare on equal-length strings. Both inputs here
  /// are base64-encoded SHA-256 outputs (always 44 chars including the
  /// trailing `=`), so the length-prefix check is safe.
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
