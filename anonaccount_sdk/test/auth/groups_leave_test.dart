import 'package:anonaccount_client/anonaccount_client.dart' as wire;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeCaller extends Mock implements wire.Caller {}

class _FakeEntrypoint extends Mock implements wire.EndpointEntrypoint {}

class _FakeGroup extends Mock implements wire.EndpointGroup {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      wire.UuidValue.fromString('00000000-0000-4000-8000-000000000000'),
    );
  });

  test('leaveGroup calls wire with member key attestation and correct memberSigningPublicKeyHex', () async {
    final caller = _FakeCaller();
    final entrypoint = _FakeEntrypoint();
    final group = _FakeGroup();
    when(() => caller.entrypoint).thenReturn(entrypoint);
    when(() => caller.group).thenReturn(group);
    when(() => entrypoint.getChallenge()).thenAnswer(
      (_) async => wire.PublicChallengeResponse(
        challenge: 'CHAL-LV',
        difficulty: 4,
        expiresAt: 9999999999,
      ),
    );

    final memberId = wire.UuidValue.fromString(
      'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
    );

    when(() => group.leaveGroup(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          callerDeviceSigningPublicKeyHex:
              any(named: 'callerDeviceSigningPublicKeyHex'),
          memberId: any(named: 'memberId'),
          memberSigningPublicKeyHex: any(named: 'memberSigningPublicKeyHex'),
          memberAuthSignature: any(named: 'memberAuthSignature'),
        )).thenAnswer((_) async => true);

    final callerMemberKey = await KeyGen.generateDeviceKey();
    final callerDeviceKey = await KeyGen.generateDeviceKey();
    final groups = AnonaccountGroups(caller, difficulty: 4);

    final result = await groups.leaveGroup(
      memberId: memberId,
      callerMemberKey: callerMemberKey,
      callerDeviceKey: callerDeviceKey,
    );

    expect(result, isTrue);

    // Extract the caller member key's public key hex for verification.
    final expectedMemberPubkeyHex =
        await callerMemberKey.signingKeyPair.exportPublicKeyHex();

    final captured = verify(
      () => group.leaveGroup(
        challenge: captureAny(named: 'challenge'),
        proofOfWork: any(named: 'proofOfWork'),
        signature: any(named: 'signature'),
        callerDeviceSigningPublicKeyHex:
            any(named: 'callerDeviceSigningPublicKeyHex'),
        memberId: captureAny(named: 'memberId'),
        memberSigningPublicKeyHex:
            captureAny(named: 'memberSigningPublicKeyHex'),
        memberAuthSignature: captureAny(named: 'memberAuthSignature'),
      ),
    ).captured;

    // Indices: challenge(0), memberId(1), memberSigningPublicKeyHex(2), memberAuthSignature(3)
    expect(captured[0], 'CHAL-LV');
    expect(captured[1].toString(), memberId.toString());
    expect(captured[2], expectedMemberPubkeyHex); // caller's own member pubkey hex
    expect(captured[3], isNotNull); // memberAuthSignature — must be non-null
  });
}
