import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:test/test.dart';

void main() {
  test('paymentFailure carries operation and preserves extra details', () {
    final e = paymentFailure(
      code: 'PAYMENT_FAILED',
      message: 'createPayment failed: StateError',
      operation: 'createPayment',
      details: {'railType': 'polar'},
    );

    expect(e.code, 'PAYMENT_FAILED');
    expect(e.details!['railType'], 'polar');
    expect(e.details!['operation'], 'createPayment');
  });

  test('inventoryFailure matches the same shape', () {
    final e = inventoryFailure(
      code: 'INVENTORY_INVALID_QUANTITY',
      message: 'consume failed: StateError',
      operation: 'consume',
      details: const {},
    );

    expect(e.details!['operation'], 'consume');
  });

  test('both adapters satisfy ProtocolFailure', () {
    // A signature mismatch is a compile error, not a runtime one; naming the
    // types here is what makes that check happen.
    const ProtocolFailure<PaymentException> p = paymentFailure;
    const ProtocolFailure<InventoryException> i = inventoryFailure;
    expect(p, isNotNull);
    expect(i, isNotNull);
  });

  test('a per-site closure can still set PaymentException rail fields', () {
    // The generic adapters deliberately do not carry internalTransactionId,
    // paymentRail, or InventoryException.tag. Sites that set them pass a
    // closure instead, which is what keeps the wire shape unchanged.
    const ProtocolFailure<PaymentException> withRail = _railFailure;
    final e = withRail(
      code: 'PAYMENT_FAILED',
      message: 'm',
      operation: 'createPayment',
      details: const {},
    );

    expect(e.internalTransactionId, 'tx-1');
    expect(e.paymentRail, 'polar');
  });
}

PaymentException _railFailure({
  required String code,
  required String message,
  required String operation,
  required Map<String, String> details,
}) =>
    PaymentException(
      code: code,
      message: message,
      internalTransactionId: 'tx-1',
      paymentRail: 'polar',
      details: {'operation': operation, ...details},
    );