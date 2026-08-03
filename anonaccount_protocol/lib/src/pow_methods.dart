import 'package:serverpod_serialization/serverpod_serialization.dart'
    show UuidValue;

import 'generated/public_key_duo.dart';

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
  static const grantMemberDevice = 'grantMemberDevice';
}

abstract final class AccountInnerPayloads {
  /// The ultimate key attests to a new device's key pair.
  /// Used identically by createAccount and registerDevice.
  ///
  /// Covers BOTH halves: the encryption key becomes a wrap target, so it must
  /// be inside the signature rather than beside it, or it can be substituted.
  static String registerDevice(PublicKeyDuo deviceKeys) =>
      'registerDevice:${deviceKeys.signingPublicKeyHex}'
      ':${deviceKeys.encryptionPublicKeyHex}';

  /// An existing paired device attests to a newly paired device's key pair.
  static String pairDevice(PublicKeyDuo newDeviceKeys) =>
      'pairDevice:${newDeviceKeys.signingPublicKeyHex}'
      ':${newDeviceKeys.encryptionPublicKeyHex}';
}

abstract final class GroupInnerPayloads {
  /// Same reasoning as AccountInnerPayloads.registerDevice (Task 5): two
  /// same-typed positional strings per key pair is exactly the
  /// transposition hazard PublicKeyDuo exists to prevent. Emitted strings
  /// are byte-identical to the old positional-string form.
  static String createGroup(
    PublicKeyDuo groupUltimateKeys,
    PublicKeyDuo creatorMemberKeys,
  ) =>
      'createGroup:${groupUltimateKeys.signingPublicKeyHex}'
      ':${groupUltimateKeys.encryptionPublicKeyHex}'
      ':${creatorMemberKeys.signingPublicKeyHex}'
      ':${creatorMemberKeys.encryptionPublicKeyHex}';

  /// Takes the role's `.name` rather than GroupMemberRole: that enum is a
  /// column type on group_member and stays in anonaccount_server, because
  /// moving a DB-backed enum across packages is migration risk for no gain.
  /// Role is a single value, not a transposition hazard — unlike the key
  /// pair, which keeps its type.
  static String addGroupMember(
    UuidValue groupId,
    UuidValue newMemberAccountId,
    String roleName,
    PublicKeyDuo memberKeys,
  ) =>
      'addGroupMember:$groupId:$newMemberAccountId:$roleName'
      ':${memberKeys.signingPublicKeyHex}'
      ':${memberKeys.encryptionPublicKeyHex}';

  static String removeGroupMember(UuidValue memberId) =>
      'removeGroupMember:$memberId';

  static String leaveGroup(UuidValue memberId) => 'leaveGroup:$memberId';

  static String getGroup(UuidValue groupId) => 'getGroup:$groupId';

  static String monitorGroupMembership(UuidValue groupId) =>
      'monitorGroupMembership:$groupId';

  static String listGroupMembers(UuidValue groupId) =>
      'listGroupMembers:$groupId';

  /// A grant of one device's access to one membership.
  ///
  /// Covers the wrapped key as well as the device's two public halves. Round 1
  /// puts both key halves inside the device attestation so the wrap *target*
  /// cannot be substituted; the wrapped *value* needs the same protection, or a
  /// server can hand a device a blob containing an attacker-chosen key and that
  /// device then encrypts group content nobody else can read.
  static String grantMemberDevice(
    UuidValue memberId,
    PublicKeyDuo deviceKeys,
    String encryptedDataKey,
  ) =>
      'grantMemberDevice:$memberId:${deviceKeys.signingPublicKeyHex}'
      ':${deviceKeys.encryptionPublicKeyHex}:$encryptedDataKey';

  /// Signed by the member signing key whose pair is inside
  /// [encryptedMemberKey]. Binds the blob to one group, one account, and
  /// one member key, and covers the ciphertext itself — so a party merely
  /// relaying it (the admin, in addGroupMember) can neither substitute the
  /// blob nor redirect it to another group or account.
  ///
  /// Identifies the group by its ultimate signing key rather than its id,
  /// because at createGroup time the group has no id yet.
  static String setEncryptedMemberKey(
    String groupUltimateSigningPublicKeyHex,
    UuidValue anonAccountId,
    String memberSigningPublicKeyHex,
    String encryptedMemberKey,
  ) =>
      'setEncryptedMemberKey:$groupUltimateSigningPublicKeyHex'
      ':$anonAccountId:$memberSigningPublicKeyHex:$encryptedMemberKey';

  static String setEncryptedUltimateKey(
    String groupUltimateSigningPublicKeyHex,
    UuidValue anonAccountId,
    String encryptedUltimateKey,
  ) =>
      'setEncryptedUltimateKey:$groupUltimateSigningPublicKeyHex'
      ':$anonAccountId:$encryptedUltimateKey';
}
