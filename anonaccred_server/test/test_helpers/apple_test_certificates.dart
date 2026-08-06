import 'dart:convert';

/// Test-only P-256 certificate fixtures for Apple x5c chain verification.
class AppleTestCertificates {
  static const String rootDerBase64 =
      'MIIBsjCCAVegAwIBAgIUZqHtlZRca/BuvyRZ+amVhxFCvPcwCgYIKoZIzj0EAwIwJjEVMBMGA1UE'
      'AwwMVGVzdCBSb290IENBMQ0wCwYDVQQKDARUZXN0MB4XDTI2MDgwNjE1NDU0N1oXDTM2MDgwMzE1'
      'NDU0N1owJjEVMBMGA1UEAwwMVGVzdCBSb290IENBMQ0wCwYDVQQKDARUZXN0MFkwEwYHKoZIzj0C'
      'AQYIKoZIzj0DAQcDQgAE+A8j8wIHM8TsuOzdFORRqb41ccQAUoq0kufSMlYSrvmGnf8wqf2UXrIh'
      '9w0c60dYpN3pKjEDNlaJ2egq4O19ZqNjMGEwHQYDVR0OBBYEFBiExPIOlyBD6hzsczeWxnKPuq4g'
      'MB8GA1UdIwQYMBaAFBiExPIOlyBD6hzsczeWxnKPuq4gMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0P'
      'AQH/BAQDAgEGMAoGCCqGSM49BAMCA0kAMEYCIQDPPs7aCCiNwKc+lKXHnOmIf88aGYf+yyygz0tg'
      '1qvGMwIhANQpR388BAVU6/qqSVj1n8WZh8OVbbNA1Hk6gR0Nxrux';

  static const String intermediateDerBase64 =
      'MIIBtTCCAVygAwIBAgIUBH6mxUTDCgGjZUK6Qj0Zctl0HL8wCgYIKoZIzj0EAwIwJjEVMBMGA1UE'
      'AwwMVGVzdCBSb290IENBMQ0wCwYDVQQKDARUZXN0MB4XDTI2MDgwNjE1NDU0N1oXDTM2MDgwMzE1'
      'NDU0N1owKzEaMBgGA1UEAwwRVGVzdCBJbnRlcm1lZGlhdGUxDTALBgNVBAoMBFRlc3QwWTATBgcq'
      'hkjOPQIBBggqhkjOPQMBBwNCAAQi/yV6+z9pGcH2CSYrpoiKJUk9Feo+GGvvrctWqr5Eu5m9ApFr'
      '7BfRQPJeq6QyaagiC11nn62ntUs/p7WreiQSo2MwYTAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB'
      '/wQEAwIBBjAdBgNVHQ4EFgQUqfAM5m8hjabnZarJUvYcITibhM8wHwYDVR0jBBgwFoAUGITE8g6X'
      'IEPqHOxzN5bGco+6riAwCgYIKoZIzj0EAwIDRwAwRAIgR7CudfKUKAtybhXKEI+nseF0XzfKQtSV'
      '5Cs71ODmz2UCIBIQcK5bLzpWJKuXyqfxdGEONCU05uc7BHRbDmUTkg9o';

  static const String leafDerBase64 =
      'MIIBkzCCATigAwIBAgIUegb0m0SlLMratkV5R1ua6m0VecowCgYIKoZIzj0EAwIwKzEaMBgGA1UE'
      'AwwRVGVzdCBJbnRlcm1lZGlhdGUxDTALBgNVBAoMBFRlc3QwHhcNMjYwODA2MTU0NTQ4WhcNMzYw'
      'ODAzMTU0NTQ4WjAjMRIwEAYDVQQDDAlUZXN0IExlYWYxDTALBgNVBAoMBFRlc3QwWTATBgcqhkjO'
      'PQIBBggqhkjOPQMBBwNCAAR0QNDfSww6uZWunIQe4ECe1HQxruBvcftaiWYetvCccW8PulDPW3xR'
      'MSi6FPLY9a5uMTsMgai09ddD03uOBDBho0IwQDAdBgNVHQ4EFgQUSdzymfGlIisQqyYz6ivMpjh3'
      'cHUwHwYDVR0jBBgwFoAUqfAM5m8hjabnZarJUvYcITibhM8wCgYIKoZIzj0EAwIDSQAwRgIhAMIm'
      'oDhA8+JHBTkM402M5lshuySRJPdzWCL7i5n+O9s8AiEA7YvW/3M6E18Ik4yb+doqmK8v+ZhWV4Qs'
      '5/gaZZIcRGk=';

  static const String leafPrivateKeyDerBase64 =
      'MHcCAQEEIMpNYWb1hIqjoa7M/RCjmft723ML8Dt4VVhpmHjfknlToAoGCCqGSM49AwEHoUQDQgAE'
      'dEDQ30sMOrmVrpyEHuBAntR0Ma7gb3H7WolmHrbwnHFvD7pQz1t8UTEouhTy2PWubjE7DIGotPXX'
      'Q9N7jgQwYQ==';

  static const String unrelatedSelfSignedDerBase64 =
      'MIIBsjCCAVmgAwIBAgIUKNCak4mpg/+x0VtdbWy3v7/xCGQwCgYIKoZIzj0EAwIwLzEeMBwGA1UE'
      'AwwVVW5yZWxhdGVkIFNlbGYtU2lnbmVkMQ0wCwYDVQQKDARUZXN0MB4XDTI2MDgwNjA3MDgwMFoX'
      'DTM2MDgwMzA3MDgwMFowLzEeMBwGA1UEAwwVVW5yZWxhdGVkIFNlbGYtU2lnbmVkMQ0wCwYDVQQK'
      'DARUZXN0MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE+l+QA4Z04PXut2kquq3KqnDe71oJ/67C'
      'vUpiReJ8wQrSFpoV9GYNHtXEufblT/C3vBU2+X46WnFgRYsuSD49MaNTMFEwHQYDVR0OBBYEFPR7'
      'ljx14hlRBXV8TDbyEuS00kMzMB8GA1UdIwQYMBaAFPR7ljx14hlRBXV8TDbyEuS00kMzMA8GA1Ud'
      'EwEB/wQFMAMBAf8wCgYIKoZIzj0EAwIDRwAwRAIgSpC5C6JwC1gqsys04wA3ljAVab3IIcY42Tb9'
      'zYGDYlICIFciXNlO+HrEjEDciRIK60i2NWxz83dgPXnza+D/AyBx';

  static const String unrelatedPrivateKeyDerBase64 =
      'MHcCAQEEIJApY/iVviNLuTbqsMU8weDGBrV9uW1rbAtijDMufl5PoAoGCCqGSM49AwEHoUQDQgAE'
      '+l+QA4Z04PXut2kquq3KqnDe71oJ/67CvUpiReJ8wQrSFpoV9GYNHtXEufblT/C3vBU2+X46WnFg'
      'RYsuSD49MQ==';

  static const String expiredLeafDerBase64 =
      'MIIBmzCCAUCgAwIBAgIUegb0m0SlLMratkV5R1ua6m0VecswCgYIKoZIzj0EAwIwKzEaMBgGA1UE'
      'AwwRVGVzdCBJbnRlcm1lZGlhdGUxDTALBgNVBAoMBFRlc3QwHhcNMjAwMTAxMDAwMDAwWhcNMjAw'
      'NjAxMDAwMDAwWjArMRowGAYDVQQDDBFUZXN0IEV4cGlyZWQgTGVhZjENMAsGA1UECgwEVGVzdDBZ'
      'MBMGByqGSM49AgEGCCqGSM49AwEHA0IABIavM6IAo2/QjbNxB27OVu9ov/VzidJ9NN9M5y/DG9dr'
      'MTMnpQcBwiH9k4zdsKN/Ei6RMZTxUlq1dhVmkqerVV6jQjBAMB0GA1UdDgQWBBT/aS62i10pVj39'
      'oKHzPIsPBzUlTTAfBgNVHSMEGDAWgBSp8AzmbyGNpudlqslS9hwhOJuEzzAKBggqhkjOPQQDAgNJ'
      'ADBGAiEAuWJH9C+k+Jze6o4QZDE6MYs2Bj1iinTNuTBaWRDKDL8CIQDQxz719ZKobSIKe8fCbQcg'
      '2Plgl+odLJ2/XblGRWYhVw==';

  static const String expiredLeafPrivateKeyDerBase64 =
      'MHcCAQEEIJeCM0ngbVPzP156oxf3TQOJRH5EtOd2DA+rO8PgF2oloAoGCCqGSM49AwEHoUQDQgAE'
      'hq8zogCjb9CNs3EHbs5W72i/9XOJ0n0030znL8Mb12sxMyelBwHCIf2TjN2wo38SLpExlPFSWrV2'
      'FWaSp6tVXg==';

  static const String nonCaIntermediateDerBase64 =
      'MIIBnTCCAUKgAwIBAgIUBH6mxUTDCgGjZUK6Qj0Zctl0HMAwCgYIKoZIzj0EAwIwJjEVMBMGA1UE'
      'AwwMVGVzdCBSb290IENBMQ0wCwYDVQQKDARUZXN0MB4XDTI2MDgwNjE1NDU1OVoXDTM2MDgwMzE1'
      'NDU1OVowMjEhMB8GA1UEAwwYVGVzdCBOb24tQ0EgSW50ZXJtZWRpYXRlMQ0wCwYDVQQKDARUZXN0'
      'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAENd695Bzr9yCBovASNpzuKIkOKgc5gOH5mYhMclej'
      'S5JIjSYFhjp41SL2I5kMwH7e3+99BFw39XshIJ/3T2inQ6NCMEAwHQYDVR0OBBYEFBK1MBAk/Je7'
      'jVb9DHIcRH/F4+0jMB8GA1UdIwQYMBaAFBiExPIOlyBD6hzsczeWxnKPuq4gMAoGCCqGSM49BAMC'
      'A0kAMEYCIQCQa7bWA7O7lnAh/HEYfI/DRY21vUjpL7FXVpR0SAHXqQIhALLzQ3AZEkWvDh3FzGMs'
      'w4QRQQrbfIfExO7KTMIDFoNY';

  static const String nonCaIntermediatePrivateKeyDerBase64 =
      'MHcCAQEEIDLzTqkWwDe99NTbH6JPmkkPhwS2A+xWhqo4W0q7nNvcoAoGCCqGSM49AwEHoUQDQgAE'
      'Nd695Bzr9yCBovASNpzuKIkOKgc5gOH5mYhMclejS5JIjSYFhjp41SL2I5kMwH7e3+99BFw39Xsh'
      'IJ/3T2inQw==';

  static const String leafSignedByNonCaIntermediateDerBase64 =
      'MIIBozCCAUmgAwIBAgIUZSDMmRpu6DqiXZpx7aBTiAzpJhYwCgYIKoZIzj0EAwIwMjEhMB8GA1UE'
      'AwwYVGVzdCBOb24tQ0EgSW50ZXJtZWRpYXRlMQ0wCwYDVQQKDARUZXN0MB4XDTI2MDgwNjE1NDU1'
      'OVoXDTM2MDgwMzE1NDU1OVowLTEcMBoGA1UEAwwTVGVzdCBMZWFmIFZpYSBOb25DQTENMAsGA1UE'
      'CgwEVGVzdDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABF97N98RjDV4FJAowyFmJ5xczqIogSkG'
      'T6QUcach4OUn2t09WgvhPoEpWCI/5Tw6y/rNYolUyGumJF+sRB7TjDujQjBAMB0GA1UdDgQWBBQ9'
      '1sf3Bb9y1hsAaNeZ9fS+X7y7DTAfBgNVHSMEGDAWgBQStTAQJPyXu41W/QxyHER/xePtIzAKBggq'
      'hkjOPQQDAgNIADBFAiAT1KMHKYqttepIZvRT5gPPSjubSt39iFR8TCeehNCZMwIhAP0EBCNUrHYS'
      'c7c8UT63EWmD/cGBVIYeZqxhRpy/VBW0';

  static const String leafSignedByNonCaIntermediatePrivateKeyDerBase64 =
      'MHcCAQEEIAO4K0Ht2K7DeTXCy/wGhNDDvginJtgjTk8TbdfklrYKoAoGCCqGSM49AwEHoUQDQgAE'
      'X3s33xGMNXgUkCjDIWYnnFzOoiiBKQZPpBRxpyHg5Sfa3T1aC+E+gSlYIj/lPDrL+s1iiVTIa6Yk'
      'X6xEHtOMOw==';

  static List<int> get rootDer => base64.decode(rootDerBase64);
  static List<int> get intermediateDer => base64.decode(intermediateDerBase64);
  static List<int> get leafDer => base64.decode(leafDerBase64);
  static List<int> get leafPrivateKeyDer =>
      base64.decode(leafPrivateKeyDerBase64);
  static List<int> get unrelatedSelfSignedDer =>
      base64.decode(unrelatedSelfSignedDerBase64);
  static List<int> get unrelatedPrivateKeyDer =>
      base64.decode(unrelatedPrivateKeyDerBase64);
  static List<int> get expiredLeafDer => base64.decode(expiredLeafDerBase64);
  static List<int> get expiredLeafPrivateKeyDer =>
      base64.decode(expiredLeafPrivateKeyDerBase64);
  static List<int> get nonCaIntermediateDer =>
      base64.decode(nonCaIntermediateDerBase64);
  static List<int> get nonCaIntermediatePrivateKeyDer =>
      base64.decode(nonCaIntermediatePrivateKeyDerBase64);
  static List<int> get leafSignedByNonCaIntermediateDer =>
      base64.decode(leafSignedByNonCaIntermediateDerBase64);
  static List<int> get leafSignedByNonCaIntermediatePrivateKeyDer =>
      base64.decode(leafSignedByNonCaIntermediatePrivateKeyDerBase64);
}
