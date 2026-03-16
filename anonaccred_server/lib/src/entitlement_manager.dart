import 'package:serverpod/serverpod.dart';
import 'package:anonaccount_server/anonaccount_server.dart';
import 'exception_factory.dart';
import 'generated/protocol.dart';

/// High-level service for managing account entitlements (balances and consumption)
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
    if (quantity <= 0) {
      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccredErrorCodes.inventoryInvalidQuantity,
        message: 'Grant quantity must be positive',
        details: {
          'providedQuantity': quantity.toString(),
          'entitlementId': entitlementId.toString(),
        },
      );
    }

    final existingRecord = await AccountEntitlement.db.findFirstRow(
      session,
      where: (t) =>
          t.anonAccountId.equals(accountUuid) &
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
          anonAccountId: accountUuid,
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
    final entitlement = await Entitlement.db.findFirstRow(
      session,
      where: (t) => t.tag.equals(tag),
      transaction: transaction,
    );

    if (entitlement == null) {
      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccredErrorCodes.inventoryInvalidConsumable,
        message: 'Entitlement with tag "$tag" not found',
        tag: tag,
      );
    }

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
    if (amount <= 0) {
      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccredErrorCodes.inventoryInvalidQuantity,
        message: 'Consumption amount must be positive',
        tag: tag,
      );
    }

    try {
      await session.db.transaction((transaction) async {
        // 1. Get the entitlement ID from the tag
        final entitlement = await Entitlement.db.findFirstRow(
          session,
          where: (t) => t.tag.equals(tag),
          transaction: transaction,
        );

        if (entitlement == null) {
          throw AnonAccredExceptionFactory.createInventoryException(
            code: AnonAccredErrorCodes.inventoryInvalidConsumable,
            message: 'Entitlement with tag "$tag" not found',
          );
        }

        // 2. Find AccountEntitlement
        final record = await AccountEntitlement.db.findFirstRow(
          session,
          where: (t) =>
              t.anonAccountId.equals(accountUuid) &
              t.entitlementId.equals(entitlement.id),
          transaction: transaction,
        );

        if (record == null || record.balance < amount) {
          throw AnonAccredExceptionFactory.createInventoryException(
            code: AnonAccredErrorCodes.inventoryInsufficientBalance,
            message: 'Insufficient balance for entitlement "$tag"',
            tag: tag,
            details: {
              'currentBalance': (record?.balance ?? 0.0).toString(),
              'requested': amount.toString(),
            },
          );
        }

        // 3. Update balance
        await AccountEntitlement.db.updateRow(
          session,
          record.copyWith(balance: record.balance - amount),
          transaction: transaction,
        );

        // 4. Log consumption
        await ConsumptionLog.db.insertRow(
          session,
          ConsumptionLog(
            anonAccountId: accountUuid,
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
              t.anonAccountId.equals(accountUuid) &
              t.entitlementId.equals(entitlementId),
          transaction: transaction,
        );

        if (record == null) return; // Nothing to revoke

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
            anonAccountId: accountUuid,
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
            t.anonAccountId.equals(accountUuid) &
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
        where: (t) => t.anonAccountId.equals(accountUuid),
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
