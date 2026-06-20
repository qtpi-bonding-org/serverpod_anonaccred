import 'package:serverpod/serverpod.dart';
import 'package:anonaccount_server/anonaccount_server.dart';
import 'entitlement_core.dart';
import 'exception_factory.dart';
import 'generated/protocol.dart';

/// High-level service for managing group-scoped entitlements.
///
/// Mirrors [EntitlementManager]'s public surface against the
/// `group_entitlement` and `group_consumption_log` tables, keyed on
/// `shareGroupUuid` instead of `accountUuid`. Consumption events
/// optionally attribute themselves to a specific member via
/// `consumingAccountUuid` (for UI attribution only — billing
/// correctness doesn't depend on it).
///
/// Tag namespace convention (spec §7.1): group-scoped entitlements use
/// the `group_*` tag prefix. This is not enforced here — callers are
/// responsible for keeping account and group entitlement tags
/// separate. Use the same `entitlement` registry table for both.
class GroupEntitlementManager {
  /// Grants entitlement to a group by entitlement ID.
  ///
  /// Caller must provide a [transaction].
  static Future<void> grantGroupEntitlementById(
    Session session, {
    required UuidValue shareGroupUuid,
    required int entitlementId,
    required double quantity,
    required Transaction transaction,
  }) async {
    EntitlementCore.requirePositiveAmount(
      quantity,
      operation: 'Group grant',
    );

    final existing = await GroupEntitlement.db.findFirstRow(
      session,
      where: (t) =>
          t.shareGroupUuid.equals(shareGroupUuid) &
          t.entitlementId.equals(entitlementId),
      transaction: transaction,
    );

    if (existing != null) {
      await GroupEntitlement.db.updateRow(
        session,
        existing.copyWith(balance: existing.balance + quantity),
        transaction: transaction,
      );
    } else {
      await GroupEntitlement.db.insertRow(
        session,
        GroupEntitlement(
          shareGroupUuid: shareGroupUuid,
          entitlementId: entitlementId,
          balance: quantity,
        ),
        transaction: transaction,
      );
    }
  }

  /// Grants entitlement to a group by tag.
  ///
  /// Caller must provide a [transaction].
  static Future<void> grantGroupEntitlement(
    Session session, {
    required UuidValue shareGroupUuid,
    required String tag,
    required double quantity,
    required Transaction transaction,
  }) async {
    final entitlement = await EntitlementCore.requireByTag(
      session,
      tag,
      transaction: transaction,
    );
    await grantGroupEntitlementById(
      session,
      shareGroupUuid: shareGroupUuid,
      entitlementId: entitlement.id!,
      quantity: quantity,
      transaction: transaction,
    );
  }

  /// Consumes a group entitlement.
  ///
  /// Deducts from balance and writes a `group_consumption_log` row.
  /// [consumingAccountUuid] optionally attributes the event to the
  /// member who triggered it (used by client UI; billing-irrelevant).
  static Future<void> consumeGroupEntitlement(
    Session session, {
    required UuidValue shareGroupUuid,
    required String tag,
    required double amount,
    required String reason,
    UuidValue? consumingAccountUuid,
  }) async {
    EntitlementCore.requirePositiveAmount(
      amount,
      tag: tag,
      operation: 'Group consumption',
    );

    try {
      await session.db.transaction((transaction) async {
        final entitlement = await EntitlementCore.requireByTag(
          session,
          tag,
          transaction: transaction,
        );

        // FOR UPDATE lock prevents concurrent consumptions from racing on the
        // same balance row under Postgres READ COMMITTED isolation.
        final record = await GroupEntitlement.db.findFirstRow(
          session,
          where: (t) =>
              t.shareGroupUuid.equals(shareGroupUuid) &
              t.entitlementId.equals(entitlement.id),
          lockMode: LockMode.forUpdate,
          transaction: transaction,
        );

        if (record == null || record.balance < amount) {
          throw EntitlementCore.insufficientBalance(
            currentBalance: record?.balance ?? 0.0,
            requested: amount,
            tag: tag,
          );
        }

        await GroupEntitlement.db.updateRow(
          session,
          record.copyWith(balance: record.balance - amount),
          transaction: transaction,
        );

        await GroupConsumptionLog.db.insertRow(
          session,
          GroupConsumptionLog(
            shareGroupUuid: shareGroupUuid,
            entitlementId: entitlement.id!,
            amount: amount,
            reason: reason,
            timestamp: DateTime.now(),
            consumingAccountUuid: consumingAccountUuid,
          ),
          transaction: transaction,
        );
      });
    } catch (e) {
      if (e is InventoryException) rethrow;
      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Failed to consume group entitlement: ${e.toString()}',
        tag: tag,
        details: {'error': e.toString()},
      );
    }
  }

  /// Revokes a group entitlement balance.
  ///
  /// Clamps at zero. Writes a log row. No-op if no balance exists.
  static Future<void> revokeGroupEntitlement(
    Session session, {
    required UuidValue shareGroupUuid,
    required int entitlementId,
    required double quantity,
    required String reason,
    UuidValue? consumingAccountUuid,
  }) async {
    if (quantity <= 0) return;

    try {
      await session.db.transaction((transaction) async {
        // FOR UPDATE lock prevents concurrent revocations from racing on the
        // same balance row under Postgres READ COMMITTED isolation.
        final record = await GroupEntitlement.db.findFirstRow(
          session,
          where: (t) =>
              t.shareGroupUuid.equals(shareGroupUuid) &
              t.entitlementId.equals(entitlementId),
          lockMode: LockMode.forUpdate,
          transaction: transaction,
        );
        if (record == null) return;

        final debit = quantity > record.balance ? record.balance : quantity;
        if (debit <= 0) return;

        await GroupEntitlement.db.updateRow(
          session,
          record.copyWith(balance: record.balance - debit),
          transaction: transaction,
        );

        await GroupConsumptionLog.db.insertRow(
          session,
          GroupConsumptionLog(
            shareGroupUuid: shareGroupUuid,
            entitlementId: entitlementId,
            amount: debit,
            reason: reason,
            timestamp: DateTime.now(),
            consumingAccountUuid: consumingAccountUuid,
          ),
          transaction: transaction,
        );
      });
    } catch (e) {
      if (e is InventoryException) rethrow;
      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Failed to revoke group entitlement: ${e.toString()}',
        details: {
          'error': e.toString(),
          'entitlementId': entitlementId.toString(),
        },
      );
    }
  }

  /// Gets the current balance for a group entitlement by tag.
  static Future<double> getGroupEntitlementBalance(
    Session session, {
    required UuidValue shareGroupUuid,
    required String tag,
  }) async {
    try {
      final entitlement = await Entitlement.db.findFirstRow(
        session,
        where: (t) => t.tag.equals(tag),
      );
      if (entitlement == null) return 0.0;

      final record = await GroupEntitlement.db.findFirstRow(
        session,
        where: (t) =>
            t.shareGroupUuid.equals(shareGroupUuid) &
            t.entitlementId.equals(entitlement.id),
      );

      return record?.balance ?? 0.0;
    } catch (e) {
      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Failed to get group entitlement balance: ${e.toString()}',
        tag: tag,
      );
    }
  }

  /// Gets all entitlement balances for a group.
  static Future<List<GroupEntitlement>> getGroupEntitlements(
    Session session, {
    required UuidValue shareGroupUuid,
  }) async {
    try {
      return await GroupEntitlement.db.find(
        session,
        where: (t) => t.shareGroupUuid.equals(shareGroupUuid),
        include: GroupEntitlement.include(
          entitlement: Entitlement.include(),
        ),
      );
    } catch (e) {
      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Failed to get group entitlements: ${e.toString()}',
      );
    }
  }
}
