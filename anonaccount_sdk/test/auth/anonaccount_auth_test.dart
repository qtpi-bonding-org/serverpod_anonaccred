// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/client.dart'
    show Caller, EndpointAccount, EndpointEntrypoint;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/public_challenge_response.dart'
    show PublicChallengeResponse;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/account_creation_response.dart'
    show AccountCreationResponse;
// ignore: implementation_imports
import 'package:anonaccount_sdk/src/auth/anonaccount_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeAccount extends Mock implements EndpointAccount {}

class _FakeEntrypoint extends Mock implements EndpointEntrypoint {}

class _FakeCaller extends Mock implements Caller {}

void main() {
  late _FakeCaller caller;
  late _FakeAccount account;
  late _FakeEntrypoint entrypoint;

  setUp(() {
    caller = _FakeCaller();
    account = _FakeAccount();
    entrypoint = _FakeEntrypoint();
    when(() => caller.account).thenReturn(account);
    when(() => caller.entrypoint).thenReturn(entrypoint);
    when(() => entrypoint.getChallenge()).thenAnswer(
      (_) async => PublicChallengeResponse(
        challenge: 'CHAL-FAKE',
        difficulty: 4,
        expiresAt: 9999999999,
      ),
    );
    when(() => account.createAccount(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          publicKeyHex: any(named: 'publicKeyHex'),
          ultimateSigningPublicKeyHex: any(named: 'ultimateSigningPublicKeyHex'),
          encryptedDataKey: any(named: 'encryptedDataKey'),
          ultimatePublicKey: any(named: 'ultimatePublicKey'),
          deviceKeyAttestation: any(named: 'deviceKeyAttestation'),
          deviceSigningPublicKeyHex: any(named: 'deviceSigningPublicKeyHex'),
          deviceEncryptedDataKey: any(named: 'deviceEncryptedDataKey'),
          deviceLabel: any(named: 'deviceLabel'),
        )).thenAnswer(
        (_) async => AccountCreationResponse(
              ultimateSigningPublicKeyHex: 'a' * 128,
              encryptedDataKey: 'blob',
              ultimatePublicKey: '{}',
              createdAt: DateTime.utc(2026),
            ));
  });

  group('createAccount (local-only)', () {
    test('produces a complete AccountCreationResult without calling the wire',
        () async {
      final auth = AnonaccountAuth(caller);
      final result = await auth.createAccount(deviceLabel: 'iPhone-15');

      expect(result.keys.ultimateKey, isNotNull);
      expect(result.keys.deviceKey, isNotNull);
      expect(result.payload.devicePublicKeyHex, hasLength(128));
      expect(result.payload.ultimatePublicKeyHex, hasLength(128));
      expect(result.payload.recoveryBlob, isNotEmpty);
      expect(result.payload.deviceBlob, isNotEmpty);
      expect(result.payload.signature, isNotEmpty);
      expect(result.payload.deviceKeyAttestation, isNotEmpty);

      verifyNever(() => account.createAccount(
            challenge: any(named: 'challenge'),
            proofOfWork: any(named: 'proofOfWork'),
            signature: any(named: 'signature'),
            publicKeyHex: any(named: 'publicKeyHex'),
            ultimateSigningPublicKeyHex: any(named: 'ultimateSigningPublicKeyHex'),
            encryptedDataKey: any(named: 'encryptedDataKey'),
            ultimatePublicKey: any(named: 'ultimatePublicKey'),
            deviceKeyAttestation: any(named: 'deviceKeyAttestation'),
            deviceSigningPublicKeyHex: any(named: 'deviceSigningPublicKeyHex'),
            deviceEncryptedDataKey: any(named: 'deviceEncryptedDataKey'),
            deviceLabel: any(named: 'deviceLabel'),
          ));
    });
  });

  group('registerAccount (wire submission)', () {
    test('calls account.createAccount with consistent pubkeys + deviceLabel',
        () async {
      final auth = AnonaccountAuth(caller);
      final created = await auth.createAccount(deviceLabel: 'iPhone-15');
      await auth.registerAccount(
        created.payload,
        keys: created.keys,
        deviceLabel: 'iPhone-15',
      );
      final captured = verify(() => account.createAccount(
            challenge: captureAny(named: 'challenge'),
            proofOfWork: captureAny(named: 'proofOfWork'),
            signature: captureAny(named: 'signature'),
            publicKeyHex: captureAny(named: 'publicKeyHex'),
            ultimateSigningPublicKeyHex:
                captureAny(named: 'ultimateSigningPublicKeyHex'),
            encryptedDataKey: captureAny(named: 'encryptedDataKey'),
            ultimatePublicKey: captureAny(named: 'ultimatePublicKey'),
            deviceKeyAttestation: captureAny(named: 'deviceKeyAttestation'),
            deviceSigningPublicKeyHex:
                captureAny(named: 'deviceSigningPublicKeyHex'),
            deviceEncryptedDataKey:
                captureAny(named: 'deviceEncryptedDataKey'),
            deviceLabel: captureAny(named: 'deviceLabel'),
          )).captured;
      expect(captured[0], 'CHAL-FAKE'); // challenge
      // captured order matches the captureAny order above
      expect(captured[3], created.payload.devicePublicKeyHex); // publicKeyHex
      expect(captured[4],
          created.payload.ultimatePublicKeyHex); // ultimateSigningPublicKeyHex
      expect(captured[5], created.payload.recoveryBlob); // encryptedDataKey
      expect(captured[8],
          created.payload.devicePublicKeyHex); // deviceSigningPublicKeyHex
      expect(captured[9], created.payload.deviceBlob); // deviceEncryptedDataKey
      expect(captured[10], 'iPhone-15'); // deviceLabel
    });
  });
}
