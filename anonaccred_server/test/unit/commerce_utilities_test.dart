import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:test/test.dart';

void main() {
  group('Commerce Utilities Tests', () {
    group('InventoryUtils', () {
      test('ConsumeResult structure is correct', () {
        // Test successful consumption result
        final successResult = ConsumeResult(
          success: true,
          availableBalance: 50.0,
        );

        expect(successResult.success, isTrue);
        expect(successResult.availableBalance, equals(50.0));
        expect(successResult.errorMessage, isNull);

        // Test failed consumption result
        final failureResult = ConsumeResult(
          success: false,
          availableBalance: 10.0,
          errorMessage: 'Insufficient balance',
        );

        expect(failureResult.success, isFalse);
        expect(failureResult.availableBalance, equals(10.0));
        expect(failureResult.errorMessage, equals('Insufficient balance'));
      });
    });

    // Note: TransactionUtil tests removed - over-engineered transaction management
    // Use Serverpod's built-in transaction patterns instead
  });
}
