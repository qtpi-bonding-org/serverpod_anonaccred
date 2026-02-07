import 'dart:convert';
import 'package:test/test.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/rails/apple_iap_rail.dart';

/// Unit tests for Apple IAP rail implementation
/// 
/// Tests core Apple IAP functionality including payment request creation,
/// receipt validation result parsing, and transaction data extraction.
/// 
/// Focuses on happy path validation and essential error cases during development.
void main() {
  group('Apple IAP Rail Tests', () {
    late AppleIAPRail appleRail;

    setUp(() {
      appleRail = AppleIAPRail();
    });

    test('createPayment returns valid PaymentRequest for Apple IAP', () async {
      // Test happy path: creating payment request for Apple IAP
      final paymentRequest = await appleRail.createPayment(
        amountUSD: 9.99,
        orderId: 'apple_test_order_123',
      );

      expect(paymentRequest.paymentRef, equals('apple_test_order_123'));
      expect(paymentRequest.amountUSD, equals(9.99));
      expect(paymentRequest.orderId, equals('apple_test_order_123'));
      
      final railData = jsonDecode(paymentRequest.railDataJson) as Map<String, dynamic>;
      expect(railData['payment_rail'], equals('apple_iap'));
      expect(railData['order_id'], equals('apple_test_order_123'));
      expect(railData['validation_endpoint'], equals('/api/iap/apple/validate'));
      expect(DateTime.parse(railData['expires_at']).isAfter(DateTime.now()), isTrue);
    });

    test('railType returns correct PaymentRail enum value', () {
      // Test that rail type is correctly identified
      expect(appleRail.railType, equals(PaymentRail.apple_iap));
    });

    test('AppleReceiptValidationResult.fromJson parses valid Apple response', () {
      // Test parsing of successful Apple receipt validation response
      final mockAppleResponse = {
        'status': 0,
        'environment': 'Production',
        'receipt': {
          'bundle_id': 'com.example.app',
          'application_version': '1.0',
          'in_app': [
            {
              'transaction_id': '1000000012345678',
              'original_transaction_id': '1000000012345678',
              'product_id': 'com.example.premium',
              'purchase_date': '2023-10-27 10:00:00 Etc/GMT',
              'purchase_date_ms': '1698386400000',
              'quantity': '1',
            }
          ]
        }
      };

      final result = AppleReceiptValidationResult.fromJson(mockAppleResponse);

      expect(result.status, equals(0));
      expect(result.environment, equals('Production'));
      expect(result.isValid, isTrue);
      expect(result.isSandbox, isFalse);
      expect(result.purchaseDate, equals('1000000012345678'));
      expect(result.errorMessage, equals('Receipt validation successful'));
    });

    test('AppleReceiptValidationResult handles error status codes', () {
      // Test parsing of Apple error responses
      final errorCodes = [21000, 21002, 21003, 21004, 21005, 21006, 21007, 21008, 21010];
      final expectedMessages = [
        'App Store cannot read the JSON object',
        'Receipt data property malformed or missing',
        'Receipt could not be authenticated',
        'Shared secret does not match',
        'Receipt server temporarily unavailable',
        'Receipt valid but subscription expired',
        'Receipt from sandbox but sent to production',
        'Receipt from production but sent to sandbox',
        'Account not found or deleted',
      ];

      for (int i = 0; i < errorCodes.length; i++) {
        final mockErrorResponse = {
          'status': errorCodes[i],
          'environment': 'Production',
        };

        final result = AppleReceiptValidationResult.fromJson(mockErrorResponse);

        expect(result.status, equals(errorCodes[i]));
        expect(result.isValid, isFalse);
        expect(result.errorMessage, equals(expectedMessages[i]));
      }
    });

    test('AppleReceiptValidationResult detects sandbox environment', () {
      // Test sandbox environment detection
      final mockSandboxResponse = {
        'status': 0,
        'environment': 'Sandbox',
        'receipt': {
          'bundle_id': 'com.example.app',
          'in_app': []
        }
      };

      final result = AppleReceiptValidationResult.fromJson(mockSandboxResponse);

      expect(result.environment, equals('Sandbox'));
      expect(result.isSandbox, isTrue);
      expect(result.isValid, isTrue);
    });

    test('extractTransactionData extracts PII-free transaction details', () {
      // Test that transaction data extraction only includes non-PII information
      final mockReceiptData = {
        'receipt': {
          'bundle_id': 'com.example.app',
          'application_version': '1.0',
          'in_app': [
            {
              'transaction_id': '1000000012345678',
              'original_transaction_id': '1000000012345678',
              'product_id': 'com.example.premium',
              'purchase_date': '2023-10-27 10:00:00 Etc/GMT',
              'purchase_date_ms': '1698386400000',
              'quantity': '1',
              'is_trial_period': 'false',
            }
          ]
        }
      };

      final transactionData = AppleIAPRail.extractTransactionData(mockReceiptData);

      // Verify extracted data contains expected fields
      expect(transactionData['transaction_id'], equals('1000000012345678'));
      expect(transactionData['original_transaction_id'], equals('1000000012345678'));
      expect(transactionData['product_id'], equals('com.example.premium'));
      expect(transactionData['purchase_date'], equals('2023-10-27 10:00:00 Etc/GMT'));
      expect(transactionData['purchase_date_ms'], equals('1698386400000'));
      expect(transactionData['quantity'], equals('1'));
      expect(transactionData['is_trial_period'], equals('false'));
      expect(transactionData['bundle_id'], equals('com.example.app'));
      expect(transactionData['application_version'], equals('1.0'));

      // Verify no PII fields are included (transaction IDs and product info are not PII)
      expect(transactionData.keys, everyElement(isNot(contains('email'))));
      expect(transactionData.keys, everyElement(isNot(contains('name'))));
      expect(transactionData.keys, everyElement(isNot(contains('address'))));
    });

    test('processCallback handles Apple webhook data', () async {
      // Test callback processing for Apple webhooks
      final mockCallbackData = {
        'receipt_data': 'base64_encoded_receipt_data',
        'order_id': 'webhook_test_order',
      };

      final result = await appleRail.processCallback(mockCallbackData);

      // Should return failure since we don't have configuration in test
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Apple IAP callback processing failed'));
    });

    test('processCallback handles missing callback data', () async {
      // Test callback processing with missing required fields
      final mockCallbackData = {
        'receipt_data': 'base64_encoded_receipt_data',
        // Missing order_id
      };

      final result = await appleRail.processCallback(mockCallbackData);

      expect(result.success, isFalse);
      expect(result.errorMessage, equals('Missing receipt_data or order_id in callback'));
    });

    test('AppleIAPConfig configuration detection', () {
      // Test configuration detection (will be false in test environment)
      expect(AppleIAPConfig.isConfigured, isFalse);
      expect(AppleIAPConfig.sharedSecret, isNull);
      expect(AppleIAPConfig.useSandbox, isFalse);
    });

    test('AppleIAPConfig validation throws exception when not configured', () {
      // Test that configuration validation throws appropriate exception
      expect(
        () => AppleIAPConfig.validateConfiguration(),
        throwsA(isA<AnonAccredException>()),
      );
    });
  });
}