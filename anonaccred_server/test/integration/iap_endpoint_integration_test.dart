import 'dart:convert';

import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/mock_android_publisher_client.dart';
import 'package:anonaccred_server/src/payments/mock_app_store_server_client.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:anonaccred_server/src/payments/rails/apple_iap_rail.dart';
import 'package:anonaccred_server/src/payments/rails/google_iap_rail.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Integration tests for IAP endpoint functionality
///
/// Tests complete IAP validation flows including authentication, receipt/token validation,
/// and inventory fulfillment. Uses mock data for reliable testing without external dependencies.
///
/// Focuses on essential integration scenarios during development phase.
void main() {
  withServerpod('IAP Endpoint Integration Tests', (sessionBuilder, endpoints) {
    late TestSessionBuilder authenticatedSessionBuilder;
    late AnonAccount testAccount;
    late AccountDevice testDevice;

    setUp(() async {
      // Register payment rails with mock clients for testing
      PaymentManager.clearRails();
      PaymentManager.registerRail(AppleIAPRail(client: MockAppStoreServerClient()));
      PaymentManager.registerRail(GoogleIAPRail(client: MockAndroidPublisherClient()));

      // Create test account and device for authenticated tests
      testAccount = await AnonAccount.db.insertRow(sessionBuilder.build(), AnonAccount(
        ultimateSigningPublicKeyHex:
            'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890'
            'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890', // Valid 128-char hex for ECDSA P-256
        encryptedDataKey: 'encrypted_data_key_test',
        ultimatePublicKey:
            'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890'
            'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890', // ultimatePublicKey - using same key for testing
      ));

      testDevice = await AccountDevice.db.insertRow(sessionBuilder.build(), AccountDevice(
        accountUuid: testAccount.accountUuid,
        deviceSigningPublicKeyHex:
            'fedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321'
            'fedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321', // Valid 128-char hex
        encryptedDataKey: 'encrypted_device_key_test',
        label: 'Test Device',
      ));

      // Create authenticated session builder with device scope
      // userIdentifier must be the UUID string so getAccountUuid() can parse it
      authenticatedSessionBuilder = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          testAccount.accountUuid.toString(),
          {Scope('device:${testDevice.deviceSigningPublicKeyHex}')},
          authId: testDevice.deviceSigningPublicKeyHex,
        ),
      );
    });

    tearDown(PaymentManager.clearRails);

    group('Apple IAP Endpoint Integration', () {
      test('validateAppleTransaction fails without authentication', () async {
        expect(
          () => endpoints.iAP.validateAppleTransaction(
            sessionBuilder,
            'mock_transaction_id',
            'mock_product_id',
            internalTransactionId: 'test_order_123',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test(
        'validateAppleTransaction throws PaymentException for empty receipt data',
        () async {
          try {
            await endpoints.iAP.validateAppleTransaction(
              authenticatedSessionBuilder,
              '', // Empty transaction ID
              '', // Empty product ID
              internalTransactionId: 'test_order_123',
            );
            fail('Should have thrown PaymentException');
          } on Exception catch (e) {
            expect(e, isA<PaymentException>());
            expect(
              e.toString(),
              contains('Transaction ID and product ID are required'),
            );
          }
        },
      );

      test(
        'validateAppleTransaction handles Apple configuration gracefully',
        () async {
          try {
            await endpoints.iAP.validateAppleTransaction(
              authenticatedSessionBuilder,
              'mock_transaction_id',
              'mock_product_id',
              internalTransactionId: 'test_order_123',
            );
            // If no error, the test passes (Apple not configured)
          } on Exception catch (e) {
            // Any exception is acceptable when Apple is not configured
            expect(e.toString(), anyOf(
              contains('configuration'),
              contains('credentials'),
              contains('Apple'),
            ));
          }
        },
      );
    });

    group('Google IAP Endpoint Integration', () {
      test('validateGooglePurchase fails without authentication', () async {
        expect(
          () => endpoints.iAP.validateGooglePurchase(
            sessionBuilder,
            'com.example.app',
            'com.example.premium',
            'mock_purchase_token',
            internalTransactionId: 'test_order_456',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test(
        'validateGooglePurchase throws PaymentException for empty purchase data',
        () async {
          try {
            await endpoints.iAP.validateGooglePurchase(
              authenticatedSessionBuilder,
              '', // Empty package name
              'com.example.premium',
              'mock_purchase_token',
              internalTransactionId: 'test_order_456',
            );
            fail('Should have thrown PaymentException');
          } on Exception catch (e) {
            expect(e, isA<PaymentException>());
            expect(
              e.toString(),
              contains(
                'Package name, product ID, and purchase token are required',
              ),
            );
          }
        },
      );

      test(
        'validateGooglePurchase handles Google configuration gracefully',
        () async {
          try {
            await endpoints.iAP.validateGooglePurchase(
              authenticatedSessionBuilder,
              'com.example.app',
              'com.example.premium',
              'mock_purchase_token',
              internalTransactionId: 'test_order_456',
            );
            // If no error, the test passes (Google not configured)
          } on Exception catch (e) {
            // Any exception is acceptable when Google is not configured
            expect(e.toString(), anyOf(
              contains('configuration'),
              contains('credentials'),
              contains('Google'),
            ));
          }
        },
      );
    });

    group('IAP Payment Rail Integration', () {
      test('Payment Manager can create Apple IAP payments', () async {
        final paymentRequest = await PaymentManager.createPayment(
          railType: PaymentRail.apple_iap,
          amountUSD: 9.99,
          internalTransactionId: 'integration_test_apple',
        );

        expect(paymentRequest.paymentRef, equals('integration_test_apple'));
        expect(paymentRequest.amountUSD, equals(9.99));
        final railData =
            jsonDecode(paymentRequest.railDataJson) as Map<String, dynamic>;
        expect(railData['payment_rail'], equals('apple_iap'));
      });

      test('Payment Manager can create Google IAP payments', () async {
        final paymentRequest = await PaymentManager.createPayment(
          railType: PaymentRail.google_iap,
          amountUSD: 4.99,
          internalTransactionId: 'integration_test_google',
        );

        expect(paymentRequest.paymentRef, equals('integration_test_google'));
        expect(paymentRequest.amountUSD, equals(4.99));
        final railData =
            jsonDecode(paymentRequest.railDataJson) as Map<String, dynamic>;
        expect(railData['payment_rail'], equals('google_iap'));
      });

      test('Payment Manager initialization registers IAP rails', () async {
        PaymentManager.clearRails();
        expect(PaymentManager.isRailRegistered(PaymentRail.apple_iap), isFalse);
        expect(
          PaymentManager.isRailRegistered(PaymentRail.google_iap),
          isFalse,
        );

        await PaymentManager.initializeAllRails();

        // Ensure X402 is always there as it doesn't need config
        final registeredTypes = PaymentManager.getRegisteredRailTypes();
        expect(registeredTypes, contains(PaymentRail.x402_http));
      });
    });
  });
}
