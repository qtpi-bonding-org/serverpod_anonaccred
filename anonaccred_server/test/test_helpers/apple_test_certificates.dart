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

  static List<int> get rootDer => base64.decode(rootDerBase64);
  static List<int> get intermediateDer => base64.decode(intermediateDerBase64);
  static List<int> get leafDer => base64.decode(leafDerBase64);
}
