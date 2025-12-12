import 'package:test/test.dart';
import 'package:anonaccred_server/anonaccred_server.dart';
import 'dart:math';

/// **Feature: anonaccred-phase1-5, Property 2: Exception Pattern Consistency**
/// **Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5**

void main() {
  group('Exception Pattern Consistency Property Tests', () {
    test('Property 2: Exception Pattern Consistency - All AnonAccred operation failures should follow consistent patterns', () {
      // Run 5 iterations during development (can be increased to 100+ for production)
      for (int i = 0; i < 5; i++) {
        // Test authentication operation failures
        _testAuthenticationOperationPatterns();
        
        // Test payment operation failures
        _testPaymentOperationPatterns();
        
        // Test inventory operation failures
        _testInventoryOperationPatterns();
        
        // Test general operation failures
        _testGeneralOperationPatterns();
      }
    });
    
    test('Property 2: Error classification consistency', () {
      // Run 5 iterations during development
      for (int i = 0; i < 5; i++) {
        final errorCode = _generateRandomErrorCode();
        
        // Test that error classification is consistent
        final isRetryable = AnonAccredExceptionUtils.isRetryable(errorCode);
        final severity = AnonAccredExceptionUtils.getErrorSeverity(errorCode);
        final category = AnonAccredExceptionUtils.getErrorCategory(errorCode);
        final guidance = AnonAccredExceptionUtils.getRecoveryGuidance(errorCode);
        
        // Verify classification consistency
        expect(isRetryable, isA<bool>());
        expect(severity, isA<ErrorSeverity>());
        expect(category, isA<ErrorCategory>());
        expect(guidance, isA<String>());
        expect(guidance.isNotEmpty, isTrue);
        
        // Verify retryability logic consistency
        if (errorCode == AnonAccredErrorCodes.networkTimeout || 
            errorCode == AnonAccredErrorCodes.databaseError) {
          expect(isRetryable, isTrue, reason: 'Network and database errors should be retryable');
        }
        
        if (errorCode == AnonAccredErrorCodes.authInvalidSignature ||
            errorCode == AnonAccredErrorCodes.paymentInsufficientFunds) {
          expect(isRetryable, isFalse, reason: 'Client errors should not be retryable');
        }
        
        // Verify severity logic consistency
        if (errorCode == AnonAccredErrorCodes.databaseError ||
            errorCode == AnonAccredErrorCodes.internalError) {
          expect(severity, equals(ErrorSeverity.high), reason: 'System errors should be high severity');
        }
        
        // Verify category logic consistency
        if (errorCode.startsWith('AUTH_')) {
          expect(category, equals(ErrorCategory.authentication));
        } else if (errorCode.startsWith('PAYMENT_')) {
          expect(category, equals(ErrorCategory.payment));
        } else if (errorCode.startsWith('INVENTORY_')) {
          expect(category, equals(ErrorCategory.inventory));
        }
      }
    });
    
    test('Property 2: Exception analysis consistency', () {
      // Run 5 iterations during development
      for (int i = 0; i < 5; i++) {
        // Test different exception types
        final exceptions = [
          _generateRandomAnonAccredException(),
          _generateRandomAuthenticationException(),
          _generateRandomPaymentException(),
          _generateRandomInventoryException(),
        ];
        
        for (final exception in exceptions) {
          final analysis = AnonAccredExceptionUtils.analyzeException(exception);
          
          // Verify analysis structure consistency
          expect(analysis, isA<Map<String, dynamic>>());
          expect(analysis.containsKey('code'), isTrue);
          expect(analysis.containsKey('message'), isTrue);
          expect(analysis.containsKey('retryable'), isTrue);
          expect(analysis.containsKey('severity'), isTrue);
          expect(analysis.containsKey('category'), isTrue);
          expect(analysis.containsKey('recoveryGuidance'), isTrue);
          
          // Verify data types
          expect(analysis['code'], isA<String>());
          expect(analysis['message'], isA<String>());
          expect(analysis['retryable'], isA<bool>());
          expect(analysis['severity'], isA<String>());
          expect(analysis['category'], isA<String>());
          expect(analysis['recoveryGuidance'], isA<String>());
          
          // Verify non-empty values
          expect(analysis['code'].toString().isNotEmpty, isTrue);
          expect(analysis['message'].toString().isNotEmpty, isTrue);
          expect(analysis['recoveryGuidance'].toString().isNotEmpty, isTrue);
        }
      }
    });
  });
}

void _testAuthenticationOperationPatterns() {
  final authCodes = [
    AnonAccredErrorCodes.authInvalidSignature,
    AnonAccredErrorCodes.authExpiredChallenge,
    AnonAccredErrorCodes.authMissingKey,
  ];
  
  for (final code in authCodes) {
    final exception = AnonAccredExceptionFactory.createAuthenticationException(
      code: code,
      message: 'Authentication failed',
      operation: 'test_operation',
    );
    
    // Verify consistent pattern structure
    expect(exception.code, equals(code));
    expect(exception.message, isA<String>());
    expect(exception.operation, isA<String>());
    
    // Verify error classification follows patterns
    final category = AnonAccredExceptionUtils.getErrorCategory(code);
    expect(category, equals(ErrorCategory.authentication));
    
    // Verify recovery guidance is provided
    final guidance = AnonAccredExceptionUtils.getRecoveryGuidance(code);
    expect(guidance.isNotEmpty, isTrue);
  }
}

void _testPaymentOperationPatterns() {
  final paymentCodes = [
    AnonAccredErrorCodes.paymentFailed,
    AnonAccredErrorCodes.paymentInsufficientFunds,
    AnonAccredErrorCodes.paymentInvalidRail,
  ];
  
  for (final code in paymentCodes) {
    final exception = AnonAccredExceptionFactory.createPaymentException(
      code: code,
      message: 'Payment failed',
      orderId: 'test_order_123',
      paymentRail: 'x402',
    );
    
    // Verify consistent pattern structure
    expect(exception.code, equals(code));
    expect(exception.message, isA<String>());
    expect(exception.orderId, isA<String>());
    expect(exception.paymentRail, isA<String>());
    
    // Verify error classification follows patterns
    final category = AnonAccredExceptionUtils.getErrorCategory(code);
    expect(category, equals(ErrorCategory.payment));
    
    // Verify recovery guidance is provided
    final guidance = AnonAccredExceptionUtils.getRecoveryGuidance(code);
    expect(guidance.isNotEmpty, isTrue);
  }
}

void _testInventoryOperationPatterns() {
  final inventoryCodes = [
    AnonAccredErrorCodes.inventoryInsufficientBalance,
    AnonAccredErrorCodes.inventoryInvalidConsumable,
    AnonAccredErrorCodes.inventoryAccountNotFound,
  ];
  
  for (final code in inventoryCodes) {
    final exception = AnonAccredExceptionFactory.createInventoryException(
      code: code,
      message: 'Inventory operation failed',
      accountId: 12345,
      consumableType: 'analysis_credit',
    );
    
    // Verify consistent pattern structure
    expect(exception.code, equals(code));
    expect(exception.message, isA<String>());
    expect(exception.accountId, isA<int>());
    expect(exception.consumableType, isA<String>());
    
    // Verify error classification follows patterns
    final category = AnonAccredExceptionUtils.getErrorCategory(code);
    expect(category, equals(ErrorCategory.inventory));
    
    // Verify recovery guidance is provided
    final guidance = AnonAccredExceptionUtils.getRecoveryGuidance(code);
    expect(guidance.isNotEmpty, isTrue);
  }
}

void _testGeneralOperationPatterns() {
  final generalCodes = [
    AnonAccredErrorCodes.networkTimeout,
    AnonAccredErrorCodes.databaseError,
    AnonAccredErrorCodes.internalError,
  ];
  
  for (final code in generalCodes) {
    final exception = AnonAccredExceptionFactory.createException(
      code: code,
      message: 'General operation failed',
    );
    
    // Verify consistent pattern structure
    expect(exception.code, equals(code));
    expect(exception.message, isA<String>());
    
    // Verify error classification follows patterns
    final category = AnonAccredExceptionUtils.getErrorCategory(code);
    expect(category, isIn([ErrorCategory.network, ErrorCategory.database]));
    
    // Verify recovery guidance is provided
    final guidance = AnonAccredExceptionUtils.getRecoveryGuidance(code);
    expect(guidance.isNotEmpty, isTrue);
  }
}

// Test data generators
String _generateRandomErrorCode() {
  final codes = [
    AnonAccredErrorCodes.authInvalidSignature,
    AnonAccredErrorCodes.authExpiredChallenge,
    AnonAccredErrorCodes.authMissingKey,
    AnonAccredErrorCodes.paymentFailed,
    AnonAccredErrorCodes.paymentInsufficientFunds,
    AnonAccredErrorCodes.paymentInvalidRail,
    AnonAccredErrorCodes.inventoryInsufficientBalance,
    AnonAccredErrorCodes.inventoryInvalidConsumable,
    AnonAccredErrorCodes.inventoryAccountNotFound,
    AnonAccredErrorCodes.networkTimeout,
    AnonAccredErrorCodes.databaseError,
    AnonAccredErrorCodes.internalError,
  ];
  return codes[Random().nextInt(codes.length)];
}

AnonAccredException _generateRandomAnonAccredException() {
  return AnonAccredExceptionFactory.createException(
    code: _generateRandomErrorCode(),
    message: 'Test exception message',
    details: {'test': 'data'},
  );
}

AuthenticationException _generateRandomAuthenticationException() {
  final authCodes = [
    AnonAccredErrorCodes.authInvalidSignature,
    AnonAccredErrorCodes.authExpiredChallenge,
    AnonAccredErrorCodes.authMissingKey,
  ];
  
  return AnonAccredExceptionFactory.createAuthenticationException(
    code: authCodes[Random().nextInt(authCodes.length)],
    message: 'Authentication test exception',
    operation: 'test_auth_operation',
  );
}

PaymentException _generateRandomPaymentException() {
  final paymentCodes = [
    AnonAccredErrorCodes.paymentFailed,
    AnonAccredErrorCodes.paymentInsufficientFunds,
    AnonAccredErrorCodes.paymentInvalidRail,
  ];
  
  return AnonAccredExceptionFactory.createPaymentException(
    code: paymentCodes[Random().nextInt(paymentCodes.length)],
    message: 'Payment test exception',
    orderId: 'test_order_${Random().nextInt(1000)}',
    paymentRail: 'x402',
  );
}

InventoryException _generateRandomInventoryException() {
  final inventoryCodes = [
    AnonAccredErrorCodes.inventoryInsufficientBalance,
    AnonAccredErrorCodes.inventoryInvalidConsumable,
    AnonAccredErrorCodes.inventoryAccountNotFound,
  ];
  
  return AnonAccredExceptionFactory.createInventoryException(
    code: inventoryCodes[Random().nextInt(inventoryCodes.length)],
    message: 'Inventory test exception',
    accountId: Random().nextInt(10000) + 1,
    consumableType: 'analysis_credit',
  );
}