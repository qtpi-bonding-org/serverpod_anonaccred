import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:crypto/crypto.dart';
import 'package:crypto_keys/crypto_keys.dart';

import '../../test_helpers/apple_test_certificates.dart';
import '../../test_helpers/google_test_oidc.dart';

/// Produces genuinely, correctly signed webhook payloads for all three
/// payment rails (Apple, Polar, Google) so flow tests can drive the real
/// webhook routes end-to-end without live provider APIs.
class WebhookSigner {
  static String appleNotification(Map<String, dynamic> payload) {
    final header = {
      'alg': 'ES256',
      'x5c': [
        base64.encode(AppleTestCertificates.leafDer),
        base64.encode(AppleTestCertificates.intermediateDer),
      ],
    };
    final headerB64 = base64Url.encode(utf8.encode(jsonEncode(header))).replaceAll('=', '');
    final payloadB64 = base64Url.encode(utf8.encode(jsonEncode(payload))).replaceAll('=', '');
    final signingInput = '$headerB64.$payloadB64';
    final signatureB64 = _signWithLeafKey(signingInput);
    return jsonEncode({'signedPayload': '$signingInput.$signatureB64'});
  }

  static ({String requestBody, Map<String, String> headers}) polarWebhook({
    required String secret,
    required Map<String, dynamic> payload,
    String id = 'wh-test-1',
    // PolarSignatureValidator.verify() rejects deliveries whose timestamp
    // falls outside a tolerance window measured against wall-clock "now",
    // so the default here tracks the real clock rather than a fixed value.
    String? timestamp,
  }) {
    final ts = timestamp ?? (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000).toString();
    final rawBody = jsonEncode(payload);
    final key =
        secret.startsWith('whsec_') ? base64.decode(secret.substring('whsec_'.length)) : utf8.encode(secret);
    final signedContent = '$id.$ts.$rawBody';
    final sig = base64.encode(Hmac(sha256, key).convert(utf8.encode(signedContent)).bytes);
    return (
      requestBody: rawBody,
      headers: {'webhook-id': id, 'webhook-timestamp': ts, 'webhook-signature': 'v1,$sig'},
    );
  }

  static ({String requestBody, String authorizationHeader}) googlePubSubPush({
    required Map<String, dynamic> notification,
    required String audience,
  }) {
    final data = base64.encode(utf8.encode(jsonEncode(notification)));
    final requestBody = jsonEncode({
      'message': {'data': data, 'messageId': 'test-msg-1'},
      'subscription': 'projects/test/subscriptions/test',
    });
    final token = GoogleTestOidc.signToken(audience: audience);
    return (requestBody: requestBody, authorizationHeader: 'Bearer $token');
  }

  /// Decodes the SEC1 `ECPrivateKey` DER blob for the Task 3 test leaf
  /// cert and signs with it, matching the pattern
  /// `notification_signature_validator_test.dart` uses to produce real
  /// signatures over its own fake payloads (`_ecPrivateKeyFromDer` /
  /// `_signedPayload`).
  static String _signWithLeafKey(String signingInput) {
    final signer = _leafPrivateKey.createSigner(algorithms.signing.ecdsa.sha256);
    final signature = signer.sign(utf8.encode(signingInput));
    return base64Url.encode(signature.data).replaceAll('=', '');
  }

  static EcPrivateKey get _leafPrivateKey {
    final der = AppleTestCertificates.leafPrivateKeyDer;
    final sequence = ASN1Parser(Uint8List.fromList(der)).nextObject() as ASN1Sequence;
    final privateKeyOctets = sequence.elements[1] as ASN1OctetString;
    final hex = privateKeyOctets.contentBytes().map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return EcPrivateKey(eccPrivateKey: BigInt.parse(hex, radix: 16), curve: curves.p256);
  }
}
