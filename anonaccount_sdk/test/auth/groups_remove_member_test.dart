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

  test('removeGroupMember calls wire with member-key attestation, null ultimate', () async {
    final caller = _FakeCaller();
    final entrypoint = _FakeEntrypoint();
    final group = _FakeGroup();
    when(() => caller.entrypoint).thenReturn(entrypoint);
    when(() => caller.group).thenReturn(group);
    when(() => entrypoint.getChallenge()).thenAnswer(
      (_) async => wire.PublicChallengeResponse(
        challenge: 'CHAL-RM',
        difficulty: 4,
        expiresAt: 9999999999,
      ),
    );

    final memberId = wire.UuidValue.fromString(
      'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
    );

    when(() => group.removeGroupMember(
          challenge: any(named: 'challenge'),
          proofOfWork: any(named: 'proofOfWork'),
          signature: any(named: 'signature'),
          callerDeviceSigningPublicKeyHex:
              any(named: 'callerDeviceSigningPublicKeyHex'),
          memberId: any(named: 'memberId'),
          callerMemberSigningPublicKeyHex:
              any(named: 'callerMemberSigningPublicKeyHex'),
          memberAuthSignature: any(named: 'memberAuthSignature'),
          groupUltimateSignature: any(named: 'groupUltimateSignature'),
        )).thenAnswer((_) async => true);

    final callerMemberKey = await KeyGen.generateDeviceKey();
    final callerDeviceKey = await KeyGen.generateDeviceKey();
    final groups = AnonaccountGroups(caller, difficulty: 4);

    final result = await groups.removeGroupMember(
      memberId: memberId,
      callerMemberKey: callerMemberKey,
      callerDeviceKey: callerDeviceKey,
    );

    expect(result, isTrue);

    // Verify wire call parameters.
    final captured = verify(
      () => group.removeGroupMember(
        challenge: captureAny(named: 'challenge'),
        proofOfWork: any(named: 'proofOfWork'),
        signature: any(named: 'signature'),
        callerDeviceSigningPublicKeyHex:
            any(named: 'callerDeviceSigningPublicKeyHex'),
        memberId: captureAny(named: 'memberId'),
        callerMemberSigningPublicKeyHex:
            captureAny(named: 'callerMemberSigningPublicKeyHex'),
        memberAuthSignature: captureAny(named: 'memberAuthSignature'),
        groupUltimateSignature: captureAny(named: 'groupUltimateSignature'),
      ),
    ).captured;

    // Indices: challenge(0), memberId(1), callerMemberSigningPublicKeyHex(2),
    //           memberAuthSignature(3), groupUltimateSignature(4)
    expect(captured[0], 'CHAL-RM');
    expect(captured[1].toString(), memberId.toString());
    expect(captured[2], isNotNull); // callerMemberSigningPublicKeyHex
    expect(captured[3], isNotNull); // memberAuthSignature
    expect(captured[4], isNull);    // groupUltimateSignature — null for admin branch
  });
}
