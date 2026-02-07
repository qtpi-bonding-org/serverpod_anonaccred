import 'package:test/test.dart';

import '../../lib/src/payments/x402_interceptor.dart';
import '../../lib/src/payments/x402_payment_processor.dart';

/// Integration tests for X402 endpoint integration
/// 
/// Tests the X402 interceptor and payment processor functionality
/// that enables endpoint integration.
/// 
/// Requirements 5.1, 5.2, 5.3: X402 endpoint integration
void main() {

  group('X402 Interceptor Tests', () {
    test('should detect payment headers correctly', () {
      // Test case-insensitive header detection
      expect(X402Interceptor.hasPaymentHeader({'X-PAYMENT': 'test'}), isTrue);
      expect(X402Interceptor.hasPaymentHeader({'x-payment': 'test'}), isTrue);
      expect(X402Interceptor.hasPaymentHeader({'X-Payment': 'test'}), isTrue);
      expect(X402Interceptor.hasPaymentHeader({'OTHER': 'test'}), isFalse);
      expect(X402Interceptor.hasPaymentHeader({}), isFalse);
    });

    test('should extract payment headers correctly', () {
      // Test case-insensitive header extraction
      expect(X402Interceptor.getPaymentHeader({'X-PAYMENT': 'payload1'}), equals('payload1'));
      expect(X402Interceptor.getPaymentHeader({'x-payment': 'payload2'}), equals('payload2'));
      expect(X402Interceptor.getPaymentHeader({'X-Payment': 'payload3'}), equals('payload3'));
      expect(X402Interceptor.getPaymentHeader({'OTHER': 'test'}), isNull);
      expect(X402Interceptor.getPaymentHeader({}), isNull);
    });

    test('should validate configuration requirements', () {
      // This test verifies that configuration validation works
      // In a real environment, this would check actual environment variables
      expect(() => X402Interceptor.validateConfiguration(), throwsA(isA<Exception>()));
    });
  });

  group('X402 Payment Processor Tests', () {
    test('should generate compliant X402 payment responses', () {
      // Test payment response generation
      final response = X402PaymentProcessor.generatePaymentRequired(
        amount: 1.99,
        orderId: 'test_order_123',
      );

      // Verify X402 protocol compliance
      expect(response.amount, equals(1.99));
      expect(response.currency, equals('USD'));
      expect(response.orderId, equals('test_order_123'));
      expect(response.protocol, equals('x402'));
      expect(response.destination, isNotEmpty);
      expect(response.facilitator, isNotEmpty);
      expect(response.timestamp, isNotEmpty);
      
      // Verify timestamp format (ISO 8601)
      final timestamp = DateTime.tryParse(response.timestamp);
      expect(timestamp, isNotNull);
    });

    test('should handle payment verification gracefully', () async {
      // Test payment verification with empty headers
      final result1 = await X402PaymentProcessor.verifyPayment({});
      expect(result1, isFalse); // No payment header

      // Test payment verification with invalid payload
      final result2 = await X402PaymentProcessor.verifyPayment({
        'X-PAYMENT': 'invalid_payload'
      });
      expect(result2, isFalse); // Invalid payment (facilitator will reject)
    });

    test('should serialize payment responses correctly', () {
      final response = X402PaymentProcessor.generatePaymentRequired(
        amount: 5.50,
        orderId: 'serialization_test',
      );

      final json = response.toJson();
      expect(json['amount'], equals(5.50));
      expect(json['currency'], equals('USD'));
      expect(json['orderId'], equals('serialization_test'));
      expect(json['protocol'], equals('x402'));

      // Test round-trip serialization
      final restored = X402PaymentResponse.fromJson(json);
      expect(restored.amount, equals(response.amount));
      expect(restored.currency, equals(response.currency));
      expect(restored.orderId, equals(response.orderId));
      expect(restored.protocol, equals(response.protocol));
    });
  });
}

