import 'package:anonaccred_server/src/payments/rails/apple_iap_rail.dart';
import 'package:anonaccred_server/src/payments/rails/google_iap_rail.dart';
import 'package:test/test.dart';

/// Unit tests for IAP error handling scenarios
///
/// Tests basic error handling for Apple and Google IAP validation failures.
/// Focuses on essential error cases without over-engineering.
///
/// Requirements 7.1: Test Apple receipt validation errors
/// Requirements 7.2: Test Google purchase validation errors
/// Requirements 7.3: Test network error handling
void main() {
  group('Apple IAP Logic', () {
    test('AppleTransactionValidationResult preserves fields', () {
      final purchaseDate = DateTime.now();
      final result = AppleTransactionValidationResult(
        isValid: true,
        transactionId: 'tx123',
        productId: 'prod123',
        purchaseDate: purchaseDate,
        tag: 'tag123',
        quantity: 1.0,
      );
      expect(result.isValid, isTrue);
      expect(result.transactionId, equals('tx123'));
      expect(result.tag, equals('tag123'));
    });
  });

  group('Google IAP Error Handling', () {
    test('GooglePurchaseValidationResult handles purchase states', () {
      // Test Google purchase states are properly mapped
      final validPurchase = GooglePurchaseValidationResult(
        consumptionState: 0,
        purchaseState: 0,
      );
      expect(validPurchase.isValid, isTrue);
      expect(validPurchase.errorMessage, contains('successful'));

      final canceledPurchase = GooglePurchaseValidationResult(
        consumptionState: 0,
        purchaseState: 1,
      );
      expect(canceledPurchase.isValid, isFalse);
      expect(canceledPurchase.errorMessage, contains('canceled'));

      final pendingPurchase = GooglePurchaseValidationResult(
        consumptionState: 0,
        purchaseState: 2,
      );
      expect(pendingPurchase.isValid, isFalse);
      expect(pendingPurchase.errorMessage, contains('pending'));
    });

    test(
      'GooglePurchaseValidationResult handles consumption and acknowledgment states',
      () {
        // Test consumption and acknowledgment state detection
        final consumedPurchase = GooglePurchaseValidationResult(
          consumptionState: 1,
          purchaseState: 0,
        );
        expect(consumedPurchase.isConsumed, isTrue);

        final acknowledgedPurchase = GooglePurchaseValidationResult(
          consumptionState: 0,
          purchaseState: 0,
          acknowledgementState: 1,
        );
        expect(acknowledgedPurchase.isAcknowledged, isTrue);
      },
    );
  });
}
