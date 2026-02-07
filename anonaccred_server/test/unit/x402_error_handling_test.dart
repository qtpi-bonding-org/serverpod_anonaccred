import 'package:test/test.dart';
import 'package:anonaccred_server/src/payments/x402_payment_processor.dart';
import 'package:anonaccred_server/src/exception_factory.dart';
import 'package:anonaccred_server/src/error_classification.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';

/// Test for X402 error handling improvements
/// 
/// Validates that the enhanced error handling system works correctly
/// while maintaining backward compatibility.
void main() {
  group('X402 Error Handling Tests', () {
    test('verifyPayment maintains backward compatibility', () async {
      // Test that verifyPayment returns false for all error conditions
      // (maintaining backward compatibility with existing tests)
      
      final testCases = [
        <String, String>{}, // No headers
        {'OTHER-HEADER': 'value'}, // Wrong header
        {'X-PAYMENT': ''}, // Empty payment
        {'X-PAYMENT': '   '}, // Whitespace only
        {'X-PAYMENT': 'invalid_payload'}, // Invalid payload (will fail at facilitator)
      ];

      for (final headers in testCases) {
        final result = await X402PaymentProcessor.verifyPayment(headers);
        expect(result, isFalse, reason: 'All error cases should return false');
        expect(result, isA<bool>(), reason: 'Should return boolean');
      }
    });

    test('verifyPaymentWithDetails provides detailed error information', () async {
      // Test that verifyPaymentWithDetails throws appropriate exceptions
      
      // Test missing X-PAYMENT header
      expect(
        () async => await X402PaymentProcessor.verifyPaymentWithDetails({}),
        returnsNormally, // Missing header returns false, doesn't throw
      );
      
      final result = await X402PaymentProcessor.verifyPaymentWithDetails({});
      expect(result, isFalse);

      // Test facilitator unavailable (will throw exception)
      expect(
        () async => await X402PaymentProcessor.verifyPaymentWithDetails({
          'X-PAYMENT': 'valid_looking_payload_123'
        }),
        throwsA(isA<PaymentException>()),
      );
    });

    test('generatePaymentRequired handles configuration errors', () {
      // Test configuration validation in generatePaymentRequired
      // This should work with default environment values
      
      expect(
        () => X402PaymentProcessor.generatePaymentRequired(
          amount: 10.0,
          orderId: 'test_order_123',
        ),
        returnsNormally, // Should work with default config
      );
      
      final response = X402PaymentProcessor.generatePaymentRequired(
        amount: 10.0,
        orderId: 'test_order_123',
      );
      
      expect(response.amount, equals(10.0));
      expect(response.orderId, equals('test_order_123'));
      expect(response.currency, equals('USD'));
      expect(response.protocol, equals('x402'));
    });

    test('error codes are properly classified', () {
      // Test that new X402 error codes are properly classified
      
      expect(
        AnonAccredExceptionUtils.isRetryable(AnonAccredErrorCodes.x402FacilitatorUnavailable),
        isTrue,
        reason: 'Facilitator unavailable should be retryable',
      );
      
      expect(
        AnonAccredExceptionUtils.isRetryable(AnonAccredErrorCodes.x402InvalidPaymentPayload),
        isFalse,
        reason: 'Invalid payment payload should not be retryable',
      );
      
      expect(
        AnonAccredExceptionUtils.isRetryable(AnonAccredErrorCodes.x402ConfigurationMissing),
        isFalse,
        reason: 'Configuration missing should not be retryable',
      );
      
      expect(
        AnonAccredExceptionUtils.isRetryable(AnonAccredErrorCodes.x402VerificationFailed),
        isFalse,
        reason: 'Verification failed should not be retryable',
      );
    });

    test('error analysis provides comprehensive information', () {
      // Test that error analysis works for X402 exceptions
      
      final exception = AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.x402FacilitatorUnavailable,
        message: 'Test facilitator unavailable',
        paymentRail: 'x402_http',
      );
      
      final analysis = AnonAccredExceptionUtils.analyzeException(exception);
      
      expect(analysis['code'], equals(AnonAccredErrorCodes.x402FacilitatorUnavailable));
      expect(analysis['message'], equals('Test facilitator unavailable'));
      expect(analysis['retryable'], isTrue);
      expect(analysis['severity'], equals('medium'));
      expect(analysis['category'], equals('payment'));
      expect(analysis['recoveryGuidance'], contains('Facilitator'));
    });
  });
}