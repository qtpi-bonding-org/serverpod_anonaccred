import 'dart:convert';

import 'package:anonaccred_server/src/payments/polar_signature_validator.dart';
import 'package:crypto/crypto.dart';
import 'package:test/test.dart';

String _sign({
  required String secret,
  required String id,
  required String timestamp,
  required String body,
}) {
  final key = secret.startsWith('whsec_')
      ? base64.decode(secret.substring('whsec_'.length))
      : utf8.encode(secret);
  final signed = '$id.$timestamp.$body';
  return 'v1,${base64.encode(Hmac(sha256, key).convert(utf8.encode(signed)).bytes)}';
}

void main() {
  group('PolarSignatureValidator', () {
    const secret =
        'whsec_VGhpc0lzQVNlY3JldFRoYXRJc1ByZXR0eUxvbmdGb3JIbWFjVGVzdGluZw==';
    final fixedNow = DateTime.utc(2026, 5, 19, 12, 0, 0);
    final ts = (fixedNow.millisecondsSinceEpoch ~/ 1000).toString();
    const id = 'msg_01HXYZ';
    const body = '{"type":"refund.created","data":{}}';

    test('accepts correctly signed delivery within window', () {
      final v = PolarSignatureValidator(secret: secret);
      final sig = _sign(secret: secret, id: id, timestamp: ts, body: body);
      expect(
        v.verify(
          id: id,
          timestamp: ts,
          signatureHeader: sig,
          rawBody: body,
          now: fixedNow,
        ),
        isTrue,
      );
    });

    test('rejects tampered body', () {
      final v = PolarSignatureValidator(secret: secret);
      final sig = _sign(secret: secret, id: id, timestamp: ts, body: body);
      expect(
        v.verify(
          id: id,
          timestamp: ts,
          signatureHeader: sig,
          rawBody: '$body ',
          now: fixedNow,
        ),
        isFalse,
      );
    });

    test('rejects tampered signature', () {
      final v = PolarSignatureValidator(secret: secret);
      final bogus = 'v1,${base64.encode(List<int>.filled(32, 0))}';
      expect(
        v.verify(
          id: id,
          timestamp: ts,
          signatureHeader: bogus,
          rawBody: body,
          now: fixedNow,
        ),
        isFalse,
      );
    });

    test('rejects out-of-window delivery', () {
      final v = PolarSignatureValidator(
        secret: secret,
        tolerance: const Duration(minutes: 1),
      );
      final sig = _sign(secret: secret, id: id, timestamp: ts, body: body);
      expect(
        v.verify(
          id: id,
          timestamp: ts,
          signatureHeader: sig,
          rawBody: body,
          now: fixedNow.add(const Duration(minutes: 5)),
        ),
        isFalse,
      );
    });

    test('accepts second of two rotation signatures', () {
      final v = PolarSignatureValidator(secret: secret);
      final goodSig =
          _sign(secret: secret, id: id, timestamp: ts, body: body);
      final old = 'v1,${base64.encode(List<int>.filled(32, 1))}';
      expect(
        v.verify(
          id: id,
          timestamp: ts,
          signatureHeader: '$old $goodSig',
          rawBody: body,
          now: fixedNow,
        ),
        isTrue,
      );
    });

    test('rejects missing headers', () {
      final v = PolarSignatureValidator(secret: secret);
      expect(
        v.verify(
          id: '',
          timestamp: ts,
          signatureHeader: 'v1,sig',
          rawBody: body,
          now: fixedNow,
        ),
        isFalse,
      );
    });

    test('handles raw (non-whsec_) secrets', () {
      const rawSecret = 'plain-dev-secret';
      final v = PolarSignatureValidator(secret: rawSecret);
      final sig =
          _sign(secret: rawSecret, id: id, timestamp: ts, body: body);
      expect(
        v.verify(
          id: id,
          timestamp: ts,
          signatureHeader: sig,
          rawBody: body,
          now: fixedNow,
        ),
        isTrue,
      );
    });
  });
}
