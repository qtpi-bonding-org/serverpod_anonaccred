# Apple x5c Certificate-Chain Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `basicConstraints CA:TRUE` and certificate-validity-period checks to `NotificationSignatureValidator`'s Apple x5c chain-of-trust verification, closing two of the three gaps recorded in `docs/key-model-conventions.md`'s Known Deviations table.

**Architecture:** Both checks are added inside the existing per-cert loop in `_chainsToTrustedRoot` (`anonaccred_server/lib/src/payments/notification_signature_validator.dart`) — no new parsing pass, no new error path, matching the function's existing all-or-nothing boolean contract. A prerequisite fix regenerates the test fixture chain in `AppleTestCertificates`, because the existing `intermediateDerBase64` fixture has no `basicConstraints` extension at all and would fail the new check.

**Tech Stack:** Dart, `package:x509` 0.2.4+3 (already a direct dependency), `package:test`.

## Global Constraints

- **THE COMMENT RULE** (repo root `CLAUDE.md`): comments may state WHY, never a falsifiable claim. Trigger words: prevents, ensures, proves, guarantees, atomic, safe, cannot, never, always. `notification_signature_validator.dart` has a documented history of exactly this mistake surviving multiple reviews — see the file's own header comments and the repo CLAUDE.md's audit note. Any comment describing what a new check *guarantees* is wrong; describe only why it's placed where it is.
- **`dart test`, not `flutter test`** — `anonaccred_server` is a pure-Dart package (per repo CLAUDE.md Serverpod Rules / Conventions).
- **No leaf-OID check, no `keyUsage`/`keyCertSign` check** — both are explicitly out of scope per the spec (`docs/superpowers/specs/2026-08-06-apple-cert-chain-hardening-design.md`), deferred pending confirmation against real Apple certificate behavior.
- **No generic chain-verifier abstraction** — Apple is the only provider in this codebase using X.509 chain-of-trust verification (Google uses OIDC/JWKS, Polar uses HMAC). Do not introduce an interface for this.
- Package location for API reference during implementation: `~/.pub-cache/hosted/pub.dev/x509-0.2.4+3/lib/src/extension.dart` (for `BasicConstraints`/`Extension`) and `lib/src/x509_base.dart` (for `Validity`).

---

### Task 1: Regenerate `AppleTestCertificates` fixtures (fixes existing bug, adds 3 new fixtures)

**Files:**
- Modify: `anonaccred_server/test/test_helpers/apple_test_certificates.dart`

**Interfaces:**
- Consumes: nothing (this is the root of the dependency chain for later tasks).
- Produces: getters `rootDer`, `intermediateDer`, `leafDer`, `leafPrivateKeyDer` (existing names, new byte values), plus six new getters: `expiredLeafDer`, `expiredLeafPrivateKeyDer`, `nonCaIntermediateDer`, `nonCaIntermediatePrivateKeyDer`, `leafSignedByNonCaIntermediateDer`, `leafSignedByNonCaIntermediatePrivateKeyDer`. `unrelatedSelfSignedDer`/`unrelatedPrivateKeyDer` are unchanged.

The existing `intermediateDerBase64` fixture has **no `basicConstraints` extension at all** (verified by parsing it with the installed `x509` package) — not `CA:FALSE`, absent entirely. Task 2's new check rejects any non-leaf cert lacking the extension, which would break the existing "accepts a genuinely valid chain and signature" test (`notification_signature_validator_test.dart:97-111`). The root/intermediate/leaf chain must be regenerated with the intermediate correctly carrying `basicConstraints=critical,CA:TRUE`. Because the original root and intermediate private keys were never persisted (only used ephemerally during the original `openssl` generation), the entire root→intermediate→leaf chain is regenerated fresh below — this also produces new key material for the two new fixture chains needed in Tasks 2 and 3.

- [ ] **Step 1: Replace `apple_test_certificates.dart`'s constants**

Open `anonaccred_server/test/test_helpers/apple_test_certificates.dart`. Keep the file's existing structure, doc comments, and the `_appleRootCaG3DerBase64`-style pattern from `notification_signature_validator.dart` for context, but replace the whole file with the following (this replaces `rootDerBase64`, `intermediateDerBase64`, `leafDerBase64`, `leafPrivateKeyDerBase64` with freshly generated values, keeps `unrelatedSelfSignedDerBase64`/`unrelatedPrivateKeyDerBase64` unchanged, and adds six new constants + six new getters):

```dart
import 'dart:convert';

/// Test-only P-256 certificate chain (root -> intermediate -> leaf),
/// generated once via openssl and hardcoded here so tests never shell
/// out. Mirrors the shape of a real Apple x5c chain without depending
/// on Apple's actual certificates.
///
/// Regenerated 2026-08-06 (see docs/superpowers/plans/2026-08-06-apple-
/// cert-chain-hardening.md Task 1) to fix a fixture bug: the prior
/// `intermediateDerBase64` carried no `basicConstraints` extension at
/// all, which would fail a `basicConstraints CA:TRUE` check added in
/// this same change. The root and intermediate private keys used to
/// generate this chain were not persisted (ephemeral, discarded after
/// signing) — only `leafPrivateKeyDer` is kept, since `WebhookSigner`
/// needs it to sign JWS payloads in tests.
class AppleTestCertificates {
  // DER bytes (base64, no PEM headers) for each generated .pem file:
  // `openssl x509 -in root.pem -outform DER | base64`. Root: P-256,
  // self-signed, basicConstraints=critical,CA:TRUE.
  static const String rootDerBase64 =
      'MIIBsjCCAVegAwIBAgIUZqHtlZRca/BuvyRZ+amVhxFCvPcwCgYIKoZIzj0EAwIwJjEVMBMGA1UE'
      'AwwMVGVzdCBSb290IENBMQ0wCwYDVQQKDARUZXN0MB4XDTI2MDgwNjE1NDU0N1oXDTM2MDgwMzE1'
      'NDU0N1owJjEVMBMGA1UEAwwMVGVzdCBSb290IENBMQ0wCwYDVQQKDARUZXN0MFkwEwYHKoZIzj0C'
      'AQYIKoZIzj0DAQcDQgAE+A8j8wIHM8TsuOzdFORRqb41ccQAUoq0kufSMlYSrvmGnf8wqf2UXrIh'
      '9w0c60dYpN3pKjEDNlaJ2egq4O19ZqNjMGEwHQYDVR0OBBYEFBiExPIOlyBD6hzsczeWxnKPuq4g'
      'MB8GA1UdIwQYMBaAFBiExPIOlyBD6hzsczeWxnKPuq4gMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0P'
      'AQH/BAQDAgEGMAoGCCqGSM49BAMCA0kAMEYCIQDPPs7aCCiNwKc+lKXHnOmIf88aGYf+yyygz0tg'
      '1qvGMwIhANQpR388BAVU6/qqSVj1n8WZh8OVbbNA1Hk6gR0Nxrux';

  // Intermediate: P-256, signed by root, basicConstraints=critical,
  // CA:TRUE (this is the field the prior fixture was missing).
  static const String intermediateDerBase64 =
      'MIIBtTCCAVygAwIBAgIUBH6mxUTDCgGjZUK6Qj0Zctl0HL8wCgYIKoZIzj0EAwIwJjEVMBMGA1UE'
      'AwwMVGVzdCBSb290IENBMQ0wCwYDVQQKDARUZXN0MB4XDTI2MDgwNjE1NDU0N1oXDTM2MDgwMzE1'
      'NDU0N1owKzEaMBgGA1UEAwwRVGVzdCBJbnRlcm1lZGlhdGUxDTALBgNVBAoMBFRlc3QwWTATBgcq'
      'hkjOPQIBBggqhkjOPQMBBwNCAAQi/yV6+z9pGcH2CSYrpoiKJUk9Feo+GGvvrctWqr5Eu5m9ApFr'
      '7BfRQPJeq6QyaagiC11nn62ntUs/p7WreiQSo2MwYTAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB'
      '/wQEAwIBBjAdBgNVHQ4EFgQUqfAM5m8hjabnZarJUvYcITibhM8wHwYDVR0jBBgwFoAUGITE8g6X'
      'IEPqHOxzN5bGco+6riAwCgYIKoZIzj0EAwIDRwAwRAIgR7CudfKUKAtybhXKEI+nseF0XzfKQtSV'
      '5Cs71ODmz2UCIBIQcK5bLzpWJKuXyqfxdGEONCU05uc7BHRbDmUTkg9o';

  // Leaf: P-256, signed by intermediate, 10-year validity from
  // generation date.
  static const String leafDerBase64 =
      'MIIBkzCCATigAwIBAgIUegb0m0SlLMratkV5R1ua6m0VecowCgYIKoZIzj0EAwIwKzEaMBgGA1UE'
      'AwwRVGVzdCBJbnRlcm1lZGlhdGUxDTALBgNVBAoMBFRlc3QwHhcNMjYwODA2MTU0NTQ4WhcNMzYw'
      'ODAzMTU0NTQ4WjAjMRIwEAYDVQQDDAlUZXN0IExlYWYxDTALBgNVBAoMBFRlc3QwWTATBgcqhkjO'
      'PQIBBggqhkjOPQMBBwNCAAR0QNDfSww6uZWunIQe4ECe1HQxruBvcftaiWYetvCccW8PulDPW3xR'
      'MSi6FPLY9a5uMTsMgai09ddD03uOBDBho0IwQDAdBgNVHQ4EFgQUSdzymfGlIisQqyYz6ivMpjh3'
      'cHUwHwYDVR0jBBgwFoAUqfAM5m8hjabnZarJUvYcITibhM8wCgYIKoZIzj0EAwIDSQAwRgIhAMIm'
      'oDhA8+JHBTkM402M5lshuySRJPdzWCL7i5n+O9s8AiEA7YvW/3M6E18Ik4yb+doqmK8v+ZhWV4Qs'
      '5/gaZZIcRGk=';

  // Raw EC private key bytes for the leaf
  // (`openssl ec -in leaf.key -outform DER | base64`), used to sign JWS
  // payloads in WebhookSigner.
  static const String leafPrivateKeyDerBase64 =
      'MHcCAQEEIMpNYWb1hIqjoa7M/RCjmft723ML8Dt4VVhpmHjfknlToAoGCCqGSM49AwEHoUQDQgAE'
      'dEDQ30sMOrmVrpyEHuBAntR0Ma7gb3H7WolmHrbwnHFvD7pQz1t8UTEouhTy2PWubjE7DIGotPXX'
      'Q9N7jgQwYQ==';

  // A self-signed cert from an entirely separate CA (its own throwaway
  // key, not chained through `rootDerBase64` at all). Used to test that a
  // chain genuinely unrelated to the trusted root is rejected — as
  // opposed to a chain that is merely incomplete but still verifiably
  // rooted in trust, which a different bug class could wrongly accept.
  static const String unrelatedSelfSignedDerBase64 =
      'MIIBsjCCAVmgAwIBAgIUKNCak4mpg/+x0VtdbWy3v7/xCGQwCgYIKoZIzj0EAwIwLzEeMBwGA1UE'
      'AwwVVW5yZWxhdGVkIFNlbGYtU2lnbmVkMQ0wCwYDVQQKDARUZXN0MB4XDTI2MDgwNjA3MDgwMFoX'
      'DTM2MDgwMzA3MDgwMFowLzEeMBwGA1UEAwwVVW5yZWxhdGVkIFNlbGYtU2lnbmVkMQ0wCwYDVQQK'
      'DARUZXN0MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE+l+QA4Z04PXut2kquq3KqnDe71oJ/67C'
      'vUpiReJ8wQrSFpoV9GYNHtXEufblT/C3vBU2+X46WnFgRYsuSD49MaNTMFEwHQYDVR0OBBYEFPR7'
      'ljx14hlRBXV8TDbyEuS00kMzMB8GA1UdIwQYMBaAFPR7ljx14hlRBXV8TDbyEuS00kMzMA8GA1Ud'
      'EwEB/wQFMAMBAf8wCgYIKoZIzj0EAwIDRwAwRAIgSpC5C6JwC1gqsys04wA3ljAVab3IIcY42Tb9'
      'zYGDYlICIFciXNlO+HrEjEDciRIK60i2NWxz83dgPXnza+D/AyBx';

  // Raw EC private key bytes for the unrelated self-signed cert above —
  // used to produce a genuinely valid signature over an untrusted chain,
  // so a chain-of-trust test can't pass by accident on garbage signature
  // bytes.
  static const String unrelatedPrivateKeyDerBase64 =
      'MHcCAQEEIJApY/iVviNLuTbqsMU8weDGBrV9uW1rbAtijDMufl5PoAoGCCqGSM49AwEHoUQDQgAE'
      '+l+QA4Z04PXut2kquq3KqnDe71oJ/67CvUpiReJ8wQrSFpoV9GYNHtXEufblT/C3vBU2+X46WnFg'
      'RYsuSD49MQ==';

  // Leaf signed by the intermediate above, but with a validity window
  // entirely in the past (2020-01-01 to 2020-06-01). Used to prove the
  // validity-period check rejects an expired cert — chains and signs
  // correctly otherwise, so a rejecting test can't be explained by any
  // other failure.
  static const String expiredLeafDerBase64 =
      'MIIBmzCCAUCgAwIBAgIUegb0m0SlLMratkV5R1ua6m0VecswCgYIKoZIzj0EAwIwKzEaMBgGA1UE'
      'AwwRVGVzdCBJbnRlcm1lZGlhdGUxDTALBgNVBAoMBFRlc3QwHhcNMjAwMTAxMDAwMDAwWhcNMjAw'
      'NjAxMDAwMDAwWjArMRowGAYDVQQDDBFUZXN0IEV4cGlyZWQgTGVhZjENMAsGA1UECgwEVGVzdDBZ'
      'MBMGByqGSM49AgEGCCqGSM49AwEHA0IABIavM6IAo2/QjbNxB27OVu9ov/VzidJ9NN9M5y/DG9dr'
      'MTMnpQcBwiH9k4zdsKN/Ei6RMZTxUlq1dhVmkqerVV6jQjBAMB0GA1UdDgQWBBT/aS62i10pVj39'
      'oKHzPIsPBzUlTTAfBgNVHSMEGDAWgBSp8AzmbyGNpudlqslS9hwhOJuEzzAKBggqhkjOPQQDAgNJ'
      'ADBGAiEAuWJH9C+k+Jze6o4QZDE6MYs2Bj1iinTNuTBaWRDKDL8CIQDQxz719ZKobSIKe8fCbQcg'
      '2Plgl+odLJ2/XblGRWYhVw==';

  // Raw EC private key for the expired leaf above.
  static const String expiredLeafPrivateKeyDerBase64 =
      'MHcCAQEEIJeCM0ngbVPzP156oxf3TQOJRH5EtOd2DA+rO8PgF2oloAoGCCqGSM49AwEHoUQDQgAE'
      'hq8zogCjb9CNs3EHbs5W72i/9XOJ0n0030znL8Mb12sxMyelBwHCIf2TjN2wo38SLpExlPFSWrV2'
      'FWaSp6tVXg==';

  // Intermediate signed by root, valid today, but deliberately generated
  // WITHOUT basicConstraints CA:TRUE (openssl's default when that
  // extension isn't explicitly requested) — reproduces on purpose the
  // same fixture shape that was the bug in the original
  // `intermediateDerBase64` above. Used to prove the basicConstraints
  // check rejects a non-CA intermediate.
  static const String nonCaIntermediateDerBase64 =
      'MIIBnTCCAUKgAwIBAgIUBH6mxUTDCgGjZUK6Qj0Zctl0HMAwCgYIKoZIzj0EAwIwJjEVMBMGA1UE'
      'AwwMVGVzdCBSb290IENBMQ0wCwYDVQQKDARUZXN0MB4XDTI2MDgwNjE1NDU1OVoXDTM2MDgwMzE1'
      'NDU1OVowMjEhMB8GA1UEAwwYVGVzdCBOb24tQ0EgSW50ZXJtZWRpYXRlMQ0wCwYDVQQKDARUZXN0'
      'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAENd695Bzr9yCBovASNpzuKIkOKgc5gOH5mYhMclej'
      'S5JIjSYFhjp41SL2I5kMwH7e3+99BFw39XshIJ/3T2inQ6NCMEAwHQYDVR0OBBYEFBK1MBAk/Je7'
      'jVb9DHIcRH/F4+0jMB8GA1UdIwQYMBaAFBiExPIOlyBD6hzsczeWxnKPuq4gMAoGCCqGSM49BAMC'
      'A0kAMEYCIQCQa7bWA7O7lnAh/HEYfI/DRY21vUjpL7FXVpR0SAHXqQIhALLzQ3AZEkWvDh3FzGMs'
      'w4QRQQrbfIfExO7KTMIDFoNY';

  // Raw EC private key for the non-CA intermediate above.
  static const String nonCaIntermediatePrivateKeyDerBase64 =
      'MHcCAQEEIDLzTqkWwDe99NTbH6JPmkkPhwS2A+xWhqo4W0q7nNvcoAoGCCqGSM49AwEHoUQDQgAE'
      'Nd695Bzr9yCBovASNpzuKIkOKgc5gOH5mYhMclejS5JIjSYFhjp41SL2I5kMwH7e3+99BFw39Xsh'
      'IJ/3T2inQw==';

  // Freshly generated leaf, signed by nonCaIntermediateDerBase64's own
  // key (not by the CA-valid intermediate's key). Kept separate from
  // `leafDerBase64` deliberately: signing this leaf with the CA-valid
  // intermediate's key would make a basicConstraints-rejection test
  // fail on signature linkage first, instead of on the check under test.
  static const String leafSignedByNonCaIntermediateDerBase64 =
      'MIIBozCCAUmgAwIBAgIUZSDMmRpu6DqiXZpx7aBTiAzpJhYwCgYIKoZIzj0EAwIwMjEhMB8GA1UE'
      'AwwYVGVzdCBOb24tQ0EgSW50ZXJtZWRpYXRlMQ0wCwYDVQQKDARUZXN0MB4XDTI2MDgwNjE1NDU1'
      'OVoXDTM2MDgwMzE1NDU1OVowLTEcMBoGA1UEAwwTVGVzdCBMZWFmIFZpYSBOb25DQTENMAsGA1UE'
      'CgwEVGVzdDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABF97N98RjDV4FJAowyFmJ5xczqIogSkG'
      'T6QUcach4OUn2t09WgvhPoEpWCI/5Tw6y/rNYolUyGumJF+sRB7TjDujQjBAMB0GA1UdDgQWBBQ9'
      '1sf3Bb9y1hsAaNeZ9fS+X7y7DTAfBgNVHSMEGDAWgBQStTAQJPyXu41W/QxyHER/xePtIzAKBggq'
      'hkjOPQQDAgNIADBFAiAT1KMHKYqttepIZvRT5gPPSjubSt39iFR8TCeehNCZMwIhAP0EBCNUrHYS'
      'c7c8UT63EWmD/cGBVIYeZqxhRpy/VBW0';

  // Raw EC private key for the leaf above.
  static const String leafSignedByNonCaIntermediatePrivateKeyDerBase64 =
      'MHcCAQEEIAO4K0Ht2K7DeTXCy/wGhNDDvginJtgjTk8TbdfklrYKoAoGCCqGSM49AwEHoUQDQgAE'
      'X3s33xGMNXgUkCjDIWYnnFzOoiiBKQZPpBRxpyHg5Sfa3T1aC+E+gSlYIj/lPDrL+s1iiVTIa6Yk'
      'X6xEHtOMOw==';

  static List<int> get rootDer => base64.decode(rootDerBase64);
  static List<int> get intermediateDer => base64.decode(intermediateDerBase64);
  static List<int> get leafDer => base64.decode(leafDerBase64);
  static List<int> get leafPrivateKeyDer => base64.decode(leafPrivateKeyDerBase64);
  static List<int> get unrelatedSelfSignedDer => base64.decode(unrelatedSelfSignedDerBase64);
  static List<int> get unrelatedPrivateKeyDer => base64.decode(unrelatedPrivateKeyDerBase64);
  static List<int> get expiredLeafDer => base64.decode(expiredLeafDerBase64);
  static List<int> get expiredLeafPrivateKeyDer => base64.decode(expiredLeafPrivateKeyDerBase64);
  static List<int> get nonCaIntermediateDer => base64.decode(nonCaIntermediateDerBase64);
  static List<int> get nonCaIntermediatePrivateKeyDer =>
      base64.decode(nonCaIntermediatePrivateKeyDerBase64);
  static List<int> get leafSignedByNonCaIntermediateDer =>
      base64.decode(leafSignedByNonCaIntermediateDerBase64);
  static List<int> get leafSignedByNonCaIntermediatePrivateKeyDer =>
      base64.decode(leafSignedByNonCaIntermediatePrivateKeyDerBase64);
}
```

- [ ] **Step 2: Run the existing test suite to confirm nothing else broke from the fixture regeneration**

Run: `cd anonaccred_server && dart test test/unit/notification_signature_validator_test.dart test/integration/test_tools/webhook_signer_test.dart -v`

Expected: All existing tests still PASS (they reference fixtures by getter name, not byte content, so new valid byte values that still form a correct chain keep them green).

- [ ] **Step 3: Commit**

```bash
git add anonaccred_server/test/test_helpers/apple_test_certificates.dart
git commit -m "test: regenerate AppleTestCertificates chain, fix missing basicConstraints on intermediate

The prior intermediateDerBase64 had no basicConstraints extension at
all, which would fail a CA:TRUE check about to be added. Regenerated
the whole root/intermediate/leaf chain (prior root/intermediate private
keys were never persisted) and added fixtures for an expired leaf and
a non-CA intermediate, needed by the next two tasks."
```

---

### Task 2: `basicConstraints CA:TRUE` check on non-leaf certs

**Files:**
- Modify: `anonaccred_server/lib/src/payments/notification_signature_validator.dart:99-116` (the `_chainsToTrustedRoot` method and its helpers)
- Test: `anonaccred_server/test/unit/notification_signature_validator_test.dart`

**Interfaces:**
- Consumes: `AppleTestCertificates.nonCaIntermediateDer`, `.nonCaIntermediatePrivateKeyDer`, `.leafSignedByNonCaIntermediateDer` (from Task 1).
- Produces: a private static helper `_hasCaBasicConstraints(_ParsedCertificate cert)` returning `bool`, used only within this file.

- [ ] **Step 1: Write the failing test**

Add to `anonaccred_server/test/unit/notification_signature_validator_test.dart`, inside the existing `group(...)` block, after the `'accepts a genuinely valid chain and signature'` test:

```dart
    test('rejects a chain whose intermediate lacks basicConstraints CA:TRUE', () async {
      NotificationSignatureValidator.trustedRootDerOverride = AppleTestCertificates.rootDer;

      final signedPayload = _signedPayload(
        x5c: [
          AppleTestCertificates.leafSignedByNonCaIntermediateDer,
          AppleTestCertificates.nonCaIntermediateDer,
        ],
        signingKeyDer: AppleTestCertificates.leafSignedByNonCaIntermediatePrivateKeyDer,
      );

      final isValid = await NotificationSignatureValidator.validateSignature(
        signedPayload: signedPayload,
      );

      expect(isValid, isFalse);
      NotificationSignatureValidator.trustedRootDerOverride = null;
    });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd anonaccred_server && dart test test/unit/notification_signature_validator_test.dart -v -N "rejects a chain whose intermediate lacks basicConstraints"`
Expected: FAIL — `isValid` is currently `true` (chain-of-trust and signature both pass; nothing checks `basicConstraints` yet).

- [ ] **Step 3: Add the `BasicConstraints` import and the check**

In `anonaccred_server/lib/src/payments/notification_signature_validator.dart`, the `x509` package is already imported (`import 'package:x509/x509.dart';` at line 7) — `BasicConstraints` is exported from that same package, no new import needed.

Modify `_chainsToTrustedRoot` (currently lines 99-116) to check `basicConstraints` on every non-leaf cert:

```dart
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

  // Every cert except the leaf (index 0) must be authorized to act as a
  // CA — otherwise a cert with no signing authority could still appear
  // as an intermediate and pass the signature-linkage check above, which
  // only confirms *whose key* signed the next cert, not whether that
  // signer was permitted to sign other certificates at all.
  static bool _hasCaBasicConstraints(_ParsedCertificate cert) {
    final extensions = cert.certificate.tbsCertificate.extensions;
    if (extensions == null) return false;
    for (final extension in extensions) {
      final value = extension.extnValue;
      if (value is BasicConstraints) return value.cA;
    }
    return false;
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd anonaccred_server && dart test test/unit/notification_signature_validator_test.dart -v`
Expected: PASS — all tests in the file, including the new one and the three pre-existing ones.

- [ ] **Step 5: Commit**

```bash
git add anonaccred_server/lib/src/payments/notification_signature_validator.dart anonaccred_server/test/unit/notification_signature_validator_test.dart
git commit -m "feat: reject Apple x5c chains whose intermediate lacks basicConstraints CA:TRUE"
```

---

### Task 3: Certificate validity-period check on every cert in the chain

**Files:**
- Modify: `anonaccred_server/lib/src/payments/notification_signature_validator.dart` (same `_chainsToTrustedRoot`, extended further)
- Test: `anonaccred_server/test/unit/notification_signature_validator_test.dart`

**Interfaces:**
- Consumes: `AppleTestCertificates.expiredLeafDer`, `.expiredLeafPrivateKeyDer`, `.intermediateDer` (from Task 1); `_chainsToTrustedRoot` and `_ParsedCertificate` (from Task 2 / existing code).
- Produces: a private static helper `_isWithinValidityPeriod(_ParsedCertificate cert)` returning `bool`, used only within this file.

- [ ] **Step 1: Write the failing test**

Add to `anonaccred_server/test/unit/notification_signature_validator_test.dart`, after the test added in Task 2:

```dart
    test('rejects a chain whose leaf certificate has expired', () async {
      NotificationSignatureValidator.trustedRootDerOverride = AppleTestCertificates.rootDer;

      final signedPayload = _signedPayload(
        x5c: [AppleTestCertificates.expiredLeafDer, AppleTestCertificates.intermediateDer],
        signingKeyDer: AppleTestCertificates.expiredLeafPrivateKeyDer,
      );

      final isValid = await NotificationSignatureValidator.validateSignature(
        signedPayload: signedPayload,
      );

      expect(isValid, isFalse);
      NotificationSignatureValidator.trustedRootDerOverride = null;
    });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd anonaccred_server && dart test test/unit/notification_signature_validator_test.dart -v -N "rejects a chain whose leaf certificate has expired"`
Expected: FAIL — `isValid` is currently `true` (the expired leaf still chains and signs correctly; nothing checks validity dates yet).

- [ ] **Step 3: Add the validity-period check**

Modify `_chainsToTrustedRoot` again (now including Task 2's `basicConstraints` loop) to also check validity on every cert, leaf included:

```dart
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

  // Checked for every cert in the chain, leaf included — a chain that is
  // otherwise correctly signed and rooted in trust still shouldn't be
  // accepted outside the window its issuer bounded it to.
  static bool _isWithinValidityPeriod(_ParsedCertificate cert) {
    final validity = cert.certificate.tbsCertificate.validity;
    if (validity == null) return false;
    final now = DateTime.now();
    return !now.isBefore(validity.notBefore) && !now.isAfter(validity.notAfter);
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd anonaccred_server && dart test test/unit/notification_signature_validator_test.dart -v`
Expected: PASS — all tests in the file (5 total: the 3 original, plus Task 2's and this task's).

- [ ] **Step 5: Commit**

```bash
git add anonaccred_server/lib/src/payments/notification_signature_validator.dart anonaccred_server/test/unit/notification_signature_validator_test.dart
git commit -m "feat: reject Apple x5c chains containing an expired or not-yet-valid certificate"
```

---

### Task 4: Update the Known Deviations table

**Files:**
- Modify: `docs/key-model-conventions.md` (the "Commerce webhook verification gaps" table, currently one row around line 369)

**Interfaces:**
- Consumes: nothing (documentation-only task).
- Produces: nothing consumed by later tasks — this is the last task.

- [ ] **Step 1: Replace the single deviation row with two rows**

Find the "Commerce webhook verification gaps" table in `docs/key-model-conventions.md` (currently a single row). Replace its row with two rows — one closed, one still open, reflecting exactly what Tasks 1-3 fixed and what remains deferred:

```markdown
**Commerce webhook verification gaps:**

| Deviation | Where | Status |
|---|---|---|
| Apple x5c chain-of-trust verification checked signature linkage and root pinning, but did not check `basicConstraints CA:TRUE` on intermediates or certificate validity periods (`notBefore`/`notAfter`) | `notification_signature_validator.dart` | Fixed by `docs/superpowers/plans/2026-08-06-apple-cert-chain-hardening.md` |
| Apple x5c chain-of-trust verification does not check Apple's leaf certificate OID (`1.2.840.113635.100.6.11.1`) or the `keyUsage`/`keyCertSign` bit on CA certs. Practical consequence: any certificate that chains to Apple's real Root CA G3 and is CA-authorized where required — not just an App Store Server certificate, e.g. an Apple Pay merchant identity cert obtainable by any Apple developer — is still accepted as a valid signer of App Store notifications | `notification_signature_validator.dart` | Not fixed here — deferred because the exact OID's meaning and `keyUsage` requirement couldn't be confirmed against Apple's docs or a real sample cert; must be closed before this verifier is used against real production Apple webhook traffic |
```

- [ ] **Step 2: Verify the table renders correctly and no other reference to the old single-row deviation remains**

Run: `grep -n "basicConstraints\|1.2.840.113635.100.6.11.1" docs/key-model-conventions.md`
Expected: exactly the two new rows' text, nothing stale left over from the old single row.

- [ ] **Step 3: Commit**

```bash
git add docs/key-model-conventions.md
git commit -m "docs: split Apple cert-chain Known Deviation into fixed + still-deferred rows"
```
