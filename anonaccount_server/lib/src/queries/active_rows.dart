import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Every read of a soft-deleted table, with `isRevoked = false` applied.
///
/// These tables' unique indexes are partial, so a query that forgets the
/// filter can match a historical revoked row instead of the live one.
/// Writing the filter in one place is why this file exists (D25).
abstract final class ActiveRows {
  static Future<AccountDevice?> deviceBySigningKey(
    Session session,
    String signingPublicKeyHex, {
    Transaction? transaction,
  }) =>
      AccountDevice.db.findFirstRow(
        session,
        where: (t) =>
            t.deviceSigningPublicKeyHex.equals(signingPublicKeyHex) &
            t.isRevoked.equals(false),
        transaction: transaction,
      );

  static Future<AccountDevice?> deviceByIdForAccount(
    Session session,
    UuidValue deviceId,
    UuidValue accountId, {
    Transaction? transaction,
  }) =>
      AccountDevice.db.findFirstRow(
        session,
        where: (t) =>
            t.id.equals(deviceId) &
            t.anonAccountId.equals(accountId) &
            t.isRevoked.equals(false),
        transaction: transaction,
      );

  static Future<List<AccountDevice>> devicesForAccount(
    Session session,
    UuidValue accountId, {
    Transaction? transaction,
  }) =>
      AccountDevice.db.find(
        session,
        where: (t) =>
            t.anonAccountId.equals(accountId) & t.isRevoked.equals(false),
        transaction: transaction,
      );

  static Future<GroupMember?> memberBySigningKey(
    Session session,
    String memberSigningPublicKeyHex, {
    Transaction? transaction,
  }) =>
      GroupMember.db.findFirstRow(
        session,
        where: (t) =>
            t.memberSigningPublicKeyHex.equals(memberSigningPublicKeyHex) &
            t.isRevoked.equals(false),
        transaction: transaction,
      );

  static Future<GroupMember?> memberInGroup(
    Session session,
    UuidValue groupId,
    UuidValue accountId, {
    Transaction? transaction,
  }) =>
      GroupMember.db.findFirstRow(
        session,
        where: (t) =>
            t.shareGroupId.equals(groupId) &
            t.anonAccountId.equals(accountId) &
            t.isRevoked.equals(false),
        transaction: transaction,
      );

  /// Caller membership lookup by member signing key in a specific group,
  /// active only.
  static Future<GroupMember?> callerMembershipByMemberKey(
    Session session,
    UuidValue groupId,
    String memberSigningPublicKeyHex, {
    Transaction? transaction,
  }) =>
      GroupMember.db.findFirstRow(
        session,
        where: (t) =>
            t.memberSigningPublicKeyHex.equals(memberSigningPublicKeyHex) &
            t.shareGroupId.equals(groupId) &
            t.isRevoked.equals(false),
        transaction: transaction,
      );

  static Future<List<GroupMember>> membersOfGroup(
    Session session,
    UuidValue groupId, {
    Transaction? transaction,
  }) =>
      GroupMember.db.find(
        session,
        where: (t) =>
            t.shareGroupId.equals(groupId) & t.isRevoked.equals(false),
        orderBy: (t) => t.joinedAt,
        transaction: transaction,
      );

  static Future<List<GroupMember>> membershipsForAccount(
    Session session,
    UuidValue accountId, {
    Transaction? transaction,
  }) =>
      GroupMember.db.find(
        session,
        where: (t) =>
            t.anonAccountId.equals(accountId) & t.isRevoked.equals(false),
        transaction: transaction,
      );

  static Future<GroupMemberDevice?> grant(
    Session session,
    UuidValue memberId,
    UuidValue deviceId, {
    Transaction? transaction,
  }) =>
      GroupMemberDevice.db.findFirstRow(
        session,
        where: (t) =>
            t.groupMemberId.equals(memberId) &
            t.accountDeviceId.equals(deviceId) &
            t.isRevoked.equals(false),
        transaction: transaction,
      );

  static Future<List<GroupMemberDevice>> grantsForMember(
    Session session,
    UuidValue memberId, {
    Transaction? transaction,
  }) =>
      GroupMemberDevice.db.find(
        session,
        where: (t) =>
            t.groupMemberId.equals(memberId) & t.isRevoked.equals(false),
        transaction: transaction,
      );

  /// Active grants held by a single device, for every membership it has
  /// been granted into.
  static Future<List<GroupMemberDevice>> grantsForDevice(
    Session session,
    UuidValue deviceId, {
    Transaction? transaction,
  }) =>
      GroupMemberDevice.db.find(
        session,
        where: (t) =>
            t.accountDeviceId.equals(deviceId) & t.isRevoked.equals(false),
        transaction: transaction,
      );

  /// Active grant a given device holds for a given membership.
  static Future<GroupMemberDevice?> grantForDevice(
    Session session,
    UuidValue memberId,
    UuidValue deviceId, {
    Transaction? transaction,
  }) =>
      GroupMemberDevice.db.findFirstRow(
        session,
        where: (t) =>
            t.groupMemberId.equals(memberId) &
            t.accountDeviceId.equals(deviceId) &
            t.isRevoked.equals(false),
        transaction: transaction,
      );

  /// Active memberships of a group, with row locks applied.
  /// Used inside transactions that need to serialize the last-admin check.
  static Future<List<GroupMember>> activeMembersOfGroupForUpdate(
    Session session,
    UuidValue groupId, {
    required Transaction transaction,
  }) =>
      GroupMember.db.find(
        session,
        where: (t) =>
            t.shareGroupId.equals(groupId) & t.isRevoked.equals(false),
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );

  static Future<GroupOwner?> owner(
    Session session,
    UuidValue groupId,
    UuidValue accountId, {
    Transaction? transaction,
  }) =>
      GroupOwner.db.findFirstRow(
        session,
        where: (t) =>
            t.shareGroupId.equals(groupId) &
            t.anonAccountId.equals(accountId) &
            t.isRevoked.equals(false),
        transaction: transaction,
      );

  static Future<List<GroupOwner>> ownersOfGroup(
    Session session,
    UuidValue groupId, {
    Transaction? transaction,
  }) =>
      GroupOwner.db.find(
        session,
        where: (t) =>
            t.shareGroupId.equals(groupId) & t.isRevoked.equals(false),
        transaction: transaction,
      );
}

/// Reads that deliberately include revoked rows.
///
/// Separate from [ActiveRows] so that including them is a choice a reader
/// can see at the call site.
abstract final class AllRows {
  static Future<AccountDevice?> deviceBySigningKeyIncludingRevoked(
    Session session,
    String signingPublicKeyHex, {
    Transaction? transaction,
  }) =>
      AccountDevice.db.findFirstRow(
        session,
        where: (t) =>
            t.deviceSigningPublicKeyHex.equals(signingPublicKeyHex),
        transaction: transaction,
      );

  static Future<AccountDevice?> deviceByIdForAccountIncludingRevoked(
    Session session,
    UuidValue deviceId,
    UuidValue accountId, {
    Transaction? transaction,
  }) =>
      AccountDevice.db.findFirstRow(
        session,
        where: (t) =>
            t.id.equals(deviceId) & t.anonAccountId.equals(accountId),
        transaction: transaction,
      );

  static Future<AccountDevice?> deviceByIdIncludingRevoked(
    Session session,
    UuidValue deviceId, {
    Transaction? transaction,
  }) =>
      AccountDevice.db.findById(
        session,
        deviceId,
        transaction: transaction,
      );

  static Future<List<AccountDevice>> devicesForAccountIncludingRevoked(
    Session session,
    UuidValue accountId, {
    Transaction? transaction,
  }) =>
      AccountDevice.db.find(
        session,
        where: (t) => t.anonAccountId.equals(accountId),
        orderBy: (t) => t.lastActive,
        orderDescending: true,
        transaction: transaction,
      );

  static Future<GroupMember?> groupMemberByIdIncludingRevoked(
    Session session,
    UuidValue memberId, {
    Transaction? transaction,
  }) =>
      GroupMember.db.findById(
        session,
        memberId,
        transaction: transaction,
      );
}
