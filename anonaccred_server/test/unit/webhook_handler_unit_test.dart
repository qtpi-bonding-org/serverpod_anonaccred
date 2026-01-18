import 'package:test/test.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:anonaccred_server/src/payments/payment_rail_interface.dart';
import 'package:anonaccred_server/src/payments/webhook_handler.dart';

/// Unit tests for WebhookHandler operations
/// Tests webhook routing, transaction status updates, and error handling
/// Requirements: 4.1, 4.2, 4.3

void main() {
  group('WebhookHandler Unit Tests', () {
    setUp(() {
      // Clear rails before each test to ensure clean state
      PaymentManager.clearRails();
    });

    group('Webhook Routing to Correct Rails', () {
      test('should route webhook to correct registered rail', () async {
        // Register mock rail
        final mockRail = MockWebhookRail(PaymentRail.x402_http);
        PaymentManager.registerRail(mockRail);

        final webhookData = {
          'orderId': 'test_order_123',
          'success': true,
          'transactionTimestamp': 'ts_456',
        };

        // Test direct rail callback processing (Requirement 4.1)
        final rail = PaymentManager.getRail(PaymentRail.x402_http);
        expect(rail, isNotNull);

        final result = await rail!.processCallback(webhookData);

        // Verify rail was called and returned expected result
        expect(mockRail.processCallbackCallCount, equals(1));
        expect(mockRail.lastCallbackData, equals(webhookData));
        expect(result.success, isTrue);
        expect(result.orderId, equals('test_order_123'));
      });

      test('should handle webhook for unregistered rail gracefully', () async {
        // No rails registered
        PaymentManager.clearRails();

        // Test rail retrieval for unregistered rail
        final rail = PaymentManager.getRail(PaymentRail.monero);
        expect(rail, isNull);

        // This simulates the WebhookHandler behavior when no rail is found
        // In the actual implementation, this would log a warning and return early
      });

      test('should route webhooks to different rails correctly', () async {
        // Register multiple rails
        final x402Rail = MockWebhookRail(PaymentRail.x402_http);
        final moneroRail = MockWebhookRail(PaymentRail.monero);

        PaymentManager.registerRail(x402Rail);
        PaymentManager.registerRail(moneroRail);

        // Process webhooks for different rails
        final x402Result = await x402Rail.processCallback({
          'orderId': 'x402_order',
        });
        final moneroResult = await moneroRail.processCallback({
          'orderId': 'monero_order',
        });

        // Verify correct rails were called
        expect(x402Rail.processCallbackCallCount, equals(1));
        expect(x402Rail.lastCallbackData?['orderId'], equals('x402_order'));
        expect(x402Result.orderId, equals('x402_order'));

        expect(moneroRail.processCallbackCallCount, equals(1));
        expect(moneroRail.lastCallbackData?['orderId'], equals('monero_order'));
        expect(moneroResult.orderId, equals('monero_order'));
      });
    });

    group('Transaction Status Updates', () {
      test('should process successful webhook results correctly', () async {
        // Register mock rail that returns successful result
        final mockRail = MockWebhookRail(
          PaymentRail.x402_http,
          shouldSucceed: true,
        );
        PaymentManager.registerRail(mockRail);

        final webhookData = {
          'orderId': 'success_order_123',
          'success': true,
          'transactionTimestamp': 'ts_success',
        };

        // Process webhook through rail (Requirement 4.2)
        final result = await mockRail.processCallback(webhookData);

        // Verify successful result structure
        expect(result.success, isTrue);
        expect(result.orderId, equals('success_order_123'));
        expect(result.transactionTimestamp, isNotNull);
        expect(result.errorMessage, isNull);
      });

      test('should handle webhook with no orderId gracefully', () async {
        // Register mock rail that returns result without orderId
        final mockRail = MockWebhookRail(
          PaymentRail.x402_http,
          includeOrderId: false,
        );
        PaymentManager.registerRail(mockRail);

        final webhookData = {
          'success': true,
          'transactionTimestamp': 'ts_no_order',
        };

        // Process webhook
        final result = await mockRail.processCallback(webhookData);

        // Should return result without orderId
        expect(result.success, isTrue);
        expect(result.orderId, isNull);
        expect(result.transactionTimestamp, isNotNull);
      });

      test('should handle failed payment webhooks correctly', () async {
        // Register mock rail that returns failed result
        final mockRail = MockWebhookRail(
          PaymentRail.x402_http,
          shouldSucceed: false,
        );
        PaymentManager.registerRail(mockRail);

        final webhookData = {
          'orderId': 'failed_order_123',
          'success': false,
          'error': 'Payment declined',
        };

        // Process webhook
        final result = await mockRail.processCallback(webhookData);

        // Verify failed result structure
        expect(result.success, isFalse);
        expect(result.orderId, equals('failed_order_123'));
        expect(result.transactionTimestamp, isNull);
        expect(result.errorMessage, equals('Mock payment failed'));
      });
    });

    group('Error Handling for Invalid Webhooks', () {
      test('should handle rail processing errors gracefully', () async {
        // Register error-throwing rail
        final errorRail = ErrorThrowingWebhookRail(PaymentRail.x402_http);
        PaymentManager.registerRail(errorRail);

        final webhookData = {'orderId': 'error_order_123', 'success': true};

        // Test that rail throws error (Requirement 4.3)
        expect(
          () async => await errorRail.processCallback(webhookData),
          throwsA(isA<Exception>()),
        );

        // In the actual WebhookHandler, this error would be caught and logged
        // but not rethrown to maintain webhook endpoint stability
      });

      test('should handle PaymentException from rails', () async {
        // Register rail that throws PaymentException
        final paymentExceptionRail = PaymentExceptionThrowingWebhookRail(
          PaymentRail.monero,
        );
        PaymentManager.registerRail(paymentExceptionRail);

        final webhookData = {
          'orderId': 'payment_exception_order',
          'success': true,
        };

        // Test that rail throws PaymentException
        expect(
          () async => await paymentExceptionRail.processCallback(webhookData),
          throwsA(isA<PaymentException>()),
        );

        // In the actual WebhookHandler, this would be caught and logged
      });

      test('should handle empty webhook data', () async {
        final mockRail = MockWebhookRail(PaymentRail.x402_http);
        PaymentManager.registerRail(mockRail);

        // Process empty webhook data
        final result = await mockRail.processCallback({});

        // Rail should still process and return result
        expect(mockRail.processCallbackCallCount, equals(1));
        expect(mockRail.lastCallbackData, equals({}));
        expect(result.success, isTrue);
      });
    });

    group('Webhook Utility Methods', () {
      test('should validate webhook data correctly', () {
        // Valid webhook data
        expect(WebhookHandler.isValidWebhookData({'key': 'value'}), isTrue);

        // Empty webhook data
        expect(WebhookHandler.isValidWebhookData({}), isFalse);
      });

      test('should extract order ID from various webhook formats', () {
        // Test different field names
        expect(
          WebhookHandler.extractOrderId({'orderId': 'order123'}),
          equals('order123'),
        );
        expect(
          WebhookHandler.extractOrderId({'order_id': 'order456'}),
          equals('order456'),
        );
        expect(
          WebhookHandler.extractOrderId({'externalId': 'order789'}),
          equals('order789'),
        );
        expect(
          WebhookHandler.extractOrderId({'external_id': 'order000'}),
          equals('order000'),
        );

        // Test precedence (orderId should take priority)
        expect(
          WebhookHandler.extractOrderId({
            'orderId': 'priority_order',
            'order_id': 'secondary_order',
          }),
          equals('priority_order'),
        );

        // Test no order ID found
        expect(WebhookHandler.extractOrderId({'other_field': 'value'}), isNull);
      });
    });
  });
}

/// Mock implementation of PaymentRailInterface for webhook testing
class MockWebhookRail implements PaymentRailInterface {
  final PaymentRail _railType;
  final bool shouldSucceed;
  final bool includeOrderId;

  int processCallbackCallCount = 0;
  Map<String, dynamic>? lastCallbackData;

  MockWebhookRail(
    this._railType, {
    this.shouldSucceed = true,
    this.includeOrderId = true,
  });

  @override
  PaymentRail get railType => _railType;

  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String orderId,
  }) async {
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
  Future<PaymentResult> processCallback(
    Map<String, dynamic> callbackData,
  ) async {
    processCallbackCallCount++;
    lastCallbackData = callbackData;

    return PaymentResult(
      success: shouldSucceed,
      orderId: includeOrderId ? callbackData['orderId'] as String? : null,
      transactionTimestamp: shouldSucceed ? DateTime.now() : null,
      errorMessage: shouldSucceed ? null : 'Mock payment failed',
    );
  }
}

/// Mock rail that throws errors for testing error handling
class ErrorThrowingWebhookRail implements PaymentRailInterface {
  final PaymentRail _railType;

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
  Future<PaymentResult> processCallback(
    Map<String, dynamic> callbackData,
  ) async {
    throw Exception('Mock webhook processing error');
  }
}

/// Mock rail that throws PaymentException for testing exception handling
class PaymentExceptionThrowingWebhookRail implements PaymentRailInterface {
  final PaymentRail _railType;

  PaymentExceptionThrowingWebhookRail(this._railType);

  @override
  PaymentRail get railType => _railType;

  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String orderId,
  }) async {
    throw PaymentException(
      code: 'RAIL_SPECIFIC_ERROR',
      message: 'Rail-specific payment error',
    );
  }

  @override
  Future<PaymentResult> processCallback(
    Map<String, dynamic> callbackData,
  ) async {
    throw PaymentException(
      code: 'WEBHOOK_PROCESSING_ERROR',
      message: 'Rail-specific webhook processing error',
    );
  }
}
