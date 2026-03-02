import 'dart:convert';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:anonaccred_server/src/payments/payment_processor.dart';
import 'package:anonaccred_server/src/payments/payment_rail_interface.dart';
import 'package:anonaccred_server/src/payments/webhook_handler.dart';
import 'package:anonaccred_server/src/price_registry.dart';
import 'package:anonaccred_server/src/refund_event.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Mock payment rail for testing complete payment flows
class MockPaymentRail implements PaymentRailInterface {
  MockPaymentRail({
    this.shouldSucceed = true,
    this.shouldThrowOnCreate = false,
    this.shouldThrowOnCallback = false,
    this.customPaymentRef,
  });
  @override
  PaymentRail get railType => PaymentRail.monero;

  final bool shouldSucceed;
  final bool shouldThrowOnCreate;
  final bool shouldThrowOnCallback;
  final String? customPaymentRef;

  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String internalTransactionId,
  }) async {
    if (shouldThrowOnCreate) {
      throw Exception('Mock payment creation failure');
    }

    return PaymentRequestExtension.withRailData(
      paymentRef: customPaymentRef ?? 'mock_payment_ref_$internalTransactionId',
      amountUSD: amountUSD,
      internalTransactionId: internalTransactionId,
      railData: {
        'mockRail': true,
        'paymentAddress': 'mock_address_123',
        'expirationTime': DateTime.now()
            .add(const Duration(hours: 1))
            .toIso8601String(),
      },
    );
  }

  @override
  Future<PaymentResult> processCallback(
    Map<String, dynamic> callbackData,
  ) async {
    if (shouldThrowOnCallback) {
      throw Exception('Mock callback processing failure');
    }

    final internalTransactionId =
        callbackData['internalTransactionId'] as String?;

    return PaymentResult(
      success: shouldSucceed,
      internalTransactionId: internalTransactionId,
      transactionTimestamp: shouldSucceed ? DateTime.now() : null,
      errorMessage: shouldSucceed ? null : 'Mock payment failed',
    );
  }

  @override
  RefundEvent? extractRefundEvent(Map<String, dynamic> notificationData) => null;
}

/// Integration tests for complete payment flow validation
///
/// Tests the end-to-end payment processing including payment initiation,
/// status checking, webhook processing, database transactions, and error handling.
///
/// Requirements 6.5, 8.5: Complete payment flow and error handling validation
void main() {
  withServerpod('Payment Flow Integration Tests', (sessionBuilder, endpoints) {
    // Test constants - valid ECDSA P-256 key format (128 hex chars)
    const validPublicKey =
        '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
    const validSignature =
        'valid_signature_placeholder_64_chars_1234567890abcdef1234567890ab';

    late AnonAccount testAccount;
    late TransactionPayment testTransaction;

    setUp(() async {
      // Clear payment rails before each test
      PaymentManager.clearRails();

      // Create test account and transaction for each test
      final session = sessionBuilder.build();

      testAccount = AnonAccount(
        ultimateSigningPublicKeyHex:
            'test_public_key_${DateTime.now().millisecondsSinceEpoch}',
        encryptedDataKey: 'encrypted_data_key_test',
        ultimatePublicKey:
            'ultimate_public_key_${DateTime.now().millisecondsSinceEpoch}',
      );
      testAccount = await AnonAccount.db.insertRow(session, testAccount);

      // Create dummy rail product
      final railProduct = await RailProduct.db.insertRow(
        session,
        RailProduct(
          rail: PaymentRail.monero,
          storeProductId: 'test_product',
          isActive: true,
        ),
      );

      testTransaction = TransactionPayment(
        railProductId: railProduct.id!,
        internalTransactionId:
            'test-order-${DateTime.now().millisecondsSinceEpoch}',
        priceCurrency: Currency.USD,
        price: 10.0,
        paymentRail: PaymentRail.monero,
        paymentCurrency: Currency.USD,
        paymentAmount: 10.0,
        transactionTimestamp: DateTime.now(),
        status: OrderStatus.pending,
      );

      testTransaction = await TransactionPayment.db.insertRow(
        session,
        testTransaction,
      );

      // Register test product in price registry for tests that need it
      PriceRegistry().registerProduct('test_product', 10.0);
    });

    group('Complete Payment Flow Tests', () {
      test('successful payment flow with mock rail', () async {
        // Register mock payment rail
        final mockRail = MockPaymentRail();
        PaymentManager.registerRail(mockRail);

        // Step 1: Initiate payment via commerce endpoint
        final paymentRequest = await endpoints.commerce.initiatePayment(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccount.id!,
          PaymentRail.monero,
          'test_product',
        );

        // Verify payment request structure
        expect(paymentRequest.paymentRef, startsWith('mock_payment_ref_'));
        expect(paymentRequest.paymentAmount, equals(10.0));
        expect(paymentRequest.internalTransactionId, isNotEmpty);

        // Verify rail data (decoded from railDataJson)
        final railData =
            jsonDecode(paymentRequest.railDataJson ?? '{}')
                as Map<String, dynamic>;
        expect(railData['mockRail'], isTrue);
        expect(railData['paymentAddress'], equals('mock_address_123'));

        // Step 2: Check payment status (should be pending after initiation)
        var statusResult = await endpoints.payment.checkPaymentStatus(
          sessionBuilder,
          validPublicKey,
          validSignature,
          paymentRequest.internalTransactionId,
        );
        expect(statusResult.status, equals(OrderStatus.pending));

        // Step 3: Process successful webhook directly through WebhookHandler
        final session = sessionBuilder.build();
        try {
          final webhookData = {
            'internalTransactionId': paymentRequest.internalTransactionId,
            'success': true,
          };

          await WebhookHandler.processWebhook(
            session: session,
            railType: PaymentRail.monero,
            webhookData: webhookData,
          );
        } finally {
          await session.close();
        }

        // Step 4: Verify payment status updated to paid
        statusResult = await endpoints.payment.checkPaymentStatus(
          sessionBuilder,
          validPublicKey,
          validSignature,
          paymentRequest.internalTransactionId,
        );
        expect(statusResult.status, equals(OrderStatus.paid));
        expect(statusResult.transactionTimestamp, isNotNull);
      });

      test('failed payment flow with mock rail', () async {
        // Register mock payment rail that fails
        final mockRail = MockPaymentRail(shouldSucceed: false);
        PaymentManager.registerRail(mockRail);

        // Step 1: Initiate payment via commerce endpoint
        final paymentRequest = await endpoints.commerce.initiatePayment(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccount.id!,
          PaymentRail.monero,
          'test_product',
        );

        expect(paymentRequest.paymentRef, startsWith('mock_payment_ref_'));

        // Step 2: Process failed webhook directly through WebhookHandler
        final session = sessionBuilder.build();
        try {
          final webhookData = {
            'internalTransactionId': paymentRequest.internalTransactionId,
            'success': false,
            'error': 'Payment declined',
          };

          await WebhookHandler.processWebhook(
            session: session,
            railType: PaymentRail.monero,
            webhookData: webhookData,
          );
        } finally {
          await session.close();
        }

        // Step 3: Verify payment status updated to failed
        final statusResult = await endpoints.payment.checkPaymentStatus(
          sessionBuilder,
          validPublicKey,
          validSignature,
          paymentRequest.internalTransactionId,
        );
        expect(statusResult.status, equals(OrderStatus.failed));
      });

      test('payment creation error handling', () async {
        // Register mock payment rail that throws on creation
        final mockRail = MockPaymentRail(shouldThrowOnCreate: true);
        PaymentManager.registerRail(mockRail);

        // Attempt to initiate payment - should throw PaymentException
        expect(
          () => endpoints.commerce.initiatePayment(
            sessionBuilder,
            validPublicKey,
            validSignature,
            testAccount.id!,
            PaymentRail.monero,
            'test_product',
          ),
          throwsA(isA<PaymentException>()),
        );
      });

      test('webhook processing error handling', () async {
        // Register mock payment rail that throws on callback
        final mockRail = MockPaymentRail(shouldThrowOnCallback: true);
        PaymentManager.registerRail(mockRail);

        // Process webhook directly - should not throw (errors are logged but not propagated)
        final session = sessionBuilder.build();
        try {
          final webhookData = {
            'internalTransactionId': testTransaction.internalTransactionId,
            'success': true,
          };

          // This should complete without throwing
          await WebhookHandler.processWebhook(
            session: session,
            railType: PaymentRail.monero,
            webhookData: webhookData,
          );
        } finally {
          await session.close();
        }

        // Transaction status should remain unchanged
        final statusResult = await endpoints.payment.checkPaymentStatus(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testTransaction.internalTransactionId,
        );
        expect(statusResult.status, equals(OrderStatus.pending));
      });

      test('unsupported payment rail error', () async {
        // Don't register any payment rails

        // Attempt to initiate payment - should throw PaymentException
        expect(
          () => endpoints.commerce.initiatePayment(
            sessionBuilder,
            validPublicKey,
            validSignature,
            testAccount.id!,
            PaymentRail.monero,
            'test_product',
          ),
          throwsA(isA<PaymentException>()),
        );
      });

      test('webhook idempotency - duplicate processing', () async {
        // Register mock payment rail
        final mockRail = MockPaymentRail();
        PaymentManager.registerRail(mockRail);

        // Process webhook first time directly
        final session = sessionBuilder.build();
        try {
          final webhookData = {
            'internalTransactionId': testTransaction.internalTransactionId,
            'success': true,
          };

          await WebhookHandler.processWebhook(
            session: session,
            railType: PaymentRail.monero,
            webhookData: webhookData,
          );
        } finally {
          await session.close();
        }

        // Verify status is paid
        var statusResult = await endpoints.payment.checkPaymentStatus(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testTransaction.internalTransactionId,
        );
        expect(statusResult.status, equals(OrderStatus.paid));
        expect(statusResult.transactionTimestamp, isNotNull);

        // Process same webhook again - should be idempotent
        final session2 = sessionBuilder.build();
        try {
          final webhookData = {
            'internalTransactionId': testTransaction.internalTransactionId,
            'success': true,
          };

          await WebhookHandler.processWebhook(
            session: session2,
            railType: PaymentRail.monero,
            webhookData: webhookData,
          );
        } finally {
          await session2.close();
        }

        // Status should remain the same
        statusResult = await endpoints.payment.checkPaymentStatus(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testTransaction.internalTransactionId,
        );
        expect(statusResult.status, equals(OrderStatus.paid));
        expect(statusResult.transactionTimestamp, isNotNull);
      });

      test('multiple payment rails registration and routing', () async {
        // Register multiple mock rails
        final moneroRail = MockPaymentRail();
        final x402Rail = MockPaymentRail();

        // Override railType for x402
        final x402RailWithType = _MockX402Rail();

        PaymentManager.registerRail(moneroRail);
        PaymentManager.registerRail(x402RailWithType);

        // Verify both rails are registered
        expect(PaymentManager.isRailRegistered(PaymentRail.monero), isTrue);
        expect(PaymentManager.isRailRegistered(PaymentRail.x402_http), isTrue);
        expect(PaymentManager.getRegisteredRailTypes().length, equals(2));

        // Test routing to correct rail
        final moneroPayment = await PaymentManager.createPayment(
          railType: PaymentRail.monero,
          amountUSD: 10.0,
          internalTransactionId: 'test-monero-order',
        );
        expect(moneroPayment.paymentRef, startsWith('mock_payment_ref_'));

        final x402Payment = await PaymentManager.createPayment(
          railType: PaymentRail.x402_http,
          amountUSD: 5.0,
          internalTransactionId: 'test-x402-order',
        );
        expect(x402Payment.paymentRef, startsWith('x402_payment_ref_'));
      });

      test('database transaction consistency', () async {
        final session = sessionBuilder.build();

        try {
          // Test direct PaymentProcessor methods
          await PaymentProcessor.updateTransactionStatus(
            session,
            testTransaction.internalTransactionId,
            OrderStatus.processing,
          );

          await PaymentProcessor.updatePaymentRef(
            session,
            testTransaction.internalTransactionId,
            'test_payment_ref_123',
          );

          await PaymentProcessor.updateTransactionTimestamp(
            session,
            testTransaction.internalTransactionId,
            DateTime.now(),
          );

          // Verify all updates were applied
          final updatedTransaction = await PaymentProcessor.getTransactionById(
            session,
            testTransaction.internalTransactionId,
          );

          expect(updatedTransaction, isNotNull);
          expect(updatedTransaction!.status, equals(OrderStatus.processing));
          expect(updatedTransaction.paymentRef, equals('test_payment_ref_123'));
          expect(updatedTransaction.transactionTimestamp, isNotNull);
        } finally {
          await session.close();
        }
      });

      test('webhook processing with invalid order ID', () async {
        // Register mock payment rail
        final mockRail = MockPaymentRail();
        PaymentManager.registerRail(mockRail);

        // Process webhook with non-existent order ID directly
        final session = sessionBuilder.build();
        try {
          final webhookData = {
            'internalTransactionId': 'non-existent-order-id',
            'success': true,
          };

          // Should complete without throwing (warning logged)
          await WebhookHandler.processWebhook(
            session: session,
            railType: PaymentRail.monero,
            webhookData: webhookData,
          );
        } finally {
          await session.close();
        }

        // Original transaction should remain unchanged
        final statusResult = await endpoints.payment.checkPaymentStatus(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testTransaction.internalTransactionId,
        );
        expect(statusResult.status, equals(OrderStatus.pending));
      });

      test('payment rail data serialization round trip', () async {
        // Register mock payment rail with complex rail data
        final mockRail = MockPaymentRail();
        PaymentManager.registerRail(mockRail);

        // Initiate payment
        final paymentRequest = await endpoints.commerce.initiatePayment(
          sessionBuilder,
          validPublicKey,
          validSignature,
          testAccount.id!,
          PaymentRail.monero,
          'test_product',
        );

        // Verify rail data round trip
        final railData =
            jsonDecode(paymentRequest.railDataJson ?? '{}')
                as Map<String, dynamic>;
        expect(railData['mockRail'], isTrue);
        expect(railData['paymentAddress'], equals('mock_address_123'));
        expect(railData['expirationTime'], isA<String>());

        // Verify the data can be serialized and deserialized
        final recreatedRequest = PaymentRequestExtension.withRailData(
          paymentRef: paymentRequest.paymentRef ?? '',
          amountUSD: paymentRequest.paymentAmount,
          internalTransactionId: paymentRequest.internalTransactionId,
          railData: railData,
        );

        expect(recreatedRequest.railData, equals(railData));
      });
    });

    group('Error Propagation Tests', () {
      test('authentication errors are properly propagated', () async {
        // Test with invalid public key
        expect(
          () => endpoints.payment.checkPaymentStatus(
            sessionBuilder,
            'invalid_key',
            validSignature,
            'any-order-id',
          ),
          throwsA(isA<AuthenticationException>()),
        );

        // Test with empty signature
        expect(
          () => endpoints.commerce.initiatePayment(
            sessionBuilder,
            validPublicKey,
            '',
            testAccount.id!,
            PaymentRail.monero,
            'test_product',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('payment exceptions contain proper context', () async {
        // Don't register any payment rails - payment should fail
        try {
          await endpoints.commerce.initiatePayment(
            sessionBuilder,
            validPublicKey,
            validSignature,
            testAccount.id!,
            PaymentRail.monero,
            'test_product',
          );
          fail('Expected PaymentException to be thrown');
        } on PaymentException catch (e) {
          // internalTransactionId is generated by CommerceManager before calling PaymentManager
          expect(e.internalTransactionId, isNotNull);
          expect(e.code, isNotEmpty);
          expect(e.message, isNotEmpty);
        }
      });
    });
  });
}

/// Mock X402 payment rail for testing multiple rail types
class _MockX402Rail implements PaymentRailInterface {
  @override
  PaymentRail get railType => PaymentRail.x402_http;

  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String internalTransactionId,
  }) async => PaymentRequestExtension.withRailData(
    paymentRef: 'x402_payment_ref_$internalTransactionId',
    amountUSD: amountUSD,
    internalTransactionId: internalTransactionId,
    railData: {
      'x402Rail': true,
      'paymentUrl': 'https://example.com/pay/$internalTransactionId',
      'acceptHeader': 'application/vnd.x402+json',
    },
  );

  @override
  Future<PaymentResult> processCallback(
    Map<String, dynamic> callbackData,
  ) async {
    final internalTransactionId =
        callbackData['internalTransactionId'] as String?;
    return PaymentResult(
      success: true,
      internalTransactionId: internalTransactionId,
      transactionTimestamp: DateTime.now(),
    );
  }

  @override
  RefundEvent? extractRefundEvent(Map<String, dynamic> notificationData) => null;
}
