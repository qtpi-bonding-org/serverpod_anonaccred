import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:test/test.dart';

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
    const validPublicKey =
        '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
    const validSignature =
        'valid_signature_placeholder_64_chars_1234567890abcdef1234567890ab';

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

      test('checkPaymentStatus - invalid authentication', () async {
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
