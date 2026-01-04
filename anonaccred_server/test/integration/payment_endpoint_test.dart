import 'package:test/test.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Integration tests for PaymentEndpoint
/// 
/// Tests the payment endpoints functionality including payment initiation,
/// status checking, and webhook processing.
void main() {
  withServerpod('PaymentEndpoint Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    // Test constants - valid ECDSA P-256 key format (128 hex chars)
    const validPublicKey = '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
    const validSignature = 'valid_signature_placeholder_64_chars_1234567890abcdef1234567890ab';

    group('Payment Endpoint Tests', () {
      setUp(() async {
        // Clear payment rails before each test
        PaymentManager.clearRails();
      });

      test('checkPaymentStatus - transaction not found', () async {
        // Test checking status for non-existent transaction
        expect(
          () => endpoints.payment.checkPaymentStatus(
            sessionBuilder,
            validPublicKey,
            validSignature,
            'non-existent-order',
          ),
          throwsA(isA<PaymentException>()),
        );
      });

      test('initiatePayment - transaction not found', () async {
        // Test initiating payment for non-existent transaction
        expect(
          () => endpoints.payment.initiatePayment(
            sessionBuilder,
            validPublicKey,
            validSignature,
            'non-existent-order',
            PaymentRail.monero,
          ),
          throwsA(isA<PaymentException>()),
        );
      });

      test('initiatePayment - unsupported payment rail', () async {
        final session = sessionBuilder.build();
        
        // Create a test account first (required for foreign key)
        final testAccount = AnonAccount(
          publicMasterKey: 'test_public_key_${DateTime.now().millisecondsSinceEpoch}',
          encryptedDataKey: 'encrypted_data_key_test',
          ultimatePublicKey: 'ultimate_public_key_${DateTime.now().millisecondsSinceEpoch}',
        );
        final insertedAccount = await AnonAccount.db.insertRow(session, testAccount);

        // Create a test transaction
        final transaction = TransactionPayment(
          externalId: 'test-order-123',
          accountId: insertedAccount.id!,
          priceCurrency: Currency.USD,
          price: 10.0,
          paymentRail: PaymentRail.monero,
          paymentCurrency: Currency.USD,
          paymentAmount: 10.0,
          status: OrderStatus.pending,
        );

        await TransactionPayment.db.insertRow(session, transaction);

        // Test initiating payment with unsupported rail (no rails registered)
        expect(
          () => endpoints.payment.initiatePayment(
            sessionBuilder,
            validPublicKey,
            validSignature,
            'test-order-123',
            PaymentRail.monero,
          ),
          throwsA(isA<PaymentException>()),
        );
      });

      test('authentication validation - empty public key', () async {
        expect(
          () => endpoints.payment.checkPaymentStatus(
            sessionBuilder,
            '', // Empty public key
            validSignature,
            'test-order',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('authentication validation - empty signature', () async {
        expect(
          () => endpoints.payment.checkPaymentStatus(
            sessionBuilder,
            validPublicKey,
            '', // Empty signature
            'test-order',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('authentication validation - invalid public key format', () async {
        expect(
          () => endpoints.payment.checkPaymentStatus(
            sessionBuilder,
            'invalid_key', // Invalid format
            validSignature,
            'test-order',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });
    });
  });
}