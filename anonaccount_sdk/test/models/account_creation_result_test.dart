import 'package:anonaccount_sdk/src/models/account_creation_result.dart';
import 'package:anonaccount_sdk/src/models/registration_payload.dart';
import 'package:test/test.dart';

void main() {
  test('AccountCreationResult exposes payload', () async {
    final payload = RegistrationPayload(
      devicePublicKeyHex: 'x',
      deviceEncryptionPublicKeyHex: 'x2',
      ultimatePublicKeyHex: 'y',
      ultimateEncryptionPublicKeyHex: 'y2',
      recoveryBlob: '',
      deviceBlob: '',
      deviceKeyAttestation: '',
      createdAt: DateTime.utc(2026, 5, 20),
    );
    final result = AccountCreationResult(payload: payload);
    expect(result.payload, payload);
  });
}
