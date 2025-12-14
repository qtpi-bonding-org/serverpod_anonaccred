import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart';
import 'package:anonaccred_server/anonaccred_server.dart';

void main() {
  group('X402PaymentRail', () {
    late X402PaymentRail rail;
    
    setUp(() {
      // Clear any existing rails before each test
      PaymentManager.clearRails();
      
      // Create X402 rail (uses environment variables)
      rail = X402PaymentRail();
    });
    
    test('should have correct rail type', () {
      expect(rail.railType, equals(PaymentRail.x402_http));
    });
    
    test('should create payment request with correct data', () async {
      final paymentRequest = await rail.createPayment(
        amountUSD: 10.50,
        orderId: 'test_order_123',
      );
      
      expect(paymentRequest.amountUSD, equals(10.50));
      expect(paymentRequest.orderId, equals('test_order_123'));
      expect(paymentRequest.paymentRef, startsWith('x402_test_order_123_'));
      
      // Check rail data
      final railData = paymentRequest.railData;
      expect(railData['facilitatorUrl'], equals('http://localhost:8090/verify'));
      expect(railData['destinationAddress'], equals('bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh'));
      expect(railData['amount'], equals('10.5'));
      expect(railData['currency'], equals('USD'));
      expect(railData['orderId'], equals('test_order_123'));
      expect(railData['protocol'], equals('x402'));
    });
    
    test('should process successful callback', () async {
      final callbackData = {
        'paymentRef': 'x402_test_123',
        'orderId': 'test_order_123',
        'success': true,
      };
      
      final result = await rail.processCallback(callbackData);
      
      expect(result.success, isTrue);
      expect(result.orderId, equals('test_order_123'));
      expect(result.transactionHash, isNotNull);
      expect(result.transactionHash, startsWith('x402_tx_'));
      expect(result.errorMessage, isNull);
    });
    
    test('should process failed callback', () async {
      final callbackData = {
        'paymentRef': 'x402_test_123',
        'orderId': 'test_order_123',
        'success': false,
      };
      
      final result = await rail.processCallback(callbackData);
      
      expect(result.success, isFalse);
      expect(result.orderId, equals('test_order_123'));
      expect(result.transactionHash, isNull);
      expect(result.errorMessage, equals('X402 payment verification failed'));
    });
    
    test('should throw PaymentException for invalid callback data', () async {
      final callbackData = {
        'invalid': 'data',
      };
      
      expect(
        () => rail.processCallback(callbackData),
        throwsA(isA<PaymentException>()),
      );
    });
  });
  

  
  group('PaymentManager X402 Integration', () {
    setUp(() {
      PaymentManager.clearRails();
    });
    
    test('should initialize X402 payment rail', () {
      // Create a mock session for testing
      final session = MockSession();
      
      PaymentManager.initializeX402Rail(session);
      
      // Verify X402 rail is registered
      expect(PaymentManager.isRailRegistered(PaymentRail.x402_http), isTrue);
    });
    
    test('should check X402 availability', () {
      expect(PaymentManager.isRailRegistered(PaymentRail.x402_http), isFalse);
      
      // Register X402 rail
      PaymentManager.registerRail(X402PaymentRail());
      
      expect(PaymentManager.isRailRegistered(PaymentRail.x402_http), isTrue);
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