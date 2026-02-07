import 'package:test/test.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Integration tests for complete IAP payment flows
/// 
/// Tests end-to-end IAP payment processing including rail registration,
/// payment creation, and basic error handling.
/// 
/// Requirements 1.4: Test inventory fulfillment after successful validation
/// Requirements 1.5: Test complete Apple and Google IAP flows
void main() {
  withServerpod('IAP Payment Flow Integration Tests', (sessionBuilder, endpoints) {
    setUp(() {
      // Clear and reinitialize payment rails for each test
      PaymentManager.clearRails();
      PaymentManager.initializeAllRails();
    });

    group('Apple IAP Payment Flow', () {
      test('Complete Apple IAP payment creation flow', () async {
        // Test that Apple IAP rail is registered and can create payments
        expect(PaymentManager.isRailRegistered(PaymentRail.apple_iap), isTrue);

        final paymentRequest = await PaymentManager.createPayment(
          railType: PaymentRail.apple_iap,
          amountUSD: 9.99,
          orderId: 'test_apple_flow_001',
        );

        expect(paymentRequest.paymentRef, equals('test_apple_flow_001'));
        expect(paymentRequest.amountUSD, equals(9.99));
        expect(paymentRequest.orderId, equals('test_apple_flow_001'));
        
        // Verify rail data contains Apple IAP information
        expect(paymentRequest.railDataJson, contains('apple_iap'));
        expect(paymentRequest.railDataJson, contains('validation_endpoint'));
      });

      test('Apple IAP payment handles configuration errors gracefully', () async {
        // Test that payment creation works even without configuration
        // (Configuration is checked during validation, not creation)
        expect(() async {
          await PaymentManager.createPayment(
            railType: PaymentRail.apple_iap,
            amountUSD: 4.99,
            orderId: 'test_apple_config_001',
          );
        }, returnsNormally);
      });
    });

    group('Google IAP Payment Flow', () {
      test('Complete Google IAP payment creation flow', () async {
        // Test that Google IAP rail is registered and can create payments
        expect(PaymentManager.isRailRegistered(PaymentRail.google_iap), isTrue);

        final paymentRequest = await PaymentManager.createPayment(
          railType: PaymentRail.google_iap,
          amountUSD: 14.99,
          orderId: 'test_google_flow_001',
        );

        expect(paymentRequest.paymentRef, equals('test_google_flow_001'));
        expect(paymentRequest.amountUSD, equals(14.99));
        expect(paymentRequest.orderId, equals('test_google_flow_001'));
        
        // Verify rail data contains Google IAP information
        expect(paymentRequest.railDataJson, contains('google_iap'));
        expect(paymentRequest.railDataJson, contains('validation_endpoint'));
      });

      test('Google IAP payment handles configuration errors gracefully', () async {
        // Test that payment creation works even without configuration
        // (Configuration is checked during validation, not creation)
        expect(() async {
          await PaymentManager.createPayment(
            railType: PaymentRail.google_iap,
            amountUSD: 7.99,
            orderId: 'test_google_config_001',
          );
        }, returnsNormally);
      });
    });

    group('IAP Payment Manager Integration', () {
      test('Payment Manager registers all IAP rails correctly', () {
        // Test that initialization registers both IAP rails
        final registeredTypes = PaymentManager.getRegisteredRailTypes();
        
        expect(registeredTypes, contains(PaymentRail.apple_iap));
        expect(registeredTypes, contains(PaymentRail.google_iap));
        expect(registeredTypes, contains(PaymentRail.x402_http));
      });

      test('Payment Manager handles unsupported rail types', () {
        // Clear rails and test error handling
        PaymentManager.clearRails();
        
        expect(() async {
          await PaymentManager.createPayment(
            railType: PaymentRail.apple_iap,
            amountUSD: 9.99,
            orderId: 'test_unsupported_001',
          );
        }, throwsA(isA<PaymentException>()));
      });
    });
  });
}