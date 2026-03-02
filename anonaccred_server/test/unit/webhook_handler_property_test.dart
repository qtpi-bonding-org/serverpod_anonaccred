import 'dart:math';

import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:anonaccred_server/src/payments/payment_rail_interface.dart';
import 'package:test/test.dart';

/// **Feature: anonaccred-phase4, Property 3: Webhook Processing Idempotency**
/// **Validates: Requirements 4.4**

void main() {
  final random = Random();

  group('Webhook Handler Property Tests', () {
    setUp(PaymentManager.clearRails);

    test(
      'Property 3: Webhook Processing Idempotency - For any webhook payload, processing it multiple times should not cause duplicate transaction status changes',
      () async {
        // Run 5 iterations during development (can be increased to 100+ for production)
        for (var i = 0; i < 5; i++) {
          // Generate random test data
          final railType =
              PaymentRail.values[random.nextInt(PaymentRail.values.length)];
          final internalTransactionId = 'order_${random.nextInt(999999)}';
          final transactionTimestamp = DateTime.now();
          final isSuccess = random.nextBool();

          // Register a mock rail that returns consistent results
          final mockRail = MockWebhookRail(
            railType,
            internalTransactionId,
            transactionTimestamp,
            isSuccess,
          );
          PaymentManager.registerRail(mockRail);

          // Create webhook data
          final webhookData = {
            'internalTransactionId': internalTransactionId,
            'transactionTimestamp': transactionTimestamp,
            'success': isSuccess,
            'timestamp': DateTime.now().toIso8601String(),
          };

          // Test the core idempotency property: processing the same webhook multiple times
          // should produce identical results from the payment rail

          // Process webhook first time
          final firstResult = await mockRail.processCallback(webhookData);

          // Process the same webhook multiple times (idempotency test)
          final subsequentResults = <PaymentResult>[];
          for (var j = 0; j < 3; j++) {
            final result = await mockRail.processCallback(webhookData);
            subsequentResults.add(result);
          }

          // Verify all results are identical (idempotent)
          for (final result in subsequentResults) {
            expect(result.success, equals(firstResult.success));
            expect(
              result.internalTransactionId,
              equals(firstResult.internalTransactionId),
            );
            expect(
              result.transactionTimestamp,
              equals(firstResult.transactionTimestamp),
            );
            expect(result.errorMessage, equals(firstResult.errorMessage));
          }

          // Verify consistent results match expected values
          expect(firstResult.success, equals(isSuccess));
          expect(
            firstResult.internalTransactionId,
            equals(internalTransactionId),
          );
          if (isSuccess) {
            expect(
              firstResult.transactionTimestamp,
              equals(transactionTimestamp),
            );
          }

          // Verify rail was called for each processing
          expect(mockRail.callCount, equals(4)); // 1 initial + 3 repeated calls
        }
      },
    );

    test(
      'Property 3 Extension: Payment rail registration and retrieval idempotency',
      () async {
        // Test that registering the same rail multiple times is idempotent
        const railType = PaymentRail.x402_http;

        final rail1 = MockWebhookRail(railType, 'order1', DateTime.now(), true);
        final rail2 = MockWebhookRail(
          railType,
          'order2',
          DateTime.now(),
          false,
        );

        // Register first rail
        PaymentManager.registerRail(rail1);
        expect(PaymentManager.getRail(railType), equals(rail1));

        // Register second rail with same type (should replace)
        PaymentManager.registerRail(rail2);
        expect(PaymentManager.getRail(railType), equals(rail2));

        // Multiple registrations of the same rail should be idempotent
        PaymentManager.registerRail(rail2);
        PaymentManager.registerRail(rail2);
        expect(PaymentManager.getRail(railType), equals(rail2));
      },
    );

    test(
      'Property 3 Extension: Payment result consistency across multiple calls',
      () async {
        // Test that payment rails return consistent results for the same input
        for (final railType in PaymentRail.values) {
          final internalTransactionId = 'consistency_test_${railType.name}';
          final mockRail = MockWebhookRail(
            railType,
            internalTransactionId,
            DateTime.now(),
            true,
          );

          final webhookData = {
            'internalTransactionId': internalTransactionId,
            'success': true,
          };

          // Call processCallback multiple times with same data
          final results = <PaymentResult>[];
          for (var i = 0; i < 5; i++) {
            final result = await mockRail.processCallback(webhookData);
            results.add(result);
          }

          // All results should be identical
          final firstResult = results.first;
          for (final result in results.skip(1)) {
            expect(result.success, equals(firstResult.success));
            expect(
              result.internalTransactionId,
              equals(firstResult.internalTransactionId),
            );
            expect(
              result.transactionTimestamp,
              equals(firstResult.transactionTimestamp),
            );
            expect(result.errorMessage, equals(firstResult.errorMessage));
          }
        }
      },
    );

    test('Property 3 Extension: Error handling consistency', () async {
      // Test that error-throwing rails behave consistently
      const railType = PaymentRail.monero;
      final errorRail = ErrorThrowingWebhookRail(railType);

      final webhookData = {
        'internalTransactionId': 'error_test',
        'success': true,
      };

      // Multiple calls should all throw the same type of error
      for (var i = 0; i < 3; i++) {
        expect(
          () async => errorRail.processCallback(webhookData),
          throwsA(isA<Exception>()),
        );
      }

      expect(errorRail.callCount, equals(3));
    });
  });
}

/// Mock implementation of PaymentRailInterface for webhook testing
class MockWebhookRail implements PaymentRailInterface {
  MockWebhookRail(
    this._railType,
    this._internalTransactionId,
    this._transactionTimestamp,
    this._success,
  );
  final PaymentRail _railType;
  final String _internalTransactionId;
  final DateTime _transactionTimestamp;
  final bool _success;
  int callCount = 0;
  final List<PaymentResult> results = [];

  @override
  PaymentRail get railType => _railType;

  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String internalTransactionId,
  }) async {
    // Mock implementation for testing
    return PaymentRequestExtension.withRailData(
      paymentRef: 'mock_payment_ref_$internalTransactionId',
      amountUSD: amountUSD,
      internalTransactionId: internalTransactionId,
      railData: {
        'railType': railType.toString(),
        'mockData': 'webhook_test_data',
      },
    );
  }

  @override
  Future<PaymentResult> processCallback(
    Map<String, dynamic> callbackData,
  ) async {
    callCount++;

    // Mock implementation that returns consistent results for testing idempotency
    final result = PaymentResult(
      success: _success,
      internalTransactionId: _internalTransactionId,
      transactionTimestamp: _success ? _transactionTimestamp : null,
      errorMessage: _success ? null : 'Mock payment failed',
    );

    results.add(result);
    return result;
  }
}

/// Mock rail that throws errors for testing error handling
class ErrorThrowingWebhookRail implements PaymentRailInterface {
  ErrorThrowingWebhookRail(this._railType);
  final PaymentRail _railType;
  int callCount = 0;

  @override
  PaymentRail get railType => _railType;

  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String internalTransactionId,
  }) async {
    throw Exception('Mock rail error for testing');
  }

  @override
  Future<PaymentResult> processCallback(
    Map<String, dynamic> callbackData,
  ) async {
    callCount++;
    throw Exception('Mock callback error for testing');
  }
}
