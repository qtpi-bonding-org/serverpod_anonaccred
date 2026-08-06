import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:anonaccount_server/src/crypto_utils.dart';
import 'package:anonaccred_server/src/exception_factory.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/google_pubsub_verifier.dart';
import 'package:anonaccred_server/src/payments/mock_android_publisher_client.dart';
import 'package:anonaccred_server/src/payments/rails/google_iap_rail.dart';
import 'package:anonaccred_server/src/refund_event.dart';
import 'package:anonaccred_server/src/refund_manager.dart';
import 'package:googleapis/androidpublisher/v3.dart' show ProductPurchase;
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../integration/test_tools/serverpod_test_tools.dart';
import '../test_helpers/google_test_oidc.dart';

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

    test('processCallback handles a callback missing the Pub/Sub envelope',
        () async {
      // Old flat snake_case fields are not part of Google's real RTDN
      // schema (a Cloud Pub/Sub push envelope) — a callback shaped like
      // this carries none of the required keys.
      final mockCallbackData = {
        'package_name': 'com.example.app',
        'product_id': 'com.example.premium',
        'purchase_token': 'mock_purchase_token',
        'order_id': 'webhook_test_order',
      };

      final result = await googleRail.processCallback(mockCallbackData);

      expect(result.success, isFalse);
      expect(
        result.errorMessage,
        contains(
          'Missing authorization_header, request_body, expected_audience, or session',
        ),
      );
    });

    test('processCallback handles missing callback data', () async {
      final mockCallbackData = {
        'package_name': 'com.example.app',
        'product_id': 'com.example.premium',
        // Missing authorization_header, request_body, expected_audience, session
      };

      final result = await googleRail.processCallback(mockCallbackData);

      expect(result.success, isFalse);
      expect(
        result.errorMessage,
        equals(
          'Missing authorization_header, request_body, expected_audience, or session',
        ),
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
      test(
        'rejects a package name outside GOOGLE_PACKAGE_NAME before API access',
        () async {
          final session = sessionBuilder.build();

          await expectLater(
            googleRail.validatePurchase(
              session: session,
              packageName: 'com.someone.else',
              productId: 'com.quanitya.coins_100',
              purchaseToken: 'token_wrong_package',
              accountUuid: UuidValue.fromString(const Uuid().v4()),
            ),
            throwsA(isA<PaymentException>()),
          );
          expect(mockClient.callLog, isEmpty);
        },
        skip: Platform.environment['GOOGLE_PACKAGE_NAME'] == null
            ? 'requires GOOGLE_PACKAGE_NAME'
            : null,
      );

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
        expect(mockClient.callLog.first.method, equals('getPurchase'));
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
          throwsA(isA<PaymentException>()),
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

    test('extracts RefundEvent from a voidedPurchaseNotification map', () {
      const token = 'token_refund_extract';
      const orderId = 'GPA.order_refund_extract';

      final event = googleRail.extractRefundEvent({
        'purchaseToken': token,
        'orderId': orderId,
        'productType': 1,
        'refundType': 1,
      });

      expect(event, isNotNull);
      expect(event!.rail, equals(PaymentRail.google_iap));
      expect(event.paymentRef, equals(orderId));
      expect(event.receiptHash, equals(CryptoUtils.sha256Hash(token)));
      // Google's VoidedPurchaseNotification carries no product identifier —
      // unlike the old fictional flat schema, there is no productId to read.
      expect(event.productId, isNull);
    });

    test(
        'extracts RefundEvent from a subscriptionNotification map, falling '
        'back to subscriptionId since it carries no orderId', () {
      const token = 'token_sub_extract';
      const subscriptionId = 'sub-plan-1';

      final event = googleRail.extractRefundEvent({
        'purchaseToken': token,
        'subscriptionId': subscriptionId,
        'notificationType': 12,
      });

      expect(event, isNotNull);
      expect(event!.paymentRef, equals(subscriptionId));
      expect(event.receiptHash, equals(CryptoUtils.sha256Hash(token)));
    });

    test('returns null when purchaseToken is missing', () {
      final event = googleRail.extractRefundEvent({
        'orderId': 'GPA.test',
      });
      expect(event, isNull);
    });

    test('returns null when both orderId and subscriptionId are missing', () {
      final event = googleRail.extractRefundEvent({
        'purchaseToken': 'token_test',
      });
      expect(event, isNull);
    });

    test('returns null when all fields missing', () {
      final event = googleRail.extractRefundEvent(<String, dynamic>{});
      expect(event, isNull);
    });
  });

  withServerpod('Google IAP Rail - processCallback Pub/Sub verification', (
    sessionBuilder,
    endpoints,
  ) {
    late MockAndroidPublisherClient mockClient;
    late GoogleIAPRail googleRail;
    const audience = 'https://example.com/hooks/google';

    setUp(() async {
      mockClient = MockAndroidPublisherClient();
      googleRail = GoogleIAPRail(client: mockClient);
      RefundManager.resetHandler();
      GooglePubSubVerifier.certsUriOverride = await GoogleTestOidc.certsUri;
    });

    tearDown(() {
      RefundManager.resetHandler();
      GooglePubSubVerifier.certsUriOverride = null;
    });

    String envelopeFor(Map<String, dynamic> notification) => jsonEncode({
          'message': {
            'data': base64.encode(utf8.encode(jsonEncode(notification))),
            'messageId': 'm-1',
          },
          'subscription': 'projects/p/subscriptions/s',
        });

    test(
        'processCallback rejects a request missing the authorization header',
        () async {
      final session = sessionBuilder.build();

      final result = await googleRail.processCallback({
        'request_body': envelopeFor({
          'packageName': 'com.quanitya.app',
          'eventTimeMillis': '1700000000000',
        }),
        'expected_audience': audience,
        'session': session,
      });

      expect(result.success, isFalse);
      expect(
        result.errorMessage,
        equals(
          'Missing authorization_header, request_body, expected_audience, or session',
        ),
      );
    });

    test('processCallback rejects an OIDC token with the wrong audience',
        () async {
      final session = sessionBuilder.build();
      final token = GoogleTestOidc.signToken(audience: 'https://wrong.example.com');

      final result = await googleRail.processCallback({
        'authorization_header': 'Bearer $token',
        'request_body': envelopeFor({
          'packageName': 'com.quanitya.app',
          'eventTimeMillis': '1700000000000',
        }),
        'expected_audience': audience,
        'session': session,
      });

      expect(result.success, isFalse);
      expect(result.errorMessage, equals('Invalid webhook signature'));
    });

    test(
        'processCallback routes a voidedPurchaseNotification to RefundManager',
        () async {
      final session = sessionBuilder.build();
      const token = 'token_refund_callback';
      const orderId = 'GPA.order_refund_callback';

      final hash = CryptoUtils.sha256Hash(token);
      await ReceiptHash.db.insertRow(
        session,
        ReceiptHash(hash: hash, paymentRail: PaymentRail.google_iap),
      );

      RefundEvent? capturedEvent;
      RefundManager.onRefund((s, event, context) async {
        capturedEvent = event;
        return RefundAction.ignore;
      });

      final oidcToken = GoogleTestOidc.signToken(audience: audience);
      final result = await googleRail.processCallback({
        'authorization_header': 'Bearer $oidcToken',
        'request_body': envelopeFor({
          'packageName': 'com.quanitya.app',
          'eventTimeMillis': '1700000000000',
          'voidedPurchaseNotification': {
            'purchaseToken': token,
            'orderId': orderId,
            'productType': 2,
            'refundType': 1,
          },
        }),
        'expected_audience': audience,
        'session': session,
      });

      expect(result.success, isTrue);
      expect(result.internalTransactionId, equals(orderId));
      expect(capturedEvent, isNotNull);
      expect(capturedEvent!.paymentRef, equals(orderId));
      expect(capturedEvent!.receiptHash, equals(hash));
    });

    test(
        'processCallback acknowledges a SUBSCRIPTION_PURCHASED notification '
        'without touching RefundManager', () async {
      final session = sessionBuilder.build();
      var refundCalled = false;
      RefundManager.onRefund((s, event, context) async {
        refundCalled = true;
        return RefundAction.ignore;
      });

      final oidcToken = GoogleTestOidc.signToken(audience: audience);
      final result = await googleRail.processCallback({
        'authorization_header': 'Bearer $oidcToken',
        'request_body': envelopeFor({
          'packageName': 'com.quanitya.app',
          'eventTimeMillis': '1700000000000',
          'subscriptionNotification': {
            'version': '1.0',
            'notificationType': 4, // SUBSCRIPTION_PURCHASED
            'purchaseToken': 'sub-token',
            'subscriptionId': 'sub-1',
          },
        }),
        'expected_audience': audience,
        'session': session,
      });

      expect(result.success, isTrue);
      expect(refundCalled, isFalse);
    });

    test(
        'processCallback acknowledges a SUBSCRIPTION_CANCELED notification '
        'without touching RefundManager (a cancellation still runs to the '
        'end of the paid period — it is not a revocation)', () async {
      final session = sessionBuilder.build();
      var refundCalled = false;
      RefundManager.onRefund((s, event, context) async {
        refundCalled = true;
        return RefundAction.ignore;
      });

      final oidcToken = GoogleTestOidc.signToken(audience: audience);
      final result = await googleRail.processCallback({
        'authorization_header': 'Bearer $oidcToken',
        'request_body': envelopeFor({
          'packageName': 'com.quanitya.app',
          'eventTimeMillis': '1700000000000',
          'subscriptionNotification': {
            'version': '1.0',
            'notificationType': 3, // SUBSCRIPTION_CANCELED
            'purchaseToken': 'sub-token-cancel',
            'subscriptionId': 'sub-2',
          },
        }),
        'expected_audience': audience,
        'session': session,
      });

      expect(result.success, isTrue);
      expect(refundCalled, isFalse);
    });

    test(
        'processCallback routes a SUBSCRIPTION_REVOKED notification to '
        'RefundManager', () async {
      final session = sessionBuilder.build();
      const token = 'token_sub_revoked';
      const subscriptionId = 'sub-revoked-1';

      final hash = CryptoUtils.sha256Hash(token);
      await ReceiptHash.db.insertRow(
        session,
        ReceiptHash(hash: hash, paymentRail: PaymentRail.google_iap),
      );

      RefundEvent? capturedEvent;
      RefundManager.onRefund((s, event, context) async {
        capturedEvent = event;
        return RefundAction.ignore;
      });

      final oidcToken = GoogleTestOidc.signToken(audience: audience);
      final result = await googleRail.processCallback({
        'authorization_header': 'Bearer $oidcToken',
        'request_body': envelopeFor({
          'packageName': 'com.quanitya.app',
          'eventTimeMillis': '1700000000000',
          'subscriptionNotification': {
            'version': '1.0',
            'notificationType': 12, // SUBSCRIPTION_REVOKED
            'purchaseToken': token,
            'subscriptionId': subscriptionId,
          },
        }),
        'expected_audience': audience,
        'session': session,
      });

      expect(result.success, isTrue);
      expect(result.internalTransactionId, equals(subscriptionId));
      expect(capturedEvent, isNotNull);
      expect(capturedEvent!.paymentRef, equals(subscriptionId));
      expect(capturedEvent!.receiptHash, equals(hash));
    });
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
