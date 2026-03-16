import 'package:serverpod/serverpod.dart';
import 'package:anonaccount_server/anonaccount_server.dart';
import 'exception_factory.dart';
import 'generated/protocol.dart';
import 'payments/payment_manager.dart';
import 'post_fulfillment_context.dart';
import 'price_registry.dart';

/// Called after fulfillTransactionPayment() has granted all entitlements.
typedef PostFulfillmentHook = Future<void> Function(
  Session session,
  PostFulfillmentContext context,
);

/// Service for managing commerce operations (payments, fulfillment, and accreditation)
///
/// Implements the "Destructible Bridge" pattern:
/// 1. TransactionPayment is identity-free (linked to railProductId, no accountUuid).
/// 2. EphemeralAccreditation links the account to a timestamp for 7 days.
/// 3. After 7 days, the bridge record is deleted, leaving the financials anonymous.
class CommerceManager {
  static PostFulfillmentHook? _postFulfillmentHook;

  /// Register a hook called after every successful fulfillment.
  static void onPostFulfillment(PostFulfillmentHook hook) {
    _postFulfillmentHook = hook;
  }

  /// Reset hook (for testing).
  static void resetPostFulfillmentHook() {
    _postFulfillmentHook = null;
  }

  /// Initiates a transaction payment using the 7-day identity bridge.
  ///
  /// Parameters:
  /// - [session]: Serverpod session
  /// - [accountUuid]: The initiating account UUID (stored in EphemeralAccreditation)
  /// - [rail]: The payment rail being used
  /// - [storeProductId]: The SKU from the vendor (e.g., 'com.app.pro_monthly')
  /// - [clientReference]: Optional client-side UUID or order number
  static Future<TransactionPayment> initiateTransactionPayment(
    Session session, {
    required UuidValue accountUuid,
    required PaymentRail rail,
    required String storeProductId,
    String? clientReference,
    double? customPrice, // Optional for manual rails
  }) async => session.db.transaction((transaction) async {
    // 1. Find the RailProduct (must exist and be active)
    final railProduct = await RailProduct.db.findFirstRow(
      session,
      where: (t) =>
          t.rail.equals(rail) &
          t.storeProductId.equals(storeProductId) &
          t.isActive.equals(true),
      transaction: transaction,
    );

    if (railProduct == null) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.orderInvalidProduct,
        message:
            'Active RailProduct not found for SKU: $storeProductId on $rail',
      );
    }

    // 2. Get price from PriceRegistry if customPrice not provided
    final price = customPrice ?? PriceRegistry().getPrice(storeProductId) ?? 0.0;

    // 3. Prepare internalTransactionId and Timestamp
    final internalTxId = const Uuid().v4();
    final now = DateTime.now();

    // 4. Create EphemeralAccreditation (The identity link bridge)
    await EphemeralAccreditation.db.insertRow(
      session,
      EphemeralAccreditation(accountUuid: accountUuid, transactionTimestamp: now),
      transaction: transaction,
    );

    // 5. Create the real payment via rail (Requirement 2.2)
    final paymentRequest = await PaymentManager.createPayment(
      session: session,
      railType: rail,
      amountUSD: price,
      internalTransactionId: internalTxId,
    );

    // 6. Create TransactionPayment (The identity-free record)
    // Note: This model is intentionally identity-free. It links back via timestamp.
    final result = await TransactionPayment.db.insertRow(
      session,
      TransactionPayment(
        railProductId: railProduct.id!,
        internalTransactionId: internalTxId,
        priceCurrency: Currency.USD,
        price: price,
        paymentRail: rail,
        paymentCurrency: Currency.USD,
        paymentAmount: price,
        paymentRef: paymentRequest.paymentRef,
        transactionTimestamp: now,
        clientReference: clientReference,
        status: OrderStatus.pending,
        railDataJson: paymentRequest.railDataJson,
      ),
      transaction: transaction,
    );

    return result;
  });

  /// Fulfills a transaction payment by adding entitlements to the account.
  ///
  /// This must locate the account via the identity bridge record.
  static Future<void> fulfillTransactionPayment(
    Session session, {
    required String internalTransactionId,
  }) async {
    await session.db.transaction((transaction) async {
      // 1. Find the transaction
      final payment = await TransactionPayment.db.findFirstRow(
        session,
        where: (t) => t.internalTransactionId.equals(internalTransactionId),
        transaction: transaction,
      );

      if (payment == null) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.paymentNotFound,
          message: 'TransactionPayment not found: $internalTransactionId',
        );
      }

      // Check if already fulfilled
      if (payment.status == OrderStatus.paid) {
        session.log(
          'Transaction $internalTransactionId already fulfilled.',
          level: LogLevel.info,
        );
        return;
      }

      // 2. Locate the Account via the Bridge (Exact timestamp match)
      final bridge = await EphemeralAccreditation.db.findFirstRow(
        session,
        where: (t) =>
            t.transactionTimestamp.equals(payment.transactionTimestamp),
        transaction: transaction,
      );

      if (bridge == null) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.paymentVerificationFailed,
          message:
              'Accreditation bridge not found for timestamp ${payment.transactionTimestamp}. Link broken/expired.',
        );
      }

      // 3. Update Transaction Status
      await TransactionPayment.db.updateRow(
        session,
        payment.copyWith(status: OrderStatus.paid),
        transaction: transaction,
      );

      // 4. Grant Entitlements from the Product SKU
      final grants = await RailProductGrant.db.find(
        session,
        where: (t) => t.railProductId.equals(payment.railProductId),
        transaction: transaction,
      );

      for (final grant in grants) {
        // Find or create account entitlement
        final existingRecord = await AccountEntitlement.db.findFirstRow(
          session,
          where: (t) =>
              t.accountUuid.equals(bridge.accountUuid) &
              t.entitlementId.equals(grant.entitlementId),
          transaction: transaction,
        );

        if (existingRecord != null) {
          await AccountEntitlement.db.updateRow(
            session,
            existingRecord.copyWith(
              balance: existingRecord.balance + grant.quantity,
            ),
            transaction: transaction,
          );
        } else {
          await AccountEntitlement.db.insertRow(
            session,
            AccountEntitlement(
              accountUuid: bridge.accountUuid,
              entitlementId: grant.entitlementId,
              balance: grant.quantity,
            ),
            transaction: transaction,
          );
        }

        // Optional: Add record to consumption log or a generic "GrantLog" if needed
        // The schema has consumption_log which tracks usage, but maybe we want a "GrantLog" as well?
        // For now, only the balance is updated.
      }

      // 5. Call post-fulfillment hook if registered
      if (_postFulfillmentHook != null) {
        final railProduct = await RailProduct.db.findById(
          session,
          payment.railProductId,
          transaction: transaction,
        );
        await _postFulfillmentHook!(
          session,
          PostFulfillmentContext(
            accountUuid: bridge.accountUuid,
            grantsApplied: grants,
            payment: payment,
            storeProductId: railProduct?.storeProductId ?? '',
          ),
        );
      }
    });
  }

  /// Manually links an account to a transaction via timestamp (for reactive rails like IAPs).
  static Future<void> accreditTransaction(
    Session session, {
    required UuidValue accountUuid,
    required DateTime transactionTimestamp,
  }) async {
    try {
      await EphemeralAccreditation.db.insertRow(
        session,
        EphemeralAccreditation(
          accountUuid: accountUuid,
          transactionTimestamp: transactionTimestamp,
        ),
      );
    } catch (e) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'Failed to create accreditation bridge: ${e.toString()}',
      );
    }
  }
}
