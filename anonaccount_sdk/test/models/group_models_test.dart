// ignore: implementation_imports
import 'package:anonaccount_client/anonaccount_client.dart' show UuidValue;
// ignore: implementation_imports
import 'package:anonaccount_client/src/protocol/group_member_role.dart'
    show GroupMemberRole;
import 'package:anonaccount_sdk/src/models/created_group.dart';
import 'package:anonaccount_sdk/src/models/group_membership.dart';
import 'package:test/test.dart';
import 'package:webcrypto/webcrypto.dart';

void main() {
  test('CreatedGroup carries the runtime data key', () async {
    final key = await AesGcmSecretKey.generateKey(256);
    final group = CreatedGroup(
      groupId: '11111111-1111-4111-8111-111111111111',
      displayName: 'Family',
      groupDataKey: key,
      createdAt: DateTime.utc(2026, 5, 20),
    );
    expect(group.groupId, '11111111-1111-4111-8111-111111111111');
    expect(group.groupDataKey, key);
  });

  test('GroupMembership round-trips through JSON (sans runtime key)', () {
    final m = GroupMembership(
      groupId: '11111111-1111-4111-8111-111111111111',
      memberId: UuidValue.fromString('66666666-6666-4666-8666-666666666666'),
      role: GroupMemberRole.admin,
      memberSigningPublicKeyHex: '04${'a' * 128}',
      memberEncryptedDataKey: 'BLOB',
      deviceEncryptedDataKey: 'device-blob',
      joinedAt: DateTime.utc(2026, 5, 20),
    );
    final back = GroupMembership.fromJson(m.toJson());
    expect(back, m);
  });
}
