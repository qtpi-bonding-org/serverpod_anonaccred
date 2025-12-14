import 'dart:convert';
import 'package:test/test.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/rails/google_iap_rail.dart';

/// Unit tests for Google IAP rail implementation
/// 
/// Tests core Google IAP functionality including payment request creation,
/// purchase validation result parsing, and transaction data extraction.
/// 
/// Focuses on happy path validation and essential error cases during development.
void main() {
  group('Google IAP Rail Tests', () {
    late GoogleIAPRail googleRail;

    setUp(() {
      googleRail = GoogleIAPRail();
    });

    test('createPayment returns valid PaymentRequest for Google IAP', () async {
      // Test happy path: creating payment request for Google IAP
      final paymentRequest = await googleRail.createPayment(
        amountUSD: 4.99,
        orderId: 'google_test_order_456',
      );

      expect(paymentRequest.paymentRef, equals('google_test_order_456'));
      expect(paymentRequest.amountUSD, equals(4.99));
      expect(paymentRequest.orderId, equals('google_test_order_456'));
      
      final railData = jsonDecode(paymentRequest.railDataJson) as Map<String, dynamic>;
      expect(railData['payment_rail'], equals('google_iap'));
      expect(railData['order_id'], equals('google_test_order_456'));
      expect(railData['validation_endpoint'], equals('/api/iap/google/validate'));
      expect(DateTime.parse(railData['expires_at']).isAfter(DateTime.now()), isTrue);
    });

    test('railType returns correct PaymentRail enum value', () {
      // Test that rail type is correctly identified
      expect(googleRail.railType, equals(PaymentRail.google_iap));
    });

    test('GooglePurchaseValidationResult.fromJson parses valid Google response', () {
      // Test parsing of successful Google purchase validation response
      final mockGoogleResponse = {
        'consumptionState': 0,
        'purchaseState': 0,
        'developerPayload': 'test_payload',
        'orderId': 'GPA.1234-5678-9012-34567',
        'purchaseTimeMillis': 1698386400000,
        'purchaseType': 0,
        'acknowledgementState': 1,
      };

      final result = GooglePurchaseValidationResult.fromJson(mockGoogleResponse);

      expect(result.consumptionState, equals(0));
      expect(result.purchaseState, equals(0));
      expect(result.developerPayload, equals('test_payload'));
      expect(result.orderId, equals('GPA.1234-5678-9012-34567'));
      expect(result.purchaseTimeMillis, equals(1698386400000));
      expect(result.purchaseType, equals(0));
      expect(result.acknowledgementState, equals(1));
      expect(result.isValid, isTrue);
      expect(result.isConsumed, isFalse);
      expect(result.isAcknowledged, isTrue);
      expect(result.errorMessage, equals('Purchase successful'));
    });

    test('GooglePurchaseValidationResult handles different purchase states', () {
      // Test parsing of different Google purchase states
      final purchaseStates = [0, 1, 2];
      final expectedMessages = [
        'Purchase successful',
        'Purchase was canceled',
        'Purchase is pending',
      ];
      final expectedValid = [true, false, false];

      for (int i = 0; i < purchaseStates.length; i++) {
        final mockResponse = {
          'consumptionState': 0,
          'purchaseState': purchaseStates[i],
          'orderId': 'GPA.test-$i',
        };

        final result = GooglePurchaseValidationResult.fromJson(mockResponse);

        expect(result.purchaseState, equals(purchaseStates[i]));
        expect(result.isValid, equals(expectedValid[i]));
        expect(result.errorMessage, equals(expectedMessages[i]));
      }
    });

    test('GooglePurchaseValidationResult handles consumption states', () {
      // Test consumption state detection
      final mockConsumedResponse = {
        'consumptionState': 1,
        'purchaseState': 0,
        'orderId': 'GPA.consumed-test',
      };

      final mockUnconsumedResponse = {
        'consumptionState': 0,
        'purchaseState': 0,
        'orderId': 'GPA.unconsumed-test',
      };

      final consumedResult = GooglePurchaseValidationResult.fromJson(mockConsumedResponse);
      final unconsumedResult = GooglePurchaseValidationResult.fromJson(mockUnconsumedResponse);

      expect(consumedResult.isConsumed, isTrue);
      expect(unconsumedResult.isConsumed, isFalse);
    });

    test('extractTransactionData extracts PII-free transaction details', () {
      // Test that transaction data extraction only includes non-PII information
      final mockPurchaseData = {
        'orderId': 'GPA.1234-5678-9012-34567',
        'productId': 'com.example.premium',
        'purchaseTimeMillis': 1698386400000,
        'purchaseState': 0,
        'consumptionState': 0,
        'developerPayload': 'test_payload',
        'purchaseType': 0,
        'acknowledgementState': 1,
      };

      final transactionData = GoogleIAPRail.extractTransactionData(mockPurchaseData);

      // Verify extracted data contains expected fields
      expect(transactionData['order_id'], equals('GPA.1234-5678-9012-34567'));
      expect(transactionData['product_id'], equals('com.example.premium'));
      expect(transactionData['purchase_time_millis'], equals(1698386400000));
      expect(transactionData['purchase_state'], equals(0));
      expect(transactionData['consumption_state'], equals(0));
      expect(transactionData['developer_payload'], equals('test_payload'));
      expect(transactionData['purchase_type'], equals(0));
      expect(transactionData['acknowledgement_state'], equals(1));

      // Verify no PII fields are included (order IDs and product info are not PII)
      expect(transactionData.keys, everyElement(isNot(contains('email'))));
      expect(transactionData.keys, everyElement(isNot(contains('name'))));
      expect(transactionData.keys, everyElement(isNot(contains('address'))));
    });

    test('processCallback handles Google webhook data', () async {
      // Test callback processing for Google webhooks
      final mockCallbackData = {
        'package_name': 'com.example.app',
        'product_id': 'com.example.premium',
        'purchase_token': 'mock_purchase_token',
        'order_id': 'webhook_test_order',
      };

      final result = await googleRail.processCallback(mockCallbackData);

      // Should return failure since we don't have configuration in test
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Google IAP callback processing failed'));
    });

    test('processCallback handles missing callback data', () async {
      // Test callback processing with missing required fields
      final mockCallbackData = {
        'package_name': 'com.example.app',
        'product_id': 'com.example.premium',
        // Missing purchase_token and order_id
      };

      final result = await googleRail.processCallback(mockCallbackData);

      expect(result.success, isFalse);
      expect(result.errorMessage, equals('Missing required fields in Google IAP callback'));
    });

    test('GoogleIAPConfig configuration detection', () {
      // Test configuration detection (will be false in test environment)
      expect(GoogleIAPConfig.isConfigured, isFalse);
      expect(GoogleIAPConfig.serviceAccountJson, isNull);
      expect(GoogleIAPConfig.serviceAccountPath, isNull);
    });

    test('GoogleIAPConfig validation throws exception when not configured', () {
      // Test that configuration validation throws appropriate exception
      expect(
        () => GoogleIAPConfig.validateConfiguration(),
        throwsA(isA<AnonAccredException>()),
      );
    });

    test('GoogleIAPConfig getAccessToken returns null when not configured', () async {
      // Test that access token retrieval returns null when not configured
      final accessToken = await GoogleIAPConfig.getAccessToken();
      expect(accessToken, isNull);
    });
  });
}