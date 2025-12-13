import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart';
import 'package:anonaccred_server/src/generated/payment_exception.dart';
import 'package:anonaccred_server/src/generated/payment_rail.dart';
import 'package:anonaccred_server/src/generated/payment_request.dart';
import 'package:anonaccred_server/src/generated/payment_result.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:anonaccred_server/src/payments/payment_rail_interface.dart';

/// Unit tests for PaymentManager operations
/// Tests rail registration, retrieval, payment creation routing, and error handling
/// Requirements: 2.1, 2.2, 2.3

void main() {
  group('PaymentManager Unit Tests', () {
    late MockSession mockSession;
    
    setUp(() {
      // Clear rails before each test to ensure clean state
      PaymentManager.clearRails();
      mockSession = MockSession();
    });

    group('Rail Registration and Retrieval', () {
      test('should register and retrieve payment rails correctly', () {
        // Test rail registration (Requirement 2.1)
        final mockRail = MockPaymentRail(PaymentRail.x402_http);
        PaymentManager.registerRail(mockRail);
        
        // Test rail retrieval (Requirement 2.2)
        final retrievedRail = PaymentManager.getRail(PaymentRail.x402_http);
        expect(retrievedRail, equals(mockRail));
        expect(retrievedRail?.railType, equals(PaymentRail.x402_http));
      });

      test('should return null for unregistered rail types', () {
        // Test retrieval of unregistered rail
        final retrievedRail = PaymentManager.getRail(PaymentRail.monero);
        expect(retrievedRail, isNull);
      });

      test('should replace existing rail when registering same type', () {
        // Register first rail
        final firstRail = MockPaymentRail(PaymentRail.x402_http);
        PaymentManager.registerRail(firstRail);
        
        // Register second rail with same type
        final secondRail = MockPaymentRail(PaymentRail.x402_http);
        PaymentManager.registerRail(secondRail);
        
        // Should retrieve the second rail
        final retrievedRail = PaymentManager.getRail(PaymentRail.x402_http);
        expect(retrievedRail, equals(secondRail));
        expect(retrievedRail, isNot(equals(firstRail)));
      });

      test('should track registered rail types correctly', () {
        // Register multiple rails
        PaymentManager.registerRail(MockPaymentRail(PaymentRail.x402_http));
        PaymentManager.registerRail(MockPaymentRail(PaymentRail.monero));
        
        final registeredTypes = PaymentManager.getRegisteredRailTypes();
        expect(registeredTypes, hasLength(2));
        expect(registeredTypes, contains(PaymentRail.x402_http));
        expect(registeredTypes, contains(PaymentRail.monero));
      });

      test('should check rail registration status correctly', () {
        // Initially no rails registered
        expect(PaymentManager.isRailRegistered(PaymentRail.x402_http), isFalse);
        
        // Register a rail
        PaymentManager.registerRail(MockPaymentRail(PaymentRail.x402_http));
        expect(PaymentManager.isRailRegistered(PaymentRail.x402_http), isTrue);
        expect(PaymentManager.isRailRegistered(PaymentRail.monero), isFalse);
      });
    });

    group('Payment Creation Routing', () {
      test('should route payment creation to correct rail', () async {
        // Register mock rail
        final mockRail = MockPaymentRail(PaymentRail.x402_http);
        PaymentManager.registerRail(mockRail);
        
        // Create payment through manager (Requirement 2.2)
        const amountUSD = 100.0;
        const orderId = 'test_order_123';
        
        final paymentRequest = await PaymentManager.createPayment(
          railType: PaymentRail.x402_http,
          amountUSD: amountUSD,
          orderId: orderId,
        );
        
        // Verify payment request structure
        expect(paymentRequest.amountUSD, equals(amountUSD));
        expect(paymentRequest.orderId, equals(orderId));
        expect(paymentRequest.paymentRef, isNotEmpty);
        expect(paymentRequest.railData, isNotEmpty);
        
        // Verify mock rail was called
        expect(mockRail.createPaymentCallCount, equals(1));
        expect(mockRail.lastAmountUSD, equals(amountUSD));
        expect(mockRail.lastOrderId, equals(orderId));
      });

      test('should handle multiple rails correctly', () async {
        // Register multiple rails
        final x402Rail = MockPaymentRail(PaymentRail.x402_http);
        final moneroRail = MockPaymentRail(PaymentRail.monero);
        
        PaymentManager.registerRail(x402Rail);
        PaymentManager.registerRail(moneroRail);
        
        // Create payments through different rails
        await PaymentManager.createPayment(
          
          railType: PaymentRail.x402_http,
          amountUSD: 50.0,
          orderId: 'x402_order',
        );
        
        await PaymentManager.createPayment(
          
          railType: PaymentRail.monero,
          amountUSD: 75.0,
          orderId: 'monero_order',
        );
        
        // Verify correct rails were called
        expect(x402Rail.createPaymentCallCount, equals(1));
        expect(x402Rail.lastOrderId, equals('x402_order'));
        
        expect(moneroRail.createPaymentCallCount, equals(1));
        expect(moneroRail.lastOrderId, equals('monero_order'));
      });
    });

    group('Error Handling for Unsupported Rails', () {
      test('should throw PaymentException for unsupported rail type', () async {
        // Ensure no rails are registered
        PaymentManager.clearRails();
        
        // Attempt to create payment with unsupported rail (Requirement 2.3)
        expect(
          () async => await PaymentManager.createPayment(
            
            railType: PaymentRail.x402_http,
            amountUSD: 100.0,
            orderId: 'test_order',
          ),
          throwsA(isA<PaymentException>().having(
            (e) => e.code,
            'error code',
            equals('PAYMENT_INVALID_RAIL'),
          )),
        );
      });

      test('should include helpful error details for unsupported rails', () async {
        // Register one rail but try to use another
        PaymentManager.registerRail(MockPaymentRail(PaymentRail.x402_http));
        
        try {
          await PaymentManager.createPayment(
            
            railType: PaymentRail.monero,
            amountUSD: 100.0,
            orderId: 'test_order',
          );
          fail('Expected PaymentException to be thrown');
        } catch (e) {
          expect(e, isA<PaymentException>());
          final paymentException = e as PaymentException;
          
          expect(paymentException.code, equals('PAYMENT_INVALID_RAIL'));
          expect(paymentException.orderId, equals('test_order'));
          expect(paymentException.paymentRail, equals('monero'));
          expect(paymentException.details?['requestedRail'], equals('monero'));
          expect(paymentException.details?['availableRails'], contains('x402_http'));
        }
      });

      test('should wrap rail creation errors in PaymentException', () async {
        // Register error-throwing rail
        final errorRail = ErrorThrowingMockRail(PaymentRail.x402_http);
        PaymentManager.registerRail(errorRail);
        
        // Attempt payment creation
        expect(
          () async => await PaymentManager.createPayment(
            
            railType: PaymentRail.x402_http,
            amountUSD: 100.0,
            orderId: 'error_test_order',
          ),
          throwsA(isA<PaymentException>().having(
            (e) => e.code,
            'error code',
            equals('PAYMENT_FAILED'),
          )),
        );
      });

      test('should wrap PaymentException from rails in new PaymentException', () async {
        // Register rail that throws PaymentException
        final paymentExceptionRail = PaymentExceptionThrowingMockRail(PaymentRail.x402_http);
        PaymentManager.registerRail(paymentExceptionRail);
        
        try {
          await PaymentManager.createPayment(
            
            railType: PaymentRail.x402_http,
            amountUSD: 100.0,
            orderId: 'payment_exception_test',
          );
          fail('Expected PaymentException to be thrown');
        } catch (e) {
          expect(e, isA<PaymentException>());
          final paymentException = e as PaymentException;
          
          // PaymentManager wraps all exceptions, even PaymentExceptions
          expect(paymentException.code, equals('PAYMENT_FAILED'));
          expect(paymentException.message, contains('Payment creation failed'));
          expect(paymentException.message, contains('Rail-specific payment error'));
        }
      });
    });

    group('Utility Methods', () {
      test('should clear all rails correctly', () {
        // Register some rails
        PaymentManager.registerRail(MockPaymentRail(PaymentRail.x402_http));
        PaymentManager.registerRail(MockPaymentRail(PaymentRail.monero));
        
        expect(PaymentManager.getRegisteredRailTypes(), hasLength(2));
        
        // Clear rails
        PaymentManager.clearRails();
        
        expect(PaymentManager.getRegisteredRailTypes(), isEmpty);
        expect(PaymentManager.getRail(PaymentRail.x402_http), isNull);
        expect(PaymentManager.getRail(PaymentRail.monero), isNull);
      });
    });
  });
}

/// Mock implementation of PaymentRailInterface for testing
class MockPaymentRail implements PaymentRailInterface {
  final PaymentRail _railType;
  int createPaymentCallCount = 0;
  int processCallbackCallCount = 0;
  double? lastAmountUSD;
  String? lastOrderId;
  
  MockPaymentRail(this._railType);
  
  @override
  PaymentRail get railType => _railType;
  
  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String orderId,
  }) async {
    createPaymentCallCount++;
    lastAmountUSD = amountUSD;
    lastOrderId = orderId;
    
    return PaymentRequestExtension.withRailData(
      paymentRef: 'mock_payment_ref_${orderId}_${DateTime.now().millisecondsSinceEpoch}',
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
  Future<PaymentResult> processCallback(Map<String, dynamic> callbackData) async {
    processCallbackCallCount++;
    
    return PaymentResult(
      success: true,
      orderId: callbackData['orderId'] as String?,
      transactionHash: 'mock_tx_hash_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

/// Mock rail that throws generic errors for testing error handling
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

/// Mock rail that throws PaymentException for testing exception preservation
class PaymentExceptionThrowingMockRail implements PaymentRailInterface {
  final PaymentRail _railType;
  
  PaymentExceptionThrowingMockRail(this._railType);
  
  @override
  PaymentRail get railType => _railType;
  
  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String orderId,
  }) async {
    throw PaymentException(
      code: 'RAIL_SPECIFIC_ERROR',
      message: 'Rail-specific payment error',
      orderId: orderId,
      paymentRail: railType.toString(),
    );
  }
  
  @override
  Future<PaymentResult> processCallback(Map<String, dynamic> callbackData) async {
    throw PaymentException(
      code: 'RAIL_CALLBACK_ERROR',
      message: 'Rail-specific callback error',
    );
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