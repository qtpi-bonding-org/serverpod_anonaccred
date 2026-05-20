import 'package:anonaccount_sdk/src/models/registration_payload.dart';
import 'package:test/test.dart';

void main() {
  final example = RegistrationPayload(
    devicePublicKeyHex: 'a' * 128,
    ultimatePublicKeyHex: 'b' * 128,
    recoveryBlob: 'BLOB_R',
    deviceBlob: 'BLOB_D',
    signature: 'SIG',
    deviceKeyAttestation: 'ATT',
    crossDeviceKeyAttestation: null,
    createdAt: DateTime.utc(2026, 5, 20, 12),
  );

  test('signableData uses the documented field order', () {
    expect(
      example.signableData,
      '${'a' * 128}:${'b' * 128}:BLOB_R:BLOB_D:2026-05-20T12:00:00.000Z',
    );
  });

  test('round-trips through JSON', () {
    final json = example.toJson();
    final back = RegistrationPayload.fromJson(json);
    expect(back, example);
  });

  test('crossDeviceKeyAttestation is optional and survives round-trip', () {
    final withCross = example.copyWith(crossDeviceKeyAttestation: 'CROSS');
    final back = RegistrationPayload.fromJson(withCross.toJson());
    expect(back.crossDeviceKeyAttestation, 'CROSS');
  });
}
