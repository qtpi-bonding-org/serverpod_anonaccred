import 'package:serverpod/serverpod.dart';
import '../crypto_utils.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../helpers.dart';
import '../pow_methods.dart';
import 'signed_pow_endpoint.dart';

/// Three-tier auth model for group operations:
///
/// 1. **Transport (outer envelope):** every call carries a PoW + ECDSA
///    signature from the caller's device key. Same shape as every other
///    `SignedPowEndpoint`. Proves the request is live and from a
///    non-revoked device of some account.
/// 2. **Role (inner signature):** for admin-tier ops where the role is
///    `member`, the caller's group-member signing key signs an
///    operation-specific payload. The server verifies against the row
///    in `group_member` and asserts `role = admin`, not revoked, and
///    account-bound to the device-resolved account.
/// 3. **Owner (inner signature):** for owner-tier ops (creating the
///    group, granting/removing admins), the group's ultimate signing
///    key signs the inner payload. The server verifies against
///    `share_group.ultimateSigningPublicKeyHex`. There is no DB role
///    for "owner" — possession of the ultimate private key IS owner
///    authority.
///
/// Inner payloads are challenge-free so the persisted attestation is
/// reconstructable from row state alone. Outer envelopes keep the
/// challenge for transport replay protection (PoW).
class GroupEndpoint extends SignedPowEndpoint {
  @override
  String get endpointType => 'group';

  @override
  int get rateLimitPerHour => 30;

  /// Create a new share group.
  ///
  /// The creator becomes the first `admin`. Possession of the new
  /// group's ultimate signing private key (proven by signing the inner
  /// payload) makes them an "owner" — there is no DB role for that.
  Future<ShareGroup> createGroup(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required String groupUltimateSigningPublicKeyHex,
    required String groupUltimatePublicKey,
    required String groupEncryptedDataKey,
    required String creatorMemberSigningPublicKeyHex,
    required String creatorMemberPublicKey,
    required String creatorMemberEncryptedDataKey,
    required String groupUltimateAttestation,
  }) async {
    try {
      final outerPayload =
          '$challenge:${GroupMethods.createGroup}:$callerDeviceSigningPublicKeyHex';
      await verifySignedPow(
        session,
        challenge,
        proofOfWork,
        callerDeviceSigningPublicKeyHex,
        signature,
        outerPayload,
      );

      final callerDevice = await AccountDevice.db.findFirstRow(
        session,
        where: (t) =>
            t.deviceSigningPublicKeyHex.equals(callerDeviceSigningPublicKeyHex),
      );
      final activeDevice = AnonAccountHelpers.requireActiveDevice(
        callerDevice,
        callerDeviceSigningPublicKeyHex,
        'createGroup',
      );
      final accountId = activeDevice.anonAccountId;

      AnonAccountHelpers.validatePublicKey(
        groupUltimateSigningPublicKeyHex,
        'createGroup',
      );
      AnonAccountHelpers.validatePublicKey(
        groupUltimatePublicKey,
        'createGroup',
      );
      AnonAccountHelpers.validatePublicKey(
        creatorMemberSigningPublicKeyHex,
        'createGroup',
      );
      AnonAccountHelpers.validatePublicKey(
        creatorMemberPublicKey,
        'createGroup',
      );
      AnonAccountHelpers.validateNonEmpty(
        groupEncryptedDataKey,
        'groupEncryptedDataKey',
        'createGroup',
      );
      AnonAccountHelpers.validateNonEmpty(
        creatorMemberEncryptedDataKey,
        'creatorMemberEncryptedDataKey',
        'createGroup',
      );

      final innerPayload = GroupInnerPayloads.createGroup(
        groupUltimateSigningPublicKeyHex,
        groupUltimatePublicKey,
        creatorMemberSigningPublicKeyHex,
        creatorMemberPublicKey,
      );
      final innerOk = await CryptoUtils.verifySignature(
        message: innerPayload,
        signature: groupUltimateAttestation,
        publicKey: groupUltimateSigningPublicKeyHex,
      );
      if (!innerOk) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.cryptoInvalidSignature,
          message:
              'Invalid group ultimate attestation — privkey did not authorize this createGroup',
          operation: 'createGroup',
        );
      }

      final now = DateTime.now();
      final group = ShareGroup(
        ultimateSigningPublicKeyHex: groupUltimateSigningPublicKeyHex,
        ultimatePublicKey: groupUltimatePublicKey,
        encryptedDataKey: groupEncryptedDataKey,
        createdAt: now,
      );
      final insertedGroup = await ShareGroup.db.insertRow(session, group);

      final member = GroupMember(
        shareGroupId: insertedGroup.id!,
        anonAccountId: accountId,
        role: GroupMemberRole.admin,
        memberSigningPublicKeyHex: creatorMemberSigningPublicKeyHex,
        memberPublicKey: creatorMemberPublicKey,
        encryptedDataKey: creatorMemberEncryptedDataKey,
        joinedAt: now,
        lastActive: now,
        isRevoked: false,
        addedBySignerPublicKeyHex: groupUltimateSigningPublicKeyHex,
        addedByAttestation: groupUltimateAttestation,
      );
      await GroupMember.db.insertRow(session, member);

      return insertedGroup;
    } on AuthenticationException {
      rethrow;
    } catch (e, stackTrace) {
      session.log(
        'GroupEndpoint: createGroup error: $e\n$stackTrace',
        level: LogLevel.error,
      );
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'createGroup failed: ${e.toString()}',
        operation: 'createGroup',
        details: {'error': e.toString()},
      );
    }
  }

  /// List the caller's non-revoked group memberships.
  Future<List<GroupMember>> listMyGroups(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
  }) async {
    try {
      final outerPayload =
          '$challenge:${GroupMethods.listMyGroups}:$callerDeviceSigningPublicKeyHex';
      await verifySignedPow(
        session,
        challenge,
        proofOfWork,
        callerDeviceSigningPublicKeyHex,
        signature,
        outerPayload,
      );

      final accountId = await AnonAccountHelpers.resolveAccountUuid(
        session,
        callerDeviceSigningPublicKeyHex,
        'listMyGroups',
      );

      return await GroupMember.db.find(
        session,
        where: (t) =>
            t.anonAccountId.equals(accountId) & t.isRevoked.equals(false),
        orderBy: (t) => t.joinedAt,
        orderDescending: true,
      );
    } on AuthenticationException {
      rethrow;
    } catch (e, stackTrace) {
      session.log(
        'GroupEndpoint: listMyGroups error: $e\n$stackTrace',
        level: LogLevel.error,
      );
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'listMyGroups failed: ${e.toString()}',
        operation: 'listMyGroups',
        details: {'error': e.toString()},
      );
    }
  }

  /// Add a new member to a group.
  ///
  /// Auth branches on [role]:
  /// - `member`: requires `callerMemberSigningPublicKeyHex` +
  ///   `memberAuthSignature`. Caller's `group_member` row must be
  ///   `role = admin`, not revoked, and account-bound to the
  ///   device-resolved account.
  /// - `admin`: requires `groupUltimateSignature`. Verified against
  ///   `share_group.ultimateSigningPublicKeyHex`. Member-tier params
  ///   are ignored.
  Future<GroupMember> addGroupMember(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required UuidValue groupId,
    required UuidValue newMemberAccountId,
    required GroupMemberRole role,
    required String memberSigningPublicKeyHex,
    required String memberPublicKey,
    required String encryptedDataKey,
    String? callerMemberSigningPublicKeyHex,
    String? memberAuthSignature,
    String? groupUltimateSignature,
  }) async {
    try {
      final outerPayload =
          '$challenge:${GroupMethods.addGroupMember}:$callerDeviceSigningPublicKeyHex';
      await verifySignedPow(
        session,
        challenge,
        proofOfWork,
        callerDeviceSigningPublicKeyHex,
        signature,
        outerPayload,
      );

      AnonAccountHelpers.validatePublicKey(
        memberSigningPublicKeyHex,
        'addGroupMember',
      );
      AnonAccountHelpers.validatePublicKey(memberPublicKey, 'addGroupMember');
      AnonAccountHelpers.validateNonEmpty(
        encryptedDataKey,
        'encryptedDataKey',
        'addGroupMember',
      );

      final innerPayload = GroupInnerPayloads.addGroupMember(
        groupId,
        newMemberAccountId,
        role,
        memberSigningPublicKeyHex,
        memberPublicKey,
      );

      late final String attestingPubkey;
      late final String attestationSig;

      if (role == GroupMemberRole.admin) {
        // Owner-tier path: ignore member-sig params, require ultimate sig.
        if (groupUltimateSignature == null || groupUltimateSignature.isEmpty) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.authMissingKey,
            message:
                'addGroupMember with role=admin requires groupUltimateSignature',
            operation: 'addGroupMember',
          );
        }
        final group = await ShareGroup.db.findById(session, groupId);
        if (group == null) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.authAccountNotFound,
            message: 'Group not found',
            operation: 'addGroupMember',
            details: {'groupId': groupId.toString()},
          );
        }
        final innerOk = await CryptoUtils.verifySignature(
          message: innerPayload,
          signature: groupUltimateSignature,
          publicKey: group.ultimateSigningPublicKeyHex,
        );
        if (!innerOk) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.cryptoInvalidSignature,
            message: 'Invalid group ultimate attestation for admin grant',
            operation: 'addGroupMember',
          );
        }
        attestingPubkey = group.ultimateSigningPublicKeyHex;
        attestationSig = groupUltimateSignature;
      } else {
        // Admin-tier path: require caller member-key sig.
        if (callerMemberSigningPublicKeyHex == null ||
            callerMemberSigningPublicKeyHex.isEmpty ||
            memberAuthSignature == null ||
            memberAuthSignature.isEmpty) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.authMissingKey,
            message:
                'addGroupMember with role=member requires callerMemberSigningPublicKeyHex and memberAuthSignature',
            operation: 'addGroupMember',
          );
        }
        final innerOk = await CryptoUtils.verifySignature(
          message: innerPayload,
          signature: memberAuthSignature,
          publicKey: callerMemberSigningPublicKeyHex,
        );
        if (!innerOk) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.cryptoInvalidSignature,
            message: 'Invalid member attestation',
            operation: 'addGroupMember',
          );
        }
        final callerMembership = await GroupMember.db.findFirstRow(
          session,
          where: (t) =>
              t.memberSigningPublicKeyHex
                  .equals(callerMemberSigningPublicKeyHex) &
              t.shareGroupId.equals(groupId) &
              t.isRevoked.equals(false),
        );
        if (callerMembership == null) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.authAccountNotFound,
            message: 'No active membership for caller member key in this group',
            operation: 'addGroupMember',
          );
        }
        if (callerMembership.role != GroupMemberRole.admin) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.authInvalidSignature,
            message: 'Caller is not an admin of this group',
            operation: 'addGroupMember',
          );
        }
        final deviceAccountId = await AnonAccountHelpers.resolveAccountUuid(
          session,
          callerDeviceSigningPublicKeyHex,
          'addGroupMember',
        );
        if (callerMembership.anonAccountId != deviceAccountId) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.authInvalidSignature,
            message:
                'Caller member key is not bound to the device-resolved account',
            operation: 'addGroupMember',
          );
        }
        attestingPubkey = callerMemberSigningPublicKeyHex;
        attestationSig = memberAuthSignature;
      }

      // Reject duplicate non-revoked memberships.
      final existing = await GroupMember.db.findFirstRow(
        session,
        where: (t) =>
            t.shareGroupId.equals(groupId) &
            t.anonAccountId.equals(newMemberAccountId) &
            t.isRevoked.equals(false),
      );
      if (existing != null) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authDuplicateDevice,
          message: 'Account already a member of this group',
          operation: 'addGroupMember',
          details: {
            'groupId': groupId.toString(),
            'accountId': newMemberAccountId.toString(),
          },
        );
      }

      final now = DateTime.now();
      final member = GroupMember(
        shareGroupId: groupId,
        anonAccountId: newMemberAccountId,
        role: role,
        memberSigningPublicKeyHex: memberSigningPublicKeyHex,
        memberPublicKey: memberPublicKey,
        encryptedDataKey: encryptedDataKey,
        joinedAt: now,
        lastActive: now,
        isRevoked: false,
        addedBySignerPublicKeyHex: attestingPubkey,
        addedByAttestation: attestationSig,
      );
      final insertedMember = await GroupMember.db.insertRow(session, member);
      session.messages.postMessage(
        'group-membership-${insertedMember.memberSigningPublicKeyHex}',
        insertedMember,
      );
      return insertedMember;
    } on AuthenticationException {
      rethrow;
    } catch (e, stackTrace) {
      session.log(
        'GroupEndpoint: addGroupMember error: $e\n$stackTrace',
        level: LogLevel.error,
      );
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'addGroupMember failed: ${e.toString()}',
        operation: 'addGroupMember',
        details: {'error': e.toString()},
      );
    }
  }

  /// Mark a group member as revoked.
  ///
  /// Auth branches on the target row's [role]:
  /// - target `member`: caller's member key must be admin (+ binding check).
  /// - target `admin`: requires `groupUltimateSignature`.
  Future<bool> removeGroupMember(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required UuidValue memberId,
    String? callerMemberSigningPublicKeyHex,
    String? memberAuthSignature,
    String? groupUltimateSignature,
  }) async {
    try {
      final outerPayload =
          '$challenge:${GroupMethods.removeGroupMember}:$callerDeviceSigningPublicKeyHex';
      await verifySignedPow(
        session,
        challenge,
        proofOfWork,
        callerDeviceSigningPublicKeyHex,
        signature,
        outerPayload,
      );

      final target = await GroupMember.db.findById(session, memberId);
      if (target == null) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authDeviceNotFound,
          message: 'Group member not found',
          operation: 'removeGroupMember',
          details: {'memberId': memberId.toString()},
        );
      }

      final innerPayload = GroupInnerPayloads.removeGroupMember(memberId);
      late final String attestingPubkey;
      late final String attestationSig;

      if (target.role == GroupMemberRole.admin) {
        if (groupUltimateSignature == null || groupUltimateSignature.isEmpty) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.authMissingKey,
            message:
                'Removing an admin requires groupUltimateSignature',
            operation: 'removeGroupMember',
          );
        }
        final group = await ShareGroup.db.findById(session, target.shareGroupId);
        if (group == null) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.authAccountNotFound,
            message: 'Group not found',
            operation: 'removeGroupMember',
          );
        }
        final ok = await CryptoUtils.verifySignature(
          message: innerPayload,
          signature: groupUltimateSignature,
          publicKey: group.ultimateSigningPublicKeyHex,
        );
        if (!ok) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.cryptoInvalidSignature,
            message: 'Invalid group ultimate attestation for admin removal',
            operation: 'removeGroupMember',
          );
        }
        attestingPubkey = group.ultimateSigningPublicKeyHex;
        attestationSig = groupUltimateSignature;
      } else {
        // target.role == member: caller's member key must be admin in the same group.
        if (callerMemberSigningPublicKeyHex == null ||
            callerMemberSigningPublicKeyHex.isEmpty ||
            memberAuthSignature == null ||
            memberAuthSignature.isEmpty) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.authMissingKey,
            message:
                'Removing a member requires callerMemberSigningPublicKeyHex and memberAuthSignature',
            operation: 'removeGroupMember',
          );
        }
        final ok = await CryptoUtils.verifySignature(
          message: innerPayload,
          signature: memberAuthSignature,
          publicKey: callerMemberSigningPublicKeyHex,
        );
        if (!ok) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.cryptoInvalidSignature,
            message: 'Invalid member attestation',
            operation: 'removeGroupMember',
          );
        }
        final callerMembership = await GroupMember.db.findFirstRow(
          session,
          where: (t) =>
              t.memberSigningPublicKeyHex
                  .equals(callerMemberSigningPublicKeyHex) &
              t.shareGroupId.equals(target.shareGroupId) &
              t.isRevoked.equals(false),
        );
        if (callerMembership == null) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.authAccountNotFound,
            message: 'No active membership for caller in this group',
            operation: 'removeGroupMember',
          );
        }
        if (callerMembership.role != GroupMemberRole.admin) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.authInvalidSignature,
            message: 'Caller is not an admin of this group',
            operation: 'removeGroupMember',
          );
        }
        final deviceAccountId = await AnonAccountHelpers.resolveAccountUuid(
          session,
          callerDeviceSigningPublicKeyHex,
          'removeGroupMember',
        );
        if (callerMembership.anonAccountId != deviceAccountId) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.authInvalidSignature,
            message:
                'Caller member key is not bound to the device-resolved account',
            operation: 'removeGroupMember',
          );
        }
        attestingPubkey = callerMemberSigningPublicKeyHex;
        attestationSig = memberAuthSignature;
      }

      // Last-admin guard: if removing target would leave 0 admins, either
      // dissolve (no other members remain) or reject (members would be orphaned).
      var shouldDissolve = false;
      if (target.role == GroupMemberRole.admin) {
        final activeMembers = await GroupMember.db.find(
          session,
          where: (t) =>
              t.shareGroupId.equals(target.shareGroupId) &
              t.isRevoked.equals(false),
        );
        final activeAdmins =
            activeMembers.where((m) => m.role == GroupMemberRole.admin).toList();
        if (activeAdmins.length == 1 && activeAdmins.first.id == target.id) {
          final otherMembers =
              activeMembers.where((m) => m.id != target.id).toList();
          if (otherMembers.isNotEmpty) {
            throw AnonAccountExceptionFactory.createAuthenticationException(
              code: AnonAccountErrorCodes.groupOperationNotAllowed,
              message: 'Cannot remove the last admin while other members remain. '
                  'Promote another member to admin first.',
              operation: 'removeGroupMember',
              details: {'groupId': target.shareGroupId.toString()},
            );
          }
          shouldDissolve = true;
        }
      }

      if (!target.isRevoked) {
        await GroupMember.db.updateRow(
          session,
          target.copyWith(
            isRevoked: true,
            revokedBySignerPublicKeyHex: attestingPubkey,
            revokedByAttestation: attestationSig,
          ),
        );
      }

      if (shouldDissolve) {
        final group =
            await ShareGroup.db.findById(session, target.shareGroupId);
        if (group != null) {
          await ShareGroup.db.deleteRow(session, group);
        }
      }

      return true;
    } on AuthenticationException {
      rethrow;
    } catch (e, stackTrace) {
      session.log(
        'GroupEndpoint: removeGroupMember error: $e\n$stackTrace',
        level: LogLevel.error,
      );
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'removeGroupMember failed: ${e.toString()}',
        operation: 'removeGroupMember',
        details: {'error': e.toString()},
      );
    }
  }

  Stream<GroupMember> monitorGroupMembership(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required String memberSigningKeyHex,
  }) async* {
    final outerPayload =
        '$challenge:${GroupMethods.monitorGroupMembership}:$callerDeviceSigningPublicKeyHex';
    await verifySignedPow(
      session,
      challenge,
      proofOfWork,
      callerDeviceSigningPublicKeyHex,
      signature,
      outerPayload,
    );

    final channelName = 'group-membership-$memberSigningKeyHex';
    final stream = session.messages.createStream<GroupMember>(channelName);

    await for (final event in stream) {
      yield event;
    }
  }

  Future<ShareGroup> getGroup(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required UuidValue groupId,
    required String callerMemberSigningPublicKeyHex,
    required String memberAuthSignature,
  }) async {
    try {
      final outerPayload =
          '$challenge:${GroupMethods.getGroup}:$callerDeviceSigningPublicKeyHex';
      await verifySignedPow(
        session,
        challenge,
        proofOfWork,
        callerDeviceSigningPublicKeyHex,
        signature,
        outerPayload,
      );

      final innerPayload = GroupInnerPayloads.getGroup(groupId);
      final innerOk = await CryptoUtils.verifySignature(
        message: innerPayload,
        signature: memberAuthSignature,
        publicKey: callerMemberSigningPublicKeyHex,
      );
      if (!innerOk) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.cryptoInvalidSignature,
          message: 'Invalid member attestation for getGroup',
          operation: 'getGroup',
        );
      }

      final callerMembership = await GroupMember.db.findFirstRow(
        session,
        where: (t) =>
            t.memberSigningPublicKeyHex
                .equals(callerMemberSigningPublicKeyHex) &
            t.shareGroupId.equals(groupId) &
            t.isRevoked.equals(false),
      );
      if (callerMembership == null) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authAccountNotFound,
          message: 'No active membership for caller in this group',
          operation: 'getGroup',
        );
      }

      final deviceAccountId = await AnonAccountHelpers.resolveAccountUuid(
        session,
        callerDeviceSigningPublicKeyHex,
        'getGroup',
      );
      if (callerMembership.anonAccountId != deviceAccountId) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authInvalidSignature,
          message: 'Caller member key is not bound to the device-resolved account',
          operation: 'getGroup',
        );
      }

      final group = await ShareGroup.db.findById(session, groupId);
      if (group == null) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authAccountNotFound,
          message: 'Group not found',
          operation: 'getGroup',
          details: {'groupId': groupId.toString()},
        );
      }
      return group;
    } on AuthenticationException {
      rethrow;
    } catch (e, stackTrace) {
      session.log(
        'GroupEndpoint: getGroup error: $e\n$stackTrace',
        level: LogLevel.error,
      );
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'getGroup failed: ${e.toString()}',
        operation: 'getGroup',
        details: {'error': e.toString()},
      );
    }
  }

  Future<List<GroupMember>> listGroupMembers(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required UuidValue groupId,
    required String callerMemberSigningPublicKeyHex,
    required String memberAuthSignature,
  }) async {
    try {
      final outerPayload =
          '$challenge:${GroupMethods.listGroupMembers}:$callerDeviceSigningPublicKeyHex';
      await verifySignedPow(
        session,
        challenge,
        proofOfWork,
        callerDeviceSigningPublicKeyHex,
        signature,
        outerPayload,
      );

      final innerPayload = GroupInnerPayloads.listGroupMembers(groupId);
      final innerOk = await CryptoUtils.verifySignature(
        message: innerPayload,
        signature: memberAuthSignature,
        publicKey: callerMemberSigningPublicKeyHex,
      );
      if (!innerOk) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.cryptoInvalidSignature,
          message: 'Invalid member attestation for listGroupMembers',
          operation: 'listGroupMembers',
        );
      }

      final callerMembership = await GroupMember.db.findFirstRow(
        session,
        where: (t) =>
            t.memberSigningPublicKeyHex
                .equals(callerMemberSigningPublicKeyHex) &
            t.shareGroupId.equals(groupId) &
            t.isRevoked.equals(false),
      );
      if (callerMembership == null) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authAccountNotFound,
          message: 'No active membership for caller in this group',
          operation: 'listGroupMembers',
        );
      }

      final deviceAccountId = await AnonAccountHelpers.resolveAccountUuid(
        session,
        callerDeviceSigningPublicKeyHex,
        'listGroupMembers',
      );
      if (callerMembership.anonAccountId != deviceAccountId) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authInvalidSignature,
          message: 'Caller member key is not bound to the device-resolved account',
          operation: 'listGroupMembers',
        );
      }

      return await GroupMember.db.find(
        session,
        where: (t) =>
            t.shareGroupId.equals(groupId) & t.isRevoked.equals(false),
        orderBy: (t) => t.joinedAt,
      );
    } on AuthenticationException {
      rethrow;
    } catch (e, stackTrace) {
      session.log(
        'GroupEndpoint: listGroupMembers error: $e\n$stackTrace',
        level: LogLevel.error,
      );
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'listGroupMembers failed: ${e.toString()}',
        operation: 'listGroupMembers',
        details: {'error': e.toString()},
      );
    }
  }

  Future<bool> leaveGroup(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required UuidValue memberId,
    required String memberSigningPublicKeyHex,
    required String memberAuthSignature,
  }) async {
    try {
      final outerPayload =
          '$challenge:${GroupMethods.leaveGroup}:$callerDeviceSigningPublicKeyHex';
      await verifySignedPow(
        session,
        challenge,
        proofOfWork,
        callerDeviceSigningPublicKeyHex,
        signature,
        outerPayload,
      );

      final target = await GroupMember.db.findById(session, memberId);
      if (target == null || target.isRevoked) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authDeviceNotFound,
          message: 'Group member not found or already revoked',
          operation: 'leaveGroup',
          details: {'memberId': memberId.toString()},
        );
      }

      if (target.memberSigningPublicKeyHex != memberSigningPublicKeyHex) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authInvalidSignature,
          message: 'memberSigningPublicKeyHex does not match the target row',
          operation: 'leaveGroup',
        );
      }

      final innerPayload = GroupInnerPayloads.leaveGroup(memberId);
      final innerOk = await CryptoUtils.verifySignature(
        message: innerPayload,
        signature: memberAuthSignature,
        publicKey: memberSigningPublicKeyHex,
      );
      if (!innerOk) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.cryptoInvalidSignature,
          message: 'Invalid member attestation for leaveGroup',
          operation: 'leaveGroup',
        );
      }

      final deviceAccountId = await AnonAccountHelpers.resolveAccountUuid(
        session,
        callerDeviceSigningPublicKeyHex,
        'leaveGroup',
      );
      if (target.anonAccountId != deviceAccountId) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authInvalidSignature,
          message:
              'Caller member key is not bound to the device-resolved account',
          operation: 'leaveGroup',
        );
      }

      // Last-admin guard: check before leaving so we can give a clear error
      // rather than leaving the group in an adminless-but-not-dissolved state.
      var shouldDissolve = false;
      if (target.role == GroupMemberRole.admin) {
        final activeMembers = await GroupMember.db.find(
          session,
          where: (t) =>
              t.shareGroupId.equals(target.shareGroupId) &
              t.isRevoked.equals(false),
        );
        final activeAdmins =
            activeMembers.where((m) => m.role == GroupMemberRole.admin).toList();
        if (activeAdmins.length == 1 && activeAdmins.first.id == target.id) {
          final otherMembers =
              activeMembers.where((m) => m.id != target.id).toList();
          if (otherMembers.isNotEmpty) {
            throw AnonAccountExceptionFactory.createAuthenticationException(
              code: AnonAccountErrorCodes.groupOperationNotAllowed,
              message: 'Cannot leave as the last admin while other members remain. '
                  'Promote another member to admin first.',
              operation: 'leaveGroup',
              details: {'groupId': target.shareGroupId.toString()},
            );
          }
          shouldDissolve = true;
        }
      }

      await GroupMember.db.updateRow(
        session,
        target.copyWith(
          isRevoked: true,
          revokedBySignerPublicKeyHex: memberSigningPublicKeyHex,
          revokedByAttestation: memberAuthSignature,
        ),
      );

      if (shouldDissolve) {
        final group = await ShareGroup.db.findById(session, target.shareGroupId);
        if (group != null) {
          await ShareGroup.db.deleteRow(session, group);
        }
      }

      return true;
    } on AuthenticationException {
      rethrow;
    } catch (e, stackTrace) {
      session.log(
        'GroupEndpoint: leaveGroup error: $e\n$stackTrace',
        level: LogLevel.error,
      );
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'leaveGroup failed: ${e.toString()}',
        operation: 'leaveGroup',
        details: {'error': e.toString()},
      );
    }
  }
}
