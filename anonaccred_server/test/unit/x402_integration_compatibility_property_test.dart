import 'dart:math';
import 'package:test/test.dart';
import 'package:anonaccred_server/src/generated/payment_rail.dart';
import 'package:anonaccred_server/src/generated/payment_request.dart';
import 'package:anonaccred_server/src/generated/payment_result.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:anonaccred_server/src/payments/payment_rail_interface.dart';
import 'package:anonaccred_server/src/payments/x402_payment_rail.dart';

/// **Feature: anonaccred-phase5, Property 6: Integration Compatibility**
/// **Validates: Requirements 3.1, 3.2, 3.3**

void main() {
  final random = Random();

  group('X402 Integration Compatibility Property Tests', () {
    setUp(() {
      // Clear rails before each test to ensure clean state
      PaymentManager.clearRails();
    });

    test(
      'Property 6: Integration Compatibility - For any X402 payment operation, the system should integrate with existing AnonAccred payment patterns',
      () async {
        // Run 5 iterations during development (can be increased to 100+ for production)
        for (int i = 0; i < 5; i++) {
          // Generate random test data
          final amountUSD =
              (random.nextDouble() * 1000) + 0.01; // $0.01 to $1000
          final orderId = 'order_${random.nextInt(999999)}';

          // Test X402 rail registration with PaymentManager (Requirement 3.1)
          final x402Rail = X402PaymentRail();
          PaymentManager.registerRail(x402Rail);

          // Verify X402 rail is registered and retrievable
          final retrievedRail = PaymentManager.getRail(PaymentRail.x402_http);
          expect(retrievedRail, isNotNull);
          expect(retrievedRail!.railType, equals(PaymentRail.x402_http));
          expect(retrievedRail, same(x402Rail));

          // Test X402 payment creation through PaymentManager (Requirement 3.2)
          final paymentRequest = await PaymentManager.createPayment(
            railType: PaymentRail.x402_http,
            amountUSD: amountUSD,
            orderId: orderId,
          );

          // Verify PaymentRequest follows existing AnonAccred patterns (Requirement 3.2)
          expect(paymentRequest.paymentRef, isNotEmpty);
          expect(paymentRequest.paymentRef, startsWith('x402_'));
          expect(paymentRequest.amountUSD, equals(amountUSD));
          expect(paymentRequest.orderId, equals(orderId));
          expect(paymentRequest.railDataJson, isNotEmpty);

          // Verify X402-specific rail data follows existing patterns (Requirement 3.3)
          final railData = paymentRequest.railData;
          expect(railData, isNotEmpty);
          expect(railData['facilitatorUrl'], isA<String>());
          expect(railData['destinationAddress'], isA<String>());
          expect(railData['amount'], equals(amountUSD.toString()));
          expect(railData['currency'], equals('USD'));
          expect(railData['orderId'], equals(orderId));
          expect(railData['protocol'], equals('x402'));
          expect(railData['timestamp'], isA<String>());

          // Test X402 callback processing follows existing patterns (Requirement 3.3)
          final callbackData = {
            'paymentRef': paymentRequest.paymentRef,
            'orderId': orderId,
            'success': random.nextBool(),
          };

          final paymentResult = await x402Rail.processCallback(callbackData);

          // Verify PaymentResult follows existing AnonAccred patterns
          expect(paymentResult.orderId, equals(orderId));
          expect(paymentResult.success, equals(callbackData['success']));

          if (paymentResult.success) {
            expect(paymentResult.transactionTimestamp, isNotNull);
            expect(paymentResult.transactionTimestamp, isNotNull);
            expect(paymentResult.errorMessage, isNull);
          } else {
            expect(paymentResult.transactionTimestamp, isNull);
            expect(paymentResult.errorMessage, isNotNull);
          }
        }
      },
    );

    test(
      'Property 6 Extension: X402 rail coexists with other payment rails',
      () async {
        // Register X402 rail alongside mock rails for other payment types
        final x402Rail = X402PaymentRail();
        final mockMoneroRail = MockPaymentRail(PaymentRail.monero);
        final mockIapRail = MockPaymentRail(PaymentRail.apple_iap);

        PaymentManager.registerRail(x402Rail);
        PaymentManager.registerRail(mockMoneroRail);
        PaymentManager.registerRail(mockIapRail);

        // Verify all rails are registered
        expect(PaymentManager.isRailRegistered(PaymentRail.x402_http), isTrue);
        expect(PaymentManager.isRailRegistered(PaymentRail.monero), isTrue);
        expect(PaymentManager.isRailRegistered(PaymentRail.apple_iap), isTrue);
        expect(PaymentManager.getRegisteredRailTypes().length, equals(3));

        // Test payment creation through each rail
        for (final railType in [
          PaymentRail.x402_http,
          PaymentRail.monero,
          PaymentRail.apple_iap,
        ]) {
          final amountUSD = (random.nextDouble() * 100) + 1.0;
          final orderId = 'order_${railType.name}_${random.nextInt(1000)}';

          final paymentRequest = await PaymentManager.createPayment(
            railType: railType,
            amountUSD: amountUSD,
            orderId: orderId,
          );

          // Verify correct rail was used and follows patterns
          expect(paymentRequest.amountUSD, equals(amountUSD));
          expect(paymentRequest.orderId, equals(orderId));
          expect(paymentRequest.railDataJson, isNotEmpty);

          // Verify rail-specific payment reference patterns
          if (railType == PaymentRail.x402_http) {
            expect(paymentRequest.paymentRef, startsWith('x402_'));
          } else {
            expect(paymentRequest.paymentRef, startsWith('mock_payment_ref_'));
          }
        }
      },
    );

    test(
      'Property 6 Extension: X402 error handling follows existing patterns',
      () async {
        final x402Rail = X402PaymentRail();
        PaymentManager.registerRail(x402Rail);

        // Test callback with missing required fields (should throw PaymentException)
        final invalidCallbackData = {
          'success': true,
          // Missing paymentRef and orderId
        };

        expect(
          () async => await x402Rail.processCallback(invalidCallbackData),
          throwsA(isA<Exception>()),
        );

        // Test callback with valid structure but failure
        final failureCallbackData = {
          'paymentRef': 'x402_test_ref',
          'orderId': 'test_order_123',
          'success': false,
        };

        final failureResult = await x402Rail.processCallback(
          failureCallbackData,
        );
        expect(failureResult.success, isFalse);
        expect(failureResult.orderId, equals('test_order_123'));
        expect(failureResult.transactionTimestamp, isNull);
        expect(failureResult.errorMessage, isNotNull);
      },
    );

    test(
      'Property 6 Extension: X402 PaymentRequest serialization compatibility',
      () async {
        final x402Rail = X402PaymentRail();
        PaymentManager.registerRail(x402Rail);

        for (int i = 0; i < 5; i++) {
          final amountUSD = (random.nextDouble() * 100) + 1.0;
          final orderId = 'serialization_test_${random.nextInt(1000)}';

          // Create payment request
          final originalRequest = await x402Rail.createPayment(
            amountUSD: amountUSD,
            orderId: orderId,
          );

          // Test serialization round trip using existing extension
          final railData = originalRequest.railData;
          final recreatedRequest = PaymentRequestExtension.withRailData(
            paymentRef: originalRequest.paymentRef,
            amountUSD: originalRequest.amountUSD,
            orderId: originalRequest.orderId,
            railData: railData,
          );

          // Verify round trip preserves all data
          expect(
            recreatedRequest.paymentRef,
            equals(originalRequest.paymentRef),
          );
          expect(recreatedRequest.amountUSD, equals(originalRequest.amountUSD));
          expect(recreatedRequest.orderId, equals(originalRequest.orderId));
          expect(recreatedRequest.railData, equals(railData));

          // Verify X402-specific data is preserved
          expect(recreatedRequest.railData['protocol'], equals('x402'));
          expect(recreatedRequest.railData['facilitatorUrl'], isA<String>());
          expect(
            recreatedRequest.railData['destinationAddress'],
            isA<String>(),
          );
        }
      },
    );

    test(
      'Property 6 Extension: X402 initialization follows existing patterns',
      () async {
        // Clear rails to test initialization
        PaymentManager.clearRails();
        expect(PaymentManager.isRailRegistered(PaymentRail.x402_http), isFalse);

        // Test X402 initialization method
        PaymentManager.initializeX402Rail();

        // Verify X402 rail is registered after initialization
        expect(PaymentManager.isRailRegistered(PaymentRail.x402_http), isTrue);

        final retrievedRail = PaymentManager.getRail(PaymentRail.x402_http);
        expect(retrievedRail, isNotNull);
        expect(retrievedRail!.railType, equals(PaymentRail.x402_http));
        expect(retrievedRail, isA<X402PaymentRail>());

        // Test idempotent initialization (calling again should not cause issues)
        PaymentManager.initializeX402Rail();
        expect(PaymentManager.isRailRegistered(PaymentRail.x402_http), isTrue);
        expect(PaymentManager.getRegisteredRailTypes().length, equals(1));
      },
    );
  });
}

/// Mock implementation of PaymentRailInterface for testing compatibility
class MockPaymentRail implements PaymentRailInterface {
  final PaymentRail _railType;

  MockPaymentRail(this._railType);

  @override
  PaymentRail get railType => _railType;

  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String orderId,
  }) async {
    return PaymentRequestExtension.withRailData(
      paymentRef:
          'mock_payment_ref_${orderId}_${DateTime.now().millisecondsSinceEpoch}',
      amountUSD: amountUSD,
      orderId: orderId,
      railData: {
        'railType': railType.toString(),
        'mockData': 'test_data',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Future<PaymentResult> processCallback(
    Map<String, dynamic> callbackData,
  ) async {
    return PaymentResult(
      success: true,
      orderId: callbackData['orderId'] as String?,
      transactionTimestamp: DateTime.now(),
    );
  }
}
