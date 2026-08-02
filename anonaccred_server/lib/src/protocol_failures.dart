import 'generated/protocol.dart';

/// Neither exception has an `operation` field, so it is carried in `details`
/// rather than dropped.
///
/// `internalTransactionId`, `paymentRail`, and `tag` are deliberately absent:
/// adding them to [ProtocolFailure] would put payment-specific parameters in
/// anonaccount's typedef. The few sites that set them pass a closure.
PaymentException paymentFailure({
  required String code,
  required String message,
  required String operation,
  required Map<String, String> details,
}) =>
    PaymentException(
      code: code,
      message: message,
      details: {'operation': operation, ...details},
    );

InventoryException inventoryFailure({
  required String code,
  required String message,
  required String operation,
  required Map<String, String> details,
}) =>
    InventoryException(
      code: code,
      message: message,
      details: {'operation': operation, ...details},
    );