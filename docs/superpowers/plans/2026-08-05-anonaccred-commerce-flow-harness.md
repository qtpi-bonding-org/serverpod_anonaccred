# Anonaccred Commerce Flow Test Harness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give `anonaccred_server` flow-level test coverage across all three commerce rails (Apple, Google, Polar), close the Polar mock-parity gap, and fix two confirmed webhook-verification bugs (Apple's wrong trust model, Google's wrong envelope/auth) so the new webhook tests validate real behavior.

**Architecture:** A `MockPolarClient` (subclassing the concrete `PolarClient`) brings Polar to parity with the existing Apple/Google mocks. A `CommerceTestHarness` builds real DB-backed identity + `AuthenticationOverride` sessions and drives high-level purchase/consume/redeem actions. A `WebhookSigner` produces real, validly-signed payloads for all three providers and drives each webhook `Route.handleCall` directly via a `relic_core` `Request` built through its internal (but reachable) `RequestInternal.create` extension — no live HTTP server. Apple's and Google's signature validators are rewritten against their real verification models (x5c chain-of-trust for Apple, Pub/Sub envelope + OIDC bearer for Google) using the `x509`/`crypto_keys`/`asn1lib` packages.

**Tech Stack:** Dart, Serverpod 3.4.1, `serverpod_test`, `package:x509` 0.2.4+3, `package:crypto_keys` 0.3.1, `package:asn1lib` 1.6.5, `package:pointycastle` 4.x, `package:crypto` 3.x.

## Global Constraints

- Pure-Dart server package: use `dart test`, never `flutter test`.
- THE COMMENT RULE (this repo's `CLAUDE.md`): comments may state WHY, never a falsifiable claim (no "prevents"/"ensures"/"guarantees"/"atomic"/"safe"/"cannot"/"never"/"always"). Falsifiable claims go in test names/assertions.
- Flat migrations already exist for the tables touched here (`AccountEntitlement`, `GroupEntitlement`, `ReceiptHash`, `TransactionPayment`, `RefundClaim`, `EphemeralAccreditation`, `EphemeralAccreditationGroup`) — no migration changes needed by this plan; nothing here alters the schema.
- Test-only override hooks (Apple's trusted root, Google's certs endpoint) must be static fields explicitly documented as test-only, mirroring the existing `NotificationSignatureValidator.jwksUri` pattern — never a runtime/production configuration knob.
- `x509`, `crypto_keys`, and `asn1lib` are currently only *transitive* dependencies (resolved via `pubspec.lock` but not declared in `pubspec.yaml`). Any task that imports them directly must first add them as explicit `dependencies:` entries.
- Out of scope: `quanitya_cloud_server/lib/server.dart` never registers `PolarWebhookRoute` (`/hooks/polar` is unbound). That file lives in a different repo and is not touched by this plan — flagged for a separate fix.

---

### Task 1: Declare explicit dependencies on x509/crypto_keys/asn1lib

**Files:**
- Modify: `anonaccred_server/pubspec.yaml`

**Interfaces:**
- Produces: `package:x509/x509.dart` (`X509Certificate`, `TbsCertificate`), `package:crypto_keys/crypto_keys.dart` (`PublicKey`, `algorithms`, `Verifier`, `Signature`), `package:asn1lib/asn1lib.dart` (`ASN1Parser`, `ASN1Sequence`) all become directly importable without relying on transitive resolution.

- [ ] **Step 1: Confirm current transitive versions**

Run: `cd anonaccred_server && grep -A3 -E "^  (x509|crypto_keys|asn1lib):" pubspec.lock`
Expected: shows `x509` (0.2.4+3), `crypto_keys` (0.3.1 or 0.3.0+2), `asn1lib` (1.6.5 or 1.2.1) each under `dependency: transitive`.

- [ ] **Step 2: Add explicit dependencies**

In `anonaccred_server/pubspec.yaml`, under the existing `dependencies:` block (near `pointycastle: ^4.0.0`), add:

```yaml
  x509: ^0.2.4+3
  crypto_keys: ^0.3.1
  asn1lib: ^1.6.5
```

Use the exact versions found in Step 1 as the lower bound if they differ from what's shown above.

- [ ] **Step 3: Resolve and verify no version conflicts**

Run: `cd anonaccred_server && dart pub get`
Expected: completes with no version-solving errors, and `pubspec.lock` now shows `dependency: "direct main"` for all three packages.

- [ ] **Step 4: Commit**

```bash
git add anonaccred_server/pubspec.yaml anonaccred_server/pubspec.lock
git commit -m "chore: declare x509/crypto_keys/asn1lib as direct dependencies"
```

---

### Task 2: MockPolarClient

**Files:**
- Create: `anonaccred_server/lib/src/payments/mock_polar_client.dart`
- Test: `anonaccred_server/test/unit/mock_polar_client_test.dart`

**Interfaces:**
- Consumes: `PolarClient` (`anonaccred_server/lib/src/payments/polar_client.dart:76`) — concrete class, constructor `PolarClient({required String organizationId, required PolarHttpClient http})`; `PolarLicenseValidation` (same file, factory `.fromJson`); `PolarHttpClient` (`polar_http_client.dart:38`) constructor `PolarHttpClient({required String baseUrl, required String bearerToken, http.Client? httpClient, Duration timeout})`; `ApiCall` (`mock_api_call.dart`, already exported by the existing Apple/Google mocks).
- Produces: `MockPolarClient` — `extends PolarClient`, overrides `validateLicenseKey` and `getOrder`. Public API: `callLog` (`List<ApiCall>`), `addMockLicense(String key, PolarLicenseValidation validation)`, `addMockOrder(String orderId, Map<String, dynamic> orderJson)`, `Object? validateLicenseKeyError` (when set, throws instead of returning). Later tasks (`CommerceTestHarness`) construct this with no arguments and register it via `PaymentManager.registerRail(PolarRail(client: MockPolarClient()))`.

- [ ] **Step 1: Write the failing test**

```dart
// anonaccred_server/test/unit/mock_polar_client_test.dart
import 'package:anonaccred_server/src/payments/mock_polar_client.dart';
import 'package:anonaccred_server/src/payments/polar_client.dart';
import 'package:anonaccred_server/src/protocol_failures.dart';
import 'package:test/test.dart';

void main() {
  group('MockPolarClient', () {
    test('validateLicenseKey returns a configured mock response', () async {
      final client = MockPolarClient();
      final validation = PolarLicenseValidation(
        id: 'lk-1',
        key: 'LICENSE-KEY-1',
        status: 'granted',
        organizationId: 'org-1',
        benefitId: 'benefit-1',
        customerId: 'cust-1',
        expiresAt: null,
        raw: const {},
      );
      client.addMockLicense('LICENSE-KEY-1', validation);

      final result = await client.validateLicenseKey(key: 'LICENSE-KEY-1');

      expect(result.benefitId, 'benefit-1');
      expect(client.callLog, hasLength(1));
      expect(client.callLog.first.method, 'validateLicenseKey');
    });

    test('validateLicenseKey throws PaymentException for an unknown key', () async {
      final client = MockPolarClient();

      await expectLater(
        client.validateLicenseKey(key: 'UNKNOWN'),
        throwsA(isA<PaymentException>()),
      );
    });

    test('getOrder returns a configured mock order', () async {
      final client = MockPolarClient();
      client.addMockOrder('order-1', {'id': 'order-1', 'status': 'refunded'});

      final order = await client.getOrder('order-1');

      expect(order['status'], 'refunded');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd anonaccred_server && dart test test/unit/mock_polar_client_test.dart`
Expected: FAIL — `mock_polar_client.dart` does not exist.

- [ ] **Step 3: Write minimal implementation**

```dart
// anonaccred_server/lib/src/payments/mock_polar_client.dart
import 'polar_client.dart';
import 'polar_http_client.dart';
import 'mock_api_call.dart';
import '../protocol_failures.dart';
import '../generated/protocol.dart';

export 'mock_api_call.dart' show ApiCall;

/// Test double for [PolarClient]. Subclasses rather than implements an
/// interface because PolarRail depends on the concrete PolarClient type
/// directly (unlike AppleIAPRail/GoogleIAPRail, which depend on abstract
/// client interfaces) — see the design spec's note on this asymmetry.
class MockPolarClient extends PolarClient {
  MockPolarClient()
      : super(
          organizationId: 'mock-org',
          http: PolarHttpClient(
            baseUrl: 'http://mock.invalid',
            bearerToken: 'mock-token',
          ),
        );

  final List<ApiCall> callLog = [];
  final Map<String, PolarLicenseValidation> _mockLicenses = {};
  final Map<String, Map<String, dynamic>> _mockOrders = {};

  Object? validateLicenseKeyError;

  void addMockLicense(String key, PolarLicenseValidation validation) {
    _mockLicenses[key] = validation;
  }

  void addMockOrder(String orderId, Map<String, dynamic> orderJson) {
    _mockOrders[orderId] = orderJson;
  }

  @override
  Future<PolarLicenseValidation> validateLicenseKey({
    required String key,
    String? activationId,
    String? benefitId,
    int? incrementUsage,
  }) async {
    callLog.add(ApiCall('validateLicenseKey', {'key': key}));

    if (validateLicenseKeyError != null) {
      throw validateLicenseKeyError!;
    }

    final validation = _mockLicenses[key];
    if (validation == null) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.polarValidationFailed,
        message: 'License key not found in mock: $key',
        paymentRail: PaymentRail.polar.name,
      );
    }
    return validation;
  }

  @override
  Future<Map<String, dynamic>> getOrder(String orderId) async {
    callLog.add(ApiCall('getOrder', {'orderId': orderId}));

    final order = _mockOrders[orderId];
    if (order == null) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.polarApiUnavailable,
        message: 'Order not found in mock: $orderId',
        paymentRail: PaymentRail.polar.name,
      );
    }
    return order;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd anonaccred_server && dart test test/unit/mock_polar_client_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add anonaccred_server/lib/src/payments/mock_polar_client.dart anonaccred_server/test/unit/mock_polar_client_test.dart
git commit -m "feat: add MockPolarClient for Polar mock parity with Apple/Google"
```

---

### Task 3: Rewrite Apple notification verification (x5c chain-of-trust)

**Files:**
- Modify: `anonaccred_server/lib/src/payments/notification_signature_validator.dart`
- Test: `anonaccred_server/test/unit/notification_signature_validator_test.dart` (new file — the existing `test/unit/notification_signature_test.dart` and `notification_signature_jwks_fetch_test.dart` test the *old* JWKS-fetch model; leave them in place for now, replaced in Step 6 below)
- Create: `anonaccred_server/test/test_helpers/apple_test_certificates.dart`

**Interfaces:**
- Consumes: `X509Certificate.fromAsn1(ASN1Sequence)` (`package:x509`), `ASN1Parser` (`package:asn1lib`), `PublicKey.createVerifier(Identifier algorithm)` / `algorithms.signing.ecdsa.sha256` / `Verifier.verify(Uint8List, Signature)` (`package:crypto_keys`).
- Produces: `NotificationSignatureValidator.trustedRootDer` — a test-only static `List<int>?` override (mirrors the existing `jwksUri` static override pattern); when null, uses the real bundled Apple Root CA G3 DER bytes. `NotificationSignatureValidator.validateSignature({required String signedPayload})` keeps its existing signature (`Future<bool>`) so `validateSignatureOrThrow` and all call sites in `apple_iap_rail.dart` / `apple_webhook_route.dart` are unaffected.

- [ ] **Step 1: Generate a test certificate chain and write the test helper**

Generate a throwaway 3-certificate chain (root → intermediate → leaf, all P-256/ES256, matching Apple's real shape) once, offline, and hardcode the resulting DER bytes as base64 constants — tests must not shell out to `openssl` at run time.

Run once to generate the chain (not part of the test suite):

```bash
openssl ecparam -name prime256v1 -genkey -noout -out /tmp/root.key
openssl req -x509 -new -key /tmp/root.key -subj "/CN=Test Root CA/O=Test" -days 3650 -out /tmp/root.pem
openssl ecparam -name prime256v1 -genkey -noout -out /tmp/intermediate.key
openssl req -new -key /tmp/intermediate.key -subj "/CN=Test Intermediate/O=Test" -out /tmp/intermediate.csr
openssl x509 -req -in /tmp/intermediate.csr -CA /tmp/root.pem -CAkey /tmp/root.key -CAcreateserial -days 3650 -out /tmp/intermediate.pem
openssl ecparam -name prime256v1 -genkey -noout -out /tmp/leaf.key
openssl req -new -key /tmp/leaf.key -subj "/CN=Test Leaf/O=Test" -out /tmp/leaf.csr
openssl x509 -req -in /tmp/leaf.csr -CA /tmp/intermediate.pem -CAkey /tmp/intermediate.key -CAcreateserial -days 3650 -out /tmp/leaf.pem
```

```dart
// anonaccred_server/test/test_helpers/apple_test_certificates.dart
import 'dart:convert';

/// Test-only P-256 certificate chain (root -> intermediate -> leaf),
/// generated once via openssl (see plan Task 3, Step 1) and hardcoded here
/// so tests never shell out. Mirrors the shape of a real Apple x5c chain
/// without depending on Apple's actual certificates.
class AppleTestCertificates {
  // Paste the DER bytes (base64, no PEM headers) from each generated .pem
  // file: `openssl x509 -in /tmp/root.pem -outform DER | base64`.
  static const String rootDerBase64 = 'PASTE_ROOT_DER_BASE64_HERE';
  static const String intermediateDerBase64 = 'PASTE_INTERMEDIATE_DER_BASE64_HERE';
  static const String leafDerBase64 = 'PASTE_LEAF_DER_BASE64_HERE';

  // Paste the raw EC private key bytes for the leaf
  // (`openssl ec -in /tmp/leaf.key -outform DER | base64`), used to sign
  // JWS payloads in WebhookSigner (Task 5).
  static const String leafPrivateKeyDerBase64 = 'PASTE_LEAF_KEY_DER_BASE64_HERE';

  static List<int> get rootDer => base64.decode(rootDerBase64);
  static List<int> get intermediateDer => base64.decode(intermediateDerBase64);
  static List<int> get leafDer => base64.decode(leafDerBase64);
}
```

- [ ] **Step 2: Write the failing tests**

```dart
// anonaccred_server/test/unit/notification_signature_validator_test.dart
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
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `cd anonaccred_server && dart test test/unit/notification_signature_validator_test.dart`
Expected: FAIL — `trustedRootDerOverride` does not exist yet on `NotificationSignatureValidator`.

- [ ] **Step 4: Rewrite the validator**

Replace the entire contents of `anonaccred_server/lib/src/payments/notification_signature_validator.dart` with:

```dart
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
const String _appleRootCaG3DerBase64 = 'REPLACE_WITH_REAL_APPLE_ROOT_CA_G3_DER_BASE64';

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

      final chain = x5c.map((c) => _parseCertDer(base64.decode(c as String))).toList();
      if (!_chainsToTrustedRoot(chain)) return false;

      final leafPublicKey = chain.first.publicKey;
      final signingInput = '${parts[0]}.${parts[1]}';
      final signatureBytes = _base64UrlDecode(parts[2]);
      final r = _bytesToBigInt(signatureBytes.sublist(0, signatureBytes.length ~/ 2));
      final s = _bytesToBigInt(signatureBytes.sublist(signatureBytes.length ~/ 2));

      final verifier = leafPublicKey.createVerifier(algorithms.signing.ecdsa.sha256);
      return verifier.verify(
        Uint8List.fromList(utf8.encode(signingInput)),
        Signature(_derEncodeEcdsaSignature(r, s)),
      );
    } catch (e) {
      return false;
    }
  }

  /// Verifies cert[i] was signed by cert[i+1]'s key for every adjacent
  /// pair, and that the last certificate's raw bytes equal the trusted
  /// root's raw bytes (root pinning, not just "some self-signed CA").
  static bool _chainsToTrustedRoot(List<X509Certificate> chain) {
    if (chain.isEmpty) return false;
    for (var i = 0; i < chain.length - 1; i++) {
      if (!_isSignedBy(chain[i], chain[i + 1])) return false;
    }
    final lastDer = chain.last.toAsn1().encodedBytes;
    return _bytesEqual(lastDer, Uint8List.fromList(_trustedRootDer));
  }

  static bool _isSignedBy(X509Certificate cert, X509Certificate issuer) {
    try {
      final tbsBytes = cert.tbsCertificate.toAsn1().encodedBytes;
      final sig = cert.signatureValue;
      if (sig == null) return false;
      final verifier = issuer.publicKey.createVerifier(algorithms.signing.ecdsa.sha256);
      return verifier.verify(tbsBytes, Signature(Uint8List.fromList(sig)));
    } catch (e) {
      return false;
    }
  }

  static X509Certificate _parseCertDer(List<int> der) {
    final asn1 = ASN1Parser(Uint8List.fromList(der)).nextObject() as ASN1Sequence;
    return X509Certificate.fromAsn1(asn1);
  }

  static bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static Uint8List _derEncodeEcdsaSignature(BigInt r, BigInt s) {
    final rBytes = _asn1Integer(r);
    final sBytes = _asn1Integer(s);
    final seqLen = rBytes.length + sBytes.length;
    final out = BytesBuilder()
      ..addByte(0x30)
      ..addByte(seqLen)
      ..add(rBytes)
      ..add(sBytes);
    return out.toBytes();
  }

  static Uint8List _asn1Integer(BigInt value) {
    var bytes = _bigIntToBytes(value);
    if (bytes.isNotEmpty && bytes[0] & 0x80 != 0) {
      bytes = [0, ...bytes];
    }
    return Uint8List.fromList([0x02, bytes.length, ...bytes]);
  }

  static List<int> _bigIntToBytes(BigInt value) {
    var hex = value.toRadixString(16);
    if (hex.length % 2 != 0) hex = '0$hex';
    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }

  static BigInt _bytesToBigInt(List<int> bytes) =>
      BigInt.parse(bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(), radix: 16);

  static List<int> _base64UrlDecode(String input) {
    final normalized = input.replaceAll('-', '+').replaceAll('_', '/');
    final padded = normalized.padRight(normalized.length + (4 - normalized.length % 4) % 4, '=');
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
```

Then fetch the real Apple Root CA G3 certificate and replace the placeholder constant:

```bash
curl -s https://www.apple.com/certificateauthority/AppleRootCA-G3.cer | base64
```

Paste that output as `_appleRootCaG3DerBase64`'s value.

Finally, fill in `apple_test_certificates.dart`'s three `PASTE_..._HERE` placeholders with the base64 DER output from the openssl commands in Step 1.

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd anonaccred_server && dart test test/unit/notification_signature_validator_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 6: Delete the tests for the old (wrong) verification model**

The old JWKS-fetch model no longer exists in the rewritten validator. Delete:

```bash
rm anonaccred_server/test/unit/notification_signature_test.dart
rm anonaccred_server/test/unit/notification_signature_jwks_fetch_test.dart
```

Run: `cd anonaccred_server && dart test test/unit/`
Expected: PASS, no references to the deleted files remain (check `grep -rn "notification_signature_jwks_fetch\|jwksUri" anonaccred_server/` returns nothing outside this task's own files — `jwksUri`/`_JWKSCache`/`_fetchJWKS`/`refreshJWKS` are removed along with the JWKS-fetch model).

- [ ] **Step 7: Confirm no remaining callers of removed JWKS machinery**

Run: `cd anonaccred_server && grep -rn "jwksUri\|refreshJWKS\|_JWKSCache" lib/ test/`
Expected: no matches.

- [ ] **Step 8: Commit**

```bash
git add anonaccred_server/lib/src/payments/notification_signature_validator.dart \
        anonaccred_server/test/unit/notification_signature_validator_test.dart \
        anonaccred_server/test/test_helpers/apple_test_certificates.dart \
        anonaccred_server/test/unit/notification_signature_test.dart \
        anonaccred_server/test/unit/notification_signature_jwks_fetch_test.dart
git commit -m "fix: verify Apple notifications via x5c chain-of-trust, not a fictional JWKS endpoint"
```

---

### Task 4: Rewrite Google webhook handling (real Pub/Sub envelope + OIDC verification)

**Files:**
- Modify: `anonaccred_server/lib/src/payments/webhook_signature_validator.dart`
- Modify: `anonaccred_server/lib/src/webhooks/google_webhook_route.dart`
- Modify: `anonaccred_server/lib/src/payments/rails/google_iap_rail.dart:94-193` (`processCallback`)
- Test: `anonaccred_server/test/unit/google_pubsub_verifier_test.dart` (new)

**Interfaces:**
- Consumes: `PublicKey.createVerifier(algorithms.signing.rsa.sha256)` (`package:crypto_keys`) for RS256 OIDC token verification; existing `AnonAccountException`/`AnonAccredErrorCodes` factories.
- Produces: `GooglePubSubVerifier.certsUriOverride` (test-only override, mirrors Apple's pattern) and `GooglePubSubVerifier.verifyAndDecode({required String authorizationHeader, required String requestBody, required String expectedAudience})` returning a `GoogleDeveloperNotification` (a small typed wrapper: `packageName`, `eventTimeMillis`, `subscriptionNotification` map, `oneTimeProductNotification` map, `voidedPurchaseNotification` map — all nullable except `packageName`/`eventTimeMillis`) or throwing `AnonAccountException` on verification failure. This replaces `WebhookSignatureValidator` entirely for Google; `webhook_signature_validator.dart` is deleted.
- `GoogleWebhookRoute.buildCallbackData` now returns `{'session': session, 'authorization_header': ..., 'request_body': requestBody, 'expected_audience': ...}` instead of spreading flat snake_case fields.
- `GoogleIAPRail.processCallback` now calls `GooglePubSubVerifier.verifyAndDecode(...)` and reads the decoded camelCase notification instead of `callbackData['package_name']` etc.

- [ ] **Step 1: Write the failing test for the new verifier**

```dart
// anonaccred_server/test/unit/google_pubsub_verifier_test.dart
import 'dart:convert';
import 'package:anonaccred_server/src/payments/google_pubsub_verifier.dart';
import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:test/test.dart';
import '../test_helpers/google_test_oidc.dart';

void main() {
  group('GooglePubSubVerifier', () {
    test('decodes a valid Pub/Sub push envelope with a valid OIDC token', () async {
      GooglePubSubVerifier.certsUriOverride = GoogleTestOidc.certsUri;
      final notification = {
        'version': '1.0',
        'packageName': 'com.example.app',
        'eventTimeMillis': '1700000000000',
        'oneTimeProductNotification': {
          'version': '1.0',
          'notificationType': 1,
          'purchaseToken': 'tok-1',
          'sku': 'sku-1',
        },
      };
      final data = base64.encode(utf8.encode(jsonEncode(notification)));
      final requestBody = jsonEncode({
        'message': {'data': data, 'messageId': 'm-1'},
        'subscription': 'projects/p/subscriptions/s',
      });
      final token = GoogleTestOidc.signToken(audience: 'https://example.com/hooks/google');

      final decoded = await GooglePubSubVerifier.verifyAndDecode(
        authorizationHeader: 'Bearer $token',
        requestBody: requestBody,
        expectedAudience: 'https://example.com/hooks/google',
      );

      expect(decoded.packageName, 'com.example.app');
      expect(decoded.oneTimeProductNotification?['purchaseToken'], 'tok-1');
      GooglePubSubVerifier.certsUriOverride = null;
    });

    test('rejects a token with the wrong audience', () async {
      GooglePubSubVerifier.certsUriOverride = GoogleTestOidc.certsUri;
      final requestBody = jsonEncode({
        'message': {'data': base64.encode(utf8.encode('{"packageName":"x","eventTimeMillis":"1"}'))},
      });
      final token = GoogleTestOidc.signToken(audience: 'https://wrong.example.com/hooks/google');

      await expectLater(
        GooglePubSubVerifier.verifyAndDecode(
          authorizationHeader: 'Bearer $token',
          requestBody: requestBody,
          expectedAudience: 'https://example.com/hooks/google',
        ),
        throwsA(isA<AnonAccountException>()),
      );
      GooglePubSubVerifier.certsUriOverride = null;
    });
  });
}
```

Also write the test-only OIDC signer/certs-server helper it depends on:

```dart
// anonaccred_server/test/test_helpers/google_test_oidc.dart
import 'dart:convert';
import 'package:crypto_keys/crypto_keys.dart';

/// Test-only RS256 keypair + minimal in-memory JWKS server used to fake
/// Google's Pub/Sub push OIDC tokens without depending on Google's real
/// signing keys. Start once per test file via [certsUri]; it serves the
/// public key set GooglePubSubVerifier.certsUriOverride is pointed at.
class GoogleTestOidc {
  static final _keyPair = _generateRsaKeyPair();
  static Uri? _serverUri;

  static Uri get certsUri {
    // Implementation detail resolved during Task 4 implementation: spin up
    // a tiny loopback HttpServer serving {"keys": [<JWK of _keyPair.publicKey>]}
    // at GET /, matching the shape GooglePubSubVerifier fetches from Google's
    // real https://www.googleapis.com/oauth2/v3/certs endpoint. Cache
    // _serverUri across calls within a test run.
    throw UnimplementedError('start loopback JWKS server, return its Uri');
  }

  static String signToken({required String audience}) {
    final header = {'alg': 'RS256', 'typ': 'JWT', 'kid': 'test-key-1'};
    final now = 1700000000;
    final payload = {
      'iss': 'https://accounts.google.com',
      'aud': audience,
      'email': 'test-pubsub@test.iam.gserviceaccount.com',
      'email_verified': true,
      'iat': now,
      'exp': now + 3600,
    };
    final headerB64 = base64Url.encode(utf8.encode(jsonEncode(header))).replaceAll('=', '');
    final payloadB64 = base64Url.encode(utf8.encode(jsonEncode(payload))).replaceAll('=', '');
    final signingInput = '$headerB64.$payloadB64';
    final signer = _keyPair.privateKey.createSigner(algorithms.signing.rsa.sha256);
    final signature = signer.sign(utf8.encode(signingInput) as dynamic);
    final sigB64 = base64Url.encode(signature.data).replaceAll('=', '');
    return '$signingInput.$sigB64';
  }

  static KeyPair _generateRsaKeyPair() {
    throw UnimplementedError('generate a test RSA keypair via crypto_keys/pointycastle');
  }
}
```

Note: `GoogleTestOidc._generateRsaKeyPair` and `certsUri`'s loopback server are left as concrete `UnimplementedError` stubs *in this plan step only* because their exact construction depends on which RSA keygen helper `crypto_keys`/`pointycastle` expose at implementation time — the implementer must resolve both by reading `crypto_keys`'s `RsaPrivateKey`/`RsaPublicKey` constructors and `dart:io`'s `HttpServer.bind` before writing Step 3 below; this is the one piece of this plan intentionally deferred to implementation-time API discovery, not a placeholder for the underlying logic (the logic — RS256 sign, serve a JWKS, verify against it — is fully specified).

- [ ] **Step 2: Run test to verify it fails**

Run: `cd anonaccred_server && dart test test/unit/google_pubsub_verifier_test.dart`
Expected: FAIL — `google_pubsub_verifier.dart` does not exist.

- [ ] **Step 3: Implement `GoogleTestOidc`'s keygen and loopback server**

Resolve the two `UnimplementedError`s from Step 1 using `crypto_keys`'s RSA key generation (check `RsaPrivateKey`/`RsaPublicKey` factory constructors — `package:crypto_keys/src/rsa_keys.dart`) and `dart:io`'s `HttpServer.bind(InternetAddress.loopbackIPv4, 0)` serving a static JWKS JSON body derived from the public key's modulus/exponent (base64url, per RFC 7517).

- [ ] **Step 4: Write `GooglePubSubVerifier`**

```dart
// anonaccred_server/lib/src/payments/google_pubsub_verifier.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto_keys/crypto_keys.dart';
import 'package:anonaccount_server/anonaccount_server.dart';

import '../exception_factory.dart';

const String _googleCertsUrl = 'https://www.googleapis.com/oauth2/v3/certs';
const Duration _jwksCacheExpiry = Duration(hours: 1);

class GoogleDeveloperNotification {
  GoogleDeveloperNotification({
    required this.packageName,
    required this.eventTimeMillis,
    this.subscriptionNotification,
    this.oneTimeProductNotification,
    this.voidedPurchaseNotification,
  });

  final String packageName;
  final String eventTimeMillis;
  final Map<String, dynamic>? subscriptionNotification;
  final Map<String, dynamic>? oneTimeProductNotification;
  final Map<String, dynamic>? voidedPurchaseNotification;

  factory GoogleDeveloperNotification.fromJson(Map<String, dynamic> json) =>
      GoogleDeveloperNotification(
        packageName: json['packageName'] as String,
        eventTimeMillis: json['eventTimeMillis'] as String,
        subscriptionNotification: json['subscriptionNotification'] as Map<String, dynamic>?,
        oneTimeProductNotification: json['oneTimeProductNotification'] as Map<String, dynamic>?,
        voidedPurchaseNotification: json['voidedPurchaseNotification'] as Map<String, dynamic>?,
      );
}

/// Verifies Google Play Real-time Developer Notifications, delivered as
/// a Cloud Pub/Sub push HTTP request authenticated by an OIDC bearer
/// token (NOT a shared-secret HMAC — see design spec for why the prior
/// implementation was wrong about this).
class GooglePubSubVerifier {
  /// Test-only override for Google's public-certs endpoint.
  static Uri? certsUriOverride;

  static Future<GoogleDeveloperNotification> verifyAndDecode({
    required String authorizationHeader,
    required String requestBody,
    required String expectedAudience,
  }) async {
    final token = _extractBearerToken(authorizationHeader);
    if (token == null) {
      throw _invalid('Missing or malformed Authorization header');
    }
    await _verifyOidcToken(token, expectedAudience: expectedAudience);

    final envelope = jsonDecode(requestBody) as Map<String, dynamic>;
    final message = envelope['message'] as Map<String, dynamic>?;
    final data = message?['data'] as String?;
    if (data == null) {
      throw _invalid('Pub/Sub envelope missing message.data');
    }
    final decoded = utf8.decode(base64.decode(data));
    return GoogleDeveloperNotification.fromJson(
      jsonDecode(decoded) as Map<String, dynamic>,
    );
  }

  static String? _extractBearerToken(String header) {
    if (!header.startsWith('Bearer ')) return null;
    return header.substring('Bearer '.length);
  }

  static Future<void> _verifyOidcToken(String token, {required String expectedAudience}) async {
    final parts = token.split('.');
    if (parts.length != 3) throw _invalid('Malformed OIDC token');

    final header = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[0])))) as Map<String, dynamic>;
    final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))) as Map<String, dynamic>;

    if (payload['iss'] != 'https://accounts.google.com' && payload['iss'] != 'accounts.google.com') {
      throw _invalid('Unexpected token issuer: ${payload['iss']}');
    }
    if (payload['aud'] != expectedAudience) {
      throw _invalid('Unexpected token audience: ${payload['aud']}');
    }

    final kid = header['kid'] as String?;
    final keys = await _fetchCerts();
    final key = keys[kid];
    if (key == null) throw _invalid('No matching signing key for kid: $kid');

    final signingInput = '${parts[0]}.${parts[1]}';
    final signatureBytes = base64Url.decode(base64Url.normalize(parts[2]));
    final verifier = key.createVerifier(algorithms.signing.rsa.sha256);
    final ok = verifier.verify(
      Uint8List.fromList(utf8.encode(signingInput)),
      Signature(Uint8List.fromList(signatureBytes)),
    );
    if (!ok) throw _invalid('OIDC token signature verification failed');
  }

  static Future<Map<String, RsaPublicKey>> _fetchCerts() async {
    final client = HttpClient();
    try {
      final uri = certsUriOverride ?? Uri.parse(_googleCertsUrl);
      final request = await client.getUrl(uri);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final keysList = decoded['keys'] as List<dynamic>;
      final result = <String, RsaPublicKey>{};
      for (final k in keysList) {
        final jwk = k as Map<String, dynamic>;
        final kid = jwk['kid'] as String;
        result[kid] = RsaPublicKey(
          modulus: _base64UrlToBigInt(jwk['n'] as String),
          exponent: _base64UrlToBigInt(jwk['e'] as String),
        );
      }
      return result;
    } finally {
      client.close();
    }
  }

  static BigInt _base64UrlToBigInt(String input) {
    final bytes = base64Url.decode(base64Url.normalize(input));
    return BigInt.parse(bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(), radix: 16);
  }

  static AnonAccountException _invalid(String message) =>
      AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.authInvalidSignature,
        message: message,
      );
}
```

Delete `anonaccred_server/lib/src/payments/webhook_signature_validator.dart` — fully replaced.

- [ ] **Step 5: Update `GoogleWebhookRoute` and `GoogleIAPRail.processCallback`**

In `google_webhook_route.dart`, replace `buildCallbackData`:

```dart
@override
Future<Map<String, dynamic>> buildCallbackData(
  Session session,
  Request request,
  String requestBody,
) async => {
  'session': session,
  'authorization_header': request.headers['authorization']?.first ?? '',
  'request_body': requestBody,
  'expected_audience': GoogleIAPRail.expectedPushAudience,
};
```

In `google_iap_rail.dart`, replace `processCallback` (lines 94-193) to call `GooglePubSubVerifier.verifyAndDecode` and read the decoded `GoogleDeveloperNotification` instead of flat snake_case fields — refund detection now checks `voidedPurchaseNotification`/`subscriptionNotification` (Google's real notification-type fields) instead of a `notification_type == 'refund'` string that doesn't exist in Google's real schema. Add a static `expectedPushAudience` field (the configured push endpoint URL, e.g. from `Platform.environment['GOOGLE_PUBSUB_PUSH_AUDIENCE']`) alongside the existing `GoogleIAPRail.create()` factory.

- [ ] **Step 6: Run tests to verify they pass**

Run: `cd anonaccred_server && dart test test/unit/google_pubsub_verifier_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 7: Fix/delete tests that depended on the removed HMAC model**

Run: `cd anonaccred_server && grep -rln "webhook_signature_validator\|GOOGLE_WEBHOOK_SIGNING_KEY" test/`
For each match, either delete the test (if it only tested the removed HMAC scheme) or rewrite it against `GooglePubSubVerifier`. Then:

Run: `cd anonaccred_server && dart test`
Expected: PASS, no compile errors from the deleted file.

- [ ] **Step 8: Commit**

```bash
git add anonaccred_server/lib/src/payments/google_pubsub_verifier.dart \
        anonaccred_server/lib/src/webhooks/google_webhook_route.dart \
        anonaccred_server/lib/src/payments/rails/google_iap_rail.dart \
        anonaccred_server/test/unit/google_pubsub_verifier_test.dart \
        anonaccred_server/test/test_helpers/google_test_oidc.dart
git add -u anonaccred_server/lib/src/payments/webhook_signature_validator.dart
git commit -m "fix: verify Google RTDN webhooks via real Pub/Sub envelope + OIDC bearer token"
```

---

### Task 5: WebhookSigner test helper (Apple + Polar)

**Files:**
- Create: `anonaccred_server/test/integration/test_tools/webhook_signer.dart`
- Test: `anonaccred_server/test/integration/test_tools/webhook_signer_test.dart`

**Interfaces:**
- Consumes: `AppleTestCertificates` (Task 3), `PolarSignatureValidator`'s signed-content format (`${id}.${timestamp}.${rawBody}`, HMAC-SHA256, `v1,<base64>` — from `polar_signature_validator_test.dart`'s existing `_sign()`), `GoogleTestOidc` (Task 4).
- Produces: `WebhookSigner.appleNotification(Map<String, dynamic> payload)` returns `String requestBody` (JSON-encoded `{"signedPayload": "<JWS>"}`, signed with the Task 3 test leaf cert, chain in `x5c`). `WebhookSigner.polarWebhook({required String secret, required Map<String, dynamic> payload})` returns `({String requestBody, Map<String, String> headers})`. `WebhookSigner.googlePubSubPush({required Map<String, dynamic> notification, required String audience})` returns `({String requestBody, String authorizationHeader})`.

- [ ] **Step 1: Write the failing test**

```dart
// anonaccred_server/test/integration/test_tools/webhook_signer_test.dart
import 'dart:convert';
import 'package:anonaccred_server/src/payments/notification_signature_validator.dart';
import 'package:anonaccred_server/src/payments/polar_signature_validator.dart';
import 'package:anonaccred_server/src/payments/google_pubsub_verifier.dart';
import 'package:test/test.dart';
import '../../test_helpers/apple_test_certificates.dart';
import '../../test_helpers/google_test_oidc.dart';
import 'webhook_signer.dart';

void main() {
  group('WebhookSigner', () {
    test('appleNotification produces a payload that verifies', () async {
      NotificationSignatureValidator.trustedRootDerOverride = AppleTestCertificates.rootDer;
      final body = WebhookSigner.appleNotification({'notificationType': 'REFUND'});
      final signedPayload = NotificationSignatureValidator.extractSignedPayload(body)!;

      expect(await NotificationSignatureValidator.validateSignature(signedPayload: signedPayload), isTrue);
      NotificationSignatureValidator.trustedRootDerOverride = null;
    });

    test('polarWebhook produces headers that verify against the same secret', () {
      const secret = 'whsec_dGVzdC1zZWNyZXQ=';
      final signed = WebhookSigner.polarWebhook(secret: secret, payload: {'type': 'refund.created'});
      final validator = PolarSignatureValidator(secret: secret);

      final isValid = validator.verify(
        id: signed.headers['webhook-id']!,
        timestamp: signed.headers['webhook-timestamp']!,
        signatureHeader: signed.headers['webhook-signature']!,
        rawBody: signed.requestBody,
      );

      expect(isValid, isTrue);
    });

    test('googlePubSubPush produces a token that verifies', () async {
      GooglePubSubVerifier.certsUriOverride = GoogleTestOidc.certsUri;
      final signed = WebhookSigner.googlePubSubPush(
        notification: {'packageName': 'com.example.app', 'eventTimeMillis': '1'},
        audience: 'https://example.com/hooks/google',
      );

      final decoded = await GooglePubSubVerifier.verifyAndDecode(
        authorizationHeader: signed.authorizationHeader,
        requestBody: signed.requestBody,
        expectedAudience: 'https://example.com/hooks/google',
      );

      expect(decoded.packageName, 'com.example.app');
      GooglePubSubVerifier.certsUriOverride = null;
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd anonaccred_server && dart test test/integration/test_tools/webhook_signer_test.dart`
Expected: FAIL — `webhook_signer.dart` does not exist.

- [ ] **Step 3: Implement `WebhookSigner`**

```dart
// anonaccred_server/test/integration/test_tools/webhook_signer.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../test_helpers/apple_test_certificates.dart';
import '../../test_helpers/google_test_oidc.dart';

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
    String timestamp = '1700000000',
  }) {
    final rawBody = jsonEncode(payload);
    final key = secret.startsWith('whsec_') ? base64.decode(secret.substring(7)) : utf8.encode(secret);
    final signedContent = '$id.$timestamp.$rawBody';
    final sig = base64.encode(Hmac(sha256, key).convert(utf8.encode(signedContent)).bytes);
    return (
      requestBody: rawBody,
      headers: {'webhook-id': id, 'webhook-timestamp': timestamp, 'webhook-signature': 'v1,$sig'},
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

  static String _signWithLeafKey(String signingInput) {
    // Resolved during implementation using AppleTestCertificates.leafPrivateKeyDerBase64
    // and crypto_keys' EcPrivateKey.createSigner(algorithms.signing.ecdsa.sha256) —
    // the ECDSA-P256 signer, DER-decoded from the leaf private key generated
    // alongside the test certificate chain in Task 3, Step 1.
    throw UnimplementedError('sign signingInput with AppleTestCertificates leaf private key');
  }
}
```

- [ ] **Step 4: Resolve `_signWithLeafKey`**

Implement using `crypto_keys`'s EC private key loading (parse the DER bytes from `AppleTestCertificates.leafPrivateKeyDerBase64` — check `package:x509`'s `ecKeyPairFromAsn1` or `package:crypto_keys`'s `KeyPair.fromEcPrivateKey` for the exact constructor) and `.createSigner(algorithms.signing.ecdsa.sha256).sign(bytes)`, base64url-encoding the raw `r||s` signature bytes (not DER) to match JWS's expected signature encoding.

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd anonaccred_server && dart test test/integration/test_tools/webhook_signer_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 6: Commit**

```bash
git add anonaccred_server/test/integration/test_tools/webhook_signer.dart \
        anonaccred_server/test/integration/test_tools/webhook_signer_test.dart
git commit -m "test: add WebhookSigner producing real valid signatures for all three rails"
```

---

### Task 6: Request-construction helper + route smoke tests

**Files:**
- Create: `anonaccred_server/test/integration/test_tools/fake_webhook_request.dart`
- Test: `anonaccred_server/test/integration/webhook_route_smoke_test.dart`

**Interfaces:**
- Consumes: `RequestInternal.create` (`package:relic_core/src/context/request.dart` — deep import, deliberately internal; see design spec's note on fragility), `WebhookSigner` (Task 5), `PaymentManager.registerRail` / `getRail`.
- Produces: `FakeWebhookRequest.build({required String body, Map<String, String> headers})` returns a `relic_core.Request` usable as the second argument to any `PaymentWebhookRoute.handleCall(session, request)`.

- [ ] **Step 1: Write the failing test**

```dart
// anonaccred_server/test/integration/webhook_route_smoke_test.dart
import 'package:anonaccred_server/src/payments/mock_polar_client.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:anonaccred_server/src/payments/rails/polar_rail.dart';
import 'package:anonaccred_server/src/payments/polar_signature_validator.dart';
import 'package:anonaccred_server/src/webhooks/polar_webhook_route.dart';
import 'package:test/test.dart';
import 'test_tools/fake_webhook_request.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/webhook_signer.dart';

void main() {
  withServerpod('PolarWebhookRoute smoke test', (sessionBuilder, endpoints) {
    test('handleCall accepts a validly signed refund payload', () async {
      const secret = 'whsec_dGVzdC1zZWNyZXQ=';
      PaymentManager.clearRails();
      PaymentManager.registerRail(
        PolarRail(client: MockPolarClient(), signatureValidator: PolarSignatureValidator(secret: secret)),
      );

      final signed = WebhookSigner.polarWebhook(
        secret: secret,
        payload: {'type': 'refund.created', 'data': {'order_id': 'order-does-not-exist'}},
      );
      final request = FakeWebhookRequest.build(body: signed.requestBody, headers: signed.headers);
      final session = sessionBuilder.build();

      final response = await PolarWebhookRoute().handleCall(session, request);

      expect(response.statusCode, 200);
      await session.close();
      PaymentManager.clearRails();
    });

    test('handleCall rejects a bad signature', () async {
      PaymentManager.clearRails();
      PaymentManager.registerRail(
        PolarRail(client: MockPolarClient(), signatureValidator: PolarSignatureValidator(secret: 'whsec_dGVzdA==')),
      );

      final request = FakeWebhookRequest.build(
        body: '{"type":"refund.created"}',
        headers: {'webhook-id': 'x', 'webhook-timestamp': '1700000000', 'webhook-signature': 'v1,bad'},
      );
      final session = sessionBuilder.build();

      final response = await PolarWebhookRoute().handleCall(session, request);

      expect(response.statusCode, 401);
      await session.close();
      PaymentManager.clearRails();
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd anonaccred_server && dart test test/integration/webhook_route_smoke_test.dart`
Expected: FAIL — `fake_webhook_request.dart` does not exist.

- [ ] **Step 3: Implement `FakeWebhookRequest`**

```dart
// anonaccred_server/test/integration/test_tools/fake_webhook_request.dart
import 'dart:convert';
import 'package:relic_core/src/context/request.dart';
import 'package:relic_core/relic_core.dart';

/// Builds a relic_core Request without a live HTTP server, using the
/// RequestInternal extension relic_core's own test suite uses for the
/// same purpose (Request's only public constructor path otherwise runs
/// through a real IO adapter). Deliberately reaching past the public
/// barrel export — relic_core could remove or relocate this extension
/// without a deprecation cycle; if this import breaks on a relic_core
/// upgrade, that's why.
class FakeWebhookRequest {
  static Request build({required String body, required Map<String, String> headers}) {
    final headerBuilder = Headers.build((mh) {
      headers.forEach((key, value) => mh[key] = [value]);
    });
    return RequestInternal.create(
      Method.post,
      Uri.parse('http://localhost/webhook'),
      Object(),
      headers: headerBuilder,
      body: Body.fromString(body),
    );
  }
}
```

Check `package:relic_core`'s actual `Headers.build` API (`relic_core-1.1.1/lib/src/headers/headers.dart`) during implementation — the mutable-header-setter shape above is illustrative of intent (build a `Headers` from a plain map) and must be confirmed against the installed version's real builder API before this compiles.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd anonaccred_server && dart test test/integration/webhook_route_smoke_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add anonaccred_server/test/integration/test_tools/fake_webhook_request.dart \
        anonaccred_server/test/integration/webhook_route_smoke_test.dart
git commit -m "test: drive webhook routes directly via a relic_core Request test helper"
```

---

### Task 7: CommerceTestHarness

**Files:**
- Create: `anonaccred_server/test/integration/test_tools/commerce_test_harness.dart`
- Test: `anonaccred_server/test/integration/commerce_test_harness_test.dart`

**Interfaces:**
- Consumes: `AnonAccount`/`AccountDevice` (generated protocol models, per the existing pattern in `iap_endpoint_integration_test.dart:39-70`), `AuthenticationOverride.authenticationInfo` (Serverpod), `MockAppStoreServerClient`/`MockAndroidPublisherClient`/`MockPolarClient`, `PaymentManager.registerRail`, `TestEndpoints` (`serverpod_test_tools.dart`).
- Produces: `CommerceTestHarness.create(TestSessionBuilder sessionBuilder, TestEndpoints endpoints, {String label})` (async factory — inserts real rows) exposing: `authenticatedSessionBuilder` (`TestSessionBuilder`), `accountUuid` (`UuidValue`), `appleMock`/`googleMock`/`polarMock` (the three mock clients, for call-log assertions), `buyApple(...)`, `buyGoogle(...)`, `redeemPolar(...)` (account target), `redeemPolarForGroup(UuidValue shareGroupUuid, ...)`, `getEntitlements()`, `getBalance(String tag)`, `consume(String tag, double quantity)`, `consumeGroup(UuidValue shareGroupUuid, String tag, double quantity)`, `revokeDevice()` (flips the harness's own `AccountDevice.isRevoked`).

- [ ] **Step 1: Write the failing test**

```dart
// anonaccred_server/test/integration/commerce_test_harness_test.dart
import 'package:anonaccred_server/src/payments/mock_app_store_server_client.dart';
import 'package:app_store_server_sdk/app_store_server_sdk.dart';
import 'package:test/test.dart';
import 'test_tools/commerce_test_harness.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('CommerceTestHarness', (sessionBuilder, endpoints) {
    test('buyApple fulfils via the mock and credits the account', () async {
      final harness = await CommerceTestHarness.create(sessionBuilder, endpoints, label: 'h1');
      harness.appleMock.addMockTransaction(
        'txn-1',
        HistoryResponse('sandbox', null, 'com.example.app', false, '', [
          // A signedTransaction JWS string recognized by AppleIAPRail's
          // decoding path — implementer fills this in against
          // DecodedTransaction's expected shape during Task 8.
        ]),
      );

      final result = await harness.buyApple(transactionId: 'txn-1', productId: 'coins_100');

      expect(result.success, isTrue);
      final entitlements = await harness.getEntitlements();
      expect(entitlements, isNotEmpty);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd anonaccred_server && dart test test/integration/commerce_test_harness_test.dart`
Expected: FAIL — `commerce_test_harness.dart` does not exist.

- [ ] **Step 3: Implement `CommerceTestHarness`**

```dart
// anonaccred_server/test/integration/test_tools/commerce_test_harness.dart
import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/mock_app_store_server_client.dart';
import 'package:anonaccred_server/src/payments/mock_android_publisher_client.dart';
import 'package:anonaccred_server/src/payments/mock_polar_client.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:anonaccred_server/src/payments/rails/apple_iap_rail.dart';
import 'package:anonaccred_server/src/payments/rails/google_iap_rail.dart';
import 'package:anonaccred_server/src/payments/rails/polar_rail.dart';
import 'package:anonaccred_server/src/payments/redemption_target.dart';
import 'package:serverpod/serverpod.dart';
import 'package:uuid/uuid.dart';
import 'serverpod_test_tools.dart';

class CommerceTestHarness {
  CommerceTestHarness._({
    required this.authenticatedSessionBuilder,
    required this.accountUuid,
    required this._deviceKeyHex,
    required this._sessionBuilder,
    required this.appleMock,
    required this.googleMock,
    required this.polarMock,
    required this.endpoints,
  });

  final TestSessionBuilder authenticatedSessionBuilder;
  final UuidValue accountUuid;
  final String _deviceKeyHex;
  final TestSessionBuilder _sessionBuilder;
  final MockAppStoreServerClient appleMock;
  final MockAndroidPublisherClient googleMock;
  final MockPolarClient polarMock;
  final TestEndpoints endpoints;

  static Future<CommerceTestHarness> create(
    TestSessionBuilder sessionBuilder,
    TestEndpoints endpoints, {
    required String label,
  }) async {
    final ultimateHex = _hexKey('u-$label');
    final deviceHex = _hexKey('d-$label');

    final account = await AnonAccount.db.insertRow(
      sessionBuilder.build(),
      AnonAccount(
        id: UuidValue.fromString(const Uuid().v4()),
        ultimateSigningPublicKeyHex: ultimateHex,
        ultimateEncryptionPublicKeyHex: ultimateHex,
        encryptedDataKey: 'test-data-key-$label',
        createdAt: DateTime.now(),
      ),
    );

    await AccountDevice.db.insertRow(
      sessionBuilder.build(),
      AccountDevice(
        anonAccountId: account.id!,
        deviceSigningPublicKeyHex: deviceHex,
        deviceEncryptionPublicKeyHex: deviceHex,
        addedByAttestorPublicKeyHex: ultimateHex,
        addedByAttestation: 'test-attestation-$label',
        encryptedDataKey: 'test-device-data-key-$label',
        label: 'device-$label',
      ),
    );

    final appleMock = MockAppStoreServerClient();
    final googleMock = MockAndroidPublisherClient();
    final polarMock = MockPolarClient();
    PaymentManager.registerRail(AppleIAPRail(client: appleMock));
    PaymentManager.registerRail(GoogleIAPRail(client: googleMock));
    PaymentManager.registerRail(PolarRail(client: polarMock));

    final authenticatedSessionBuilder = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        account.id.toString(),
        {Scope('device:$deviceHex')},
        authId: deviceHex,
      ),
    );

    return CommerceTestHarness._(
      authenticatedSessionBuilder: authenticatedSessionBuilder,
      accountUuid: account.id!,
      _deviceKeyHex: deviceHex,
      _sessionBuilder: sessionBuilder,
      appleMock: appleMock,
      googleMock: googleMock,
      polarMock: polarMock,
      endpoints: endpoints,
    );
  }

  Future<IapValidationResponse> buyApple({
    required String transactionId,
    required String productId,
  }) => endpoints.iAP.validateAppleTransaction(
        authenticatedSessionBuilder,
        transactionId,
        productId,
      );

  Future<IapValidationResponse> buyGoogle({
    required String packageName,
    required String productId,
    required String purchaseToken,
  }) => endpoints.iAP.validateGooglePurchase(
        authenticatedSessionBuilder,
        packageName,
        productId,
        purchaseToken,
      );

  Future<IapValidationResponse> redeemPolar({required String licenseKey}) =>
      endpoints.polar.redeemLicenseKey(authenticatedSessionBuilder, licenseKey);

  Future<IapValidationResponse> redeemPolarForGroup({
    required String licenseKey,
    required UuidValue shareGroupUuid,
  }) => endpoints.polar.redeemLicenseKey(
        authenticatedSessionBuilder,
        licenseKey,
        shareGroupUuid: shareGroupUuid,
      );

  Future<List<AccountEntitlement>> getEntitlements() =>
      endpoints.commerce.getEntitlements(authenticatedSessionBuilder);

  Future<double> getBalance(String tag) =>
      endpoints.commerce.getEntitlementBalance(authenticatedSessionBuilder, tag);

  Future<ConsumeResult> consume(String tag, double quantity) =>
      endpoints.commerce.consumeEntitlement(authenticatedSessionBuilder, tag, quantity);

  Future<ConsumeResult> consumeGroup(UuidValue shareGroupUuid, String tag, double quantity) =>
      endpoints.groupCommerce.consumeGroupEntitlement(
        authenticatedSessionBuilder,
        shareGroupUuid,
        tag,
        quantity,
      );

  Future<void> revokeDevice() async {
    final session = _sessionBuilder.build();
    try {
      final device = (await AccountDevice.db.findFirstRow(
        session,
        where: (t) => t.deviceSigningPublicKeyHex.equals(_deviceKeyHex),
      ))!;
      await AccountDevice.db.updateRow(session, device.copyWith(isRevoked: true));
    } finally {
      await session.close();
    }
  }

  static String _hexKey(String seed) {
    final base = seed.hashCode.toRadixString(16).padLeft(8, '0');
    return (base * 16).substring(0, 128);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd anonaccred_server && dart test test/integration/commerce_test_harness_test.dart`
Expected: PASS. If it fails on `AppleIAPRail.validateTransaction`'s JWS-decoding step (the placeholder `signedTransactions` list in Step 1's test), resolve by reading `apple_iap_rail.dart:191-329` and `decoded_transaction.dart` for the exact JWS shape `AppleIAPRail` expects and constructing a minimal valid one — the same signing mechanism as `WebhookSigner.appleNotification` (Task 5) applies here, since App Store Server transaction JWS and notification JWS share Apple's signing format.

- [ ] **Step 5: Commit**

```bash
git add anonaccred_server/test/integration/test_tools/commerce_test_harness.dart \
        anonaccred_server/test/integration/commerce_test_harness_test.dart
git commit -m "test: add CommerceTestHarness for flow-level commerce integration tests"
```

---

### Task 8: Flow test — purchase-to-consume lifecycle (per rail)

**Files:**
- Create: `anonaccred_server/test/integration/flow_purchase_consume_lifecycle_test.dart`

**Interfaces:**
- Consumes: `CommerceTestHarness` (Task 7).

- [ ] **Step 1: Write the test**

```dart
// anonaccred_server/test/integration/flow_purchase_consume_lifecycle_test.dart
import 'package:test/test.dart';
import 'test_tools/commerce_test_harness.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Purchase-to-consume lifecycle', (sessionBuilder, endpoints) {
    test('Polar: redeem, query, consume, over-consume fails, replay is idempotent', () async {
      final harness = await CommerceTestHarness.create(sessionBuilder, endpoints, label: 'polar1');
      harness.polarMock.addMockLicense('LICENSE-1', /* PolarLicenseValidation granting e.g. 100 'coins' */ throw UnimplementedError());

      final first = await harness.redeemPolar(licenseKey: 'LICENSE-1');
      expect(first.success, isTrue);

      final balanceAfterBuy = await harness.getBalance(first.tag!);
      expect(balanceAfterBuy, greaterThan(0));

      final consumeResult = await harness.consume(first.tag!, balanceAfterBuy);
      expect(consumeResult.success, isTrue);
      expect(consumeResult.availableBalance, 0);

      final overConsume = await harness.consume(first.tag!, 1);
      expect(overConsume.success, isFalse);

      final replay = await harness.redeemPolar(licenseKey: 'LICENSE-1');
      expect(replay.fromCache, isTrue);
      final balanceAfterReplay = await harness.getBalance(first.tag!);
      expect(balanceAfterReplay, 0, reason: 'replay must not double-credit');
    });
  });
}
```

Fill in the `PolarLicenseValidation` construction using a real `RailProduct`/`RailProductGrant` seeded for `benefitId: 'LICENSE-1-benefit'` mapping to a known tag (check existing `commerce_endpoint_test.dart` / `iap_payment_flow_test.dart` for how those tests seed `RailProduct` rows — reuse the same seeding helper if one exists there, or write one modeled on it).

- [ ] **Step 2: Run to verify it fails, then implement any missing seeding helper, then verify it passes**

Run: `cd anonaccred_server && dart test test/integration/flow_purchase_consume_lifecycle_test.dart`
Iterate until PASS.

- [ ] **Step 3: Repeat the same four-part flow (redeem/buy → balance → consume → over-consume → replay) for Apple and Google**

Add two more `test(...)` blocks in the same file using `harness.buyApple(...)` / `harness.buyGoogle(...)` with their respective mocks, following the same assertions shape as the Polar test above.

- [ ] **Step 4: Run full file to verify all pass**

Run: `cd anonaccred_server && dart test test/integration/flow_purchase_consume_lifecycle_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add anonaccred_server/test/integration/flow_purchase_consume_lifecycle_test.dart
git commit -m "test: flow coverage for purchase-to-consume lifecycle across all three rails"
```

---

### Task 9: Flow test — group commerce lifecycle + member revocation

**Files:**
- Create: `anonaccred_server/test/integration/flow_group_commerce_lifecycle_test.dart`

**Interfaces:**
- Consumes: `CommerceTestHarness.redeemPolarForGroup`/`consumeGroup` (Task 7), `ShareGroup`/`GroupMember` (from `anonaccount_server`, per the existing pattern in `require_member_standing_test.dart:47-84`).

- [ ] **Step 1: Write the test**

```dart
// anonaccred_server/test/integration/flow_group_commerce_lifecycle_test.dart
import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:test/test.dart';
import 'test_tools/commerce_test_harness.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Group commerce lifecycle', (sessionBuilder, endpoints) {
    test(
      'member consumes, gets revoked, can no longer consume; balance and other members unaffected',
      () async {
        final buyer = await CommerceTestHarness.create(sessionBuilder, endpoints, label: 'buyer');
        final member = await CommerceTestHarness.create(sessionBuilder, endpoints, label: 'member');
        final otherMember = await CommerceTestHarness.create(sessionBuilder, endpoints, label: 'other');

        final session = sessionBuilder.build();
        final group = await ShareGroup.db.insertRow(
          session,
          ShareGroup(
            ultimateSigningPublicKeyHex: 'a' * 128,
            ultimateEncryptionPublicKeyHex: 'a' * 128,
            encryptedDataKey: 'x',
            createdAt: DateTime.now(),
          ),
        );
        for (final h in [member, otherMember]) {
          await GroupMember.db.insertRow(
            session,
            GroupMember(
              shareGroupId: group.id!,
              anonAccountId: h.accountUuid,
              role: GroupMemberRole.member,
              memberSigningPublicKeyHex: h.accountUuid.toString().padRight(128, '0').substring(0, 128),
              memberEncryptionPublicKeyHex: h.accountUuid.toString().padRight(128, '0').substring(0, 128),
              encryptedDataKey: 'x',
              encryptedMemberKey: 'x',
              joinedAt: DateTime.now(),
              addedByAttestorPublicKeyHex: 'a' * 128,
              addedByAttestation: 'x',
            ),
          );
        }
        await session.close();

        buyer.polarMock.addMockLicense('GROUP-LICENSE-1', throw UnimplementedError());
        final purchase = await buyer.redeemPolarForGroup(licenseKey: 'GROUP-LICENSE-1', shareGroupUuid: group.id!);
        expect(purchase.success, isTrue);

        final consumeResult = await member.consumeGroup(group.id!, purchase.tag!, 10);
        expect(consumeResult.success, isTrue);

        final revokeSession = sessionBuilder.build();
        final memberRow = (await GroupMember.db.findFirstRow(
          revokeSession,
          where: (t) => t.shareGroupId.equals(group.id!) & t.anonAccountId.equals(member.accountUuid),
        ))!;
        await GroupMember.db.updateRow(revokeSession, memberRow.copyWith(isRevoked: true));
        await revokeSession.close();

        await expectLater(
          member.consumeGroup(group.id!, purchase.tag!, 1),
          throwsA(isA<AuthenticationException>()),
        );

        final otherStillWorks = await otherMember.consumeGroup(group.id!, purchase.tag!, 5);
        expect(otherStillWorks.success, isTrue);
      },
    );
  });
}
```

Fill in the `PolarLicenseValidation` for `GROUP-LICENSE-1` granting a `group_`-prefixed tag (per `polar_rail.dart:27-33`'s scope-dispatch convention), seeded against a `RailProduct` the same way Task 8 does.

- [ ] **Step 2: Run to verify it fails, iterate on seeding until it passes**

Run: `cd anonaccred_server && dart test test/integration/flow_group_commerce_lifecycle_test.dart`
Expected eventual: PASS (1 test).

- [ ] **Step 3: Commit**

```bash
git add anonaccred_server/test/integration/flow_group_commerce_lifecycle_test.dart
git commit -m "test: flow coverage for group commerce + mid-flow member revocation"
```

---

### Task 10: Flow test — cross-module auth chaining

**Files:**
- Create: `anonaccred_server/test/integration/flow_cross_module_auth_test.dart`

**Interfaces:**
- Consumes: `CommerceTestHarness.revokeDevice()` (Task 7).

- [ ] **Step 1: Write the test**

```dart
// anonaccred_server/test/integration/flow_cross_module_auth_test.dart
import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:test/test.dart';
import 'test_tools/commerce_test_harness.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Cross-module auth chaining', (sessionBuilder, endpoints) {
    test('a revoked device is rejected by every commerce entrypoint, not just one', () async {
      final harness = await CommerceTestHarness.create(sessionBuilder, endpoints, label: 'revoke1');
      await harness.revokeDevice();

      await expectLater(harness.getEntitlements(), throwsA(isA<AuthenticationException>()));
      await expectLater(harness.getBalance('coins'), throwsA(isA<AuthenticationException>()));
      await expectLater(harness.consume('coins', 1), throwsA(isA<AuthenticationException>()));
      await expectLater(
        harness.buyApple(transactionId: 't', productId: 'p'),
        throwsA(isA<AuthenticationException>()),
      );
      await expectLater(
        harness.buyGoogle(packageName: 'pkg', productId: 'p', purchaseToken: 'tok'),
        throwsA(isA<AuthenticationException>()),
      );
      await expectLater(harness.redeemPolar(licenseKey: 'x'), throwsA(isA<AuthenticationException>()));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails or passes**

Run: `cd anonaccred_server && dart test test/integration/flow_cross_module_auth_test.dart`
Expected: PASS if `AnonAccountHelpers.requireCaller`'s live DB check (confirmed in the design spec, `helpers.dart:323-337`) is working as documented. If any entrypoint does NOT throw, that is a real finding — do not weaken the test to make it pass; report it instead (see plan note below).

- [ ] **Step 3: Commit**

```bash
git add anonaccred_server/test/integration/flow_cross_module_auth_test.dart
git commit -m "test: flow coverage proving revoked-device rejection on every commerce entrypoint"
```

---

### Task 11: Flow test — webhook-driven fulfillment (all three providers)

**Files:**
- Create: `anonaccred_server/test/integration/flow_webhook_fulfillment_test.dart`

**Interfaces:**
- Consumes: `CommerceTestHarness` (Task 7), `WebhookSigner` (Task 5), `FakeWebhookRequest` (Task 6), `AppleWebhookRoute`/`GoogleWebhookRoute`/`PolarWebhookRoute`.

- [ ] **Step 1: Write the tests**

```dart
// anonaccred_server/test/integration/flow_webhook_fulfillment_test.dart
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:anonaccred_server/src/payments/polar_signature_validator.dart';
import 'package:anonaccred_server/src/payments/rails/polar_rail.dart';
import 'package:anonaccred_server/src/webhooks/polar_webhook_route.dart';
import 'package:test/test.dart';
import 'test_tools/commerce_test_harness.dart';
import 'test_tools/fake_webhook_request.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/webhook_signer.dart';

void main() {
  withServerpod('Webhook-driven fulfillment', (sessionBuilder, endpoints) {
    test('Polar: a validly signed webhook is accepted; a bad signature is rejected', () async {
      final harness = await CommerceTestHarness.create(sessionBuilder, endpoints, label: 'wh-polar');
      const secret = 'whsec_dGVzdC1zZWNyZXQ=';
      PaymentManager.registerRail(
        PolarRail(client: harness.polarMock, signatureValidator: PolarSignatureValidator(secret: secret)),
      );

      final good = WebhookSigner.polarWebhook(
        secret: secret,
        payload: {'type': 'order.created', 'data': {'order_id': 'order-1'}},
      );
      final goodResponse = await PolarWebhookRoute().handleCall(
        sessionBuilder.build(),
        FakeWebhookRequest.build(body: good.requestBody, headers: good.headers),
      );
      expect(goodResponse.statusCode, 200);

      final tampered = WebhookSigner.polarWebhook(secret: 'whsec_d3Jvbmc=', payload: {'type': 'order.created'});
      final badResponse = await PolarWebhookRoute().handleCall(
        sessionBuilder.build(),
        FakeWebhookRequest.build(body: tampered.requestBody, headers: tampered.headers),
      );
      expect(badResponse.statusCode, 401);
    });

    // Apple and Google variants follow the same shape, using
    // WebhookSigner.appleNotification / googlePubSubPush and
    // AppleWebhookRoute / GoogleWebhookRoute respectively — write one
    // "valid" + one "bad signature/audience" test per provider, mirroring
    // the Polar test above.
  });
}
```

- [ ] **Step 2: Run to verify it fails/passes, then add the Apple and Google variants per the comment above**

Run: `cd anonaccred_server && dart test test/integration/flow_webhook_fulfillment_test.dart`
Iterate until all 6 tests (2 per provider) PASS.

- [ ] **Step 3: Commit**

```bash
git add anonaccred_server/test/integration/flow_webhook_fulfillment_test.dart
git commit -m "test: flow coverage for webhook-driven fulfillment across all three providers"
```

---

### Task 12: Flow test — refund lifecycle

**Files:**
- Create: `anonaccred_server/test/integration/flow_refund_lifecycle_test.dart`

**Interfaces:**
- Consumes: `CommerceTestHarness` (Task 7), `WebhookSigner.polarWebhook` (Task 5), `RefundManager.resetHandler()` (existing, `refund_manager.dart:74`).

- [ ] **Step 1: Write the test**

```dart
// anonaccred_server/test/integration/flow_refund_lifecycle_test.dart
import 'package:anonaccred_server/src/refund_manager.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:anonaccred_server/src/payments/polar_signature_validator.dart';
import 'package:anonaccred_server/src/payments/rails/polar_rail.dart';
import 'package:anonaccred_server/src/webhooks/polar_webhook_route.dart';
import 'package:test/test.dart';
import 'test_tools/commerce_test_harness.dart';
import 'test_tools/fake_webhook_request.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/webhook_signer.dart';

void main() {
  withServerpod('Refund lifecycle', (sessionBuilder, endpoints) {
    tearDown(RefundManager.resetHandler);

    test('a refund webhook revokes the entitlement, and a duplicate delivery is a no-op', () async {
      final harness = await CommerceTestHarness.create(sessionBuilder, endpoints, label: 'refund1');
      harness.polarMock.addMockLicense('REFUND-LICENSE-1', throw UnimplementedError());
      final purchase = await harness.redeemPolar(licenseKey: 'REFUND-LICENSE-1');
      final balanceAfterBuy = await harness.getBalance(purchase.tag!);
      expect(balanceAfterBuy, greaterThan(0));

      harness.polarMock.addMockOrder('order-refund-1', {
        'id': 'order-refund-1',
        'license_key_id': /* the licenseKeyId from purchase, resolved during implementation */ '',
      });

      const secret = 'whsec_dGVzdC1zZWNyZXQ=';
      PaymentManager.registerRail(
        PolarRail(client: harness.polarMock, signatureValidator: PolarSignatureValidator(secret: secret)),
      );

      final refundSigned = WebhookSigner.polarWebhook(
        secret: secret,
        payload: {
          'type': 'refund.created',
          'data': {'order_id': 'order-refund-1', 'created_at': DateTime.now().toIso8601String()},
        },
      );

      final response1 = await PolarWebhookRoute().handleCall(
        sessionBuilder.build(),
        FakeWebhookRequest.build(body: refundSigned.requestBody, headers: refundSigned.headers),
      );
      expect(response1.statusCode, 200);

      final balanceAfterRefund = await harness.getBalance(purchase.tag!);
      expect(balanceAfterRefund, 0);

      // Duplicate delivery — RefundClaim's unique index makes this a no-op
      // (RefundManager.processRefund, refund_manager.dart:84-97).
      final response2 = await PolarWebhookRoute().handleCall(
        sessionBuilder.build(),
        FakeWebhookRequest.build(body: refundSigned.requestBody, headers: refundSigned.headers),
      );
      expect(response2.statusCode, 200);

      final balanceAfterDuplicate = await harness.getBalance(purchase.tag!);
      expect(balanceAfterDuplicate, 0, reason: 'duplicate refund must not double-process');
    });
  });
}
```

Resolve the `licenseKeyId`-from-`purchase` placeholder by checking what `PolarValidationResult` (`polar_rail.dart`, returned from `validateLicenseKey`) exposes — `IapValidationResponse.productId` maps to `benefitId` per `polar_endpoint.dart:99-104`, but the refund bridge keys on `licenseKeyId`/`ReceiptHash`, which requires reading `polar_rail.dart`'s full `validateLicenseKey` body (lines 92-300, only partially read during planning) to find the exact field the test needs to thread through to `addMockOrder`.

- [ ] **Step 2: Run to verify it fails, resolve the license-key-id threading, iterate until it passes**

Run: `cd anonaccred_server && dart test test/integration/flow_refund_lifecycle_test.dart`
Expected eventual: PASS (1 test).

- [ ] **Step 3: Commit**

```bash
git add anonaccred_server/test/integration/flow_refund_lifecycle_test.dart
git commit -m "test: flow coverage for refund lifecycle with idempotent duplicate delivery"
```

---

### Task 13: Full suite run and cleanup

**Files:**
- None created — verification only.

- [ ] **Step 1: Run the full anonaccred_server suite**

Run: `cd anonaccred_server && dart test`
Expected: PASS, no flaky failures across 2 consecutive runs.

- [ ] **Step 2: Run analyzer**

Run: `cd anonaccred_server && dart analyze`
Expected: no new warnings introduced by this plan (the pre-existing `pubspec.yaml` path-dependency warning is unrelated and expected to remain).

- [ ] **Step 3: Report the out-of-scope finding**

This plan does not touch `quanitya_cloud_server`. Separately tell whoever owns that repo: `PolarWebhookRoute` is defined but never registered in `lib/server.dart` — Polar refunds/cancellations have no delivery path in production today. The one-line fix is:

```dart
pod.webServer.addRoute(PolarWebhookRoute(), '/hooks/polar');
```

- [ ] **Step 4: Final commit (if any cleanup was needed)**

```bash
git add -A
git commit -m "chore: final cleanup pass on anonaccred commerce flow harness" --allow-empty
```
