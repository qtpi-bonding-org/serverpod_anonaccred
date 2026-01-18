import 'dart:math';
import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart';
import 'package:anonaccred_server/src/generated/payment_rail.dart';
import 'package:anonaccred_server/src/generated/payment_request.dart';
import 'package:anonaccred_server/src/generated/payment_result.dart';
import 'package:anonaccred_server/src/payments/payment_rail_interface.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:anonaccred_server/src/generated/payment_exception.dart';

/// **Feature: anonaccred-phase4, Property 2: Payment Request Creation**
/// **Validates: Requirements 1.2, 3.1**

void main() {
  final random = Random();

  group('Payment Manager Property Tests', () {
    late MockSession mockSession;
    
    setUp(() {
      // Clear rails before each test to ensure clean state
      PaymentManager.clearRails();
      mockSession = MockSession();
    });

    test(
      'Property 2: Payment Request Creation - For any valid payment parameters, creating a payment through a registered rail should return a PaymentRequest with paymentRef, amountUSD, and orderId populated',
      () async {
        // Run 5 iterations during development (can be increased to 100+ for production)
        for (int i = 0; i < 5; i++) {
          // Generate random test data
          final railType = PaymentRail.values[random.nextInt(PaymentRail.values.length)];
          final amountUSD = (random.nextDouble() * 1000) + 0.01; // $0.01 to $1000
          final orderId = 'order_${random.nextInt(999999)}';
          
          // Register a mock rail
          final mockRail = MockPaymentRail(railType);
          PaymentManager.registerRail(mockRail);
          
          // Create payment through PaymentManager (Requirements 1.2, 3.1)
          final paymentRequest = await PaymentManager.createPayment(
            
            railType: railType,
            amountUSD: amountUSD,
            orderId: orderId,
          );
          
          // Verify PaymentRequest structure (Requirement 3.1)
          expect(paymentRequest.paymentRef, isNotEmpty);
          expect(paymentRequest.amountUSD, equals(amountUSD));
          expect(paymentRequest.orderId, equals(orderId));
          expect(paymentRequest.railDataJson, isNotEmpty);
          
          // Verify rail-specific data is preserved (Requirement 3.1)
          final railData = paymentRequest.railData;
          expect(railData, isNotEmpty);
          expect(railData['railType'], equals(railType.toString()));
          expect(railData['mockData'], equals('test_data'));
          expect(railData['timestamp'], isNotNull);
          
          // Verify payment reference format (Requirement 1.2)
          expect(paymentRequest.paymentRef, startsWith('mock_payment_ref_$orderId'));
        }
      },
    );

    test(
      'Property 2 Extension: Unsupported rail error handling',
      () async {
        // Clear all rails to ensure none are registered
        PaymentManager.clearRails();
        
        for (final railType in PaymentRail.values) {
          final amountUSD = 100.0;
          final orderId = 'order_test';
          
          // Attempt to create payment with unregistered rail (Requirement 2.3)
          expect(
            () async => await PaymentManager.createPayment(
              
              railType: railType,
              amountUSD: amountUSD,
              orderId: orderId,
            ),
            throwsA(isA<PaymentException>().having(
              (e) => e.code,
              'error code',
              equals('PAYMENT_INVALID_RAIL'),
            )),
          );
        }
      },
    );

    test(
      'Property 2 Extension: Multiple rails registration and routing',
      () async {
        // Register all available rails
        final registeredRails = <PaymentRail, MockPaymentRail>{};
        for (final railType in PaymentRail.values) {
          final mockRail = MockPaymentRail(railType);
          registeredRails[railType] = mockRail;
          PaymentManager.registerRail(mockRail);
        }
        
        // Test payment creation through each rail
        for (final railType in PaymentRail.values) {
          final amountUSD = (random.nextDouble() * 100) + 1.0;
          final orderId = 'order_${railType.name}_${random.nextInt(1000)}';
          
          final paymentRequest = await PaymentManager.createPayment(
            
            railType: railType,
            amountUSD: amountUSD,
            orderId: orderId,
          );
          
          // Verify correct rail was used
          expect(paymentRequest.railData['railType'], equals(railType.toString()));
          expect(paymentRequest.amountUSD, equals(amountUSD));
          expect(paymentRequest.orderId, equals(orderId));
        }
      },
    );

    test(
      'Property 2 Extension: Rail replacement behavior',
      () async {
        const railType = PaymentRail.x402_http;
        const amountUSD = 50.0;
        const orderId = 'order_replacement_test';
        
        // Register first rail
        final firstRail = MockPaymentRail(railType, customData: 'first_rail');
        PaymentManager.registerRail(firstRail);
        
        final firstPayment = await PaymentManager.createPayment(
          
          railType: railType,
          amountUSD: amountUSD,
          orderId: orderId,
        );
        
        expect(firstPayment.railData['customData'], equals('first_rail'));
        
        // Register second rail with same type (should replace)
        final secondRail = MockPaymentRail(railType, customData: 'second_rail');
        PaymentManager.registerRail(secondRail);
        
        final secondPayment = await PaymentManager.createPayment(
          
          railType: railType,
          amountUSD: amountUSD,
          orderId: orderId,
        );
        
        expect(secondPayment.railData['customData'], equals('second_rail'));
      },
    );

    test(
      'Property 2 Extension: Error handling for rail failures',
      () async {
        const railType = PaymentRail.monero;
        const amountUSD = 25.0;
        const orderId = 'order_error_test';
        
        // Register a rail that throws errors
        final errorRail = ErrorThrowingMockRail(railType);
        PaymentManager.registerRail(errorRail);
        
        // Verify that rail errors are wrapped in PaymentException
        expect(
          () async => await PaymentManager.createPayment(
            
            railType: railType,
            amountUSD: amountUSD,
            orderId: orderId,
          ),
          throwsA(isA<PaymentException>().having(
            (e) => e.code,
            'error code',
            equals('PAYMENT_FAILED'),
          )),
        );
      },
    );
  });
}

/// Mock implementation of PaymentRailInterface for testing
class MockPaymentRail implements PaymentRailInterface {
  final PaymentRail _railType;
  final String? customData;
  
  MockPaymentRail(this._railType, {this.customData});
  
  @override
  PaymentRail get railType => _railType;
  
  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String orderId,
  }) async {
    // Mock implementation for testing
    return PaymentRequestExtension.withRailData(
      paymentRef: 'mock_payment_ref_${orderId}_${DateTime.now().millisecondsSinceEpoch}',
      amountUSD: amountUSD,
      orderId: orderId,
      railData: {
        'railType': railType.toString(),
        'mockData': 'test_data',
        'timestamp': DateTime.now().toIso8601String(),
        if (customData != null) 'customData': customData!,
      },
    );
  }
  
  @override
  Future<PaymentResult> processCallback(Map<String, dynamic> callbackData) async {
    // Mock implementation for testing
    return PaymentResult(
      success: true,
      orderId: callbackData['orderId'] as String?,
      transactionTimestamp: DateTime.now(),
    );
  }
}

/// Mock rail that throws errors for testing error handling
class ErrorThrowingMockRail implements PaymentRailInterface {
  final PaymentRail _railType;
  
  ErrorThrowingMockRail(this._railType);
  
  @override
  PaymentRail get railType => _railType;
  
  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String orderId,
  }) async {
    throw Exception('Mock rail error for testing');
  }
  
  @override
  Future<PaymentResult> processCallback(Map<String, dynamic> callbackData) async {
    throw Exception('Mock callback error for testing');
  }
}
/// Mock Session for testing payment manager operations
class MockSession {
  final List<LogEntry> logEntries = [];
  
  void log(String message, {LogLevel? level, dynamic exception}) {
    logEntries.add(LogEntry(
      message: message,
      level: level ?? LogLevel.info,
      exception: exception,
    ));
  }
}

/// Log entry for tracking mock session logs
class LogEntry {
  final String message;
  final LogLevel level;
  final dynamic exception;
  
  LogEntry({
    required this.message,
    required this.level,
    this.exception,
  });
}