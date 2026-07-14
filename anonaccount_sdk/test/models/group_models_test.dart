// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/group_member_role.dart'
    show GroupMemberRole;
import 'package:anonaccount_sdk/src/crypto/key_gen.dart';
import 'package:anonaccount_sdk/src/models/created_group.dart';
import 'package:anonaccount_sdk/src/models/group_membership.dart';
import 'package:test/test.dart';
import 'package:webcrypto/webcrypto.dart';

void main() {
  test('CreatedGroup carries the runtime data key', () async {
    final key = await AesGcmSecretKey.generateKey(256);
    final memberKey = await KeyGen.generateDeviceKey();
    final group = CreatedGroup(
      groupId: '11111111-1111-4111-8111-111111111111',
      displayName: 'Family',
      groupDataKey: key,
      memberKey: memberKey,
      createdAt: DateTime.utc(2026, 5, 20),
    );
    expect(group.groupId, '11111111-1111-4111-8111-111111111111');
    expect(group.groupDataKey, key);
    expect(group.memberKey, memberKey);
  });

  test('GroupMembership round-trips through JSON (sans runtime key)', () {
    final m = GroupMembership(
      groupId: '11111111-1111-4111-8111-111111111111',
      role: GroupMemberRole.admin,
      encryptedDataKey: 'BLOB',
      joinedAt: DateTime.utc(2026, 5, 20),
      isRevoked: false,
    );
    final back = GroupMembership.fromJson(m.toJson());
    expect(back, m);
  });
}
