import 'dart:convert';
import 'dart:math';
import 'package:test/test.dart';
import '../../lib/src/generated/payment_request.dart';
import '../../lib/src/payments/payment_rail_interface.dart';

/// Property-based test for payment rail data serialization round trip
/// 
/// **Feature: anonaccred-phase4, Property 4: Payment Rail Data Round Trip**
/// **Validates: Requirements 3.3**
/// 
/// This test verifies that rail-specific data in PaymentRequest.railData
/// preserves all key-value pairs when stored and retrieved through JSON serialization.
void main() {
  group('Payment Rail Data Serialization Property Tests', () {
    test('Property 4: Payment Rail Data Round Trip - 5 iterations', () {
      final random = Random();
      
      for (int i = 0; i < 5; i++) {
        // Generate random rail data with various types
        final railData = _generateRandomRailData(random);
        
        // Create PaymentRequest with rail data
        final originalRequest = PaymentRequestExtension.withRailData(
          paymentRef: 'test-ref-$i',
          amountUSD: 10.0 + random.nextDouble() * 90.0,
          orderId: 'order-$i',
          railData: railData,
        );
        
        // Serialize to JSON and back
        final json = originalRequest.toJson();
        final deserializedRequest = PaymentRequest.fromJson(json);
        
        // Extract rail data from both requests
        final originalRailData = originalRequest.railData;
        final deserializedRailData = deserializedRequest.railData;
        
        // Verify all key-value pairs are preserved
        expect(deserializedRailData.length, equals(originalRailData.length),
            reason: 'Rail data should preserve all keys after round trip');
        
        for (final entry in originalRailData.entries) {
          expect(deserializedRailData.containsKey(entry.key), isTrue,
              reason: 'Key "${entry.key}" should be preserved');
          expect(deserializedRailData[entry.key], equals(entry.value),
              reason: 'Value for key "${entry.key}" should be preserved');
        }
        
        // Verify the rail data matches exactly
        expect(deserializedRailData, equals(originalRailData),
            reason: 'Complete rail data should be identical after round trip');
      }
    });
    
    test('Property 4: Empty rail data round trip', () {
      // Test with empty rail data
      final request = PaymentRequestExtension.withRailData(
        paymentRef: 'test-ref-empty',
        amountUSD: 25.0,
        orderId: 'order-empty',
        railData: <String, dynamic>{},
      );
      
      final json = request.toJson();
      final deserializedRequest = PaymentRequest.fromJson(json);
      
      expect(deserializedRequest.railData, isEmpty,
          reason: 'Empty rail data should remain empty after round trip');
    });
    
    test('Property 4: Complex nested data round trip', () {
      // Test with complex nested structures
      final complexData = {
        'payment_url': 'https://example.com/pay/12345',
        'metadata': {
          'user_id': 'user123',
          'session_id': 'sess456',
          'preferences': ['fast', 'secure'],
        },
        'amounts': {
          'base': 100.0,
          'fees': 2.5,
          'total': 102.5,
        },
        'flags': {
          'test_mode': true,
          'auto_confirm': false,
        },
      };
      
      final request = PaymentRequestExtension.withRailData(
        paymentRef: 'test-ref-complex',
        amountUSD: 102.5,
        orderId: 'order-complex',
        railData: complexData,
      );
      
      final json = request.toJson();
      final deserializedRequest = PaymentRequest.fromJson(json);
      
      expect(deserializedRequest.railData, equals(complexData),
          reason: 'Complex nested data should be preserved exactly');
    });
  });
}

/// Generate random rail data for property testing
Map<String, dynamic> _generateRandomRailData(Random random) {
  final data = <String, dynamic>{};
  final keyCount = 1 + random.nextInt(5); // 1-5 keys
  
  for (int i = 0; i < keyCount; i++) {
    final key = _generateRandomKey(random, i);
    final value = _generateRandomValue(random);
    data[key] = value;
  }
  
  return data;
}

/// Generate a random key for rail data
String _generateRandomKey(Random random, int index) {
  final keys = [
    'payment_url',
    'transaction_id',
    'amount_cents',
    'currency_code',
    'metadata',
    'webhook_url',
    'return_url',
    'expires_at',
    'test_mode',
    'auto_confirm',
  ];
  
  if (index < keys.length) {
    return keys[index];
  }
  
  return 'custom_key_$index';
}

/// Generate a random value for rail data
dynamic _generateRandomValue(Random random) {
  final valueType = random.nextInt(6);
  
  switch (valueType) {
    case 0: // String
      return 'value_${random.nextInt(1000)}';
    case 1: // Integer
      return random.nextInt(10000);
    case 2: // Double
      return random.nextDouble() * 1000;
    case 3: // Boolean
      return random.nextBool();
    case 4: // List
      return List.generate(
        1 + random.nextInt(3),
        (i) => 'item_$i',
      );
    case 5: // Map
      return {
        'nested_key': 'nested_value_${random.nextInt(100)}',
        'nested_number': random.nextInt(100),
      };
    default:
      return 'default_value';
  }
}