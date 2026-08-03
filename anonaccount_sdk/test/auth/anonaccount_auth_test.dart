// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/client.dart'
    show Caller, EndpointAccount, EndpointEntrypoint;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/public_challenge_response.dart'
    show PublicChallengeResponse;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/account_creation_response.dart'
    show AccountCreationResponse;
import 'package:anonaccount_protocol/anonaccount_protocol.dart'
    show PublicKeyDuo;
// ignore: implementation_imports
import 'package:anonaccount_sdk/src/auth/anonaccount_auth.dart';
// ignore: implementation_imports
import 'package:anonaccount_sdk/src/auth/in_memory_account_key_store.dart';
import 'package:anonaccount_sdk/src/auth/in_memory_group_owner_key_store.dart';
// ignore: implementation_imports
import 'package:anonaccount_sdk/src/auth/in_memory_member_key_store.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeAccount extends Mock implements EndpointAccount {}

class _FakeEntrypoint extends Mock implements EndpointEntrypoint {}

class _FakeCaller extends Mock implements Caller {}

void main() {
  late _FakeCaller caller;
  late _FakeAccount account;
  late _FakeEntrypoint entrypoint;

  setUpAll(() {
    registerFallbackValue(
      PublicKeyDuo(
        signingPublicKeyHex: '04${'0' * 128}',
        encryptionPublicKeyHex: '04${'1' * 128}',
      ),
    );
  });

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
          ultimateKeys: any(named: 'ultimateKeys'),
          encryptedDataKey: any(named: 'encryptedDataKey'),
          deviceKeys: any(named: 'deviceKeys'),
          deviceKeyAttestation: any(named: 'deviceKeyAttestation'),
          deviceEncryptedDataKey: any(named: 'deviceEncryptedDataKey'),
          deviceLabel: any(named: 'deviceLabel'),
        )).thenAnswer(
        (_) async => AccountCreationResponse(
              ultimateSigningPublicKeyHex: '04${'a' * 128}',
              encryptedDataKey: 'blob',
              ultimateEncryptionPublicKeyHex: '04${'b' * 128}',
              createdAt: DateTime.utc(2026),
            ));
  });

  group('createAccount (local-only)', () {
    test('produces a complete AccountCreationResult without calling the wire',
        () async {
      final auth = AnonaccountAuth(caller, InMemoryAccountKeyStore(), InMemoryMemberKeyStore(), InMemoryGroupOwnerKeyStore());
      final result = await auth.createAccount(
        deviceLabel: 'iPhone-15',
        createdAt: DateTime.utc(2026),
      );

      expect(result.payload.devicePublicKeyHex, hasLength(130));
      expect(result.payload.deviceEncryptionPublicKeyHex, hasLength(130));
      expect(result.payload.ultimatePublicKeyHex, hasLength(130));
      expect(result.payload.ultimateEncryptionPublicKeyHex, hasLength(130));
      expect(
        result.payload.devicePublicKeyHex,
        isNot(result.payload.deviceEncryptionPublicKeyHex),
      );
      expect(
        result.payload.ultimatePublicKeyHex,
        isNot(result.payload.ultimateEncryptionPublicKeyHex),
      );
      expect(result.payload.recoveryBlob, isNotEmpty);
      expect(result.payload.deviceBlob, isNotEmpty);
      expect(result.payload.deviceKeyAttestation, isNotEmpty);

      verifyNever(() => account.createAccount(
            challenge: any(named: 'challenge'),
            proofOfWork: any(named: 'proofOfWork'),
            signature: any(named: 'signature'),
            publicKeyHex: any(named: 'publicKeyHex'),
            ultimateKeys: any(named: 'ultimateKeys'),
            encryptedDataKey: any(named: 'encryptedDataKey'),
            deviceKeys: any(named: 'deviceKeys'),
            deviceKeyAttestation: any(named: 'deviceKeyAttestation'),
            deviceEncryptedDataKey: any(named: 'deviceEncryptedDataKey'),
            deviceLabel: any(named: 'deviceLabel'),
          ));
    });
  });

  group('registerAccount (wire submission)', () {
    test('calls account.createAccount with a duo whose halves differ and are SEC1',
        () async {
      final auth = AnonaccountAuth(caller, InMemoryAccountKeyStore(), InMemoryMemberKeyStore(), InMemoryGroupOwnerKeyStore());
      final created = await auth.createAccount(
        deviceLabel: 'iPhone-15',
        createdAt: DateTime.utc(2026),
      );
      await auth.registerAccount(
        created.payload,
        deviceLabel: 'iPhone-15',
      );
      final captured = verify(() => account.createAccount(
            challenge: captureAny(named: 'challenge'),
            proofOfWork: captureAny(named: 'proofOfWork'),
            signature: captureAny(named: 'signature'),
            publicKeyHex: captureAny(named: 'publicKeyHex'),
            ultimateKeys: captureAny(named: 'ultimateKeys'),
            encryptedDataKey: captureAny(named: 'encryptedDataKey'),
            deviceKeys: captureAny(named: 'deviceKeys'),
            deviceKeyAttestation: captureAny(named: 'deviceKeyAttestation'),
            deviceEncryptedDataKey:
                captureAny(named: 'deviceEncryptedDataKey'),
            deviceLabel: captureAny(named: 'deviceLabel'),
          )).captured;
      expect(captured[0], 'CHAL-FAKE'); // challenge
      // The envelope is signed by the DEVICE key, so publicKeyHex must be
      // the device signing key, not the ultimate key.
      expect(captured[3], created.payload.devicePublicKeyHex); // publicKeyHex

      final capturedUltimateKeys = captured[4] as PublicKeyDuo;
      expect(
        capturedUltimateKeys.signingPublicKeyHex,
        created.payload.ultimatePublicKeyHex,
      );
      expect(
        capturedUltimateKeys.encryptionPublicKeyHex,
        created.payload.ultimateEncryptionPublicKeyHex,
      );

      expect(captured[5], created.payload.recoveryBlob); // encryptedDataKey

      final capturedDeviceKeys = captured[6] as PublicKeyDuo;
      expect(
        capturedDeviceKeys.signingPublicKeyHex,
        created.payload.devicePublicKeyHex,
      );
      expect(
        capturedDeviceKeys.encryptionPublicKeyHex,
        created.payload.deviceEncryptionPublicKeyHex,
      );
      expect(
        capturedDeviceKeys.signingPublicKeyHex,
        isNot(capturedDeviceKeys.encryptionPublicKeyHex),
      );

      expect(captured[8], created.payload.deviceBlob); // deviceEncryptedDataKey
      expect(captured[9], 'iPhone-15'); // deviceLabel
    });
  });
}
