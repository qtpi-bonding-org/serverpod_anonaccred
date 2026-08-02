import 'package:anonaccount_protocol/anonaccount_protocol.dart' hide Protocol;
import 'package:anonaccount_server/src/generated/group_member_role.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:test/test.dart';

/// These strings are SIGNED. If one changes, every signature in the system
/// verifies against the wrong message — at runtime, with no compile error.
/// Never edit an expectation here to make a change pass; the change is wrong.
void main() {
  final duoA = PublicKeyDuo(
    signingPublicKeyHex: '04aa',
    encryptionPublicKeyHex: '04bb',
  );
  final duoB = PublicKeyDuo(
    signingPublicKeyHex: '04cc',
    encryptionPublicKeyHex: '04dd',
  );
  final id1 = UuidValue.fromString('11111111-1111-4111-8111-111111111111');
  final id2 = UuidValue.fromString('22222222-2222-4222-8222-222222222222');

  test('account payloads are unchanged', () {
    expect(AccountInnerPayloads.registerDevice(duoA),
        'registerDevice:04aa:04bb');
    expect(AccountInnerPayloads.pairDevice(duoA), 'pairDevice:04aa:04bb');
  });

  test('group payloads are unchanged', () {
    expect(GroupInnerPayloads.createGroup(duoA, duoB),
        'createGroup:04aa:04bb:04cc:04dd');
    expect(
      GroupInnerPayloads.addGroupMember(
          id1, id2, GroupMemberRole.admin.name, duoA),
      'addGroupMember:$id1:$id2:admin:04aa:04bb',
    );
    expect(GroupInnerPayloads.removeGroupMember(id1), 'removeGroupMember:$id1');
    expect(GroupInnerPayloads.leaveGroup(id1), 'leaveGroup:$id1');
    expect(GroupInnerPayloads.getGroup(id1), 'getGroup:$id1');
    expect(GroupInnerPayloads.listGroupMembers(id1), 'listGroupMembers:$id1');
    expect(GroupInnerPayloads.grantMemberDevice(id1, duoA, 'CT'),
        'grantMemberDevice:$id1:04aa:04bb:CT');
  });

  test('method name constants are unchanged', () {
    expect(AccountMethods.createAccount, 'createAccount');
    expect(DeviceMethods.registerDevice, 'registerDevice');
    expect(DeviceMethods.signIn, 'signIn');
    expect(DeviceMethods.monitorRegistration, 'monitorRegistration');
    expect(DataKeyMethods.retrieveEncryptedDataKey, 'retrieveEncryptedDataKey');
    expect(DataKeyMethods.recoverEncryptedDataKey, 'recoverEncryptedDataKey');
    expect(GroupMethods.createGroup, 'createGroup');
    expect(GroupMethods.listMyGroups, 'listMyGroups');
    expect(GroupMethods.addGroupMember, 'addGroupMember');
    expect(GroupMethods.removeGroupMember, 'removeGroupMember');
    expect(GroupMethods.monitorGroupMembership, 'monitorGroupMembership');
    expect(GroupMethods.getGroup, 'getGroup');
    expect(GroupMethods.listGroupMembers, 'listGroupMembers');
    expect(GroupMethods.leaveGroup, 'leaveGroup');
    expect(GroupMethods.grantMemberDevice, 'grantMemberDevice');
  });
}
