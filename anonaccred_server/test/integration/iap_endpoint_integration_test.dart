import 'dart:convert';
import 'package:test/test.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/endpoints/iap_endpoint.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Integration tests for IAP endpoint functionality
/// 
/// Tests complete IAP validation flows including authentication, receipt/token validation,
/// and inventory fulfillment. Uses mock data for reliable testing without external dependencies.
/// 
/// Focuses on essential integration scenarios during development phase.
void main() {
  withServerpod('IAP Endpoint Integration Tests', (sessionBuilder, endpoints) {
    late IAPEndpoint iapEndpoint;

    setUp(() {
      iapEndpoint = IAPEndpoint();
      // Initialize payment rails for testing
      PaymentManager.initializeAllRails();
    });

    tearDown(() {
      PaymentManager.clearRails();
    });

    group('Apple IAP Endpoint Integration', () {
      test('validateAppleReceipt handles authentication validation', () async {
        // Test that endpoint validates authentication parameters
        final session = await sessionBuilder.build();

        try {
          await iapEndpoint.validateAppleReceipt(
            session,
            '', // Empty public key should trigger authentication error
            'test_signature',
            'mock_receipt_data',
            'test_order_123',
            1,
            'premium_credits',
            10.0,
          );
          fail('Should have thrown authentication exception');
        } catch (e) {
          expect(e, isA<AuthenticationException>());
          expect(e.toString(), contains('Public key is required'));
        }
      });

      test('validateAppleReceipt handles empty receipt data', () async {
        // Test that endpoint validates receipt data parameter
        final session = await sessionBuilder.build();

        try {
          await iapEndpoint.validateAppleReceipt(
            session,
            'valid_64_char_public_key_1234567890abcdef1234567890abcdef12345678', // 64 char hex
            'test_signature',
            '', // Empty receipt data should trigger validation error
            'test_order_123',
            1,
            'premium_credits',
            10.0,
          );
          fail('Should have thrown payment exception');
        } catch (e) {
          expect(e, isA<PaymentException>());
          expect(e.toString(), contains('Receipt data cannot be empty'));
        }
      });

      test('validateAppleReceipt handles invalid consumable type', () async {
        // Test that endpoint validates consumable type parameter
        final session = await sessionBuilder.build();

        try {
          await iapEndpoint.validateAppleReceipt(
            session,
            'valid_64_char_public_key_1234567890abcdef1234567890abcdef12345678',
            'test_signature',
            'mock_receipt_data',
            'test_order_123',
            1,
            '', // Empty consumable type should trigger inventory error
            10.0,
          );
          fail('Should have thrown inventory exception');
        } catch (e) {
          expect(e, isA<InventoryException>());
          expect(e.toString(), contains('Consumable type cannot be empty'));
        }
      });

      test('validateAppleReceipt handles invalid quantity', () async {
        // Test that endpoint validates quantity parameter
        final session = await sessionBuilder.build();

        try {
          await iapEndpoint.validateAppleReceipt(
            session,
            'valid_64_char_public_key_1234567890abcdef1234567890abcdef12345678',
            'test_signature',
            'mock_receipt_data',
            'test_order_123',
            1,
            'premium_credits',
            -5.0, // Negative quantity should trigger inventory error
          );
          fail('Should have thrown inventory exception');
        } catch (e) {
          expect(e, isA<InventoryException>());
          expect(e.toString(), contains('Quantity must be positive'));
        }
      });
    });

    group('Google IAP Endpoint Integration', () {
      test('validateGooglePurchase handles authentication validation', () async {
        // Test that endpoint validates authentication parameters
        final session = await sessionBuilder.build();

        try {
          await iapEndpoint.validateGooglePurchase(
            session,
            '', // Empty public key should trigger authentication error
            'test_signature',
            'com.example.app',
            'com.example.premium',
            'mock_purchase_token',
            'test_order_456',
            1,
            'premium_credits',
            5.0,
          );
          fail('Should have thrown authentication exception');
        } catch (e) {
          expect(e, isA<AuthenticationException>());
          expect(e.toString(), contains('Public key is required'));
        }
      });

      test('validateGooglePurchase handles missing purchase parameters', () async {
        // Test that endpoint validates Google-specific parameters
        final session = await sessionBuilder.build();

        try {
          await iapEndpoint.validateGooglePurchase(
            session,
            'valid_64_char_public_key_1234567890abcdef1234567890abcdef12345678',
            'test_signature',
            '', // Empty package name should trigger validation error
            'com.example.premium',
            'mock_purchase_token',
            'test_order_456',
            1,
            'premium_credits',
            5.0,
          );
          fail('Should have thrown payment exception');
        } catch (e) {
          expect(e, isA<PaymentException>());
          expect(e.toString(), contains('Package name, product ID, and purchase token are required'));
        }
      });

      test('validateGooglePurchase handles invalid consumable type', () async {
        // Test that endpoint validates consumable type parameter
        final session = await sessionBuilder.build();

        try {
          await iapEndpoint.validateGooglePurchase(
            session,
            'valid_64_char_public_key_1234567890abcdef1234567890abcdef12345678',
            'test_signature',
            'com.example.app',
            'com.example.premium',
            'mock_purchase_token',
            'test_order_456',
            1,
            '', // Empty consumable type should trigger inventory error
            5.0,
          );
          fail('Should have thrown inventory exception');
        } catch (e) {
          expect(e, isA<InventoryException>());
          expect(e.toString(), contains('Consumable type cannot be empty'));
        }
      });

      test('validateGooglePurchase handles invalid quantity', () async {
        // Test that endpoint validates quantity parameter
        final session = await sessionBuilder.build();

        try {
          await iapEndpoint.validateGooglePurchase(
            session,
            'valid_64_char_public_key_1234567890abcdef1234567890abcdef12345678',
            'test_signature',
            'com.example.app',
            'com.example.premium',
            'mock_purchase_token',
            'test_order_456',
            1,
            'premium_credits',
            0.0, // Zero quantity should trigger inventory error
          );
          fail('Should have thrown inventory exception');
        } catch (e) {
          expect(e, isA<InventoryException>());
          expect(e.toString(), contains('Quantity must be positive'));
        }
      });
    });

    group('IAP Webhook Integration', () {
      test('handleAppleWebhook processes webhook data', () async {
        // Test Apple webhook processing
        final session = await sessionBuilder.build();

        final mockWebhookData = {
          'notification_type': 'INITIAL_BUY',
          'password': 'shared_secret',
          'receipt_data': 'base64_encoded_receipt',
        };

        final result = await iapEndpoint.handleAppleWebhook(session, mockWebhookData);

        expect(result['success'], isTrue);
        expect(result['message'], contains('Apple webhook processed'));
        expect(result['timestamp'], isNotNull);
      });

      test('handleGoogleWebhook processes webhook data', () async {
        // Test Google webhook processing
        final session = await sessionBuilder.build();

        final mockWebhookData = {
          'version': '1.0',
          'packageName': 'com.example.app',
          'eventTimeMillis': 1698386400000,
          'subscriptionNotification': {
            'version': '1.0',
            'notificationType': 1,
            'purchaseToken': 'mock_purchase_token',
            'subscriptionId': 'premium_subscription',
          },
        };

        final result = await iapEndpoint.handleGoogleWebhook(session, mockWebhookData);

        expect(result['success'], isTrue);
        expect(result['message'], contains('Google webhook processed'));
        expect(result['timestamp'], isNotNull);
      });

      test('handleAppleWebhook handles webhook processing errors', () async {
        // Test Apple webhook error handling
        final session = await sessionBuilder.build();

        // Pass null to trigger error
        final result = await iapEndpoint.handleAppleWebhook(session, null as Map<String, dynamic>);

        expect(result['success'], isFalse);
        expect(result['error'], equals('Webhook processing failed'));
        expect(result['message'], isNotNull);
      });

      test('handleGoogleWebhook handles webhook processing errors', () async {
        // Test Google webhook error handling
        final session = await sessionBuilder.build();

        // Pass null to trigger error
        final result = await iapEndpoint.handleGoogleWebhook(session, null as Map<String, dynamic>);

        expect(result['success'], isFalse);
        expect(result['error'], equals('Webhook processing failed'));
        expect(result['message'], isNotNull);
      });
    });

    group('IAP Payment Rail Integration', () {
      test('Payment Manager can create Apple IAP payments', () async {
        // Test that Payment Manager routes Apple IAP requests correctly
        final paymentRequest = await PaymentManager.createPayment(
          railType: PaymentRail.apple_iap,
          amountUSD: 9.99,
          orderId: 'integration_test_apple',
        );

        expect(paymentRequest.paymentRef, equals('integration_test_apple'));
        expect(paymentRequest.amountUSD, equals(9.99));
        final railData = jsonDecode(paymentRequest.railDataJson);
        expect(railData['payment_rail'], equals('apple_iap'));
      });

      test('Payment Manager can create Google IAP payments', () async {
        // Test that Payment Manager routes Google IAP requests correctly
        final paymentRequest = await PaymentManager.createPayment(
          railType: PaymentRail.google_iap,
          amountUSD: 4.99,
          orderId: 'integration_test_google',
        );

        expect(paymentRequest.paymentRef, equals('integration_test_google'));
        expect(paymentRequest.amountUSD, equals(4.99));
        final railData = jsonDecode(paymentRequest.railDataJson);
        expect(railData['payment_rail'], equals('google_iap'));
      });

      test('Payment Manager initialization registers IAP rails', () {
        // Test that initialization properly registers IAP rails
        PaymentManager.clearRails();
        expect(PaymentManager.isRailRegistered(PaymentRail.apple_iap), isFalse);
        expect(PaymentManager.isRailRegistered(PaymentRail.google_iap), isFalse);

        PaymentManager.initializeAllRails();
        
        // Rails should be registered (even if not configured, they should be registered)
        final registeredTypes = PaymentManager.getRegisteredRailTypes();
        expect(registeredTypes, contains(PaymentRail.apple_iap));
        expect(registeredTypes, contains(PaymentRail.google_iap));
      });
    });
  });
}