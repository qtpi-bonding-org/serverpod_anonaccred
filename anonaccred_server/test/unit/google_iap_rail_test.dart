import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:anonaccount_server/src/crypto_utils.dart';
import 'package:anonaccred_server/src/exception_factory.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/mock_android_publisher_client.dart';
import 'package:anonaccred_server/src/payments/rails/google_iap_rail.dart';
import 'package:anonaccred_server/src/refund_manager.dart';
import 'package:crypto/crypto.dart';
import 'package:googleapis/androidpublisher/v3.dart' show ProductPurchase;
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

/// Unit tests for Google IAP rail implementation
///
/// Tests core Google IAP functionality including payment request creation,
/// purchase validation result parsing, and transaction data extraction.
///
/// Focuses on happy path validation and essential error cases during development.
void main() {
  group('Google IAP Rail Tests', () {
    late GoogleIAPRail googleRail;
    late MockAndroidPublisherClient mockClient;

    setUp(() {
      mockClient = MockAndroidPublisherClient();
      googleRail = GoogleIAPRail(client: mockClient);
    });

    test('createPayment returns valid PaymentRequest for Google IAP', () async {
      // Test happy path: creating payment request for Google IAP
      final paymentRequest = await googleRail.createPayment(
        amountUSD: 4.99,
        internalTransactionId: 'google_test_order_456',
      );

      expect(paymentRequest.paymentRef, equals('google_test_order_456'));
      expect(paymentRequest.amountUSD, equals(4.99));
      expect(
        paymentRequest.internalTransactionId,
        equals('google_test_order_456'),
      );

      final railData =
          jsonDecode(paymentRequest.railDataJson) as Map<String, dynamic>;
      expect(railData['payment_rail'], equals('google_iap'));
      expect(
        railData['internal_transaction_id'],
        equals('google_test_order_456'),
      );
      expect(
        railData['validation_endpoint'],
        equals('/api/iap/google/validate'),
      );
      expect(
        DateTime.parse(
          railData['expires_at'] as String,
        ).isAfter(DateTime.now()),
        isTrue,
      );
    });

    test('railType returns correct PaymentRail enum value', () {
      // Test that rail type is correctly identified
      expect(googleRail.railType, equals(PaymentRail.google_iap));
    });

    test(
      'GooglePurchaseValidationResult.fromJson parses valid Google response',
      () {
        // Test parsing of successful Google purchase validation response
        final mockGoogleResponse = {
          'consumptionState': 0,
          'purchaseState': 0,
          'developerPayload': 'test_payload',
          'internalTransactionId': 'GPA.1234-5678-9012-34567',
          'purchaseTimeMillis': 1698386400000,
          'purchaseType': 0,
          'acknowledgementState': 1,
        };

        final result = GooglePurchaseValidationResult.fromJson(
          mockGoogleResponse,
        );

        expect(result.consumptionState, equals(0));
        expect(result.purchaseState, equals(0));
        expect(result.developerPayload, equals('test_payload'));
        expect(
          result.internalTransactionId,
          equals('GPA.1234-5678-9012-34567'),
        );
        expect(result.purchaseTimeMillis, equals(1698386400000));
        expect(result.purchaseType, equals(0));
        expect(result.acknowledgementState, equals(1));
        expect(result.isValid, isTrue);
        expect(result.isConsumed, isFalse);
        expect(result.isAcknowledged, isTrue);
        expect(result.errorMessage, equals('Purchase successful'));
      },
    );

    test(
      'GooglePurchaseValidationResult handles different purchase states',
      () {
        // Test parsing of different Google purchase states
        final purchaseStates = [0, 1, 2];
        final expectedMessages = [
          'Purchase successful',
          'Purchase was canceled',
          'Purchase is pending',
        ];
        final expectedValid = [true, false, false];

        for (var i = 0; i < purchaseStates.length; i++) {
          final mockResponse = {
            'consumptionState': 0,
            'purchaseState': purchaseStates[i],
            'internalTransactionId': 'GPA.test-$i',
          };

          final result = GooglePurchaseValidationResult.fromJson(mockResponse);

          expect(result.purchaseState, equals(purchaseStates[i]));
          expect(result.isValid, equals(expectedValid[i]));
          expect(result.errorMessage, equals(expectedMessages[i]));
        }
      },
    );

    test('GooglePurchaseValidationResult handles consumption states', () {
      // Test consumption state detection
      final mockConsumedResponse = {
        'consumptionState': 1,
        'purchaseState': 0,
        'internalTransactionId': 'GPA.consumed-test',
      };

      final mockUnconsumedResponse = {
        'consumptionState': 0,
        'purchaseState': 0,
        'internalTransactionId': 'GPA.unconsumed-test',
      };

      final consumedResult = GooglePurchaseValidationResult.fromJson(
        mockConsumedResponse,
      );
      final unconsumedResult = GooglePurchaseValidationResult.fromJson(
        mockUnconsumedResponse,
      );

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

      final transactionData = GoogleIAPRail.extractTransactionData(
        mockPurchaseData,
      );

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

      // Should return failure since no signature/payload/session provided
      expect(result.success, isFalse);
      expect(
        result.errorMessage,
        contains('Missing webhook signature, payload, or session'),
      );
    });

    test('processCallback handles missing callback data', () async {
      // Test callback processing with missing required fields
      final mockCallbackData = {
        'package_name': 'com.example.app',
        'product_id': 'com.example.premium',
        // Missing signature, payload, and session
      };

      final result = await googleRail.processCallback(mockCallbackData);

      expect(result.success, isFalse);
      expect(
        result.errorMessage,
        equals('Missing webhook signature, payload, or session'),
      );
    });

    test(
      'GooglePurchaseValidationResult constructor with tag and quantity',
      () {
        final result = GooglePurchaseValidationResult(
          consumptionState: 0,
          purchaseState: 0,
          internalTransactionId: 'GPA.test-purchase',
          purchaseTimeMillis: 1698386400000,
          tag: 'sync_500mb_days',
          quantity: 32.0,
        );

        expect(result.purchaseState, equals(0));
        expect(result.internalTransactionId, equals('GPA.test-purchase'));
        expect(result.tag, equals('sync_500mb_days'));
        expect(result.quantity, equals(32.0));
        expect(result.isValid, isTrue);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Tests requiring a database session (withServerpod)
  // ---------------------------------------------------------------------------
  withServerpod('Google IAP Rail - validatePurchase', (
    sessionBuilder,
    endpoints,
  ) {
    late MockAndroidPublisherClient mockClient;
    late GoogleIAPRail googleRail;

    setUp(() {
      mockClient = MockAndroidPublisherClient();
      googleRail = GoogleIAPRail(client: mockClient);
    });

    group('error paths — no DB writes occur', () {
      test('throws when Google API returns ApiRequestError for unknown token',
          () async {
        final session = sessionBuilder.build();

        // mockClient throws ApiRequestError by default for unknown tokens
        await expectLater(
          googleRail.validatePurchase(
            session: session,
            packageName: 'com.quanitya.app',
            productId: 'com.quanitya.coins_100',
            purchaseToken: 'unknown_token_404',
            accountUuid: UuidValue.fromString(const Uuid().v4()),
          ),
          throwsA(isA<PaymentException>()),
        );

        expect(mockClient.callLog, hasLength(1));
        expect(mockClient.callLog.first.methodName, equals('getPurchase'));
      });

      test('throws when purchase is in canceled state (purchaseState=1)',
          () async {
        final session = sessionBuilder.build();
        const token = 'token_canceled_purchase';

        mockClient.addMockPurchase(
          token,
          ProductPurchase(purchaseState: 1, consumptionState: 0),
        );

        await expectLater(
          googleRail.validatePurchase(
            session: session,
            packageName: 'com.quanitya.app',
            productId: 'com.quanitya.coins_100',
            purchaseToken: token,
            accountUuid: UuidValue.fromString(const Uuid().v4()),
          ),
          throwsA(isA<PaymentException>()),
        );
      });

      test('throws when purchase is in pending state (purchaseState=2)',
          () async {
        final session = sessionBuilder.build();
        const token = 'token_pending_purchase';

        mockClient.addMockPurchase(
          token,
          ProductPurchase(purchaseState: 2, consumptionState: 0),
        );

        await expectLater(
          googleRail.validatePurchase(
            session: session,
            packageName: 'com.quanitya.app',
            productId: 'com.quanitya.coins_100',
            purchaseToken: token,
            accountUuid: UuidValue.fromString(const Uuid().v4()),
          ),
          throwsA(isA<PaymentException>()),
        );
      });

      test('throws when no RailProduct exists in DB for product ID',
          () async {
        final session = sessionBuilder.build();
        const token = 'token_no_mapping';
        const productId = 'com.quanitya.unmapped_product';

        // No RailProduct seeded in DB for this product ID
        mockClient.addMockPurchase(
          token,
          ProductPurchase(purchaseState: 0, consumptionState: 0),
        );

        await expectLater(
          googleRail.validatePurchase(
            session: session,
            packageName: 'com.quanitya.app',
            productId: productId,
            purchaseToken: token,
            accountUuid: UuidValue.fromString(const Uuid().v4()),
          ),
          throwsA(isA<AnonAccountException>()),
        );
      });
    });

    group('idempotency', () {
      test('returns fromCache=true when receipt hash already exists', () async {
        final session = sessionBuilder.build();
        const token = 'token_already_processed';

        // Pre-insert the hash as if this purchase was already delivered
        final hash = CryptoUtils.sha256Hash(token);
        await ReceiptHash.db.insertRow(
          session,
          ReceiptHash(hash: hash, paymentRail: PaymentRail.google_iap),
        );

        final result = await googleRail.validatePurchase(
          session: session,
          packageName: 'com.quanitya.app',
          productId: 'com.quanitya.coins_100',
          purchaseToken: token,
          accountUuid: UuidValue.fromString(const Uuid().v4()),
        );

        expect(result.isValid, isTrue);
        expect(result.fromCache, isTrue);
      });

      test('does not call Google API when receipt hash already exists',
          () async {
        final session = sessionBuilder.build();
        const token = 'token_cache_no_api_call';

        final hash = CryptoUtils.sha256Hash(token);
        await ReceiptHash.db.insertRow(
          session,
          ReceiptHash(hash: hash, paymentRail: PaymentRail.google_iap),
        );

        await googleRail.validatePurchase(
          session: session,
          packageName: 'com.quanitya.app',
          productId: 'com.quanitya.coins_100',
          purchaseToken: token,
          accountUuid: UuidValue.fromString(const Uuid().v4()),
        );

        expect(mockClient.callLog, isEmpty);
      });
    });

    group('purchaseTimeMillis parsing', () {
      test(
        'validatePurchase still delivers the purchase when purchaseTimeMillis '
        'is a non-numeric string',
        () async {
          final session = sessionBuilder.build();
          const token = 'token_malformed_purchase_time';
          const productId = 'com.quanitya.coins_malformed_time';

          final account = await AnonAccount.db.insertRow(
            session,
            AnonAccount(
              id: UuidValue.fromString(const Uuid().v4()),
              ultimateSigningPublicKeyHex: _randomHex(),
              encryptedDataKey: 'encrypted_data_key',
              ultimateEncryptionPublicKeyHex: _randomHex(),
            ),
          );

          final entitlement = await Entitlement.db.insertRow(
            session,
            Entitlement(
              tag: 'coins_malformed_time',
              name: 'Coins',
              type: EntitlementType.consumable,
              serverValidated: true,
            ),
          );

          final railProduct = await RailProduct.db.insertRow(
            session,
            RailProduct(
              rail: PaymentRail.google_iap,
              storeProductId: productId,
              isActive: true,
            ),
          );

          await RailProductGrant.db.insertRow(
            session,
            RailProductGrant(
              railProductId: railProduct.id!,
              entitlementId: entitlement.id!,
              quantity: 100,
            ),
          );

          mockClient.addMockPurchase(
            token,
            ProductPurchase(
              purchaseState: 0,
              consumptionState: 0,
              orderId: 'order_malformed_time',
              // Google's androidpublisher API types this field as a decimal
              // string. A malformed value here must not sink an otherwise
              // valid purchase.
              purchaseTimeMillis: 'not-a-number',
            ),
          );

          final result = await googleRail.validatePurchase(
            session: session,
            packageName: 'com.quanitya.app',
            productId: productId,
            purchaseToken: token,
            accountUuid: account.id!,
          );

          expect(result.isValid, isTrue);
        },
      );
    });

    group('async ack/consume failure logging', () {
      test(
        'does not fall back to print() when acknowledgePurchase fails',
        () async {
          final session = sessionBuilder.build();
          const token = 'token_ack_failure_logging';
          const productId = 'com.quanitya.coins_ack_failure';

          final account = await AnonAccount.db.insertRow(
            session,
            AnonAccount(
              id: UuidValue.fromString(const Uuid().v4()),
              ultimateSigningPublicKeyHex: _randomHex(),
              encryptedDataKey: 'encrypted_data_key',
              ultimateEncryptionPublicKeyHex: _randomHex(),
            ),
          );

          final entitlement = await Entitlement.db.insertRow(
            session,
            Entitlement(
              tag: 'coins_ack_failure',
              name: 'Coins',
              type: EntitlementType.consumable,
              serverValidated: true,
            ),
          );

          final railProduct = await RailProduct.db.insertRow(
            session,
            RailProduct(
              rail: PaymentRail.google_iap,
              storeProductId: productId,
              isActive: true,
            ),
          );

          await RailProductGrant.db.insertRow(
            session,
            RailProductGrant(
              railProductId: railProduct.id!,
              entitlementId: entitlement.id!,
              quantity: 100,
            ),
          );

          mockClient
            ..addMockPurchase(
              token,
              ProductPurchase(
                purchaseState: 0,
                consumptionState: 0,
                orderId: 'order_ack_failure',
              ),
            )
            ..acknowledgePurchaseError = Exception('transient network error');

          final capturedPrints = <String>[];

          await runZoned(
            () async {
              final result = await googleRail.validatePurchase(
                session: session,
                packageName: 'com.quanitya.app',
                productId: productId,
                purchaseToken: token,
                accountUuid: account.id!,
              );
              expect(result.isValid, isTrue);

              // Flush the microtask queue so the unawaited
              // _acknowledgePurchaseAsync call's catch block runs.
              await Future<void>.delayed(Duration.zero);
            },
            zoneSpecification: ZoneSpecification(
              print: (self, parent, zone, line) => capturedPrints.add(line),
            ),
          );

          expect(
            capturedPrints,
            isEmpty,
            reason:
                'acknowledgePurchase failures must go through session.log, '
                'not print()',
          );
        },
      );
    });
  });

  // ---------------------------------------------------------------------------
  // extractRefundEvent + refund webhook flow
  // ---------------------------------------------------------------------------
  group('Google IAP Rail - extractRefundEvent', () {
    late MockAndroidPublisherClient mockClient;
    late GoogleIAPRail googleRail;

    setUp(() {
      mockClient = MockAndroidPublisherClient();
      googleRail = GoogleIAPRail(client: mockClient);
      RefundManager.resetHandler();
    });

    tearDown(() {
      RefundManager.resetHandler();
    });

    test('extracts RefundEvent from valid notification data', () {
      const token = 'token_refund_extract';
      const orderId = 'GPA.order_refund_extract';

      final event = googleRail.extractRefundEvent({
        'purchase_token': token,
        'order_id': orderId,
        'product_id': 'com.quanitya.coins_100',
      });

      expect(event, isNotNull);
      expect(event!.rail, equals(PaymentRail.google_iap));
      expect(event.paymentRef, equals(orderId));
      expect(event.receiptHash, equals(CryptoUtils.sha256Hash(token)));
      expect(event.productId, equals('com.quanitya.coins_100'));
    });

    test('extracts RefundEvent with alternative key names', () {
      const token = 'token_refund_alt';
      const orderId = 'GPA.order_refund_alt';

      final event = googleRail.extractRefundEvent({
        'purchaseToken': token,
        'orderId': orderId,
      });

      expect(event, isNotNull);
      expect(event!.paymentRef, equals(orderId));
      expect(event.receiptHash, equals(CryptoUtils.sha256Hash(token)));
    });

    test('returns null when purchaseToken is missing', () {
      final event = googleRail.extractRefundEvent({
        'order_id': 'GPA.test',
      });
      expect(event, isNull);
    });

    test('returns null when orderId is missing', () {
      final event = googleRail.extractRefundEvent({
        'purchase_token': 'token_test',
      });
      expect(event, isNull);
    });

    test('returns null when both fields missing', () {
      final event = googleRail.extractRefundEvent(<String, dynamic>{});
      expect(event, isNull);
    });
  });

  withServerpod('Google IAP Rail - processCallback refund flow', (
    sessionBuilder,
    endpoints,
  ) {
    late MockAndroidPublisherClient mockClient;
    late GoogleIAPRail googleRail;

    setUp(() {
      mockClient = MockAndroidPublisherClient();
      googleRail = GoogleIAPRail(client: mockClient);
      RefundManager.resetHandler();
    });

    tearDown(() {
      RefundManager.resetHandler();
    });

    test(
        'processCallback rejects refund notification without webhook signature',
        () async {
      final session = sessionBuilder.build();
      const token = 'token_refund_callback';
      const orderId = 'GPA.order_refund_callback';

      // Pre-insert the hash
      final hash = CryptoUtils.sha256Hash(token);
      await ReceiptHash.db.insertRow(
        session,
        ReceiptHash(hash: hash, paymentRail: PaymentRail.google_iap),
      );

      // Without signature/payload, the callback should be rejected
      final result = await googleRail.processCallback({
        'notification_type': 'refund',
        'purchase_token': token,
        'order_id': orderId,
        'session': session,
      });

      expect(result.success, isFalse);
      expect(
        result.errorMessage,
        equals('Missing webhook signature, payload, or session'),
      );
    });

    test(
      'processCallback does not throw when a validated purchase carries a '
      'purchaseTimeMillis',
      () async {
        final session = sessionBuilder.build();
        const token = 'token_callback_timestamp';
        const payload = '{"notificationType":"SUBSCRIPTION_PURCHASED"}';
        final signingKey = Platform.environment['GOOGLE_WEBHOOK_SIGNING_KEY']!;
        final signature = Hmac(sha256, utf8.encode(signingKey))
            .convert(utf8.encode(payload))
            .toString();

        mockClient.addMockPurchase(
          token,
          ProductPurchase(
            purchaseState: 0,
            consumptionState: 0,
            orderId: 'order_callback_timestamp',
            purchaseTimeMillis: '1700000000000',
          ),
        );

        final result = await googleRail.processCallback({
          'package_name': 'com.quanitya.app',
          'product_id': 'com.quanitya.coins_100',
          'purchase_token': token,
          'order_id': 'order_callback_timestamp',
          'signature': signature,
          'payload': payload,
          'session': session,
        });

        expect(result.success, isTrue);
        expect(
          result.transactionTimestamp,
          equals(DateTime.fromMillisecondsSinceEpoch(1700000000000)),
        );
      },
      skip: Platform.environment['GOOGLE_WEBHOOK_SIGNING_KEY'] == null
          ? 'requires GOOGLE_WEBHOOK_SIGNING_KEY in the process environment '
              '(WebhookSignatureValidator reads it directly; run with '
              'GOOGLE_WEBHOOK_SIGNING_KEY=<any value> dart test to exercise '
              'this test)'
          : null,
    );
  });
}

String _randomHex() {
  final random = Random();
  final buffer = StringBuffer();
  for (var i = 0; i < 128; i++) {
    buffer.write(random.nextInt(16).toRadixString(16));
  }
  return buffer.toString();
}
