import 'package:anonaccount_sdk/src/crypto/key_gen.dart';
import 'package:anonaccount_sdk/src/models/account_creation_result.dart';
import 'package:anonaccount_sdk/src/models/registration_payload.dart';
import 'package:test/test.dart';

void main() {
  test('AccountCreationResult exposes keys and payload', () async {
    final keys = await KeyGen.generateAccountKeys();
    final payload = RegistrationPayload(
      devicePublicKeyHex: 'x',
      ultimatePublicKeyHex: 'y',
      recoveryBlob: '',
      deviceBlob: '',
      signature: '',
      deviceKeyAttestation: '',
      createdAt: DateTime.utc(2026, 5, 20),
    );
    final result = AccountCreationResult(keys: keys, payload: payload);
    expect(result.keys, keys);
    expect(result.payload, payload);
  });
}
