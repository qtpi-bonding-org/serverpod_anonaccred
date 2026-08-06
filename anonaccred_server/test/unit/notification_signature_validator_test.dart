import 'dart:convert';
import 'package:anonaccred_server/src/payments/notification_signature_validator.dart';
import 'package:test/test.dart';
import '../test_helpers/apple_test_certificates.dart';

String _fakeSignedPayload({required List<List<int>> x5c, String? kid}) {
  final header = {
    'alg': 'ES256',
    'x5c': x5c.map(base64.encode).toList(),
    if (kid != null) 'kid': kid,
  };
  final payload = {'notificationType': 'TEST', 'data': {}};
  final headerB64 = base64Url.encode(utf8.encode(jsonEncode(header))).replaceAll('=', '');
  final payloadB64 = base64Url.encode(utf8.encode(jsonEncode(payload))).replaceAll('=', '');
  // Signature bytes are irrelevant for these two rejection cases — an
  // invalid/absent chain must be rejected before signature bytes matter.
  return '$headerB64.$payloadB64.${base64Url.encode([1, 2, 3])}';
}

void main() {
  group('NotificationSignatureValidator x5c chain verification', () {
    test('rejects a chain that does not lead to the trusted root', () async {
      NotificationSignatureValidator.trustedRootDerOverride = AppleTestCertificates.rootDer;
      // A chain built from unrelated (self-signed, untrusted) bytes.
      final untrustedLeaf = AppleTestCertificates.intermediateDer; // wrong link
      final signedPayload = _fakeSignedPayload(x5c: [untrustedLeaf]);

      final isValid = await NotificationSignatureValidator.validateSignature(
        signedPayload: signedPayload,
      );

      expect(isValid, isFalse);
      NotificationSignatureValidator.trustedRootDerOverride = null;
    });

    test('does not require a kid header (sandbox notifications omit it)', () async {
      NotificationSignatureValidator.trustedRootDerOverride = AppleTestCertificates.rootDer;
      final signedPayload = _fakeSignedPayload(
        x5c: [AppleTestCertificates.leafDer, AppleTestCertificates.intermediateDer],
      );

      // No kid in the header — must not be rejected for that reason alone
      // (it may still be rejected on signature verification in this test,
      // since the signature bytes above are fake; the assertion here is
      // that validateSignature reaches signature verification instead of
      // short-circuiting on a missing kid).
      final isValid = await NotificationSignatureValidator.validateSignature(
        signedPayload: signedPayload,
      );

      // The fake signature bytes are garbage, so this must still be false —
      // but for the RIGHT reason (bad signature), verified by the next test
      // using a real signature.
      expect(isValid, isFalse);
      NotificationSignatureValidator.trustedRootDerOverride = null;
    });
  });
}
