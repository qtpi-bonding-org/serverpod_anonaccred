import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart';
import 'package:anonaccred_server/anonaccred_server.dart';

void main() {
  group('X402 Integration Tests', () {
    setUp(() {
      // Clear any existing rails before each test
      PaymentManager.clearRails();
    });
    
    test('should register X402 rail and create payment through PaymentManager', () async {
      // Initialize X402 rail
      final session = MockSession();
      PaymentManager.initializeX402Rail(session);
      
      // Verify X402 rail is registered
      expect(PaymentManager.isRailRegistered(PaymentRail.x402_http), isTrue);
      
      // Create payment through PaymentManager
      final paymentRequest = await PaymentManager.createPayment(
        session: session,
        railType: PaymentRail.x402_http,
        amountUSD: 25.99,
        orderId: 'integration_test_order_456',
      );
      
      expect(paymentRequest.amountUSD, equals(25.99));
      expect(paymentRequest.orderId, equals('integration_test_order_456'));
      expect(paymentRequest.paymentRef, startsWith('x402_integration_test_order_456_'));
      
      // Verify rail data contains X402-specific information
      final railData = paymentRequest.railData;
      expect(railData['protocol'], equals('x402'));
      expect(railData['facilitatorUrl'], isNotNull);
      expect(railData['destinationAddress'], isNotNull);
    });
    
    test('should handle X402 rail initialization gracefully', () {
      // X402 should not be available initially
      expect(PaymentManager.isRailRegistered(PaymentRail.x402_http), isFalse);
      
      // After initialization, X402 should be available (uses environment defaults)
      final session = MockSession();
      PaymentManager.initializeX402Rail(session);
      
      expect(PaymentManager.isRailRegistered(PaymentRail.x402_http), isTrue);
    });
    
    test('should process X402 payment flow end-to-end', () async {
      // Initialize X402 rail
      final session = MockSession();
      PaymentManager.initializeX402Rail(session);
      
      // Step 1: Create payment
      final paymentRequest = await PaymentManager.createPayment(
        session: session,
        railType: PaymentRail.x402_http,
        amountUSD: 5.00,
        orderId: 'e2e_test_order_789',
      );
      
      expect(paymentRequest.paymentRef, isNotNull);
      
      // Step 2: Simulate payment callback processing
      final rail = PaymentManager.getRail(PaymentRail.x402_http);
      expect(rail, isNotNull);
      
      final callbackData = {
        'paymentRef': paymentRequest.paymentRef,
        'orderId': paymentRequest.orderId,
        'success': true,
      };
      
      final result = await rail!.processCallback(callbackData);
      
      expect(result.success, isTrue);
      expect(result.orderId, equals('e2e_test_order_789'));
      expect(result.transactionHash, isNotNull);
    });
    
    test('should maintain compatibility with existing payment system', () async {
      // Initialize X402 rail
      final session = MockSession();
      PaymentManager.initializeX402Rail(session);
      
      // Register a mock rail for another payment type
      final mockRail = MockPaymentRail(PaymentRail.monero);
      PaymentManager.registerRail(mockRail);
      
      // Verify both rails are registered
      expect(PaymentManager.isRailRegistered(PaymentRail.x402_http), isTrue);
      expect(PaymentManager.isRailRegistered(PaymentRail.monero), isTrue);
      
      // Verify we can create payments with both rails
      final x402Payment = await PaymentManager.createPayment(
        session: session,
        railType: PaymentRail.x402_http,
        amountUSD: 10.00,
        orderId: 'x402_order',
      );
      
      final moneroPayment = await PaymentManager.createPayment(
        session: session,
        railType: PaymentRail.monero,
        amountUSD: 15.00,
        orderId: 'monero_order',
      );
      
      expect(x402Payment.railData['protocol'], equals('x402'));
      expect(moneroPayment.railData['railType'], equals('monero'));
    });
  });
}

/// Mock session for testing
class MockSession implements Session {
  @override
  void log(
    String message, {
    LogLevel? level,
    Object? exception,
    StackTrace? stackTrace,
  }) {
    // Mock logging - do nothing in tests
  }
  
  // Implement other required Session methods as no-ops for testing
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Mock payment rail for testing compatibility
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
      paymentRef: 'mock_${orderId}_${DateTime.now().millisecondsSinceEpoch}',
      amountUSD: amountUSD,
      orderId: orderId,
      railData: {
        'railType': railType.name,
        'mockData': 'test_data',
      },
    );
  }
  
  @override
  Future<PaymentResult> processCallback(Map<String, dynamic> callbackData) async {
    return PaymentResult(
      success: true,
      orderId: callbackData['orderId'] as String?,
      transactionHash: 'mock_tx_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}