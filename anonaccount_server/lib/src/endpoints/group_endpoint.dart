import 'package:serverpod/serverpod.dart';
import 'package:anonaccount_protocol/anonaccount_protocol.dart' hide Protocol;
import '../protocol_failures.dart';
import '../try_operation.dart';
import '../crypto_utils.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../helpers.dart';
import '../queries/active_rows.dart';
import 'signed_pow_endpoint.dart';

/// Three-tier auth model for group operations:
///
/// 1. **Transport (outer envelope):** every call carries a PoW + ECDSA
///    signature from the caller's device key. Same shape as every other
///    `SignedPowEndpoint`. Proves the request is live and signed by whoever
///    holds that key — not that the device is still active. The methods that
///    use [guard] additionally check revocation; the remaining legacy methods
///    still resolve callers through the revocation-blind account helper.
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
    required PublicKeyDuo groupUltimateKeys,
    required String groupEncryptedDataKey,
    required PublicKeyDuo creatorMemberKeys,
    required String creatorMemberEncryptedDataKey,
    required String groupUltimateAttestation,
    required String creatorEncryptedMemberKey,
    required String creatorEncryptedMemberKeyAttestation,
    required String creatorEncryptedUltimateKey,
    required String creatorEncryptedUltimateKeyAttestation,
  }) async {
    return tryOperation(
      session,
      'createGroup',
      () async {
        final activeCaller = await guard(
          session,
          challenge: challenge,
          proofOfWork: proofOfWork,
          signature: signature,
          callerDeviceSigningPublicKeyHex: callerDeviceSigningPublicKeyHex,
          methodName: GroupMethods.createGroup,
        );
        final accountId = activeCaller.accountId;

        final groupKeys = AnonAccountHelpers.validateKeyDuo(
          groupUltimateKeys,
          'createGroup',
        );
        final memberKeys = AnonAccountHelpers.validateKeyDuo(
          creatorMemberKeys,
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
          groupKeys,
          memberKeys,
        );
        final innerOk = await CryptoUtils.verifySignature(
          message: innerPayload,
          signature: groupUltimateAttestation,
          publicKey: groupKeys.signingPublicKeyHex,
        );
        if (!innerOk) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.cryptoInvalidSignature,
            message:
                'Invalid group ultimate attestation — privkey did not authorize this createGroup',
            operation: 'createGroup',
          );
        }

        AnonAccountHelpers.validateNonEmpty(
          creatorEncryptedMemberKey,
          'creatorEncryptedMemberKey',
          'createGroup',
        );
        final memberKeyBackupOk = await CryptoUtils.verifySignature(
          message: GroupInnerPayloads.setEncryptedMemberKey(
            groupKeys.signingPublicKeyHex,
            accountId,
            memberKeys.signingPublicKeyHex,
            creatorEncryptedMemberKey,
          ),
          signature: creatorEncryptedMemberKeyAttestation,
          publicKey: memberKeys.signingPublicKeyHex,
        );
        if (!memberKeyBackupOk) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.cryptoInvalidSignature,
            message:
                'Invalid encrypted member key attestation — the creator '
                'member key did not authorize this backup',
            operation: 'createGroup',
          );
        }

        AnonAccountHelpers.validateNonEmpty(
          creatorEncryptedUltimateKey,
          'creatorEncryptedUltimateKey',
          'createGroup',
        );
        await AnonAccountHelpers.requireAttestation(
          message: GroupInnerPayloads.setEncryptedUltimateKey(
            groupKeys.signingPublicKeyHex,
            accountId,
            creatorEncryptedUltimateKey,
          ),
          signature: creatorEncryptedUltimateKeyAttestation,
          publicKey: groupKeys.signingPublicKeyHex,
          operation: 'createGroup',
          failureMessage:
              'Invalid encrypted ultimate key attestation — the '
              'group ultimate key did not authorize this backup',
        );

        final now = DateTime.now();
        return await session.db.transaction((tx) async {
          final group = ShareGroup(
            ultimateSigningPublicKeyHex: groupKeys.signingPublicKeyHex,
            ultimateEncryptionPublicKeyHex: groupKeys.encryptionPublicKeyHex,
            encryptedDataKey: groupEncryptedDataKey,
            createdAt: now,
          );
          final insertedGroup = await ShareGroup.db.insertRow(
            session,
            group,
            transaction: tx,
          );
          final member = GroupMember(
            shareGroupId: insertedGroup.id!,
            anonAccountId: accountId,
            role: GroupMemberRole.admin,
            memberSigningPublicKeyHex: memberKeys.signingPublicKeyHex,
            memberEncryptionPublicKeyHex: memberKeys.encryptionPublicKeyHex,
            encryptedDataKey: creatorMemberEncryptedDataKey,
            encryptedMemberKey: creatorEncryptedMemberKey,
            joinedAt: now,
            isRevoked: false,
            addedByAttestorPublicKeyHex: groupKeys.signingPublicKeyHex,
            addedByAttestation: groupUltimateAttestation,
          );
          await GroupMember.db.insertRow(session, member, transaction: tx);
          final owner = GroupOwner(
            shareGroupId: insertedGroup.id!,
            anonAccountId: accountId,
            encryptedUltimateKey: creatorEncryptedUltimateKey,
            addedByAttestorPublicKeyHex: groupKeys.signingPublicKeyHex,
            addedByAttestation: creatorEncryptedUltimateKeyAttestation,
            createdAt: now,
            isRevoked: false,
          );
          await GroupOwner.db.insertRow(session, owner, transaction: tx);
          return insertedGroup;
        });
      },
      onFailure: authFailure,
      code: AnonAccountErrorCodes.databaseError,
    );
  }

  /// List the caller's non-revoked group memberships, each joined with
  /// the per-device wrapped data key when the calling device has been
  /// granted access to that membership.
  ///
  /// The `deviceEncryptedDataKey` field is `null` for a device that has
  /// not yet been granted access to a given membership — that is the
  /// expected state for a freshly-paired device, not an error. A revoked
  /// device, by contrast, is rejected with `AuthenticationException`
  /// before any data leaves the server: it would otherwise recover
  /// group data keys for every group it was ever granted.
  Future<List<GroupMembershipView>> listMyGroups(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
  }) async {
    return tryOperation(
      session,
      'listMyGroups',
      () async {
        // The caller must be an active device because returned data is
        // wrapped to the caller's own encryption key.
        final activeCaller = await guard(
          session,
          challenge: challenge,
          proofOfWork: proofOfWork,
          signature: signature,
          callerDeviceSigningPublicKeyHex: callerDeviceSigningPublicKeyHex,
          methodName: GroupMethods.listMyGroups,
        );

        final members = await ActiveRows.membershipsForAccount(
          session,
          activeCaller.accountId,
        );

        final grants = await ActiveRows.grantsForDevice(
          session,
          activeCaller.device.id!,
        );
        final grantByMemberId = {for (final g in grants) g.groupMemberId: g};

        final views = <GroupMembershipView>[];
        for (final m in members) {
          final owner = await ActiveRows.owner(
            session,
            m.shareGroupId,
            activeCaller.accountId,
          );
          views.add(
            GroupMembershipView(
              memberId: m.id!,
              shareGroupId: m.shareGroupId,
              role: m.role,
              memberSigningPublicKeyHex: m.memberSigningPublicKeyHex,
              memberEncryptedDataKey: m.encryptedDataKey,
              deviceEncryptedDataKey: grantByMemberId[m.id]?.encryptedDataKey,
              joinedAt: m.joinedAt,
              encryptedMemberKey: m.encryptedMemberKey,
              encryptedUltimateKey: owner?.encryptedUltimateKey,
            ),
          );
        }
        return views;
      },
      onFailure: authFailure,
      code: AnonAccountErrorCodes.databaseError,
    );
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
    required PublicKeyDuo memberKeys,
    required String encryptedDataKey,
    required String encryptedMemberKey,
    required String encryptedMemberKeyAttestation,
    String? callerMemberSigningPublicKeyHex,
    String? memberAuthSignature,
    String? groupUltimateSignature,
  }) async {
    return tryOperation(
      session,
      'addGroupMember',
      () async {
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

        final validatedMemberKeys = AnonAccountHelpers.validateKeyDuo(
          memberKeys,
          'addGroupMember',
        );
        AnonAccountHelpers.validateNonEmpty(
          encryptedDataKey,
          'encryptedDataKey',
          'addGroupMember',
        );
        AnonAccountHelpers.validateNonEmpty(
          encryptedMemberKey,
          'encryptedMemberKey',
          'addGroupMember',
        );

        // Loaded here regardless of role: both the admin-role branch below
        // and the member-key backup check need the group's ultimate signing
        // key, so one lookup serves both instead of issuing two.
        final backupGroup = await ShareGroup.db.findById(session, groupId);
        if (backupGroup == null) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.authAccountNotFound,
            message: 'Group not found',
            operation: 'addGroupMember',
            details: {'groupId': groupId.toString()},
          );
        }

        // Signed by the NEW member's key, not the caller's. The admin only
        // relays this blob and must not be able to alter it, redirect it to
        // another group, or bind it to another account.
        final memberKeyBackupOk = await CryptoUtils.verifySignature(
          message: GroupInnerPayloads.setEncryptedMemberKey(
            backupGroup.ultimateSigningPublicKeyHex,
            newMemberAccountId,
            validatedMemberKeys.signingPublicKeyHex,
            encryptedMemberKey,
          ),
          signature: encryptedMemberKeyAttestation,
          publicKey: validatedMemberKeys.signingPublicKeyHex,
        );
        if (!memberKeyBackupOk) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.cryptoInvalidSignature,
            message:
                'Invalid encrypted member key attestation — the new '
                'member key did not authorize this backup',
            operation: 'addGroupMember',
          );
        }

        final innerPayload = GroupInnerPayloads.addGroupMember(
          groupId,
          newMemberAccountId,
          role.name,
          validatedMemberKeys,
        );

        late final String attestingPubkey;
        late final String attestationSig;

        if (role == GroupMemberRole.admin) {
          // Owner-tier path: ignore member-sig params, require ultimate sig.
          if (groupUltimateSignature == null ||
              groupUltimateSignature.isEmpty) {
            throw AnonAccountExceptionFactory.createAuthenticationException(
              code: AnonAccountErrorCodes.authMissingKey,
              message:
                  'addGroupMember with role=admin requires groupUltimateSignature',
              operation: 'addGroupMember',
            );
          }
          final group = backupGroup;
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
          final activeCaller = await AnonAccountHelpers.requireCaller(
            session,
            callerDeviceSigningPublicKeyHex,
            'addGroupMember',
          );
          final callerMembership =
              await AnonAccountHelpers.requireMemberStanding(
                session,
                activeCaller,
                callerMemberSigningPublicKeyHex,
                groupId,
                'addGroupMember',
              );
          if (callerMembership.role != GroupMemberRole.admin) {
            throw AnonAccountExceptionFactory.createAuthenticationException(
              code: AnonAccountErrorCodes.authInvalidSignature,
              message: 'Caller is not an admin of this group',
              operation: 'addGroupMember',
            );
          }
          attestingPubkey = callerMemberSigningPublicKeyHex;
          attestationSig = memberAuthSignature;
        }

        // Reject duplicate non-revoked memberships.
        final existing = await ActiveRows.memberInGroup(
          session,
          groupId,
          newMemberAccountId,
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
          memberSigningPublicKeyHex: validatedMemberKeys.signingPublicKeyHex,
          memberEncryptionPublicKeyHex:
              validatedMemberKeys.encryptionPublicKeyHex,
          encryptedDataKey: encryptedDataKey,
          encryptedMemberKey: encryptedMemberKey,
          joinedAt: now,
          isRevoked: false,
          addedByAttestorPublicKeyHex: attestingPubkey,
          addedByAttestation: attestationSig,
        );
        final insertedMember = await GroupMember.db.insertRow(session, member);
        // Post the view, not the row: the channel payload only needs enough
        // to identify the membership change, not the wrapped secrets
        // (encryptedMemberKey, encryptedDataKey) that live on the row.
        session.messages.postMessage(
          'group-membership-${insertedMember.memberSigningPublicKeyHex}',
          GroupMemberView(
            memberId: insertedMember.id!,
            shareGroupId: insertedMember.shareGroupId,
            anonAccountId: insertedMember.anonAccountId,
            role: insertedMember.role,
            memberSigningPublicKeyHex: insertedMember.memberSigningPublicKeyHex,
            memberEncryptionPublicKeyHex:
                insertedMember.memberEncryptionPublicKeyHex,
            joinedAt: insertedMember.joinedAt,
          ),
        );
        return insertedMember;
      },
      onFailure: authFailure,
      code: AnonAccountErrorCodes.databaseError,
    );
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
    return tryOperation(
      session,
      'removeGroupMember',
      () async {
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

        final target = await AllRows.groupMemberByIdIncludingRevoked(
          session,
          memberId,
        );
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
          if (groupUltimateSignature == null ||
              groupUltimateSignature.isEmpty) {
            throw AnonAccountExceptionFactory.createAuthenticationException(
              code: AnonAccountErrorCodes.authMissingKey,
              message: 'Removing an admin requires groupUltimateSignature',
              operation: 'removeGroupMember',
            );
          }
          final group = await ShareGroup.db.findById(
            session,
            target.shareGroupId,
          );
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
          final activeCaller = await AnonAccountHelpers.requireCaller(
            session,
            callerDeviceSigningPublicKeyHex,
            'removeGroupMember',
          );
          final callerMembership =
              await AnonAccountHelpers.requireMemberStanding(
                session,
                activeCaller,
                callerMemberSigningPublicKeyHex,
                target.shareGroupId,
                'removeGroupMember',
              );
          if (callerMembership.role != GroupMemberRole.admin) {
            throw AnonAccountExceptionFactory.createAuthenticationException(
              code: AnonAccountErrorCodes.authInvalidSignature,
              message: 'Caller is not an admin of this group',
              operation: 'removeGroupMember',
            );
          }
          attestingPubkey = callerMemberSigningPublicKeyHex;
          attestationSig = memberAuthSignature;
        }

        // Last-admin guard: transactional + row-locked (same reasoning as
        // leaveGroup above) so two concurrent removals/departures of a group's
        // last two admins cannot both pass the check.
        await session.db.transaction((tx) async {
          var shouldDissolve = false;
          if (target.role == GroupMemberRole.admin) {
            final activeMembers =
                await ActiveRows.activeMembersOfGroupForUpdate(
                  session,
                  target.shareGroupId,
                  transaction: tx,
                );
            final activeAdmins = activeMembers
                .where((m) => m.role == GroupMemberRole.admin)
                .toList();
            if (activeAdmins.length == 1 &&
                activeAdmins.first.id == target.id) {
              final otherMembers = activeMembers
                  .where((m) => m.id != target.id)
                  .toList();
              if (otherMembers.isNotEmpty) {
                throw AnonAccountExceptionFactory.createAuthenticationException(
                  code: AnonAccountErrorCodes.groupOperationNotAllowed,
                  message:
                      'Cannot remove the last admin while other members remain. '
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
                revokedByAttestorPublicKeyHex: attestingPubkey,
                revokedByAttestation: attestationSig,
              ),
              transaction: tx,
            );
          }

          if (shouldDissolve) {
            final group = await ShareGroup.db.findById(
              session,
              target.shareGroupId,
              transaction: tx,
            );
            if (group != null) {
              await ShareGroup.db.deleteRow(session, group, transaction: tx);
            }
          }
        });

        return true;
      },
      onFailure: authFailure,
      code: AnonAccountErrorCodes.databaseError,
    );
  }

  Future<GroupMember> changeGroupMemberRole(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required UuidValue memberId,
    required GroupMemberRole newRole,
    String? callerMemberSigningPublicKeyHex,
    String? memberAuthSignature,
    String? groupUltimateSignature,
  }) async {
    return tryOperation(
      session,
      'changeGroupMemberRole',
      () async {
        final outerPayload =
            '$challenge:${GroupMethods.changeGroupMemberRole}:$callerDeviceSigningPublicKeyHex';
        await verifySignedPow(
          session,
          challenge,
          proofOfWork,
          callerDeviceSigningPublicKeyHex,
          signature,
          outerPayload,
        );

        final target = await AllRows.groupMemberByIdIncludingRevoked(
          session,
          memberId,
        );
        if (target == null) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.authDeviceNotFound,
            message: 'Group member not found',
            operation: 'changeGroupMemberRole',
            details: {'memberId': memberId.toString()},
          );
        }
        if (target.isRevoked) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.authAccountRevoked,
            message: 'Cannot change the role of a revoked membership',
            operation: 'changeGroupMemberRole',
            details: {'memberId': memberId.toString()},
          );
        }

        final innerPayload = GroupInnerPayloads.changeGroupMemberRole(
          memberId,
          newRole.name,
        );
        late final String attestingPubkey;
        late final String attestationSig;

        if (newRole == GroupMemberRole.admin &&
            groupUltimateSignature == null) {
          if (callerMemberSigningPublicKeyHex == null ||
              callerMemberSigningPublicKeyHex.isEmpty ||
              memberAuthSignature == null ||
              memberAuthSignature.isEmpty) {
            throw AnonAccountExceptionFactory.createAuthenticationException(
              code: AnonAccountErrorCodes.authMissingKey,
              message:
                  'Promoting to admin requires either groupUltimateSignature or '
                  'callerMemberSigningPublicKeyHex + memberAuthSignature',
              operation: 'changeGroupMemberRole',
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
              operation: 'changeGroupMemberRole',
            );
          }
          final activeCaller = await AnonAccountHelpers.requireCaller(
            session,
            callerDeviceSigningPublicKeyHex,
            'changeGroupMemberRole',
          );
          final callerMembership =
              await AnonAccountHelpers.requireMemberStanding(
                session,
                activeCaller,
                callerMemberSigningPublicKeyHex,
                target.shareGroupId,
                'changeGroupMemberRole',
              );
          if (callerMembership.role != GroupMemberRole.admin) {
            throw AnonAccountExceptionFactory.createAuthenticationException(
              code: AnonAccountErrorCodes.authInvalidSignature,
              message: 'Caller is not an admin of this group',
              operation: 'changeGroupMemberRole',
            );
          }
          attestingPubkey = callerMemberSigningPublicKeyHex;
          attestationSig = memberAuthSignature;
        } else {
          if (groupUltimateSignature == null ||
              groupUltimateSignature.isEmpty) {
            throw AnonAccountExceptionFactory.createAuthenticationException(
              code: AnonAccountErrorCodes.authMissingKey,
              message:
                  '${newRole == GroupMemberRole.admin ? 'Promoting' : 'Demoting'} '
                  'requires groupUltimateSignature',
              operation: 'changeGroupMemberRole',
            );
          }
          final group = await ShareGroup.db.findById(
            session,
            target.shareGroupId,
          );
          if (group == null) {
            throw AnonAccountExceptionFactory.createAuthenticationException(
              code: AnonAccountErrorCodes.authAccountNotFound,
              message: 'Group not found',
              operation: 'changeGroupMemberRole',
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
              message: 'Invalid group ultimate attestation',
              operation: 'changeGroupMemberRole',
            );
          }
          attestingPubkey = group.ultimateSigningPublicKeyHex;
          attestationSig = groupUltimateSignature;
        }

        return await session.db.transaction((tx) async {
          if (target.role == newRole) {
            throw AnonAccountExceptionFactory.createAuthenticationException(
              code: AnonAccountErrorCodes.groupOperationNotAllowed,
              message: 'Member already has the requested role',
              operation: 'changeGroupMemberRole',
              details: {'memberId': memberId.toString()},
            );
          }

          if (newRole == GroupMemberRole.member &&
              target.role == GroupMemberRole.admin) {
            final activeMembers =
                await ActiveRows.activeMembersOfGroupForUpdate(
                  session,
                  target.shareGroupId,
                  transaction: tx,
                );
            final activeAdmins = activeMembers
                .where((m) => m.role == GroupMemberRole.admin)
                .toList();
            if (activeAdmins.length == 1 &&
                activeAdmins.first.id == target.id) {
              throw AnonAccountExceptionFactory.createAuthenticationException(
                code: AnonAccountErrorCodes.groupOperationNotAllowed,
                message:
                    'Cannot demote the last active admin. Promote another '
                    'member to admin first.',
                operation: 'changeGroupMemberRole',
                details: {'groupId': target.shareGroupId.toString()},
              );
            }
          }

          return GroupMember.db.updateRow(
            session,
            target.copyWith(
              role: newRole,
              roleChangedAt: DateTime.now(),
              roleChangedByAttestorPublicKeyHex: attestingPubkey,
              roleChangedByAttestation: attestationSig,
            ),
            transaction: tx,
          );
        });
      },
      onFailure: authFailure,
      code: AnonAccountErrorCodes.databaseError,
    );
  }

  Stream<GroupMemberView> monitorGroupMembership(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required UuidValue groupId,
    required String memberSigningKeyHex,
    required String memberAuthSignature,
  }) async* {
    // Subscribe before doing anything else, including PoW/attestation
    // verification. session.messages is fire-and-forget: a postMessage with
    // no current subscriber on the channel is dropped, not queued.
    // createStream() is a cheap, synchronous, in-memory registration — it
    // exposes no data and costs nothing extra to open early, so there's no
    // tradeoff in doing it before verification instead of after. Any later
    // ordering (verify then subscribe) leaves a real gap: an addGroupMember
    // landing during verification would be lost forever, with the caller
    // waiting on a stream event that already happened.
    final channelName = 'group-membership-$memberSigningKeyHex';
    final stream = session.messages.createStream<GroupMemberView>(channelName);

    // Verify PoW/signature/attestation/standing before returning any data.
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

    final activeCaller = await AnonAccountHelpers.requireCaller(
      session,
      callerDeviceSigningPublicKeyHex,
      'monitorGroupMembership',
    );
    await AnonAccountHelpers.requireAttestation(
      message: GroupInnerPayloads.monitorGroupMembership(groupId),
      signature: memberAuthSignature,
      publicKey: memberSigningKeyHex,
      operation: 'monitorGroupMembership',
      failureMessage: 'Invalid member attestation for monitorGroupMembership',
    );
    await AnonAccountHelpers.requireMemberStanding(
      session,
      activeCaller,
      memberSigningKeyHex,
      groupId,
      'monitorGroupMembership',
    );

    final existingMember = await GroupMember.db.findFirstRow(
      session,
      where: (t) =>
          t.shareGroupId.equals(groupId) &
          t.memberSigningPublicKeyHex.equals(memberSigningKeyHex),
    );
    if (existingMember != null) {
      yield GroupMemberView(
        memberId: existingMember.id!,
        shareGroupId: existingMember.shareGroupId,
        anonAccountId: existingMember.anonAccountId,
        role: existingMember.role,
        memberSigningPublicKeyHex: existingMember.memberSigningPublicKeyHex,
        memberEncryptionPublicKeyHex:
            existingMember.memberEncryptionPublicKeyHex,
        joinedAt: existingMember.joinedAt,
      );
      return;
    }

    // Only one insert ever posts to this channel, so the first event is the
    // only one that will ever arrive — without an explicit stop, this
    // generator keeps its subscription (and DB session) alive forever
    // waiting for a second event that will never come.
    yield await stream.first;
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
    return tryOperation(
      session,
      'getGroup',
      () async {
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

        final activeCaller = await AnonAccountHelpers.requireCaller(
          session,
          callerDeviceSigningPublicKeyHex,
          'getGroup',
        );
        await AnonAccountHelpers.requireMemberStanding(
          session,
          activeCaller,
          callerMemberSigningPublicKeyHex,
          groupId,
          'getGroup',
        );

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
      },
      onFailure: authFailure,
      code: AnonAccountErrorCodes.databaseError,
    );
  }

  Future<List<GroupMemberView>> listGroupMembers(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required UuidValue groupId,
    required String callerMemberSigningPublicKeyHex,
    required String memberAuthSignature,
  }) async {
    return tryOperation(
      session,
      'listGroupMembers',
      () async {
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

        final activeCaller = await AnonAccountHelpers.requireCaller(
          session,
          callerDeviceSigningPublicKeyHex,
          'listGroupMembers',
        );
        await AnonAccountHelpers.requireMemberStanding(
          session,
          activeCaller,
          callerMemberSigningPublicKeyHex,
          groupId,
          'listGroupMembers',
        );

        final rows = await ActiveRows.membersOfGroup(session, groupId);
        return rows
            .map(
              (r) => GroupMemberView(
                memberId: r.id!,
                shareGroupId: r.shareGroupId,
                anonAccountId: r.anonAccountId,
                role: r.role,
                memberSigningPublicKeyHex: r.memberSigningPublicKeyHex,
                memberEncryptionPublicKeyHex: r.memberEncryptionPublicKeyHex,
                joinedAt: r.joinedAt,
              ),
            )
            .toList();
      },
      onFailure: authFailure,
      code: AnonAccountErrorCodes.databaseError,
    );
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
    return tryOperation(
      session,
      'leaveGroup',
      () async {
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

        final target = await AllRows.groupMemberByIdIncludingRevoked(
          session,
          memberId,
        );
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

        final activeCaller = await AnonAccountHelpers.requireCaller(
          session,
          callerDeviceSigningPublicKeyHex,
          'leaveGroup',
        );
        if (target.anonAccountId != activeCaller.accountId) {
          throw AnonAccountExceptionFactory.createAuthenticationException(
            code: AnonAccountErrorCodes.authInvalidSignature,
            message:
                'Caller member key is not bound to the device-resolved account',
            operation: 'leaveGroup',
          );
        }

        // Last-admin guard: transactional + row-locked so two concurrent
        // leaveGroup calls for the group's last two admins cannot both pass
        // the check. session.db.transaction() alone is READ COMMITTED with no
        // row lock — two racing SELECTs would both see "2 admins" and both
        // proceed. Locking the active-member set with LockMode.forUpdate
        // serializes the race: the second caller's SELECT blocks until the
        // first caller's transaction commits, then re-reads the now-reduced
        // admin set (Postgres re-fetches the current row versions once the
        // lock is granted) and takes the correct branch.
        await session.db.transaction((tx) async {
          var shouldDissolve = false;
          if (target.role == GroupMemberRole.admin) {
            final activeMembers =
                await ActiveRows.activeMembersOfGroupForUpdate(
                  session,
                  target.shareGroupId,
                  transaction: tx,
                );
            final activeAdmins = activeMembers
                .where((m) => m.role == GroupMemberRole.admin)
                .toList();
            if (activeAdmins.length == 1 &&
                activeAdmins.first.id == target.id) {
              final otherMembers = activeMembers
                  .where((m) => m.id != target.id)
                  .toList();
              if (otherMembers.isNotEmpty) {
                throw AnonAccountExceptionFactory.createAuthenticationException(
                  code: AnonAccountErrorCodes.groupOperationNotAllowed,
                  message:
                      'Cannot leave as the last admin while other members remain. '
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
              revokedByAttestorPublicKeyHex: memberSigningPublicKeyHex,
              revokedByAttestation: memberAuthSignature,
            ),
            transaction: tx,
          );

          if (shouldDissolve) {
            final group = await ShareGroup.db.findById(
              session,
              target.shareGroupId,
              transaction: tx,
            );
            if (group != null) {
              await ShareGroup.db.deleteRow(session, group, transaction: tx);
            }
          }
        });

        return true;
      },
      onFailure: authFailure,
      code: AnonAccountErrorCodes.databaseError,
    );
  }

  /// Grants one or more devices access to one or more memberships, by
  /// persisting the group data key wrapped to each grantee device.
  ///
  /// Each item in [grants] is independently attested: `memberKey` requires
  /// the membership's own member signing key; `grantedDevice` requires an
  /// already-granted device of the same membership. Validation and the
  /// batch insert share one transaction — unwrapped, a concurrent
  /// `revokeDevice` between the grantee-active check and the insert could
  /// persist a signed record certifying a grant the system should have
  /// refused.
  Future<GrantMemberDeviceResult> grantMemberDevice(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required List<MemberDeviceGrant> grants,
  }) async {
    return tryOperation(
      session,
      'grantMemberDevice',
      () async {
        // The caller must be an active device because this endpoint writes
        // grants whose result is readable by the grantee.
        await guard(
          session,
          challenge: challenge,
          proofOfWork: proofOfWork,
          signature: signature,
          callerDeviceSigningPublicKeyHex: callerDeviceSigningPublicKeyHex,
          methodName: GroupMethods.grantMemberDevice,
        );

        return await session.db.transaction((tx) async {
          // No duplicate pairs within the batch. Postgres resolves
          // intra-command duplicates under DO NOTHING, but which one wins is
          // not something to build on, and it makes the granted/alreadyGranted
          // split ambiguous.
          final seen = <String>{};
          for (final g in grants) {
            if (!seen.add('${g.groupMemberId}:${g.accountDeviceId}')) {
              throw AnonAccountExceptionFactory.createAuthenticationException(
                code: AnonAccountErrorCodes.authDuplicateDevice,
                message: 'Duplicate (groupMemberId, accountDeviceId) in batch',
                operation: 'grantMemberDevice',
              );
            }
          }

          final rows = <GroupMemberDevice>[];
          for (final g in grants) {
            // 1. membership exists and is active.
            final member = await AllRows.groupMemberByIdIncludingRevoked(
              session,
              g.groupMemberId,
              transaction: tx,
            );
            if (member == null || member.isRevoked) {
              throw AnonAccountExceptionFactory.createAuthenticationException(
                code: AnonAccountErrorCodes.authAccountNotFound,
                message: 'Membership not found or revoked',
                operation: 'grantMemberDevice',
                details: {'groupMemberId': g.groupMemberId.toString()},
              );
            }

            // 2. THE binding check: the grantee must be a device of the
            //    account that owns this membership. Without it a member
            //    could push the group data key to an arbitrary device
            //    through a server-persisted, member-attested channel
            //    co-members cannot see.
            final grantee = await AllRows.deviceByIdIncludingRevoked(
              session,
              g.accountDeviceId,
              transaction: tx,
            );
            if (grantee == null ||
                grantee.anonAccountId != member.anonAccountId) {
              throw AnonAccountExceptionFactory.createAuthenticationException(
                code: AnonAccountErrorCodes.authInvalidSignature,
                message:
                    'Grantee device does not belong to the membership account',
                operation: 'grantMemberDevice',
                details: {'accountDeviceId': g.accountDeviceId.toString()},
              );
            }

            // 3. grantee device is active.
            if (grantee.isRevoked) {
              throw AnonAccountExceptionFactory.createAuthenticationException(
                code: AnonAccountErrorCodes.authDeviceRevoked,
                message: 'Grantee device is revoked',
                operation: 'grantMemberDevice',
                details: {'accountDeviceId': g.accountDeviceId.toString()},
              );
            }

            // 4. attestor standing.
            if (g.attestor == GrantAttestor.memberKey) {
              if (g.attestorSigningPublicKeyHex !=
                  member.memberSigningPublicKeyHex) {
                throw AnonAccountExceptionFactory.createAuthenticationException(
                  code: AnonAccountErrorCodes.authInvalidSignature,
                  message:
                      'memberKey-attested grant requires the membership '
                      'member key',
                  operation: 'grantMemberDevice',
                );
              }
            } else {
              final attestorDevice =
                  await AllRows.deviceBySigningKeyIncludingRevoked(
                    session,
                    g.attestorSigningPublicKeyHex,
                    transaction: tx,
                  );
              if (attestorDevice == null || attestorDevice.isRevoked) {
                throw AnonAccountExceptionFactory.createAuthenticationException(
                  code: AnonAccountErrorCodes.authDeviceRevoked,
                  message: 'grantedDevice attestor not found or revoked',
                  operation: 'grantMemberDevice',
                );
              }
              final attestorGrant = await ActiveRows.grantForDevice(
                session,
                g.groupMemberId,
                attestorDevice.id!,
                transaction: tx,
              );
              if (attestorGrant == null) {
                throw AnonAccountExceptionFactory.createAuthenticationException(
                  code: AnonAccountErrorCodes.authAccountNotFound,
                  message:
                      'grantedDevice attestor has no active grant for this '
                      'membership',
                  operation: 'grantMemberDevice',
                );
              }
            }

            // 5. the attestation covers the device duo AND the wrapped key.
            final ok = await CryptoUtils.verifySignature(
              message: GroupInnerPayloads.grantMemberDevice(
                g.groupMemberId,
                PublicKeyDuo(
                  signingPublicKeyHex: grantee.deviceSigningPublicKeyHex,
                  encryptionPublicKeyHex: grantee.deviceEncryptionPublicKeyHex,
                ),
                g.encryptedDataKey,
              ),
              signature: g.attestation,
              publicKey: g.attestorSigningPublicKeyHex,
            );
            if (!ok) {
              throw AnonAccountExceptionFactory.createAuthenticationException(
                code: AnonAccountErrorCodes.cryptoInvalidSignature,
                message: 'Invalid grant attestation',
                operation: 'grantMemberDevice',
              );
            }

            // Scalar FKs only — a populated relation object silently
            // degrades the batch insert to N single-row inserts.
            rows.add(
              GroupMemberDevice(
                groupMemberId: g.groupMemberId,
                accountDeviceId: g.accountDeviceId,
                encryptedDataKey: g.encryptedDataKey,
                addedByAttestorPublicKeyHex: g.attestorSigningPublicKeyHex,
                addedByAttestation: g.attestation,
              ),
            );
          }

          final inserted = await GroupMemberDevice.db.insert(
            session,
            rows,
            transaction: tx,
            ignoreConflicts: true,
          );

          final landed = inserted
              .map((r) => '${r.groupMemberId}:${r.accountDeviceId}')
              .toSet();
          return GrantMemberDeviceResult(
            granted: [
              for (final g in grants)
                if (landed.contains('${g.groupMemberId}:${g.accountDeviceId}'))
                  MemberDeviceGrantOutcome(
                    groupMemberId: g.groupMemberId,
                    accountDeviceId: g.accountDeviceId,
                  ),
            ],
            alreadyGranted: [
              for (final g in grants)
                if (!landed.contains('${g.groupMemberId}:${g.accountDeviceId}'))
                  MemberDeviceGrantOutcome(
                    groupMemberId: g.groupMemberId,
                    accountDeviceId: g.accountDeviceId,
                  ),
            ],
          );
        });
      },
      onFailure: authFailure,
      code: AnonAccountErrorCodes.databaseError,
    );
  }
}
