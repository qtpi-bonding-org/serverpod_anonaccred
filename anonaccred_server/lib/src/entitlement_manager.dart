import 'package:serverpod/serverpod.dart';
import 'package:anonaccount_server/anonaccount_server.dart';
import 'entitlement_core.dart';
import 'exception_factory.dart';
import 'generated/protocol.dart';

/// High-level service for managing account entitlements (balances and consumption).
///
/// Shares validation, tag lookup, and exception construction with
/// [EntitlementCore] — see also [GroupEntitlementManager] for the
/// parallel group-scoped service.
class EntitlementManager {
  /// Grants entitlement to an account by its ID.
  ///
  /// Caller must provide a [transaction] — the grant participates in the
  /// caller's transaction so everything commits or rolls back together.
  static Future<void> grantEntitlementById(
    Session session, {
    required UuidValue accountUuid,
    required int entitlementId,
    required double quantity,
    required Transaction transaction,
  }) async {
    EntitlementCore.requirePositiveAmount(
      quantity,
      operation: 'Grant',
    );

    final existingRecord = await AccountEntitlement.db.findFirstRow(
      session,
      where: (t) =>
          t.accountUuid.equals(accountUuid) &
          t.entitlementId.equals(entitlementId),
      transaction: transaction,
    );

    if (existingRecord != null) {
      await AccountEntitlement.db.updateRow(
        session,
        existingRecord.copyWith(balance: existingRecord.balance + quantity),
        transaction: transaction,
      );
    } else {
      await AccountEntitlement.db.insertRow(
        session,
        AccountEntitlement(
          accountUuid: accountUuid,
          entitlementId: entitlementId,
          balance: quantity,
        ),
        transaction: transaction,
      );
    }
  }

  /// Grants entitlement to an account by its tag.
  ///
  /// Caller must provide a [transaction].
  static Future<void> grantEntitlement(
    Session session, {
    required UuidValue accountUuid,
    required String tag,
    required double quantity,
    required Transaction transaction,
  }) async {
    final entitlement = await EntitlementCore.requireByTag(
      session,
      tag,
      transaction: transaction,
    );
    await grantEntitlementById(
      session,
      accountUuid: accountUuid,
      entitlementId: entitlement.id!,
      quantity: quantity,
      transaction: transaction,
    );
  }

  /// Consumes an entitlement from an account.
  /// Deducts from balance and logs the consumption.
  static Future<void> consumeEntitlement(
    Session session, {
    required UuidValue accountUuid,
    required String tag,
    required double amount,
    required String reason,
  }) async {
    EntitlementCore.requirePositiveAmount(
      amount,
      tag: tag,
      operation: 'Consumption',
    );

    try {
      await session.db.transaction((transaction) async {
        final entitlement = await EntitlementCore.requireByTag(
          session,
          tag,
          transaction: transaction,
        );

        final record = await AccountEntitlement.db.findFirstRow(
          session,
          where: (t) =>
              t.accountUuid.equals(accountUuid) &
              t.entitlementId.equals(entitlement.id),
          transaction: transaction,
        );

        if (record == null || record.balance < amount) {
          throw EntitlementCore.insufficientBalance(
            currentBalance: record?.balance ?? 0.0,
            requested: amount,
            tag: tag,
          );
        }

        await AccountEntitlement.db.updateRow(
          session,
          record.copyWith(balance: record.balance - amount),
          transaction: transaction,
        );

        await ConsumptionLog.db.insertRow(
          session,
          ConsumptionLog(
            accountUuid: accountUuid,
            entitlementId: entitlement.id!,
            amount: amount,
            reason: reason,
            timestamp: DateTime.now(),
          ),
          transaction: transaction,
        );
      });
    } catch (e) {
      if (e is InventoryException) rethrow;
      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Failed to consume entitlement: ${e.toString()}',
        tag: tag,
        details: {'error': e.toString()},
      );
    }
  }

  /// Revokes entitlement from an account by debiting the balance.
  ///
  /// Clamps at zero (never goes negative). Creates a ConsumptionLog entry
  /// with the provided reason. No-op if no AccountEntitlement record exists.
  static Future<void> revokeEntitlement(
    Session session, {
    required UuidValue accountUuid,
    required int entitlementId,
    required double quantity,
    required String reason,
  }) async {
    if (quantity <= 0) return;

    try {
      await session.db.transaction((transaction) async {
        final record = await AccountEntitlement.db.findFirstRow(
          session,
          where: (t) =>
              t.accountUuid.equals(accountUuid) &
              t.entitlementId.equals(entitlementId),
          transaction: transaction,
        );

        if (record == null) return;

        final debit = quantity > record.balance ? record.balance : quantity;
        if (debit <= 0) return;

        await AccountEntitlement.db.updateRow(
          session,
          record.copyWith(balance: record.balance - debit),
          transaction: transaction,
        );

        await ConsumptionLog.db.insertRow(
          session,
          ConsumptionLog(
            accountUuid: accountUuid,
            entitlementId: entitlementId,
            amount: debit,
            reason: reason,
            timestamp: DateTime.now(),
          ),
          transaction: transaction,
        );
      });
    } catch (e) {
      if (e is InventoryException) rethrow;
      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Failed to revoke entitlement: ${e.toString()}',
        details: {
          'error': e.toString(),
          'entitlementId': entitlementId.toString(),
        },
      );
    }
  }

  /// Gets the current balance for an entitlement by tag.
  static Future<double> getEntitlementBalance(
    Session session, {
    required UuidValue accountUuid,
    required String tag,
  }) async {
    try {
      final entitlement = await Entitlement.db.findFirstRow(
        session,
        where: (t) => t.tag.equals(tag),
      );
      if (entitlement == null) return 0.0;

      final record = await AccountEntitlement.db.findFirstRow(
        session,
        where: (t) =>
            t.accountUuid.equals(accountUuid) &
            t.entitlementId.equals(entitlement.id),
      );

      return record?.balance ?? 0.0;
    } catch (e) {
      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Failed to get entitlement balance: ${e.toString()}',
        tag: tag,
      );
    }
  }

  /// Gets all entitlement balances for an account.
  static Future<List<AccountEntitlement>> getAccountEntitlements(
    Session session, {
    required UuidValue accountUuid,
  }) async {
    try {
      return await AccountEntitlement.db.find(
        session,
        where: (t) => t.accountUuid.equals(accountUuid),
        include: AccountEntitlement.include(
          entitlement: Entitlement.include(),
        ),
      );
    } catch (e) {
      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Failed to get account entitlements: ${e.toString()}',
      );
    }
  }
}
