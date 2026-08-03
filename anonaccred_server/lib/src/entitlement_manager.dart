import 'package:serverpod/serverpod.dart';
import 'package:anonaccount_server/anonaccount_server.dart';
import 'protocol_failures.dart';
import 'entitlement_core.dart';
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
  }) => EntitlementCore.grantByKey(
    session,
    quantity: quantity,
    operation: 'Grant',
    findExisting: () => AccountEntitlement.db.findFirstRow(
      session,
      where: (t) =>
          t.accountUuid.equals(accountUuid) &
          t.entitlementId.equals(entitlementId),
      lockMode: LockMode.forUpdate,
      transaction: transaction,
    ),
    updateBalance: (existing) => AccountEntitlement.db.updateRow(
      session,
      existing.copyWith(balance: existing.balance + quantity),
      transaction: transaction,
    ),
    insertNew: () => AccountEntitlement.db.insertRow(
      session,
      AccountEntitlement(
        accountUuid: accountUuid,
        entitlementId: entitlementId,
        balance: quantity,
      ),
      transaction: transaction,
    ),
  );

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
    return EntitlementCore.consumeByKey(
      session,
      tag: tag,
      amount: amount,
      operationName: 'consumeEntitlement',
      findRecord: (entitlement, transaction) => AccountEntitlement.db.findFirstRow(
        session,
        where: (t) =>
            t.accountUuid.equals(accountUuid) &
            t.entitlementId.equals(entitlement.id),
        lockMode: LockMode.forUpdate,
        transaction: transaction,
      ),
      balanceOf: (record) => record.balance,
      applyDebit: (record, transaction) => AccountEntitlement.db.updateRow(
        session,
        record.copyWith(balance: record.balance - amount),
        transaction: transaction,
      ),
      insertLog: (entitlement, transaction) => ConsumptionLog.db.insertRow(
        session,
        ConsumptionLog(
          accountUuid: accountUuid,
          entitlementId: entitlement.id!,
          amount: amount,
          reason: reason,
          timestamp: DateTime.now(),
        ),
        transaction: transaction,
      ),
    );
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
    return EntitlementCore.revokeByKey(
      session,
      quantity: quantity,
      operationName: 'revokeEntitlement',
      extraDetails: {'entitlementId': entitlementId.toString()},
      findRecord: (transaction) => AccountEntitlement.db.findFirstRow(
        session,
        where: (t) =>
            t.accountUuid.equals(accountUuid) &
            t.entitlementId.equals(entitlementId),
        lockMode: LockMode.forUpdate,
        transaction: transaction,
      ),
      balanceOf: (record) => record.balance,
      applyDebit: (record, debit, transaction) => AccountEntitlement.db.updateRow(
        session,
        record.copyWith(balance: record.balance - debit),
        transaction: transaction,
      ),
      insertLog: (debit, transaction) => ConsumptionLog.db.insertRow(
        session,
        ConsumptionLog(
          accountUuid: accountUuid,
          entitlementId: entitlementId,
          amount: debit,
          reason: reason,
          timestamp: DateTime.now(),
        ),
        transaction: transaction,
      ),
    );
  }

  /// Gets the current balance for an entitlement by tag.
  static Future<double> getEntitlementBalance(
    Session session, {
    required UuidValue accountUuid,
    required String tag,
  }) {
    return EntitlementCore.getBalanceByKey(
      session,
      tag: tag,
      findRecord: (entitlement) => AccountEntitlement.db.findFirstRow(
        session,
        where: (t) =>
            t.accountUuid.equals(accountUuid) &
            t.entitlementId.equals(entitlement.id),
      ),
      balanceOf: (record) => record.balance,
    );
  }

  /// Gets all entitlement balances for an account.
  static Future<List<AccountEntitlement>> getAccountEntitlements(
    Session session, {
    required UuidValue accountUuid,
  }) async {
    return tryOperation(
      session,
      'getAccountEntitlements',
      () async {
        return await AccountEntitlement.db.find(
          session,
          where: (t) => t.accountUuid.equals(accountUuid),
          include: AccountEntitlement.include(
            entitlement: Entitlement.include(),
          ),
        );
      },
      onFailure: inventoryFailure,
      code: AnonAccountErrorCodes.databaseError,
    );
  }
}
