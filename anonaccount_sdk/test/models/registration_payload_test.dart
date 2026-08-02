import 'package:anonaccount_sdk/src/models/registration_payload.dart';
import 'package:test/test.dart';

void main() {
  final example = RegistrationPayload(
    devicePublicKeyHex: '04${'a' * 128}',
    deviceEncryptionPublicKeyHex: '04${'c' * 128}',
    ultimatePublicKeyHex: '04${'b' * 128}',
    ultimateEncryptionPublicKeyHex: '04${'d' * 128}',
    recoveryBlob: 'BLOB_R',
    deviceBlob: 'BLOB_D',
    deviceKeyAttestation: 'ATT',
    createdAt: DateTime.utc(2026, 5, 20, 12),
  );

  test('round-trips through JSON', () {
    final json = example.toJson();
    final back = RegistrationPayload.fromJson(json);
    expect(back, example);
  });

  test('carries both halves of both key pairs', () {
    expect(example.devicePublicKeyHex, hasLength(130));
    expect(example.deviceEncryptionPublicKeyHex, hasLength(130));
    expect(example.ultimatePublicKeyHex, hasLength(130));
    expect(example.ultimateEncryptionPublicKeyHex, hasLength(130));
    expect(
      example.devicePublicKeyHex,
      isNot(example.deviceEncryptionPublicKeyHex),
    );
  });
}
