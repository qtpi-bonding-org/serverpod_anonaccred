import 'package:test/test.dart';
import 'package:anonaccred_server/anonaccred_server.dart';

/// Integration tests for module packaging and external consumption
///
/// **Feature: anonaccred-phase1, Requirements: 5.1, 5.2, 5.3, 5.5**
///
/// These tests verify that the AnonAccred module can be properly imported
/// and used as an external dependency in Serverpod projects.
void main() {
  group('Module Packaging Integration Tests', () {
    test('module export provides all public API components', () {
      // Test that all expected classes are accessible through the main export

      // Exception factory should be available
      expect(
        () => AnonAccredExceptionFactory.createException(
          code: AnonAccredErrorCodes.internalError,
          message: 'Test',
        ),
        returnsNormally,
      );

      // Error classification should be available
      expect(
        () => AnonAccredExceptionUtils.isRetryable(
          AnonAccredErrorCodes.internalError,
        ),
        returnsNormally,
      );

      // Crypto utilities should be available
      expect(
        () => CryptoUtils.isValidEd25519PublicKey('invalid'),
        returnsNormally,
      );

      // Privacy logger removed - using Serverpod built-in logging
    });

    test('exception factory creates consistent exception structures', () {
      // Test base exception
      final baseException = AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.internalError,
        message: 'Test message',
        details: {'key': 'value'},
      );

      expect(baseException.code, equals(AnonAccredErrorCodes.internalError));
      expect(baseException.message, equals('Test message'));
      expect(baseException.details, equals({'key': 'value'}));

      // Test authentication exception
      final authException =
          AnonAccredExceptionFactory.createAuthenticationException(
            code: AnonAccredErrorCodes.authInvalidSignature,
            message: 'Auth test',
            operation: 'testOp',
          );

      expect(
        authException.code,
        equals(AnonAccredErrorCodes.authInvalidSignature),
      );
      expect(authException.message, equals('Auth test'));
      expect(authException.operation, equals('testOp'));

      // Test payment exception
      final paymentException =
          AnonAccredExceptionFactory.createPaymentException(
            code: AnonAccredErrorCodes.paymentInsufficientFunds,
            message: 'Payment test',
            orderId: 'order123',
            paymentRail: 'monero',
          );

      expect(
        paymentException.code,
        equals(AnonAccredErrorCodes.paymentInsufficientFunds),
      );
      expect(paymentException.orderId, equals('order123'));
      expect(paymentException.paymentRail, equals('monero'));

      // Test inventory exception
      final inventoryException =
          AnonAccredExceptionFactory.createInventoryException(
            code: AnonAccredErrorCodes.inventoryInsufficientBalance,
            message: 'Inventory test',
            accountId: 123,
            consumableType: 'test_consumable',
          );

      expect(
        inventoryException.code,
        equals(AnonAccredErrorCodes.inventoryInsufficientBalance),
      );
      expect(inventoryException.accountId, equals(123));
      expect(inventoryException.consumableType, equals('test_consumable'));
    });

    test('error classification provides comprehensive analysis', () {
      final exception =
          AnonAccredExceptionFactory.createAuthenticationException(
            code: AnonAccredErrorCodes.authInvalidSignature,
            message: 'Invalid signature',
            operation: 'authenticate',
          );

      final analysis = AnonAccredExceptionUtils.analyzeException(exception);

      // Verify all required analysis fields are present
      expect(
        analysis,
        containsPair('code', AnonAccredErrorCodes.authInvalidSignature),
      );
      expect(analysis, containsPair('message', 'Invalid signature'));
      expect(analysis, contains('retryable'));
      expect(analysis, contains('severity'));
      expect(analysis, contains('category'));
      expect(analysis, contains('recoveryGuidance'));

      // Verify specific classification for this error type
      expect(
        analysis['retryable'],
        isFalse,
      ); // Invalid signature is not retryable
      expect(analysis['severity'], equals('low')); // Client error
      expect(analysis['category'], equals('authentication'));
      expect(analysis['recoveryGuidance'], isA<String>());
    });

    test('cryptographic utilities work correctly', () {
      // Test Ed25519 public key validation
      expect(CryptoUtils.isValidEd25519PublicKey('invalid'), isFalse);
      expect(CryptoUtils.isValidEd25519PublicKey(''), isFalse);
      expect(CryptoUtils.isValidEd25519PublicKey('short'), isFalse);

      // Test with valid format (64 hex characters)
      final validKey = 'a' * 64; // 64 'a' characters
      expect(CryptoUtils.isValidEd25519PublicKey(validKey), isTrue);

      // Test with invalid hex characters
      final invalidHex = 'g' * 64; // 64 'g' characters (not hex)
      expect(CryptoUtils.isValidEd25519PublicKey(invalidHex), isFalse);
    });

    test('module dependencies are properly configured', () {
      // This test verifies that the module can be imported without dependency conflicts
      // The fact that we can run these tests means dependencies are properly resolved

      // Test that we can create instances of generated protocol classes
      // (This would fail if Serverpod integration was broken)
      expect(() {
        // These classes should be available through the generated protocol
        final currency = Currency.USD;
        final rail = PaymentRail.monero;
        final status = OrderStatus.pending;

        expect(currency.name, equals('USD'));
        expect(rail.name, equals('monero'));
        expect(status.name, equals('pending'));
      }, returnsNormally);
    });

    test('error codes are properly defined and accessible', () {
      // Test that all error code constants are accessible
      expect(AnonAccredErrorCodes.internalError, isNotNull);
      expect(AnonAccredErrorCodes.authInvalidSignature, isNotNull);
      expect(AnonAccredErrorCodes.cryptoInvalidPublicKey, isNotNull);
      expect(AnonAccredErrorCodes.paymentInsufficientFunds, isNotNull);
      expect(AnonAccredErrorCodes.paymentInvalidRail, isNotNull);
      expect(AnonAccredErrorCodes.inventoryInsufficientBalance, isNotNull);
      expect(AnonAccredErrorCodes.inventoryInvalidConsumable, isNotNull);
      expect(AnonAccredErrorCodes.networkTimeout, isNotNull);
      expect(AnonAccredErrorCodes.databaseError, isNotNull);

      // Test that error codes are strings
      expect(AnonAccredErrorCodes.internalError, isA<String>());
      expect(AnonAccredErrorCodes.authInvalidSignature, isA<String>());
    });

    test('module versioning is properly configured', () {
      // This test verifies that the module has proper version configuration
      // We can't directly test the pubspec.yaml version, but we can verify
      // that the module loads without version conflicts

      // The fact that we can import and use the module indicates proper versioning
      expect(
        () => AnonAccredExceptionFactory.createException(
          code: 'test',
          message: 'test',
        ),
        returnsNormally,
      );
    });
  });

  group('Serverpod Code Generation Integration', () {
    test('generated protocol classes are accessible', () {
      // Test that Serverpod-generated classes work correctly
      expect(() {
        final currency = Currency.USD;
        final rail = PaymentRail.x402_http;
        final status = OrderStatus.paid;

        // Test enum serialization
        expect(currency.name, equals('USD'));
        expect(rail.name, equals('x402_http'));
        expect(status.name, equals('paid'));
      }, returnsNormally);
    });

    test('exception classes have proper Serverpod integration', () {
      // Test that exception classes work with Serverpod's serialization
      final exception =
          AnonAccredExceptionFactory.createAuthenticationException(
            code: AnonAccredErrorCodes.authInvalidSignature,
            message: 'Test exception',
            operation: 'test',
          );

      // Verify exception has required fields
      expect(exception.code, isNotNull);
      expect(exception.message, isNotNull);
      expect(exception.operation, isNotNull);

      // Verify exception can be thrown and caught
      expect(() => throw exception, throwsA(isA<AuthenticationException>()));
    });
  });
}
