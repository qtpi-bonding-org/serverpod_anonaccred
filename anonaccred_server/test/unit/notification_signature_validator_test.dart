import 'dart:convert';
import 'dart:typed_data';
import 'package:anonaccred_server/src/payments/notification_signature_validator.dart';
import 'package:asn1lib/asn1lib.dart';
import 'package:crypto_keys/crypto_keys.dart';
import 'package:test/test.dart';
import '../test_helpers/apple_test_certificates.dart';

String _signingInput({required List<List<int>> x5c, String? kid}) {
  final header = {
    'alg': 'ES256',
    'x5c': x5c.map(base64.encode).toList(),
    if (kid != null) 'kid': kid,
  };
  final payload = {'notificationType': 'TEST', 'data': <String, dynamic>{}};
  final headerB64 = base64Url
      .encode(utf8.encode(jsonEncode(header)))
      .replaceAll('=', '');
  final payloadB64 = base64Url
      .encode(utf8.encode(jsonEncode(payload)))
      .replaceAll('=', '');
  return '$headerB64.$payloadB64';
}

String _fakeSignedPayload({required List<List<int>> x5c, String? kid}) {
  final signingInput = _signingInput(x5c: x5c, kid: kid);
  // Signature bytes are irrelevant for these rejection cases — an
  // invalid/absent chain must be rejected before signature bytes matter.
  return '$signingInput.${base64Url.encode([1, 2, 3])}';
}

/// Decodes a SEC1 `ECPrivateKey` DER blob (as produced by
/// `openssl ec ... -outform DER`) into a `crypto_keys` `EcPrivateKey` on
/// the P-256 curve, so tests can sign JWS payloads exactly like a real
/// certificate holder would.
EcPrivateKey _ecPrivateKeyFromDer(List<int> der) {
  final sequence =
      ASN1Parser(Uint8List.fromList(der)).nextObject() as ASN1Sequence;
  final privateKeyOctets = sequence.elements[1] as ASN1OctetString;
  final hex = privateKeyOctets
      .contentBytes()
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
  return EcPrivateKey(
    eccPrivateKey: BigInt.parse(hex, radix: 16),
    curve: curves.p256,
  );
}

String _signedPayload({
  required List<List<int>> x5c,
  required List<int> signingKeyDer,
  String? kid,
}) {
  final signingInput = _signingInput(x5c: x5c, kid: kid);
  final signer = _ecPrivateKeyFromDer(
    signingKeyDer,
  ).createSigner(algorithms.signing.ecdsa.sha256);
  final signature = signer.sign(utf8.encode(signingInput));
  final signatureB64 = base64Url.encode(signature.data).replaceAll('=', '');
  return '$signingInput.$signatureB64';
}

void main() {
  group('NotificationSignatureValidator x5c chain verification', () {
    test('rejects a chain that does not lead to the trusted root', () async {
      NotificationSignatureValidator.trustedRootDerOverride =
          AppleTestCertificates.rootDer;

      // A cert from a completely separate CA — not merely an incomplete
      // link in the trusted chain, but signed by an unrelated key the
      // trusted root never certified. The signature is genuinely valid
      // for this cert's own key, so this test can only pass if
      // chain-of-trust verification itself rejects the chain — a
      // hardcoded-true chain check would let this through.
      final signedPayload = _signedPayload(
        x5c: [AppleTestCertificates.unrelatedSelfSignedDer],
        signingKeyDer: AppleTestCertificates.unrelatedPrivateKeyDer,
      );

      final isValid = await NotificationSignatureValidator.validateSignature(
        signedPayload: signedPayload,
      );

      expect(isValid, isFalse);
      NotificationSignatureValidator.trustedRootDerOverride = null;
    });

    test(
      'does not require a kid header (sandbox notifications omit it)',
      () async {
        NotificationSignatureValidator.trustedRootDerOverride =
            AppleTestCertificates.rootDer;
        final signedPayload = _fakeSignedPayload(
          x5c: [
            AppleTestCertificates.leafDer,
            AppleTestCertificates.intermediateDer,
          ],
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
      },
    );

    test('accepts a genuinely valid chain and signature', () async {
      NotificationSignatureValidator.trustedRootDerOverride =
          AppleTestCertificates.rootDer;

      final signedPayload = _signedPayload(
        x5c: [
          AppleTestCertificates.leafDer,
          AppleTestCertificates.intermediateDer,
        ],
        signingKeyDer: AppleTestCertificates.leafPrivateKeyDer,
      );

      final isValid = await NotificationSignatureValidator.validateSignature(
        signedPayload: signedPayload,
      );

      expect(isValid, isTrue);
      NotificationSignatureValidator.trustedRootDerOverride = null;
    });

    test(
      'rejects a chain whose intermediate lacks basicConstraints CA:TRUE',
      () async {
        NotificationSignatureValidator.trustedRootDerOverride =
            AppleTestCertificates.rootDer;

        final signedPayload = _signedPayload(
          x5c: [
            AppleTestCertificates.leafSignedByNonCaIntermediateDer,
            AppleTestCertificates.nonCaIntermediateDer,
          ],
          signingKeyDer:
              AppleTestCertificates.leafSignedByNonCaIntermediatePrivateKeyDer,
        );

        final isValid = await NotificationSignatureValidator.validateSignature(
          signedPayload: signedPayload,
        );

        expect(isValid, isFalse);
        NotificationSignatureValidator.trustedRootDerOverride = null;
      },
    );

    test('rejects a chain whose leaf certificate has expired', () async {
      NotificationSignatureValidator.trustedRootDerOverride =
          AppleTestCertificates.rootDer;

      final signedPayload = _signedPayload(
        x5c: [
          AppleTestCertificates.expiredLeafDer,
          AppleTestCertificates.intermediateDer,
        ],
        signingKeyDer: AppleTestCertificates.expiredLeafPrivateKeyDer,
      );

      final isValid = await NotificationSignatureValidator.validateSignature(
        signedPayload: signedPayload,
      );

      expect(isValid, isFalse);
      NotificationSignatureValidator.trustedRootDerOverride = null;
    });
  });
}
