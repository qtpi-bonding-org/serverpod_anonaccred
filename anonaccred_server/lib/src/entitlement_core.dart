import 'package:serverpod/serverpod.dart';
import 'package:anonaccount_server/anonaccount_server.dart';

import 'exception_factory.dart';
import 'generated/protocol.dart';
import 'protocol_failures.dart';

/// Shared internals for account-scoped and group-scoped entitlement
/// managers. Holds the things that are identical across both scopes:
/// tag → Entitlement lookup, amount validation, common exception
/// constructors. Each scope-specific manager owns its own DB
/// interaction (which balance table, which log table, how rows are
/// keyed) but reuses these utilities.
class EntitlementCore {
  /// Throws InventoryException if [amount] is non-positive.
  static void requirePositiveAmount(
    double amount, {
    String? tag,
    String operation = 'entitlement operation',
  }) {
    if (amount <= 0) {
      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccredErrorCodes.inventoryInvalidQuantity,
        message: '$operation amount must be positive',
        tag: tag,
        details: {'providedAmount': amount.toString()},
      );
    }
  }

  /// Look up an [Entitlement] by tag, throwing if it doesn't exist.
  ///
  /// Pass a [transaction] to keep the lookup in the caller's transaction.
  static Future<Entitlement> requireByTag(
    Session session,
    String tag, {
    Transaction? transaction,
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
    return entitlement;
  }

  /// Standardized insufficient-balance exception.
  static InventoryException insufficientBalance({
    required double currentBalance,
    required double requested,
    required String tag,
  }) {
    return AnonAccredExceptionFactory.createInventoryException(
      code: AnonAccredErrorCodes.inventoryInsufficientBalance,
      message: 'Insufficient balance for entitlement "$tag"',
      tag: tag,
      details: {
        'currentBalance': currentBalance.toString(),
        'requested': requested.toString(),
      },
    );
  }

  static Future<void> grantByKey<TEntry>(
    Session session, {
    required double quantity,
    required String operation,
    required Future<TEntry?> Function() findExisting,
    required Future<void> Function(TEntry existing) updateBalance,
    required Future<void> Function() insertNew,
  }) async {
    requirePositiveAmount(quantity, operation: operation);
    final existing = await findExisting();
    if (existing != null) {
      await updateBalance(existing);
    } else {
      await insertNew();
    }
  }

  static Future<void> consumeByKey<TEntry>(
    Session session, {
    required String tag,
    required double amount,
    required String operationName,
    required Future<TEntry?> Function(Entitlement entitlement, Transaction tx)
    findRecord,
    required double Function(TEntry record) balanceOf,
    required Future<void> Function(TEntry record, Transaction tx) applyDebit,
    required Future<void> Function(Entitlement entitlement, Transaction tx)
    insertLog,
  }) async {
    requirePositiveAmount(amount, tag: tag, operation: operationName);
    return tryOperation(
      session,
      operationName,
      () async {
        await session.db.transaction((tx) async {
          final entitlement = await requireByTag(session, tag, transaction: tx);
          final record = await findRecord(entitlement, tx);
          final balance = record == null ? 0.0 : balanceOf(record);
          if (record == null || balance < amount) {
            throw insufficientBalance(
              currentBalance: balance,
              requested: amount,
              tag: tag,
            );
          }
          await applyDebit(record, tx);
          await insertLog(entitlement, tx);
        });
      },
      onFailure: inventoryFailureWithTag(tag),
      code: AnonAccountErrorCodes.databaseError,
    );
  }

  static Future<void> revokeByKey<TEntry>(
    Session session, {
    required double quantity,
    required String operationName,
    required Map<String, String> extraDetails,
    required Future<TEntry?> Function(Transaction tx) findRecord,
    required double Function(TEntry record) balanceOf,
    required Future<void> Function(TEntry record, double debit, Transaction tx)
    applyDebit,
    required Future<void> Function(double debit, Transaction tx) insertLog,
  }) async {
    if (quantity <= 0) return;
    return tryOperation(
      session,
      operationName,
      () async {
        await session.db.transaction((tx) async {
          final record = await findRecord(tx);
          if (record == null) return;
          final balance = balanceOf(record);
          final debit = quantity > balance ? balance : quantity;
          if (debit <= 0) return;
          await applyDebit(record, debit, tx);
          await insertLog(debit, tx);
        });
      },
      onFailure: inventoryFailure,
      code: AnonAccountErrorCodes.databaseError,
      extraDetails: extraDetails,
    );
  }

  static Future<double> getBalanceByKey<TEntry>(
    Session session, {
    required String tag,
    required Future<TEntry?> Function(Entitlement entitlement) findRecord,
    required double Function(TEntry record) balanceOf,
  }) {
    return tryOperation(
      session,
      'getBalance',
      () async {
        final entitlement = await Entitlement.db.findFirstRow(
          session,
          where: (t) => t.tag.equals(tag),
        );
        if (entitlement == null) return 0.0;
        final record = await findRecord(entitlement);
        return record == null ? 0.0 : balanceOf(record);
      },
      onFailure: inventoryFailureWithTag(tag),
      code: AnonAccountErrorCodes.databaseError,
    );
  }
}
