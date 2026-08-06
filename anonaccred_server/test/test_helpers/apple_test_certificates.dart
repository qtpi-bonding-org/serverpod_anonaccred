import 'dart:convert';

/// Test-only P-256 certificate chain (root -> intermediate -> leaf),
/// generated once via openssl (see plan Task 3, Step 1) and hardcoded here
/// so tests never shell out. Mirrors the shape of a real Apple x5c chain
/// without depending on Apple's actual certificates.
class AppleTestCertificates {
  // DER bytes (base64, no PEM headers) for each generated .pem file:
  // `openssl x509 -in /tmp/root.pem -outform DER | base64`.
  static const String rootDerBase64 =
      'MIIBoDCCAUegAwIBAgIUQSXcy0/pLwUUeIhEREmauOxwpjwwCgYIKoZIzj0EAwIwJjEVMBMGA1UE'
      'AwwMVGVzdCBSb290IENBMQ0wCwYDVQQKDARUZXN0MB4XDTI2MDgwNjA2NDk1MloXDTM2MDgwMzA2'
      'NDk1MlowJjEVMBMGA1UEAwwMVGVzdCBSb290IENBMQ0wCwYDVQQKDARUZXN0MFkwEwYHKoZIzj0C'
      'AQYIKoZIzj0DAQcDQgAEnwH2ZSoTAexnZlcascwaHubk8JIXaFGai++qxwlODpGtNqKBsJNa5d42'
      'XIzX5MUsw7kpwVoBqHEAh9wvhaxngqNTMFEwHQYDVR0OBBYEFNLw3GWKfnrdxnNcu1MzR8ecnta/'
      'MB8GA1UdIwQYMBaAFNLw3GWKfnrdxnNcu1MzR8ecnta/MA8GA1UdEwEB/wQFMAMBAf8wCgYIKoZI'
      'zj0EAwIDRwAwRAIgBnQmoUPL/ufy8PE7oCCdE53vpXtvwOiJpLlwGQ9S3Z8CIH9h/nubgChhzmDi'
      'MxvFHRV3Z5igoHSKpS6wrAHliSZd';
  static const String intermediateDerBase64 =
      'MIIBljCCATugAwIBAgIUHx1ws/JFA3T/ImuQKCRWSGQP6agwCgYIKoZIzj0EAwIwJjEVMBMGA1UE'
      'AwwMVGVzdCBSb290IENBMQ0wCwYDVQQKDARUZXN0MB4XDTI2MDgwNjA2NDk1MloXDTM2MDgwMzA2'
      'NDk1MlowKzEaMBgGA1UEAwwRVGVzdCBJbnRlcm1lZGlhdGUxDTALBgNVBAoMBFRlc3QwWTATBgcq'
      'hkjOPQIBBggqhkjOPQMBBwNCAAQSBW+v/5hFVxV3DZJdj7Md9pMQuibbWGbUUcSwTZh4mbTjdn4/'
      '7w/aNtkmd/ee6SFVCABg2P0oaqGQLvS1axjyo0IwQDAdBgNVHQ4EFgQUi+UD+UahRJInzfjbVMd3'
      'Iogj8NQwHwYDVR0jBBgwFoAU0vDcZYp+et3Gc1y7UzNHx5ye1r8wCgYIKoZIzj0EAwIDSQAwRgIh'
      'AKYmk+6YlB/FabqZQ1tn1qOPEs84nDPkstsZMlkzcQv/AiEAx7Kllw9wc4AA+butSMp9q4JIscKv'
      'kwYwAD9FnRO3TXM=';
  static const String leafDerBase64 =
      'MIIBkjCCATigAwIBAgIUKBLkbG+ifW43818wAW/wCG5OfcMwCgYIKoZIzj0EAwIwKzEaMBgGA1UE'
      'AwwRVGVzdCBJbnRlcm1lZGlhdGUxDTALBgNVBAoMBFRlc3QwHhcNMjYwODA2MDY0OTUyWhcNMzYw'
      'ODAzMDY0OTUyWjAjMRIwEAYDVQQDDAlUZXN0IExlYWYxDTALBgNVBAoMBFRlc3QwWTATBgcqhkjO'
      'PQIBBggqhkjOPQMBBwNCAAS//Yz/EyTxK65uaZz/JGnhtC686zUF7RrP0WiFGoGzGpuEeXPOVXn6'
      '6gNQO38iLe0Uup6561jtrTAS95Q6F3dpo0IwQDAdBgNVHQ4EFgQUfwAd8qxEgbQ7cyShJqBj12V1'
      'xPYwHwYDVR0jBBgwFoAUi+UD+UahRJInzfjbVMd3Iogj8NQwCgYIKoZIzj0EAwIDSAAwRQIgIR5X'
      'bMgyUEEOaoyJM6hfOBUxMij38FxHJbBYBjcILfMCIQCdRx8FVmVGiH5eV5xWASn50Bm6Lg8tL9Dn'
      '0PExLNORNQ==';

  // Raw EC private key bytes for the leaf
  // (`openssl ec -in /tmp/leaf.key -outform DER | base64`), used to sign
  // JWS payloads in WebhookSigner (Task 5).
  static const String leafPrivateKeyDerBase64 =
      'MHcCAQEEIJzFDoGMSAqRoKhjNhbDY+/qItmM8mX5lhbRw3iqVxqPoAoGCCqGSM49AwEHoUQDQgAE'
      'v/2M/xMk8Suubmmc/yRp4bQuvOs1Be0az9FohRqBsxqbhHlzzlV5+uoDUDt/Ii3tFLqeuetY7a0w'
      'EveUOhd3aQ==';

  // A self-signed cert from an entirely separate CA (its own throwaway
  // key, not chained through `rootDerBase64` at all). Used to test that a
  // chain genuinely unrelated to the trusted root is rejected — as
  // opposed to a chain that is merely incomplete but still verifiably
  // rooted in trust, which a different bug class could wrongly accept.
  // Generated the same way as the chain above:
  //   openssl ecparam -name prime256v1 -genkey -noout -out unrelated_leaf.key
  //   openssl req -x509 -new -key unrelated_leaf.key \
  //     -subj "/CN=Unrelated Self-Signed/O=Test" -days 3650 -out unrelated_leaf.pem
  static const String unrelatedSelfSignedDerBase64 =
      'MIIBsjCCAVmgAwIBAgIUKNCak4mpg/+x0VtdbWy3v7/xCGQwCgYIKoZIzj0EAwIwLzEeMBwGA1UE'
      'AwwVVW5yZWxhdGVkIFNlbGYtU2lnbmVkMQ0wCwYDVQQKDARUZXN0MB4XDTI2MDgwNjA3MDgwMFoX'
      'DTM2MDgwMzA3MDgwMFowLzEeMBwGA1UEAwwVVW5yZWxhdGVkIFNlbGYtU2lnbmVkMQ0wCwYDVQQK'
      'DARUZXN0MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE+l+QA4Z04PXut2kquq3KqnDe71oJ/67C'
      'vUpiReJ8wQrSFpoV9GYNHtXEufblT/C3vBU2+X46WnFgRYsuSD49MaNTMFEwHQYDVR0OBBYEFPR7'
      'ljx14hlRBXV8TDbyEuS00kMzMB8GA1UdIwQYMBaAFPR7ljx14hlRBXV8TDbyEuS00kMzMA8GA1Ud'
      'EwEB/wQFMAMBAf8wCgYIKoZIzj0EAwIDRwAwRAIgSpC5C6JwC1gqsys04wA3ljAVab3IIcY42Tb9'
      'zYGDYlICIFciXNlO+HrEjEDciRIK60i2NWxz83dgPXnza+D/AyBx';

  // Raw EC private key bytes for the unrelated self-signed cert above
  // (`openssl ec -in unrelated_leaf.key -outform DER | base64`) — used to
  // produce a genuinely valid signature over an untrusted chain, so a
  // chain-of-trust test can't pass by accident on garbage signature bytes.
  static const String unrelatedPrivateKeyDerBase64 =
      'MHcCAQEEIJApY/iVviNLuTbqsMU8weDGBrV9uW1rbAtijDMufl5PoAoGCCqGSM49AwEHoUQDQgAE'
      '+l+QA4Z04PXut2kquq3KqnDe71oJ/67CvUpiReJ8wQrSFpoV9GYNHtXEufblT/C3vBU2+X46WnFg'
      'RYsuSD49MQ==';

  static List<int> get rootDer => base64.decode(rootDerBase64);
  static List<int> get intermediateDer => base64.decode(intermediateDerBase64);
  static List<int> get leafDer => base64.decode(leafDerBase64);
  static List<int> get leafPrivateKeyDer => base64.decode(leafPrivateKeyDerBase64);
  static List<int> get unrelatedSelfSignedDer => base64.decode(unrelatedSelfSignedDerBase64);
  static List<int> get unrelatedPrivateKeyDer => base64.decode(unrelatedPrivateKeyDerBase64);
}
