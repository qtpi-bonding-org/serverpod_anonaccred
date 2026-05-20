import 'package:serverpod/serverpod.dart';
import 'generated/group_member_role.dart';

/// Method name constants for PoW payload construction.
///
/// Both client and server must agree on the method name embedded in the
/// signed payload (`'$challenge:$methodName:$publicKeyHex'`).
/// Using these constants instead of raw strings prevents silent auth
/// failures when a method is renamed on one side but not the other.
abstract final class AccountMethods {
  static const createAccount = 'createAccount';
}

abstract final class DeviceMethods {
  static const registerDevice = 'registerDevice';
  static const signIn = 'signIn';
  static const monitorRegistration = 'monitorRegistration';
}

abstract final class DataKeyMethods {
  static const retrieveEncryptedDataKey = 'retrieveEncryptedDataKey';
  static const recoverEncryptedDataKey = 'recoverEncryptedDataKey';
}

abstract final class GroupMethods {
  static const createGroup = 'createGroup';
  static const listMyGroups = 'listMyGroups';
  static const addGroupMember = 'addGroupMember';
  static const removeGroupMember = 'removeGroupMember';
  static const monitorGroupMembership = 'monitorGroupMembership';
  static const getGroup = 'getGroup';
  static const listGroupMembers = 'listGroupMembers';
  static const leaveGroup = 'leaveGroup';
}

abstract final class AccountInnerPayloads {
  /// Ultimate key attests to a new device signing key.
  /// Used identically in createAccount and registerDevice.
  static String deviceAttestation(String deviceSigningPublicKeyHex) =>
      deviceSigningPublicKeyHex;
}

abstract final class GroupInnerPayloads {
  static String createGroup(
    String ultimateSigningKeyHex,
    String ultimatePublicKey,
    String memberSigningKeyHex,
    String memberPublicKey,
  ) =>
      'createGroup:$ultimateSigningKeyHex:$ultimatePublicKey'
      ':$memberSigningKeyHex:$memberPublicKey';

  static String addGroupMember(
    UuidValue groupId,
    UuidValue newMemberAccountId,
    GroupMemberRole role,
    String memberSigningKeyHex,
    String memberPublicKey,
  ) =>
      'addGroupMember:$groupId:$newMemberAccountId:${role.name}'
      ':$memberSigningKeyHex:$memberPublicKey';

  static String removeGroupMember(UuidValue memberId) =>
      'removeGroupMember:$memberId';

  static String leaveGroup(UuidValue memberId) =>
      'leaveGroup:$memberId';

  static String getGroup(UuidValue groupId) =>
      'getGroup:$groupId';

  static String listGroupMembers(UuidValue groupId) =>
      'listGroupMembers:$groupId';
}
