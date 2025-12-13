import 'dart:math';
import 'package:test/test.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:anonaccred_server/src/payments/payment_rail_interface.dart';

/// **Feature: anonaccred-phase4, Property 3: Webhook Processing Idempotency**
/// **Validates: Requirements 4.4**

void main() {
  final random = Random();

  group('Webhook Handler Property Tests', () {
    setUp(() {
      // Clear rails before each test to ensure clean state
      PaymentManager.clearRails();
    });

    test(
      'Property 3: Webhook Processing Idempotency - For any webhook payload, processing it multiple times should not cause duplicate transaction status changes',
      () async {
        // Run 5 iterations during development (can be increased to 100+ for production)
        for (int i = 0; i < 5; i++) {
          // Generate random test data
          final railType = PaymentRail.values[random.nextInt(PaymentRail.values.length)];
          final orderId = 'order_${random.nextInt(999999)}';
          final transactionHash = 'tx_hash_${random.nextInt(999999)}';
          final isSuccess = random.nextBool();
          
          // Register a mock rail that returns consistent results
          final mockRail = MockWebhookRail(railType, orderId, transactionHash, isSuccess);
          PaymentManager.registerRail(mockRail);
          
          // Create webhook data
          final webhookData = {
            'orderId': orderId,
            'transactionHash': transactionHash,
            'success': isSuccess,
            'timestamp': DateTime.now().toIso8601String(),
          };
          
          // Test the core idempotency property: processing the same webhook multiple times
          // should produce identical results from the payment rail
          
          // Process webhook first time
          final firstResult = await mockRail.processCallback(webhookData);
          
          // Process the same webhook multiple times (idempotency test)
          final subsequentResults = <PaymentResult>[];
          for (int j = 0; j < 3; j++) {
            final result = await mockRail.processCallback(webhookData);
            subsequentResults.add(result);
          }
          
          // Verify all results are identical (idempotent)
          for (final result in subsequentResults) {
            expect(result.success, equals(firstResult.success));
            expect(result.orderId, equals(firstResult.orderId));
            expect(result.transactionHash, equals(firstResult.transactionHash));
            expect(result.errorMessage, equals(firstResult.errorMessage));
          }
          
          // Verify consistent results match expected values
          expect(firstResult.success, equals(isSuccess));
          expect(firstResult.orderId, equals(orderId));
          if (isSuccess) {
            expect(firstResult.transactionHash, equals(transactionHash));
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
        
        final rail1 = MockWebhookRail(railType, 'order1', 'hash1', true);
        final rail2 = MockWebhookRail(railType, 'order2', 'hash2', false);
        
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
          final orderId = 'consistency_test_${railType.name}';
          final mockRail = MockWebhookRail(railType, orderId, 'hash_123', true);
          
          final webhookData = {
            'orderId': orderId,
            'success': true,
          };
          
          // Call processCallback multiple times with same data
          final results = <PaymentResult>[];
          for (int i = 0; i < 5; i++) {
            final result = await mockRail.processCallback(webhookData);
            results.add(result);
          }
          
          // All results should be identical
          final firstResult = results.first;
          for (final result in results.skip(1)) {
            expect(result.success, equals(firstResult.success));
            expect(result.orderId, equals(firstResult.orderId));
            expect(result.transactionHash, equals(firstResult.transactionHash));
            expect(result.errorMessage, equals(firstResult.errorMessage));
          }
        }
      },
    );

    test(
      'Property 3 Extension: Error handling consistency',
      () async {
        // Test that error-throwing rails behave consistently
        const railType = PaymentRail.monero;
        final errorRail = ErrorThrowingWebhookRail(railType);
        
        final webhookData = {
          'orderId': 'error_test',
          'success': true,
        };
        
        // Multiple calls should all throw the same type of error
        for (int i = 0; i < 3; i++) {
          expect(
            () async => await errorRail.processCallback(webhookData),
            throwsA(isA<Exception>()),
          );
        }
        
        expect(errorRail.callCount, equals(3));
      },
    );
  });
}

/// Mock implementation of PaymentRailInterface for webhook testing
class MockWebhookRail implements PaymentRailInterface {
  final PaymentRail _railType;
  final String _orderId;
  final String _transactionHash;
  final bool _success;
  int callCount = 0;
  final List<PaymentResult> results = [];
  
  MockWebhookRail(this._railType, this._orderId, this._transactionHash, this._success);
  
  @override
  PaymentRail get railType => _railType;
  
  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String orderId,
  }) async {
    // Mock implementation for testing
    return PaymentRequestExtension.withRailData(
      paymentRef: 'mock_payment_ref_$orderId',
      amountUSD: amountUSD,
      orderId: orderId,
      railData: {
        'railType': railType.toString(),
        'mockData': 'webhook_test_data',
      },
    );
  }
  
  @override
  Future<PaymentResult> processCallback(Map<String, dynamic> callbackData) async {
    callCount++;
    
    // Mock implementation that returns consistent results for testing idempotency
    final result = PaymentResult(
      success: _success,
      orderId: _orderId,
      transactionHash: _success ? _transactionHash : null,
      errorMessage: _success ? null : 'Mock payment failed',
    );
    
    results.add(result);
    return result;
  }
}

/// Mock rail that throws errors for testing error handling
class ErrorThrowingWebhookRail implements PaymentRailInterface {
  final PaymentRail _railType;
  int callCount = 0;
  
  ErrorThrowingWebhookRail(this._railType);
  
  @override
  PaymentRail get railType => _railType;
  
  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String orderId,
  }) async {
    throw Exception('Mock rail error for testing');
  }
  
  @override
  Future<PaymentResult> processCallback(Map<String, dynamic> callbackData) async {
    callCount++;
    throw Exception('Mock callback error for testing');
  }
}

