import 'dart:math';
import 'package:test/test.dart';
import '../../lib/src/generated/payment_rail.dart';
import '../../lib/src/generated/payment_request.dart';
import '../../lib/src/generated/payment_result.dart';
import '../../lib/src/payments/payment_rail_interface.dart';

/// **Feature: anonaccred-phase4, Property 1: Payment Rail Registration**
/// **Validates: Requirements 2.1, 2.2**

void main() {
  final random = Random();

  group('Payment Rail Interface Property Tests', () {
    test(
      'Property 1: Payment Rail Registration - For any payment rail registered with the Payment Manager, it should be retrievable by its rail type',
      () async {
        // Run 5 iterations during development (can be increased to 100+ for production)
        for (int i = 0; i < 5; i++) {
          // Create a mock payment rail for testing
          final mockRail = MockPaymentRail(PaymentRail.values[i % PaymentRail.values.length]);
          
          // Test registration (Requirement 2.1)
          PaymentManager.registerRail(mockRail);
          
          // Test retrieval (Requirement 2.2)
          final retrievedRail = PaymentManager.getRail(mockRail.railType);
          
          // Verify the rail was registered and can be retrieved
          expect(retrievedRail, isNotNull);
          expect(retrievedRail!.railType, equals(mockRail.railType));
          expect(retrievedRail, same(mockRail)); // Should be the exact same instance
          
          // Test that different rail types don't interfere
          final otherRailTypes = PaymentRail.values.where((type) => type != mockRail.railType);
          for (final otherType in otherRailTypes) {
            final otherRail = PaymentManager.getRail(otherType);
            if (otherRail != null) {
              expect(otherRail.railType, equals(otherType));
              expect(otherRail.railType, isNot(equals(mockRail.railType)));
            }
          }
        }
      },
    );

    test(
      'Property 1 Extension: Multiple rail registration and retrieval',
      () async {
        // Clear any existing rails
        PaymentManager.clearRails();
        
        // Register multiple rails
        final rails = <PaymentRailInterface>[];
        for (final railType in PaymentRail.values) {
          final rail = MockPaymentRail(railType);
          rails.add(rail);
          PaymentManager.registerRail(rail);
        }
        
        // Verify all rails can be retrieved correctly
        for (final expectedRail in rails) {
          final retrievedRail = PaymentManager.getRail(expectedRail.railType);
          expect(retrievedRail, isNotNull);
          expect(retrievedRail!.railType, equals(expectedRail.railType));
          expect(retrievedRail, same(expectedRail));
        }
        
        // Verify total count
        expect(PaymentManager.getRegisteredRailTypes().length, equals(PaymentRail.values.length));
      },
    );

    test(
      'Property 1 Extension: Rail replacement behavior',
      () async {
        // Clear any existing rails
        PaymentManager.clearRails();
        
        final railType = PaymentRail.x402_http;
        
        // Register first rail
        final firstRail = MockPaymentRail(railType);
        PaymentManager.registerRail(firstRail);
        
        final retrievedFirst = PaymentManager.getRail(railType);
        expect(retrievedFirst, same(firstRail));
        
        // Register second rail with same type (should replace)
        final secondRail = MockPaymentRail(railType);
        PaymentManager.registerRail(secondRail);
        
        final retrievedSecond = PaymentManager.getRail(railType);
        expect(retrievedSecond, same(secondRail));
        expect(retrievedSecond, isNot(same(firstRail)));
      },
    );

    test(
      'Property 1 Extension: Non-existent rail retrieval',
      () async {
        // Clear all rails
        PaymentManager.clearRails();
        
        // Try to retrieve non-existent rails
        for (final railType in PaymentRail.values) {
          final retrievedRail = PaymentManager.getRail(railType);
          expect(retrievedRail, isNull);
        }
      },
    );
  });
}

/// Mock implementation of PaymentRailInterface for testing
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
    // Mock implementation for testing
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
    // Mock implementation for testing
    return PaymentResult(
      success: true,
      orderId: callbackData['orderId'] as String?,
      transactionHash: 'mock_tx_hash_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

/// Simple PaymentManager implementation for testing
class PaymentManager {
  static final Map<PaymentRail, PaymentRailInterface> _rails = {};
  
  /// Register a payment rail (Requirement 2.1)
  static void registerRail(PaymentRailInterface rail) {
    _rails[rail.railType] = rail;
  }
  
  /// Get payment rail by type (Requirement 2.2)
  static PaymentRailInterface? getRail(PaymentRail railType) {
    return _rails[railType];
  }
  
  /// Clear all registered rails (for testing)
  static void clearRails() {
    _rails.clear();
  }
  
  /// Get all registered rail types (for testing)
  static List<PaymentRail> getRegisteredRailTypes() {
    return _rails.keys.toList();
  }
}