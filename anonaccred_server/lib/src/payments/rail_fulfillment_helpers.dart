import 'package:serverpod/serverpod.dart';
import 'package:uuid/uuid.dart';

import '../exception_factory.dart';
import '../generated/protocol.dart';

Future<ReceiptHash?> findExistingReceipt(Session session, String hash) {
  return ReceiptHash.db.findFirstRow(
    session,
    where: (t) => t.hash.equals(hash),
  );
}

Future<RailProduct> requireActiveRailProduct(
  Session session,
  PaymentRail rail,
  String storeProductId,
) async {
  final railProduct = await RailProduct.db.findFirstRow(
    session,
    where: (t) =>
        t.rail.equals(rail) &
        t.storeProductId.equals(storeProductId) &
        t.isActive.equals(true),
  );
  if (railProduct == null) {
    throw AnonAccredExceptionFactory.createPaymentException(
      code: AnonAccredErrorCodes.configurationMissing,
      message: 'No active RailProduct found for ${rail.name}:$storeProductId',
      details: {'storeProductId': storeProductId},
    );
  }
  return railProduct;
}

({String? tag, double? quantity}) firstGrantMetadata(
  List<RailProductGrant> grants,
  Entitlement? firstGrantEntitlement,
) {
  if (grants.isEmpty) return (tag: null, quantity: null);
  return (tag: firstGrantEntitlement?.tag, quantity: grants.first.quantity);
}

Future<List<RailProductGrant>> executeAtomicFulfillment(
  Session session, {
  required String receiptHash,
  required PaymentRail rail,
  required RailProduct railProduct,
  String? internalTransactionId,
  required DateTime purchaseDate,
  String? paymentRef,
  required Future<void> Function(Transaction tx) insertBridge,
  required Future<void> Function(RailProductGrant grant, Transaction tx)
  creditGrant,
}) async {
  late List<RailProductGrant> grants;
  await session.db.transaction((tx) async {
    await ReceiptHash.db.insertRow(
      session,
      ReceiptHash(hash: receiptHash, paymentRail: rail),
      transaction: tx,
    );
    await insertBridge(tx);
    final internalTxId = internalTransactionId ?? const Uuid().v4();
    await TransactionPayment.db.insertRow(
      session,
      TransactionPayment(
        railProductId: railProduct.id!,
        internalTransactionId: internalTxId,
        priceCurrency: Currency.USD,
        price: 0.0,
        paymentRail: rail,
        paymentCurrency: Currency.USD,
        paymentAmount: 0.0,
        paymentRef: paymentRef,
        transactionTimestamp: purchaseDate,
        clientReference: internalTxId,
        status: OrderStatus.paid,
      ),
      transaction: tx,
    );
    grants = await RailProductGrant.db.find(
      session,
      where: (t) => t.railProductId.equals(railProduct.id!),
      transaction: tx,
    );
    for (final grant in grants) {
      await creditGrant(grant, tx);
    }
  });
  return grants;
}

Future<List<RailProductGrant>> findGrantsForRailProduct(
  Session session,
  int railProductId, {
  Transaction? transaction,
}) {
  return RailProductGrant.db.find(
    session,
    where: (t) => t.railProductId.equals(railProductId),
    transaction: transaction,
  );
}
