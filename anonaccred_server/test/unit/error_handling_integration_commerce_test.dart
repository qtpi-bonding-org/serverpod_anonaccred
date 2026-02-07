import 'package:test/test.dart';
import 'package:anonaccred_server/anonaccred_server.dart';

/// Tests for error handling integration in commerce components
///
/// Validates that all commerce components use the established
/// AnonAccred error handling patterns consistently.
void main() {
  group('Commerce Error Handling Integration', () {
    setUp(() {
      // Clear registry before each test
      PriceRegistry().clearRegistry();
    });

    test('PriceRegistry throws proper exceptions for invalid inputs', () {
      final registry = PriceRegistry();

      // Test empty SKU
      expect(
        () => registry.registerProduct('', 5.99),
        throwsA(
          isA<PaymentException>().having(
            (e) => e.code,
            'code',
            equals(AnonAccredErrorCodes.priceRegistryInvalidSku),
          ),
        ),
      );

      // Test invalid price (zero)
      expect(
        () => registry.registerProduct('test_item', 0.0),
        throwsA(
          isA<PaymentException>().having(
            (e) => e.code,
            'code',
            equals(AnonAccredErrorCodes.priceRegistryInvalidPrice),
          ),
        ),
      );

      // Test invalid price (negative)
      expect(
        () => registry.registerProduct('test_item', -1.0),
        throwsA(
          isA<PaymentException>().having(
            (e) => e.code,
            'code',
            equals(AnonAccredErrorCodes.priceRegistryInvalidPrice),
          ),
        ),
      );

      // Test invalid price (infinite)
      expect(
        () => registry.registerProduct('test_item', double.infinity),
        throwsA(
          isA<PaymentException>().having(
            (e) => e.code,
            'code',
            equals(AnonAccredErrorCodes.priceRegistryInvalidPrice),
          ),
        ),
      );
    });

    test(
      'OrderManager uses correct error codes for price registry errors',
      () async {
        // Test with unregistered product
        final items = {'unregistered_product': 1.0};

        expect(
          () => OrderManager.calculateTotal(items),
          throwsA(
            isA<PaymentException>().having(
              (e) => e.code,
              'code',
              equals(AnonAccredErrorCodes.priceRegistryProductNotFound),
            ),
          ),
        );
      },
    );

    test('Error classification works for new price registry codes', () {
      // Test retryability
      expect(
        AnonAccredExceptionUtils.isRetryable(
          AnonAccredErrorCodes.priceRegistryProductNotFound,
        ),
        isFalse,
      );
      expect(
        AnonAccredExceptionUtils.isRetryable(
          AnonAccredErrorCodes.priceRegistryOperationFailed,
        ),
        isTrue,
      );

      // Test basic error analysis (lightweight approach)
      final analysis = AnonAccredExceptionUtils.analyzeException(
        AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.priceRegistryInvalidPrice,
          message: 'Invalid price',
        ),
      );
      expect(
        analysis['code'],
        equals(AnonAccredErrorCodes.priceRegistryInvalidPrice),
      );
      expect(analysis['retryable'], isFalse);
    });

    test('Exception analysis works for price registry exceptions', () {
      final exception = AnonAccredExceptionFactory.createPriceRegistryException(
        code: AnonAccredErrorCodes.priceRegistryInvalidPrice,
        message: 'Invalid price',
        sku: 'test_item',
        details: {'price': '0.0'},
      );

      final analysis = AnonAccredExceptionUtils.analyzeException(exception);

      expect(
        analysis['code'],
        equals(AnonAccredErrorCodes.priceRegistryInvalidPrice),
      );
      expect(analysis['message'], equals('Invalid price'));
      expect(analysis['retryable'], isFalse);
      expect(analysis['severity'], equals('low'));
      expect(analysis['category'], equals('payment'));
      expect(analysis['recoveryGuidance'], isNotNull);
    });

    test('Exception factory creates consistent exception structures', () {
      // Test price registry exception creation
      final priceException =
          AnonAccredExceptionFactory.createPriceRegistryException(
            code: AnonAccredErrorCodes.priceRegistryInvalidPrice,
            message: 'Test message',
            sku: 'test_sku',
            details: {'extra': 'data'},
          );

      expect(
        priceException.code,
        equals(AnonAccredErrorCodes.priceRegistryInvalidPrice),
      );
      expect(priceException.message, equals('Test message'));
      expect(priceException.details!['sku'], equals('test_sku'));
      expect(priceException.details!['extra'], equals('data'));
      expect(priceException.orderId, isNull);
      expect(priceException.paymentRail, isNull);
    });
  });
}
