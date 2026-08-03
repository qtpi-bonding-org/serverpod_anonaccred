import 'package:anonaccount_client/anonaccount_client.dart' as wire;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _Caller extends Mock implements wire.Caller {}

void main() {
  test('demoteToMember requires a stored group owner key', () async {
    final groups = AnonaccountGroups(
      _Caller(),
      InMemoryMemberKeyStore(),
      InMemoryGroupOwnerKeyStore(),
      difficulty: 4,
    );

    await expectLater(
      groups.demoteToMember(
        groupId: UuidValue.fromString(
          'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        ),
        memberId: UuidValue.fromString(
          'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
        ),
        callerDeviceKey: await KeyGen.generateDeviceKey(),
      ),
      throwsA(isA<StateError>()),
    );
  });
}
