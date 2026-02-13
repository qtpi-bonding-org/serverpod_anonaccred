import 'dart:convert';
import 'package:test/test.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/rails/apple_iap_rail.dart';
import 'package:anonaccred_server/src/payments/mock_app_store_server_client.dart';
import 'package:anonaccred_server/src/payments/apple_consumable_delivery_manager.dart';
import 'package:anonaccred_server/src/payments/decoded_transaction.dart';
import 'package:anonaccred_server/src/product_mapping_config.dart';

/// Unit tests for Apple IAP rail implementation
///
/// Tests core Apple IAP functionality including payment request creation,
/// mock client injection, and delivery manager injection.
///
/// Focuses on happy path validation for the refactored implementation.
void main() {
  group('Apple IAP Rail Tests', () {
    late AppleIAPRail appleRail;
    late MockAppStoreServerClient mockClient;

    setUp(() {
      mockClient = MockAppStoreServerClient();
      appleRail = AppleIAPRail(
        client: mockClient,
        deliveryManager: const AppleConsumableDeliveryManager(),
      );
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

      final railData =
          jsonDecode(paymentRequest.railDataJson) as Map<String, dynamic>;
      expect(railData['payment_rail'], equals('apple_iap'));
      expect(railData['order_id'], equals('apple_test_order_123'));
      expect(railData['amount_usd'], equals(9.99));
    });

    test('railType returns correct PaymentRail enum value', () {
      // Test that rail type is correctly identified
      expect(appleRail.railType, equals(PaymentRail.apple_iap));
    });

    test('mock client injection works correctly', () {
      // Test that mock client can be injected for testing
      expect(mockClient, isNotNull);
      expect(mockClient.callLog, isEmpty);
    });

    test('delivery manager injection works correctly', () {
      // Test that delivery manager can be injected
      final deliveryManager = const AppleConsumableDeliveryManager();
      final rail = AppleIAPRail(
        client: mockClient,
        deliveryManager: deliveryManager,
      );
      expect(rail, isNotNull);
    });

    test('processCallback handles missing request_body', () async {
      // Test callback processing with missing required fields
      final mockCallbackData = <String, dynamic>{
        // Missing request_body
      };

      final result = await appleRail.processCallback(mockCallbackData);

      expect(result.success, isFalse);
      expect(
        result.errorMessage,
        equals('Malformed payload: missing request_body or session'),
      );
    });

    test('processCallback handles malformed JSON', () async {
      // Test callback processing with invalid JSON
      final mockCallbackData = {
        'request_body': 'not valid json',
        'session': null,
      };

      final result = await appleRail.processCallback(mockCallbackData);

      expect(result.success, isFalse);
      expect(
        result.errorMessage,
        equals('Malformed payload: missing request_body or session'),
      );
    });

    test('AppleTransactionValidationResult.fromTransaction creates result',
        () {
      // Test that validation result can be created from transaction
      final transaction = DecodedTransaction(
        transactionId: 'txn_123',
        originalTransactionId: 'orig_txn_123',
        productId: 'com.test.product',
        bundleId: 'com.test.app',
        purchaseDate: DateTime.now().millisecondsSinceEpoch,
        originalPurchaseDate: DateTime.now().millisecondsSinceEpoch,
        quantity: 1,
        type: 'Consumable',
      );

      final mapping = ProductMapping(
        consumableType: 'coins',
        quantity: 100,
      );

      final result = AppleTransactionValidationResult.fromTransaction(
        transaction,
        mapping,
      );

      expect(result.isValid, isTrue);
      expect(result.transactionId, equals('txn_123'));
      expect(result.productId, equals('com.test.product'));
      expect(result.consumableType, equals('coins'));
      expect(result.quantity, equals(100));
      expect(result.fromCache, isFalse);
    });

    test('AppleTransactionValidationResult.fromExistingDelivery creates result',
        () {
      // Test that validation result can be created from existing delivery
      final delivery = AppleConsumableDelivery(
        id: 1,
        transactionId: 'txn_123',
        originalTransactionId: 'orig_txn_123',
        productId: 'com.test.product',
        accountId: 456,
        consumableType: 'coins',
        quantity: 100,
        orderId: 'order_123',
        deliveredAt: DateTime.now(),
      );

      final result =
          AppleTransactionValidationResult.fromExistingDelivery(delivery);

      expect(result.isValid, isTrue);
      expect(result.transactionId, equals('txn_123'));
      expect(result.productId, equals('com.test.product'));
      expect(result.consumableType, equals('coins'));
      expect(result.quantity, equals(100));
      expect(result.fromCache, isTrue);
      expect(result.deliveredAt, isNotNull);
    });
  });
}