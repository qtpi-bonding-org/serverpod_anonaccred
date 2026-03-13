// Add your modules' endpoints to the `endpoints` directory. Run
// `serverpod generate` to produce the modules server and client code. Refer to
// the documentation on how to add endpoints to your server.

import 'package:serverpod/serverpod.dart';
import '../entitlement_manager.dart';
import 'package:anonaccount_server/anonaccount_server.dart';

import '../exception_factory.dart';
import '../generated/protocol.dart';

class ModuleEndpoint extends Endpoint {
  Future<String> hello(Session session, String name) async => 'Hello $name';

  /// Authenticates a user using ECDSA P-256 signature verification
  /// Throws AuthenticationException on failure
  Future<bool> authenticateUser(
    Session session,
    String publicKey,
    String signature,
    String challenge,
  ) async {
    try {
      // Validate input parameters
      if (publicKey.isEmpty) {
        final exception =
            AnonAccountExceptionFactory.createAuthenticationException(
              code: AnonAccountErrorCodes.authMissingKey,
              message: 'Public key is required for authentication',
              operation: 'authenticateUser',
              details: {'publicKey': 'empty'},
            );

        throw exception;
      }

      if (signature.isEmpty || challenge.isEmpty) {
        final exception =
            AnonAccountExceptionFactory.createAuthenticationException(
              code: AnonAccountErrorCodes.authInvalidSignature,
              message:
                  'Signature and challenge are required for authentication',
              operation: 'authenticateUser',
              details: {
                'signature': signature.isEmpty ? 'empty' : 'provided',
                'challenge': challenge.isEmpty ? 'empty' : 'provided',
              },
            );

        throw exception;
      }

      // Simulate signature verification (in real implementation, this would use crypto library)
      // For now, we'll simulate some failure conditions
      if (signature.length < 64) {
        final exception =
            AnonAccountExceptionFactory.createAuthenticationException(
              code: AnonAccountErrorCodes.authInvalidSignature,
              message: 'Invalid signature format',
              operation: 'authenticateUser',
              details: {
                'signatureLength': signature.length.toString(),
                'expectedMinLength': '64',
              },
            );

        throw exception;
      }

      // Simulate expired challenge check
      if (challenge.startsWith('expired_')) {
        final exception =
            AnonAccountExceptionFactory.createAuthenticationException(
              code: AnonAccountErrorCodes.authExpiredChallenge,
              message: 'Authentication challenge has expired',
              operation: 'authenticateUser',
              details: {'challenge': challenge, 'status': 'expired'},
            );

        throw exception;
      }

      // Successful authentication
      return true;
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      // Log unexpected error

      // Wrap unexpected errors in AuthenticationException
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.internalError,
        message: 'Unexpected error during authentication: ${e.toString()}',
        operation: 'authenticateUser',
        details: {'error': e.toString()},
      );
    }
  }

  /// Processes a payment through specified payment rail
  /// Throws PaymentException on failure
  Future<String> processPayment(
    Session session,
    String internalTransactionId,
    String paymentRail,
    double amount,
  ) async {
    try {
      // Validate input parameters
      if (internalTransactionId.isEmpty) {
        final exception = AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.paymentFailed,
          message: 'Internal transaction ID is required for payment processing',
          internalTransactionId: internalTransactionId,
          paymentRail: paymentRail,
          details: {'internalTransactionId': 'empty'},
        );

        throw exception;
      }

      if (amount <= 0) {
        final exception = AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.paymentInsufficientFunds,
          message: 'Payment amount must be greater than zero',
          internalTransactionId: internalTransactionId,
          paymentRail: paymentRail,
          details: {'amount': amount.toString()},
        );

        throw exception;
      }

      // Validate payment rail
      const validRails = ['x402_http', 'monero', 'apple_iap', 'google_iap'];
      if (!validRails.contains(paymentRail.toLowerCase())) {
        final exception = AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.paymentInvalidRail,
          message: 'Invalid payment rail specified',
          internalTransactionId: internalTransactionId,
          paymentRail: paymentRail,
          details: {
            'providedRail': paymentRail,
            'validRails': validRails.join(', '),
          },
        );

        throw exception;
      }

      // Simulate payment processing failures
      if (internalTransactionId.startsWith('fail_')) {
        final exception = AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.paymentFailed,
          message: 'Payment processing failed',
          internalTransactionId: internalTransactionId,
          paymentRail: paymentRail,
          details: {'reason': 'simulated_failure'},
        );

        throw exception;
      }

      if (amount > 1000) {
        final exception = AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.paymentInsufficientFunds,
          message: 'Payment amount exceeds limit',
          internalTransactionId: internalTransactionId,
          paymentRail: paymentRail,
          details: {'amount': amount.toString(), 'limit': '1000'},
        );

        throw exception;
      }

      // Successful payment processing
      final receipt =
          'payment_receipt_${internalTransactionId}_${DateTime.now().millisecondsSinceEpoch}';

      return receipt;
    } on PaymentException {
      rethrow;
    } catch (e) {
      // Log unexpected error

      // Wrap unexpected errors in PaymentException
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccountErrorCodes.internalError,
        message: 'Unexpected error during payment processing: ${e.toString()}',
        internalTransactionId: internalTransactionId,
        paymentRail: paymentRail,
        details: {'error': e.toString()},
      );
    }
  }

  /// Manages entitlement operations (check balance, grant)
  /// Throws InventoryException on failure
  Future<double> manageEntitlements(
    Session session,
    int accountId,
    String tag,
    String operation, // 'check' or 'grant'
    double? quantity,
  ) async {
    try {
      // Validate input parameters
      if (accountId <= 0) {
        throw AnonAccredExceptionFactory.createInventoryException(
          code: AnonAccredErrorCodes.inventoryAccountNotFound,
          message: 'Invalid account ID provided',
          accountId: accountId,
          tag: tag,
          details: {'accountId': accountId.toString()},
        );
      }

      if (tag.isEmpty) {
        throw AnonAccredExceptionFactory.createInventoryException(
          code: AnonAccredErrorCodes.inventoryInvalidConsumable,
          message: 'Entitlement tag is required',
          accountId: accountId,
          tag: tag,
          details: {'tag': 'empty'},
        );
      }

      // Handle different operations using EntitlementManager
      switch (operation.toLowerCase()) {
        case 'check':
          return await EntitlementManager.getEntitlementBalance(
            session,
            accountId: accountId,
            tag: tag,
          );

        case 'grant':
          if (quantity == null || quantity <= 0) {
            throw AnonAccredExceptionFactory.createInventoryException(
              code: AnonAccredErrorCodes.inventoryInvalidConsumable,
              message: 'Quantity must be greater than zero for grant operation',
              accountId: accountId,
              tag: tag,
              details: {'quantity': quantity?.toString() ?? 'null'},
            );
          }

          return await session.db.transaction((transaction) async {
            await EntitlementManager.grantEntitlement(
              session,
              accountId: accountId,
              tag: tag,
              quantity: quantity,
              transaction: transaction,
            );

            // Return new balance
            return await EntitlementManager.getEntitlementBalance(
              session,
              accountId: accountId,
              tag: tag,
            );
          });

        default:
          throw AnonAccredExceptionFactory.createInventoryException(
            code: AnonAccredErrorCodes.inventoryInvalidConsumable,
            message: 'Invalid operation specified: $operation',
            accountId: accountId,
            tag: tag,
            details: {
              'operation': operation,
              'validOperations': 'check, grant',
            },
          );
      }
    } on InventoryException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createInventoryException(
        code: AnonAccountErrorCodes.internalError,
        message:
            'Unexpected error during entitlement operation: ${e.toString()}',
        accountId: accountId,
        tag: tag,
        details: {'error': e.toString()},
      );
    }
  }
}
